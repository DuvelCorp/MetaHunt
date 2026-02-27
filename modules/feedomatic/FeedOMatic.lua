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

local function FOM_CoreFeedReady()
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
				if (type(MTH_FEED_RecordUnknownFoodCandidate) == "function") then
					pcall(MTH_FEED_RecordUnknownFoodCandidate, {
						itemId = itemID,
						itemName = itemName,
						itemLink = itemLink,
						source = "vendor-scan",
						observedFoodLevel = (type(MTH_FEED_GetFoodLevel) == "function") and MTH_FEED_GetFoodLevel(itemID) or nil,
						observedDietHint = nil,
						evidenceType = "vendor-scan",
					});
				end
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

function FOM_FeedButton_OnClick()
	if (arg1 == "RightButton") then
		if (MTH_OpenOptions) then
			MTH_OpenOptions("FeedOMatic");
		end
	else
		FOM_Feed();
	end
end

function FOM_FeedButton_OnEnter()
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

function FOM_FeedButton_OnLeave()
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
	SlashCmdList["FEEDOMATIC"] = function(msg)
		if MTH_IsModuleEnabled and not MTH_IsModuleEnabled("feedomatic") then
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

			if (FOM_FeedButton == nil) then
				FOM_FeedButton = CreateFrame("Button", "FOM_FeedButton", PetFrameHappiness);
				FOM_FeedButton:SetAllPoints(PetFrameHappiness);
				FOM_FeedButton:RegisterForClicks("LeftButtonUp", "RightButtonUp");
				FOM_FeedButton:SetScript("OnClick", FOM_FeedButton_OnClick);
				FOM_FeedButton:SetScript("OnEnter", FOM_FeedButton_OnEnter);
				FOM_FeedButton:SetScript("OnLeave", FOM_FeedButton_OnLeave);
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

		if (isLowLevelError) then
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
	
		-- clean up the FOM_FoodQuality sub-tables in case we missed you abandoning a pet
		FOM_CheckSetup();
		local stabledPetNames = nil;
		if (type(MTH_GetStablePetNames) == "function") then
			stabledPetNames = MTH_GetStablePetNames();
		end
		if (stabledPetNames == nil) then
			stabledPetNames = {};
		end
		local orphanedPetNames = {};
		for savedPetName in FOM_FoodQuality[FOM_RealmPlayer] do
			if (stabledPetNames == nil) then
				GFWUtils.DebugLog("stabledPetNames == nil");
			end
			if (stabledPetNames ~= nil and GFWTable.IndexOf(stabledPetNames, savedPetName) == 0) then
				table.insert(orphanedPetNames, savedPetName);
			end
		end
		for _, orphanedPet in orphanedPetNames do
			FOM_FoodQuality[FOM_RealmPlayer][orphanedPet] = nil;
		end
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

