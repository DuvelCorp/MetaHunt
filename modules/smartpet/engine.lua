------------------------------------------------------
-- MetaHunt: SmartPet — Pet Combat Management
-- TWoW 1.18.1
------------------------------------------------------
--
-- Integrated pet combat manager inspired by SmartPet v2.5.1.
-- Handles taunt management, focus budgeting, CC-break
-- prevention, PVP auto-detaunt, The Button keybind,
-- NoChase, Dash/Dive on attack, auto-cower, and
-- low-health chat warnings.
------------------------------------------------------

-- ── Localised ability names ──────────────────────────────────
-- Resolved from MTH_LocaleData.spells via MTH:LocalizeSpell().
-- PET_ACTION_FOLLOW / PET_ACTION_ATTACK are built-in WoW tokens,
-- not localised spell names.
local L_GROWL, L_COWER, L_CLAW, L_BITE, L_DASH, L_DIVE
local L_LIGHTNING_BREATH, L_SCREECH, L_SCORPID_POISON
local L_CHARGE, L_DEATH_ROLL, L_FURIOUS_HOWL, L_SAVAGE_REND
local L_THUNDERSTOMP, L_POISON_SPIT, L_POLLEN_BURST
local L_PROWL, L_SHELL_SHIELD, L_GRACE, L_BUBBLE_BARRIER
local L_WEB, L_ROAR_OF_FORTITUDE, L_PACKLEADER, L_STRIDER_PRESENCE
local L_FOLLOW = "PET_ACTION_FOLLOW"
local L_ATTACK = "PET_ACTION_ATTACK"
local L_FLEE   = "attempts to run away in fear"

-- ── CC debuff token list (English keys into spell locale) ────
local CC_DEBUFF_TOKENS = {
	"Gouge", "Sap", "Charm", "Seduction", "Sheep", "Polymorph",
	"Tame Beast", "Scare Beast", "Sleep", "Hibernate", "Fear",
	"Mind Control", "Blind", "Scatter Shot", "Enslave Demon",
	"Shackle Undead", "Reckless Charge", "Freezing Trap Effect",
	"Intimidating Shout", "Repentance", "Wyvern Sting",
}

-- Populated once MTH:LocalizeSpell is available (VARIABLES_LOADED)
local CC_DEBUFF_SET = {}

-- Maps localised ability names to rt.slot keys.
local ABILITY_MAP = {}
local function BuildAbilityMap()
	ABILITY_MAP = {
		[L_GROWL]  = "growl",
		[L_COWER]  = "cower",
		[L_CLAW]   = "claw",
		[L_BITE]   = "bite",
		[L_FOLLOW] = "follow",
		[L_ATTACK] = "attack",
		[L_DASH]   = "dash",
		[L_DIVE]   = "dive",
	}
	-- Conditionally add family-specific abilities (nil-safe: L_ vars may be nil before locale resolution)
	if L_LIGHTNING_BREATH  then ABILITY_MAP[L_LIGHTNING_BREATH]  = "lightningBreath"  end
	if L_SCREECH           then ABILITY_MAP[L_SCREECH]           = "screech"           end
	if L_SCORPID_POISON    then ABILITY_MAP[L_SCORPID_POISON]    = "scorpidPoison"    end
	if L_CHARGE            then ABILITY_MAP[L_CHARGE]            = "charge"            end
	if L_DEATH_ROLL        then ABILITY_MAP[L_DEATH_ROLL]        = "deathRoll"        end
	if L_FURIOUS_HOWL      then ABILITY_MAP[L_FURIOUS_HOWL]      = "furiousHowl"      end
	if L_SAVAGE_REND       then ABILITY_MAP[L_SAVAGE_REND]       = "savageRend"       end
	if L_THUNDERSTOMP      then ABILITY_MAP[L_THUNDERSTOMP]      = "thunderstomp"     end
	if L_POISON_SPIT       then ABILITY_MAP[L_POISON_SPIT]       = "poisonSpit"       end
	if L_POLLEN_BURST      then ABILITY_MAP[L_POLLEN_BURST]      = "pollenBurst"      end
	if L_PROWL             then ABILITY_MAP[L_PROWL]             = "prowl"             end
	if L_SHELL_SHIELD      then ABILITY_MAP[L_SHELL_SHIELD]      = "shellShield"      end
	if L_GRACE             then ABILITY_MAP[L_GRACE]             = "grace"             end
	if L_BUBBLE_BARRIER    then ABILITY_MAP[L_BUBBLE_BARRIER]    = "bubbleBarrier"    end
	if L_WEB               then ABILITY_MAP[L_WEB]               = "web"              end
	if L_ROAR_OF_FORTITUDE then ABILITY_MAP[L_ROAR_OF_FORTITUDE] = "roarOfFortitude"  end
	if L_PACKLEADER        then ABILITY_MAP[L_PACKLEADER]        = "packleader"       end
	if L_STRIDER_PRESENCE  then ABILITY_MAP[L_STRIDER_PRESENCE]  = "striderPresence"  end
end

