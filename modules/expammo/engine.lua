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
	return base or s
end

-- Scan player buffs+debuffs for an active ammo state via texture comparison.
local function MTH_EA_FindAmmoStateByTexture()
	for i = 1, 32 do
		local t = UnitBuff("player", i)
		if not t then break end
		local base = MTH_EA_IconBasename(t)
		for stateKey, frag in pairs(MTH_EA_AMMO_TEX) do
			if base == frag then return stateKey end
		end
	end
	for i = 1, 16 do
		local t = UnitDebuff("player", i)
		if not t then break end
		local base = MTH_EA_IconBasename(t)
		for stateKey, frag in pairs(MTH_EA_AMMO_TEX) do
			if base == frag then return stateKey end
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
	if cfg.bigCD    == nil then cfg.bigCD    = false end
	if cfg.hideOOC  == nil then cfg.hideOOC  = false end
end

-- Combat state flag (avoids needing InCombatLockdown, which doesn't exist in 1.12)
local inCombat = false

-- Throttle for PLAYER_AURAS_CHANGED: even with the fast texture path this event
-- fires 10-50+/sec in combat, so cap processing at ~6/sec.
local MTH_EA_AurasChangedLastTime = 0

-- UI frame handles — declared here so MTH_EA_RefreshVisibility (and every
-- function defined below) all close over the SAME locals.
local strip       = nil   -- root drag frame (sized to 3×1 row)
local cells       = {}    -- [1..3] ammo state cells
local cdTexts     = {}    -- [1..3] countdown fontstrings in ammo cells
local cellTop     = nil   -- Lock and Load cell
local cellTopCD   = nil   -- L&L countdown fontstring
local cellBot     = nil   -- action button cell
local cellBotIcon = nil   -- action button icon texture
local cellBotCD   = nil   -- action button CD / "READY" text
local cellBotBlink = 0    -- blink phase accumulator

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
local function MTH_EA_SetState(newState)
	-- Track which state just ended so the predictive display knows what comes next.
	if newState == IDLE and rt.state ~= IDLE then
		rt.lastState = rt.state
	end
	rt.state    = newState
	rt.consumed = false
	rt.expiresAt = (newState ~= IDLE) and (GetTime() + CYCLE_DURATION) or 0
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

-- Action button: what spell to show / cast right now
local function MTH_EA_GetActionSpell()
	if rt.state == EXPLOSIVE then
		return SPELL_MULTI,   ICON_MULTI,   1.00, 0.60, 0.05
	elseif rt.state == POISONOUS then
		return SPELL_SERPENT, ICON_SERPENT, 0.12, 0.85, 0.18
	elseif rt.state == ENCHANTED then
		return SPELL_ARCANE,  ICON_ARCANE,  0.38, 0.12, 1.00
	else
		return SPELL_AIMED,   ICON_AIMED,   1.00, 0.85, 0.00
	end
end

-- Called from the keybind and from clicking the action button
function MTH_EA_CastActionSpell()
	local spellName = MTH_EA_GetActionSpell()
	if spellName then CastSpellByName(spellName) end
end

-- Build a styled cell frame parented to `parent`
local function MTH_EA_MakeCell(name, parent, w, h)
	local c = CreateFrame("Frame", name, parent)
	c:SetWidth(w or CELL_SIZE)
	c:SetHeight(h or CELL_SIZE)
	c:SetBackdrop({
		bgFile   = "Interface\\Buttons\\WHITE8X8",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		edgeSize = 10,
		insets   = { left = 2, right = 2, top = 2, bottom = 2 },
	})
	c:SetBackdropColor(0, 0, 0, 0.65)
	c:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.5)
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
	strip:EnableMouse(true)
	strip:RegisterForDrag("LeftButton")
	strip:SetScript("OnDragStart", function()
		if IsAltKeyDown() then this:StartMoving() end
	end)
	strip:SetScript("OnDragStop", function()
		this:StopMovingOrSizing()
		local cfg = MTH_EA_GetConfig()
		local point, _, relPoint, x, y = this:GetPoint()
		if point and x and y then
			cfg.pos = { point = point, relPoint = relPoint,
			            x = math.floor(x + 0.5), y = math.floor(y + 0.5) }
		end
	end)
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

	-- ── BOTTOM cell: action button ───────────────────────────
	cellBot = MTH_EA_MakeCell("MTH_ExpAmmoBot", strip)
	cellBot:SetPoint("TOP", cells[2], "BOTTOM", 0, -CELL_GAP)
	cellBot:EnableMouse(true)
	cellBot:SetScript("OnMouseUp", function()
		if arg1 == "LeftButton" then MTH_EA_CastActionSpell() end
	end)
	cellBotIcon = cellBot.icon
	cellBotCD   = cellBot.cd
	cellBotIcon:SetTexture(ICON_AIMED)
	cellBotIcon:SetVertexColor(1, 0.85, 0, 0.6)

	-- Tooltip on the action button
	cellBot:SetScript("OnEnter", function()
		local spellName = MTH_EA_GetActionSpell()
		GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
		GameTooltip:SetText(spellName or "")
		GameTooltip:AddLine("Left-click or use keybind", 0.6, 0.6, 0.6)
		GameTooltip:Show()
	end)
	cellBot:SetScript("OnLeave", function() GameTooltip:Hide() end)

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
		local spellName, icon, r, g, b = MTH_EA_GetActionSpell()
		cellBotIcon:SetTexture(icon)

		if rt.state == IDLE then
			-- Show Aimed Shot with CD and blink when ready
			local cdRemain = 0
			if type(GetSpellCooldown) == "function" and MTH_HT_GetSpellInfo then
				local info = MTH_HT_GetSpellInfo(SPELL_AIMED)
				if info and info.slot then
					local start, duration = GetSpellCooldown(info.slot, BOOKTYPE_SPELL)
					-- Ignore GCD-length cooldowns (≤1.5 s) triggered by other casts.
					-- Aimed Shot's real cooldown is always longer than the GCD.
					if start and duration and duration > 1.5 then
						cdRemain = math.max(0, (start + duration) - now)
					end
				end
			end
			if cdRemain > 0 then
				-- On cooldown: dim, show seconds
				cellBotBlink = 0
				cellBotIcon:SetVertexColor(r * 0.45, g * 0.45, b * 0.45, 0.70)
				cellBot:SetBackdropBorderColor(r * 0.35, g * 0.35, b * 0.35, 0.55)
				cellBotCD:SetText("|cffaaaaaa" .. math.floor(cdRemain + 0.5) .. "|r")
			else
				-- Ready: full colour + blink border
				local pulse = math.abs(math.sin(cellBotBlink * 3))
				cellBotIcon:SetVertexColor(r, g, b, 0.75 + pulse * 0.25)
				cellBot:SetBackdropBorderColor(r, g * pulse, b * 0.2, 0.7 + pulse * 0.3)
				cellBotCD:SetText("|cff00ff00READY|r")
			end
		else
			-- Ammo active: show consume spell, fully lit
			cellBotBlink = 0
			cellBotIcon:SetVertexColor(r, g, b, 1)
			cellBot:SetBackdropBorderColor(r, g, b, 1)
			cellBotCD:SetText("|cffffe066USE|r")
		end
	end
