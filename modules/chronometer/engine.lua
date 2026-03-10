local Chronometer = AceLibrary("AceAddon-2.0"):new("AceEvent-2.0", "AceHook-2.1", "CandyBar-2.0")
local BS = {
	GetSpellIcon = function(self, spellName)
		local cacheOwner = type(self) == "table" and self or {}
		local name = tostring(spellName or "")
		if name == "" then
			return "Interface\\Icons\\INV_Misc_QuestionMark"
		end

		local iconCache = rawget(cacheOwner, "_iconCache")
		if type(iconCache) ~= "table" then
			iconCache = {}
			rawset(cacheOwner, "_iconCache", iconCache)
		end
		if iconCache[name] then
			return iconCache[name]
		end

		if type(GetSpellName) == "function" and type(GetSpellTexture) == "function" then
			local spellBookType = BOOKTYPE_SPELL or "spell"
			local i = 1
			while true do
				local okName, n = pcall(GetSpellName, i, spellBookType)
				if not okName or not n then
					break
				end
				if n == name then
					local okTex, tex = pcall(GetSpellTexture, i, spellBookType)
					if okTex and tex then
						iconCache[name] = tex
						return tex
					end
					break
				end
				i = i + 1
			end
		end

		iconCache[name] = "Interface\\Icons\\INV_Misc_QuestionMark"
		return "Interface\\Icons\\INV_Misc_QuestionMark"
	end,
}
BS = setmetatable(BS, {
	__index = function(_, key)
		if MTH and MTH.LocalizeSpell then
			return MTH:LocalizeSpell(key)
		end
		return key
	end,
})

MTH_ChronometerHunter = Chronometer

Chronometer.SPELL = 1
Chronometer.EVENT = 2
Chronometer.rightclick = false
Chronometer.dataSetup = {}

local latins = { I = 1, II = 2, III = 3, IV = 4, V = 5, VI = 6, VII = 7, VIII = 8, IX = 9, X = 10, XI = 11, XII = 12, XIII = 13, XIV = 14 }
local BAR_GROUP = "MTHChronometer"
local PARSER_OWNER = "MTHChronometerHunter"
local MTH_CHRON_TRACE_ENABLED = false

local function MTH_CHRON_Trace(msg)
	if not MTH_CHRON_TRACE_ENABLED then
		return
	end
	if MTH and MTH.Print then
		MTH:Print("[CHRONTRACE] " .. tostring(msg), "debug")
	elseif DEFAULT_CHAT_FRAME and DEFAULT_CHAT_FRAME.AddMessage then
		DEFAULT_CHAT_FRAME:AddMessage("[CHRONTRACE] " .. tostring(msg))
	end
end

local function MTH_CHRON_FormatBarPosition(profile)
	local bp = profile and profile.barposition
	if type(bp) ~= "table" then
		return "<none>"
	end
	return tostring(bp.point or "nil")
		.. "/" .. tostring(bp.relativePoint or "nil")
		.. " @(" .. tostring(bp.x) .. "," .. tostring(bp.y) .. ")"
end

local function MTH_CHRON_DescribePoint(frame)
	if not (frame and frame.GetPoint) then
		return "<no-frame>"
	end
	local point, relTo, relPoint, x, y = frame:GetPoint()
	local relName = "nil"
	if type(relTo) == "table" and relTo.GetName then
		relName = tostring(relTo:GetName() or "<anon>")
	elseif relTo then
		relName = tostring(relTo)
	end
	return tostring(point or "nil")
		.. "->" .. relName
		.. ":" .. tostring(relPoint or "nil")
		.. " @(" .. tostring(x) .. "," .. tostring(y) .. ")"
end

local COLOR_NAME_MAP = {
	white = { 1.0, 1.0, 1.0 },
	black = { 0.0, 0.0, 0.0 },
	blue = { 0.0, 0.0, 1.0 },
	magenta = { 1.0, 0.0, 1.0 },
	cyan = { 0.0, 1.0, 1.0 },
	green = { 0.0, 1.0, 0.0 },
	yellow = { 1.0, 1.0, 0.0 },
	orange = { 1.0, 0.5, 0.0 },
	red = { 1.0, 0.0, 0.0 },
	gray = { 0.5, 0.5, 0.5 },
	forest = { 0.0, 0.5, 0.0 },
	maroon = { 0.5, 0.0, 0.0 },
	navy = { 0.0, 0.0, 0.5 },
	olive = { 0.5, 0.5, 0.0 },
	purple = { 0.5, 0.0, 0.5 },
	teal = { 0.0, 0.5, 0.5 },
}

local DEFAULTS = {
	growup = false,
	reverse = false,
	fadeonkill = true,
	fadeonfade = true,
	barposition = {},
	ghost = 0,
	selfbars = true,
	barwidth = 220,
	barheight = 16,
	spacing = 0,
	barscale = 1,
	iconposition = "LEFT",
	textsize = 10,
	textcolor = "white",
	bgcolor = "teal",
	barcolor = "gray",
	bordercolor = "black",
	bordertex = "None",
	bgalpha = 0.5,
	text = "$t",
	onlyself = false,
	disabledSpells = {
		COMMON = {
			["Ephemeral Power"] = {},
			["Mind Quickening"] = {},
			["Unstable Power"] = {},
		},
		RACIAL = {},
		HUNTER = {},
	},
}

local function seedDefaultCommonDisabled(commonBucket)
	if type(commonBucket) ~= "table" then
		return
	end
	local names = {
		"Ephemeral Power",
		"Mind Quickening",
		"Unstable Power",
	}
	for i = 1, table.getn(names) do
		local baseName = names[i]
		if commonBucket[baseName] == nil then
			commonBucket[baseName] = {}
		end
		if MTH and MTH.LocalizeSpell then
			local localized = MTH:LocalizeSpell(baseName)
			if localized and localized ~= "" and commonBucket[localized] == nil then
				commonBucket[localized] = {}
			end
		end
	end
end

local function shallowCopy(source)
	local dest = {}
	for key, value in pairs(source) do
		dest[key] = value
	end
	return dest
end

local function deepCopyValue(value)
	if type(value) ~= "table" then
		return value
	end
	local copy = {}
	for key, entry in pairs(value) do
		copy[key] = deepCopyValue(entry)
	end
	return copy
end