-- Called at VARIABLES_LOADED when the locale system is ready
local function ResolveLocaleStrings()
	if not (MTH and MTH.LocalizeSpell) then return end

	L_GROWL = MTH:LocalizeSpell("Growl")
	L_COWER = MTH:LocalizeSpell("Cower")
	L_CLAW  = MTH:LocalizeSpell("Claw")
	L_BITE  = MTH:LocalizeSpell("Bite")
	L_DASH  = MTH:LocalizeSpell("Dash")
	L_DIVE  = MTH:LocalizeSpell("Dive")

	-- Family-specific abilities
	L_LIGHTNING_BREATH  = MTH:LocalizeSpell("Lightning Breath")
	L_SCREECH           = MTH:LocalizeSpell("Screech")
	L_SCORPID_POISON    = MTH:LocalizeSpell("Scorpid Poison")
	L_CHARGE            = MTH:LocalizeSpell("Charge")
	L_DEATH_ROLL        = MTH:LocalizeSpell("Death Roll")
	L_FURIOUS_HOWL      = MTH:LocalizeSpell("Furious Howl")
	L_SAVAGE_REND       = MTH:LocalizeSpell("Savage Rend")
	L_THUNDERSTOMP      = MTH:LocalizeSpell("Thunderstomp")
	L_POISON_SPIT       = MTH:LocalizeSpell("Poison Spit")
	L_POLLEN_BURST      = MTH:LocalizeSpell("Pollen Burst")
	L_PROWL             = MTH:LocalizeSpell("Prowl")
	L_SHELL_SHIELD      = MTH:LocalizeSpell("Shell Shield")
	L_GRACE             = MTH:LocalizeSpell("Grace")
	L_BUBBLE_BARRIER    = MTH:LocalizeSpell("Bubble Barrier")
	L_WEB               = MTH:LocalizeSpell("Web")
	L_ROAR_OF_FORTITUDE = MTH:LocalizeSpell("Roar of Fortitude")
	L_PACKLEADER        = MTH:LocalizeSpell("Packleader")
	L_STRIDER_PRESENCE  = MTH:LocalizeSpell("Strider Presence")

	-- Flee pattern from spell locale (special key)
	local spellLocales = MTH_LocaleData and MTH_LocaleData.spells
	if spellLocales then
		local locale = MTH.currentLocale or "enUS"
		local aliases = { enGB = "enUS", esMX = "esES", zhTW = "zhCN" }
		if aliases[locale] then locale = aliases[locale] end
		local map = spellLocales[locale] or spellLocales.enUS
		if map and map["SP_FLEE_PATTERN"] then
			L_FLEE = map["SP_FLEE_PATTERN"]
		end
	end

	-- Rebuild CC debuff set from localised names
	CC_DEBUFF_SET = {}
	for _, token in ipairs(CC_DEBUFF_TOKENS) do
		local localized = MTH:LocalizeSpell(token)
		CC_DEBUFF_SET[localized] = true
	end

	-- Rebuild ability map with resolved names
	BuildAbilityMap()
end

-- ── Constants ────────────────────────────────────────────────
local FOCUS_REGEN_INTERVAL = 5     -- pet focus ticks roughly every 5s

-- Pet action bar slot count (WoW 1.12)
local NUM_PET_SLOTS = NUM_PET_ACTION_SLOTS or 10

-- Ability metadata: focus cost and behaviour type.
-- type: "taunt", "autocastDPS" (spammable, no meaningful CD),
--       "semiAutocast" (short CD, still autocasts frequently),
--       "cdDPS" (significant cooldown), "mobility", "defensive",
--       "utility", "partyBuff"
local ABILITY_INFO = {
	growl           = { cost = 15, type = "taunt" },
	cower           = { cost = 15, type = "taunt" },
	bite            = { cost = 35, type = "autocastDPS" },
	claw            = { cost = 25, type = "autocastDPS" },
	lightningBreath = { cost = 50, type = "autocastDPS" },
	scorpidPoison   = { cost = 25, type = "semiAutocast" },
	screech         = { cost = 20, type = "semiAutocast" },
	charge          = { cost = 35, type = "cdDPS" },
	deathRoll       = { cost = 50, type = "cdDPS" },
	furiousHowl     = { cost = 50, type = "cdDPS" },
	savageRend      = { cost = 25, type = "cdDPS" },
	thunderstomp    = { cost = 60, type = "cdDPS" },
	poisonSpit      = { cost = 35, type = "cdDPS" },
	pollenBurst     = { cost = 40, type = "cdDPS" },
	dash            = { cost = 20, type = "mobility" },
	dive            = { cost = 20, type = "mobility" },
	prowl           = { cost = 40, type = "utility" },
	shellShield     = { cost = 10, type = "defensive" },
	grace           = { cost = 10, type = "defensive" },
	bubbleBarrier   = { cost = 20, type = "defensive" },
	web             = { cost = 0,  type = "utility" },
	roarOfFortitude = { cost = 50, type = "partyBuff" },
	packleader      = { cost = 50, type = "partyBuff" },
	striderPresence = { cost = 50, type = "partyBuff" },
}

-- Ability keys whose autocast is managed by the focus budget system.
local MANAGED_DPS_TYPES = { autocastDPS = true, semiAutocast = true, cdDPS = true }

-- ── Config defaults (persisted per-character) ────────────────
local CONFIG_DEFAULTS = {
	tauntMode       = "auto",   -- "auto" | "growl" | "cower" | "off"
	pvpDetaunt      = true,
	ccBreakCheck    = true,
	ccBreakMode     = "block",  -- "block" | "warn"
	theButton       = true,
	smartFocus      = false,
	autoCower       = false,
	autoCowerPct    = 30,
	noChase         = false,
	rushOnAttack    = true,
	autoWarn        = false,
	autoWarnPct     = 20,
	autoWarnChannel = "SAY",
}

-- ── Runtime state (not persisted) ────────────────────────────
local rt = {
	inCombat        = false,
	inPVP           = false,
	-- Backed-up pre-PVP autocast states
	pvpBackup       = nil,         -- { growl=bool, cower=bool, autoCower=bool }
	-- Pet action bar slot indices (-1 = not found)
	slot            = {
		attack          = -1,
		follow          = -1,
		growl           = -1,
		cower           = -1,
		bite            = -1,
		claw            = -1,
		dash            = -1,
		dive            = -1,
		lightningBreath = -1,
		screech         = -1,
		scorpidPoison   = -1,
		charge          = -1,
		deathRoll       = -1,
		furiousHowl     = -1,
		savageRend      = -1,
		thunderstomp    = -1,
		poisonSpit      = -1,
		pollenBurst     = -1,
		prowl           = -1,
		shellShield     = -1,
		grace           = -1,
		bubbleBarrier   = -1,
		web             = -1,
		roarOfFortitude = -1,
		packleader      = -1,
		striderPresence = -1,
	},
	-- Pet spellbook indices for rush abilities (used for CastSpell)
	spellbook       = {
		dash   = -1,
		dive   = -1,
		charge = -1,
	},
	-- Focus tracking
	focus1          = 100,
	focus2          = 100,
	lastFocusTick   = 0,
	nextFocusTick   = 0,
	-- Smart Focus: remember which DPS autocasts were ON at combat start
	preCombatAutocast = {},  -- { [slotKey] = bool }
	-- AutoCower: track if we swapped to cower
	autoCowered     = false,
	-- AutoWarn throttle
	lastWarnTime    = 0,
	lastWarnPct     = 0,
	-- NoChase recall flag
	recallPending   = false,
	-- TheButton context
	theButtonRecall = false,
	-- Party has a tank (cached)
	partyHasTank    = false,
}