end

-- ── Layout / appearance manager ──────────────────────────────────────────────
-- Called once after CreateUI (with saved settings) and on every option change.
MTH_EA_ApplyLayout = function()
	if not strip then return end
	local cfg   = MTH_EA_GetConfig()
	local sz    = math.max(20, math.min(80, cfg.cellSize or 40))
	local bigCD = cfg.bigCD == true
	local font  = CELL_FONT

	strip:SetWidth(sz * 3 + CELL_GAP * 2)
	strip:SetHeight(sz * 3 + CELL_GAP * 2)

	for i = 1, 3 do
		local c  = cells[i]
		local fs = cdTexts[i]
		c:SetWidth(sz)
		c:SetHeight(sz)
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
		if cfg.showLnL ~= false then cellTop:Show() else cellTop:Hide() end
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
		if cfg.showHint ~= false then cellBot:Show() else cellBot:Hide() end
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
local MTH_EA_OrigCSBN      = CastSpellByName
local MTH_EA_OrigCS        = CastSpell
local MTH_EA_OrigUA        = UseAction

local function MTH_EA_HookInstallCSBN()
	CastSpellByName = function(spellText, onSelf)
		if MTH_EA_InHookCSBN then
			local f = MTH_EA_OrigCSBN
			if f and f ~= CastSpellByName then return f(spellText, onSelf) end
			return
		end
		MTH_EA_InHookCSBN = true
		local _, _, name = string.find(tostring(spellText or ""), "([%w%'%s%-]+)")
		MTH_EA_LastSpell = name and (string.gsub(name, "^%s*(.-)%s*$", "%1")) or nil
		local upstream = MTH_EA_OrigCSBN
		-- Always call the current global so Quiver/SmartAmmo's chain is respected
		local cur = CastSpellByName
		MTH_EA_InHookCSBN = false
		if upstream and upstream ~= cur then
			return upstream(spellText, onSelf)
		elseif cur ~= MTH_EA_HookInstallCSBN then
			-- another addon replaced us; call them
		end
		-- fallback: nothing more to call (we ARE the last in chain)
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