local function ensureProfile()
	if not MTH or not MTH.GetModuleCharSavedVariables then
		MTH_CHRON_Trace("ensureProfile fallback defaults (no MTH store)")
		return shallowCopy(DEFAULTS)
	end

	local store = MTH:GetModuleCharSavedVariables("chronometer")
	if type(store) ~= "table" then
		MTH_CHRON_Trace("ensureProfile fallback defaults (invalid store)")
		return shallowCopy(DEFAULTS)
	end
	if type(store.profile) ~= "table"
		and type(MTH_CharSavedVariables) == "table"
		and type(MTH_CharSavedVariables.chronometer) == "table"
	then
		local legacyChar = MTH_CharSavedVariables.chronometer
		if type(legacyChar.profile) == "table" then
			store.profile = deepCopyValue(legacyChar.profile)
			MTH_CHRON_Trace("ensureProfile migrated legacy MTH_CharSavedVariables.chronometer.profile")
		elseif type(legacyChar.barposition) == "table" then
			store.profile = { barposition = deepCopyValue(legacyChar.barposition) }
			MTH_CHRON_Trace("ensureProfile migrated legacy MTH_CharSavedVariables.chronometer.barposition")
		end
	end
	if type(store.profile) ~= "table"
		and type(MTH_SavedVariables) == "table"
		and type(MTH_SavedVariables.chronometer) == "table"
	then
		local legacyAccount = MTH_SavedVariables.chronometer
		if type(legacyAccount.profile) == "table" then
			store.profile = deepCopyValue(legacyAccount.profile)
			MTH_CHRON_Trace("ensureProfile migrated legacy MTH_SavedVariables.chronometer.profile")
		elseif type(legacyAccount.barposition) == "table" then
			store.profile = { barposition = deepCopyValue(legacyAccount.barposition) }
			MTH_CHRON_Trace("ensureProfile migrated legacy MTH_SavedVariables.chronometer.barposition")
		end
	end
	if type(store.profile) ~= "table" and MTH.GetModuleSavedVariables then
		local accountStore = MTH:GetModuleSavedVariables("chronometer")
		if type(accountStore) == "table" and type(accountStore.profile) == "table" then
			store.profile = deepCopyValue(accountStore.profile)
			MTH_CHRON_Trace("ensureProfile copied account profile into char store")
		end
	end
	if type(store.profile) ~= "table" then
		store.profile = {}
	end
	if type(store.profile.barposition) ~= "table" and type(store.barposition) == "table" then
		store.profile.barposition = deepCopyValue(store.barposition)
		MTH_CHRON_Trace("ensureProfile migrated legacy char barposition -> profile.barposition")
	end
	if type(store.profile.barposition) ~= "table" and MTH.GetModuleSavedVariables then
		local accountStore = MTH:GetModuleSavedVariables("chronometer")
		if type(accountStore) == "table" then
			if type(accountStore.barposition) == "table" then
				store.profile.barposition = deepCopyValue(accountStore.barposition)
				MTH_CHRON_Trace("ensureProfile migrated legacy account barposition -> profile.barposition")
			elseif type(accountStore.profile) == "table" and type(accountStore.profile.barposition) == "table" then
				store.profile.barposition = deepCopyValue(accountStore.profile.barposition)
				MTH_CHRON_Trace("ensureProfile copied account profile.barposition -> char profile.barposition")
			end
		end
	end
	local profile = store.profile

	for key, value in pairs(DEFAULTS) do
		if profile[key] == nil then
			if type(value) == "table" then
				profile[key] = shallowCopy(value)
			else
				profile[key] = value
			end
		end
	end

	if type(profile.disabledSpells) ~= "table" then
		profile.disabledSpells = {}
	end
	if type(profile.disabledSpells.COMMON) ~= "table" then
		profile.disabledSpells.COMMON = {}
	end
	seedDefaultCommonDisabled(profile.disabledSpells.COMMON)
	if type(profile.disabledSpells.RACIAL) ~= "table" then
		profile.disabledSpells.RACIAL = {}
	end
	if type(profile.disabledSpells.HUNTER) ~= "table" then
		profile.disabledSpells.HUNTER = {}
	end

	MTH_CHRON_Trace("ensureProfile result barposition=" .. MTH_CHRON_FormatBarPosition(profile))

	return profile
end

local function MTH_CHRON_PersistAnchorPosition(self, reason)
	if not (self and self.anchor and self.anchor.GetPoint) then
		return false
	end
	if type(self.profile) ~= "table" then
		return false
	end
	if type(self.profile.barposition) ~= "table" then
		self.profile.barposition = {}
	end
	local point, _, relPoint, x, y = self.anchor:GetPoint()
	x = tonumber(x)
	y = tonumber(y)
	if not (point and relPoint and x and y) then
		return false
	end
	x = math.floor(x + 0.5)
	y = math.floor(y + 0.5)
	self.profile.barposition.point = point
	self.profile.barposition.relativePoint = relPoint
	self.profile.barposition.x = x
	self.profile.barposition.y = y
	MTH_CHRON_Trace("persist-anchor reason=" .. tostring(reason or "")
		.. " profile=" .. MTH_CHRON_FormatBarPosition(self.profile))
	return true
end

local function MTH_CHRON_RestoreAnchorFromProfile(self, reason)
	if not (self and self.anchor and self.anchor.ClearAllPoints and self.anchor.SetPoint) then
		return false
	end
	if type(self.profile) ~= "table" then
		return false
	end
	local bp = self.profile.barposition
	if type(bp) ~= "table" then
		return false
	end
	local px = tonumber(bp.x)
	local py = tonumber(bp.y)
	local ppoint = tostring(bp.point or "")
	local prelpoint = tostring(bp.relativePoint or "")
	if not (px and py and ppoint ~= "") then
		MTH_CHRON_Trace("restore-anchor skipped reason=" .. tostring(reason or "")
			.. " profile=" .. MTH_CHRON_FormatBarPosition(self.profile))
		return false
	end
	if prelpoint == "" then
		prelpoint = ppoint
	end
	self.anchor:ClearAllPoints()
	self.anchor:SetPoint(ppoint, UIParent, prelpoint, px, py)
	MTH_CHRON_Trace("restore-anchor applied reason=" .. tostring(reason or "")
		.. " frame=" .. MTH_CHRON_DescribePoint(self.anchor))
	return true
end

local function MTH_CHRON_IsPersistedEnabled()
	if MTH and MTH.IsModuleEnabled then
		return MTH:IsModuleEnabled("chronometer", true) and true or false
	end

	if type(MTH_SavedVariables) == "table" then
		if type(MTH_SavedVariables.modules) == "table"
			and type(MTH_SavedVariables.modules.chronometer) == "table"
			and MTH_SavedVariables.modules.chronometer.enabled ~= nil
		then
			return MTH_SavedVariables.modules.chronometer.enabled and true or false
		end

		if type(MTH_SavedVariables.chronometer) == "table"
			and MTH_SavedVariables.chronometer.enabled ~= nil
		then
			return MTH_SavedVariables.chronometer.enabled and true or false
		end
	end

	return true
end

local function convertcolor(color)
	if type(color) == "string" then
		local key = string.lower(color)
		local named = COLOR_NAME_MAP[key]
		if named then
			return { named[1], named[2], named[3] }
		end
		if string.len(key) == 6 then
			local rr = tonumber(string.sub(key, 1, 2), 16)
			local gg = tonumber(string.sub(key, 3, 4), 16)
			local bb = tonumber(string.sub(key, 5, 6), 16)
			if rr and gg and bb then
				return { rr / 255, gg / 255, bb / 255 }
			end
		end
		return { 1, 1, 1 }
	elseif type(color) == "table" then
		if type(color[1]) == "table" then
			color = color[1]
		end
		local r = tonumber(color[1] or color.r)
		local g = tonumber(color[2] or color.g)
		local b = tonumber(color[3] or color.b)
		if r and g and b then
			return { r, g, b }
		end
		return { 1, 1, 1 }
	else
		return { 1, 1, 1 }
	end
end

local function parseRankNumber(text)
	if not text or text == "" then
		return 0
	end
	local _, _, rankText = string.find(tostring(text), "(%d+)")
	local rank = tonumber(rankText)
	if rank then
		return rank
	end
	local _, _, roman = string.find(tostring(text), "([IVX]+)")
	if roman and latins[roman] then
		return latins[roman]
	end
	return 0
end

local function resolvePlayerClassBucket(profile)
	profile = profile or {}
	local buckets = profile.disabledSpells
	if type(buckets) ~= "table" then
		return "HUNTER"
	end

	local localizedClass, classToken = UnitClass("player")
	local candidates = {
		classToken,
		localizedClass,
		string.upper(tostring(classToken or "")),
		string.upper(tostring(localizedClass or "")),
		"HUNTER",
	}

	for i = 1, table.getn(candidates) do
		local key = tostring(candidates[i] or "")
		if key ~= "" and type(buckets[key]) == "table" then
			return key
		end
	end

	return tostring(classToken or localizedClass or "HUNTER")