-- ── Hidden tooltip for debuff scanning (legacy path) ─────────
local debuffTip = nil
local function EnsureDebuffTip()
	if debuffTip then return debuffTip end
	debuffTip = CreateFrame("GameTooltip", "MTH_SP_DebuffTip", UIParent, "GameTooltipTemplate")
	debuffTip:SetOwner(UIParent, "ANCHOR_NONE")
	return debuffTip
end

-- ── Config helpers ───────────────────────────────────────────
local function GetCfg()
	if type(MTH_SavedVariables) ~= "table" then return CONFIG_DEFAULTS end
	if type(MTH_SavedVariables.modules) ~= "table" then
		MTH_SavedVariables.modules = {}
	end
	local cfg = MTH_SavedVariables.modules["smartpet"]
	if type(cfg) ~= "table" then
		cfg = {}
		MTH_SavedVariables.modules["smartpet"] = cfg
	end
	-- Fill defaults for missing keys
	for k, v in pairs(CONFIG_DEFAULTS) do
		if cfg[k] == nil then
			cfg[k] = v
		end
	end
	return cfg
end

local function IsEnabled()
	if not (MTH and MTH.IsModuleEnabled) then return false end
	return MTH:IsModuleEnabled("smartpet", false)
end

-- ── Pet action bar helpers ───────────────────────────────────
local function GetAutocast(slotIndex)
	if slotIndex < 1 then return false end
	local name, subtext, texture, isToken, isActive, autoCastAllowed, autoCastEnabled = GetPetActionInfo(slotIndex)
	return autoCastEnabled and true or false
end

local function SetAutocast(slotIndex, enabled)
	if slotIndex < 1 then return end
	local current = GetAutocast(slotIndex)
	if (current and not enabled) or (not current and enabled) then
		TogglePetAutocast(slotIndex)
	end
end

-- ── Pet action bar scanning ──────────────────────────────────

local function ScanPetActionBar()
	for key in pairs(rt.slot) do
		rt.slot[key] = -1
	end
	for i = 1, NUM_PET_SLOTS do
		local name = GetPetActionInfo(i)
		if name then
			local key = ABILITY_MAP[name]
			if key then
				rt.slot[key] = i
			end
		end
	end
end

-- Scan pet spellbook for rush ability indices (for CastSpell)
local function ScanPetSpellbook()
	rt.spellbook.dash   = -1
	rt.spellbook.dive   = -1
	rt.spellbook.charge = -1
	for i = 1, 20 do
		local spellName = GetSpellName(i, BOOKTYPE_PET)
		if not spellName then break end
		if spellName == L_DASH then
			rt.spellbook.dash = i
		elseif spellName == L_DIVE then
			rt.spellbook.dive = i
		elseif spellName == L_CHARGE then
			rt.spellbook.charge = i
		end
	end
end

-- ── Party/tank detection ─────────────────────────────────────
local TANK_CLASSES = { WARRIOR = true, PALADIN = true }
-- Druid tanks detected by class + bear form buff (approximate)

local function ScanPartyForTank()
	local members = GetNumPartyMembers and GetNumPartyMembers() or 0
	local raid    = GetNumRaidMembers and GetNumRaidMembers() or 0

	if members == 0 and raid == 0 then
		rt.partyHasTank = false
		return
	end

	-- Raid scan
	if raid > 0 then
		for i = 1, raid do
			local unit = "raid" .. i
			if UnitExists(unit) and not UnitIsUnit(unit, "player") then
				local _, cls = UnitClass(unit)
				if cls and TANK_CLASSES[cls] then
					rt.partyHasTank = true
					return
				end
				if cls == "DRUID" then
					-- Check for bear form via power type (rage = 1)
					if UnitPowerType and UnitPowerType(unit) == 1 then
						rt.partyHasTank = true
						return
					end
				end
			end
		end
		rt.partyHasTank = false
		return
	end

	-- Party scan
	for i = 1, members do
		local unit = "party" .. i
		if UnitExists(unit) then
			local _, cls = UnitClass(unit)
			if cls and TANK_CLASSES[cls] then
				rt.partyHasTank = true
				return
			end
			if cls == "DRUID" then
				if UnitPowerType and UnitPowerType(unit) == 1 then
					rt.partyHasTank = true
					return
				end
			end
		end
	end
	rt.partyHasTank = false
end

-- ── Taunt Management ─────────────────────────────────────────
local function ApplyTauntMode()
	if not IsEnabled() then return end
	local cfg = GetCfg()
	local mode = cfg.tauntMode

	if mode == "off" then return end
	if mode == "growl" then
		SetAutocast(rt.slot.growl, true)
		SetAutocast(rt.slot.cower, false)
		return
	end
	if mode == "cower" then
		SetAutocast(rt.slot.growl, false)
		SetAutocast(rt.slot.cower, true)
		return
	end
	-- auto: solo → growl, party with tank → cower
	if rt.partyHasTank then
		SetAutocast(rt.slot.growl, false)
		if rt.slot.cower > 0 then
			SetAutocast(rt.slot.cower, true)
		end
	else
		SetAutocast(rt.slot.growl, true)
		SetAutocast(rt.slot.cower, false)
	end
end

-- ── PVP Auto-Detaunt ─────────────────────────────────────────
local function StartPVP()
	if rt.inPVP then return end
	local cfg = GetCfg()
	if not cfg.pvpDetaunt then return end

	rt.inPVP = true
	rt.pvpBackup = {
		growl     = GetAutocast(rt.slot.growl),
		cower     = GetAutocast(rt.slot.cower),
		autoCower = cfg.autoCower,
	}
	SetAutocast(rt.slot.growl, false)
	SetAutocast(rt.slot.cower, false)
end

local function EndPVP()
	if not rt.inPVP then return end
	rt.inPVP = false
	if rt.pvpBackup then
		SetAutocast(rt.slot.growl, rt.pvpBackup.growl)
		SetAutocast(rt.slot.cower, rt.pvpBackup.cower)
		-- Restore autoCower setting — it doesn't get toggled on the bar, just the config flag
		rt.pvpBackup = nil
	end
