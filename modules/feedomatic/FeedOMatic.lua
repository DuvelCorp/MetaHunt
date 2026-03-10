------------------------------------------------------
-- FeedOMatic.lua
------------------------------------------------------
FOM_VERSION = "11200.2";
------------------------------------------------------

-- constants
FOM_WARNING_INTERVAL = 10; -- don't warn more than once per this many seconds
MAX_QUALITY = 35 * 60 + 1; -- We store a notion of a food's "quality": its best happiness-per-tick multiplied by the pet's level as of when that tick occurred. We use "best" because a pet that's closer to "sated" (maximum happiness) will receive less happiness per tick than he would from the same food if he were hungrier. (So, a food that gives 35 happiness per tick to a level 60 pet is "better" than a food that's worth 35 happiness per tick to a level 30 pet.) Foods whose quality hasn't been observed yet are given this value when sorting, so we can prioritize the discovery of new foods' quality ratings.
MAX_KEEPOPEN_SLOTS = 150;

-- Configuration
FOM_Config_Default = {
	Enabled = false;
	Alert = "emote";
	Level = "content";
	KeepOpenSlots = 8;
	AvoidUsefulFood = true;
	AvoidQuestFood = true;
	AvoidBonusFood = true;
	Fallback = false;
	SaveForCookingLevel = 1;
	PreferHigherQuality = true;
};
FOM_Config = FOM_Config_Default;

-- FOM_Cooking = { };
-- Has the following internal structure:
--		REALM_PLAYER = {
--			FOODNAME = SKILL_DIFFICULTY,
--		}

-- FOM_QuestFood = { };
-- Has the following internal structure:
--		REALM_PLAYER = {
--			FOODNAME = QUANTITY_REQUIRED,
--		}

-- FOM_FoodQuality = { };
-- Has the following internal structure:
--		REALM_PLAYER = {
--			PETNAME = {
--				FOODNAME = HAPPINESS,
--			}
--		}

-- Variables
FOM_State = { };
FOM_State.InCombat = false;
FOM_State.IsAFK = false;
FOM_State.ShouldFeed = false;
FOM_LastWarning = 0;

FOM_LastFood = nil;
FOM_LastChoiceReason = nil;
FOM_RealmPlayer = nil;
FOM_LastPetName = nil;
FOM_LastFeedAttempt = nil;
FOM_TRACE_ENABLED = false;
local FOM_CORE_ATTEMPT_TRACKING_ENABLED = false;
local FOM_PERF_TRACE_ENABLED = false;
local FOM_PERF_TRACE_HISTORY_LIMIT = 80;
local FOM_PERF_TRACE_SPIKE_MS = 12;
local FOM_PERF_TRACE_HISTORY = {};
local FOM_LAST_SETUP_AT = 0;
local FOM_LAST_SETUP_PET = nil;
local FOM_LAST_QUEST_SCAN_AT = 0;
local FOM_TEMP_FOOD_CACHE = {};
local FOM_FEED_SCAN_CACHE = nil;
local FOM_FEED_SCAN_CACHE_TTL = 5.0;
local FOM_LAST_AUTO_CHOICE = nil;
local FOM_LAST_AUTO_CHOICE_TTL = 2.0;

local FOM_REQUIRE_KNOWN_LEVEL_PET_LEVEL = 60;
local FOM_MAX_RETRIES_PER_REQUEST = 2;
local FOM_UNKNOWN_QUALITY_FOR_DESC = -1;
local FOM_UNKNOWN_QUALITY_FOR_ASC = MAX_QUALITY + 1;
local FOM_SERVER_PROFILE = "turtle";
local FOM_ServerProfiles = {
	turtle = {
		itemMaxPetLevel = {
			[12037] = 44,
		},
		itemFoodLevel = {
			[8952] = 45,
			[12208] = 35,
		},
	},
};

-- Anti-freeze code borrowed from ReagentInfo (in turn, from Quest-I-On):
-- keeps WoW from locking up if we try to scan the tradeskill window too fast.
FOM_TradeSkillLock = { };
FOM_TradeSkillLock.Locked = false;
FOM_TradeSkillLock.EventTimer = 0;
FOM_TradeSkillLock.EventCooldown = 0;
FOM_TradeSkillLock.EventCooldownTime = 1;


-- State variable used to track required quantities of quest food when it's in more than one stack
FOM_Quantity = { };

-- Remember how item IDs map to food names at runtime, but don't bloat long-term memory with it...
FOM_FoodIDsToNames = {};

FOM_FamilyAliasMap = nil;
FOM_DietByItemID = nil;
FOM_FamilyToLegacyMap = {
	["Bats"] = BAT,
	["Bears"] = BEAR,
	["Boars"] = BOAR,
	["Carrion Birds"] = CARRION_BIRD,
	["Cats"] = CAT,
	["Crabs"] = CRAB,
	["Crocolisks"] = CROCOLISK,
	["Gorillas"] = GORILLA,
	["Hyenas"] = HYENA,
	["Owls"] = OWL,
	["Raptors"] = RAPTOR,
	["Scorpids"] = SCORPID,
	["Spiders"] = SPIDER,
	["Tallstriders"] = TALLSTRIDER,
	["Turtles"] = TURTLE,
	["Wind Serpents"] = WIND_SERPENT,
	["Wolves"] = WOLF,
};

local function FOM_Trace(message)
	return;
end

local function FOM_PerfNowMs()
	if (type(debugprofilestop) == "function") then
		local raw = tonumber(debugprofilestop()) or 0;
		return raw / 1000;
	end
	if (type(GetTime) == "function") then
		return (tonumber(GetTime()) or 0) * 1000;
	end
	return 0;
end

local function FOM_PerfOut(message, forceShow)
	local text = tostring(message or "");
	if (text == "") then
		return;
	end
	if (type(MTH_DebugFrame) == "table" and type(MTH_DebugFrame.AddInfo) == "function") then
		if (forceShow and type(MTH_DebugFrame.Show) == "function") then
			MTH_DebugFrame:Show();
		end
		MTH_DebugFrame:AddInfo(text);
		return;
	end
	if (MTH and type(MTH.Print) == "function") then
		MTH:Print(text, "debug");
		return;
	end
	if (type(GFWUtils) == "table" and type(GFWUtils.Print) == "function") then
		GFWUtils.Print(text);
	end
end

local function FOM_PerfRecord(label, elapsedMs, detail, forcePrint)
	if (not FOM_PERF_TRACE_ENABLED) then
		return;
	end
	local numericElapsed = tonumber(elapsedMs) or 0;
	if (numericElapsed > 10000) then
		numericElapsed = numericElapsed / 1000;
	end
	local row = {
		ts = time and time() or 0,
		label = tostring(label or "unknown"),
		ms = numericElapsed,
		detail = tostring(detail or ""),
	};
	table.insert(FOM_PERF_TRACE_HISTORY, row);
	if (table.getn(FOM_PERF_TRACE_HISTORY) > FOM_PERF_TRACE_HISTORY_LIMIT) then
		table.remove(FOM_PERF_TRACE_HISTORY, 1);
	end
	return;
end

local function FOM_PerfDump()
	if (table.getn(FOM_PERF_TRACE_HISTORY) <= 0) then
		FOM_PerfOut("[FOM PERF] no samples.", true);
		return;
	end
	FOM_PerfOut("[FOM PERF] recent samples: " .. tostring(table.getn(FOM_PERF_TRACE_HISTORY)), true);
	for i = 1, table.getn(FOM_PERF_TRACE_HISTORY) do
		local row = FOM_PERF_TRACE_HISTORY[i];
		if (type(row) == "table") then
			FOM_PerfOut("[FOM PERF] #" .. tostring(i)
				.. " " .. tostring(row.label)
				.. " " .. string.format("%.2f", tonumber(row.ms) or 0) .. "ms"
				.. (tostring(row.detail or "") ~= "" and (" | " .. tostring(row.detail)) or ""), false);
		end
	end
end

local function FOM_GetServerProfile()
	return FOM_ServerProfiles[FOM_SERVER_PROFILE] or {};
end

local function FOM_EnsureQuarantineStore()
	if (type(MTH_CharSavedVariables) == "table") then
		if (type(MTH_CharSavedVariables.feedTracking) ~= "table") then
			MTH_CharSavedVariables.feedTracking = {};
		end
		local feedStore = MTH_CharSavedVariables.feedTracking;
		if (type(feedStore.fomQuarantine) ~= "table") then
			feedStore.fomQuarantine = {};
		end
		if (type(feedStore.fomQuarantine.byFamily) ~= "table") then
			feedStore.fomQuarantine.byFamily = {};
		end

		if (type(FOM_Quarantine) == "table" and type(FOM_Quarantine.byFamily) == "table") then
			for family, byItem in FOM_Quarantine.byFamily do
				if (type(byItem) == "table") then
					if (type(feedStore.fomQuarantine.byFamily[family]) ~= "table") then
						feedStore.fomQuarantine.byFamily[family] = {};
					end
					for itemId, row in byItem do
						if (type(row) == "table") then
							feedStore.fomQuarantine.byFamily[family][itemId] = row;
						end
					end
				end
			end
			FOM_Quarantine = nil;
		end

		return feedStore.fomQuarantine;
	end

	if (type(FOM_Quarantine) ~= "table") then
		FOM_Quarantine = {};
	end
	if (type(FOM_Quarantine.byFamily) ~= "table") then
		FOM_Quarantine.byFamily = {};
	end
	return FOM_Quarantine;
end

local function FOM_GetFamilyKeyFromInfo(petInfo)
	local family = nil;
	if (type(petInfo) == "table") then
		family = petInfo.family;
	end
	if (family == nil or family == "") then
		family = UnitCreatureFamily("pet");
	end
	family = FOM_GetCanonicalPetFamily(family);
	if (family == nil or family == "") then
		return "unknown";
	end
	return tostring(family);
end

local function FOM_RegisterNoBuffQuarantine(itemID, petInfo)
	local numericItem = tonumber(itemID);
	if (numericItem == nil) then
		return;
	end
	local petLevel = tonumber(petInfo and petInfo.level) or tonumber(UnitLevel("pet")) or 0;
	if (petLevel <= 0) then
		return;
	end
	local familyKey = FOM_GetFamilyKeyFromInfo(petInfo);
	local store = FOM_EnsureQuarantineStore();
	if (type(store.byFamily[familyKey]) ~= "table") then
		store.byFamily[familyKey] = {};
	end
	local byItem = store.byFamily[familyKey];
	if (type(byItem[numericItem]) ~= "table") then
		byItem[numericItem] = {
			minRejectPetLevel = petLevel,
			lastObservedAt = 0,
			reason = "no-buff",
		};
	end
	local row = byItem[numericItem];
	local currentMin = tonumber(row.minRejectPetLevel);
	if (currentMin == nil or petLevel < currentMin) then
		row.minRejectPetLevel = petLevel;
	end
	row.lastObservedAt = time and time() or 0;
	row.reason = "no-buff";
	FOM_Trace("quarantine add family='" .. tostring(familyKey)
		.. "' itemId=" .. tostring(numericItem)
		.. " minRejectPetLevel=" .. tostring(row.minRejectPetLevel));
end

local function FOM_IsQuarantined(itemID, petLevel, familyKey)
	local numericItem = tonumber(itemID);
	local numericPet = tonumber(petLevel);
	if (numericItem == nil or numericPet == nil or numericPet <= 0) then
		return false;
	end
	local store = FOM_EnsureQuarantineStore();
	local key = tostring(familyKey or "unknown");
	local familyTable = store.byFamily[key];
	if (type(familyTable) ~= "table") then
		return false;
	end
	local row = familyTable[numericItem];
	if (type(row) ~= "table") then
		return false;
	end
	local minReject = tonumber(row.minRejectPetLevel);
	if (minReject == nil) then
		return false;
	end
	return numericPet >= minReject;
end

local function FOM_GetFoodLevelOverride(itemID)
	local numericItem = tonumber(itemID);
	if (numericItem == nil) then
		return nil;
	end
	local profile = FOM_GetServerProfile();
	if (type(profile.itemFoodLevel) ~= "table") then
		return nil;
	end
	local override = tonumber(profile.itemFoodLevel[numericItem]);
	return override;
end

local function FOM_IsItemPetLevelCompatible(itemID, petLevel)
	local numericItem = tonumber(itemID);
	local numericPet = tonumber(petLevel);
	if (numericItem == nil or numericPet == nil) then
		return true;
	end
	local profile = FOM_GetServerProfile();
	local maxPetLevel = nil;
	if (type(profile.itemMaxPetLevel) == "table") then
		maxPetLevel = tonumber(profile.itemMaxPetLevel[numericItem]);
	end
	if (maxPetLevel ~= nil and numericPet > maxPetLevel) then
		return false;
	end
	return true;
end

function FOM_CommandTrace(mode)
	local arg = string.lower(tostring(mode or ""));
	if (arg == "perf on") then
		FOM_PERF_TRACE_ENABLED = true;
		FOM_PerfOut("[FOM PERF] enabled.", true);
		return;
	end
	if (arg == "perf off") then
		FOM_PERF_TRACE_ENABLED = false;
		FOM_PerfOut("[FOM PERF] disabled.", true);
		return;
	end
	if (arg == "perf clear") then
		FOM_PERF_TRACE_HISTORY = {};
		FOM_PerfOut("[FOM PERF] cleared.", true);
		return;
	end
	if (arg == "perf dump") then
		FOM_PerfDump();
		return;
	end
	FOM_PerfOut("Usage: /fomtrace perf on|off|dump|clear", true);
end

local function FOM_CoreFeedReady()
	if (not FOM_CORE_ATTEMPT_TRACKING_ENABLED) then
		return false;
	end
	return type(MTH_FEED_BeginAttempt) == "function" and type(MTH_FEED_FinalizeAttempt) == "function";
end

local function FOM_CoreBeginAttempt(payload)
	if (not FOM_CoreFeedReady()) then
		return nil;
	end
	local ok, attemptId = pcall(MTH_FEED_BeginAttempt, payload);
	if (ok) then
		return attemptId;
	end
	return nil;
end

local function FOM_CoreRecordReject(attemptId, reason, rawMessage)
	if (attemptId == nil or type(MTH_FEED_RecordRejectEvent) ~= "function") then
		return;
	end
	pcall(MTH_FEED_RecordRejectEvent, attemptId, {
		reason = reason,
		rawMessage = rawMessage,
	});
end

local function FOM_CoreFinalizeAttempt(attemptId, outcome, reason)
	if (attemptId == nil or type(MTH_FEED_FinalizeAttempt) ~= "function") then
		return;
	end
	pcall(MTH_FEED_FinalizeAttempt, attemptId, {
		outcome = outcome,
		reason = reason,
	});
end

function FOM_NormalizeFamilyName(name)
	if (name == nil or name == "") then
		return nil;
	end
	local normalized = string.lower(name);
	normalized = string.gsub(normalized, "%b()", "");
	normalized = string.gsub(normalized, "[^%a]", "");
	if (normalized == "") then
		return nil;
	end
	return normalized;
end

function FOM_AddFamilyAlias(aliasName, canonicalName)
	local aliasKey = FOM_NormalizeFamilyName(aliasName);
	if (aliasKey ~= nil and canonicalName ~= nil and canonicalName ~= "") then
		FOM_FamilyAliasMap[aliasKey] = canonicalName;
	end
end

function FOM_BuildFamilyAliasMap()
	if (FOM_FamilyAliasMap ~= nil) then
		return;
	end
	FOM_FamilyAliasMap = {};
	if (MTH_DS_Families == nil) then
		return;
	end

	for canonicalName, _ in MTH_DS_Families do
		if (type(canonicalName) == "string") then
			local singularName = string.gsub(canonicalName, "%s*%b()", "");
			if (string.sub(singularName, -3) == "ies") then
				singularName = string.sub(singularName, 1, string.len(singularName) - 3) .. "y";
			elseif (string.sub(singularName, -2) == "es") then
				singularName = string.sub(singularName, 1, string.len(singularName) - 2);
			elseif (string.sub(singularName, -1) == "s") then
				singularName = string.sub(singularName, 1, string.len(singularName) - 1);
			end
			FOM_AddFamilyAlias(canonicalName, canonicalName);
			FOM_AddFamilyAlias(singularName, canonicalName);
		end
	end

	FOM_AddFamilyAlias("Carrion Bird", "Carrion Birds");
	FOM_AddFamilyAlias("Wind Serpent", "Wind Serpents");
	FOM_AddFamilyAlias("Serpent", "Serpents (Cobra)");