end

local function normalizeTimerName(name)
	local normalized = tostring(name or "")
	normalized = string.gsub(normalized, "^%s+", "")
	normalized = string.gsub(normalized, "%s+$", "")
	normalized = string.gsub(normalized, "%s+", " ")
	normalized = string.lower(normalized)
	return normalized
end

local function isTimerDisabled(profile, timerClass, timerName)
	local disabledSpells = profile and profile.disabledSpells
	if type(disabledSpells) ~= "table" then
		return false, "no-disabled-table"
	end

	local classBucket = disabledSpells[timerClass]
	if type(classBucket) ~= "table" then
		return false, "no-class-bucket"
	end

	if classBucket[timerName] ~= nil then
		return true, "exact"
	end

	local wanted = normalizeTimerName(timerName)
	if wanted == "" then
		return false, "empty-name"
	end

	for key, value in pairs(classBucket) do
		if value ~= nil and normalizeTimerName(key) == wanted then
			return true, "normalized"
		end
	end

	return false, "miss"
end

local function getActionSpell(slot)
	if GetActionText(slot) or not HasAction(slot) then
		return nil, 0
	end

	if not Chronometer._scanTooltip then
		local tip = CreateFrame("GameTooltip", "MTH_ChrBarProbe", UIParent)
		tip:SetOwner(UIParent, "ANCHOR_NONE")
		for i = 1, 4 do
			local L = tip:CreateFontString("MTH_ChrBarProbeTextLeft"..i, "ARTWORK", "GameTooltipText")
			local R = tip:CreateFontString("MTH_ChrBarProbeTextRight"..i, "ARTWORK", "GameTooltipText")
			tip:AddFontStrings(L, R)
		end
		Chronometer._scanTooltip = tip
	end

	local tooltip = Chronometer._scanTooltip
	tooltip:ClearLines()
	tooltip:SetAction(slot)

	local left1 = getglobal("MTH_ChrBarProbeTextLeft1")
	local left2 = getglobal("MTH_ChrBarProbeTextLeft2")
	local spellName = left1 and left1:GetText() or nil
	if not spellName or spellName == "" then
		return nil, 0
	end

	local rankText = left2 and left2:GetText() or ""
	return spellName, parseRankNumber(rankText)
end

local function callGlobal(name, a1, a2, a3, a4)
	if type(name) ~= "string" or name == "" then
		return nil
	end
	local fn = getglobal(name)
	if type(fn) == "function" then
		return fn(a1, a2, a3, a4)
	end
	return nil
end

function Chronometer:MTH_Initialize()
	if self._mth_initialized then
		return
	end

	self.profile = ensureProfile()
	MTH_CHRON_Trace("MTH_Initialize profile=" .. MTH_CHRON_FormatBarPosition(self.profile))
	self.parser = ParserLib:GetInstance("1.1")

	self.COLOR_MAP = {
		[0] = "olive",
		[1] = "teal",
		[2] = "purple",
		[3] = "forest",
	}

	self.anchor = self:CreateAnchor("MetaHunt Chronometer", 0, 1, 0)
	MTH_CHRON_Trace("MTH_Initialize anchor-created point=" .. MTH_CHRON_DescribePoint(self.anchor))
	self:RegisterCandyBarGroup(BAR_GROUP)
	self:SetCandyBarGroupPoint(BAR_GROUP, "TOP", self.anchor, "BOTTOM", 0, 0)

	self._mth_initialized = true
end

function Chronometer:MTH_Enable()
	self._mth_explicitEnable = true
	MTH_CHRON_Trace("MTH_Enable called")
	self:MTH_Initialize()
	self:OnEnable()
	self._mth_explicitEnable = nil
end

function Chronometer:MTH_Disable()
	MTH_CHRON_Trace("MTH_Disable called")
	self:OnDisable()
end

function Chronometer:OnEnable()
	MTH_CHRON_Trace("OnEnable begin enabled=" .. tostring(self._mth_enabled and true or false))
	if self._mth_enabled then
		return
	end

	if (not self._mth_explicitEnable) and (not MTH_CHRON_IsPersistedEnabled()) then
		if self.parser then
			self.parser:UnregisterAllEvents(PARSER_OWNER)
		end
		self:UnregisterAllEvents()
		if self.CancelAllScheduledEvents then
			self:CancelAllScheduledEvents()
		end
		self:UnhookAll()
		if self.anchor then
			self.anchor:Hide()
		end
		self.bars = nil
		self.timers = nil
		self.groups = nil
		self.captive = nil
		self.active = nil
		self._mth_enabled = false
		return
	end

	self:MTH_Initialize()
	self._mth_enabled = true

	self.profile = ensureProfile()
	MTH_CHRON_Trace("OnEnable profile-after-ensure=" .. MTH_CHRON_FormatBarPosition(self.profile))
	self:SetCandyBarGroupGrowth(BAR_GROUP, self.profile.growup and true or false)
	self:SetCandyBarGroupVerticalSpacing(BAR_GROUP, self.profile.spacing or 0)
	if self.anchor then
		MTH_CHRON_Trace("OnEnable anchor-current-point=" .. MTH_CHRON_DescribePoint(self.anchor))
	end
	MTH_CHRON_RestoreAnchorFromProfile(self, "OnEnable")

	self.groups = {}
	self.timers = {}
	self.bars = {}
	for i = 1, 20 do
		self.bars[i] = {}
	end

	for _, setupFunc in pairs(self.dataSetup) do
		setupFunc(self)
	end

	self.parser:RegisterEvent(PARSER_OWNER, "CHAT_MSG_COMBAT_FRIENDLY_DEATH", function(event, info) self:COMBAT_DEATH(event, info) end)
	self.parser:RegisterEvent(PARSER_OWNER, "CHAT_MSG_COMBAT_HOSTILE_DEATH", function(event, info) self:COMBAT_DEATH(event, info) end)
	self.parser:RegisterEvent(PARSER_OWNER, "CHAT_MSG_COMBAT_XP_GAIN", function(event, info) self:COMBAT_DEATH(event, info) end)

	self.parser:RegisterEvent(PARSER_OWNER, "CHAT_MSG_SPELL_AURA_GONE_SELF", function(event, info) self:SPELL_FADE(event, info) end)
	self.parser:RegisterEvent(PARSER_OWNER, "CHAT_MSG_SPELL_AURA_GONE_OTHER", function(event, info) self:SPELL_FADE(event, info) end)

	self.parser:RegisterEvent(PARSER_OWNER, "CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE", function(event, info) self:SPELL_PERIODIC(event, info) end)
	self.parser:RegisterEvent(PARSER_OWNER, "CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS", function(event, info) self:SPELL_PERIODIC(event, info) end)
	self.parser:RegisterEvent(PARSER_OWNER, "CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_BUFFS", function(event, info) self:SPELL_PERIODIC(event, info) end)
	self.parser:RegisterEvent(PARSER_OWNER, "CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE", function(event, info) self:SPELL_PERIODIC(event, info) end)
	self.parser:RegisterEvent(PARSER_OWNER, "CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS", function(event, info) self:SPELL_PERIODIC(event, info) end)
	self.parser:RegisterEvent(PARSER_OWNER, "CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", function(event, info) self:SPELL_PERIODIC(event, info) end)
	self.parser:RegisterEvent(PARSER_OWNER, "CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_BUFFS", function(event, info) self:SPELL_PERIODIC(event, info) end)
	self.parser:RegisterEvent(PARSER_OWNER, "CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", function(event, info) self:SPELL_PERIODIC(event, info) end)

	local enableRoM = false
	for _, timer in pairs(self.timers[self.SPELL] or {}) do
		if timer.x.rom or timer.x.romc then
			enableRoM = true
			break
		end
	end
	if not enableRoM then
		for _, timer in pairs(self.timers[self.EVENT] or {}) do
			if timer.x.rom or timer.x.romc then
				enableRoM = true
				break
			end
		end
	end
	if enableRoM then
		self.parser:RegisterEvent(PARSER_OWNER, "CHAT_MSG_COMBAT_SELF_HITS", function(event, info) self:SELF_HITS(event, info) end)
		self.parser:RegisterEvent(PARSER_OWNER, "CHAT_MSG_COMBAT_SELF_CRITS", function(event, info) self:SELF_CRITS(event, info) end)
	end

	self.captive = {}
	self.active = {}
	if type(getglobal("UseAction")) == "function" then
		self:Hook("UseAction")
	end
	if type(getglobal("CastSpell")) == "function" then
		self:Hook("CastSpell")
	end
	if type(getglobal("CastSpellByName")) == "function" then
		self:Hook("CastSpellByName")
	end
	if type(getglobal("SpellTargetUnit")) == "function" then
		self:Hook("SpellTargetUnit")
	end
	if type(getglobal("TargetUnit")) == "function" then
		self:Hook("TargetUnit")
	end
	if type(getglobal("SpellStopTargeting")) == "function" then
		self:Hook("SpellStopTargeting")
	end
	if type(getglobal("SpellStopCasting")) == "function" then
		self:Hook("SpellStopCasting")
	end
	if WorldFrame then
		self:HookScript(WorldFrame, "OnMouseDown")
	end
	self:RegisterEvent("SPELLCAST_INTERRUPTED")
	self:RegisterEvent("SPELLCAST_START")
	self:RegisterEvent("SPELLCAST_STOP")
	self:RegisterEvent("UNIT_AURA")
	self:RegisterEvent("PLAYER_DEAD")
	self:RegisterEvent("VARIABLES_LOADED")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("PLAYER_LOGOUT")
	self.parser:RegisterEvent(PARSER_OWNER, "CHAT_MSG_SPELL_SELF_DAMAGE", function(event, info) self:SELF_DAMAGE(event, info) end)
	self.parser:RegisterEvent(PARSER_OWNER, "CHAT_MSG_SPELL_DAMAGESHIELDS_ON_SELF", function(event, info) self:SELF_DAMAGE(event, info) end)
	self.parser:RegisterEvent(PARSER_OWNER, "CHAT_MSG_SPELL_FAILED_LOCALPLAYER", function(event, info) self:SPELL_FAILED(event, info) end)
