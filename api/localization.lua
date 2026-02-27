------------------------------------------------------
-- MetaHunt Localization System
------------------------------------------------------

MTH.localization = MTH.localization or {}
MTH.currentLocale = GetLocale()

local MTH_LOCALE_ALIASES = {
	enGB = "enUS",
	esMX = "esES",
	zhTW = "zhCN",
	frFR = "enUS",
}

local MTH_SUPPORTED_LOCALES = {
	enUS = true,
	deDE = true,
	esES = true,
	ptBR = true,
	ruRU = true,
	zhCN = true,
}

local function MTH_ResolveLocale(locale)
	local resolved = tostring(locale or "enUS")
	if MTH_LOCALE_ALIASES[resolved] then
		resolved = MTH_LOCALE_ALIASES[resolved]
	end
	if not MTH_SUPPORTED_LOCALES[resolved] then
		resolved = "enUS"
	end
	return resolved
end

local activeLocale = MTH_ResolveLocale(MTH.currentLocale)
local localeData = MTH_LocaleData or {}
local uiLocales = localeData.ui or {}
local uiDefault = uiLocales.enUS or {}
local uiActive = uiLocales[activeLocale] or {}

local function MTH_L(key, default)
	if uiActive[key] ~= nil then
		return uiActive[key]
	end
	if uiDefault[key] ~= nil then
		return uiDefault[key]
	end
	return default or key
end

MTH.localization[activeLocale] = uiActive
MTH.localization.enUS = uiDefault

BINDING_HEADER_FEEDOMATIC = MTH_L("BINDING_HEADER_FEEDOMATIC", "[MetaHunt] Feed-O-Matic")
BINDING_HEADER_ZAspectHeader = MTH_L("BINDING_HEADER_ZAspectHeader", "[MetaHunt] ZAspect Buttons")
BINDING_HEADER_ZTrackHeader = MTH_L("BINDING_HEADER_ZTrackHeader", "[MetaHunt] ZTrack Buttons")
BINDING_HEADER_ZTrapHeader = MTH_L("BINDING_HEADER_ZTrapHeader", "[MetaHunt] ZTrap Buttons")
BINDING_HEADER_ZPetHeader = MTH_L("BINDING_HEADER_ZPetHeader", "[MetaHunt] ZPet Buttons")
BINDING_HEADER_ZAmmoHeader = MTH_L("BINDING_HEADER_ZAmmoHeader", "[MetaHunt] ZAmmo Buttons")

function MTH:GetLocalization(key, default)
	return MTH_L(key, default)
end

local function MTH_GetLocaleVendorNameMap(locale)
	local dataLocales = (MTH_LocaleData and MTH_LocaleData.data) or nil
	local vendorLocales = dataLocales and dataLocales.vendors or nil
	if type(vendorLocales) ~= "table" then
		return nil
	end
	return vendorLocales[locale]
end

local function MTH_GetLocaleItemNameMap(locale)
	local dataLocales = (MTH_LocaleData and MTH_LocaleData.data) or nil
	local itemLocales = dataLocales and dataLocales.items or nil
	if type(itemLocales) ~= "table" then
		return nil
	end
	return itemLocales[locale]
end

local function MTH_GetLocaleBeastNameMap(locale)
	local dataLocales = (MTH_LocaleData and MTH_LocaleData.data) or nil
	if type(dataLocales) ~= "table" then
		MTH_LocaleData = MTH_LocaleData or {}
		MTH_LocaleData.data = MTH_LocaleData.data or {}
		dataLocales = MTH_LocaleData.data
	end
	local beastLocales = dataLocales and dataLocales.beasts or nil
	if type(beastLocales) ~= "table" then
		dataLocales.beasts = {}
		beastLocales = dataLocales.beasts
	end

	if locale == "enUS" then
		local enMap = beastLocales.enUS
		if type(enMap) ~= "table" then
			enMap = {}
			beastLocales.enUS = enMap
		end
		if next(enMap) == nil then
			local beasts = _G and _G.MTH_DS_Beasts or MTH_DS_Beasts
			if type(beasts) == "table" then
				for beastId, beast in pairs(beasts) do
					local id = tonumber(beastId)
					local name = type(beast) == "table" and tostring(beast.name or "") or ""
					if id and name ~= "" and enMap[id] == nil then
						enMap[id] = name
					end
				end
			end
		end
	end
	return beastLocales[locale]
end

