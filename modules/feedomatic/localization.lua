-----------------------------------------------------
-- localization.lua
-- English strings by default, localizations override with their own.
------------------------------------------------------

-- Key bindings
-- NOTE: BINDING_HEADER_FEEDOMATIC is defined in api/localization.lua via the MTH_L() system.
BINDING_NAME_FEEDOMATIC = "Feed Pet";

-- Diet names. These should be the all-lowercase versions of the six diets returned from GetPetFoodTypes(). (Want to get them all nice and quick for your localization? Go tame a bear... they eat anything.)
-- THESE STRINGS MUST BE LOCALIZED for Feed-O-Matic to work properly in other locales.
FOM_DIET_MEAT	= "meat";
FOM_DIET_FISH	= "fish";
FOM_DIET_BREAD	= "bread";
FOM_DIET_CHEESE = "cheese";
FOM_DIET_FRUIT	= "fruit";
FOM_DIET_FUNGUS = "fungus";

-- If the player has a buff whose icon name contains "Ability_Mount" and whose name contains one of these substrings, we assume the player is mounted. We have to use this rather oblique way to check for mounted because some other buffs use the Ability_Mount_* icons. If these aren't localized, we may not recognize when the player is mounted and still try to feed the pet.
FOM_MOUNT_NAME_SUBSTRINGS = { "kodo", "wolf", "raptor", "steed", "horse", "ram", "saber", "mechanostrider" };

-- It's not clear whether the 5th and 6th returns from GetItemInfo() are supposed to be localized... so we have localized keys for them just in case. If these aren't localized, we'll just needlessly search your ammo bags for food.
FOM_AMMO_POUCH = "Ammo Pouch";
FOM_QUIVER = "Quiver";

-- From here on down, the localized strings are just for readability... they don't affect whether Feed-O-Matic works.