end

function Chronometer:VARIABLES_LOADED()
	self.profile = ensureProfile()
	MTH_CHRON_RestoreAnchorFromProfile(self, "VARIABLES_LOADED")
end

function Chronometer:PLAYER_ENTERING_WORLD()
	self.profile = ensureProfile()
	MTH_CHRON_RestoreAnchorFromProfile(self, "PLAYER_ENTERING_WORLD")
end

function Chronometer:PLAYER_LOGOUT()
	MTH_CHRON_PersistAnchorPosition(self, "PLAYER_LOGOUT")
end

function Chronometer:OnDisable()
	if not self._mth_enabled then
		return
	end
	MTH_CHRON_Trace("OnDisable begin profile=" .. MTH_CHRON_FormatBarPosition(self.profile))
	if self.anchor then
		MTH_CHRON_Trace("OnDisable anchor-point=" .. MTH_CHRON_DescribePoint(self.anchor))
	end
	MTH_CHRON_PersistAnchorPosition(self, "OnDisable")
	self._mth_enabled = false

	if self.bars then
		for i = 1, 20 do
			if self.bars[i].id then
				self:StopCandyBar(self.bars[i].id)
			end
		end
	end
	if self.anchor then
		self.anchor:Hide()
	end
	self.bars = nil
	self.timers = nil
	self.groups = nil
	self.captive = nil
	self.active = nil

	if self.parser then
		self.parser:UnregisterAllEvents(PARSER_OWNER)
	end
	self:UnregisterAllEvents()
	if self.CancelAllScheduledEvents then
		self:CancelAllScheduledEvents()
	end
	self:UnhookAll()
end

function Chronometer:AddGroup(id, forall, color)
	if color then
		self.groups[id] = { fa = forall, cr = color }
	else
		self.groups[id] = { fa = forall }
	end
end

function Chronometer:AddTimer(kind, name, duration, targeted, isgain, selforselect, extra)
	if not self.timers[kind] then
		self.timers[kind] = {}
	end
	if not self.timers[kind][name] then
		self.timers[kind][name] = {}
	end
	if not extra then
		extra = {}
	end
	targeted = (targeted and targeted > 0) and 1 or nil
	isgain = (isgain and isgain > 0) and 1 or nil
	selforselect = (selforselect and selforselect > 0) and 1 or nil
	if not extra.cr then
		if extra.gr and self.groups[extra.gr] and self.groups[extra.gr].cr then
			extra.cr = self.groups[extra.gr].cr
		else
			local ccode = (targeted and 2 or 0) + (isgain and 1 or 0)
			extra.cr = self.COLOR_MAP[ccode]
		end
	end
	self.timers[kind][name] = { d = duration, k = { t = targeted, g = isgain, s = selforselect }, x = extra }
end

