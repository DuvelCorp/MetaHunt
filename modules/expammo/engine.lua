------------------------------------------------------
-- MetaHunt: Experimental Ammunition Tracker
-- TWoW 1.18.1 — "Nightmares of Ursol"
------------------------------------------------------
--
-- Mechanic (confirmed from live 1.18.1 talent tooltip):
--   Aimed Shot triggers a cyclic 3-state ammo sequence:
--     EXPLOSIVE (60s) → POISONOUS (60s) → ENCHANTED (60s)
--   Each Aimed Shot (re)starts the cycle at EXPLOSIVE.
--   Each state is consumed early by the matching shot:
--     EXPLOSIVE → Multi-Shot     (AoE fire explosion)
--     POISONOUS → Serpent Sting  (corrosive poison 15s)
--     ENCHANTED → Arcane Shot    (magic resist debuff 6s)
--   Whether consumed or expired, the next state begins
--   automatically. After ENCHANTED the cycle ends; the
--   next Aimed Shot will restart it.
--
--   Requires: Experimental Ammunition talent (MM, 1 rank).
--   Module auto-hides if player does not have the talent.
------------------------------------------------------

local MODULE_NAME    = "expammo"
local CYCLE_DURATION = 60     -- seconds per ammo state
local TALENT_NAME    = "Experimental Ammunition"

-- ── Spell names (English) ────────────────────────────────────
local SPELL_AIMED   = "Aimed Shot"
local SPELL_STEADY  = "Steady Shot"
local SPELL_MULTI   = "Multi-Shot"
local SPELL_ARCANE  = "Arcane Shot"
local SPELL_SERPENT = "Serpent Sting"

-- ── Buff names (English, as shown in buff bar) ───────────────
-- These match the talent tooltip text for each state.
local BUFF_EXPLOSIVE = "Explosive Ammunition"
local BUFF_POISONOUS = "Poisonous Ammunition"
local BUFF_ENCHANTED = "Enchanted Ammunition"

-- ── State IDs ────────────────────────────────────────────────
local IDLE      = "IDLE"
local EXPLOSIVE = "EXPLOSIVE"
local POISONOUS = "POISONOUS"
local ENCHANTED = "ENCHANTED"

local STATE_ORDER = { EXPLOSIVE, POISONOUS, ENCHANTED }

-- Buff name for each state (for recovery scan on login)
local STATE_BUFF = {
	[EXPLOSIVE] = BUFF_EXPLOSIVE,
	[POISONOUS] = BUFF_POISONOUS,
	[ENCHANTED] = BUFF_ENCHANTED,
}

-- Spell that consumes each state
local CONSUME_SPELL = {
	[EXPLOSIVE] = SPELL_MULTI,
	[POISONOUS] = SPELL_SERPENT,
	[ENCHANTED] = SPELL_ARCANE,
}

-- Reverse lookup: buff name → state key (used for CHAT_MSG matching)
-- Built at load time so hot-path matching is a simple table index.
local BUFF_TO_STATE = {}
for _, sk in ipairs(STATE_ORDER) do
	BUFF_TO_STATE[STATE_BUFF[sk]] = sk
end

-- State that follows each state (nil = IDLE)
local NEXT_STATE = {
	[EXPLOSIVE] = POISONOUS,
	[POISONOUS] = ENCHANTED,
	[ENCHANTED] = nil,   -- cycle ends; restart on next Aimed Shot
}

-- Prediction: which state will the server send next time Aimed Shot fires?
-- The server tracks cycle position: EXPLOSIVE→POISONOUS→ENCHANTED, then restarts.
-- After ENCHANTED (or no prior cycle) the next state is EXPLOSIVE.
local PREDICT_NEXT = {
	[EXPLOSIVE] = POISONOUS,
	[POISONOUS] = ENCHANTED,
	[ENCHANTED] = EXPLOSIVE,   -- full cycle done: restart
}

-- ── Per-cell appearance ───────────────────────────────────────
local CELL_DEF = {
	{ state = EXPLOSIVE, label = "Explosive", r = 1.00, g = 0.38, b = 0.05,
	  icon = "Interface\\Icons\\Ability_SearingArrow" },
	{ state = POISONOUS, label = "Poisonous", r = 0.12, g = 0.85, b = 0.18,
	  icon = "Interface\\Icons\\Ability_PoisonArrow" },
	{ state = ENCHANTED, label = "Enchanted", r = 0.38, g = 0.12, b = 1.00,
	  icon = "Interface\\Icons\\Ability_TheBlackArrow" },
}

-- ── Creature-type immunity rules ──────────────────────────────
-- Maps UnitCreatureType("target") → set of ammo states the target resists.
-- Used by PLAYER_TARGET_CHANGED to proactively flag blocked states.
local CREATURE_TYPE_IMMUNITIES = {
	["Elemental"] = { [POISONOUS] = true },   -- Elementals are Nature-immune
}

-- ── Talent gate ──────────────────────────────────────────────
-- The module only shows if the player has the talent.
-- Checked on login and whenever MTH_HT_OnScanComplete fires.
local MTH_EA_HasTalent = false

-- ── Volatile runtime state (not persisted) ────────────────────
local rt = {
	state     = IDLE,
	expiresAt = 0,
	consumed  = false,
	lastState = nil,   -- ammo state that most recently ended; used for predictive display
}

local MTH_EA_PendingAuraRescan = 0

-- Prediction verification timer.  When SPELLCAST_STOP sets a predictive
-- ammo state, we record GetTime()+1.5 here.  OnUpdate checks this and,
-- if the state is still the predicted one (no server confirmation arrived),
-- performs a hard aura scan.  If the aura isn't present, the phantom state
-- is cleared to IDLE.  Set to 0 when no verification is pending.
local MTH_EA_PredictVerifyAt = 0

local function MTH_EA_RequestAuraRescan(delay)
	delay = tonumber(delay) or 0.05
	if delay < 0 then
		delay = 0
	end
	if MTH_EA_PendingAuraRescan <= 0 or delay < MTH_EA_PendingAuraRescan then
		MTH_EA_PendingAuraRescan = delay
	end
end

-- ── NamPower integration ─────────────────────────────────────
-- When NamPower ≥ 2.40.0 is present, VARIABLES_LOADED unregisters
-- the 5 chat events + PLAYER_AURAS_CHANGED and registers the 4 exact
-- spellId aura events instead.  Falls back to the old path otherwise.
local MTH_EA_UseNamPower    = false
local MTH_EA_SpellIdToState = {}   -- [spellId] → EXPLOSIVE/POISONOUS/ENCHANTED (lazy)
local MTH_EA_LnLSpellId     = nil  -- Lock and Load spellId (resolved on first gain)

-- ── Aura probe for state recovery and PLAYER_AURAS_CHANGED ──
-- Combat log shows "You are afflicted by Explosive Ammunition"
-- meaning the ammo state is implemented as a player DEBUFF, not
-- a buff.  We scan both pools so we work either way.
local MTH_EA_BuffProbe = nil
local function MTH_EA_EnsureProbe()
	if not MTH_EA_BuffProbe then
		MTH_EA_BuffProbe = CreateFrame("GameTooltip", "MTH_EA_BuffProbeTooltip", UIParent, "GameTooltipTemplate")
		MTH_EA_BuffProbe:SetOwner(UIParent, "ANCHOR_NONE")
	end
	return MTH_EA_BuffProbe
end

-- Get the name of buff (isDebuff=false) or debuff (isDebuff=true) at slot index.
local function MTH_EA_GetAuraName(isDebuff, index)
	local probe = MTH_EA_EnsureProbe()
	if not probe then return nil end
	local ok
	if isDebuff then
		ok = pcall(function() probe:SetUnitDebuff("player", index) end)
	else
		ok = pcall(function() probe:SetUnitBuff("player", index) end)
	end
	if not ok then return nil end
	local text = getglobal("MTH_EA_BuffProbeTooltipTextLeft1")
	local name = text and text:GetText() or nil
	if name == "" then return nil end
	return name
end

-- Scan the player's buff list for "Lock and Load" and return its
-- actual remaining seconds by reading the tooltip duration line.
-- Returns nil if the buff is not found or duration can't be parsed.
local function MTH_EA_GetLnLRemaining()
	local probe = MTH_EA_EnsureProbe()
	if not probe then return nil end
	for i = 1, 32 do
		local ok = pcall(function() probe:SetUnitBuff("player", i) end)
		if not ok then return nil end
		local t1   = getglobal("MTH_EA_BuffProbeTooltipTextLeft1")
		local name = t1 and t1:GetText() or nil
		if not name or name == "" then return nil end
		if string.find(name, "Lock and Load", 1, true) then
			-- The game tooltip shows duration on subsequent lines,
			-- e.g. "8 sec remaining" or "Remaining: 8 sec"
			for ln = 2, 5 do
				local lt = getglobal("MTH_EA_BuffProbeTooltipTextLeft" .. ln)
				local ls = lt and lt:GetText() or nil
				if ls and ls ~= "" then
					local _, _, n = string.find(ls, "(%d+%.?%d*)%s+sec")
					if n then return tonumber(n) end
				end
				local rt2 = getglobal("MTH_EA_BuffProbeTooltipTextRight" .. ln)
				local rs  = rt2 and rt2:GetText() or nil
				if rs and rs ~= "" then
					local _, _, n = string.find(rs, "(%d+%.?%d*)%s+sec")
					if n then return tonumber(n) end
				end
			end
			-- Buff found but no parseable duration text.
			return nil
		end
	end
	return nil