end

-- ── CC-Break Prevention ──────────────────────────────────────
-- Returns true if the target has a breakable CC debuff.
local function TargetHasBreakableCC()
	local cfg = GetCfg()
	if not cfg.ccBreakCheck then return false end

	-- NamPower path: GetUnitField aura array
	if type(GetUnitField) == "function" then
		local auras = GetUnitField("target", "aura")
		if type(auras) == "table" then
			for _, aura in ipairs(auras) do
				if type(aura) == "table" then
					local auraName = aura.name or (aura.spellId and GetSpellRecField and GetSpellRecField(aura.spellId, "name"))
					if auraName and CC_DEBUFF_SET[auraName] then
						return true
					end
				end
			end
			return false
		end
	end

	-- Legacy path: hidden tooltip scan
	local tip = EnsureDebuffTip()
	tip:ClearLines()
	for j = 1, 16 do
		if not UnitDebuff("target", j) then break end
		tip:SetUnitDebuff("target", j)
		local nameRegion = getglobal("MTH_SP_DebuffTipTextLeft1")
		if nameRegion then
			local debuffName = nameRegion:GetText()
			if debuffName and CC_DEBUFF_SET[debuffName] then
				return true
			end
		end
	end
	return false
end

-- ── Rush on attack (Dash / Dive / Charge) ────────────────────
local function CastChargeAbility()
	local cfg = GetCfg()
	if not cfg.rushOnAttack then return end
	if rt.inCombat then return end  -- only on initial engage

	-- Try Charge first (Boar — rush + damage), then Dash, then Dive
	local idx = -1
	if rt.spellbook.charge > 0 then
		idx = rt.spellbook.charge
	elseif rt.spellbook.dash > 0 then
		idx = rt.spellbook.dash
	elseif rt.spellbook.dive > 0 then
		idx = rt.spellbook.dive
	end
	if idx < 1 then return end

	local start, duration = GetSpellCooldown(idx, BOOKTYPE_PET)
	if start == 0 and duration == 0 then
		CastSpell(idx, BOOKTYPE_PET)
	end
end

-- ── Smart Focus ──────────────────────────────────────────────
-- Estimate how many focus-regen ticks will occur during an ability's cooldown.
local function EstimatedFocusRegen(slotIndex)
	if slotIndex < 1 then return 0 end
	local start, duration = GetPetActionCooldown(slotIndex)
	if not start or start == 0 then return 0 end
	local remaining = (start + duration) - GetTime()
	if remaining <= 0 then return 0 end
	-- Each tick gives ~FOCUS_REGEN_INTERVAL worth of focus ticks at ~24 focus per 5s cycle
	-- SmartPet used FocusManager * 4.8; we use a simpler remaining/5 * 24 estimate
	local ticks = remaining / FOCUS_REGEN_INTERVAL
	return ticks * 24
end

local function HandleFocusEvent()
	if not IsEnabled() then return end
	local cfg = GetCfg()
	if not cfg.smartFocus and cfg.tauntMode == "off" then return end
	if not rt.inCombat then return end
	if rt.inPVP then return end

	-- Track focus regen tick timing
	rt.focus2 = rt.focus1
	rt.focus1 = UnitMana("pet") or 0
	if rt.focus1 > rt.focus2 then
		rt.lastFocusTick = GetTime()
		rt.nextFocusTick = rt.lastFocusTick + 4.5
	end

	local currentFocus = rt.focus1

	-- Determine taunt cost (must always be reservable)
	local tauntCost = 0
	if cfg.tauntMode ~= "off" then
		if GetAutocast(rt.slot.cower) then
			tauntCost = ABILITY_INFO.cower.cost
		elseif rt.slot.growl > 0 then
			tauntCost = ABILITY_INFO.growl.cost
		end
	end

	-- Collect managed DPS abilities (on bar AND pre-combat autocast was ON)
	local managed = {}  -- { {key, cost, slot}, ... }
	local managedN = 0
	for key, wasOn in pairs(rt.preCombatAutocast) do
		if wasOn and rt.slot[key] > 0 and ABILITY_INFO[key] then
			managedN = managedN + 1
			managed[managedN] = { key = key, cost = ABILITY_INFO[key].cost, slot = rt.slot[key] }
		end
	end

	if managedN == 0 then return end

	-- Sort by cost descending (most expensive = highest priority to keep active)
	table.sort(managed, function(a, b) return a.cost > b.cost end)

	if cfg.smartFocus and managedN >= 2 then
		-- Smart Focus: reserve taunt cost once, then budget the rest across DPS.
		-- Always keep the cheapest ability ON so the pet never sits idle;
		-- the worst case is growl is delayed by one regen tick (~5s).
		local budget = currentFocus - tauntCost
		if budget < 0 then budget = 0 end
		if MTH and MTH.Print then
			MTH:Print("[SP] focus=" .. currentFocus .. " reserve=" .. tauntCost .. " budget=" .. budget .. " managed=" .. managedN, "debug")
		end
		local anyEnabled = false
		for i = 1, managedN do
			local m = managed[i]
			if budget >= m.cost then
				SetAutocast(m.slot, true)
				anyEnabled = true
				if MTH and MTH.Print then
					MTH:Print("[SP]   " .. m.key .. " ON  (cost=" .. m.cost .. " left=" .. (budget - m.cost) .. ")", "debug")
				end
				budget = budget - m.cost
			elseif i == managedN and not anyEnabled then
				-- Cheapest ability: keep ON so pet isn't idle
				SetAutocast(m.slot, true)
				if MTH and MTH.Print then
					MTH:Print("[SP]   " .. m.key .. " ON* (cheapest, waiting for regen)", "debug")
				end
			else
				SetAutocast(m.slot, false)
				if MTH and MTH.Print then
					MTH:Print("[SP]   " .. m.key .. " OFF (cost=" .. m.cost .. " budget=" .. budget .. ")", "debug")
				end
			end
		end
		return
	end

	-- Basic taunt-priority: disable any DPS ability that would starve the taunt
	if cfg.tauntMode ~= "off" and tauntCost > 0 then
		for i = 1, managedN do
			local m = managed[i]
			local regen = EstimatedFocusRegen(m.slot)
			if (currentFocus + regen) - m.cost < tauntCost then
				SetAutocast(m.slot, false)
				if MTH and MTH.Print then
					MTH:Print("[SP]   tauntGuard " .. m.key .. " OFF (focus=" .. currentFocus .. " regen=" .. math.floor(regen) .. ")", "debug")
				end
			else
				SetAutocast(m.slot, true)
			end
		end
	end