function Chronometer:StartTimer(timer, name, target, rank, durmod)
	target = self:DisambiguateTarget(timer, target)
	local idTarget = target

	do
		local sp = (BS and BS["Scorpid Poison"]) or "Scorpid Poison"
		if name == sp and target and target ~= "none" then
			local label = tostring(target)
			local base = label
			local pHash = string.find(label, " #", 1, true)
			if pHash then
				base = string.sub(base, 1, pHash - 1)
			end
			local pRt = string.find(base, " {RT", 1, true)
			if pRt then
				base = string.sub(base, 1, pRt - 1)
			end

			local guid = self:SPGetGUIDForName(base)
			if guid then
				self._spGuidOrdinal = self._spGuidOrdinal or {}
				self._spGuidOrdinal[base] = self._spGuidOrdinal[base] or {}
				local ord = self._spGuidOrdinal[base][guid]
				if not ord then
					local used = {}
					for _, orderValue in pairs(self._spGuidOrdinal[base]) do
						if type(orderValue) == "number" then
							used[orderValue] = true
						end
					end
					local n = 1
					while used[n] do
						n = n + 1
					end
					ord = n
					self._spGuidOrdinal[base][guid] = ord
				end
				idTarget = base .. " #" .. guid
				target = base .. " #" .. ord
			end
		end
	end

	local timerClass = timer.x.cl
	if timerClass == nil then
		timerClass = resolvePlayerClassBucket(self.profile)
	end
	local blocked, reason = isTimerDisabled(self.profile, timerClass, name)
	if blocked then
		return
	end

	if not target then
		target = "none"
	end
	if not rank then
		rank = timer.r or 0
	end
	if not durmod then
		durmod = 0
	end
	if timer.x.gr then
		self:CleanGroup(timer.x.gr, target)
	end
	if timer.d == 0 then
		return
	end
	if (not self.profile.selfbars) and (target == UnitName("player") or (target == "none" and timer.k.g)) then
		return
	end
	if self.profile.onlyself and timer.k.t ~= nil and target ~= UnitName("player") then
		return
	end

	local id = name .. "-" .. idTarget
	local slot = nil
	for i = 20, 1, -1 do
		if self.bars[i].id == id then
			self:SetCandyBarFade(id, 0, false)
			self:StopCandyBar(self.bars[i].id)
			self:ReallyStopBar(self.bars[i].id)
			break
		end
	end
	for i = 1, 20 do
		if not self.bars[i].id then
			slot = i
			break
		end
	end
	if not slot then
		slot = 20
	end

	self.bars[slot].id = id
	self.bars[slot].timer = timer
	self.bars[slot].name = name
	self.bars[slot].rank = rank
	self.bars[slot].target = target
	self.bars[slot].group = timer.x.gr

	local duration = (timer.x.d and self:GetDuration(timer.d, timer.x.d, rank, timer.cp) or timer.d) + durmod
	local text = target == "none" and name or self.profile.text
	text = string.gsub(text, "$t", target)
	text = string.gsub(text, "$s", name)
	local icon = timer.x.tx or self:GetTexture(name, timer.x)
	local color = convertcolor(timer.x.cr or self.profile.barcolor)
	local fade = (timer.x.rc and self.profile.ghost) and self.profile.ghost or 0.5

	self:RegisterCandyBar(id, duration, text, icon, color[1], color[2], color[3], 1, 0, 0)
	self:RegisterCandyBarWithGroup(id, BAR_GROUP)
	if self.profile.barscale then self:SetCandyBarScale(id, self.profile.barscale) end
	if self.profile.barwidth then self:SetCandyBarWidth(id, self.profile.barwidth) end
	if self.profile.barheight then self:SetCandyBarHeight(id, self.profile.barheight) end
	if self.profile.iconposition then self:SetCandyBarIconPosition(id, self.profile.iconposition) end
	if self.profile.spacing then self:SetCandyBarGroupVerticalSpacing(BAR_GROUP, self.profile.spacing) end
	if self.profile.textsize then self:SetCandyBarFontSize(id, self.profile.textsize) end
	if self.profile.textcolor then local c = convertcolor(self.profile.textcolor); self:SetCandyBarTextColor(id, c[1], c[2], c[3]) end
	if self.profile.bgcolor then local c = convertcolor(self.profile.bgcolor); self:SetCandyBarBackgroundColor(id, c[1], c[2], c[3], self.profile.bgalpha) end
	if self.profile.bordercolor then local c = convertcolor(self.profile.bordercolor); self:SetCandyBarBorderColor(id, c[1], c[2], c[3]) end
	if self.profile.bordertex then self:SetCandyBarBorderTexture(id, self.profile.bordertex) end
	self:SetCandyBarFade(id, fade, true)
	self:SetCandyBarCompletion(id, self.StopBar, self, id)
	self:SetCandyBarReversed(id, self.profile.reverse)
	self:SetCandyBarOnClick(id, function(a1, a2, a3, a4, a5) self:CandyOnClick(a1, a2, a3, a4, a5) end, timer.x.rc, timer.x.mc)
	self:StartCandyBar(id, true)
end

function Chronometer:DisambiguateTarget(timer, t)
	if not timer or not timer.x or not timer.x.dn then
		return t
	end
	local base = tostring(t or "")
	if base == "" then
		return base
	end
	if string.find(base, " #", 1, true) or string.find(base, "{RT", 1, true) then
		return base
	end

	local unit = nil
	if UnitExists("pettarget") and UnitName("pettarget") == base then unit = "pettarget" end
	if UnitExists("target") and UnitName("target") == base and not unit then unit = "target" end

	local withIcon = nil
	if unit then
		local idx = GetRaidTargetIndex(unit)
		if idx then
			withIcon = base .. " {RT" .. idx .. "}"
		end
	end

	local function used(label)
		for i = 1, 20 do
			local bar = self.bars[i]
			if bar and bar.id and bar.target == label then
				if not timer.x.gr or (bar.timer and bar.timer.x and bar.timer.x.gr == timer.x.gr) then
					return true
				end
			end
		end
		return false
	end

	if withIcon and not used(withIcon) then return withIcon end
	if not used(base) then return base end
	for n = 2, 9 do
		local candidate = base .. " #" .. n
		if not used(candidate) then
			return candidate
		end
	end
	return base .. " #?"
end

function Chronometer:GetDuration(duration, record, rank, cp)
	if record.rt then duration = record.rt[rank] or duration end
	if record.rs then duration = duration + (rank - 1) * record.rs end
	if record.cp and cp then duration = duration + (cp - 1) * record.cp end

	if record.tn then
		if type(record.tn) == "string" then
			record.tn = self:GetTalentPosition(record.tn)
		end
		if record.tn then
			local _, _, _, _, talentRank = GetTalentInfo(record.tn[1], record.tn[2])
			if talentRank and talentRank > 0 then
				local gain = record.tt and record.tt[talentRank] or (record.tb + (talentRank - 1) * (record.ts or record.tb))
				duration = duration + (record.tp and (duration / 100) * gain or gain)
			end
		end
	end
	return duration
end

function Chronometer:GetTexture(name, record)
	if record.xn then
		name = record.xn
	end
	record.tx = BS:GetSpellIcon(name)
	return record.tx
end

function Chronometer:GetTalentPosition(name)
	for i = 1, GetNumTalentTabs() do
		for j = 1, GetNumTalents(i) do
			local talentName = GetTalentInfo(i, j)
			if talentName == name then
				return { i, j }
			end
		end
	end
end

function Chronometer:IsBanished(target)
	for i = 1, 20 do
		if self.bars[i].id and self.bars[i].target == target and self.bars[i].name == BS["Banish"] then
			return true
		end
	end
	return false
end

function Chronometer:CleanGroup(group, target)
	if not group or type(self.groups) ~= "table" then
		return
	end
	local groupDef = self.groups[group]
	if type(groupDef) ~= "table" then
		return
	end
	local forall = groupDef.fa
	for i = 20, 1, -1 do
		if self.bars[i].group and self.bars[i].group == group then
			if forall or self.bars[i].target == target then
				self:StopCandyBar(self.bars[i].id)
				self:StopBar(self.bars[i].id)
				if not forall then break end
			end
		end
	end
end

function Chronometer:KillBar(name, unit)
	for i = 20, 1, -1 do
		if self.bars[i].id and self.bars[i].name == name then
			if not unit then
				if self.bars[i].timer.k.t then unit = UnitName("player") else unit = "none" end
			end
			if self.bars[i].target == unit then
				self:StopCandyBar(self.bars[i].id)
				return self:StopBar(self.bars[i].id)
			end
		end
	end
end

function Chronometer:KillBars(unit)
	if unit and UnitExists("target") and UnitName("target") == unit and not UnitIsDeadOrGhost("target") then
		return
	end
	for i = 20, 1, -1 do
		if self.bars[i].id and (not unit or self.bars[i].target == unit) then
			self:SetCandyBarFade(self.bars[i].id, 0.5, true)
			self:StopCandyBar(self.bars[i].id)
			self:ReallyStopBar(self.bars[i].id)
		end
	end
end

function Chronometer:StopBar(id)
	if self.profile.ghost and self.profile.ghost > 0 then
		self:ScheduleEvent("MTHChronometerStop" .. id, self.ReallyStopBar, self.profile.ghost, self, id)
	else
		self:ReallyStopBar(id)
	end
end