end

function FOM_GetCanonicalPetFamily(rawFamily)
	if (rawFamily == nil or rawFamily == "") then
		rawFamily = UnitCreatureFamily("pet");
	end
	if (rawFamily == nil or rawFamily == "") then
		return nil;
	end
	if (MTH_DS_Families and MTH_DS_Families[rawFamily]) then
		return rawFamily;
	end

	FOM_BuildFamilyAliasMap();
	if (FOM_FamilyAliasMap ~= nil) then
		local aliasKey = FOM_NormalizeFamilyName(rawFamily);
		if (aliasKey and FOM_FamilyAliasMap[aliasKey]) then
			return FOM_FamilyAliasMap[aliasKey];
		end
	end

	return rawFamily;
end

function FOM_GetLegacyFamilyKey(rawFamily)
	local canonicalFamily = FOM_GetCanonicalPetFamily(rawFamily);
	if (canonicalFamily == nil) then
		return rawFamily;
	end
	if (FOM_FamilyToLegacyMap[canonicalFamily] ~= nil) then
		return FOM_FamilyToLegacyMap[canonicalFamily];
	end
	return rawFamily;
end

function FOM_NormalizeDietToken(diet)
	if (diet == nil or diet == "") then
		return nil;
	end
	local lowerDiet = string.lower(diet);
	if (lowerDiet == "meat" or lowerDiet == string.lower(FOM_DIET_MEAT)) then return FOM_DIET_MEAT; end
	if (lowerDiet == "fish" or lowerDiet == string.lower(FOM_DIET_FISH)) then return FOM_DIET_FISH; end
	if (lowerDiet == "bread" or lowerDiet == string.lower(FOM_DIET_BREAD)) then return FOM_DIET_BREAD; end
	if (lowerDiet == "cheese" or lowerDiet == string.lower(FOM_DIET_CHEESE)) then return FOM_DIET_CHEESE; end
	if (lowerDiet == "fruit" or lowerDiet == string.lower(FOM_DIET_FRUIT)) then return FOM_DIET_FRUIT; end
	if (lowerDiet == "fungus" or lowerDiet == string.lower(FOM_DIET_FUNGUS)) then return FOM_DIET_FUNGUS; end
	if (lowerDiet == string.lower(FOM_DIET_BONUS)) then return FOM_DIET_BONUS; end
	if (lowerDiet == string.lower(FOM_DIET_ALL)) then return FOM_DIET_ALL; end
	return lowerDiet;
end

function FOM_GetPetDietList(rawFamily)
	local canonicalFamily = FOM_GetCanonicalPetFamily(rawFamily);
	if (canonicalFamily and MTH_DS_Families and MTH_DS_Families[canonicalFamily]) then
		local familyRow = MTH_DS_Families[canonicalFamily];
		if (familyRow and type(familyRow.food) == "table" and table.getn(familyRow.food) > 0) then
			local dbDiets = {};
			for _, dietName in familyRow.food do
				local normalizedDiet = FOM_NormalizeDietToken(dietName);
				if (normalizedDiet ~= nil) then
					table.insert(dbDiets, normalizedDiet);
				end
			end
			if (table.getn(dbDiets) > 0) then
				return dbDiets;
			end
		end
	end

	-- Keep live API fallback: some edge cases can fail family mapping at runtime,
	-- and returning nil here causes false "no feedable pet" behavior on keybind use.
	local liveDiets = {GetPetFoodTypes()};
	if (liveDiets == nil) then
		return nil;
	end
	for index, dietName in liveDiets do
		liveDiets[index] = FOM_NormalizeDietToken(dietName);
	end
	return liveDiets;
end

local function FOM_BuildDietByItemIDMap()
	if (FOM_DietByItemID ~= nil) then
		return FOM_DietByItemID;
	end

	FOM_DietByItemID = {};
	if (type(FOM_Foods) ~= "table") then
		return FOM_DietByItemID;
	end

	for dietName, dietItems in FOM_Foods do
		if (type(dietItems) == "table") then
			for _, itemID in dietItems do
				local numericItemID = tonumber(itemID);
				if (numericItemID ~= nil) then
					FOM_DietByItemID[numericItemID] = dietName;
				end
			end
		end
	end

	return FOM_DietByItemID;
end

local function FOM_GetItemIDFromLink(itemLink)
	if (itemLink == nil or itemLink == "") then
		return nil;
	end

	local _, _, itemID = string.find(itemLink, "Hitem:(%d+)");
	if (itemID ~= nil) then
		return tonumber(itemID);
	end

	local _, _, legacyItemID = string.find(itemLink, "Hitem:((%d+).-)");
	if (legacyItemID ~= nil) then
		return tonumber(legacyItemID);
	end

	return nil;
end

local FOM_UnknownNoisePrunedThisSession = false;

local function FOM_IsConsumableItem(itemID)
	local numericItemID = tonumber(itemID);
	if (numericItemID == nil or type(GetItemInfo) ~= "function") then
		return nil;
	end
	local _, _, _, _, _, itemType = GetItemInfo(numericItemID);
	if (itemType == nil or itemType == "") then
		return nil;
	end
	local itemTypeLower = string.lower(tostring(itemType));
	local consumableLabel = (type(_G) == "table" and _G["ITEM_CLASS_CONSUMABLE"]) or "Consumable";
	local consumableLower = string.lower(tostring(consumableLabel));
	return itemTypeLower == consumableLower;
end

local function FOM_PruneUnknownFoodNoise(force)
	if (FOM_UnknownNoisePrunedThisSession and not force) then
		return 0;
	end
	FOM_UnknownNoisePrunedThisSession = true;

	if (type(MTH_FEED_GetStore) ~= "function") then
		return 0;
	end
	local store = MTH_FEED_GetStore();
	local byItemId = store and store.unknownFoods and store.unknownFoods.byItemId or nil;
	if (type(byItemId) ~= "table") then
		return 0;
	end

	local dietByItemID = FOM_BuildDietByItemIDMap();
	local removed = 0;
	for itemKey, row in byItemId do
		local numericItemID = tonumber(itemKey);
		local knownDietItem = (numericItemID ~= nil and dietByItemID[numericItemID] ~= nil) and true or false;
		local resolvedFood = (type(row) == "table" and type(row.resolved) == "table" and tonumber(row.resolved.foodLevel) ~= nil) and true or false;
		local confirmedFood = (type(row) == "table" and tostring(row.state or "") == "confirmed-food") and true or false;
		local consumableState = FOM_IsConsumableItem(numericItemID);
		local likelyNonConsumable = (consumableState == false);
		local hasNonVendorSource = false;
		if (type(row) == "table" and type(row.sources) == "table") then
			for _, source in row.sources do
				if (tostring(source or "") ~= "vendor-scan") then
					hasNonVendorSource = true;
					break;
				end
			end
		end

		if (not knownDietItem and not resolvedFood and not confirmedFood and (not hasNonVendorSource or likelyNonConsumable)) then
			byItemId[itemKey] = nil;
			removed = removed + 1;
		end
	end

	if (removed > 0 and store ~= nil) then
		if (type(time) == "function") then
			store.updatedAt = time();
		end
		FOM_Trace("pruned unknown vendor-only non-food rows=" .. tostring(removed));
	end

	return removed;
end

local function FOM_IsExceptionRowActive(row)
	if (type(row) ~= "table") then
		return false;
	end
	if (tonumber(row.blockAtOrAbovePetLevel) ~= nil) then
		return true;
	end
	if (tonumber(row.maxPetLevel) ~= nil) then
		return true;
	end
	local reasons = row.reasons;
	if (type(reasons) == "table") then
		if ((tonumber(reasons.noBuff) or 0) > 0) then return true; end
		if ((tonumber(reasons.lowLevel) or 0) > 0) then return true; end
		if ((tonumber(reasons.wrongFood) or 0) > 0) then return true; end
		if ((tonumber(reasons.unknown) or 0) > 0) then return true; end
	end
	return false;
end

local function FOM_PruneExceptionNoise()
	if (type(MTH_FEED_GetStore) ~= "function") then
		return 0;
	end
	local store = MTH_FEED_GetStore();
	local byItemId = store and store.exceptions and store.exceptions.byItemId or nil;
	if (type(byItemId) ~= "table") then
		return 0;
	end

	local removed = 0;
	for itemKey, row in byItemId do
		if (not FOM_IsExceptionRowActive(row)) then
			byItemId[itemKey] = nil;
			removed = removed + 1;
		end
	end

	if (removed > 0 and store ~= nil and type(time) == "function") then
		store.updatedAt = time();
		FOM_Trace("pruned inert exception rows=" .. tostring(removed));
	end
	return removed;
end

function FOM_PruneCollectedFoodData()
	local removedUnknown = tonumber(FOM_PruneUnknownFoodNoise(true)) or 0;
	local removedExceptions = tonumber(FOM_PruneExceptionNoise()) or 0;
	return removedUnknown + removedExceptions;
end

function MTH_GetMerchantFoodsByDiet()
	local result = {
		byDiet = {},
		items = {},
		unknown = {},
	};

	if (type(GetMerchantNumItems) ~= "function") then
		return result;
	end

	local itemCount = GetMerchantNumItems() or 0;
	if (itemCount <= 0) then
		return result;
	end

	local dietByItemID = FOM_BuildDietByItemIDMap();
	for index = 1, itemCount do
		local itemName, _, itemPrice, itemStackCount, itemNumAvailable = GetMerchantItemInfo(index);
		local itemLink = GetMerchantItemLink(index);
		local itemID = FOM_GetItemIDFromLink(itemLink);
		if (itemID ~= nil) then
			local dietName = dietByItemID[itemID];
			local foodRow = {
				index = index,
				id = itemID,
				name = itemName,
				link = itemLink,
				diet = dietName,
				price = itemPrice,
				stack = itemStackCount,
				available = itemNumAvailable,
			};

			if (dietName ~= nil) then
				if (result.byDiet[dietName] == nil) then
					result.byDiet[dietName] = {};
				end
				table.insert(result.byDiet[dietName], foodRow);
				table.insert(result.items, foodRow);
			else
				table.insert(result.unknown, foodRow);
			end
		end
	end

	return result;
end

local function FOM_DebugLog(message)
	return;
end

local function FOM_DebugLogMerchantFoods(sourceEvent)
	local merchantFoods = MTH_GetMerchantFoodsByDiet();
	local eventLabel = tostring(sourceEvent or "MERCHANT");
	if (merchantFoods == nil) then
		FOM_DebugLog(eventLabel .. ": no merchant data available.");
		return;
	end

	local knownCount = table.getn(merchantFoods.items or {});
	local unknownCount = table.getn(merchantFoods.unknown or {});
	local merchantName = UnitName("npc") or UnitName("target") or "unknown";

	FOM_DebugLog(eventLabel .. ": " .. tostring(merchantName) .. " | known foods=" .. tostring(knownCount) .. " | unknown items=" .. tostring(unknownCount));

	if (type(merchantFoods.byDiet) == "table") then
		for dietName, foodRows in merchantFoods.byDiet do
			local dietCount = table.getn(foodRows or {});
			FOM_DebugLog("diet " .. tostring(dietName) .. ": " .. tostring(dietCount) .. " item(s)");
			for _, row in foodRows do
				FOM_DebugLog("  - [" .. tostring(row.id) .. "] " .. tostring(row.name) .. " (merchantIndex=" .. tostring(row.index) .. ")");
			end
		end
	end

	if (unknownCount > 0) then
		for _, row in merchantFoods.unknown do
			FOM_DebugLog("unknown food map: [" .. tostring(row.id) .. "] " .. tostring(row.name) .. " (merchantIndex=" .. tostring(row.index) .. ")");
		end
	end
end

function MTH_FOM_FeedButton_OnClick()
	if (arg1 == "RightButton") then
		if (MTH_OpenOptions) then
			MTH_OpenOptions("FeedOMatic");
		end
	else
		FOM_Feed();
	end
end

function MTH_FOM_FeedButton_OnEnter()
	if ( PetFrameHappiness.tooltip ) then
		GameTooltip:SetOwner(PetFrameHappiness, "ANCHOR_RIGHT");
		GameTooltip:SetText(PetFrameHappiness.tooltip);
		if ( PetFrameHappiness.tooltipDamage ) then
			GameTooltip:AddLine(PetFrameHappiness.tooltipDamage, "", 1, 1, 1);
		end
		if ( PetFrameHappiness.tooltipLoyalty ) then
			GameTooltip:AddLine(PetFrameHappiness.tooltipLoyalty, "", 1, 1, 1);
		end
		if (FOM_LastChoiceReason ~= nil and FOM_LastChoiceReason ~= "") then
			GameTooltip:AddLine("Feed-O-Matic: " .. FOM_LastChoiceReason, 0.6, 0.9, 1.0);
		end
		GameTooltip:Show();
	end
end

function MTH_FOM_FeedButton_OnLeave()
	GameTooltip:Hide();
end

function FOM_OnLoad()

	-- Register for Events
	if (not MTH_FEED_WRAPPER_MODE) then
		this:RegisterEvent("VARIABLES_LOADED");
	end

	-- Register Slash Commands
	SLASH_FEEDOMATIC1 = "/feedomatic";
	SLASH_FEEDOMATIC2 = "/fom";
	SLASH_FEEDOMATIC3 = "/feed";
	SLASH_FEEDOMATIC4 = "/petfeed"; -- Rauen's PetFeed compatibility
	SLASH_FEEDOMATIC5 = "/pf";
	SLASH_FOMTRACE1 = "/fomtrace";
	SlashCmdList["FOMTRACE"] = function(msg)
		FOM_CommandTrace(msg);
	end
	SlashCmdList["FEEDOMATIC"] = function(msg)
		if MTH_IsModuleEnabled and not MTH_IsModuleEnabled("feedomatic", false) then
			if DEFAULT_CHAT_FRAME and DEFAULT_CHAT_FRAME.AddMessage then
				MTH:Print("Feed-O-Matic is disabled while module 'feedomatic' is disabled.")
			end
			return
		end
		FOM_ChatCommandHandler(msg);
	end
	
	-- hook functions so we can manage per-pet saved food quality data
	if (MTH_PETL_Original_PetAbandon == nil) then
		MTH_PETL_Original_PetAbandon = PetAbandon;
	end
	FOM_Original_PetAbandon = MTH_PETL_Original_PetAbandon;

	if (not MTH_FEED_WRAPPER_MODE) then
		PetAbandon = MTH_PetAbandonHook;
	end
	
	--GFWUtils.Debug = true;

end

function MTH_FOM_GetCorePetInfo()
	if (type(MTH_GetCurrentPetInfo) == "function") then
		local info = MTH_GetCurrentPetInfo();
		if (type(info) == "table") then
			return info;
		end
	end

	local info = {
		exists = false,
		liveExists = false,
		dead = false,
		name = nil,
		level = nil,
		happiness = nil,
		loyalty = nil,
		health = nil,
		healthMax = nil,
	};

	info.liveExists = (type(UnitExists) == "function" and UnitExists("pet")) and true or false;
	info.exists = info.liveExists;
	if (type(UnitName) == "function") then
		info.name = UnitName("pet");
	end
	if (type(UnitLevel) == "function") then
		info.level = tonumber(UnitLevel("pet"));
	end
	if (type(UnitHealth) == "function") then
		info.health = tonumber(UnitHealth("pet"));
	end
	if (type(UnitHealthMax) == "function") then
		info.healthMax = tonumber(UnitHealthMax("pet"));
	end
	if (type(UnitIsDead) == "function") then
		info.dead = UnitIsDead("pet") and true or false;
	end
	if (type(GetPetHappiness) == "function") then
		local happiness, _, loyalty = GetPetHappiness();
		info.happiness = happiness;
		info.loyalty = loyalty;
	end

	return info;
end

function MTH_FOM_IsValidPetName(name)
	return (name and name ~= "" and name ~= UNKNOWNOBJECT) and true or false;
end