local function MTH_EA_HookInstallUA()
	local origUA = UseAction
	UseAction = function(slot, checkCursor, onSelf)
		if MTH_EA_InHookUA then
			if origUA then return origUA(slot, checkCursor, onSelf) end
			return
		end
		MTH_EA_InHookUA = true
		if type(GetActionText) == "function" and type(GetSpellName) == "function" then
			-- For spell-type actions, resolve name via tooltip probe
			local probe = MTH_SA_AmmoProbe  -- reuse SmartAmmo's tooltip probe if available
			if probe then
				probe:SetOwner(UIParent, "ANCHOR_NONE")
				probe:SetAction(slot)
				local txt = MTH_SA_AmmoProbeTextLeft1 and MTH_SA_AmmoProbeTextLeft1:GetText()
				if txt and txt ~= "" then MTH_EA_LastSpell = txt end
			end
		end
		local result
		if origUA then result = origUA(slot, checkCursor, onSelf) end
		MTH_EA_InHookUA = false
		return result
	end
end

-- ── Debug mode ────────────────────────────────────────────────
-- /script MTH_EA_DebugMode = true   → prints every Ammunition chat event
-- /script MTH_EA_DebugMode = false  → silent
MTH_EA_DebugMode = false

-- ── Broad debug sniffer ───────────────────────────────────────
-- A separate frame that registers EVERY CHAT_MSG_SPELL_* event and
-- prints any message containing "Ammunition", so we can find exactly
-- which event the server uses for the gain messages.
local MTH_EA_Sniffer = CreateFrame("Frame", "MTH_EA_SnifferFrame")
local MTH_EA_SNIFFER_EVENTS = {
	"CHAT_MSG_SPELL_SELF_BUFF",
	"CHAT_MSG_SPELL_AURA_GONE_SELF",
	"CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS",
	"CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE",
	"CHAT_MSG_SPELL_CREATURE_VS_SELF_BUFF",
	"CHAT_MSG_SPELL_FRIENDLYPLAYER_BUFF",
	"CHAT_MSG_SPELL_HOSTILEPLAYER_BUFF",
	"CHAT_MSG_SPELL_AURA_GONE_PARTY",
	"CHAT_MSG_SPELL_AURA_GONE_OTHER",
}
for _, ev in ipairs(MTH_EA_SNIFFER_EVENTS) do
	MTH_EA_Sniffer:RegisterEvent(ev)
end
MTH_EA_Sniffer:SetScript("OnEvent", function()
	if not MTH_EA_DebugMode then return end
	local msg = arg1 or ""
	if string.find(msg, "Ammunition") then
	end
end)

-- ── Event frame ───────────────────────────────────────────────
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

frame:SetScript("OnUpdate", function()
	if not MTH_EA_IsEnabled() then return end
	local dt = arg1 or 0
	this._elapsed = (this._elapsed or 0) + dt
	cellBotBlink  = cellBotBlink + dt   -- accumulate for blink pulse

	-- Natural state expiry: the game doesn't auto-advance on expiry,
	-- so we go to IDLE. If the player consumed it, CHAT_MSG_AURA_GONE_SELF
	-- already handled it; this path only fires on genuine timeout.
	if rt.state ~= IDLE and GetTime() >= rt.expiresAt then
		MTH_EA_SetState(IDLE)
		cellBotBlink = 0
	end

	-- LnL natural expiry (belt-and-suspenders; AURA_GONE_SELF should cover it)
	if lnl.active and GetTime() >= lnl.expiresAt then
		lnl.active = false
	end

	if this._elapsed < 0.25 then return end
	this._elapsed = 0
	MTH_EA_UpdateUI()
end)