function Chronometer:ReallyStopBar(id)
	self:CancelScheduledEvent("MTHChronometerStop" .. id)
	for i = 1, 20 do
		if self.bars[i].id == id then
			for key in pairs(self.bars[i]) do
				self.bars[i][key] = nil
			end
		end
	end
	for i = 1, 19 do
		if not self.bars[i].id then
			local temp = self.bars[i]
			for j = i + 1, 20 do
				if self.bars[j].id then
					self.bars[i] = self.bars[j]
					self.bars[j] = temp
					temp = nil
					break
				end
			end
			if temp then break end
		end
	end
end

function Chronometer:CandyOnClick(id, button, reactive, middlecast)
	if button == "RightButton" then
		MouselookStart()
		Chronometer.rightclick = true
		self:ScheduleEvent(function() Chronometer.rightclick = false; Chronometer:CancelScheduledEvent("MTHChronometerCheckMouselook") end, 0.5)
		self:ScheduleRepeatingEvent("MTHChronometerCheckMouselook", Chronometer.onClickStopCandyBar, 0.06, self, id)
	elseif button == "MiddleButton" and middlecast then
		for i = 1, 20 do
			if self.bars[i].id == id then
				return self:CastSpellOnUnit(middlecast, self.bars[i].target)
			end
		end
	elseif button == "LeftButton" and reactive then
		for i = 1, 20 do
			if self.bars[i].id == id then
				return self:CastSpellOnUnit(self.bars[i].name, self.bars[i].target)
			end
		end
	end
end

function Chronometer:onClickStopCandyBar(id)
	if Chronometer.rightclick and not IsMouselooking() then
		self:SetCandyBarFade(id, 0.5, true)
		self:StopCandyBar(id)
		self:StopBar(id)
	end
end

function Chronometer:CastSpellOnUnit(spell, unit)
	local restore = nil
	local hadtarget = UnitExists("target")

	if unit and unit ~= "none" then
		if hadtarget and UnitName("target") ~= unit then
			restore = true
		end
		TargetByName(unit, true)
	end

	CastSpellByName(spell)

	if restore then
		TargetLastTarget()
	elseif not hadtarget then
		ClearTarget()
	end
end

function Chronometer:RunTest()
	if not self._mth_enabled then
		self:MTH_Enable()
	end
	if type(self.bars) ~= "table" then
		self.bars = {}
		for i = 1, 20 do
			self.bars[i] = self.bars[i] or {}
		end
	end

	for i = 1, 5 do
		local name = "Test" .. i
		local target = "Test"
		local rank = 1
		local id = name .. "-" .. target
		local slot = nil

		for j = 20, 1, -1 do
			if self.bars[j].id == id then
				self:SetCandyBarFade(id, 0, false)
				self:StopCandyBar(self.bars[j].id)
				self:ReallyStopBar(self.bars[j].id)
				break
			end
		end
		for j = 1, 20 do
			if not self.bars[j].id then
				slot = j
				break
			end
		end
		if not slot then
			slot = 20
		end

		self.bars[slot].id = id
		self.bars[slot].timer = nil
		self.bars[slot].name = name
		self.bars[slot].rank = rank
		self.bars[slot].target = target
		self.bars[slot].group = nil

		local duration = math.random() * 8.0 + 2.0
		local text = self.profile.text or "$t"
		text = string.gsub(text, "$t", target)
		text = string.gsub(text, "$s", name)
		local icon = "Interface\\Icons\\Spell_Shadow_ManaBurn"
		local color = convertcolor(self.profile.barcolor)

		self:RegisterCandyBar(id, duration, text, icon, color[1], color[2], color[3], 1, 0, 0)
		self:RegisterCandyBarWithGroup(id, BAR_GROUP)
		if self.profile.barscale then self:SetCandyBarScale(id, self.profile.barscale) end
		if self.profile.barwidth then self:SetCandyBarWidth(id, self.profile.barwidth) end
		if self.profile.barheight then self:SetCandyBarHeight(id, self.profile.barheight) end
		if self.profile.iconposition then self:SetCandyBarIconPosition(id, self.profile.iconposition) end
		if self.profile.spacing then self:SetCandyBarGroupVerticalSpacing(BAR_GROUP, self.profile.spacing) end
		if self.profile.textsize then self:SetCandyBarFontSize(id, self.profile.textsize) end
		if self.profile.textcolor then local c = convertcolor(self.profile.textcolor); self:SetCandyBarTextColor(id, c[1], c[2], c[3]) end
		if self.profile.bgcolor then local c = convertcolor(self.profile.bgcolor); self:SetCandyBarBackgroundColor(id, c[1], c[2], c[3], self.profile.bgalpha) end
		if self.profile.bordercolor then local c = convertcolor(self.profile.bordercolor); self:SetCandyBarBorderColor(id, c[1], c[2], c[3]) end
		if self.profile.bordertex then self:SetCandyBarBorderTexture(id, self.profile.bordertex) end
		if self.profile.ghost then self:SetCandyBarFade(id, self.profile.ghost, true) end
		self:SetCandyBarCompletion(id, self.StopBar, self, id)
		self:SetCandyBarReversed(id, self.profile.reverse)
		self:SetCandyBarOnClick(id, function(a1, a2, a3, a4, a5) self:CandyOnClick(a1, a2, a3, a4, a5) end)
		self:StartCandyBar(id, true)
	end
end

function Chronometer:ToggleAnchor()
	if self.anchor:IsVisible() then
		self.anchor:Hide()
	else
		self.anchor:Show()
	end
end

function Chronometer:CreateAnchor(text, r, g, b)
	local frame = CreateFrame("Button", "MTH_ChronometerAnchor", UIParent)
	frame:SetWidth(220)
	frame:SetHeight(25)
	frame.owner = self
	frame:SetClampedToScreen(true)
	frame:SetMovable(true)
	frame:RegisterForDrag("LeftButton")

	local px = tonumber(self.profile and self.profile.barposition and self.profile.barposition.x)
	local py = tonumber(self.profile and self.profile.barposition and self.profile.barposition.y)
	local ppoint = tostring(self.profile and self.profile.barposition and self.profile.barposition.point or "")
	local prelpoint = tostring(self.profile and self.profile.barposition and self.profile.barposition.relativePoint or "")
	MTH_CHRON_Trace("CreateAnchor saved-in profile=" .. MTH_CHRON_FormatBarPosition(self.profile))
	if px ~= nil and py ~= nil then
		if ppoint == "" then
			ppoint = "TOPLEFT"
		end
		if prelpoint == "" then
			prelpoint = ppoint
		end
		frame:ClearAllPoints()
		frame:SetPoint(ppoint, UIParent, prelpoint, px, py)
		MTH_CHRON_Trace("CreateAnchor restored point=" .. MTH_CHRON_DescribePoint(frame))
	else
		frame:SetPoint("CENTER", UIParent, "CENTER", 0, 50)
		MTH_CHRON_Trace("CreateAnchor default point=" .. MTH_CHRON_DescribePoint(frame))
	end

	frame:SetScript("OnDragStart", function()
		if not this or not this.StartMoving then
			return
		end
		MTH_CHRON_Trace("anchor drag-start point=" .. MTH_CHRON_DescribePoint(this))
		this:StartMoving()
	end)
	frame:SetScript("OnDragStop", function()
		if not this then
			return
		end

		if this.StopMovingOrSizing then
			this:StopMovingOrSizing()
		end

		local point, _, _, x, y = this:GetPoint()
		x = tonumber(x)
		y = tonumber(y)
		if not x or not y then
			return
		end

		x = math.floor(x + 0.5)
		y = math.floor(y + 0.5)
		this:ClearAllPoints()
		this:SetPoint(point or "TOPLEFT", UIParent, point or "TOPLEFT", x, y)

		if this.owner and this.owner.profile and type(this.owner.profile.barposition) == "table" then
			this.owner.profile.barposition.point = point or "TOPLEFT"
			this.owner.profile.barposition.relativePoint = point or "TOPLEFT"
			this.owner.profile.barposition.x = x
			this.owner.profile.barposition.y = y
			MTH_CHRON_Trace("anchor drag-stop saved profile=" .. MTH_CHRON_FormatBarPosition(this.owner.profile)
				.. " frame=" .. MTH_CHRON_DescribePoint(this))
		end
	end)

	frame:SetBackdrop({
		bgFile = "Interface/Tooltips/UI-Tooltip-Background",
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
		tile = false,
		tileSize = 16,
		edgeSize = 16,
		insets = { left = 5, right = 5, top = 5, bottom = 5 },
	})
	frame:SetBackdropColor(r, g, b, 0.6)

	frame.Text = frame:CreateFontString(nil, "OVERLAY")
	frame.Text:SetFontObject(GameFontNormalSmall)
	frame.Text:ClearAllPoints()
	frame.Text:SetTextColor(1, 1, 1, 1)
	frame.Text:SetWidth(220)
	frame.Text:SetHeight(25)
	frame.Text:SetPoint("TOPLEFT", frame, "TOPLEFT")
	frame.Text:SetJustifyH("CENTER")
	frame.Text:SetJustifyV("MIDDLE")
	frame.Text:SetText(text)
	frame:Hide()

	return frame