function MTH_FOM_GetLivePetName()
	local info = MTH_FOM_GetCorePetInfo();
	if (info and info.liveExists and MTH_FOM_IsValidPetName(info.name)) then
		return info.name;
	end
	return nil;
end

function MTH_FOM_GetTrackedPetName()
	local info = MTH_FOM_GetCorePetInfo();
	if (info and MTH_FOM_IsValidPetName(info.name)) then
		return info.name;
	end
	return nil;
end

function FOM_CheckSetup()

	_, realClass = UnitClass("player");
	if (realClass ~= "HUNTER") then return; end
	local now = (type(GetTime) == "function") and (GetTime() or 0) or 0;
	if (FOM_RealmPlayer ~= nil and (now - (tonumber(FOM_LAST_SETUP_AT) or 0)) < 5.0) then
		return;
	end

	if (FOM_RealmPlayer == nil) then
		FOM_RealmPlayer = GetCVar("realmName") .. "." .. UnitName("player");
	end
	local currentPetName = MTH_FOM_GetTrackedPetName();
	if (currentPetName) then
		FOM_LastPetName = currentPetName;
	end
	
	if (FOM_FoodQuality == nil) then
		FOM_FoodQuality = { };
	end	
	if (FOM_FoodQuality[FOM_RealmPlayer] == nil) then
		FOM_FoodQuality[FOM_RealmPlayer] = { };
	end
	if (FOM_LastPetName) then
		if (FOM_FoodQuality[FOM_RealmPlayer][FOM_LastPetName] == nil) then
			FOM_FoodQuality[FOM_RealmPlayer][FOM_LastPetName] = { };
		end
	end
	FOM_EnsureQuarantineStore();
	FOM_LAST_SETUP_AT = now;
	FOM_LAST_SETUP_PET = FOM_LastPetName;
			
end

function FOM_OnEvent(event, arg1)

	-- Save Variables
	if ( event == "VARIABLES_LOADED" ) then
				
		_, realClass = UnitClass("player");
		if (realClass == "HUNTER") then
			-- monitor status for whether we're able to feed
			if (not MTH_FEED_WRAPPER_MODE) then
				this:RegisterEvent("PET_ATTACK_START");
				this:RegisterEvent("PET_ATTACK_STOP");