end

-- ── AutoCower on low HP ──────────────────────────────────────
local function HandlePetHealth()
	if not IsEnabled() then return end
	if not rt.inCombat then return end
	local cfg = GetCfg()

	local hp    = UnitHealth("pet") or 0
	local hpMax = UnitHealthMax("pet") or 1
	if hpMax == 0 then hpMax = 1 end
	local pct = (100 * hp) / hpMax

	-- AutoCower
	if cfg.autoCower and rt.slot.cower > 0 then
		if pct < cfg.autoCowerPct then
			if not rt.autoCowered then
				rt.autoCowered = true
				SetAutocast(rt.slot.growl, false)
				SetAutocast(rt.slot.cower, true)
			end
		else
			if rt.autoCowered then
				rt.autoCowered = false
				ApplyTauntMode()
			end
		end
	end

	-- AutoWarn
	if cfg.autoWarn then
		local warnInterval
		if pct >= 60 then
			warnInterval = 10
		elseif pct >= 50 then
			warnInterval = 8
		elseif pct >= 30 then
			warnInterval = 6
		else
			warnInterval = 4
		end
		if pct < cfg.autoWarnPct
			and (GetTime() - rt.lastWarnTime) > warnInterval
			and rt.lastWarnPct > pct then
			local petName = UnitName("pet") or "Pet"
			local msg = petName .. " needs healing! (" .. string.format("%d", pct) .. "% Health)"
			local chan = string.upper(cfg.autoWarnChannel or "SAY")
			-- Validate channel
			if chan == "PARTY" then
				if not (UnitInParty and UnitInParty("player")) then chan = "SAY" end
			elseif chan == "RAID" then
				if not (GetNumRaidMembers and GetNumRaidMembers() > 0) then chan = "SAY" end
			elseif chan == "GUILD" then
				if not (IsInGuild and IsInGuild()) then chan = "SAY" end
			elseif chan ~= "SAY" then
				chan = "SAY"
			end
			SendChatMessage(msg, chan)
			rt.lastWarnTime = GetTime()
		end
		rt.lastWarnPct = pct
	end
end

-- ── NoChase ──────────────────────────────────────────────────
local function HandleMonsterEmote(emoteText, sourceName)
	if not IsEnabled() then return end
	local cfg = GetCfg()
	if not cfg.noChase then return end

	local petTarget = UnitName("pettarget")
	if sourceName and petTarget and sourceName == petTarget
		and strfind(emoteText or "", L_FLEE) then
		PetFollow()
		rt.theButtonRecall = true
		if UIErrorsFrame then
			UIErrorsFrame:AddMessage("Recall Pet", 0.0, 0.0, 1.0, 1.0, UIERRORS_HOLD_TIME)
		end
	end
end

-- ── Pet Damage Meter ─────────────────────────────────────────
local meter = {
	active    = false,
	recording = false,  -- true while actively collecting data
	startTime = 0,
	duration  = 0,       -- 0 = unlimited, >0 = auto-stop after N seconds
	totalDmg  = 0,
	totalHits = 0,
	totalCrits = 0,
	totalMisses = 0,
	abilities = {},  -- [name] = { dmg=N, hits=N, crits=N, misses=N }
	petName   = "",
	autocastSnapshot = "",  -- "Bite=ON Claw=ON Growl=OFF ..."
}

local MeterPrintSummary  -- forward declaration
local MeterStop          -- forward declaration

local function MeterReset()
	meter.startTime = GetTime()
	meter.recording = true
	meter.totalDmg = 0
	meter.totalHits = 0
	meter.totalCrits = 0
	meter.totalMisses = 0
	meter.abilities = {}
	-- Snapshot pet name
	meter.petName = UnitName("pet") or "Unknown"
	-- Ensure slot map is current before reading autocast states
	ScanPetActionBar()
	-- Snapshot all known ability autocast states
	local parts = {}
	local partN = 0
	for key, info in pairs(ABILITY_INFO) do
		if rt.slot[key] and rt.slot[key] > 0 then
			local on = GetAutocast(rt.slot[key])
			partN = partN + 1
			parts[partN] = key .. "=" .. (on and "ON" or "OFF")
		end
	end
	table.sort(parts)
	meter.autocastSnapshot = table.concat(parts, "  ")
end

MeterStop = function()
	meter.recording = false
	meter.active = false
	if meter.totalDmg > 0 then MeterPrintSummary() end
	MTH:Print("|cffff9900[SP Meter]|r Stopped.")
end

local function MeterGetAbility(name)
	if not meter.abilities[name] then
		meter.abilities[name] = { dmg = 0, hits = 0, crits = 0, misses = 0 }
	end
	return meter.abilities[name]
end

local function MeterParseCombatMsg(msg)
	if not meter.recording or not msg then return end

	local ability, dmg = nil, nil

	-- hit: "<Name>'s <Spell> hits <target> for <N>."
	_, _, ability, dmg = strfind(msg, "'s ([%a ]-) hits .+ for (%d+)")
	if ability and dmg then
		dmg = tonumber(dmg) or 0
		local a = MeterGetAbility(ability)
		a.hits = a.hits + 1
		a.dmg = a.dmg + dmg
		meter.totalHits = meter.totalHits + 1
		meter.totalDmg = meter.totalDmg + dmg
		return
	end

	-- crit: "<Name>'s <Spell> crits <target> for <N>."
	_, _, ability, dmg = strfind(msg, "'s ([%a ]-) crits .+ for (%d+)")
	if ability and dmg then
		dmg = tonumber(dmg) or 0
		local a = MeterGetAbility(ability)
		a.crits = a.crits + 1
		a.dmg = a.dmg + dmg
		meter.totalCrits = meter.totalCrits + 1
		meter.totalDmg = meter.totalDmg + dmg
		return
	end

	-- miss/resist: "<Name>'s <Spell> misses" / "<Name>'s <Spell> was resisted"
	_, _, ability = strfind(msg, "'s ([%a ]-) misses")
	if not ability then
		_, _, ability = strfind(msg, "'s ([%a ]-) was ")
	end
	if ability then
		local a = MeterGetAbility(ability)
		a.misses = a.misses + 1
		meter.totalMisses = meter.totalMisses + 1
		return
	end