end

function Chronometer:COMBAT_DEATH(event, info)
	if not self.profile.fadeonkill then return end
	if info.type == "experience" then
		if info.source and not self:IsBanished(info.source) then
			self:ScheduleEvent(self.KillBars, 0.5, self, info.source)
			return
		end
	elseif info.victim ~= ParserLib_SELF then
		self:ScheduleEvent(self.KillBars, 0.5, self, info.victim)
		return
	end
end

function Chronometer:SPELL_FADE(event, info)
	if not self.profile.fadeonfade then return end
	if info.skill == BS["Banish"] then return end
	if info.type == "fade" then
		if info.victim == ParserLib_SELF then
			return self:KillBar(info.skill)
		end
		return self:KillBar(info.skill, info.victim)
	end
end

function Chronometer:SPELL_PERIODIC(event, info)
	local aura, rank, unit, isgain

	if info.type == "buff" then
		isgain = 1
	elseif info.type == "debuff" then
		isgain = nil
	elseif not info.isDOT then
		return
	end

	if info.victim ~= ParserLib_SELF then
		unit = info.victim
	end
	aura = info.skill
	_, _, rank = string.find(aura, "%s([IVX]+)[^u]")
	if rank then
		rank = latins[rank]
		aura = string.gsub(aura, "%s([IVX]+)[^u]", "")
	end

	if aura == "Deep Wound" then
		aura = "Deep Wounds"
	elseif aura == "Piercing Shots" then
		aura = "Piercing Shot"
	end

	local timer = self.timers[self.EVENT] and self.timers[self.EVENT][aura]
	if timer and timer.k.g == isgain and not info.isDOT and (timer.x.a or (timer.v and timer.v > GetTime())) then
		if timer.k.t then
			if not unit then unit = UnitName("player") end
			if timer.k.s then
				if timer.t and timer.t ~= unit then return end
			else
				if not UnitExists("target") or unit ~= UnitName("target") then return end
			end
		else
			if not timer.k.s or not unit then unit = "none" else return end
		end
		timer.v = nil
		timer.t = nil
		self:StartTimer(timer, aura, unit, rank)
	elseif timer and info.isDOT and not timer.x.a then
		timer.v = nil
		timer.t = nil
		self:StartTimer(timer, aura, "none")
	end
end

function Chronometer:SELF_CRITS(event, info)
	if info.type == "hit" and info.source == ParserLib_SELF and info.isCrit then
		for i = 1, 20 do
			if self.bars[i].id and self.bars[i].timer.x.romc then
				self:StartTimer(self.bars[i].timer, self.bars[i].name, self.bars[i].target, self.bars[i].rank)
			end
		end
	end
end

function Chronometer:PLAYER_DEAD()
	self.active = {}
	self.captive = {}

	local unit = UnitName("player")
	for i = 20, 1, -1 do
		if self.bars[i].id and (self.bars[i].target == unit or (self.bars[i].target == "none" and self.bars[i].timer.k.g)) then
			self:SetCandyBarFade(self.bars[i].id, 0.5, true)
			self:StopCandyBar(self.bars[i].id)
			self:ReallyStopBar(self.bars[i].id)
		end
	end
end

function Chronometer:UNIT_AURA(unit)
	local auraUnit = unit
	if (not auraUnit or auraUnit == "") and type(arg1) == "string" then
		auraUnit = arg1
	end
	if auraUnit ~= "pet" then
		return
	end
	if not (UnitExists and UnitExists("pet")) then
		return
	end

	local feedSpell = BS and BS["Feed Pet"] or "Feed Pet"
	local timer = self.timers and self.timers[self.SPELL] and self.timers[self.SPELL][feedSpell]
	if not timer then
		return
	end

	local hasFeedAura = false
	if type(UnitBuff) == "function" then
		for i = 1, 32 do
			local texture = UnitBuff("pet", i)
			if not texture then
				break
			end
			local tex = tostring(texture)
			if string.find(tex, "Ability_Hunter_BeastTraining", 1, true)
				or string.find(tex, "INV_Misc_Fork&Knife", 1, true)
			then
				hasFeedAura = true
				break
			end
		end
	end

	if not hasFeedAura then
		return
	end

	local petName = UnitName and UnitName("pet") or "none"
	if not petName or petName == "" then
		petName = "none"
	end

	for i = 1, 20 do
		local bar = self.bars and self.bars[i]
		if bar and bar.id and bar.name == feedSpell then
			if bar.target == petName or bar.target == "none" then
				return
			end
		end
	end

	self:StartTimer(timer, feedSpell, petName)
end

function Chronometer:UseAction(slot, clicked, onself)
	local name, rank = getActionSpell(slot)
	if name then
		local normalized = tostring(name)
		normalized = string.gsub(normalized, "^%s+", "")
		normalized = string.gsub(normalized, "%s+$", "")
		local _, _, baseName = string.find(normalized, "^(.-)%s*%(.+%)$")
		if baseName and baseName ~= "" then
			normalized = baseName
		end

		local timer = nil
		if self.timers[self.SPELL] then
			timer = self.timers[self.SPELL][normalized] or self.timers[self.SPELL][name]
		end
		if timer then
			self:CatchSpellcast(timer, normalized, rank, onself)
		end
	end
	if self.hooks and type(self.hooks["UseAction"]) == "function" then
		return self.hooks["UseAction"](slot, clicked, onself)
	end
	return callGlobal("UseAction", slot, clicked, onself)
end

function Chronometer:CastSpell(index, booktype)
	local name, rankText = GetSpellName(index, booktype)
	local timer = self.timers[self.SPELL] and self.timers[self.SPELL][name]
	if timer then
		self:CatchSpellcast(timer, name, parseRankNumber(rankText))
	end
	if self.hooks and type(self.hooks["CastSpell"]) == "function" then
		return self.hooks["CastSpell"](index, booktype)
	end
	return callGlobal("CastSpell", index, booktype)