frame:SetScript("OnEvent", function()
	if event == "VARIABLES_LOADED" then
		-- Install hooks once SavedVariables are available
		MTH_EA_HookInstallCSBN()
		MTH_EA_HookInstallCS()
		MTH_EA_HookInstallUA()
		return
	end

	if event == "PLAYER_ENTERING_WORLD" then
		MTH_EA_EnsureConfigDefaults()
		rt.state     = IDLE
		rt.expiresAt = 0
		rt.consumed  = false
		rt.lastState = nil
		MTH_EA_LastSpell = nil
		lnl.active        = false
		lnlPendingCapture = false
		MTH_EA_SnapshotBuffs()

		-- Update talent flag from whatever the scanner has so far.
		-- We do NOT gate strip visibility on this: GetTalentInfo can return
		-- stale data briefly on login before the client finishes loading
		-- talent data.  Show the strip if enabled; MTH_HT_OnScanComplete
		-- will hide it later if the talent is truly absent after a proper scan.
		MTH_EA_HasTalent = MTH_HT_HasTalent and MTH_HT_HasTalent(TALENT_NAME) or false

		MTH_EA_CreateUI()
		if MTH_EA_IsEnabled() then
			-- Recover any active ammo aura (survives /reload in same session)
			MTH_EA_RecoverStateFromBuffs()
			inCombat = UnitAffectingCombat and UnitAffectingCombat("player") and true or false
			frame:Show()
			MTH_EA_RefreshVisibility()
		else
			strip:Hide()
		end
		MTH_EA_UpdateUI()
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
		if rt.state == IDLE then
			local stateKey = MTH_EA_FindAmmoStateByTexture()
			if stateKey then
				rt.state     = stateKey
				rt.expiresAt = now + CYCLE_DURATION
				rt.consumed  = false
			end
			MTH_EA_UpdateUI()
		end
		return
	end

	-- ── Primary state detection via combat log messages ───────────────
	-- On TWoW/MaNGOS the event routing for debuffs may differ from
	-- vanilla.  We therefore check BOTH gain and loss patterns in
	-- every chat_msg_spell event we receive, and match regardless of
	-- which specific event name the server chose to use.
	local function MTH_EA_TryHandleChatMsg(msg)
		if not MTH_EA_IsEnabled() then return false end
		msg = msg or ""
		-- ── State GAIN patterns ─────────────────────────────────────
		local _, _, gained = string.find(msg, "^You are afflicted by (.+)%.$")
		if not gained then
			_, _, gained = string.find(msg, "^You gain (.+)%.$")
		end
		if not gained then
			_, _, gained = string.find(msg, "^You gain the effect of (.+)%.$")
		end
		if gained then
			-- Ammo state?
			local stateKey = BUFF_TO_STATE[gained]
			if stateKey then
				if MTH_EA_DebugMode then
				end
				MTH_EA_SetState(stateKey)
				return true
			end
			-- Lock and Load? Chat message is a late-arriving fallback;
			-- PLAYER_AURAS_CHANGED + tooltip scan is the primary path.
			if string.find(gained, "Lock and Load") then
				if not lnl.active then
					-- Fallback: AURAS_CHANGED missed it; sync from tooltip now.
					local rem = MTH_EA_GetLnLRemaining()
					lnl.active    = true
					lnl.expiresAt = GetTime() + (rem or lnl.DURATION)
				end
				if MTH_EA_DebugMode then
				end
				return true
			end
		end
		-- ── State LOSS patterns ──────────────────────────────────────
		local _, _, lost = string.find(msg, "^(.+) fades from you%.$")
		if not lost then
			_, _, lost = string.find(msg, "^(.+) fades from you$")  -- no trailing period
		end
		if lost then
			-- Ammo state?
			local stateKey = BUFF_TO_STATE[lost]
			if stateKey then
				if MTH_EA_DebugMode then
				end
				if rt.state == stateKey then
					MTH_EA_SetState(IDLE)
				end
				return true
			end
			-- Lock and Load?
			if string.find(lost, "Lock and Load") then
				if MTH_EA_DebugMode then
				end
				lnl.active        = false
				lnlPendingCapture = false
				MTH_EA_SnapshotBuffs()  -- reset baseline; LnL no longer on player
				return true
			end
		end
		-- Debug: print any Ammunition message even if unmatched
		if MTH_EA_DebugMode then
			if string.find(msg, "Ammunition") then
			end
		end
		return false
	end

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

	-- We rely on MTH_EA_LastSpell captured in our CastSpellByName hook.
	-- Also check MTH_SA_LastSpell as a fallback (SmartAmmo's capture).
	local spellName = MTH_EA_LastSpell
		or (type(MTH_SA_LastSpell) == "string" and MTH_SA_LastSpell)
		or ""

	if event == "SPELLCAST_STOP" then
		if MTH_EA_DebugMode then
		end
		-- Predictive: show the expected next ammo state immediately when Aimed Shot
		-- fires from IDLE, before the server debuff message arrives (~1s later).
		-- We predict based on lastState so we show the correct one (not always EXPLOSIVE):
		--   no prior cycle / after ENCHANTED → EXPLOSIVE
		--   after EXPLOSIVE                  → POISONOUS
		--   after POISONOUS                  → ENCHANTED
		if spellName == SPELL_AIMED and rt.state == IDLE then
			local predicted = PREDICT_NEXT[rt.lastState] or EXPLOSIVE
			if MTH_EA_DebugMode then
			end
			MTH_EA_SetState(predicted)
		end
		-- Consume-spell detection removed: CHAT_MSG_SPELL_AURA_GONE_SELF handles
		-- state loss authoritatively. No AdvanceState here.
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
		if strip then
			if cfg.enabled then
				MTH_EA_RefreshVisibility()
			else
				strip:Hide()
			end
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
}