--			this:RegisterEvent("CHAT_MSG_SYSTEM");
						
				this:RegisterEvent("PET_STABLE_SHOW");
				this:RegisterEvent("PET_STABLE_UPDATE");

			-- track whether foods are useful for Cooking 
				this:RegisterEvent("TRADE_SKILL_SHOW");
				this:RegisterEvent("TRADE_SKILL_UPDATE");

			-- figure out what happens when we try to feed pet (gain happiness, didn't like, etc)
				this:RegisterEvent("CHAT_MSG_SPELL_TRADESKILLS");
				this:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS");
				this:RegisterEvent("UI_ERROR_MESSAGE");
			
			-- Events for trying to catch when the pet needs feeding
				this:RegisterEvent("PET_BAR_SHOWGRID");
				this:RegisterEvent("PET_BAR_UPDATE");
				this:RegisterEvent("PET_UI_UPDATE");
				this:RegisterEvent("UNIT_HAPPINESS");
				this:RegisterEvent("PLAYER_REGEN_ENABLED");
			end

			if (MTH_FOM_FeedButton == nil) then
				MTH_FOM_FeedButton = CreateFrame("Button", "MTH_FOM_FeedButton", PetFrameHappiness);
				MTH_FOM_FeedButton:SetAllPoints(PetFrameHappiness);
				MTH_FOM_FeedButton:RegisterForClicks("LeftButtonUp", "RightButtonUp");
				MTH_FOM_FeedButton:SetScript("OnClick", MTH_FOM_FeedButton_OnClick);
				MTH_FOM_FeedButton:SetScript("OnEnter", MTH_FOM_FeedButton_OnEnter);
				MTH_FOM_FeedButton:SetScript("OnLeave", MTH_FOM_FeedButton_OnLeave);
			end
					
			if (FOM_Config.Level == "happy") then
				-- we've redefined the Level option and this setting is no loger available
				FOM_Config.Level = "content";
			end
			
		end
		return;

	elseif ( event == "MERCHANT_SHOW" or event == "MERCHANT_UPDATE" ) then
		FOM_DebugLogMerchantFoods(event);
		return;

	elseif ( event == "PET_ATTACK_START" ) then
	
		-- Set Flag
		FOM_State.InCombat = true;
		return;
		
	elseif ( event == "PET_ATTACK_STOP" ) then
	
		-- Remove Flag
		FOM_State.InCombat = false;
		
	elseif ( event == "CHAT_MSG_SPELL_TRADESKILLS" ) then
	
		if (FOM_FEEDPET_LOG_FIRSTPERSON == nil) then
			FOM_FEEDPET_LOG_FIRSTPERSON = GFWUtils.FormatToPattern(FEEDPET_LOG_FIRSTPERSON);
		end
		_, _, foodName = string.find(arg1, FOM_FEEDPET_LOG_FIRSTPERSON);
		if (foodName and foodName ~= "") then
			local foodID = GFWTable.KeyOf(FOM_FoodIDsToNames, foodName);
			if (foodID == nil) then
				local bag, slot = FOM_FindSpecificFood(foodName);
				local foodLink = GetContainerItemLink(bag, slot);
				foodID = FOM_IDFromLink(foodLink);
			end
			if (foodID) then
				FOM_LastFood = GFWUtils.ItemLink(foodID);
				GFWUtils.DebugLog("Manually fed "..FOM_LastFood);
			end
		end
		return;

	elseif ( event == "CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS" ) then
		
		if (arg1 and FOM_HasFeedEffect()) then
			if (FOM_POWERGAIN_OTHER == nil and POWERGAINSELFOTHER) then
				FOM_POWERGAIN_OTHER = GFWUtils.FormatToPattern(POWERGAINSELFOTHER);
			end
			if (FOM_POWERGAIN_OTHER == nil and POWERGAIN_OTHER) then
				FOM_POWERGAIN_OTHER = GFWUtils.FormatToPattern(POWERGAIN_OTHER);
			end
			if (FOM_POWERGAIN_OTHER == nil) then
				GFWUtils.PrintOnce(GFWUtils.Red("Feed-O-Matic Error: ").. "Can't find parse pattern for pet happiness.");
				return;
			end	
			_, _, name, amount, powerType = string.find(arg1, FOM_POWERGAIN_OTHER);
			local happiness;
			local petInfo = MTH_FOM_GetCorePetInfo();
			local livePetName = MTH_FOM_GetLivePetName();
			if (name == livePetName and powerType == HAPPINESS_POINTS) then
				happiness = tonumber(amount);
			else
				return;
			end

			if (type(FOM_LastFeedAttempt) == "table" and FOM_LastFeedAttempt.coreAttemptId and happiness and happiness > 0 and type(MTH_FEED_RecordHappinessTick) == "function") then
				pcall(MTH_FEED_RecordHappinessTick, FOM_LastFeedAttempt.coreAttemptId, {
					happinessTick = happiness,
					petLevel = tonumber(petInfo and petInfo.level) or nil,
				});
			end
		end
		return;
	
	elseif ( event == "UI_ERROR_MESSAGE" ) then
		local lowerError = string.lower(tostring(arg1 or ""));
		if (FOM_LastFood) then
			FOM_Trace("ui error while feeding message='" .. tostring(arg1 or "")
				.. "' lower='" .. tostring(lowerError) .. "'")
		end
		local isLowLevelError = (arg1 and SPELL_FAILED_FOOD_LOWLEVEL and string.find(arg1, SPELL_FAILED_FOOD_LOWLEVEL))
			or string.find(lowerError, "low level")
			or string.find(lowerError, "level too low")
			or string.find(lowerError, "too low level")
		local isWrongFoodError = (arg1 and SPELL_FAILED_WRONG_PET_FOOD and string.find(arg1, SPELL_FAILED_WRONG_PET_FOOD))
			or string.find(lowerError, "wrong pet food")
			or string.find(lowerError, "doesn't like")
			or string.find(lowerError, "does not like")
		FOM_Trace("ui error classify lowLevel=" .. tostring(isLowLevelError and true or false)
			.. " wrongFood=" .. tostring(isWrongFoodError and true or false)
			.. " hasAttempt=" .. tostring(type(FOM_LastFeedAttempt) == "table" and true or false)
			.. " lastFood='" .. tostring(FOM_LastFood or "") .. "'")

		if (isLowLevelError) then
			FOM_Trace("reject reason=low-level")
			if (type(FOM_LastFeedAttempt) == "table") then
				FOM_CoreRecordReject(FOM_LastFeedAttempt.coreAttemptId, "low-level", arg1);
				FOM_CoreFinalizeAttempt(FOM_LastFeedAttempt.coreAttemptId, "rejected", "low-level");
				FOM_LastFeedAttempt = nil;
			end
			if not (FOM_LastFood == nil) then
				FOM_LastFood = nil;
				local alertPetName = MTH_FOM_GetTrackedPetName() or "Your pet";
				if ( FOM_Config.Alert == "chat") then
					GFWUtils.Print(string.format(FOM_FEEDING_EAT_ANOTHER, alertPetName));
				elseif ( FOM_Config.Alert == "emote") then
					SendChatMessage(string.format(FOM_FEEDING_FEED_ANOTHER, alertPetName), "EMOTE");
				end
				return;
			end
		
		elseif (isWrongFoodError) then
			FOM_Trace("reject reason=wrong-food")
			if (type(FOM_LastFeedAttempt) == "table") then
				FOM_CoreRecordReject(FOM_LastFeedAttempt.coreAttemptId, "wrong-food", arg1);
				FOM_CoreFinalizeAttempt(FOM_LastFeedAttempt.coreAttemptId, "rejected", "wrong-food");
				FOM_LastFeedAttempt = nil;
			end
			if (FOM_LastFood) then
				local alertPetName = MTH_FOM_GetTrackedPetName() or "Your pet";
				local itemID = FOM_IDFromLink(FOM_LastFood);
				FOM_Trace("learn reject wrongfood pet='" .. tostring(FOM_LastPetName or alertPetName)
					.. "' itemId=" .. tostring(itemID)
					.. " link='" .. tostring(FOM_LastFood) .. "'")

				if ( FOM_Config.Alert == "chat") then
					GFWUtils.Print(string.format(FOM_FEEDING_EAT_ANOTHER, alertPetName));
				elseif ( FOM_Config.Alert == "emote") then
					SendChatMessage(string.format(FOM_FEEDING_FEED_ANOTHER, alertPetName), "EMOTE");
				end
				-- remove from diet
				local dietList = FOM_GetPetDietList();
				if (dietList ~= nil) then
					for _, diet in dietList do 
						diet = FOM_NormalizeDietToken(diet);
						if (diet ~= nil and FOM_RemoveFood(diet, itemID) ) then
							local capDiet = string.upper(string.sub(diet, 1, 1)) .. string.sub(diet, 2); -- print a nicely capitalized version
							GFWUtils.Print("Removed "..FOM_LastFood.." from "..GFWUtils.Hilite(capDiet).." list.");
						end
					end
				end
				FOM_LastFood = nil;
				return;
			end
		end
		return;
		
	elseif (event == "TRADE_SKILL_SHOW" or event == "TRADE_SKILL_UPDATE") then
		if (GetTradeSkillLine() ~= nil and GetTradeSkillLine() == FOM_CookingSpellName()) then
			if (FOM_Config.SaveForCookingLevel >= 0 and FOM_Config.SaveForCookingLevel <= 3) then
				-- Update Cooking reagents list so we can avoid consuming food we could skillup from.
				if (FOM_RealmPlayer == nil) then
					FOM_RealmPlayer = GetCVar("realmName") .. "." .. UnitName("player");
				end
				if (FOM_Cooking == nil) then
					FOM_Cooking = { };
				end
				if (FOM_Cooking[FOM_RealmPlayer] == nil) then
					FOM_Cooking[FOM_RealmPlayer] = { };
				end
				if (FOM_Cooking ~= nil and FOM_Cooking[FOM_RealmPlayer] ~= nil and TradeSkillFrame and TradeSkillFrame:IsVisible() and not FOM_TradeSkillLock.Locked) then
					-- This prevents further update events from being handled if we're already processing one.
					-- This is done to prevent the game from freezing under certain conditions.
					FOM_TradeSkillLock.Locked = true;

					for i=1, GetNumTradeSkills() do
						local itemName, type, _, _ = GetTradeSkillInfo(i);
						if (type ~= "header") then
							for j=1, GetTradeSkillNumReagents(i) do
								local reagentLink = GetTradeSkillReagentItemLink(i, j);
								local itemID = FOM_IDFromLink(reagentLink);
								
								if (itemID and FOM_IsKnownFood(itemID)) then
									if (FOM_Cooking[FOM_RealmPlayer][itemID] == nil) then
										FOM_Cooking[FOM_RealmPlayer][itemID] = FOM_DifficultyToNum(type);
									else
										FOM_Cooking[FOM_RealmPlayer][itemID] = max(FOM_Cooking[FOM_RealmPlayer][itemID], FOM_DifficultyToNum(type));
									end
								end
							end
						end
					end
				end
			end
		end
		return;
		
	elseif (event == "PET_STABLE_SHOW" or event == "PET_STABLE_UPDATE") then

		return;

	elseif (FOM_Config.Level) then
		FOM_CheckHappiness();
	end
	
end

-- Update our list of quest objectives so we can avoid consuming food we want to accumulate for a quest.
function FOM_ScanQuests()
	FOM_QuestFood = nil;
	for questNum=1, GetNumQuestLogEntries() do
		local QText, level, questTag, isHeader, isCollapsed, isComplete  = GetQuestLogTitle(questNum);
		if (not isHeader) then
			for objectiveNum=1, GetNumQuestLeaderBoards(questNum) do
				local text, type, finished = GetQuestLogLeaderBoard(objectiveNum, questNum);
				if (text ~= nil and strlen(text) > 0) then
					local _, _, objectiveName, numCurrent, numRequired = string.find(text, "(.*): (%d+)/(%d+)");
					if (FOM_IsKnownFood(objectiveName)) then
						if (FOM_QuestFood == nil) then
							FOM_QuestFood = { };
						end
						if (FOM_QuestFood[FOM_RealmPlayer] == nil) then
							FOM_QuestFood[FOM_RealmPlayer] = { };
						end

						if (FOM_QuestFood[FOM_RealmPlayer][objectiveName] == nil) then
							FOM_QuestFood[FOM_RealmPlayer][objectiveName] = tonumber(numRequired);
						else
							FOM_QuestFood[FOM_RealmPlayer][objectiveName] = max(FOM_QuestFood[FOM_RealmPlayer][objectiveName], tonumber(numRequired));
						end
					end
				end
			end
		end
	end
end

function FOM_DifficultyToNum(level)
	if (level == "optimal" or level == "orange") then
		return 3;
	elseif (level == "medium" or level == "yellow") then
		return 2;
	elseif (level == "easy" or level == "green") then
		return 1;
	elseif (level == "trivial" or level == "gray" or level == "grey") then
		return 1;
	else -- bad input
		return nil;
	end
end

local FOM_CachedPlayerClass = nil
local FOM_OnUpdateElapsed = 0

function FOM_OnUpdate(elapsed)
	FOM_OnUpdateElapsed = FOM_OnUpdateElapsed + (elapsed or 0)
	if FOM_OnUpdateElapsed < 0.05 then
		return
	end
	local dt = FOM_OnUpdateElapsed
	FOM_OnUpdateElapsed = 0

	if not FOM_CachedPlayerClass then
		_, FOM_CachedPlayerClass = UnitClass("player")
	end
	if (FOM_CachedPlayerClass ~= "HUNTER") then return; end

	-- If it's been more than a second since our last tradeskill update,
	-- we can allow the event to process again.
	FOM_TradeSkillLock.EventTimer = FOM_TradeSkillLock.EventTimer + dt;
	if (FOM_TradeSkillLock.Locked) then
		FOM_TradeSkillLock.EventCooldown = FOM_TradeSkillLock.EventCooldown + dt;
		if (FOM_TradeSkillLock.EventCooldown > FOM_TradeSkillLock.EventCooldownTime) then

			FOM_TradeSkillLock.EventCooldown = 0;
			FOM_TradeSkillLock.Locked = false;
		end
	end
		
	--GFWUtils.Debug = true;

	if (FOM_State.ShouldFeed and FOM_Config.IconWarning and PetFrameHappiness) then
		if (PetFrameHappiness:IsVisible() and PetFrameHappiness:GetAlpha() == 1) then
			FOM_FadeOut();
		end
	end

	if (type(FOM_LastFeedAttempt) == "table") then
		local now = GetTime() or 0;
		local startedAt = tonumber(FOM_LastFeedAttempt.startedAt) or 0;
		local elapsedSinceFeed = now - startedAt;
		if (elapsedSinceFeed >= 0.10 and not FOM_LastFeedAttempt.loggedFirstCheck) then
			FOM_LastFeedAttempt.loggedFirstCheck = true;
			FOM_Trace("feed outcome check itemId=" .. tostring(FOM_LastFeedAttempt.itemId)
				.. " pet='" .. tostring(FOM_LastFeedAttempt.petName or "")
				.. "' hasFeedBuff=" .. tostring(FOM_HasFeedEffect() and true or false)
				.. " elapsed=" .. string.format("%.2f", elapsedSinceFeed));
		end

		if (FOM_HasFeedEffect()) then
			if (FOM_LastFeedAttempt.coreAttemptId and type(MTH_FEED_RecordBuffOutcome) == "function") then
				pcall(MTH_FEED_RecordBuffOutcome, FOM_LastFeedAttempt.coreAttemptId, { hasFeedBuff = true, elapsed = elapsedSinceFeed });
			end
			local confirmedPetName = tostring(FOM_LastFeedAttempt.petName or "Your pet")
			local confirmedFoodLink = tostring(FOM_LastFeedAttempt.itemLink or FOM_LastFood or "")
			local alertMode = tostring(FOM_LastFeedAttempt.alertMode or FOM_Config.Alert or "")
			if (alertMode == "chat") then
				GFWUtils.Print(string.format(FOM_FEEDING_EAT, confirmedPetName, GFWUtils.Hilite(confirmedFoodLink)));
			elseif (alertMode == "emote") then
				SendChatMessage(string.format(FOM_FEEDING_FEED, confirmedPetName, confirmedFoodLink).. FOM_RandomEmote(), "EMOTE");
			end
			FOM_CoreFinalizeAttempt(FOM_LastFeedAttempt.coreAttemptId, "accepted", "accepted");
			FOM_Trace("feed outcome accepted-with-buff itemId=" .. tostring(FOM_LastFeedAttempt.itemId)
				.. " pet='" .. tostring(FOM_LastFeedAttempt.petName or "")
				.. "' elapsed=" .. string.format("%.2f", elapsedSinceFeed));
			FOM_LastFeedAttempt = nil;
		elseif (elapsedSinceFeed >= 2.50) then
			local failedAttempt = FOM_LastFeedAttempt;
			if (FOM_LastFeedAttempt.coreAttemptId and type(MTH_FEED_RecordBuffOutcome) == "function") then
				pcall(MTH_FEED_RecordBuffOutcome, FOM_LastFeedAttempt.coreAttemptId, { hasFeedBuff = false, elapsed = elapsedSinceFeed });
			end
			FOM_CoreRecordReject(FOM_LastFeedAttempt.coreAttemptId, "no-buff", nil);
			FOM_CoreFinalizeAttempt(FOM_LastFeedAttempt.coreAttemptId, "rejected", "no-buff");
			local currentPetInfo = MTH_FOM_GetCorePetInfo();
			FOM_RegisterNoBuffQuarantine(FOM_LastFeedAttempt.itemId, currentPetInfo);
			if (type(MTH_FEED_BlockItemForPetLevel) == "function") then
				pcall(MTH_FEED_BlockItemForPetLevel,
					FOM_LastFeedAttempt.itemId,
					tonumber(currentPetInfo and currentPetInfo.level) or nil,
					"no-buff");
			end
			FOM_Trace("feed outcome no-eating-buff itemId=" .. tostring(FOM_LastFeedAttempt.itemId)
				.. " pet='" .. tostring(FOM_LastFeedAttempt.petName or "")
				.. "' elapsed=" .. string.format("%.2f", elapsedSinceFeed)
				.. " (likely not accepted by pet)");
			FOM_LastFood = nil;
			FOM_LastFeedAttempt = nil;

			local retryCount = tonumber(failedAttempt and failedAttempt.retryCount) or 0;
			local canRetry = (type(failedAttempt) == "table")
				and not failedAttempt.manualFood
				and retryCount < FOM_MAX_RETRIES_PER_REQUEST;
			if (canRetry) then
				local excludedItemIds = {};
				if (type(failedAttempt.excludedItemIds) == "table") then
					for blockedId, blocked in failedAttempt.excludedItemIds do
						if (blocked) then
							excludedItemIds[blockedId] = true;
						end
					end
				end
				local failedItemId = tonumber(failedAttempt.itemId);
				if (failedItemId ~= nil) then
					excludedItemIds[failedItemId] = true;
				end
				local excludedCount = 0;
				for _, isBlocked in excludedItemIds do
					if (isBlocked) then
						excludedCount = excludedCount + 1;
					end
				end
				FOM_Trace("feed retry scheduled after no-buff retry=" .. tostring(retryCount + 1)
					.. " excludedCount=" .. tostring(excludedCount));
				FOM_Feed(nil, {
					retryCount = retryCount + 1,
					excludedItemIds = excludedItemIds,
					autoRetry = true,
				});
			end
		end
	end
end

function FOM_FadeOut()
    local fadeInfo = {};
    fadeInfo.mode = "OUT";
    fadeInfo.timeToFade = 0.5;
    fadeInfo.finishedFunc = FOM_FadeIn;
    UIFrameFade(PetFrameHappiness, fadeInfo);
end

--hack since a frame can't have a reference to itself in it
function FOM_FadeIn()
    UIFrameFadeIn(PetFrameHappiness, 0.5);
end

function FOM_CanFeed()
	local petInfo = MTH_FOM_GetCorePetInfo();
	if ( not (petInfo and petInfo.liveExists) ) then
		GFWUtils.DebugLog("Can't feed; pet doesn't exist.");
		return false;
	end
	if ( tonumber(petInfo.health) and tonumber(petInfo.health) <= 0 ) then
		GFWUtils.DebugLog("Can't feed; pet is dead.");
		return false;
	end
	if ( UnitHealth("player") <= 0 ) then
		GFWUtils.DebugLog("Can't feed; I'm dead.");
		return false;
	end
	if ( CastingBarFrameStatusBar:IsVisible() ) then
		GFWUtils.DebugLog("Can't feed; casting a spell / tradeksill.");
		return false;
	end
	if ( UnitOnTaxi("player") ) then
		GFWUtils.DebugLog("Can't feed; flying.");
		return false;
	end
	if ( FOM_State.InCombat ) or ( PlayerFrame.inCombat ) then
		GFWUtils.DebugLog("Can't feed; in combat.");
		return false;
	end
	if ( LootFrame:IsVisible() ) then
		GFWUtils.DebugLog("Shouldn't feed; loot window is open.");
		return false;
	end
	
	
	local buff, buffIndex;
	local dontFeedBuffTextures = { 
		"Interface\\Icons\\Ability_Ambush",				-- NE Shadowmeld (maybe not unique buff icon?)
		"Interface\\Icons\\Ability_Rogue_FeignDeath",	-- Feign Death
		"Interface\\Icons\\INV_Drink_07",				-- drinking
		"Interface\\Icons\\INV_Misc_Fork&Knife",		-- eating
	};
	local mountTextureSubStrings = { 
		"Ability_Mount",
		"INV_Misc_Foot_Kodo",
	};
	for buffIndex=0, 15 do
		local buff = GetPlayerBuffTexture(buffIndex);
		if ( buff ~= nil) then
			for _, buffTexture in dontFeedBuffTextures do
				if ( buff == buffTexture ) then
					GFWUtils.DebugLog("Can't feed; currently, eating, drinking, or feigning death.");
					return false;
				end
			end
			if ( UnitLevel("player") >= 40 ) then
				for _, buffTexture in mountTextureSubStrings do
					if ( string.find(buff, buffTexture) ) then
						MTH_FOM_Tooltip:SetUnitBuff("player", buffIndex+1);
						local msg = MTH_FOM_TooltipTextLeft1:GetText();
						if (msg ~= nil) then
							msg = string.lower(msg);
							for _, mountName in FOM_MOUNT_NAME_SUBSTRINGS do
								if (string.find(msg, mountName)) then
									GFWUtils.DebugLog("Can't feed; mounted.");
									return false;
								end
							end
						end
					end
				end
			end
		end
	end

	return true;
end

function FOM_PrintCollectedFoodData(limitArg)
	local removedNoise = FOM_PruneUnknownFoodNoise(true);
	if (removedNoise > 0) then
		GFWUtils.Print("- pruned unknown non-food rows: " .. tostring(removedNoise));
	end
	local removedExceptions = FOM_PruneExceptionNoise();
	if (removedExceptions > 0) then
		GFWUtils.Print("- pruned inert exception rows: " .. tostring(removedExceptions));
	end

	local limit = tonumber(limitArg) or 20;
	if (limit < 1) then
		limit = 1;
	elseif (limit > 100) then
		limit = 100;
	end

	GFWUtils.Print("Feed-O-Matic collected food data (limit " .. tostring(limit) .. "):");
	GFWUtils.Print("- server profile: " .. tostring(FOM_SERVER_PROFILE));

	local unknownRows = {};
	if (type(MTH_FEED_GetUnknownFoodQueue) == "function") then
		local fetched = MTH_FEED_GetUnknownFoodQueue();
		if (type(fetched) == "table") then
			unknownRows = fetched;
		end
	end
	GFWUtils.Print("- unknown/candidate foods: " .. tostring(table.getn(unknownRows)));
	for index = 1, math.min(limit, table.getn(unknownRows)) do
		local row = unknownRows[index];
		if (type(row) == "table") then
			local itemId = tonumber(row.itemId);
			local itemName = row.itemName or (itemId and GetItemInfo(itemId)) or ("item:" .. tostring(itemId or "?"));
			local resolvedLevel = row.resolved and row.resolved.foodLevel or nil;
			GFWUtils.Print("  unknown#" .. tostring(index)
				.. " id=" .. tostring(itemId)
				.. " name='" .. tostring(itemName) .. "'"
				.. " state=" .. tostring(row.state)
				.. " confidence=" .. tostring(row.confidence)
				.. " observedLevel=" .. tostring(row.observedFoodLevel)
				.. " resolvedLevel=" .. tostring(resolvedLevel));
		end
	end

	local exceptionRows = {};
	if (type(MTH_FEED_GetStore) == "function") then
		local store = MTH_FEED_GetStore();
		local byItem = store and store.exceptions and store.exceptions.byItemId or nil;
		if (type(byItem) == "table") then
			for itemKey, row in byItem do
				if (type(row) == "table" and FOM_IsExceptionRowActive(row)) then
					table.insert(exceptionRows, {
						itemId = tonumber(itemKey) or itemKey,
						row = row,
					});
				end
			end
		end
	end
	table.sort(exceptionRows, function(a, b)
		return tostring(a.itemId) < tostring(b.itemId);
	end);
	GFWUtils.Print("- core exception rows: " .. tostring(table.getn(exceptionRows)));
	for index = 1, math.min(limit, table.getn(exceptionRows)) do
		local entry = exceptionRows[index];
		local itemId = tonumber(entry.itemId);
		local itemName = (itemId and GetItemInfo(itemId)) or ("item:" .. tostring(entry.itemId));
		local reasons = entry.row.reasons or {};
		GFWUtils.Print("  exception#" .. tostring(index)
			.. " id=" .. tostring(entry.itemId)
			.. " name='" .. tostring(itemName) .. "'"
			.. " blockAtOrAbove=" .. tostring(entry.row.blockAtOrAbovePetLevel)
			.. " maxPetLevel=" .. tostring(entry.row.maxPetLevel)
			.. " noBuff=" .. tostring(reasons.noBuff or 0)
			.. " lowLevel=" .. tostring(reasons.lowLevel or 0)
			.. " wrongFood=" .. tostring(reasons.wrongFood or 0));
	end

	local quarantineStore = FOM_EnsureQuarantineStore();
	local quarantineCount = 0;
	local printedQuarantine = 0;
	if (type(quarantineStore) == "table" and type(quarantineStore.byFamily) == "table") then
		for _, byItem in quarantineStore.byFamily do
			if (type(byItem) == "table") then
				for _, row in byItem do
					if (type(row) == "table") then
						quarantineCount = quarantineCount + 1;
					end
				end
			end
		end
	end
	GFWUtils.Print("- FOM quarantine rows: " .. tostring(quarantineCount));
	if (type(quarantineStore) == "table" and type(quarantineStore.byFamily) == "table") then
		for family, byItem in quarantineStore.byFamily do
			if (type(byItem) == "table") then
				for itemId, row in byItem do
					if (printedQuarantine >= limit) then
						break;
					end
					if (type(row) == "table") then
						local numericItemId = tonumber(itemId);
						local itemName = (numericItemId and GetItemInfo(numericItemId)) or ("item:" .. tostring(itemId));
						printedQuarantine = printedQuarantine + 1;
						GFWUtils.Print("  quarantine#" .. tostring(printedQuarantine)
							.. " family='" .. tostring(family) .. "'"
							.. " id=" .. tostring(itemId)
							.. " name='" .. tostring(itemName) .. "'"
							.. " minRejectPetLevel=" .. tostring(row.minRejectPetLevel)
							.. " reason=" .. tostring(row.reason));
					end
				end
				if (printedQuarantine >= limit) then
					break;
				end
			end
			if (printedQuarantine >= limit) then
				break;
			end
		end
	end
end

function FOM_ChatCommandHandler(msg)

	if ( msg == "" ) then
		if (MTH_OpenOptions) then
			MTH_OpenOptions("FeedOMatic");
		end
		return;
	end
	
	-- Check for Pet (we don't really need one for most of our chat commands, but we conveniently use its name.)
	local commandPetInfo = MTH_FOM_GetCorePetInfo();
	if (commandPetInfo and commandPetInfo.liveExists and MTH_FOM_IsValidPetName(commandPetInfo.name)) then
		petName = commandPetInfo.name;
		if (GetLocale() ~= "enUS") then
			if (FOM_LocaleInfo == nil) then
				FOM_LocaleInfo = {};
			end
			local localeFamilyKey = FOM_GetLegacyFamilyKey();
			if (localeFamilyKey ~= nil and localeFamilyKey ~= "") then
				FOM_LocaleInfo[localeFamilyKey] = FOM_GetPetDietList();
			end
		end
	else
		petName = "Your pet";
	end
	
	-- Print Help
	if ( msg == "help" ) or ( msg == "" ) then
		GFWUtils.Print("Fizzwidget Feed-O-Matic "..FOM_VERSION..":");
		GFWUtils.Print("/feedomatic /fom <command>");
		GFWUtils.Print("- "..GFWUtils.Hilite("help").." - Print this helplist.");
		GFWUtils.Print("- "..GFWUtils.Hilite("status").." - Check current settings.");
		GFWUtils.Print("- "..GFWUtils.Hilite("reset").." - Reset to default settings.");
		GFWUtils.Print("- "..GFWUtils.Hilite("alert chat").." | "..GFWUtils.Hilite("emote").." | "..GFWUtils.Hilite("off").." - Alert via chat window or emote channel when feeding.");
		GFWUtils.Print("- "..GFWUtils.Hilite("level content").." | "..GFWUtils.Hilite("happy").." | "..GFWUtils.Hilite("off").." - Provide an extra reminder to feed your pet when happiness is below this level.");
		GFWUtils.Print("- "..GFWUtils.Hilite("saveforcook orange").." | "..GFWUtils.Hilite("yellow").." | "..GFWUtils.Hilite("green").." | "..GFWUtils.Hilite("gray").." | "..GFWUtils.Hilite("off").." - Avoid foods used in cooking recipes (based on their difficulty).");
		GFWUtils.Print("- "..GFWUtils.Hilite("savequest on").." | "..GFWUtils.Hilite("off").." - Avoid foods you need to collect for a quest.");
		GFWUtils.Print("- "..GFWUtils.Hilite("savebonus on").." | "..GFWUtils.Hilite("off").." - Avoid foods which have bonus effects.");
		GFWUtils.Print("- "..GFWUtils.Hilite("fallback on").." | "..GFWUtils.Hilite("off").." - Fall back to foods we'd normally avoid if no other food is available.");
		GFWUtils.Print("- "..GFWUtils.Hilite("keepopen <number>").." - Set when to prefer smaller stacks of food versus evaluating food based on quality. Specify "..GFWUtils.Hilite("off").." instead of a number to always select foods by quality, or "..GFWUtils.Hilite("max").." to always prefer smaller stacks.");
		GFWUtils.Print("- "..GFWUtils.Hilite("quality high").." | "..GFWUtils.Hilite("low").." - Set whether to prefer foods that give your pet more happiness faster or less happiness more slowly.");
		GFWUtils.Print("- "..GFWUtils.Hilite("feed").." - Feed your pet (automatically finds an appropriate food).");
		GFWUtils.Print("- "..GFWUtils.Hilite("feed <name>").." - Feed your pet a specific food.");
		GFWUtils.Print("- "..GFWUtils.Hilite("fooddata [limit]").." - Print collected food intelligence (unknown queue, exception blocks, quarantine). Defaults to 20 rows per section.");
		GFWUtils.Print("- "..GFWUtils.Hilite("add <diet> <name>").." - Add food to list.");
		GFWUtils.Print("- "..GFWUtils.Hilite("remove <diet> <name>").." - Remove food from list.");
		GFWUtils.Print("- "..GFWUtils.Hilite("show <diet>").." - Show food list.");
		return;
	end

	if ( msg == "version" ) then
		GFWUtils.Print("Fizzwidget Feed-O-Matic "..FOM_VERSION..":");
		return;
	end
		
	-- Check Status
	if ( msg == "status" ) then
		if (FOM_Config.Level) then
			GFWUtils.Print("Feed-O-Matic will help remind you to feed your pet when he's "..GFWUtils.Hilite(FOM_Config.Level)..".");
		else
			GFWUtils.Print("Feed-O-Matic will "..GFWUtils.Hilite("not").." help remind you when to feed your pet.");
		end

		if (FOM_Config.KeepOpenSlots < MAX_KEEPOPEN_SLOTS) then
		
			if (FOM_Config.PreferHigherQuality) then
				GFWUtils.Print("Feed-O-Matic will prefer to use higher quality foods first.");
			else
				GFWUtils.Print("Feed-O-Matic will prefer to use lower quality foods first.");
			end
			
			if (FOM_Config.KeepOpenSlots == 0) then
				GFWUtils.Print("Feed-O-Matic will look first at food quality when determining what to feed to your pet.");
			else
				GFWUtils.Print("If fewer than "..GFWUtils.Hilite(FOM_Config.KeepOpenSlots).." spaces are open in your inventory, Feed-O-Matic will prefer smaller stacks of food regardless of quality.");
			end
			
		else
			GFWUtils.Print("Feed-O-Matic will always prefer smaller stacks of food regardless of quality.");
		end
		
		if (FOM_Config.Alert == "emote") then
			GFWUtils.Print("You will automatically emote when feeding "..petName..".");
		elseif (FOM_Config.Alert == "chat") then
			GFWUtils.Print("Feed-O-Matic will notify you in chat when feeding "..petName..".");
		else
			GFWUtils.Print("There will be no alert when feeding "..petName..".");
		end
				
		if (FOM_Config.SaveForCookingLevel >= 0 and FOM_Config.SaveForCookingLevel <= 3) then
			if (FOM_Config.SaveForCookingLevel == 3) then
				level = "orange";
			elseif (FOM_Config.SaveForCookingLevel == 2) then
				level = "yellow";
			elseif (FOM_Config.SaveForCookingLevel == 1) then
				level = "green";
			elseif (FOM_Config.SaveForCookingLevel == 0) then
				level = "gray";
			end
			GFWUtils.Print("Feed-O-Matic will avoid foods used in "..GFWUtils.Hilite(level).." or higher Cooking recipes.");
		else
			GFWUtils.Print("Feed-O-Matic will choose foods without regard to whether they're used in Cooking.");
		end
		
		if (FOM_Config.AvoidQuestFood) then
			GFWUtils.Print("Feed-O-Matic will avoid foods you need to collect for quests.");
		else
			GFWUtils.Print("Feed-O-Matic will choose foods without regard to whether they're needed for quests.");
		end
		if (FOM_Config.AvoidBonusFood) then
			GFWUtils.Print("Feed-O-Matic will avoid foods that have an additional bonus effect when eaten by a player.");
		else
			GFWUtils.Print("Feed-O-Matic will choose foods without regard to whether they have bonus effects.");
		end
		if (FOM_Config.Fallback) then
			GFWUtils.Print("Feed-O-Matic will fall back to food it would otherwise avoid if no other food is available.");
		else
			GFWUtils.Print("Feed-O-Matic will not feed your pet if the only foods available are foods you'd prefer to avoid feeding.");
		end
		return;
	end

	-- Reset Variables
	if ( msg == "reset" ) then
		FOM_Config = FOM_Config_Default;
		FOM_Cooking = nil;
		FOM_FoodQuality = nil;
		FOM_AddedFoods = nil;
		FOM_RemovedFoods = nil;
		FOM_QuestFood = nil;
		GFWUtils.Print("Feed-O-Matic configuration reset.");
		FOM_ChatCommandHandler("status");
		return;
	end
	
	-- Turn automatic feeding On
	if ( msg == "on" ) then
		GFWUtils.Print("Automatic feeding is no longer available due to changes in the WoW client as of Patch 1.10.");		
		return;
	end

	local _, _, cmd, option = string.find(msg, "(%w+) (%w+)");

	-- Toggle Alert
	if ( cmd == "alert" ) then
		
		if (option == "emote") then
			FOM_Config.Alert = "emote";
			GFWUtils.Print("You will automatically emote when feeding "..petName..".");
		elseif (option == "chat") then
			FOM_Config.Alert = "chat";
			GFWUtils.Print("Feed-O-Matic will notify you in chat when feeding "..petName..".");
		elseif (option == "off") then
			FOM_Config.Alert = nil;
			GFWUtils.Print("There will be no alert when feeding "..petName..".");
		else
			GFWUtils.Print("Usage: "..GFWUtils.Hilite("/feedomatic alert chat").." | "..GFWUtils.Hilite("emote").." | "..GFWUtils.Hilite("off"));
		end
		return;
	end
	
	-- Set Happiness Level
	if ( cmd == "level" ) then
		if ( option == "content" ) then
			FOM_Config.Level = "content";
		elseif ( option == "happy" ) then
			FOM_Config.Level = "happy";
		elseif ( option == "debug" ) then
			FOM_Config.Level = "debug";
		else
			FOM_Config.Level = nil;
		end
		if (FOM_Config.Level) then
			GFWUtils.Print("Feed-O-Matic will help remind you to feed your pet when he's less than "..GFWUtils.Hilite(FOM_Config.Level)..".");
			FOM_CheckHappiness();
		else
			GFWUtils.Print("Feed-O-Matic will "..GFWUtils.Hilite("not").." help remind you when to feed your pet.");
			FOM_Status.ShouldFeed = nil;
		end
		return;
	end
	
	-- Set Cooking recipe level
	if ( cmd == "saveforcook" ) then
		local level = option;
		if (level ~= nil) then
			local levelNum = FOM_DifficultyToNum(level);
			if (levelNum ~= nil) then 
				FOM_Config.SaveForCookingLevel = levelNum;
				FOM_Config.AvoidUsefulFood = true;
				GFWUtils.Print("Feed-O-Matic will avoid foods used in "..GFWUtils.Hilite(level).." or higher Cooking recipes. You'll need to open your Cooking window for Feed-O-Matic to cache information about what recipes you know.");
				return;
			elseif (level == "off") then
				FOM_Config.SaveForCookingLevel = 4; 
				if (not FOM_Config.AvoidQuestFood and not FOM_Config.Avoid9) then
					FOM_Config.AvoidUsefulFood = false;
				end
				GFWUtils.Print("Feed-O-Matic will choose foods without regard to whether they're used in Cooking.");
				return;
			end
		end
		GFWUtils.Print("Usage: "..GFWUtils.Hilite("/feedomatic saveforcook orange").." | "..GFWUtils.Hilite("yellow").." | "..GFWUtils.Hilite("green").." | "..GFWUtils.Hilite("gray").." | "..GFWUtils.Hilite("off"));
		return;
	end
	
	-- Set avoiding food with bonuses
	if ( cmd == "savequest" ) then
		if (option == "on") then
			FOM_Config.AvoidQuestFood = true;
			FOM_Config.AvoidUsefulFood = true;
			FOM_ScanQuests();
			GFWUtils.Print("Feed-O-Matic will avoid foods you need to collect for quests.");
		elseif (option == "off") then
			FOM_Config.AvoidQuestFood = true;
			if not (FOM_Config.SaveForCookingLevel >= 0 and FOM_Config.SaveForCookingLevel <= 3 and not FOM_Config.AvoidBonusFood) then
				FOM_Config.AvoidUsefulFood = false;
			end
			GFWUtils.Print("Feed-O-Matic will choose foods without regard to whether they're needed for quests.");
		else
			GFWUtils.Print("Usage: "..GFWUtils.Hilite("/feedomatic savequest on").." | "..GFWUtils.Hilite("off"));
		end
		return;
	end
	
	-- Set avoiding quest-objective food
	if ( cmd == "savebonus" ) then
		if (option == "on") then
			FOM_Config.AvoidBonusFood = true;
			FOM_Config.AvoidUsefulFood = true;
			GFWUtils.Print("Feed-O-Matic will avoid foods that have an additional bonus effect when eaten by a player.");
		elseif (option == "off") then
			FOM_Config.AvoidBonusFood = true;
			if not (FOM_Config.SaveForCookingLevel >= 0 and FOM_Config.SaveForCookingLevel <= 3 and not FOM_Config.AvoidQuestFood) then
				FOM_Config.AvoidUsefulFood = false;
			end
			GFWUtils.Print("Feed-O-Matic will choose foods without regard to whether they have bonus effects.");
		else
			GFWUtils.Print("Usage: "..GFWUtils.Hilite("/feedomatic savebonus on").." | "..GFWUtils.Hilite("off"));
		end
		return;
	end
	
	if ( cmd == "fallback" ) then
		if (option == "on") then
			FOM_Config.Fallback = true;
			GFWUtils.Print("Feed-O-Matic will fall back to food it would otherwise avoid if no other food is available.");
		elseif (option == "off") then
			FOM_Config.Fallback = false;
			GFWUtils.Print("Feed-O-Matic will not feed your pet if the only foods available are foods you'd prefer to avoid feeding.");
		else
			GFWUtils.Print("Usage: "..GFWUtils.Hilite("/feedomatic fallback on").." | "..GFWUtils.Hilite("off"));
		end
		return;
	end
	
	-- Set quality sorting direction
	if ( cmd == "quality" ) then
		if (option == "high") then
			FOM_Config.PreferHigherQuality = true;
			GFWUtils.Print("Feed-O-Matic will prefer to use higher quality foods first.");
		elseif (option == "low") then
			FOM_Config.PreferHigherQuality = false;
			GFWUtils.Print("Feed-O-Matic will prefer to use lower quality foods first.");
		else
			GFWUtils.Print("Usage: "..GFWUtils.Hilite("/feedomatic quality high").." | "..GFWUtils.Hilite("low"));
		end
		return;
	end

	-- Set inventory management threshold
	if ( cmd == "keepopen" ) then
		if (option == "off" or option == "none") then
			newNum = 0;
		elseif (option == "max") then
			newNum = MAX_KEEPOPEN_SLOTS;
		else
			newNum = tonumber(option);
		end
		if (newNum == nil) then
			GFWUtils.Print("Usage: "..GFWUtils.Hilite("/feedomatic keepopen <number>"));
			return;
		end
		FOM_Config.KeepOpenSlots = newNum;
		GFWUtils.Print("Feed-O-Matic will try to keep at least "..GFWUtils.Hilite(FOM_Config.KeepOpenSlots).." spaces open in your inventory when looking for food.");
		return;
	end
	
	-- Feed Pet
	local _, _, dumpCmd, dumpLimit = string.find(msg, "(%w+) *(%w*)");
	if (dumpCmd == "fooddata" or dumpCmd == "dumpfood" or dumpCmd == "data") then
		FOM_PrintCollectedFoodData(dumpLimit);
		return;
	end

	local _, _, cmd, foodString = string.find(msg, "(%w+) *(.*)");
	if ( cmd == "feed" ) then
		if (foodString == "") then
			FOM_Feed(nil); -- automatically find a food and feed it
		else
			local inputFoods = { };
			for itemLink in string.gfind(foodString, "%[[%w%s:()\"'-]+%]") do
				local _, _, foodName = string.find(itemLink, "^%[([%w%s:()\"'-]+)%]$"); 
				table.insert(inputFoods, foodName);
			end
			if (table.getn(inputFoods) == 0) then
				table.insert(inputFoods, foodString); -- if no item links, treat whole input line as one food's name
			end
			
			for _, food in inputFoods do
				FOM_Feed(food);
			end
		end
		return;
	end
	
	local _, _, cmd, diet, foodString = string.find(msg, "(%w+) (%w+) *(.*)");
	if ( cmd == "add" or cmd == "remove" or cmd == "show" or cmd == "list" ) then
	
		diet = string.lower(diet); -- let's be case insensitive
		if ( FOM_Foods[diet] == nil and diet ~= FOM_DIET_ALL) then
			local usageString = "Usage: "..GFWUtils.Hilite("/feedomatic "..cmd..FOM_DIET_MEAT).." | "..GFWUtils.Hilite(FOM_DIET_FISH).." | "..GFWUtils.Hilite(FOM_DIET_BREAD).." | "..GFWUtils.Hilite(FOM_DIET_CHEESE).." | "..GFWUtils.Hilite(FOM_DIET_FRUIT).." | "..GFWUtils.Hilite(FOM_DIET_FUNGUS).." | "..GFWUtils.Hilite(FOM_DIET_BONUS)
			if (cmd ~= "show" and cmd ~= "list") then
				usageString = usageString.." <item link>.";
			end
			GFWUtils.Print(usageString);
			return;
		end

		if (cmd == "show" or cmd == "list") then
			if ( diet == FOM_DIET_ALL ) then
				diets = {FOM_DIET_MEAT, FOM_DIET_FISH, FOM_DIET_BREAD, FOM_DIET_CHEESE, FOM_DIET_FRUIT, FOM_DIET_FUNGUS, FOM_DIET_BONUS};
			else
				diets = {diet};
			end
			
			for _, aDiet in diets do
				local capDiet = string.upper(string.sub(aDiet, 1, 1)) .. string.sub(aDiet, 2); -- print a nicely capitalized version
				GFWUtils.Print("Feed-O-Matic "..GFWUtils.Hilite(capDiet).." List:");
				local dietFoods = FOM_Foods[aDiet];
				if (FOM_AddedFoods ~= nil and FOM_AddedFoods[aDiet] ~= nil) then
					dietFoods = GFWTable.Merge(dietFoods, FOM_AddedFoods[aDiet]);
				end
				if (FOM_RemovedFoods ~= nil and FOM_RemovedFoods[aDiet] ~= nil) then
					dietFoods = GFWTable.Subtract(dietFoods, FOM_RemovedFoods[aDiet]);
				end
				table.sort(dietFoods);
				for _, food in dietFoods do
					local foodName = GetItemInfo(food);
					if (foodName) then
						if (FOM_FoodIDsToNames == nil) then
							FOM_FoodIDsToNames = {};
						end
						FOM_FoodIDsToNames[food] = foodName;
						GFWUtils.Print(GFWUtils.Hilite(" - ")..foodName);
					else
						GFWUtils.Print(GFWUtils.Hilite(" - ").."item id "..food.." (name not available)");
					end
				end
			end
			return;
		else
		
			local inputFoods = { };
			for itemLink in string.gfind(foodString, "|c%x+|Hitem:%d+:%d+:%d+:%d+|h%[.-%]|h|r") do
				table.insert(inputFoods, itemLink);
				local foodID = FOM_IDFromLink(itemLink);
				if (foodID) then
					local foodName = FOM_NameFromLink(itemLink);
					if (FOM_FoodIDsToNames == nil) then
						FOM_FoodIDsToNames = {};
					end
					FOM_FoodIDsToNames[foodID] = foodName;
				end
			end
			if (table.getn(inputFoods) == 0) then
				GFWUtils.Print("The "..GFWUtils.Hilite("/fom "..cmd).." command requires an item link; shift-click an item to insert a link.");
				return;
			end

			local capDiet = string.upper(string.sub(diet, 1, 1)) .. string.sub(diet, 2); -- print a nicely capitalized version
			if ( cmd == "add" ) then
				for _, food in inputFoods do
					local foodID = FOM_IDFromLink(food);
					if ( FOM_AddFood(diet, tonumber(foodID)) ) then
						GFWUtils.Print("Added "..food.." to "..GFWUtils.Hilite(capDiet).." list.");
					else
						GFWUtils.Print(food.." already in "..GFWUtils.Hilite(capDiet).." list.");
					end
				end
				if (FOM_Config.AvoidQuestFood) then
					FOM_ScanQuests(); -- in case any of the newly added foods are quest objectives
				end
				return;
			elseif (cmd == "remove" ) then
				for _, food in inputFoods do
					local foodID = FOM_IDFromLink(food);
					if ( FOM_RemoveFood(diet, tonumber(foodID)) ) then
						GFWUtils.Print("Removed "..food.." from "..GFWUtils.Hilite(capDiet).." list.");
					else
						GFWUtils.Print("Could not find "..food.." in "..GFWUtils.Hilite(capDiet).." list.");
					end
				end
				return;
			end
		end
	end
	
	-- if we got down to here, we got bad input
	FOM_ChatCommandHandler("help");
end

-- Add a food to a list
function FOM_AddFood(diet, food)

	if (FOM_Foods[diet] == nil) then
		GFWUtils.DebugLog("FOM_Foods[diet] == nil");
	end
	if (FOM_AddedFoods == nil or FOM_AddedFoods[diet] == nil) then
		GFWUtils.DebugLog("FOM_AddedFoods == nil or FOM_AddedFoods[diet] == nil");
	end
	if (FOM_RemovedFoods == nil or FOM_RemovedFoods[diet] == nil) then
		GFWUtils.DebugLog("FOM_RemovedFoods == nil or FOM_RemovedFoods[diet] == nil");
	end
	if ( GFWTable.IndexOf(FOM_Foods[diet], food) == 0 ) then
		if (FOM_AddedFoods == nil) then
			FOM_AddedFoods = {};
		end
		if (FOM_AddedFoods[diet] == nil) then
			FOM_AddedFoods[diet] = {};
		end
		if ( GFWTable.IndexOf(FOM_AddedFoods[diet], food) == 0 ) then
			table.insert( FOM_AddedFoods[diet], food );
			table.sort( FOM_AddedFoods[diet] );
			if (FOM_RemovedFoods and FOM_RemovedFoods[diet] and GFWTable.IndexOf(FOM_RemovedFoods[diet], food) ~= 0) then
				table.remove( FOM_RemovedFoods[diet], GFWTable.IndexOf(FOM_RemovedFoods[diet], food) );
				table.sort( FOM_RemovedFoods[diet] );
			end
			return true;
		else
			return false;
		end
	else
		return false;
	end

end

-- Remove a food from a list
function FOM_RemoveFood(diet, food)
	
	if (FOM_Foods[diet] == nil) then
		GFWUtils.DebugLog("FOM_Foods[diet] == nil");
	end
	if (FOM_AddedFoods == nil or FOM_AddedFoods[diet] == nil) then
		GFWUtils.DebugLog("FOM_AddedFoods == nil or FOM_AddedFoods[diet] == nil");
	end
	if (FOM_RemovedFoods == nil or FOM_RemovedFoods[diet] == nil) then
		GFWUtils.DebugLog("FOM_RemovedFoods == nil or FOM_RemovedFoods[diet] == nil");
	end
	if ( GFWTable.IndexOf(FOM_Foods[diet], food) ~= 0 ) then
		if (FOM_RemovedFoods == nil) then
			FOM_RemovedFoods = {};
		end
		if (FOM_RemovedFoods[diet] == nil) then
			FOM_RemovedFoods[diet] = {};
		end
		if ( GFWTable.IndexOf(FOM_RemovedFoods[diet], food) == 0 ) then
			table.insert( FOM_RemovedFoods[diet], food );
			table.sort( FOM_RemovedFoods[diet] );
			if (FOM_AddedFoods and FOM_AddedFoods[diet] and GFWTable.IndexOf(FOM_AddedFoods[diet], food) ~= 0) then
				table.remove( FOM_AddedFoods[diet], GFWTable.IndexOf(FOM_AddedFoods[diet], food) );
				table.sort( FOM_AddedFoods[diet] );
			end
			return true;
		else
			return false;
		end
	else
		if (FOM_AddedFoods and FOM_AddedFoods[diet] and GFWTable.IndexOf(FOM_AddedFoods[diet], food) ~= 0) then
			table.remove( FOM_AddedFoods[diet], GFWTable.IndexOf(FOM_AddedFoods[diet], food) );
			table.sort( FOM_AddedFoods[diet] );
			return true;
		end
		return false;
	end

end

function FOM_IsBGActive()
	local bgNum = 1;
	local status;
	repeat
		status = GetBattlefieldStatus(bgNum);
		if (status == "active") then 
			return true;
		end
		bgNum = bgNum + 1;
	until (status == nil)
	return false;
end
-- Check Happiness
function FOM_CheckHappiness()
	local petInfo = MTH_FOM_GetCorePetInfo();

	-- Check for pet
	if not ( petInfo and petInfo.liveExists ) then 
		FOM_State.ShouldFeed = nil;		
		return;
	end
		
	-- Get Pet Info
	local pet = (MTH_FOM_IsValidPetName(petInfo.name) and petInfo.name) or "Your pet";
	local happiness = petInfo.happiness;
	
	-- Check No Happiness
	if ( happiness == 0 ) or ( happiness == nil ) then return; end
	
	local level;
	if ( FOM_Config.Level == "unhappy" ) then
		level = 1;
	elseif ( FOM_Config.Level == "content" ) then
		level = 2;
	elseif ( FOM_Config.Level == "happy" ) then
		level = 3;
	elseif ( FOM_Config.Level == "debug" ) then
		level = 4;
	else
		level = 0;
	end
	
	-- Check if Need Feeding
	if ( happiness < level + 1 ) then
	
		if (UnitIsDead("pet")) then return; end
		if (UnitAffectingCombat("pet")) then return; end
		if (UnitAffectingCombat("player")) then return; end
		
		FOM_State.ShouldFeed = true;
		if (not FOM_HasFeedEffect() and GetTime() - FOM_LastWarning > FOM_WARNING_INTERVAL) then
			if (FOM_Config.TextWarning) then
				local msg;
				if (level - happiness == 0) then
					msg = FOM_PET_HUNGRY;
				else
					msg = FOM_PET_VERY_HUNGRY;
				end
				if (not (MTH and MTH.IsMessageEnabled) or MTH:IsMessageEnabled("petHungry", false)) then
					GFWUtils.Print(string.format(msg, pet));
					GFWUtils.Note(string.format(msg, pet));
				end
			end
			FOM_PlayHungrySound();
			FOM_LastWarning = GetTime();
		end
	else
		FOM_State.ShouldFeed = nil;
	end
	
end

FOM_HungrySounds = {
  	[BAT]		    = "Sound\\Creature\\FelBat\\FelBatDeath.wav",
  	[BEAR]		    = "Sound\\Creature\\Bear\\mBearDeathA.wav",
  	[BOAR]		    = "Sound\\Creature\\Boar\\mWildBoarAggro2.wav",
  	[CAT]		    = "Sound\\Creature\\Tiger\\mTigerStand2A.wav",
  	[CARRION_BIRD]	= "Sound\\Creature\\Carrion\\mCarrionWoundCriticalA.wav",
  	[CRAB]		    = "Sound\\Creature\\Crab\\CrabDeathA.wav",
  	[CROCOLISK]	    = "Sound\\Creature\\Basilisk\\mBasiliskSpellCastA.wav",
  	[GORILLA]	    = "Sound\\Creature\\Gorilla\\GorillaDeathA.wav",
  	[HYENA]		    = "Sound\\Creature\\Hyena\\HyenaPreAggroA.wav",
  	[OWL]		    = "Sound\\Creature\\OWl\\OwlPreAggro.wav",
  	[RAPTOR]	    = "Sound\\Creature\\Raptor\\mRaptorWoundCriticalA.wav",
  	[SCORPID]	    = "Sound\\Creature\\SilithidWasp\\mSilithidWaspStand2A.wav",
  	[SPIDER]	    = "Sound\\Creature\\Tarantula\\mTarantulaFidget2a.wav",
  	[TALLSTRIDER]   = "Sound\\Creature\\TallStrider\\tallStriderPreAggroA.wav",
  	[TURTLE]	    = "Sound\\Creature\\SeaTurtle\\SeaTurtleWoundCritA.wav",
  	[WIND_SERPENT]	= "Sound\\Creature\\WindSerpant\\mWindSerpantDeathA.wav",
  	[WOLF]		    = "Sound\\Creature\\Wolf\\mWolfFidget2c.wav",
};
function FOM_PlayHungrySound()
	if (FOM_Config.AudioWarning) then
		local type = FOM_GetLegacyFamilyKey();
		local sound = FOM_HungrySounds[type];
		if (sound == nil or FOM_Config.AudioWarning == "bell") then
			PlaySoundFile("Sound\\Doodad\\BellTollNightElf.wav");
		else
			PlaySoundFile(sound);
		end
	end
end

-- Check Feed Effect
function FOM_HasFeedEffect()

	local i = 1;
	local buff;
	buff = UnitBuff("pet", i);
	while buff do
		if ( string.find(buff, "Ability_Hunter_BeastTraining") ) then
			return true;
		end
		i = i + 1;
		buff = UnitBuff("pet", i);
	end
	return false;

end

-- Feed Pet
local function FOM_CloneSet(source)
	local clone = {};
	if (type(source) ~= "table") then
		return clone;
	end
	for key, value in source do
		if (value) then
			clone[key] = true;
		end
	end
	return clone;
end

local function FOM_CountSetEntries(source)
	if (type(source) ~= "table") then
		return 0;
	end
	local count = 0;
	for _, value in source do
		if (value) then
			count = count + 1;
		end
	end
	return count;
end

local function FOM_CloneFoodList(source)
	local clone = {};
	if (type(source) ~= "table") then
		return clone;
	end
	for i = 1, table.getn(source) do
		clone[i] = source[i];
	end
	return clone;
end

local function FOM_GetFeedScanCacheKey(petInfo)
	if (type(petInfo) ~= "table") then
		return "none";
	end
	return tostring(petInfo.name or "")
		.. "|" .. tostring(petInfo.family or "")
		.. "|" .. tostring(tonumber(petInfo.level) or 0);
end

local function FOM_GetCachedAutoChoice(excludedItemIds)
	if (type(FOM_LAST_AUTO_CHOICE) ~= "table") then
		return nil, nil, nil;
	end
	local now = (type(GetTime) == "function") and (GetTime() or 0) or 0;
	if ((now - (tonumber(FOM_LAST_AUTO_CHOICE.at) or 0)) > FOM_LAST_AUTO_CHOICE_TTL) then
		return nil, nil, nil;
	end
	local bag = tonumber(FOM_LAST_AUTO_CHOICE.bag);
	local slot = tonumber(FOM_LAST_AUTO_CHOICE.slot);
	local itemId = tonumber(FOM_LAST_AUTO_CHOICE.itemId);
	if (bag == nil or slot == nil or itemId == nil) then
		return nil, nil, nil;
	end
	if (type(excludedItemIds) == "table" and excludedItemIds[itemId]) then
		return nil, nil, nil;
	end
	if (type(GetContainerItemLink) ~= "function") then
		return nil, nil, nil;
	end
	local link = GetContainerItemLink(bag, slot);
	if (not link) then
		return nil, nil, nil;
	end
	local linkId = FOM_IDFromLink(link);
	if (tonumber(linkId) ~= itemId) then
		return nil, nil, nil;
	end
	return bag, slot, itemId;
end

local function FOM_SetCachedAutoChoice(bag, slot, itemId)
	if (bag == nil or slot == nil or itemId == nil) then
		return;
	end
	FOM_LAST_AUTO_CHOICE = {
		at = (type(GetTime) == "function") and (GetTime() or 0) or 0,
		bag = tonumber(bag),
		slot = tonumber(slot),
		itemId = tonumber(itemId),
	};
end

local function FOM_TryPickSinglePrecomputedFood(foodList, excludedItemIds, allowUseful)
	if (type(foodList) ~= "table" or table.getn(foodList) ~= 1) then
		return nil, nil;
	end
	local foodInfo = foodList[1];
	if (type(foodInfo) ~= "table") then
		return nil, nil;
	end
	local itemId = tonumber(foodInfo.itemId);
	if (itemId ~= nil and type(excludedItemIds) == "table" and excludedItemIds[itemId]) then
		return nil, nil;
	end
	if (not allowUseful and foodInfo.useful) then
		return nil, nil;
	end
	return foodInfo.bag, foodInfo.slot;
end

function FOM_Feed(aFood, options)
	local feedStartMs = FOM_PerfNowMs();
	options = options or {};
	local retryCount = tonumber(options.retryCount) or 0;
	local excludedItemIds = FOM_CloneSet(options.excludedItemIds);
	local sourceTag = (retryCount > 0) and "feedomatic:auto-retry" or "feedomatic:auto";
	local manualFood = (aFood ~= nil and tostring(aFood) ~= "");

	if MTH_IsModuleEnabled and not MTH_IsModuleEnabled("feedomatic", false) then
		if DEFAULT_CHAT_FRAME and DEFAULT_CHAT_FRAME.AddMessage then
			MTH:Print("[FOM WRAP] FOM_Feed blocked: module disabled", "debug")
		end
		return false;
	end
		
	-- Make sure we have a feedable pet
	local petInfo = MTH_FOM_GetCorePetInfo();
	if not (petInfo and petInfo.liveExists) then 
		GFWUtils.Note(FOM_ERROR_NO_PET); 
		return false;
	end
	if (petInfo.dead or (tonumber(petInfo.health) and tonumber(petInfo.health) <= 0)) then
		GFWUtils.Note(FOM_ERROR_PET_DEAD); 
		return false;
	end
	if (FOM_GetPetDietList() == nil) then
		GFWUtils.Note(FOM_ERROR_NO_FEEDABLE_PET); 
		return false;
	end
	if (UnitAffectingCombat("player") or UnitAffectingCombat("pet")) then
		GFWUtils.Note(FOM_ERROR_IN_COMBAT); 
		return false;
	end
	
	-- Assign Variable
	local pet = (MTH_FOM_IsValidPetName(petInfo.name) and petInfo.name) or "Your pet";
	FOM_Trace("feed request pet='" .. tostring(pet)
		.. "' level=" .. tostring(petInfo.level)
		.. " happiness=" .. tostring(petInfo.happiness)
		.. " manualFood='" .. tostring(aFood or "") .. "'"
		.. " retry=" .. tostring(retryCount)
		.. " excluded=" .. tostring(FOM_CountSetEntries(excludedItemIds)))
	
	local checkSetupStartMs = FOM_PerfNowMs();
	FOM_CheckSetup();
	FOM_PerfRecord("FOM_CheckSetup", FOM_PerfNowMs() - checkSetupStartMs, "retry=" .. tostring(retryCount), false);
	if (FOM_LastPetName == nil or FOM_LastPetName == "") then
		GFWUtils.DebugLog("Can't get pet info.");
		FOM_PerfRecord("FOM_Feed total", FOM_PerfNowMs() - feedStartMs, "result=no-pet-name", true);
		return false;
	end

	if (GetLocale() ~= "enUS") then
		if (FOM_LocaleInfo == nil) then
			FOM_LocaleInfo = {};
		end
		local localeFamilyKey = FOM_GetLegacyFamilyKey();
		if (localeFamilyKey ~= nil and localeFamilyKey ~= "") then
			FOM_LocaleInfo[localeFamilyKey] = FOM_GetPetDietList();
		end
	end
	
	-- Look for Food
	local foodBag, foodItem;
	local precomputedFoodList = nil;
	local openSlots = nil;
	if (manualFood) then
		-- if told to feed a specific food, do so
		foodBag, foodItem = FOM_FindSpecificFood(aFood);
		if ( foodBag == nil) then
			-- No Food Could be Found
			GFWUtils.Print(string.format(FOM_ERROR_FOOD_NOT_FOUND, pet, aFood));
			FOM_PerfRecord("FOM_Feed total", FOM_PerfNowMs() - feedStartMs, "result=manual-not-found", true);
			return false;
		end
		FOM_LastChoiceReason = "manual selection";
	else
		local cachedChoiceStartMs = FOM_PerfNowMs();
		local cachedBag, cachedSlot, cachedItemId = FOM_GetCachedAutoChoice(excludedItemIds);
		if (cachedBag ~= nil and cachedSlot ~= nil) then
			foodBag, foodItem = cachedBag, cachedSlot;
			FOM_LastChoiceReason = "cached previous food";
			FOM_PerfRecord("FOM_AutoChoice cache", FOM_PerfNowMs() - cachedChoiceStartMs,
				"hit itemId=" .. tostring(cachedItemId), false);
		else
			FOM_PerfRecord("FOM_AutoChoice cache", FOM_PerfNowMs() - cachedChoiceStartMs, "miss", false);
		end

		if (foodBag == nil) then
		local precomputeStartMs = FOM_PerfNowMs();
		local cacheNow = (type(GetTime) == "function") and (GetTime() or 0) or 0;
		if (retryCount <= 0
			and type(FOM_FEED_SCAN_CACHE) == "table"
			and (cacheNow - (tonumber(FOM_FEED_SCAN_CACHE.at) or 0)) <= FOM_FEED_SCAN_CACHE_TTL
			and type(FOM_FEED_SCAN_CACHE.foods) == "table") then
			precomputedFoodList = FOM_CloneFoodList(FOM_FEED_SCAN_CACHE.foods);
			openSlots = tonumber(FOM_FEED_SCAN_CACHE.openSlots) or 0;
			FOM_PerfRecord("FOM_Feed precompute", FOM_PerfNowMs() - precomputeStartMs,
				"cache-hit foods=" .. tostring(table.getn(precomputedFoodList)) .. " openSlots=" .. tostring(openSlots), false);
		else
			precomputedFoodList = FOM_FlatFoodList();
			openSlots = FOM_NumOpenBagSlots();
			FOM_FEED_SCAN_CACHE = {
				at = cacheNow,
				key = FOM_GetFeedScanCacheKey(petInfo),
				foods = FOM_CloneFoodList(precomputedFoodList),
				openSlots = openSlots,
			};
			FOM_PerfRecord("FOM_Feed precompute", FOM_PerfNowMs() - precomputeStartMs,
				"cache-miss foods=" .. tostring(table.getn(precomputedFoodList)) .. " openSlots=" .. tostring(openSlots), false);
		end

		local fastPickStartMs = FOM_PerfNowMs();
		foodBag, foodItem = FOM_TryPickSinglePrecomputedFood(precomputedFoodList, excludedItemIds, (FOM_Config.AvoidUsefulFood and false or true));
		if (foodBag ~= nil) then
			FOM_LastChoiceReason = "single candidate fast-path";
			FOM_PerfRecord("FOM_SingleCandidate", FOM_PerfNowMs() - fastPickStartMs, "hit", false);
		else
			FOM_PerfRecord("FOM_SingleCandidate", FOM_PerfNowMs() - fastPickStartMs, "miss", false);
		end

		if (foodBag == nil) then
		local findStartMs = FOM_PerfNowMs();
		foodBag, foodItem = FOM_NewFindFood(nil, excludedItemIds, precomputedFoodList, openSlots);
		FOM_PerfRecord("FOM_NewFindFood primary", FOM_PerfNowMs() - findStartMs, "found=" .. tostring(foodBag ~= nil), false);
		end
		end
	end

	local fallbackBag, fallbackItem = nil, nil;
	if (not manualFood and foodBag == nil and FOM_Config.Fallback) then
		local fallbackStartMs = FOM_PerfNowMs();
		fallbackBag, fallbackItem = FOM_NewFindFood(1, excludedItemIds, precomputedFoodList, openSlots);
		FOM_PerfRecord("FOM_NewFindFood fallback", FOM_PerfNowMs() - fallbackStartMs, "found=" .. tostring(fallbackBag ~= nil), false);
	end
	
	if ( foodBag == nil) then
		if (fallbackBag) then
			foodBag, foodItem = fallbackBag, fallbackItem;
			if (FOM_LastChoiceReason == nil or FOM_LastChoiceReason == "") then
				FOM_LastChoiceReason = "fallback to useful food";
			else
				FOM_LastChoiceReason = FOM_LastChoiceReason .. ", fallback to useful food";
			end
		else
			-- No Food Could be Found
			GFWUtils.Print(string.format(FOM_ERROR_NO_FOOD, pet));
			FOM_LastChoiceReason = nil;
			FOM_PerfRecord("FOM_Feed total", FOM_PerfNowMs() - feedStartMs, "result=no-food", true);
			return false;
		end
	end
		
	local prepareStartMs = FOM_PerfNowMs();
	FOM_LastFood = GetContainerItemLink(foodBag, foodItem);
		local selectedId = FOM_IDFromLink(FOM_LastFood)
		FOM_SetCachedAutoChoice(foodBag, foodItem, selectedId)
		local selectedFoodLevel = FOM_GetFoodLevelOverride(selectedId);
		if (selectedFoodLevel == nil and type(MTH_FEED_GetFoodLevel) == "function") then
			selectedFoodLevel = MTH_FEED_GetFoodLevel(selectedId);
		end
		local coreAttemptId = FOM_CoreBeginAttempt({
			itemId = selectedId,
			itemName = FOM_NameFromLink(FOM_LastFood),
			itemLink = tostring(FOM_LastFood or ""),
			source = sourceTag,
			petId = tostring(petInfo and petInfo.id or ""),
			petName = tostring(pet or ""),
			family = tostring(petInfo and petInfo.family or ""),
			petLevel = tonumber(petInfo and petInfo.level) or nil,
			foodLevel = selectedFoodLevel,
		})
		FOM_PerfRecord("FOM_Feed prepare", FOM_PerfNowMs() - prepareStartMs, "itemId=" .. tostring(selectedId), false);
		FOM_Trace("selected food link='" .. tostring(FOM_LastFood)
			.. "' itemId=" .. tostring(selectedId)
			.. " bag=" .. tostring(foodBag)
			.. " slot=" .. tostring(foodItem)
			.. " reason='" .. tostring(FOM_LastChoiceReason or "") .. "'")
	
	GFWUtils.DebugLog("Picked "..FOM_LastFood.." (bag "..foodBag..", slot "..foodItem..") for feeding.");
	if (FOM_Config.Debug) then
		-- don't actually feed anything, just show what we would choose
		FOM_PerfRecord("FOM_Feed total", FOM_PerfNowMs() - feedStartMs, "result=debug", true);
		return false;
	end
	
	-- Actually feed the item to the pet
	local dropStartMs = FOM_PerfNowMs();
	PickupContainerItem(foodBag, foodItem);
	FOM_Trace("feed execute pickup bag=" .. tostring(foodBag)
		.. " slot=" .. tostring(foodItem)
		.. " cursorHasItem=" .. tostring(CursorHasItem() and true or false))
	if ( CursorHasItem() ) then
		MTH_FEED_SuppressChatUntil = (GetTime() or 0) + 2.0;
		MTH_FEED_SuppressChatFoodName = FOM_NameFromLink(FOM_LastFood);
		MTH_FEED_SuppressCoreDropHook = true;
		local ok = pcall(DropItemOnUnit, "pet");
		MTH_FEED_SuppressCoreDropHook = nil;
		if (not ok) then
			FOM_Trace("feed execute drop on pet failed during protected call");
		end
		FOM_Trace("feed execute drop on pet cursorHasItemAfterDrop=" .. tostring(CursorHasItem() and true or false))
	end
	FOM_PerfRecord("FOM_Feed drop", FOM_PerfNowMs() - dropStartMs, "cursor=" .. tostring(CursorHasItem() and true or false), false);
	if (coreAttemptId and type(MTH_FEED_RecordClientDropResult) == "function") then
		pcall(MTH_FEED_RecordClientDropResult, coreAttemptId, {
			consumedFromCursor = (CursorHasItem() and false or true),
		})
	end
	if ( CursorHasItem() ) then
		FOM_Trace("feed execute immediate-fail item stayed on cursor; likely rejected before combat log/error parse")
		PickupContainerItem(foodBag, foodItem);
		FOM_CoreRecordReject(coreAttemptId, "client-drop-fail", nil);
		FOM_CoreFinalizeAttempt(coreAttemptId, "rejected", "client-drop-fail");
		FOM_Trace("feed execute returned item to bag")
		FOM_PerfRecord("FOM_Feed total", FOM_PerfNowMs() - feedStartMs, "result=cursor-fail", true);
		return false;
	else
		FOM_Trace("feed execute accepted by client (item consumed from cursor)")
		if (selectedId ~= nil) then
			excludedItemIds[selectedId] = true;
		end
		FOM_LastFeedAttempt = {
			startedAt = GetTime() or 0,
			petName = tostring(pet or ""),
			itemId = selectedId,
			itemLink = tostring(FOM_LastFood or ""),
			coreAttemptId = coreAttemptId,
			alertMode = tostring(FOM_Config.Alert or ""),
			petLevel = tonumber(petInfo and petInfo.level) or nil,
			retryCount = retryCount,
			excludedItemIds = excludedItemIds,
			manualFood = manualFood,
			loggedFirstCheck = false,
		}
		FOM_State.ShouldFeed = nil;
		FOM_Trace("feed alert deferred until confirmation itemId=" .. tostring(selectedId)
			.. " pet='" .. tostring(pet or "")
			.. "' mode='" .. tostring(FOM_Config.Alert or "") .. "'")
		FOM_PerfRecord("FOM_Feed total", FOM_PerfNowMs() - feedStartMs, "result=ok itemId=" .. tostring(selectedId), true);
		return true;
	end
end

function FOM_RandomEmote()
	
	local randomEmotes = {};
	if (UnitSex("pet") == 2) then
		randomEmotes = GFWTable.Merge(randomEmotes, FOM_Emotes["male"]);
	elseif (UnitSex("pet") == 3) then
		randomEmotes = GFWTable.Merge(randomEmotes, FOM_Emotes["female"]);
	end
	
	randomEmotes = GFWTable.Merge(randomEmotes, FOM_Emotes[FOM_GetLegacyFamilyKey()]);
	randomEmotes = GFWTable.Merge(randomEmotes, FOM_Emotes[FOM_NameFromLink(FOM_LastFood)]);
	randomEmotes = GFWTable.Merge(randomEmotes, FOM_Emotes["any"]);
	
	return randomEmotes[math.random(table.getn(randomEmotes))];

end

function FOM_FindSpecificFood(foodName)
	for bagNum = 0, 4 do
		if (not FOM_BagIsQuiver(bagNum) ) then
		-- skip bags that can't contain food
		
			local bagSize = GetContainerNumSlots(bagNum);
			for itemNum = 1, bagSize do
		
				itemName = FOM_GetItemName(bagNum, itemNum);
				if ( itemName == foodName ) then
					return bagNum, itemNum;
				end
			
			end
		end
	end
	return nil;
end

function FOM_IsTemporaryFood(itemLink)
	local numericItemId = FOM_IDFromLink(itemLink);
	if (numericItemId ~= nil and FOM_TEMP_FOOD_CACHE[numericItemId] ~= nil) then
		return FOM_TEMP_FOOD_CACHE[numericItemId] and true or false;
	end
	
	local _, _, link = string.find(itemLink, "(item:%d+:%d+:%d+:%d+)");
	if (link == nil or link == "") then 
		if (numericItemId ~= nil) then
			FOM_TEMP_FOOD_CACHE[numericItemId] = false;
		end
		return false; 
	end
	MTH_FOM_Tooltip:ClearLines();
	MTH_FOM_Tooltip:SetHyperlink(link);
	if (MTH_FOM_TooltipTextLeft2:GetText() == ITEM_CONJURED) then
		if (numericItemId ~= nil) then
			FOM_TEMP_FOOD_CACHE[numericItemId] = true;
		end
		return true;
	else
		if (numericItemId ~= nil) then
			FOM_TEMP_FOOD_CACHE[numericItemId] = false;
		end
		return false;
	end	

end

local function FOM_EnsureQuestScanFresh(maxAgeSeconds)
	if (not FOM_Config.AvoidQuestFood) then
		return;
	end
	local now = (type(GetTime) == "function") and (GetTime() or 0) or 0;
	local age = now - (tonumber(FOM_LAST_QUEST_SCAN_AT) or 0);
	local maxAge = tonumber(maxAgeSeconds) or 1.5;
	if (age < maxAge) then
		return;
	end
	FOM_ScanQuests();
	FOM_LAST_QUEST_SCAN_AT = now;
end

function FOM_FlatFoodList()
	local flatStartMs = FOM_PerfNowMs();
	local foodList = {};
	local overflowFoodList = {};
	local scanned = 0;
	local inDiet = 0;
	local compatibleCount = 0;
	local overflowCompatibleCount = 0;
	local rejectedByException = 0;
	local rejectedByLevelOverride = 0;
	local rejectedByQuarantine = 0;
	local unknownLevelCandidates = 0;
	FOM_Quantity = { };
	FOM_EnsureQuestScanFresh(1.5);
	local petInfo = MTH_FOM_GetCorePetInfo();
	local petLevel = tonumber(petInfo and petInfo.level) or 0;
	local familyKey = FOM_GetFamilyKeyFromInfo(petInfo);
	for bagNum = 0, 4 do
		if (not FOM_BagIsQuiver(bagNum) ) then
		-- skip bags that can't contain food
			for itemNum = 1, GetContainerNumSlots(bagNum) do
				local itemLink = GetContainerItemLink(bagNum, itemNum);
				if (itemLink) then
					scanned = scanned + 1;
					local itemID = FOM_IDFromLink(itemLink);
					local _, itemCount = GetContainerItemInfo(bagNum, itemNum);
					if ( FOM_IsInDiet(itemID) ) then
						inDiet = inDiet + 1;
						if (FOM_FoodIDsToNames == nil) then
							FOM_FoodIDsToNames = {};
						end
						local name = FOM_NameFromLink(itemLink);
						FOM_FoodIDsToNames[itemID] = name;
						local isUseful = FOM_IsUsefulFood(itemID, itemCount);
						local isKnownFood = FOM_IsKnownFood(itemID);
						local foodLevel = FOM_GetFoodLevelOverride(itemID);
						if (foodLevel == nil and type(MTH_FEED_GetFoodLevel) == "function") then
							foodLevel = MTH_FEED_GetFoodLevel(itemID);
						end

						local isExceptionReject = false;
						local isLevelOverrideReject = not FOM_IsItemPetLevelCompatible(itemID, petLevel);
						local isQuarantineReject = FOM_IsQuarantined(itemID, petLevel, familyKey);
						if (isExceptionReject) then
							rejectedByException = rejectedByException + 1;
						end
						if (isLevelOverrideReject) then
							rejectedByLevelOverride = rejectedByLevelOverride + 1;
						end
						if (isQuarantineReject) then
							rejectedByQuarantine = rejectedByQuarantine + 1;
						end

						local isCompatible = true;
						local isAbovePreferredLevel = false;
						local hasKnownLevel = (tonumber(foodLevel) ~= nil);
						if (not hasKnownLevel) then
							unknownLevelCandidates = unknownLevelCandidates + 1;
						end

						if (isCompatible and not isExceptionReject and not isLevelOverrideReject and not isQuarantineReject) then
							compatibleCount = compatibleCount + 1;
							local foodQuality = tonumber(foodLevel);
							if (foodQuality == nil) then
								if (FOM_Config.PreferHigherQuality) then
									foodQuality = FOM_UNKNOWN_QUALITY_FOR_DESC;
								else
									foodQuality = FOM_UNKNOWN_QUALITY_FOR_ASC;
								end
							end
							table.insert(foodList, {bag=bagNum, slot=itemNum, link=itemLink, itemId=itemID, count=itemCount, quality=foodQuality, useful=isUseful, temp=FOM_IsTemporaryFood(itemLink), knownLevel=hasKnownLevel});
						elseif (isAbovePreferredLevel and not isExceptionReject and not isLevelOverrideReject and not isQuarantineReject) then
							overflowCompatibleCount = overflowCompatibleCount + 1;
							local overflowQuality = tonumber(foodLevel);
							if (overflowQuality == nil) then
								if (FOM_Config.PreferHigherQuality) then
									overflowQuality = FOM_UNKNOWN_QUALITY_FOR_DESC;
								else
									overflowQuality = FOM_UNKNOWN_QUALITY_FOR_ASC;
								end
							end
							table.insert(overflowFoodList, {bag=bagNum, slot=itemNum, link=itemLink, itemId=itemID, count=itemCount, quality=overflowQuality, useful=isUseful, temp=FOM_IsTemporaryFood(itemLink), overflow=true, knownLevel=hasKnownLevel});
						end
					end
				end
			end
		end
	end
	if (table.getn(foodList) == 0 and table.getn(overflowFoodList) > 0) then
		foodList = overflowFoodList;
	end
	FOM_Trace("flat food scan scanned=" .. tostring(scanned)
		.. " inDiet=" .. tostring(inDiet)
		.. " compatible=" .. tostring(compatibleCount)
		.. " overflowCompatible=" .. tostring(overflowCompatibleCount)
		.. " exceptionRejects=" .. tostring(rejectedByException)
		.. " levelOverrideRejects=" .. tostring(rejectedByLevelOverride)
		.. " quarantineRejects=" .. tostring(rejectedByQuarantine)
		.. " unknownLevel=" .. tostring(unknownLevelCandidates)
		.. " candidates=" .. tostring(table.getn(foodList)))
	if (FOM_PERF_TRACE_ENABLED) then
		FOM_PerfRecord("FOM_FlatFoodList", FOM_PerfNowMs() - flatStartMs,
			"scanned=" .. tostring(scanned)
			.. " inDiet=" .. tostring(inDiet)
			.. " candidates=" .. tostring(table.getn(foodList)),
			false);
	end
	return foodList;
end

function FOM_NewFindFood(fallback, excludedItemIds, precomputedFoodList, openSlotsOverride)
	local findStartMs = FOM_PerfNowMs();
	local FlatFoodList = nil;
	if (type(precomputedFoodList) == "table") then
		FlatFoodList = FOM_CloneFoodList(precomputedFoodList);
	else
		FlatFoodList = FOM_FlatFoodList();
	end
	local initialCount = table.getn(FlatFoodList)
	local reasonParts = {};
	if (initialCount <= 0) then
		FOM_LastChoiceReason = nil;
		if (FOM_PERF_TRACE_ENABLED) then
			FOM_PerfRecord("FOM_NewFindFood", FOM_PerfNowMs() - findStartMs,
				"fallback=" .. tostring(fallback and true or false)
				.. " initial=0 final=0",
				false);
		end
		return nil;
	end
	local petInfo = MTH_FOM_GetCorePetInfo();
	local petLevel = tonumber(petInfo and petInfo.level) or 0;

	if (petLevel >= FOM_REQUIRE_KNOWN_LEVEL_PET_LEVEL) then
		local knownCount = 0;
		for _, foodInfo in FlatFoodList do
			if (foodInfo.knownLevel) then
				knownCount = knownCount + 1;
			end
		end
		if (knownCount > 0) then
			local knownOnly = {};
			for _, foodInfo in FlatFoodList do
				if (foodInfo.knownLevel) then
					table.insert(knownOnly, foodInfo);
				end
			end
			FlatFoodList = knownOnly;
			table.insert(reasonParts, "known-level required at high pet level");
		end
	end

	if (type(excludedItemIds) == "table") then
		local allowedFoods = {};
		local excludedCount = 0;
		for _, foodInfo in FlatFoodList do
			local id = tonumber(foodInfo.itemId);
			if (id ~= nil and excludedItemIds[id]) then
				excludedCount = excludedCount + 1;
			else
				table.insert(allowedFoods, foodInfo);
			end
		end
		if (excludedCount > 0) then
			FlatFoodList = allowedFoods;
			table.insert(reasonParts, "excluded failed foods=" .. tostring(excludedCount));
		end
	end
	
	-- if there are any conjured foods, drop everything else from the list
	local tempFoodsOnly = {};
	for _, foodInfo in FlatFoodList do
		if (foodInfo.temp) then
			table.insert(tempFoodsOnly, foodInfo);
		end
	end
	if (table.getn(tempFoodsOnly) > 0) then
		FlatFoodList = tempFoodsOnly;
		table.insert(reasonParts, "conjured food first");
	end
	local postConjuredCount = table.getn(FlatFoodList)
	
	
	table.sort(FlatFoodList, FOM_SortCount); -- small stacks first
	local openSlots = tonumber(openSlotsOverride);
	if (openSlots == nil) then
		openSlots = FOM_NumOpenBagSlots();
	end
	if (openSlots > FOM_Config.KeepOpenSlots) then
		if (FOM_Config.PreferHigherQuality) then
			table.sort(FlatFoodList, FOM_SortQualityDescending); -- higher quality first
			table.insert(reasonParts, "higher quality preferred");
		else
			table.sort(FlatFoodList, FOM_SortQualityAscending); -- lower quality first
			table.insert(reasonParts, "lower quality preferred");
		end
	else
		table.insert(reasonParts, "small stack to free bag space");
	end
	if (FOM_Config.AvoidUsefulFood and not fallback) then
		local nonUsefulFoodsOnly = {};
		for _, foodInfo in FlatFoodList do
			if (not foodInfo.useful) then
				table.insert(nonUsefulFoodsOnly, foodInfo);
			end
		end
		FlatFoodList = nonUsefulFoodsOnly;
		table.insert(reasonParts, "avoiding useful food");
	else
		table.sort(FlatFoodList, FOM_SortUseful); -- non-useful first
		if (fallback) then
			table.insert(reasonParts, "fallback allows useful food");
		end
	end
	FOM_Trace("find food fallback=" .. tostring(fallback and true or false)
		.. " initial=" .. tostring(initialCount)
		.. " postConjured=" .. tostring(postConjuredCount)
		.. " postFilters=" .. tostring(table.getn(FlatFoodList))
		.. " reasons='" .. tostring(table.concat(reasonParts, ", ")) .. "'")
	if (FOM_PERF_TRACE_ENABLED) then
		FOM_PerfRecord("FOM_NewFindFood", FOM_PerfNowMs() - findStartMs,
			"fallback=" .. tostring(fallback and true or false)
			.. " initial=" .. tostring(initialCount)
			.. " final=" .. tostring(table.getn(FlatFoodList)),
			false);
	end
		
	for _, foodInfo in FlatFoodList do
		if (foodInfo.overflow) then
			if (table.getn(reasonParts) > 0) then
				FOM_LastChoiceReason = table.concat(reasonParts, ", ") .. ", overflow level fallback";
			else
				FOM_LastChoiceReason = "overflow level fallback";
			end
		elseif (table.getn(reasonParts) > 0) then
			FOM_LastChoiceReason = table.concat(reasonParts, ", ");
		else
			FOM_LastChoiceReason = nil;
		end
		FOM_Trace("find food result bag=" .. tostring(foodInfo.bag)
			.. " slot=" .. tostring(foodInfo.slot)
			.. " quality=" .. tostring(foodInfo.quality)
			.. " useful=" .. tostring(foodInfo.useful and true or false)
			.. " temp=" .. tostring(foodInfo.temp and true or false))
		return foodInfo.bag, foodInfo.slot;
	end
	FOM_LastChoiceReason = nil;
	FOM_Trace("find food result: none")
	
	return nil;
end

function FOM_SortCount(a, b)
	return a.count < b.count;
end

function FOM_SortQualityDescending(a, b)
	return a.quality > b.quality;
end

function FOM_SortQualityAscending(a, b)
	return a.quality < b.quality;
end

function FOM_SortUseful(a, b)
	if (a.useful) then
		aUseful = 1;
	else
		aUseful = 0;
	end
	if (b.useful) then
		bUseful = 1;
	else
		bUseful = 0;
	end
	return aUseful < bUseful;
end

function FOM_IsUsefulFood(itemID, quantity)
	local foodName = GetItemInfo(itemID);
	if (foodName == nil) then
		GFWUtils.DebugLog("Can't get info for item ID "..itemID..", assuming it's OK to eat.");
		return false;
	end
	if (FOM_Cooking and FOM_Cooking[FOM_RealmPlayer] and FOM_Cooking[FOM_RealmPlayer][itemID]) then
		if (FOM_Cooking[FOM_RealmPlayer][itemID] >= FOM_Config.SaveForCookingLevel) then
			GFWUtils.DebugLog("Skipping "..quantity.."x "..foodName.."; is good for cooking.");
			return true;
		end
	end
	if (FOM_Config.AvoidQuestFood) then
		if (FOM_QuestFood ~= nil and FOM_QuestFood[FOM_RealmPlayer] ~= nil and FOM_QuestFood[FOM_RealmPlayer][foodName]) then
			if (FOM_Quantity[foodName] == nil) then
				FOM_Quantity[foodName] = quantity;
			else
				FOM_Quantity[foodName] = FOM_Quantity[foodName] + quantity;
			end
			if (FOM_Quantity[foodName] > FOM_QuestFood[FOM_RealmPlayer][foodName]) then
				GFWUtils.DebugLog("Not skipping "..quantity.."x "..foodName.."; is needed for quest, but we have more than enough.");
				return false;
			else
				GFWUtils.DebugLog("Skipping "..quantity.."x "..foodName.."; is needed for quest.");
				return true;
			end
		end
	end
	if (FOM_Config.AvoidBonusFood and FOM_IsInDiet(itemID, FOM_DIET_BONUS)) then
		GFWUtils.DebugLog("Skipping "..quantity.."x "..foodName.."; has bonus effect when eaten by player.");
		return true;
	end
	--GFWUtils.DebugLog("Not skipping "..quantity.."x "..foodName.."; doesn't have other uses.");
	return false;
end

function FOM_NumOpenBagSlots()
	local openSlots = 0;
	for bagNum = 0, 4 do
		if (not FOM_BagIsQuiver(bagNum) ) then
		-- skip bags that can't contain food

			local bagSize = GetContainerNumSlots(bagNum);
			for itemNum = 1, bagSize do
				if (GetContainerItemInfo(bagNum, itemNum) == nil) then
					openSlots = openSlots + 1;
				end
			end
		end
	end
	return openSlots;
end

function FOM_IsInDiet(food, dietList)

	if ( dietList == nil ) then
		dietList = FOM_GetPetDietList();
	end
	if ( dietList == nil ) then
		return false;
	end
	if (type(dietList) ~= "table") then
		dietList = {dietList};
	end
	for _, diet in dietList do 
		diet = FOM_NormalizeDietToken(diet);
		if (diet == nil) then
			diet = "";
		end
		if (FOM_Foods[diet] == nil) then
			GFWUtils.DebugLog("FOM_Foods[diet] == nil");
		end
		if (FOM_RemovedFoods ~= nil and FOM_RemovedFoods[diet] ~= nil and GFWTable.IndexOf(FOM_RemovedFoods[diet], food) ~= 0) then
			return false;
		end
		if (FOM_AddedFoods ~= nil and FOM_AddedFoods[diet] ~= nil and GFWTable.IndexOf(FOM_AddedFoods[diet], food) ~= 0) then
			return true;
		end
		if (GFWTable.IndexOf(FOM_Foods[diet], food) ~= 0) then
			return true;
		end
	end
	
	return false;

end

function FOM_IsKnownFood(food)
	return FOM_IsInDiet(food, {FOM_DIET_MEAT, FOM_DIET_FISH, FOM_DIET_BREAD, FOM_DIET_CHEESE, FOM_DIET_FUNGUS, FOM_DIET_FRUIT});
end

-- Get Item Name
function FOM_GetItemName(bag, slot)

	local itemLink = GetContainerItemLink(bag, slot);
	if (itemLink) then
		return FOM_NameFromLink(itemLink);
	else
		return "";
	end
end

function MTH_PetRenameHook(newName)

	FOM_CheckSetup();
	local oldName = FOM_LastPetName;

	-- move our saved food quality data to be indexed under the new name
	if (type(FOM_FoodQuality) == "table" and type(FOM_RealmPlayer) == "string" and FOM_RealmPlayer ~= "" and type(FOM_FoodQuality[FOM_RealmPlayer]) == "table") then
		FOM_FoodQuality[FOM_RealmPlayer][newName] = FOM_FoodQuality[FOM_RealmPlayer][FOM_LastPetName];
		FOM_FoodQuality[FOM_RealmPlayer][FOM_LastPetName] = nil;
	end
	if (type(MTH_PETS_RecordPetRename) == "function") then
		MTH_PETS_RecordPetRename(oldName, newName, "pet-lifecycle:rename");
	end
	FOM_LastPetName = newName;

	local renameDelegate = (_G and _G["MTH_PETL_Original_PetRename"]) or (_G and _G["MTH_PETS_CoreOriginal_PetRename"]);
	if (type(renameDelegate) == "function" and renameDelegate ~= MTH_PetRenameHook) then
		renameDelegate(newName);
	end
	
end

function MTH_PetAbandonHook()
	
	FOM_CheckSetup();
	local abandonedPetName = FOM_LastPetName;
	if (type(MTH_PETS_RecordPetAbandon) == "function") then
		MTH_PETS_RecordPetAbandon("pet-lifecycle:abandon", abandonedPetName);
	end

	-- delete saved food-quality data for this pet so we don't bloat SavedVariables
	FOM_FoodQuality[FOM_RealmPlayer][FOM_LastPetName] = nil;
	FOM_LastPetName = nil;

	MTH_PETL_Original_PetAbandon();
	
end

FOM_PetRename = MTH_PetRenameHook;
FOM_PetAbandon = MTH_PetAbandonHook;

-- The icon for the cooking spell is unique and the same in all languages; use that to determine the localized name.
function FOM_CookingSpellName()
	FOM_COOKING_ICON = "Interface\\Icons\\INV_Misc_Food_15"; 
	if (FOM_COOKING_NAME == nil) then
		local spellName;
		local i = 0;
		repeat
			i = i + 1;
			spellName = GetSpellName(i, BOOKTYPE_SPELL);
			if (spellName ~= nil and GetSpellTexture(i, BOOKTYPE_SPELL) == FOM_COOKING_ICON) then
				FOM_COOKING_NAME = spellName;
				return FOM_COOKING_NAME;
			end
		until (spellName == nil);
	end
	return FOM_COOKING_NAME;	
end

function FOM_BagIsQuiver(bagNum)
	local invSlotID = ContainerIDToInventoryID(bagNum);
	local bagLink = GetInventoryItemLink("player", invSlotID);
	if (bagLink == nil) then
		return false;	
	end
	local _, _, itemID  = string.find(bagLink, "item:(%d+)");
	if (tonumber(itemID)) then
		itemID = tonumber(itemID);
		local name, link, rarity, minLevel, type, subType, stackCount, equipLoc = GetItemInfo(itemID);
		if (type == "Ammo Pouch" or type == "Quiver" or subType == "Ammo Pouch" or subType == "Quiver") then
			return true;
		end
		if (type == FOM_AMMO_POUCH or type == FOM_QUIVER or subType == FOM_AMMO_POUCH or subType == FOM_QUIVER) then
			return true;
		end
	end	
	return false;
end

function FOM_IDFromLink(itemLink)
	if (itemLink == nil) then return nil; end
	local _, _, itemID  = string.find(itemLink, "item:(%d+)");
	if (tonumber(itemID)) then
		return tonumber(itemID);
	else
		return nil;
	end
end

function FOM_NameFromLink(itemLink)
	if (itemLink == nil) then return nil; end
	local _, _, name = string.find(itemLink, "%[(.-)%]"); 
	return name;
end