end

local function MeterParsePetMelee(msg)
	if not meter.recording or not msg then return end

	local dmg = nil

	-- hit: "<Name> hits <target> for <N>."
	_, _, dmg = strfind(msg, " hits .+ for (%d+)")
	if dmg then
		dmg = tonumber(dmg) or 0
		local a = MeterGetAbility("Melee")
		a.hits = a.hits + 1
		a.dmg = a.dmg + dmg
		meter.totalHits = meter.totalHits + 1
		meter.totalDmg = meter.totalDmg + dmg
		return
	end

	-- crit: "<Name> crits <target> for <N>."
	_, _, dmg = strfind(msg, " crits .+ for (%d+)")
	if dmg then
		dmg = tonumber(dmg) or 0
		local a = MeterGetAbility("Melee")
		a.crits = a.crits + 1
		a.dmg = a.dmg + dmg
		meter.totalCrits = meter.totalCrits + 1
		meter.totalDmg = meter.totalDmg + dmg
		return
	end

	-- miss: "<Name> misses <target>."
	if strfind(msg, " misses ") then
		local a = MeterGetAbility("Melee")
		a.misses = a.misses + 1
		meter.totalMisses = meter.totalMisses + 1
		return
	end
end

MeterPrintSummary = function()
	if not MTH or not MTH.Print then return end
	local elapsed = GetTime() - meter.startTime
	if elapsed < 1 then elapsed = 1 end
	local dps = meter.totalDmg / elapsed
	local smartLabel = GetCfg().smartFocus and "ON" or "OFF"
	local totalSwings = meter.totalHits + meter.totalCrits + meter.totalMisses

	MTH:Print(string.format(
		"[SP Meter] Pet=%s  SmartFocus=%s  Duration=%.1fs  TotalDmg=%d  DPS=%.1f  Swings=%d (H:%d C:%d M:%d)",
		meter.petName, smartLabel, elapsed, meter.totalDmg, dps, totalSwings,
		meter.totalHits, meter.totalCrits, meter.totalMisses), "debug")

	MTH:Print("[SP Meter] Autocasts: " .. meter.autocastSnapshot, "debug")

	-- Per-ability breakdown, sorted by damage
	local sorted = {}
	local sortN = 0
	for name, data in pairs(meter.abilities) do
		sortN = sortN + 1
		sorted[sortN] = { name = name, dmg = data.dmg, hits = data.hits, crits = data.crits, misses = data.misses }
	end
	table.sort(sorted, function(a, b) return a.dmg > b.dmg end)
	for i = 1, sortN do
		local e = sorted[i]
		local uses = e.hits + e.crits + e.misses
		local pct = (meter.totalDmg > 0) and (100 * e.dmg / meter.totalDmg) or 0
		MTH:Print(string.format(
			"  %s: %d dmg (%.0f%%)  %d uses (H:%d C:%d M:%d)",
			e.name, e.dmg, pct, uses, e.hits, e.crits, e.misses), "debug")
	end
end

-- ── Combat lifecycle ─────────────────────────────────────────
local function OnCombatStart()
	if not IsEnabled() then return end
	ScanPetActionBar()
	rt.inCombat = true
	rt.theButtonRecall = false
	rt.autoCowered = false
	rt.lastWarnTime = 0
	rt.lastWarnPct = (100 * (UnitHealth("pet") or 0)) / math.max(UnitHealthMax("pet") or 1, 1)

	-- Reset meter on new fight (only for untimed meters; timed meters keep recording across fights)
	if meter.active and meter.duration == 0 then
		MeterReset()
	end

	-- Record pre-combat autocast states for all managed DPS abilities
	rt.preCombatAutocast = {}
	for key, info in pairs(ABILITY_INFO) do
		if MANAGED_DPS_TYPES[info.type] and rt.slot[key] and rt.slot[key] > 0 then
			rt.preCombatAutocast[key] = GetAutocast(rt.slot[key])
			if MTH and MTH.Print then
				MTH:Print("[SP] snapshot " .. key .. "=" .. (GetAutocast(rt.slot[key]) and "ON" or "OFF") .. " slot=" .. rt.slot[key] .. " cost=" .. ABILITY_INFO[key].cost, "debug")
			end
		end
	end

	-- Smart Focus initial state: keep only the most expensive ability enabled
	local cfg = GetCfg()
	if cfg.smartFocus then
		local managed = {}
		local managedN = 0
		for key, wasOn in pairs(rt.preCombatAutocast) do
			if wasOn and ABILITY_INFO[key] then
				managedN = managedN + 1
				managed[managedN] = { key = key, cost = ABILITY_INFO[key].cost, slot = rt.slot[key] }
			end
		end
		if MTH and MTH.Print then
			MTH:Print("[SP] combatStart smartFocus=ON managedON=" .. managedN, "debug")
		end
		if managedN >= 2 then
			table.sort(managed, function(a, b) return a.cost > b.cost end)
			for i = 1, managedN do
				local state = (i == 1) and "ON" or "OFF"
				if MTH and MTH.Print then
					MTH:Print("[SP] init " .. managed[i].key .. "=" .. state .. " (cost=" .. managed[i].cost .. ")", "debug")
				end
				SetAutocast(managed[i].slot, i == 1)
			end
		end
	else
		if MTH and MTH.Print then
			MTH:Print("[SP] combatStart smartFocus=OFF", "debug")
		end
	end
end