function MTH:GetLocalizedVendorName(vendorId, defaultName)
	local id = tonumber(vendorId)
	if not id then
		return defaultName or "Unknown"
	end
	local locale = MTH_ResolveLocale(self.currentLocale or GetLocale() or "enUS")
	local localeMap = MTH_GetLocaleVendorNameMap(locale)
	if localeMap and localeMap[id] and localeMap[id] ~= "" then
		return localeMap[id]
	end
	local fallbackMap = MTH_GetLocaleVendorNameMap("enUS")
	if fallbackMap and fallbackMap[id] and fallbackMap[id] ~= "" then
		return fallbackMap[id]
	end
	return defaultName or "Unknown"
end

function MTH:GetLocalizedNPCNameById(npcId, defaultName)
	return self:GetLocalizedVendorName(npcId, defaultName)
end

function MTH:GetLocalizedItemName(itemId, defaultName)
	local id = tonumber(itemId)
	if not id then
		return defaultName or "Unknown"
	end
	local locale = MTH_ResolveLocale(self.currentLocale or GetLocale() or "enUS")
	local localeMap = MTH_GetLocaleItemNameMap(locale)
	if localeMap and localeMap[id] and localeMap[id] ~= "" then
		return localeMap[id]
	end
	local fallbackMap = MTH_GetLocaleItemNameMap("enUS")
	if fallbackMap and fallbackMap[id] and fallbackMap[id] ~= "" then
		return fallbackMap[id]
	end
	return defaultName or "Unknown"
end

function MTH:GetLocalizedBeastName(beastId, defaultName)
	local id = tonumber(beastId)
	if not id then
		return defaultName or "Unknown"
	end
	local locale = MTH_ResolveLocale(self.currentLocale or GetLocale() or "enUS")
	local localeMap = MTH_GetLocaleBeastNameMap(locale)
	if localeMap and localeMap[id] and localeMap[id] ~= "" then
		return localeMap[id]
	end
	local fallbackMap = MTH_GetLocaleBeastNameMap("enUS")
	if fallbackMap and fallbackMap[id] and fallbackMap[id] ~= "" then
		return fallbackMap[id]
	end
	return defaultName or "Unknown"
end

-- Module localization helper
function MTH:RegisterModuleLocalization(module_name, localizationTable)
	if not self.localization.modules then
		self.localization.modules = {}
	end
	self.localization.modules[module_name] = localizationTable
end

function MTH:GetModuleLocalization(module_name, key, default)
	if self.localization.modules and self.localization.modules[module_name] then
		local L = self.localization.modules[module_name]
		if L[key] then
			return L[key]
		end
	end
	return default or key
end

local MTH_SPELL_LOCALE = {
}

local MTH_SPELL_ID_BY_TOKEN = {
	["Banish"] = 710,
	["Bestial Wrath"] = 19574,
	["Concussive Shot"] = 5116,
	["Counterattack"] = 19306,
	["Clever Traps"] = 19239,
	["Deterrence"] = 19263,
	["Explosive Trap"] = 13813,
	["Explosive Trap Effect"] = 13812,
	["Feed Pet"] = 6991,
	["Flare"] = 1543,
	["Freezing Trap"] = 1499,
	["Freezing Trap Effect"] = 3355,
	["Frost Trap"] = 13809,
	["Frost Trap Aura"] = 13810,
	["Hunter's Mark"] = 1130,
	["Immolation Trap"] = 13795,
	["Immolation Trap Effect"] = 13797,
	["Improved Concussive Shot"] = 19407,
	["Improved Wing Clip"] = 19229,
	["Perception"] = 20600,
	["Rapid Fire"] = 3045,
	["Scare Beast"] = 1513,
	["Scatter Shot"] = 19503,
	["Scorpid Sting"] = 3043,
	["Serpent Sting"] = 1978,
	["Stoneform"] = 20594,
	["Viper Sting"] = 3034,
	["War Stomp"] = 20549,
	["Will of the Forsaken"] = 7744,
	["Wing Clip"] = 2974,
	["Wyvern Sting"] = 19386,
	["Blood Fury"] = 20572,
	["Berserking"] = 26297,
}

do
	local spellLocales = (MTH_LocaleData and MTH_LocaleData.spells) or nil
	if type(spellLocales) == "table" then
		for localeKey, localeMap in pairs(spellLocales) do
			if type(localeMap) == "table" then
				MTH_SPELL_LOCALE[localeKey] = localeMap
			end
		end
	end
end