function FOM_OnUpdate(elapsed)
	
	_, realClass = UnitClass("player");
	if (realClass ~= "HUNTER") then return; end

	-- If it's been more than a second since our last tradeskill update,
	-- we can allow the event to process again.
	FOM_TradeSkillLock.EventTimer = FOM_TradeSkillLock.EventTimer + elapsed;
	if (FOM_TradeSkillLock.Locked) then
		FOM_TradeSkillLock.EventCooldown = FOM_TradeSkillLock.EventCooldown + elapsed;
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
			FOM_CoreFinalizeAttempt(FOM_LastFeedAttempt.coreAttemptId, "accepted", "accepted");
			FOM_Trace("feed outcome accepted-with-buff itemId=" .. tostring(FOM_LastFeedAttempt.itemId)
				.. " pet='" .. tostring(FOM_LastFeedAttempt.petName or "")
				.. "' elapsed=" .. string.format("%.2f", elapsedSinceFeed));
			FOM_LastFeedAttempt = nil;
		elseif (elapsedSinceFeed >= 2.50) then
			if (FOM_LastFeedAttempt.coreAttemptId and type(MTH_FEED_RecordBuffOutcome) == "function") then
				pcall(MTH_FEED_RecordBuffOutcome, FOM_LastFeedAttempt.coreAttemptId, { hasFeedBuff = false, elapsed = elapsedSinceFeed });
			end
			FOM_CoreRecordReject(FOM_LastFeedAttempt.coreAttemptId, "no-buff", nil);
			FOM_CoreFinalizeAttempt(FOM_LastFeedAttempt.coreAttemptId, "rejected", "no-buff");
			FOM_Trace("feed outcome no-eating-buff itemId=" .. tostring(FOM_LastFeedAttempt.itemId)
				.. " pet='" .. tostring(FOM_LastFeedAttempt.petName or "")
				.. "' elapsed=" .. string.format("%.2f", elapsedSinceFeed)
				.. " (likely not accepted by pet)");
			FOM_LastFood = nil;
			FOM_LastFeedAttempt = nil;
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
						FOMTooltip:SetUnitBuff("player", buffIndex+1);
						local msg = FOMTooltipTextLeft1:GetText();
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
function FOM_Feed(aFood)
	if MTH_IsModuleEnabled and not MTH_IsModuleEnabled("feedomatic") then
		if DEFAULT_CHAT_FRAME and DEFAULT_CHAT_FRAME.AddMessage then
			MTH:Print("[FOM WRAP] FOM_Feed blocked: module disabled", "debug")
		end
		return;
	end
		
	-- Make sure we have a feedable pet
	local petInfo = MTH_FOM_GetCorePetInfo();
	if not (petInfo and petInfo.liveExists) then 
		GFWUtils.Note(FOM_ERROR_NO_PET); 
		return;
	end
	if (petInfo.dead or (tonumber(petInfo.health) and tonumber(petInfo.health) <= 0)) then
		GFWUtils.Note(FOM_ERROR_PET_DEAD); 
		return;
	end
	if (FOM_GetPetDietList() == nil) then
		GFWUtils.Note(FOM_ERROR_NO_FEEDABLE_PET); 
		return;
	end
	if (UnitAffectingCombat("player") or UnitAffectingCombat("pet")) then
		GFWUtils.Note(FOM_ERROR_IN_COMBAT); 
		return;
	end
	
	-- Assign Variable
	local pet = (MTH_FOM_IsValidPetName(petInfo.name) and petInfo.name) or "Your pet";
	FOM_Trace("feed request pet='" .. tostring(pet)
		.. "' level=" .. tostring(petInfo.level)
		.. " happiness=" .. tostring(petInfo.happiness)
		.. " manualFood='" .. tostring(aFood or "") .. "'")
	
	FOM_CheckSetup();
	if (FOM_LastPetName == nil or FOM_LastPetName == "") then
		GFWUtils.DebugLog("Can't get pet info.");
		return;
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
	if (aFood ~= nil) then
		-- if told to feed a specific food, do so
		foodBag, foodItem = FOM_FindSpecificFood(aFood);
		if ( foodBag == nil) then
			-- No Food Could be Found
			GFWUtils.Print(string.format(FOM_ERROR_FOOD_NOT_FOUND, pet, aFood));
			return;
		end
		FOM_LastChoiceReason = "manual selection";
	else
		foodBag, foodItem = FOM_NewFindFood();
	end

	local fallbackBag, fallbackItem = FOM_NewFindFood(1);
	
	if ( foodBag == nil) then
		if (not FOM_Config.Fallback and fallbackBag) then
			local pronoun = FOM_PRONOUN_MALE;
			if (UnitSex("pet") == 3) then pronoun = FOM_PRONOUN_FEMALE; end
			GFWUtils.Print(string.format(FOM_ERROR_NO_FOOD_NO_FALLBACK, pet, pronoun));
			return;
		elseif (fallbackBag) then
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
			return;
		end
	end
		
	FOM_LastFood = GetContainerItemLink(foodBag, foodItem);
		local selectedId = FOM_IDFromLink(FOM_LastFood)
		local selectedFoodLevel = (type(MTH_FEED_GetFoodLevel) == "function") and MTH_FEED_GetFoodLevel(selectedId) or nil
		local coreAttemptId = FOM_CoreBeginAttempt({
			itemId = selectedId,
			itemName = FOM_NameFromLink(FOM_LastFood),
			itemLink = tostring(FOM_LastFood or ""),
			source = "feedomatic:auto",
			petId = tostring(petInfo and petInfo.id or ""),
			petName = tostring(pet or ""),
			family = tostring(petInfo and petInfo.family or ""),
			petLevel = tonumber(petInfo and petInfo.level) or nil,
			foodLevel = selectedFoodLevel,
		})
		FOM_Trace("selected food link='" .. tostring(FOM_LastFood)
			.. "' itemId=" .. tostring(selectedId)
			.. " bag=" .. tostring(foodBag)
			.. " slot=" .. tostring(foodItem)
			.. " reason='" .. tostring(FOM_LastChoiceReason or "") .. "'")
	
	GFWUtils.DebugLog("Picked "..FOM_LastFood.." (bag "..foodBag..", slot "..foodItem..") for feeding.");
	if (FOM_Config.Debug) then
		-- don't actually feed anything, just show what we would choose
		return;
	end
	
	-- Actually feed the item to the pet
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
	else
		FOM_Trace("feed execute accepted by client (item consumed from cursor)")
		FOM_LastFeedAttempt = {
			startedAt = GetTime() or 0,
			petName = tostring(pet or ""),
			itemId = selectedId,
			itemLink = tostring(FOM_LastFood or ""),
			coreAttemptId = coreAttemptId,
			loggedFirstCheck = false,
		}
		FOM_State.ShouldFeed = nil;
		-- Alert
		if ( FOM_Config.Alert == "chat") then
			GFWUtils.Print(string.format(FOM_FEEDING_EAT, pet, GFWUtils.Hilite(FOM_LastFood)));
		elseif ( FOM_Config.Alert == "emote") then
			SendChatMessage(string.format(FOM_FEEDING_FEED, pet, FOM_LastFood).. FOM_RandomEmote(), "EMOTE");
		end
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
	
	local _, _, link = string.find(itemLink, "(item:%d+:%d+:%d+:%d+)");
	if (link == nil or link == "") then 
		return false; 
	end
	FOMTooltip:ClearLines();
	FOMTooltip:SetHyperlink(link);
	if (FOMTooltipTextLeft2:GetText() == ITEM_CONJURED) then
		return true;
	else
		return false;
	end	