local function OnCombatEnd()
	-- Print meter summary on combat end (only for untimed meters)
	if meter.active and meter.duration == 0 and meter.totalDmg > 0 then
		MeterPrintSummary()
	end

	-- Restore all managed DPS autocasts to pre-combat state
	if rt.preCombatAutocast then
		for key, wasOn in pairs(rt.preCombatAutocast) do
			if rt.slot[key] and rt.slot[key] > 0 then
				SetAutocast(rt.slot[key], wasOn)
				if MTH and MTH.Print then
					MTH:Print("[SP] restore " .. key .. "=" .. (wasOn and "ON" or "OFF"), "debug")
				end
			end
		end
	end

	if rt.inPVP then EndPVP() end

	rt.inCombat = false
	rt.autoCowered = false
	rt.theButtonRecall = false

	-- Re-apply taunt mode (restores growl/cower to config state)
	ApplyTauntMode()
end

-- ── PetAttack wrapper (used by The Button and hook) ──────────
local MTH_SP_OriginalPetAttack = nil

local function SmartPetAttack()
	if not IsEnabled() then
		if MTH_SP_OriginalPetAttack then MTH_SP_OriginalPetAttack() end
		return
	end

	local cfg = GetCfg()

	-- CC-Break check
	if cfg.ccBreakCheck and UnitExists("target") then
		if TargetHasBreakableCC() then
			if cfg.ccBreakMode == "block" then
				if UIErrorsFrame then
					UIErrorsFrame:AddMessage("Breakable debuff found — pet attack blocked", 1.0, 0.3, 0.0, 1.0, UIERRORS_HOLD_TIME)
				end
				return
			else
				if UIErrorsFrame then
					UIErrorsFrame:AddMessage("Warning: target has breakable CC", 1.0, 1.0, 0.0, 1.0, UIERRORS_HOLD_TIME)
				end
			end
		end
	end

	-- PVP check
	if UnitExists("target") and UnitIsPlayer("target") and UnitCanAttack("player", "target") then
		StartPVP()
	end

	-- Dash/Dive on attack
	CastChargeAbility()

	-- Issue the actual PetAttack
	if MTH_SP_OriginalPetAttack then MTH_SP_OriginalPetAttack() end
end

-- ── The Button ───────────────────────────────────────────────
-- Global function called from Bindings.xml
function MTH_SmartPet_TheButton()
	if not IsEnabled() then return end
	local cfg = GetCfg()
	if not cfg.theButton then return end

	-- NoChase recall pending
	if rt.theButtonRecall then
		PetFollow()
		rt.theButtonRecall = false
		return
	end

	-- No pet alive
	if not UnitExists("pet") or UnitIsDead("pet") then return end

	-- No target or dead target → recall
	if not UnitExists("target") or UnitIsDead("target") then
		PetFollow()
		return
	end

	-- Friendly target → assist (attack their target)
	if UnitIsPlayer("target") and UnitCanCooperate("player", "target") then
		if UnitExists("targettarget") and not UnitIsDead("targettarget")
			and UnitCanAttack("player", "targettarget") then
			AssistUnit("target")
			SmartPetAttack()
		end
		return
	end

	-- Enemy target → attack
	if UnitCanAttack("player", "target") and not UnitIsDead("target") then
		SmartPetAttack()
		return
	end

	-- Fallback: recall
	PetFollow()
end

-- ── Taunt toggle (keybind) ───────────────────────────────────
function MTH_SmartPet_TauntToggle()
	if not IsEnabled() then return end
	local growlOn = GetAutocast(rt.slot.growl)
	local cowerOn = GetAutocast(rt.slot.cower)

	if growlOn then
		-- Switch to cower
		SetAutocast(rt.slot.growl, false)
		if rt.slot.cower > 0 then SetAutocast(rt.slot.cower, true) end
	elseif cowerOn then
		-- Switch to growl
		SetAutocast(rt.slot.cower, false)
		if rt.slot.growl > 0 then SetAutocast(rt.slot.growl, true) end
	else
		-- Neither on: enable growl
		if rt.slot.growl > 0 then SetAutocast(rt.slot.growl, true) end
	end
end

-- ── Event frame ──────────────────────────────────────────────
local frame = CreateFrame("Frame", "MTH_SmartPetFrame")
frame:Hide()

-- Meter auto-stop ticker (runs only while meter is active with a duration)
local meterTickFrame = CreateFrame("Frame")
meterTickFrame:Hide()
meterTickFrame:SetScript("OnUpdate", function()
	if not meter.active or not meter.recording then
		meterTickFrame:Hide()
		return
	end
	if meter.duration > 0 and (GetTime() - meter.startTime) >= meter.duration then
		MeterStop()
		meterTickFrame:Hide()
	end
end)

frame:RegisterEvent("VARIABLES_LOADED")
frame:RegisterEvent("PET_BAR_UPDATE")
frame:RegisterEvent("PET_UI_UPDATE")
frame:RegisterEvent("PET_ATTACK_START")
frame:RegisterEvent("PET_ATTACK_STOP")
frame:RegisterEvent("PLAYER_DEAD")
frame:RegisterEvent("UNIT_HEALTH")
frame:RegisterEvent("UNIT_FOCUS")
frame:RegisterEvent("PARTY_MEMBERS_CHANGED")
frame:RegisterEvent("RAID_ROSTER_UPDATE")
frame:RegisterEvent("CHAT_MSG_MONSTER_EMOTE")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("CHAT_MSG_SPELL_PET_DAMAGE")
frame:RegisterEvent("CHAT_MSG_COMBAT_PET_HITS")
frame:RegisterEvent("CHAT_MSG_COMBAT_PET_MISSES")