end

function Chronometer:CastSpellByName(text, onself)
	local raw = tostring(text or "")
	local name = raw
	local rank = 0
	local _, _, spellName, paren = string.find(raw, "^(.-)%s*%((.-)%)$")
	if spellName and paren then
		name = spellName
		rank = parseRankNumber(paren)
	end
	name = string.gsub(name, "^%s+", "")
	name = string.gsub(name, "%s+$", "")
	local timer = self.timers[self.SPELL] and self.timers[self.SPELL][name]
	if timer then
		self:CatchSpellcast(timer, name, rank, onself)
	end
	if self.hooks and type(self.hooks["CastSpellByName"]) == "function" then
		return self.hooks["CastSpellByName"](text, onself)
	end
	return callGlobal("CastSpellByName", text, onself)
end

function Chronometer:CatchSpellcast(timer, name, rank, onself)
	local unit = nil
	if timer.k.t then
		if timer.k.s then
			if onself and onself == 1 then
				unit = UnitName("player")
			elseif UnitExists("target") then
				if timer.k.g then
					if UnitIsFriend("player", "target") then unit = UnitName("target") end
				else
					if UnitCanAttack("player", "target") then unit = UnitName("target") end
				end
			end
		else
			if UnitExists("target") then unit = UnitName("target") else return end
		end
	else
		unit = "none"
	end

	local cp = GetComboPoints("player", "target")
	if cp and cp > 0 then
		timer.cp = cp
	end
	table.insert(self.captive, { t = timer, n = name, u = unit, r = rank })
end

function Chronometer:SpellTargetUnit(unit)
	for _, captive in pairs(self.captive) do
		if not captive.u then
			captive.u = UnitName(unit)
		end
	end
	if self.hooks and type(self.hooks["SpellTargetUnit"]) == "function" then
		return self.hooks["SpellTargetUnit"](unit)
	end
	return callGlobal("SpellTargetUnit", unit)
end

function Chronometer:TargetUnit(unit)
	for _, captive in pairs(self.captive) do
		if not captive.u then
			captive.u = UnitName(unit)
		end
	end
	if self.hooks and type(self.hooks["TargetUnit"]) == "function" then
		return self.hooks["TargetUnit"](unit)
	end
	return callGlobal("TargetUnit", unit)
end

function Chronometer:OnMouseDown(button)
	for _, captive in pairs(self.captive) do
		if not captive.u and button == "LeftButton" and UnitExists("mouseover") then
			captive.u = UnitName("mouseover")
		end
	end
	if self.hooks and WorldFrame and self.hooks[WorldFrame] and type(self.hooks[WorldFrame]["OnMouseDown"]) == "function" then
		return self.hooks[WorldFrame]["OnMouseDown"](WorldFrame, button)
	end
	if WorldFrame and type(WorldFrame.GetScript) == "function" then
		local script = WorldFrame:GetScript("OnMouseDown")
		if type(script) == "function" and script ~= Chronometer.OnMouseDown then
			return script(WorldFrame, button)
		end
	end
	return nil
end

function Chronometer:SPELLCAST_START()
end

function Chronometer:SPELLCAST_STOP()
	local captive = self.captive[1]
	if captive then
		if captive.t and captive.t.x.ea then
			for name, valid in pairs(captive.t.x.ea) do
				local eventTimer = self.timers and self.timers[Chronometer.EVENT] and self.timers[Chronometer.EVENT][name]
				if eventTimer then
					eventTimer.r = captive.r
					eventTimer.v = GetTime() + valid
					if captive.u ~= "none" then
						eventTimer.t = captive.u
					end
				end
			end
		end

		if captive.u == "none" then
			self:StartTimer(captive.t, captive.n, captive.u, captive.r)
		else
			self.active[captive.n] = { t = captive.t, n = captive.n, u = captive.u, r = captive.r }
			self:ScheduleEvent(self.CompleteCast, 0.5, self, captive.n)
		end
	end
	self.captive = {}
end

function Chronometer:CompleteCast(name)
	local active = self.active[name]
	if active and active.t then
		self:StartTimer(active.t, active.n, active.u, active.r, -0.5)
		self.active[name] = nil
	end
end

function Chronometer:SpellStopCasting()
	self.captive = {}
	if self.hooks and type(self.hooks["SpellStopCasting"]) == "function" then
		return self.hooks["SpellStopCasting"]()
	end
	return callGlobal("SpellStopCasting")
end

function Chronometer:SpellStopTargeting()
	if type(self.captive) == "table" and table.getn(self.captive) > 0 then
		local kept = {}
		for i = 1, table.getn(self.captive) do
			local captive = self.captive[i]
			if captive and captive.t and captive.t.k and not captive.t.k.t then
				table.insert(kept, captive)
			end
		end
		self.captive = kept
	else
		self.captive = {}
	end
	if self.hooks and type(self.hooks["SpellStopTargeting"]) == "function" then
		return self.hooks["SpellStopTargeting"]()
	end
	return callGlobal("SpellStopTargeting")
end

function Chronometer:SPELL_FAILED(event, info)
	for k, captive in pairs(self.captive) do
		if captive.n == info.skill then
			table.remove(self.captive, k)
			break
		end
	end
end

function Chronometer:SPELLCAST_INTERRUPTED()
	for _, active in pairs(self.active) do
		if active.t and active.t.x.ea then
			for name in pairs(active.t.x.ea) do
				local eventTimer = self.timers and self.timers[Chronometer.EVENT] and self.timers[Chronometer.EVENT][name]
				if eventTimer then
					eventTimer.r = nil
					eventTimer.v = nil
					eventTimer.t = nil
				end
			end
		end
	end
	self.active = {}
end

function Chronometer:SELF_DAMAGE(event, info)
	local active = self.active[info.skill]
	if active and info.type == "miss" and info.victim == active.u then
		if active.t and active.t.x.ea then
			for name in pairs(active.t.x.ea) do
				local eventTimer = self.timers and self.timers[Chronometer.EVENT] and self.timers[Chronometer.EVENT][name]
				if eventTimer then
					eventTimer.r = nil
					eventTimer.v = nil
					eventTimer.t = nil
				end
			end
		end
		self.active[info.skill] = nil
	elseif active and info.type == "hit" and info.victim == active.u then
		if active.t and active.t.x.ea then
			for name in pairs(active.t.x.ea) do
				for i = 1, 20 do
					if self.bars[i].id and self.bars[i].id == name .. "-" .. info.victim then
						self:StartTimer(self.bars[i].timer, self.bars[i].name, self.bars[i].target, self.bars[i].rank)
					end
				end
			end
		end
	end
end

function Chronometer:SELF_HITS(event, info)
	if info.type == "hit" and info.source == ParserLib_SELF then
		for i = 1, 20 do
			if self.bars[i].id and self.bars[i].target == info.victim and self.bars[i].timer.x.rom then
				self:StartTimer(self.bars[i].timer, self.bars[i].name, self.bars[i].target, self.bars[i].rank)
			end
		end
	end
end

function Chronometer:SPGetGUIDForName(base)
	local name = tostring(base or "")
	if name == "" then return nil end

	local function guidOf(unit)
		if not UnitExists(unit) then
			return nil
		end
		if UnitName(unit) ~= name then
			return nil
		end
		if type(UnitGUID) == "function" then
			local guid = UnitGUID(unit)
			if guid and guid ~= "" then
				return guid
			end
		end
		return nil
	end

	return guidOf("pettarget") or guidOf("target") or guidOf("mouseover")
end
