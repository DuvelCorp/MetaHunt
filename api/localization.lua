------------------------------------------------------
-- MetaHunt Localization System
------------------------------------------------------

MTH.localization = {}
MTH.currentLocale = GetLocale()

-- Binding Headers (must be defined early for keybindings)
BINDING_HEADER_FEEDOMATIC = "[MetaHunt] Feed-O-Matic"
BINDING_HEADER_ZAspectHeader = "[MetaHunt] ZAspect Buttons"
BINDING_HEADER_ZTrackHeader = "[MetaHunt] ZTrack Buttons"
BINDING_HEADER_ZTrapHeader = "[MetaHunt] ZTrap Buttons"
BINDING_HEADER_ZPetHeader = "[MetaHunt] ZPet Buttons"
BINDING_HEADER_ZAmmoHeader = "[MetaHunt] ZAmmo Buttons"

-- Localization table structure
local L = {}

-- English (default)
if MTH.currentLocale == "enUS" or MTH.currentLocale == "enGB" then
	
	-- FeedOMatic
	L.FEEDOMATIC_NAME = "Feed-O-Matic"
	L.FEEDOMATIC_DESC = "Helps a Hunter keep his pets well fed"
	L.TOOLTIPS_OPTION_FOOD = "Add tooltips on food"
	L.TOOLTIPS_OPTION_FOOD_HELP = "Show your current pet's food preference directly in item tooltips."
	L.TOOLTIPS_OPTION_OWNPET = "Activate on my pet"
	L.TOOLTIPS_OPTION_OWNPET_HELP = "Show your own pet status details in tooltip when hovering your pet context."
	L.TOOLTIPS_FOOD_QUALITY_UNKNOWN = "%s can eat this, but hasn't tried it yet."
	L.TOOLTIPS_FOOD_QUALITY_UNDER = "%s doesn't like this anymore."
	L.TOOLTIPS_FOOD_QUALITY_MIGHT = "%s might eat this."
	L.TOOLTIPS_FOOD_QUALITY_WILL = "%s will eat this."
	L.TOOLTIPS_FOOD_QUALITY_LIKE = "%s likes to eat this."
	L.TOOLTIPS_FOOD_QUALITY_LOVE = "%s loves to eat this."
	L.TOOLTIPS_FOOD_MARKER_UNKNOWN = "can eat this, but hasn't tried it yet."
	L.TOOLTIPS_FOOD_MARKER_UNDER = "doesn't like this anymore."
	L.TOOLTIPS_FOOD_MARKER_MIGHT = "might eat this."
	L.TOOLTIPS_FOOD_MARKER_WILL = "will eat this."
	L.TOOLTIPS_FOOD_MARKER_LIKE = "likes to eat this."
	L.TOOLTIPS_FOOD_MARKER_LOVE = "loves to eat this."
	
	-- zhunter
	L.ZHUNTER_NAME = "zhunter"
	L.ZHUNTER_DESC = "Various features to make a hunter's life easier"

-- German / Deutsch
elseif MTH.currentLocale == "deDE" then
	
	L.FEEDOMATIC_NAME = "Futter-O-Mat"
	L.ZHUNTER_NAME = "zhunter"
	L.TOOLTIPS_OPTION_FOOD = "Add tooltips on food"
	L.TOOLTIPS_OPTION_FOOD_HELP = "Show your current pet's food preference directly in item tooltips."
	L.TOOLTIPS_OPTION_OWNPET = "Activate on my pet"
	L.TOOLTIPS_OPTION_OWNPET_HELP = "Show your own pet status details in tooltip when hovering your pet context."
	L.TOOLTIPS_FOOD_QUALITY_UNKNOWN = "%s can eat this, but hasn't tried it yet."
	L.TOOLTIPS_FOOD_QUALITY_UNDER = "%s doesn't like this anymore."
	L.TOOLTIPS_FOOD_QUALITY_MIGHT = "%s might eat this."
	L.TOOLTIPS_FOOD_QUALITY_WILL = "%s will eat this."
	L.TOOLTIPS_FOOD_QUALITY_LIKE = "%s likes to eat this."
	L.TOOLTIPS_FOOD_QUALITY_LOVE = "%s loves to eat this."
	L.TOOLTIPS_FOOD_MARKER_UNKNOWN = "can eat this, but hasn't tried it yet."
	L.TOOLTIPS_FOOD_MARKER_UNDER = "doesn't like this anymore."
	L.TOOLTIPS_FOOD_MARKER_MIGHT = "might eat this."
	L.TOOLTIPS_FOOD_MARKER_WILL = "will eat this."
	L.TOOLTIPS_FOOD_MARKER_LIKE = "likes to eat this."
	L.TOOLTIPS_FOOD_MARKER_LOVE = "loves to eat this."