end

function FOM_FlatFoodList()
	local foodList = {};
	local overflowFoodList = {};
	local scanned = 0;
	local inDiet = 0;
	local compatibleCount = 0;
	local overflowCompatibleCount = 0;
	local rejectedByException = 0;
	FOM_Quantity = { };
	local petInfo = MTH_FOM_GetCorePetInfo();
	local petLevel = tonumber(petInfo and petInfo.level) or 0;
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
						local isKnownFood = (type(MTH_FEED_IsKnownFoodItem) == "function") and MTH_FEED_IsKnownFoodItem(itemID) or FOM_IsKnownFood(itemID);
						local foodLevel = (type(MTH_FEED_GetFoodLevel) == "function") and MTH_FEED_GetFoodLevel(itemID) or nil;
						if (not isKnownFood and type(MTH_FEED_RecordUnknownFoodCandidate) == "function") then
							pcall(MTH_FEED_RecordUnknownFoodCandidate, {
								itemId = itemID,
								itemName = name,
								itemLink = tostring(itemLink or ""),
								source = "bag-scan",
								observedFoodLevel = foodLevel,
								observedDietHint = nil,
								evidenceType = "bag-scan",
							});
						end

						local isExceptionReject = (type(MTH_FEED_IsExceptionReject) == "function") and MTH_FEED_IsExceptionReject(itemID) or false;
						if (isExceptionReject) then
							rejectedByException = rejectedByException + 1;
						end

						local isCompatible = true;
						local isAbovePreferredLevel = false;
						if (petLevel > 0 and foodLevel ~= nil) then
							if (type(MTH_FEED_GetFoodCompatibilityWindow) == "function") then
								local minAllowed, maxAllowed = MTH_FEED_GetFoodCompatibilityWindow(petLevel);
								local numericFood = tonumber(foodLevel) or 0;
								if (minAllowed ~= nil and numericFood < tonumber(minAllowed)) then
									isCompatible = false;
								end
								if (maxAllowed ~= nil and numericFood > tonumber(maxAllowed)) then
									isCompatible = false;
									isAbovePreferredLevel = true;
								end
							elseif (type(MTH_FEED_IsFoodCompatible) == "function") then
								isCompatible = MTH_FEED_IsFoodCompatible(petLevel, foodLevel);
							end
						end

						if (isCompatible and not isExceptionReject) then
							compatibleCount = compatibleCount + 1;
							local foodQuality = tonumber(foodLevel) or MAX_QUALITY;
							table.insert(foodList, {bag=bagNum, slot=itemNum, link=itemLink, count=itemCount, quality=foodQuality, useful=isUseful, temp=FOM_IsTemporaryFood(itemLink)});
						elseif (isAbovePreferredLevel and not isExceptionReject) then
							overflowCompatibleCount = overflowCompatibleCount + 1;
							local overflowQuality = tonumber(foodLevel) or MAX_QUALITY;
							table.insert(overflowFoodList, {bag=bagNum, slot=itemNum, link=itemLink, count=itemCount, quality=overflowQuality, useful=isUseful, temp=FOM_IsTemporaryFood(itemLink), overflow=true});
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
		.. " candidates=" .. tostring(table.getn(foodList)))
	return foodList;
end

function FOM_NewFindFood(fallback)
	local FlatFoodList = FOM_FlatFoodList();
	local initialCount = table.getn(FlatFoodList)
	local reasonParts = {};
	
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
	if (FOM_NumOpenBagSlots() > FOM_Config.KeepOpenSlots) then
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
		FOM_ScanQuests();
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