-- Two special diets; one is used for tracking food that provides a bonus (or at least, that you don't want to have fed to your pet when the 'savebonus' option is on), and another that's used in the chat-line interface for listing all diets.
FOM_DIET_BONUS	= "bonus";
FOM_DIET_ALL	= "all";

-- Used in tooltips to indicate food quality.
FOM_QUALITY_UNKNOWN	= "%s can eat this, but hasn't tried it yet.";
FOM_QUALITY_UNDER	= "%s doesn't like this anymore.";
FOM_QUALITY_MIGHT	= "%s might eat this.";
FOM_QUALITY_WILL	= "%s will eat this.";
FOM_QUALITY_LIKE	= "%s likes to eat this.";
FOM_QUALITY_LOVE	= "%s loves to eat this.";

-- User-visible errors
FOM_ERROR_NO_PET		= "You don't have a pet to feed.";
FOM_ERROR_PET_DEAD		= "Your pet is dead.";
FOM_ERROR_NO_FEEDABLE_PET	= "You don't have a feedable pet.";
FOM_ERROR_IN_COMBAT	= "You can't feed your pet during combat.";
FOM_ERROR_FOOD_NOT_FOUND	= "%s could not find %s in your pack.";
FOM_ERROR_NO_FOOD		= "%s could not find any food in your pack.";
FOM_ERROR_NO_FOOD_NO_FALLBACK	= "%s could not find any food in your pack that you haven't forbidden %s to eat.";

FOM_PRONOUN_MALE 	= "him";
FOM_PRONOUN_FEMALE	= "her";

-- Feeding status messages
FOM_FEEDING_EAT_ANOTHER		= "%s doesn't like that food and will try something else...";
FOM_FEEDING_FEED_ANOTHER	= "needs to feed %s something else...";
FOM_FEEDING_EAT			= "%s eats a %s from your pack."; 
FOM_FEEDING_FEED		= "feeds %s a %s. ";

FOM_PET_HUNGRY		= "%s is hungry!";
FOM_PET_VERY_HUNGRY	= "%s is very hungry!";

-- Beast family names
BAT = "Bat";
BEAR = "Bear";
BOAR = "Boar";
CARRION_BIRD = "Carrion Bird";
CAT = "Cat";
CRAB = "Crab";
CROCOLISK = "Crocolisk";
GORILLA = "Gorilla";
HYENA = "Hyena";
OWL = "Owl";
RAPTOR = "Raptor";
SCORPID = "Scorpid";
SPIDER = "Spider";
TALLSTRIDER = "Tallstrider";
TURTLE = "Turtle";
WIND_SERPENT = "Wind Serpent";
WOLF = "Wolf";

FOM_OPTIONS_HEADER = "Feed-O-Matic Options";
FOM_OPTIONS_GENERAL = "General options:";
FOM_OPTIONS_FOOD_CHOICE = "Avoid foods used in Cooking:";
FOM_OPTIONS_FEED_NOTIFY = "Notify when feeding:";
FOM_OPTIONS_WARNING = "Warn that your pet needs feeding:";

FOM_KEEPOPEN = "Try to keep at least";
FOM_KEEPOPEN_SLOTS = "slots open in your bags.";
FOM_KEEPOPEN_INFO = "(Will choose foods from smaller stacks when low on space, regardless of how well your pet likes them.)";

FOM_OptionsButtonText = {
	["Tooltip"]	= "Show your pet's opinion of foods in their tooltips",
	["AvoidQuestFood"]	= "Avoid foods needed for quests",
	["AvoidBonusFood"]	= "Avoid foods that have a bonus effect when eaten",
	["PreferHigherQuality"]	= "Prefer foods your pet likes more",
	["Fallback"]	= "Fall back to otherwise-avoided foods if out of others",
	["SaveForCook_All"]	= "all foods used in cooking",
	["SaveForCook_Green"]	= "only foods used in |cff3fbf3f\"easy\"|r or better recipes",
	["SaveForCook_Yellow"]	= "only foods used in |cffffff00\"medium\"|r or better recipes",
	["SaveForCook_Orange"]	= "only foods used in |cffff7f3f\"difficult\"|r recipes",
	["SaveForCook_None"]	= "Don't save foods used in cooking",
	["IconWarning"]	= "Flash icon",
	["TextWarning"]	= "Show text",
	["AudioWarning"]	= "Play sound",
	["AudioWarningBell"]	= "Generic bell sound instead of pet-specific",
	["AlertEmote"]	= "Via emote (seen by others)",
	["AlertChat"]	= "In the chat window (seen by you only)",
	["AlertNone"]	= "Don't notify",
	["LevelContent"]	= "when \"content\"",
	["LevelUnhappy"]	= "when \"unhappy\"",
	["LevelOff"]	= "Don't warn",
};
------------------------------------------------------

if (GetLocale() == "deDE") then

-- Diet names. These should be the all-lowercase versions of the six diets returned from GetPetFoodTypes(). (Want to get them all nice and quick for your localization? Go tame a bear... they eat anything.)
-- THESE STRINGS MUST BE LOCALIZED for Feed-O-Matic to work properly in other locales.
	FOM_DIET_MEAT	= "fleisch";
	FOM_DIET_FISH	= "fisch";
	FOM_DIET_BREAD	= "brot";
	FOM_DIET_CHEESE = "käse";
	FOM_DIET_FRUIT	= "obst";
--	FOM_DIET_FUNGUS = "fungus";	-- same as English (?), so we don't need to re-define it.

	-- If the player has a buff whose icon name contains "Ability_Mount" and whose name contains one of these substrings, we assume the player is mounted. We have to use this rather oblique way to check for mounted because some other buffs use the Ability_Mount_* icons. If these aren't localized, we may not recognize when the player is mounted and still try to feed the pet.
--	FOM_MOUNT_NAME_SUBSTRINGS = { "kodo", "wolf", "raptor", "steed", "horse", "ram", "saber", "mechanostrider" };

	-- It's not clear whether the 5th and 6th returns from GetItemInfo() are supposed to be localized... so we have localized keys for them just in case.
	FOM_AMMO_POUCH = "Munitionsbeutel";
	FOM_QUIVER = "Köcher";
	
-- From here on down, the localized strings are just for readability; they don't affect whether Feed-O-Matic works.

	-- Two special diets; one is used for tracking food that provides a bonus (or at least, that you don't want to have fed to your pet when the 'savebonus' option is on), and another that's used in the chat-line interface for listing all diets.
--	FOM_DIET_BONUS	= "bonus";	-- same as English(?), so we don't need to re-define it.
	FOM_DIET_ALL	= "alles";

	-- Used in tooltips to indicate food quality.
	FOM_QUALITY_UNKNOWN = "%s kann das fressen, hat es aber noch nicht probiert.";
	FOM_QUALITY_UNDER = "%s mag das nicht mehr fressen.";
	FOM_QUALITY_MIGHT = "%s mag das möglicherweise fressen.";
	FOM_QUALITY_WILL = "%s mag das fressen.";
	FOM_QUALITY_LIKE = "%s frisst das gerne.";
	FOM_QUALITY_LOVE = "%s liebt es, das zu fressen.";

	-- User-visible errors
	FOM_ERROR_NO_PET  = "Du hast kein Tier um es zu füttern.";
	FOM_ERROR_PET_DEAD  = "Dein Tier ist tot.";
	FOM_ERROR_NO_FEEDABLE_PET = "Du hast kein Tier das man füttern kann.";
	FOM_ERROR_FOOD_NOT_FOUND = "%s kann %s nicht in Deinem Rucksack finden.";
	FOM_ERROR_NO_FOOD  = "%s findet nichts zu fressen in Deinem Rucksack.";

	-- Feeding status messages
	FOM_FEEDING_EAT_ANOTHER  = "%s mag dieses Futter nicht und probiert etwas anderes...";
	FOM_FEEDING_FEED_ANOTHER = "sucht nach etwas anderem um  %s zu füttern...";
	FOM_FEEDING_EAT   = "%s frisst ein %s aus Deinem Rucksack."; 
	FOM_FEEDING_FEED  = "füttert %s ein %s. ";
	
	-- Beast family names
	BAT = "Fledermaus";
	BEAR = "Bär";
	BOAR = "Eber";
	CARRION_BIRD = "Aasvogel";
	CAT = "Katze";
	CRAB = "Krebs";
	CROCOLISK = "Krokilisk";
--	GORILLA = "Gorilla";		-- same as enUS
	HYENA = "Hyäne";
	OWL = "Eule";
--	RAPTOR = "Raptor";		-- same as enUS
	SCORPID = "Skorpid";
	SPIDER = "Spinne";
	TALLSTRIDER = "Weitschreiter";
	TURTLE = "Schildkröte";
	WIND_SERPENT = "Windnatter";
--	WOLF = "Wolf";		-- same as enUS

end