-- French / Français
elseif MTH.currentLocale == "frFR" then
	
	L.FEEDOMATIC_NAME = "Nourricier"
	L.ZHUNTER_NAME = "zhunter"
	L.TOOLTIPS_OPTION_FOOD = "Add tooltips on food"
	L.TOOLTIPS_OPTION_FOOD_HELP = "Show your current pet's food preference directly in item tooltips."
	L.TOOLTIPS_OPTION_OWNPET = "Activate on my pet"
	L.TOOLTIPS_OPTION_OWNPET_HELP = "Show your own pet status details in tooltip when hovering your pet context."
	L.TOOLTIPS_FOOD_QUALITY_UNKNOWN = "%s can eat this, but hasn't tried it yet."
	L.TOOLTIPS_FOOD_QUALITY_UNDER = "%s doesn't like this anymore."
	L.TOOLTIPS_FOOD_QUALITY_MIGHT = "%s might eat this."
	L.TOOLTIPS_FOOD_QUALITY_WILL = "%s will eat this."
	L.TOOLTIPS_FOOD_QUALITY_LIKE = "%s likes to eat this."
	L.TOOLTIPS_FOOD_QUALITY_LOVE = "%s loves to eat this."
	L.TOOLTIPS_FOOD_MARKER_UNKNOWN = "can eat this, but hasn't tried it yet."
	L.TOOLTIPS_FOOD_MARKER_UNDER = "doesn't like this anymore."
	L.TOOLTIPS_FOOD_MARKER_MIGHT = "might eat this."
	L.TOOLTIPS_FOOD_MARKER_WILL = "will eat this."
	L.TOOLTIPS_FOOD_MARKER_LIKE = "likes to eat this."
	L.TOOLTIPS_FOOD_MARKER_LOVE = "loves to eat this."

end

MTH.localization[MTH.currentLocale] = L

-- Get localized string
function MTH:GetLocalization(key, default)
	if L[key] then
		return L[key]
	end
	return default or key
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
	enUS = {
		["Banish"] = "Banish",
		["Bestial Wrath"] = "Bestial Wrath",
		["Concussive Shot"] = "Concussive Shot",
		["Counterattack"] = "Counterattack",
		["Critical Mass"] = "Critical Mass",
		["Clever Traps"] = "Clever Traps",
		["Deterrence"] = "Deterrence",
		["Explosive Trap"] = "Explosive Trap",
		["Explosive Trap Effect"] = "Explosive Trap Effect",
		["Feed Pet"] = "Feed Pet",
		["Flare"] = "Flare",
		["Freezing Trap"] = "Freezing Trap",
		["Freezing Trap Effect"] = "Freezing Trap Effect",
		["Frost Trap"] = "Frost Trap",
		["Frost Trap Aura"] = "Frost Trap Aura",
		["Hunter's Mark"] = "Hunter's Mark",
		["Holy Strength"] = "Holy Strength",
		["Immolation Trap"] = "Immolation Trap",
		["Immolation Trap Effect"] = "Immolation Trap Effect",
		["Improved Concussive Shot"] = "Improved Concussive Shot",
		["Improved Wing Clip"] = "Improved Wing Clip",
		["Perception"] = "Perception",
		["Piercing Shot"] = "Piercing Shot",
		["Piercing Shots"] = "Piercing Shots",
		["Quick Shots"] = "Quick Shots",
		["Rapid Fire"] = "Rapid Fire",
		["Scare Beast"] = "Scare Beast",
		["Scatter Shot"] = "Scatter Shot",
		["Scorpid Poison"] = "Scorpid Poison",
		["Scorpid Sting"] = "Scorpid Sting",
		["Serpent Sting"] = "Serpent Sting",
		["Stoneform"] = "Stoneform",
		["Unstable Power"] = "Unstable Power",
		["Ephemeral Power"] = "Ephemeral Power",
		["Viper Sting"] = "Viper Sting",
		["War Stomp"] = "War Stomp",
		["Will of the Forsaken"] = "Will of the Forsaken",
		["Wing Clip"] = "Wing Clip",
		["Wyvern Sting"] = "Wyvern Sting",
		["Blood Fury"] = "Blood Fury",
		["Berserking"] = "Berserking",
	},
}

MTH.Const = MTH.Const or {}
MTH.Const.SpellLocaleMap = MTH_SPELL_LOCALE

function MTH:LocalizeSpell(spellToken)
	local key = tostring(spellToken or "")
	if key == "" then
		return key
	end
	local locale = tostring(self.currentLocale or GetLocale() or "enUS")
	local localeMap = MTH_SPELL_LOCALE[locale] or MTH_SPELL_LOCALE.enUS
	if localeMap and localeMap[key] then
		return localeMap[key]
	end
	return key
end