do
	local extras = {
		enUS = {
			["Devilsaur Eye"] = "Devilsaur Eye",
			["Devilsaur Fury"] = "Devilsaur Fury",
			["Zandalarian Hero Medallion"] = "Zandalarian Hero Medallion",
			["Restless Strength"] = "Restless Strength",
			["Earthstrike"] = "Earthstrike",
			["Badge of the Swarmguard"] = "Badge of the Swarmguard",
			["Jom Gabbar"] = "Jom Gabbar",
			["Kiss of the Spider"] = "Kiss of the Spider",
			["Slayer's Crest"] = "Slayer's Crest",
		},
		deDE = {
			["Devilsaur Eye"] = "Auge eines Teufelssauriers",
			["Devilsaur Fury"] = "Zorn des Teufelssauriers",
			["Zandalarian Hero Medallion"] = "Zandalarianisches Heldenmedallion",
			["Restless Strength"] = "Ruhelose Stärke",
			["Earthstrike"] = "Erdschlag",
			["Badge of the Swarmguard"] = "Abzeichen der Schwarmwache",
			["Jom Gabbar"] = "Jom Gabbar",
			["Kiss of the Spider"] = "Kuss der Spinne",
			["Slayer's Crest"] = "Jägerspitze",
		},
		esES = {
			["Devilsaur Eye"] = "Ojo de Demosaurio",
			["Devilsaur Fury"] = "Furia del devilsaurio",
			["Zandalarian Hero Medallion"] = "Zandalarian Hero Medallion",
			["Restless Strength"] = "Fuerza agitada",
			["Earthstrike"] = "Golpeterra",
			["Badge of the Swarmguard"] = "Badge of the Swarmguard",
			["Jom Gabbar"] = "Jom Gabbar",
			["Kiss of the Spider"] = "Kiss of the Spider",
			["Slayer's Crest"] = "Cresta de Matador",
		},
		frFR = {
			["Devilsaur Eye"] = "Oeil de diablosaure",
			["Devilsaur Fury"] = "Fureur du diablosaure",
			["Zandalarian Hero Medallion"] = "Médaillon de héros zandalarien",
			["Restless Strength"] = "Force inconstante",
			["Earthstrike"] = "Choc de terre",
			["Badge of the Swarmguard"] = "Insigne de garde-essaim",
			["Jom Gabbar"] = "Jom Gabbar",
			["Kiss of the Spider"] = "Baiser de l'araignée",
			["Slayer's Crest"] = "Ecusson de tueur",
		},
		zhCN = {
			["Devilsaur Eye"] = "魔暴龙眼",
			["Devilsaur Fury"] = "魔暴龙之怒",
			["Zandalarian Hero Medallion"] = "赞达拉英雄徽记",
			["Restless Strength"] = "充沛之力",
			["Earthstrike"] = "大地之击",
			["Badge of the Swarmguard"] = "虫群守卫徽章",
			["Jom Gabbar"] = "Jom Gabbar",
			["Kiss of the Spider"] = "蜘蛛之吻",
			["Slayer's Crest"] = "屠戮者徽记",
		},
	}

	for localeKey, localeMap in pairs(extras) do
		if type(MTH_SPELL_LOCALE[localeKey]) ~= "table" then
			MTH_SPELL_LOCALE[localeKey] = {}
		end
		for token, localized in pairs(localeMap) do
			if MTH_SPELL_LOCALE[localeKey][token] == nil then
				MTH_SPELL_LOCALE[localeKey][token] = localized
			end
		end
	end
end

MTH.Const = MTH.Const or {}
MTH.Const.SpellLocaleMap = MTH_SPELL_LOCALE
MTH.Const.NPCLocaleMap = (MTH_LocaleData and MTH_LocaleData.data and MTH_LocaleData.data.vendors) or {}
MTH.Const.ItemLocaleMap = (MTH_LocaleData and MTH_LocaleData.data and MTH_LocaleData.data.items) or {}
MTH.Const.BeastLocaleMap = (MTH_LocaleData and MTH_LocaleData.data and MTH_LocaleData.data.beasts) or {}

function MTH:LocalizeSpell(spellToken)
	local key = tostring(spellToken or "")
	if key == "" then
		return key
	end
	local getSpellInfo = _G and _G["GetSpellInfo"] or nil
	local spellId = MTH_SPELL_ID_BY_TOKEN[key]
	if spellId and getSpellInfo then
		local spellName = getSpellInfo(spellId)
		if spellName and spellName ~= "" then
			return spellName
		end
	end
	local locale = MTH_ResolveLocale(self.currentLocale or GetLocale() or "enUS")
	local localeMap = MTH_SPELL_LOCALE[locale] or MTH_SPELL_LOCALE.enUS
	if localeMap and localeMap[key] then
		return localeMap[key]
	end
	return key
end