end

-- ── Fast texture-based aura scanners (no tooltip, no pcall) ─────────────────
-- UnitBuff("player", i)   → icon texture path for buff slot i  (nil = end)
-- UnitDebuff("player", i) → icon texture path for debuff slot i (nil = end)
-- We match by icon basename instead of buff name: zero rendering cost.

-- Known icon basenames (lower-case, no path prefix, no extension):
local MTH_EA_AMMO_TEX = {
	[EXPLOSIVE] = "ability_searingarrow",
	[POISONOUS] = "ability_poisonarrow",
	[ENCHANTED] = "ability_theblackarrow",
}
local MTH_EA_LNL_TEX = "lockandload"   -- matches "ability_hunter_lockandload"

local function MTH_EA_IconBasename(texturePath)
	if not texturePath then return "" end
	local s = string.lower(tostring(texturePath))
	local _, _, base = string.find(s, "([^\\]+)$")
	base = base or s
	-- strip extension (.blp, .tga, etc.) if present
	base = string.gsub(base, "%.[a-z]+$", "")
	return base
end

-- Scan player buffs+debuffs for an active ammo state via texture comparison.
local function MTH_EA_FindAmmoStateByTexture()
	for i = 1, 32 do
		local t = UnitBuff("player", i)
		if not t then break end
		local base = MTH_EA_IconBasename(t)
		for stateKey, frag in pairs(MTH_EA_AMMO_TEX) do
			if string.find(base, frag, 1, true) then return stateKey end
		end
	end
	for i = 1, 16 do
		local t = UnitDebuff("player", i)
		if not t then break end
		local base = MTH_EA_IconBasename(t)
		for stateKey, frag in pairs(MTH_EA_AMMO_TEX) do
			if string.find(base, frag, 1, true) then return stateKey end
		end
	end
	return nil
end

-- Returns true if LnL buff is currently on the player.
local function MTH_EA_HasLnLByTexture()
	for i = 1, 32 do
		local t = UnitBuff("player", i)
		if not t then break end
		if string.find(MTH_EA_IconBasename(t), MTH_EA_LNL_TEX, 1, true) then
			return true
		end
	end
	return false
end

-- Scan all player auras (buffs then debuffs) for an active ammo state.
-- Returns the matching STATE_ORDER key, or nil if none found.
-- (Delegates to the fast texture path; tooltip path kept for debug use only.)
local MTH_EA_SetState
local function MTH_EA_FindAmmoAura()
	return MTH_EA_FindAmmoStateByTexture()
end

-- Restore cycle state from active auras (survives /reload within session).
local function MTH_EA_RecoverStateFromBuffs()
	local stateKey = MTH_EA_FindAmmoAura()
	if stateKey then
		rt.state     = stateKey
		rt.expiresAt = GetTime() + CYCLE_DURATION
		rt.consumed  = false
		MTH_EA_PredictVerifyAt = 0  -- server confirmed; cancel pending verify
	elseif rt.state ~= IDLE then
		MTH_EA_SetState(IDLE)
	end
end

-- ── Saved config access ───────────────────────────────────────
local function MTH_EA_GetConfig()
	if type(MTH_SavedVariables) ~= "table" then
		return {}
	end
	if type(MTH_SavedVariables.modules) ~= "table" then
		MTH_SavedVariables.modules = {}
	end
	if type(MTH_SavedVariables.modules[MODULE_NAME]) ~= "table" then
		MTH_SavedVariables.modules[MODULE_NAME] = {}
	end
	return MTH_SavedVariables.modules[MODULE_NAME]
end

function MTH_EA_IsEnabled()
	local cfg = MTH_EA_GetConfig()
	if cfg.enabled == nil then cfg.enabled = false end
	return cfg.enabled == true
end

local function MTH_EA_EnsureConfigDefaults()
	local cfg = MTH_EA_GetConfig()
	if cfg.enabled  == nil then cfg.enabled  = false end
	if cfg.showLnL  == nil then cfg.showLnL  = true  end
	if cfg.showHint == nil then cfg.showHint = true  end
	if cfg.cellSize == nil then cfg.cellSize = 40    end
	if cfg.cellGap  == nil then cfg.cellGap  = 2     end
	if cfg.bigCD           == nil then cfg.bigCD           = false end
	if cfg.hideOOC         == nil then cfg.hideOOC         = false end
	if cfg.useQuiverNoClip == nil then cfg.useQuiverNoClip = false end
	if cfg.blockExplosive  == nil then cfg.blockExplosive  = false end
	if cfg.blockPoisonous  == nil then cfg.blockPoisonous  = false end
	if cfg.blockEnchanted  == nil then cfg.blockEnchanted  = false end
end