frame:SetScript("OnEvent", function()
	-- Meter events bypass the module-enabled check
	if event == "CHAT_MSG_SPELL_PET_DAMAGE" then
		if meter.recording then
			MTH:Print("[SP Meter] " .. event .. ": " .. (arg1 or "nil"), "debug")
			MeterParseCombatMsg(arg1)
		end
		return
	end
	if event == "CHAT_MSG_COMBAT_PET_HITS" or event == "CHAT_MSG_COMBAT_PET_MISSES" then
		if meter.recording then
			MTH:Print("[SP Meter] " .. event .. ": " .. (arg1 or "nil"), "debug")
			MeterParsePetMelee(arg1)
		end
		return
	end

	if not IsEnabled() then
		-- Even with module off, handle meter start/stop (untimed only)
		if meter.active and meter.duration == 0 then
			if event == "PET_ATTACK_START" then
				MeterReset()
			elseif event == "PET_ATTACK_STOP" or event == "PLAYER_DEAD" then
				if meter.totalDmg > 0 then MeterPrintSummary() end
			end
		end
		return
	end

	if event == "VARIABLES_LOADED" or event == "PLAYER_ENTERING_WORLD" then
		ResolveLocaleStrings()
		ScanPetActionBar()
		ScanPetSpellbook()
		ScanPartyForTank()
		-- Hook PetAttack once
		if not MTH_SP_OriginalPetAttack and type(PetAttack) == "function" then
			MTH_SP_OriginalPetAttack = PetAttack
			PetAttack = SmartPetAttack
		end
		ApplyTauntMode()
		return
	end

	if event == "PET_BAR_UPDATE" or event == "PET_UI_UPDATE" then
		ScanPetActionBar()
		ScanPetSpellbook()
		return
	end

	if event == "PET_ATTACK_START" then
		OnCombatStart()
		return
	end

	if event == "PET_ATTACK_STOP" or event == "PLAYER_DEAD" then
		OnCombatEnd()
		return
	end

	if event == "UNIT_FOCUS" and arg1 == "pet" then
		HandleFocusEvent()
		return
	end

	if event == "UNIT_HEALTH" and arg1 == "pet" then
		HandlePetHealth()
		return
	end

	if event == "PARTY_MEMBERS_CHANGED" or event == "RAID_ROSTER_UPDATE" then
		ScanPartyForTank()
		if not rt.inCombat then
			ApplyTauntMode()
		end
		return
	end

	if event == "CHAT_MSG_MONSTER_EMOTE" then
		HandleMonsterEmote(arg1, arg2)
		return
	end
end)

-- ── Public API (for options panel and external access) ────────
MTH_SmartPet = {
	GetConfig = GetCfg,

	SetTauntMode = function(mode)
		local cfg = GetCfg()
		if mode == "auto" or mode == "growl" or mode == "cower" or mode == "off" then
			cfg.tauntMode = mode
			if not rt.inCombat then ApplyTauntMode() end
		end
	end,

	SetPvpDetaunt = function(v) GetCfg().pvpDetaunt = v and true or false end,

	SetCcBreakCheck = function(v) GetCfg().ccBreakCheck = v and true or false end,
	SetCcBreakMode  = function(mode)
		if mode == "block" or mode == "warn" then
			GetCfg().ccBreakMode = mode
		end
	end,

	SetTheButton    = function(v) GetCfg().theButton = v and true or false end,
	SetSmartFocus   = function(v) GetCfg().smartFocus = v and true or false end,

	SetAutoCower    = function(v) GetCfg().autoCower = v and true or false end,
	SetAutoCowerPct = function(v)
		v = tonumber(v)
		if v and v >= 1 and v <= 99 then GetCfg().autoCowerPct = v end
	end,

	SetNoChase      = function(v) GetCfg().noChase = v and true or false end,
	SetRushOnAttack = function(v) GetCfg().rushOnAttack = v and true or false end,

	SetAutoWarn     = function(v) GetCfg().autoWarn = v and true or false end,
	SetAutoWarnPct  = function(v)
		v = tonumber(v)
		if v and v >= 1 and v <= 99 then GetCfg().autoWarnPct = v end
	end,
	SetAutoWarnChannel = function(chan)
		chan = string.upper(tostring(chan or "SAY"))
		if chan == "SAY" or chan == "PARTY" or chan == "RAID" or chan == "GUILD" then
			GetCfg().autoWarnChannel = chan
		end
	end,

	-- Force a rescan (useful after pet swap)
	Rescan = function()
		ScanPetActionBar()
		ScanPetSpellbook()
		ScanPartyForTank()
		if not rt.inCombat then ApplyTauntMode() end
	end,

	-- Damage meter (duration=0 for unlimited, >0 for timed auto-stop)
	StartMeter = function(duration)
		meter.active = true
		meter.duration = duration or 0
		MeterReset()
		if duration and duration > 0 then
			meterTickFrame:Show()
			MTH:Print(string.format("|cffff9900[SP Meter]|r ON — recording for %ds.", duration))
		else
			MTH:Print("|cffff9900[SP Meter]|r ON — /sp meter to stop.")
		end
	end,

	StopMeter = function()
		if meter.active then
			MeterStop()
			meterTickFrame:Hide()
		else
			MTH:Print("|cffff9900[SP Meter]|r Not running.")
		end
	end,

	-- Reprint last summary
	PrintMeter = function()
		if meter.totalDmg > 0 then
			MeterPrintSummary()
		else
			MTH:Print("|cffff9900[SP Meter]|r No data recorded.")
		end
	end,
}

-- ── Register with MTH framework so IsModuleEnabled works ─────
local MTH_SmartPetModule = {
	name    = "smartpet",
	enabled = false,
	events  = {},
}

function MTH_SmartPetModule:init()
	self.initialized = true
end

function MTH_SmartPetModule:setEnabled(enabled)
	-- No-op: SmartPet checks IsEnabled() on every event
end

if MTH and MTH.RegisterModule then
	MTH:RegisterModule("smartpet", MTH_SmartPetModule)
end

-- ── Slash command ────────────────────────────────────────────
SLASH_MTHSmartPet1 = "/sp"
SlashCmdList["MTHSmartPet"] = function(msg)
	msg = string.lower(msg or "")
	if msg == "meter" then
		if meter.active then
			MTH_SmartPet.StopMeter()
		else
			MTH_SmartPet.StartMeter(0)
		end
	elseif msg == "meter print" then
		MTH_SmartPet.PrintMeter()
	else
		-- "/sp meter 60" — timed start
		local _, _, secs = strfind(msg, "^meter (%d+)$")
		if secs then
			MTH_SmartPet.StartMeter(tonumber(secs))
		else
			MTH:Print("|cffff9900[SmartPet]|r /sp meter — toggle damage meter")
			MTH:Print("|cffff9900[SmartPet]|r /sp meter 60 — record for 60s then stop")
			MTH:Print("|cffff9900[SmartPet]|r /sp meter print — reprint last fight")
		end
	end
end