-- Combat state flag (avoids needing InCombatLockdown, which doesn't exist in 1.12)
local inCombat = false

-- ── Runtime immunity / block tracking ─────────────────────────
-- Volatile: refreshed on PLAYER_TARGET_CHANGED and combat-log "immune" messages.
local MTH_EA_BlockedStates = {}   -- [state] = true if creature-type or reactive immunity

function MTH_EA_IsStateBlocked(state)
	if not state or state == IDLE then return false end
	local cfg = MTH_EA_GetConfig()
	if state == EXPLOSIVE and cfg.blockExplosive then return true end
	if state == POISONOUS and cfg.blockPoisonous then return true end
	if state == ENCHANTED and cfg.blockEnchanted then return true end
	if MTH_EA_BlockedStates[state] then return true end
	return false
end

-- Throttle for PLAYER_AURAS_CHANGED: even with the fast texture path this event
-- fires 10-50+/sec in combat, so cap processing at ~6/sec.
local MTH_EA_AurasChangedLastTime = 0

-- UI frame handles — declared here so MTH_EA_RefreshVisibility (and every
-- function defined below) all close over the SAME locals.
local strip       = nil   -- root positioning frame (sized to cross bounding box)
local cells       = {}    -- [1..3] ammo state cells
local cdTexts     = {}    -- [1..3] countdown fontstrings in ammo cells
local cellTop     = nil   -- Lock and Load cell
local cellTopCD   = nil   -- L&L countdown fontstring
local cellBot     = nil   -- action hint cell (display only, click-through)
local cellBotIcon = nil   -- action button icon texture
local cellBotCD   = nil   -- action button CD / "READY" text
local cellBotBlink = 0    -- blink phase accumulator
local anchorFrames = {}   -- [1..4] = BOTTOM, TOP, LEFT, RIGHT drag handles
local MTH_EA_SnapAnchor   -- forward declaration (defined after ApplyLayout)

-- Show/hide the strip according to enabled + hideOOC + inCombat
local function MTH_EA_RefreshVisibility()
	if not strip then return end
	local cfg = MTH_EA_GetConfig()
	local enabled  = MTH_EA_IsEnabled()
	local hideOOC  = cfg.hideOOC == true
	local shouldShow = enabled and (not hideOOC or inCombat)
	if shouldShow then strip:Show() else strip:Hide() end
end

-- ── Forward declarations ────────────────────────────────────────────
local MTH_EA_UpdateUI
local MTH_EA_ApplyLayout

-- ── State machine ─────────────────────────────────────────────
MTH_EA_SetState = function(newState)
	-- Track which state just ended so the predictive display knows what comes next.
	if newState == IDLE and rt.state ~= IDLE then
		rt.lastState = rt.state
	end
	rt.state    = newState
	rt.consumed = false
	rt.expiresAt = (newState ~= IDLE) and (GetTime() + CYCLE_DURATION) or 0
	-- Any authoritative state transition cancels a pending prediction verify,
	-- because the state is now confirmed (or corrected) by the server.
	MTH_EA_PredictVerifyAt = 0
	MTH_EA_UpdateUI()
end

local function MTH_EA_AdvanceState()
	local next = NEXT_STATE[rt.state]
	MTH_EA_SetState(next or IDLE)
end

-- ── UI: Cross layout ─────────────────────────────────────────
--
--        [TOP]        ← Lock and Load tracker
--   [EXP][POI][ENC]  ← 3 ammo-state cells
--        [BOT]        ← Action button: consume-spell or Aimed Shot
--
-- TOP and BOT are aligned with the centre cell (Poisonous, index 2).
--
local CELL_SIZE = 40
local CELL_GAP  = 2
local CELL_FONT = STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF"  -- reused by ApplyLayout

-- Lock and Load tracking state (independent of ammo cycle)
local lnl = {
	active    = false,
	expiresAt = 0,
	DURATION  = 10,  -- Lock and Load real duration (tooltip: "Lasts 10 sec or until Aimed Shot is cast")
}

-- ── Confirmed icon paths (captured in-game 2026-03-21) ────────
-- Action-button spells (spellbook scan)
local ICON_AIMED   = "Interface\\Icons\\INV_Spear_07"
local ICON_STEADY  = "Interface\\Icons\\Ability_Hunter_SteadyShot"
local ICON_MULTI   = "Interface\\Icons\\Ability_UpgradeMoonGlaive"
local ICON_SERPENT = "Interface\\Icons\\Ability_Hunter_QuickShot"
local ICON_ARCANE  = "Interface\\Icons\\Ability_ImpalingBolt"
-- Aura/effect textures (aura-dump debug capture)
local ICON_EXP     = "Interface\\Icons\\Ability_SearingArrow"       -- Explosive Ammunition debuff
local ICON_POI     = "Interface\\Icons\\Ability_PoisonArrow"         -- Poisonous Ammunition debuff
local ICON_ENC     = "Interface\\Icons\\Ability_TheBlackArrow"       -- Enchanted Ammunition debuff
local ICON_LNL     = "Interface\\Icons\\ability_hunter_lockandload"  -- Lock and Load buff

-- ── LnL icon capture via aura diff ───────────────────────────
-- Lock and Load is a proc buff, not in the spellbook.
-- Strategy: snapshot all current buff textures while idle; when the
-- GAIN chat-message fires we flag a pending capture; the next
-- PLAYER_AURAS_CHANGED confirms the buff is on the unit and we diff
-- to extract the new texture.
local lnlBaselineBuffs  = {}   -- kept for compat; aura-diff no longer used
local lnlPendingCapture = false

local function MTH_EA_SnapshotBuffs()
	-- No-op: ICON_LNL is hardcoded. Kept so call sites don't error.
end

local function MTH_EA_TryCaptureNewBuffIcon()
	-- No-op: ICON_LNL is hardcoded. The aura-diff path was removed because it
	-- caused incorrect icons (e.g. Quick Shots) when other buffs landed at the
	-- same time as Lock and Load.
	lnlPendingCapture = false
end

-- ── Action-bar slot cache ────────────────────────────────────
-- Maps spell names to action bar slot numbers via icon texture comparison.
-- Much more reliable than tooltip probing in 1.12 clients.
local MTH_EA_ActionSlotCache = {}   -- [spellName] = slot or false

-- Known spell icon textures (lowercase) for action bar matching.
-- These are the SPELLBOOK icons, which match what GetActionTexture returns.
local MTH_EA_SPELL_ICONS = {
	[SPELL_AIMED]   = string.lower(ICON_AIMED),
	[SPELL_STEADY]  = string.lower(ICON_STEADY),
	[SPELL_MULTI]   = string.lower(ICON_MULTI),
	[SPELL_ARCANE]  = string.lower(ICON_ARCANE),
	[SPELL_SERPENT] = string.lower(ICON_SERPENT),
}

-- Invalidate the slot cache (call on login and action bar changes).
local function MTH_EA_ClearActionSlotCache()
	MTH_EA_ActionSlotCache = {}
end

-- Find the action bar slot for a spell by comparing action icon textures.
-- Returns slot number or nil.  Result is cached until invalidated.
local function MTH_EA_FindActionSlot(spellName)
	if not spellName then return nil end
	local cached = MTH_EA_ActionSlotCache[spellName]
	if cached ~= nil then
		return cached or nil  -- false → nil (scanned, not found)
	end
	local wantIcon = MTH_EA_SPELL_ICONS[spellName]
	if not wantIcon then
		MTH_EA_ActionSlotCache[spellName] = false
		return nil
	end
	for slot = 1, 120 do
		if HasAction(slot) and not GetActionText(slot) then
			local tex = GetActionTexture(slot)
			if tex and string.lower(tex) == wantIcon then
				MTH_EA_ActionSlotCache[spellName] = slot
				return slot
			end
		end
	end
	MTH_EA_ActionSlotCache[spellName] = false
	return nil
end

-- Cooldown via action bar slot (secondary path).
local function MTH_EA_ActionSpellCD(spellName)
	local slot = MTH_EA_FindActionSlot(spellName)
	if not slot then return 0 end
	if type(GetActionCooldown) ~= "function" then return 0 end
	local start, duration = GetActionCooldown(slot)
	if not start or not duration or duration <= 1.5 then return 0 end
	return math.max(0, (start + duration) - GetTime())
end

-- Cooldown via spellbook (primary, always reliable).
-- Uses the hunter talent scanner's cached spellbook slot.
local function MTH_EA_SpellbookCD(spellName)
	if type(MTH_HT_GetSpellInfo) ~= "function" then return 0 end
	if type(GetSpellCooldown) ~= "function" then return 0 end
	local info = MTH_HT_GetSpellInfo(spellName)
	if not info or not info.slot then return 0 end
	local start, duration = GetSpellCooldown(info.slot, "spell")
	if not start or not duration or duration <= 1.5 then return 0 end
	return math.max(0, (start + duration) - GetTime())
end

-- Returns remaining cooldown of a spell in seconds (0 = ready).
-- Primary: spellbook slot (always available, no action bar needed).
-- Secondary: action bar slot via icon texture matching.
local function MTH_EA_GetSpellCD(spellName)
	local cd = MTH_EA_SpellbookCD(spellName)
	if cd > 0 then return cd end
	return MTH_EA_ActionSpellCD(spellName)
end

-- Action button: what spell to show and what spell to cast right now.
-- Returns displaySpell, icon, r, g, b, cooldownRemaining, castSpell
local function MTH_EA_GetActionSpell()
	-- If current ammo state is blocked (creature immune or rotation toggle),
	-- skip the consume-spell and fall through to Aimed/Steady instead.
	if rt.state ~= IDLE and MTH_EA_IsStateBlocked(rt.state) then
		local cd = MTH_EA_GetSpellCD(SPELL_AIMED)
		return SPELL_AIMED, ICON_AIMED, 1.00, 0.85, 0.00, cd, (cd > 0 and SPELL_STEADY or SPELL_AIMED)
	end

	if rt.state == EXPLOSIVE then
		local cd = MTH_EA_GetSpellCD(SPELL_MULTI)
		return SPELL_MULTI, ICON_MULTI, 1.00, 0.60, 0.05, cd, (cd > 0 and SPELL_STEADY or SPELL_MULTI)
	elseif rt.state == POISONOUS then
		local cd = MTH_EA_GetSpellCD(SPELL_SERPENT)
		return SPELL_SERPENT, ICON_SERPENT, 0.12, 0.85, 0.18, cd, (cd > 0 and SPELL_STEADY or SPELL_SERPENT)
	elseif rt.state == ENCHANTED then
		local cd = MTH_EA_GetSpellCD(SPELL_ARCANE)
		return SPELL_ARCANE, ICON_ARCANE, 0.38, 0.12, 1.00, cd, (cd > 0 and SPELL_STEADY or SPELL_ARCANE)
	else
		-- IDLE: cast Steady Shot while Aimed is on CD, Aimed when ready
		local cd = MTH_EA_GetSpellCD(SPELL_AIMED)
		return SPELL_AIMED, ICON_AIMED, 1.00, 0.85, 0.00, cd, (cd > 0 and SPELL_STEADY or SPELL_AIMED)
	end
end

-- Called from the keybind and from clicking the action button
function MTH_EA_CastActionSpell()
	local _, _, _, _, _, _, spellName = MTH_EA_GetActionSpell()
	if not spellName then return end
	local cfg = MTH_EA_GetConfig()
	if cfg.useQuiverNoClip
		and type(Quiver) == "table"
		and type(Quiver.GetSecondsRemainingShoot) == "function"
		and type(Quiver.CastNoClip) == "function"
	then
		local a, b = Quiver.GetSecondsRemainingShoot()
		if a and b < -0.25 then
			CastSpellByName(spellName)
		else
			Quiver.CastNoClip(spellName)
		end
	else
		CastSpellByName(spellName)
	end
end

-- Build a styled cell frame parented to `parent`
local function MTH_EA_MakeCell(name, parent, w, h)
	local c = CreateFrame("Frame", name, parent)
	c:SetWidth(w or CELL_SIZE)
	c:SetHeight(h or CELL_SIZE)
	c:SetBackdrop({
		bgFile   = "Interface\\Buttons\\WHITE8X8",
		edgeSize = 0,
		insets   = { left = 0, right = 0, top = 0, bottom = 0 },
	})
	c:SetBackdropColor(0, 0, 0, 0.65)
	c:EnableMouse(false)
	local icon = c:CreateTexture(nil, "ARTWORK")
	icon:SetPoint("TOPLEFT",     c, "TOPLEFT",     3, -3)
	icon:SetPoint("BOTTOMRIGHT", c, "BOTTOMRIGHT", -3,  3)
	c.icon = icon
	local fs = c:CreateFontString(nil, "OVERLAY")
	fs:SetFont(CELL_FONT or "Fonts\\FRIZQT__.TTF", 10, nil)
	fs:SetPoint("BOTTOM", c, "BOTTOM", 0, 3)
	fs:SetText("")
	c.cd = fs
	return c
end

local function MTH_EA_CreateUI()
	if strip then return end

	local totalW = CELL_SIZE * 3 + CELL_GAP * 2
	local totalH = CELL_SIZE * 3 + CELL_GAP * 2  -- 3 rows for cross

	-- Root frame sized to the full cross bounding box
	strip = CreateFrame("Frame", "MTH_ExpAmmoStrip", UIParent)
	strip:SetWidth(totalW)
	strip:SetHeight(totalH)
	strip:SetMovable(true)
	strip:EnableMouse(false)
	strip:SetFrameStrata("MEDIUM")

	local cfg = MTH_EA_GetConfig()
	if cfg.pos and cfg.pos.point then
		strip:SetPoint(cfg.pos.point, UIParent, cfg.pos.relPoint or "CENTER",
		               cfg.pos.x or 0, cfg.pos.y or -200)
	else
		strip:SetPoint("CENTER", UIParent, "CENTER", 0, -200)
	end

	-- ── Middle row: 3 ammo-state cells ──────────────────────
	for i = 1, 3 do
		local def = CELL_DEF[i]
		local c   = MTH_EA_MakeCell("MTH_ExpAmmoCell"..i, strip)
		if i == 1 then
			c:SetPoint("LEFT", strip, "LEFT", 0, 0)
		else
			c:SetPoint("LEFT", cells[i-1], "RIGHT", CELL_GAP, 0)
		end
		c.icon:SetTexture(def.icon)
		c.icon:SetVertexColor(0.30, 0.30, 0.30, 0.50)
		cells[i] = c
		cdTexts[i] = c.cd
	end

	-- ── TOP cell: Lock and Load ──────────────────────────────
	cellTop = MTH_EA_MakeCell("MTH_ExpAmmoTop", strip)
	-- Align with centre cell (cells[2])
	cellTop:SetPoint("BOTTOM", cells[2], "TOP", 0, CELL_GAP)
	cellTop.icon:SetTexture(ICON_LNL)
	cellTop.icon:SetVertexColor(0.30, 0.30, 0.30, 0.40)
	cellTopCD = cellTop.cd

	-- ── BOTTOM cell: action hint (display only, click-through) ─
	cellBot = MTH_EA_MakeCell("MTH_ExpAmmoBot", strip)
	cellBot:SetPoint("TOP", cells[2], "BOTTOM", 0, -CELL_GAP)
	cellBotIcon = cellBot.icon
	cellBotCD   = cellBot.cd
	cellBotIcon:SetTexture(ICON_AIMED)
	cellBotIcon:SetVertexColor(1, 0.85, 0, 0.6)

	MTH_EA_ApplyLayout()
end

MTH_EA_UpdateUI = function()
	if not (strip and strip:IsShown()) then return end
	local now = GetTime()

	-- ── Ammo state cells ─────────────────────────────────────
	for i = 1, 3 do
		local c   = cells[i]
		local def = CELL_DEF[i]

		if rt.state == IDLE then
			-- Hint: highlight the border of the predicted next ammo cell
			local hintState = PREDICT_NEXT[rt.lastState] or EXPLOSIVE
			if def.state == hintState then
				-- Use full color at moderate alpha so every hue is equally visible
				c.icon:SetVertexColor(def.r, def.g, def.b, 0.70)
				c:SetBackdropBorderColor(def.r, def.g, def.b, 1.0)
			else
				c.icon:SetVertexColor(0.28, 0.28, 0.28, 0.45)
				c:SetBackdropBorderColor(def.r * 0.20, def.g * 0.20, def.b * 0.20, 0.35)
			end
			cdTexts[i]:SetText("")

		elseif rt.state == def.state then
			local remaining = math.max(0, rt.expiresAt - now)
			local secs      = math.floor(remaining + 0.5)
			c.icon:SetVertexColor(def.r, def.g, def.b, 1)
			c:SetBackdropBorderColor(def.r, def.g, def.b, 1)
			cdTexts[i]:SetText("|cffffffff" .. secs .. "|r")

		else
			local activeIdx, thisIdx = 0, 0
			for j = 1, 3 do
				if STATE_ORDER[j] == rt.state  then activeIdx = j end
				if STATE_ORDER[j] == def.state then thisIdx   = j end
			end
			if thisIdx > activeIdx then
				c.icon:SetVertexColor(def.r * 0.45, def.g * 0.45, def.b * 0.45, 0.70)
				c:SetBackdropBorderColor(def.r * 0.40, def.g * 0.40, def.b * 0.40, 0.60)
			else
				c.icon:SetVertexColor(0.22, 0.22, 0.22, 0.38)
				c:SetBackdropBorderColor(0.18, 0.18, 0.18, 0.30)
			end
			cdTexts[i]:SetText("")
		end

		-- Red border override for blocked (immune / rotation-disabled) states
		if MTH_EA_IsStateBlocked(def.state) then
			c:SetBackdropBorderColor(1, 0, 0, 0.85)
		end
	end

	-- ── TOP cell: Lock and Load ───────────────────────────────
	if cellTop then
		if lnl.active then
			local remaining = math.max(0, lnl.expiresAt - now)
			local secs      = math.floor(remaining + 0.5)
			cellTop.icon:SetVertexColor(1.00, 0.82, 0.00, 1)
			cellTop:SetBackdropBorderColor(1.00, 0.82, 0.00, 1)
			cellTopCD:SetText("|cffffffff" .. secs .. "|r")
		else
			cellTop.icon:SetVertexColor(0.28, 0.28, 0.28, 0.40)
			cellTop:SetBackdropBorderColor(0.25, 0.25, 0.25, 0.35)
			cellTopCD:SetText("")
		end
	end

	-- ── BOTTOM cell: action button ────────────────────────────
	if cellBot then
		local displaySpell, icon, r, g, b, cdRemain = MTH_EA_GetActionSpell()

		if rt.state == IDLE then
			-- Always display Aimed Shot icon + its CD.
			-- The action (keybind/click) casts Steady Shot while Aimed is on CD.
			cellBotIcon:SetTexture(ICON_AIMED)
			if cdRemain > 0 then
				-- On CD: dim icon, show seconds countdown
				cellBotBlink = 0
				cellBotIcon:SetVertexColor(r * 0.45, g * 0.45, b * 0.45, 0.70)
				cellBot:SetBackdropBorderColor(r * 0.35, g * 0.35, b * 0.35, 0.55)
				cellBotCD:SetText("|cffaaaaaa" .. math.floor(cdRemain + 0.5) .. "|r")
			else
				-- Ready: full colour + blink border
				local pulse = math.abs(math.sin(cellBotBlink * 3))
				cellBotIcon:SetVertexColor(r, g, b, 0.75 + pulse * 0.25)
				cellBot:SetBackdropBorderColor(r, g * pulse, b * 0.2, 0.7 + pulse * 0.3)
				cellBotCD:SetText("|cffffe066USE|r")
			end
		else
			-- Ammo active: show consume spell icon, fully lit
			cellBotBlink = 0
			cellBotIcon:SetTexture(icon)
			cellBotIcon:SetVertexColor(r, g, b, 1)
			if cdRemain > 0 then
				cellBot:SetBackdropBorderColor(r * 0.35, g * 0.35, b * 0.35, 0.55)
				cellBotCD:SetText("|cffaaaaaa" .. math.floor(cdRemain + 0.5) .. "|r")
			else
				cellBot:SetBackdropBorderColor(r, g, b, 1)
				cellBotCD:SetText("|cffffe066USE|r")
			end
		end
	end
end

-- ── Layout / appearance manager ──────────────────────────────────────────────
-- Called once after CreateUI (with saved settings) and on every option change.
MTH_EA_ApplyLayout = function()
	if not strip then return end
	local cfg   = MTH_EA_GetConfig()
	local sz    = math.max(20, math.min(80, cfg.cellSize or 40))
	local gap   = math.max(0, math.min(20, cfg.cellGap  or 2))
	local bigCD = cfg.bigCD == true
	local font  = CELL_FONT

	strip:SetWidth(sz * 3 + gap * 2)
	strip:SetHeight(sz * 3 + gap * 2)

	local iconPad = math.min(gap, 3)

	for i = 1, 3 do
		local c  = cells[i]
		local fs = cdTexts[i]
		c:SetWidth(sz)
		c:SetHeight(sz)
		c:ClearAllPoints()
		if i == 1 then
			c:SetPoint("LEFT", strip, "LEFT", 0, 0)
		else
			c:SetPoint("LEFT", cells[i-1], "RIGHT", gap, 0)
		end
		c.icon:ClearAllPoints()
		c.icon:SetPoint("TOPLEFT",     c, "TOPLEFT",      iconPad, -iconPad)
		c.icon:SetPoint("BOTTOMRIGHT", c, "BOTTOMRIGHT", -iconPad,  iconPad)
		fs:ClearAllPoints()
		if bigCD then
			fs:SetPoint("CENTER", c, "CENTER", 0, 0)
			fs:SetFont(font, math.floor(sz * 0.55 + 0.5), "OUTLINE")
		else
			fs:SetPoint("BOTTOM", c, "BOTTOM", 0, 3)
			fs:SetFont(font, 10, nil)
		end
	end

	if cellTop then
		cellTop:SetWidth(sz)
		cellTop:SetHeight(sz)
		cellTop:ClearAllPoints()
		cellTop:SetPoint("BOTTOM", cells[2], "TOP", 0, gap)
		if cfg.showLnL ~= false then cellTop:Show() else cellTop:Hide() end
		cellTop.icon:ClearAllPoints()
		cellTop.icon:SetPoint("TOPLEFT",     cellTop, "TOPLEFT",      iconPad, -iconPad)
		cellTop.icon:SetPoint("BOTTOMRIGHT", cellTop, "BOTTOMRIGHT", -iconPad,  iconPad)
		if cellTopCD then
			cellTopCD:ClearAllPoints()
			if bigCD then
				cellTopCD:SetPoint("CENTER", cellTop, "CENTER", 0, 0)
				cellTopCD:SetFont(font, math.floor(sz * 0.55 + 0.5), "OUTLINE")
			else
				cellTopCD:SetPoint("BOTTOM", cellTop, "BOTTOM", 0, 3)
				cellTopCD:SetFont(font, 10, nil)
			end
		end
	end

	if cellBot then
		cellBot:SetWidth(sz)
		cellBot:SetHeight(sz)
		cellBot:ClearAllPoints()
		cellBot:SetPoint("TOP", cells[2], "BOTTOM", 0, -gap)
		if cfg.showHint ~= false then cellBot:Show() else cellBot:Hide() end
		cellBot.icon:ClearAllPoints()
		cellBot.icon:SetPoint("TOPLEFT",     cellBot, "TOPLEFT",      iconPad, -iconPad)
		cellBot.icon:SetPoint("BOTTOMRIGHT", cellBot, "BOTTOMRIGHT", -iconPad,  iconPad)
		if cellBotCD then
			cellBotCD:ClearAllPoints()
			if bigCD then
				cellBotCD:SetPoint("CENTER", cellBot, "CENTER", 0, 0)
				cellBotCD:SetFont(font, math.floor(sz * 0.45 + 0.5), "OUTLINE")
			else
				cellBotCD:SetPoint("BOTTOM", cellBot, "BOTTOM", 0, 3)
				cellBotCD:SetFont(font, 10, nil)
			end
		end
	end

	MTH_EA_UpdateUI()
	MTH_EA_SnapAnchor()
end

-- ── Anchor frames for repositioning ────────────────────────────────────────
-- 4 handles placed outside each edge of the cross so the widget can be dragged
-- from any side and positioned flush against any screen edge.

local ANCHOR_SIDES = {
	{ name = "Bot", attachPoint = "TOP",    stripPoint = "BOTTOM", ox = 0, oy = -1, isWide = true  },
	{ name = "Top", attachPoint = "BOTTOM", stripPoint = "TOP",    ox = 0, oy =  1, isWide = true  },
	{ name = "Lft", attachPoint = "RIGHT",  stripPoint = "LEFT",   ox = -1, oy = 0, isWide = false },
	{ name = "Rgt", attachPoint = "LEFT",   stripPoint = "RIGHT",  ox =  1, oy = 0, isWide = false },
}

MTH_EA_SnapAnchor = function()
	if not strip then return end
	local cfg  = MTH_EA_GetConfig()
	local gap  = math.max(0, math.min(20, cfg.cellGap  or 2))
	local sz   = math.max(20, math.min(80, cfg.cellSize or 40))
	local thin = math.max(8, math.floor(sz * 0.35 + 0.5))
	for i, side in ipairs(ANCHOR_SIDES) do
		local f = anchorFrames[i]
		if f then
			if side.isWide then
				f:SetWidth(sz * 3 + gap * 2)
				f:SetHeight(thin)
			else
				f:SetWidth(thin)
				f:SetHeight(sz * 3 + gap * 2)
			end
			f:ClearAllPoints()
			f:SetPoint(side.attachPoint, strip, side.stripPoint,
				side.ox * gap, side.oy * gap)
		end
	end
end

local function MTH_EA_MakeAnchorFrame(idx, side)
	local f = CreateFrame("Button", "MTH_ExpAmmoAnchor"..side.name, UIParent)
	f:SetFrameStrata("HIGH")
	f:EnableMouse(true)
	f:RegisterForDrag("LeftButton")
	f:SetBackdrop({
		bgFile = "Interface\\Buttons\\WHITE8X8",
		edgeSize = 0,
		insets = { left = 0, right = 0, top = 0, bottom = 0 },
	})
	f:SetBackdropColor(0.15, 0.45, 0.85, 0.75)
	local label = f:CreateFontString(nil, "OVERLAY")
	label:SetAllPoints()
	label:SetFont(CELL_FONT or "Fonts\\FRIZQT__.TTF", 8, "OUTLINE")
	label:SetJustifyH("CENTER")
	label:SetText("|cffffffffMOVE|r")
	f:SetScript("OnDragStart", function()
		strip:StartMoving()
	end)
	f:SetScript("OnDragStop", function()
		strip:StopMovingOrSizing()
		local cfg = MTH_EA_GetConfig()
		local point, _, relPoint, x, y = strip:GetPoint()
		if point and x and y then
			cfg.pos = { point = point, relPoint = relPoint,
			            x = math.floor(x + 0.5), y = math.floor(y + 0.5) }
		end
		MTH_EA_SnapAnchor()
	end)
	f:SetScript("OnEnter", function()
		GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
		GameTooltip:SetText("|cffffff00MM Widget — Move Anchor|r")
		GameTooltip:AddLine("Drag to reposition the widget", 0.6, 0.6, 0.6)
		GameTooltip:Show()
	end)
	f:SetScript("OnLeave", function() GameTooltip:Hide() end)
	return f
end

function MTH_EA_ToggleAnchor()
	if not strip then return end
	local showing = false
	-- Show if none exist or all are hidden
	for i = 1, 4 do
		if anchorFrames[i] and anchorFrames[i]:IsShown() then
			showing = true
			break
		end
	end
	if showing then
		for i = 1, 4 do
			if anchorFrames[i] then anchorFrames[i]:Hide() end
		end
	else
		for i, side in ipairs(ANCHOR_SIDES) do
			if not anchorFrames[i] then
				anchorFrames[i] = MTH_EA_MakeAnchorFrame(i, side)
			end
			anchorFrames[i]:Show()
		end
		MTH_EA_SnapAnchor()
	end
end

-- ── Spell-name capture hook ───────────────────────────────────
-- We hook CastSpellByName / CastSpell / UseAction to know which
-- spell is about to be cast before SPELLCAST_STOP fires (which
-- in 1.12 carries no spell-name argument itself).
-- Guards prevent re-entrancy; we chain into whatever was already
-- installed (Quiver, SmartAmmo, etc.) at the end of our hook.
local MTH_EA_LastSpell = nil

local MTH_EA_InHookCSBN    = false
local MTH_EA_InHookCS      = false
local MTH_EA_InHookUA      = false

local function MTH_EA_HookInstallCSBN()
	-- Capture the full current chain at install time (VARIABLES_LOADED fires after all
	-- addons — including Quiver — have loaded and installed their own hooks).  Using a
	-- file-parse-time snapshot here would skip every hook installed after this file was
	-- parsed (e.g. Quiver), causing their CastSpellByName hooks to be silently bypassed.
	local upstream = CastSpellByName
	CastSpellByName = function(spellText, onSelf)
		if MTH_EA_InHookCSBN then
			if upstream then return upstream(spellText, onSelf) end
			return
		end
		MTH_EA_InHookCSBN = true
		local _, _, name = string.find(tostring(spellText or ""), "([%w%'%s%-]+)")
		MTH_EA_LastSpell = name and (string.gsub(name, "^%s*(.-)%s*$", "%1")) or nil
		MTH_EA_InHookCSBN = false
		if upstream then
			return upstream(spellText, onSelf)
		end
	end
end

local function MTH_EA_HookInstallCS()
	local origCS = CastSpell
	CastSpell = function(spellId, bookType)
		if MTH_EA_InHookCS then
			if origCS then return origCS(spellId, bookType) end
			return
		end
		MTH_EA_InHookCS = true
		if type(GetSpellName) == "function" then
			local n = GetSpellName(spellId, bookType or "spell")
			if n and n ~= "" then MTH_EA_LastSpell = n end
		end
		local result
		if origCS then result = origCS(spellId, bookType) end
		MTH_EA_InHookCS = false
		return result
	end
end

-- Own tooltip probe for UseAction hook (created on first use).
-- Uses GameTooltipTemplate for reliable SetAction text population.
local MTH_EA_UAProbe = nil
local function MTH_EA_EnsureUAProbe()
	if MTH_EA_UAProbe then return MTH_EA_UAProbe end
	MTH_EA_UAProbe = CreateFrame("GameTooltip", "MTH_EA_UAProbe", UIParent, "GameTooltipTemplate")
	MTH_EA_UAProbe:SetOwner(UIParent, "ANCHOR_NONE")
	return MTH_EA_UAProbe
end

local function MTH_EA_HookInstallUA()
	local origUA = UseAction
	UseAction = function(slot, checkCursor, onSelf)
		if MTH_EA_InHookUA then
			if origUA then return origUA(slot, checkCursor, onSelf) end
			return
		end
		MTH_EA_InHookUA = true
		-- For spell-type actions (not macros), resolve spell name via icon texture
		-- or tooltip probe.  Texture match is tried first (zero cost).
		if not GetActionText(slot) then
			local tex = GetActionTexture(slot)
			local matched = false
			if tex then
				local lower = string.lower(tex)
				for name, icon in pairs(MTH_EA_SPELL_ICONS) do
					if lower == icon then
						MTH_EA_LastSpell = name
						matched = true
						break
					end
				end
			end
			if not matched then
				local probe = MTH_EA_EnsureUAProbe()
				probe:SetOwner(UIParent, "ANCHOR_NONE")
				probe:ClearLines()
				probe:SetAction(slot)
				local L1 = getglobal("MTH_EA_UAProbeTextLeft1")
				local txt = L1 and L1:GetText() or nil
				if txt and txt ~= "" then MTH_EA_LastSpell = txt end
			end
		end
		local result
		if origUA then result = origUA(slot, checkCursor, onSelf) end
		MTH_EA_InHookUA = false
		return result
	end
end

-- ── NamPower helper functions ────────────────────────────────
local function MTH_EA_CheckNamPower()
	if type(GetNampowerVersion) ~= "function" then return false end
	local maj, min = GetNampowerVersion()
	maj = tonumber(maj) or 0
	min = tonumber(min) or 0
	return maj > 2 or (maj == 2 and min >= 40)
end

-- Resolve spellId → state key via name lookup on first encounter; cache result.
local function MTH_EA_CacheSpellId(spellId)
	if MTH_EA_SpellIdToState[spellId] or spellId == MTH_EA_LnLSpellId then return end
	if type(GetSpellRecField) ~= "function" then return end
	local name = GetSpellRecField(spellId, "name")
	if not name or name == "" then return end
	local stateKey = BUFF_TO_STATE[name]
	if stateKey then
		MTH_EA_SpellIdToState[spellId] = stateKey
		return
	end
	if string.find(name, "Lock and Load", 1, true) then
		MTH_EA_LnLSpellId = spellId
	end
end

-- Query the authoritative remaining LnL duration from NamPower.
-- Returns seconds (float) or nil if LnL isn't active / API unavailable.
local function MTH_EA_GetLnLDurationNP()
	if type(GetPlayerAuraDuration) ~= "function" then return nil end
	if type(GetUnitField) ~= "function" then return nil end
	local auras = GetUnitField("player", "aura")
	if type(auras) ~= "table" then return nil end
	-- Buffs occupy slots 1-32 (1-based in the table, 0-based for the API).
	for i = 1, 32 do
		local sid = tonumber(auras[i])
		if sid and sid == MTH_EA_LnLSpellId then
			local _, remainMs = GetPlayerAuraDuration(i - 1)
			remainMs = tonumber(remainMs)
			if remainMs and remainMs > 0 then
				return remainMs / 1000
			end
			return nil  -- slot found but no usable duration
		end
	end
	return nil  -- LnL not in aura array
end

-- Recovery via NamPower's GetUnitField aura array (replaces texture scan).
local function MTH_EA_RecoverStateFromAuraArray()
	if type(GetUnitField) ~= "function" then
		MTH_EA_RecoverStateFromBuffs()
		return
	end
	local auras = GetUnitField("player", "aura")
	if type(auras) ~= "table" then
		MTH_EA_RecoverStateFromBuffs()
		return
	end
	local foundState = nil
	local foundLnL   = false
	for _, spellId in pairs(auras) do
		local sid = tonumber(spellId)
		if sid and sid > 0 then
			MTH_EA_CacheSpellId(sid)
			local stateKey = MTH_EA_SpellIdToState[sid]
			if stateKey and not foundState then
				foundState = stateKey
				rt.state     = stateKey
				rt.expiresAt = GetTime() + CYCLE_DURATION
				rt.consumed  = false
				MTH_EA_PredictVerifyAt = 0  -- server confirmed; cancel pending verify
			end
			if sid == MTH_EA_LnLSpellId then
				foundLnL = true
				-- Always resync from authoritative NamPower duration.
				local rem = MTH_EA_GetLnLDurationNP()
				if rem then
					lnl.active    = true
					lnl.expiresAt = GetTime() + rem
				elseif not lnl.active then
					lnl.active    = true
					lnl.expiresAt = GetTime() + lnl.DURATION
				end
			end
		end
	end
	-- Authoritative LnL clear: if the buff is no longer in the aura array,
	-- it was consumed (Aimed Shot) or expired.  Clear immediately instead
	-- of waiting for the hardcoded 10 s OnUpdate timer.
	if not foundLnL and lnl.active then
		lnl.active = false
	end
	if not foundState and rt.state ~= IDLE then
		MTH_EA_SetState(IDLE)
	end
end
-- ── Chat message handler (module-level to stay within Lua 5.0's
--    32-upvalue-per-closure limit; OnEvent closes over too many locals
--    to host this as a nested function).
local function MTH_EA_TryHandleChatMsg(msg)
	if not MTH_EA_IsEnabled() then return false end
	msg = msg or ""
	-- ── State GAIN patterns ─────────────────────────────────
	local _, _, gained = string.find(msg, "^You are afflicted by (.+)%.$")
	if not gained then
		_, _, gained = string.find(msg, "^You gain (.+)%.$")
	end
	if not gained then
		_, _, gained = string.find(msg, "^You gain the effect of (.+)%.$")
	end
	if gained then
		local stateKey = BUFF_TO_STATE[gained]
		if stateKey then
			MTH_EA_SetState(stateKey)
			return true
		end
		if string.find(gained, "Lock and Load") then
			local rem = MTH_EA_GetLnLRemaining()
			lnl.active    = true
			lnl.expiresAt = GetTime() + (rem or lnl.DURATION)
			return true
		end
	end
	-- ── State LOSS patterns ────────────────────────────────────
	local _, _, lost = string.find(msg, "^(.+) fades from you%.$")
	if not lost then
		_, _, lost = string.find(msg, "^(.+) fades from you$")
	end
	if lost then
		local stateKey = BUFF_TO_STATE[lost]
		if stateKey then
			if rt.state == stateKey then
				MTH_EA_SetState(IDLE)
			end
			return true
		end
		if string.find(lost, "Lock and Load") then
			lnl.active        = false
			lnlPendingCapture = false
			MTH_EA_SnapshotBuffs()
			return true
		end
	end
	return false
end

-- ── Event frame ───────────────────────────────────────────────────
local frame = CreateFrame("Frame", "MTH_ExpAmmoFrame")
frame:Hide()
frame._elapsed = 0

frame:RegisterEvent("VARIABLES_LOADED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("PLAYER_REGEN_DISABLED")            -- entering combat
frame:RegisterEvent("PLAYER_REGEN_ENABLED")             -- combat ends (cycle position preserved)
frame:RegisterEvent("PLAYER_AURAS_CHANGED")              -- /reload recovery
frame:RegisterEvent("CHAT_MSG_SPELL_SELF_BUFF")               -- gain fallback
frame:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE")     -- TWoW: debuff gain ("afflicted by")
frame:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF")           -- loss (confirmed)
frame:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS")      -- loss fallback
frame:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_BUFF")
frame:RegisterEvent("SPELLCAST_STOP")
frame:RegisterEvent("SPELLCAST_FAILED")
frame:RegisterEvent("SPELLCAST_INTERRUPTED")
frame:RegisterEvent("ACTIONBAR_SLOT_CHANGED")           -- invalidate Aimed Shot slot cache
frame:RegisterEvent("PLAYER_TARGET_CHANGED")             -- proactive creature-type immunity
frame:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE")        -- reactive "immune" detection

frame:SetScript("OnUpdate", function()
	if not MTH_EA_IsEnabled() then return end
	local dt = arg1 or 0
	this._elapsed = (this._elapsed or 0) + dt
	cellBotBlink  = cellBotBlink + dt   -- accumulate for blink pulse

	if MTH_EA_PendingAuraRescan > 0 then
		MTH_EA_PendingAuraRescan = MTH_EA_PendingAuraRescan - dt
		if MTH_EA_PendingAuraRescan <= 0 then
			MTH_EA_PendingAuraRescan = 0
			if MTH_EA_UseNamPower then
				MTH_EA_RecoverStateFromAuraArray()
			else
				MTH_EA_RecoverStateFromBuffs()
			end
		end
	end

	-- Natural state expiry: the game doesn't auto-advance on expiry,
	-- so we go to IDLE. If the player consumed it, CHAT_MSG_AURA_GONE_SELF
	-- already handled it; this path only fires on genuine timeout.
	if rt.state ~= IDLE and GetTime() >= rt.expiresAt then
		MTH_EA_SetState(IDLE)
		MTH_EA_PredictVerifyAt = 0
		cellBotBlink = 0
	end

	-- Prediction verification: after SPELLCAST_STOP sets a predictive state,
	-- confirm the debuff actually arrived via a hard aura scan.  If not found,
	-- clear the phantom state.  This catches stale spell-name captures, server
	-- packet loss, and any other desync between the predicted and actual state.
	if MTH_EA_PredictVerifyAt > 0 and rt.state ~= IDLE and GetTime() >= MTH_EA_PredictVerifyAt then
		MTH_EA_PredictVerifyAt = 0
		local actual = MTH_EA_FindAmmoStateByTexture()
		if not actual then
			-- Predicted debuff never showed up — phantom state; clear it.
			MTH_EA_SetState(IDLE)
		elseif actual ~= rt.state then
			-- Server sent a different state than predicted; correct it.
			rt.state     = actual
			rt.expiresAt = GetTime() + CYCLE_DURATION
			rt.consumed  = false
		end
		-- If actual == rt.state, prediction was correct — no action needed.
	end

	-- LnL: authoritative resync from NamPower every frame.
	if lnl.active and MTH_EA_UseNamPower then
		local rem = MTH_EA_GetLnLDurationNP()
		if rem then
			lnl.expiresAt = GetTime() + rem
		else
			-- Buff gone from aura array → expired or consumed.
			lnl.active = false
		end
	elseif lnl.active and GetTime() >= lnl.expiresAt then
		-- Legacy path: no NamPower, use hardcoded 10 s timer.
		lnl.active = false
	end

	if this._elapsed < 0.25 then return end
	this._elapsed = 0

	MTH_EA_UpdateUI()
end)

-- ── Per-event helpers (module-level to keep OnEvent under Lua 5.0's
--    32-upvalue-per-closure limit).  They close over only the locals
--    each one actually needs, not the full module scope.
local function MTH_EA_HandleVarsLoaded()
	MTH_EA_HookInstallCSBN()
	MTH_EA_HookInstallCS()
	MTH_EA_HookInstallUA()
	if MTH and MTH.nampower then
		MTH_EA_UseNamPower = true
		frame:UnregisterEvent("PLAYER_AURAS_CHANGED")
		frame:UnregisterEvent("CHAT_MSG_SPELL_SELF_BUFF")
		frame:UnregisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE")
		frame:UnregisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF")
		frame:UnregisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS")
		frame:UnregisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_BUFF")
		frame:RegisterEvent("BUFF_ADDED_SELF")
		frame:RegisterEvent("BUFF_REMOVED_SELF")
		frame:RegisterEvent("DEBUFF_ADDED_SELF")
		frame:RegisterEvent("DEBUFF_REMOVED_SELF")
	end
end

local function MTH_EA_HandlePlayerEnteringWorld()
	MTH_EA_EnsureConfigDefaults()

	-- Class gate: only hunters may use Experimental Ammunition.
	if MTH and MTH.IsClassGateBlocked and MTH:IsClassGateBlocked() then
		if strip then strip:Hide() end
		return
	end

	rt.state     = IDLE
	rt.expiresAt = 0
	rt.consumed  = false
	rt.lastState = nil
	MTH_EA_LastSpell = nil
	lnl.active        = false
	lnlPendingCapture = false
	MTH_EA_ClearActionSlotCache()
	MTH_EA_SnapshotBuffs()

	-- Update talent flag from whatever the scanner has so far.
	-- We do NOT gate strip visibility on this: GetTalentInfo can return
	-- stale data briefly on login before the client finishes loading
	-- talent data.  Show the strip if enabled; MTH_HT_OnScanComplete
	-- will hide it later if the talent is truly absent after a proper scan.
	MTH_EA_HasTalent = MTH_HT_HasTalent and MTH_HT_HasTalent(TALENT_NAME) or false

	if not MTH_EA_IsEnabled() then return end

	MTH_EA_CreateUI()
	-- Recover any active ammo aura (survives /reload in same session)
	if MTH_EA_UseNamPower then
		MTH_EA_RecoverStateFromAuraArray()
	else
		MTH_EA_RecoverStateFromBuffs()
	end
	inCombat = UnitAffectingCombat and UnitAffectingCombat("player") and true or false
	frame:Show()
	MTH_EA_RefreshVisibility()
	MTH_EA_UpdateUI()
end

frame:SetScript("OnEvent", function()
	if event == "VARIABLES_LOADED" then
		MTH_EA_HandleVarsLoaded()
		return
	end

	if event == "PLAYER_ENTERING_WORLD" then
		MTH_EA_HandlePlayerEnteringWorld()
		return
	end

	if event == "ACTIONBAR_SLOT_CHANGED" then
		MTH_EA_ClearActionSlotCache()
		return
	end

	if event == "PLAYER_TARGET_CHANGED" then
		MTH_EA_BlockedStates = {}
		if UnitExists("target") then
			local creatureType = UnitCreatureType("target")
			if creatureType and CREATURE_TYPE_IMMUNITIES[creatureType] then
				for st, _ in pairs(CREATURE_TYPE_IMMUNITIES[creatureType]) do
					MTH_EA_BlockedStates[st] = true
				end
			end
		end
		MTH_EA_UpdateUI()
		return
	end

	if event == "CHAT_MSG_SPELL_SELF_DAMAGE" then
		local msg = arg1 or ""
		if string.find(msg, "immune", 1, true) then
			for state, spell in pairs(CONSUME_SPELL) do
				if string.find(msg, spell, 1, true) then
					MTH_EA_BlockedStates[state] = true
					MTH_EA_UpdateUI()
					break
				end
			end
		end
		return
	end

	if event == "PLAYER_REGEN_DISABLED" then
		-- Entering combat
		inCombat = true
		MTH_EA_RefreshVisibility()
		return
	end

	if event == "PLAYER_REGEN_ENABLED" then
		-- Combat ended. The server does NOT reset the ammo sequence — it resumes
		-- exactly where it left off. Keep rt.state and rt.lastState as-is.
		inCombat = false
		MTH_EA_RefreshVisibility()
		return
	end

	if event == "PLAYER_AURAS_CHANGED" then
		if not MTH_EA_IsEnabled() then return end

		-- Throttle: cap processing at ~6/sec.  Chat-message handlers cover all
		-- real-time state transitions; this path is only for /reload recovery
		-- and LnL sync, so a 150 ms gate is perfectly safe.
		local now = GetTime()
		if (now - MTH_EA_AurasChangedLastTime) < 0.15 then return end
		MTH_EA_AurasChangedLastTime = now

		-- Pending LnL icon capture (no-op stub; kept to avoid errors).
		if lnlPendingCapture then
			MTH_EA_TryCaptureNewBuffIcon()
		end

		-- ── LnL sync: texture-based, zero tooltip cost ───────────────────
		-- We only SET active here (initial gain / missed chat message).
		-- LOSS is authoritative from the AURA_GONE_SELF chat handler + OnUpdate
		-- expiry, so we deliberately do NOT clear lnl.active when not found —
		-- AURAS_CHANGED fires for every unrelated buff change and a transient
		-- miss during slot reordering would prematurely kill the timer.
		if MTH_EA_HasLnLByTexture() then
			if not lnl.active then
				lnl.active    = true
				lnl.expiresAt = now + lnl.DURATION
			end
			lnlPendingCapture = false
		end

		-- ── Recovery: resync ammo state after /reload ─────────────────────
		if MTH_EA_UseNamPower then
			MTH_EA_RecoverStateFromAuraArray()
		else
			MTH_EA_RecoverStateFromBuffs()
		end
		MTH_EA_UpdateUI()
		return
	end

	-- ── NamPower aura events ──────────────────────────────────────────
	if event == "BUFF_ADDED_SELF" or event == "DEBUFF_ADDED_SELF" then
		local spellId = tonumber(arg3)
		if spellId and spellId > 0 then
			MTH_EA_CacheSpellId(spellId)
			-- LnL proc / re-proc: get authoritative remaining time.
			if spellId == MTH_EA_LnLSpellId then
				lnl.active = true
				local rem  = MTH_EA_GetLnLDurationNP()
				lnl.expiresAt = GetTime() + (rem or lnl.DURATION)
			end
		end
		MTH_EA_RequestAuraRescan(0.05)
		return
	end

	if event == "BUFF_REMOVED_SELF" or event == "DEBUFF_REMOVED_SELF" then
		local spellId = tonumber(arg3)
		if spellId and spellId > 0 then
			MTH_EA_CacheSpellId(spellId)
			-- LnL consumed or expired: clear immediately, don't wait for rescan.
			if spellId == MTH_EA_LnLSpellId then
				lnl.active = false
			end
		end
		MTH_EA_RequestAuraRescan(0.05)
		return
	end

	-- ── Primary state detection via combat log messages ───────────────
	-- (MTH_EA_TryHandleChatMsg is defined at module level to stay under
	--  Lua 5.0's 32-upvalue-per-closure limit.)

	if event == "CHAT_MSG_SPELL_SELF_BUFF"
	or event == "CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE"
	or event == "CHAT_MSG_SPELL_AURA_GONE_SELF"
	or event == "CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS"
	or event == "CHAT_MSG_SPELL_CREATURE_VS_SELF_BUFF" then
		MTH_EA_TryHandleChatMsg(arg1)
		return
	end

	-- ───────────────────────────────────────────────────────────

	if not MTH_EA_IsEnabled() then return end

	-- We rely on MTH_EA_LastSpell captured in our CastSpellByName / CastSpell /
	-- UseAction hooks.  Do NOT fall back to MTH_SA_LastSpell — SmartAmmo clears
	-- its capture on SPELLCAST_STOP in undefined order relative to us, making it
	-- either stale (previous cast's name) or nil depending on frame event order.
	local spellName = MTH_EA_LastSpell or ""

	if event == "SPELLCAST_STOP" then
		-- Predictive: show the expected next ammo state immediately when Aimed Shot
		-- fires from IDLE, before the server debuff message arrives (~1s later).
		-- We predict based on lastState so we show the correct one (not always EXPLOSIVE):
		--   no prior cycle / after ENCHANTED → EXPLOSIVE
		--   after EXPLOSIVE                  → POISONOUS
		--   after POISONOUS                  → ENCHANTED
		if spellName == SPELL_AIMED and rt.state == IDLE then
			local predicted = PREDICT_NEXT[rt.lastState] or EXPLOSIVE
			MTH_EA_SetState(predicted)
			-- Schedule a verification rescan: if the predicted debuff never arrives
			-- from the server within 1.5 s, the hard aura check will catch it and
			-- clear back to IDLE.  This prevents phantom states from persisting for
			-- up to 60 s when the spell name capture was stale or the server did not
			-- apply the expected debuff.
			MTH_EA_PredictVerifyAt = GetTime() + 1.5
		end
		-- Consume-spell advancement (NamPower path):
		-- Do not advance immediately here.  The aura can still be present for a
		-- short moment after the cast completes, so we defer to a live aura
		-- rescan and only update the state when the player aura actually changes.
		if MTH_EA_UseNamPower and rt.state ~= IDLE then
			local consumeSpell = CONSUME_SPELL[rt.state]
			if consumeSpell and spellName == consumeSpell then
				MTH_EA_PendingAuraRescan = 0.20
			end
		end
		MTH_EA_LastSpell = nil

	elseif event == "SPELLCAST_FAILED" or event == "SPELLCAST_INTERRUPTED" then
		-- Aimed Shot interrupted: roll back any predictive state set within the last 0.5s.
		if spellName == SPELL_AIMED and rt.state ~= IDLE then
			local elapsed = GetTime() - (rt.expiresAt - CYCLE_DURATION)
			if elapsed < 0.5 then
				MTH_EA_SetState(IDLE)
			end
		end
		MTH_EA_LastSpell = nil
	end
end)

-- ── Talent re-check on respec ───────────────────────────────
-- MTH_HT_OnScanComplete is called by core-scan-huntertalents.lua
-- after every talent/spellbook scan (login, respec, PLAYER_ENTERING_WORLD).
-- We piggyback on it to update the talent gate without polling.
local MTH_EA_PrevOnScanComplete = nil
local function MTH_EA_InstallScanHook()
	MTH_EA_PrevOnScanComplete = MTH_HT_OnScanComplete  -- chain any existing handler
	MTH_HT_OnScanComplete = function()
		if MTH_EA_PrevOnScanComplete then
			MTH_EA_PrevOnScanComplete()
		end
		local hasTalent = MTH_HT_HasTalent and MTH_HT_HasTalent(TALENT_NAME) or false
		if hasTalent == MTH_EA_HasTalent then return end  -- no change
		MTH_EA_HasTalent = hasTalent
		if not strip then return end
		if MTH_EA_IsEnabled() and hasTalent then
			MTH_EA_RefreshVisibility()
		else
			if not hasTalent then MTH_EA_SetState(IDLE) end
			strip:Hide()
		end
	end
end

-- Install the hook after VARIABLES_LOADED (globals are guaranteed by then).
-- The event frame already handles VARIABLES_LOADED, so we add a secondary
-- one-shot frame here to avoid ordering issues.
do
	local hookFrame = CreateFrame("Frame")
	hookFrame:RegisterEvent("VARIABLES_LOADED")
	hookFrame:SetScript("OnEvent", function()
		MTH_EA_InstallScanHook()
		hookFrame:UnregisterAllEvents()
	end)
end

-- ── Public API ────────────────────────────────────────────────
MTH_ExpAmmo = {
	SetEnabled = function(enabled)
		local cfg = MTH_EA_GetConfig()
		cfg.enabled = enabled and true or false
		if cfg.enabled then
			MTH_EA_CreateUI()
			frame:Show()
			MTH_EA_RefreshVisibility()
		elseif strip then
			strip:Hide()
		end
	end,
	IsEnabled  = MTH_EA_IsEnabled,
	GetState   = function() return rt.state end,
	ResetCycle = function() MTH_EA_SetState(IDLE) end,
	SetShowLnL = function(v)
		local cfg = MTH_EA_GetConfig()
		cfg.showLnL = v and true or false
		MTH_EA_ApplyLayout()
	end,
	SetShowHint = function(v)
		local cfg = MTH_EA_GetConfig()
		cfg.showHint = v and true or false
		MTH_EA_ApplyLayout()
	end,
	SetCellSize = function(v)
		local cfg = MTH_EA_GetConfig()
		cfg.cellSize = math.max(20, math.min(80, tonumber(v) or 40))
		MTH_EA_ApplyLayout()
	end,
	SetCellGap = function(v)
		local cfg = MTH_EA_GetConfig()
		cfg.cellGap = math.max(0, math.min(20, tonumber(v) or 2))
		MTH_EA_ApplyLayout()
	end,
	SetBigCD = function(v)
		local cfg = MTH_EA_GetConfig()
		cfg.bigCD = v and true or false
		MTH_EA_ApplyLayout()
	end,
	SetHideOOC = function(v)
		local cfg = MTH_EA_GetConfig()
		cfg.hideOOC = v and true or false
		MTH_EA_RefreshVisibility()
	end,
	SetUseQuiverNoClip = function(v)
		local cfg = MTH_EA_GetConfig()
		cfg.useQuiverNoClip = v and true or false
	end,
	SetBlockExplosive = function(v)
		local cfg = MTH_EA_GetConfig()
		cfg.blockExplosive = v and true or false
		MTH_EA_UpdateUI()
	end,
	SetBlockPoisonous = function(v)
		local cfg = MTH_EA_GetConfig()
		cfg.blockPoisonous = v and true or false
		MTH_EA_UpdateUI()
	end,
	SetBlockEnchanted = function(v)
		local cfg = MTH_EA_GetConfig()
		cfg.blockEnchanted = v and true or false
		MTH_EA_UpdateUI()
	end,
	ToggleAnchor = MTH_EA_ToggleAnchor,
}
