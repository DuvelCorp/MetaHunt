local MTH_FEED_SCHEMA_VERSION = 3
local MTH_FEED_RECENT_LIMIT = 40

MTH_FEED_API_VERSION = 1

local MTH_FEED_Runtime = {
	nextAttemptId = 1,
	attempts = {},
	sessionFeedsByPetId = {},
}

local MTH_FEED_CORE_HOOK_BOUNDARY_KEY = "core-feed-tracking-hooks"
MTH_FEED_Original_DropItemOnUnit = MTH_FEED_Original_DropItemOnUnit or nil
local MTH_FEED_TrackerFrame = nil
local MTH_FEED_ActiveCoreAttemptId = nil
local MTH_FEED_BootstrapFrame = nil
local MTH_FEED_NameToItemCache = {}

local MTH_FEED_HARDCODED_LEVEL_RULES = {
	{ minPetLevel = 1, minFoodLevel = 1 },
	{ minPetLevel = 20, minFoodLevel = 5 },
	{ minPetLevel = 31, minFoodLevel = 15 },
	{ minPetLevel = 40, minFoodLevel = 25 },
	{ minPetLevel = 50, minFoodLevel = 35 },
	{ minPetLevel = 60, minFoodLevel = 45 },
}

MTH_FEED_TRACE = false

local function MTH_FEED_Trace(message)
	return
end

local function MTH_FEED_Now()
	return time()
end

local function MTH_FEED_Trim(text)
	local value = tostring(text or "")
	value = string.gsub(value, "^%s+", "")
	value = string.gsub(value, "%s+$", "")
	return value
end

local function MTH_FEED_SafeLower(text)
	return string.lower(MTH_FEED_Trim(text))
end

local function MTH_FEED_NormalizeItemName(text)
	local value = MTH_FEED_SafeLower(text)
	value = string.gsub(value, "[%[%]]", "")
	value = string.gsub(value, "^%s+", "")
	value = string.gsub(value, "%s+$", "")
	value = string.gsub(value, "%s+", " ")
	return value
end

local function MTH_FEED_IsHyperlinkText(linkText)
	if type(linkText) ~= "string" then
		return false
	end
	if string.find(linkText, "|Hitem:", 1, true) then
		return true
	end
	if string.find(linkText, "^item:%d+") then
		return true
	end
	return false
end

local function MTH_FEED_NormalizeItemLink(itemId, itemName, itemLink)
	local raw = MTH_FEED_Trim(itemLink)
	if raw ~= "" and MTH_FEED_IsHyperlinkText(raw) then
		return raw
	end

	local numericId = tonumber(itemId)
	if numericId then
		if type(MTH_GetClickableItemLink) == "function" then
			local clickable = MTH_GetClickableItemLink(numericId, itemName, false)
			if clickable and clickable ~= "" and MTH_FEED_IsHyperlinkText(tostring(clickable)) then
				return tostring(clickable)
			end
		end
		return "item:" .. tostring(numericId) .. ":0:0:0"
	end

	return nil
end

local function MTH_FEED_MigrateItemLinkShapes(store)
	if type(store) ~= "table" then
		return
	end

	if type(store.byPetId) == "table" then
		for _, petRow in pairs(store.byPetId) do
			if type(petRow) == "table" and type(petRow.byItemId) == "table" then
				for itemKey, itemRow in pairs(petRow.byItemId) do
					if type(itemRow) == "table" then
						local normalized = MTH_FEED_NormalizeItemLink(itemKey, itemRow.itemName, itemRow.itemLink)
						itemRow.itemLink = normalized
					end
				end
			end
		end
	end

	if type(store.unknownFoods) == "table" and type(store.unknownFoods.byItemId) == "table" then
		for itemKey, unknownRow in pairs(store.unknownFoods.byItemId) do
			if type(unknownRow) == "table" then
				local normalized = MTH_FEED_NormalizeItemLink(itemKey, unknownRow.itemName, unknownRow.itemLink)
				unknownRow.itemLink = normalized
			end
		end
	end
end

local function MTH_FEED_IndexBagFoods()
	if type(GetContainerNumSlots) ~= "function" or type(GetContainerItemLink) ~= "function" then
		return false
	end

	local cache = {}
	for bag = 0, 4 do
		local slots = tonumber(GetContainerNumSlots(bag)) or 0
		for slot = 1, slots do
			local link = GetContainerItemLink(bag, slot)
			if link then
				local itemId = nil
				local _, _, idText = string.find(tostring(link), "item:(%d+)")
				if idText then
					itemId = tonumber(idText)
				end

				local linkName = nil
				local _, _, parsedName = string.find(tostring(link), "|h%[([^%]]+)%]|h")
				if parsedName and parsedName ~= "" then
					linkName = parsedName
				end

				local infoName = nil
				if itemId and type(GetItemInfo) == "function" then
					infoName = GetItemInfo(itemId)
				end

				local resolvedName = infoName or linkName
				local key = MTH_FEED_NormalizeItemName(resolvedName)
				if key ~= "" then
					link = MTH_FEED_NormalizeItemLink(itemId, resolvedName, link)
					cache[key] = {
						itemId = itemId,
						itemLink = link,
						itemName = resolvedName,
						seenAt = MTH_FEED_Now(),
					}
				end
			end
		end
	end

	MTH_FEED_NameToItemCache = cache
	return true
end

local function MTH_FEED_HasPetFeedBuff()
	if type(UnitBuff) ~= "function" then
		return false
	end
	local index = 1
	local buff = UnitBuff("pet", index)
	while buff do
		if string.find(tostring(buff), "Ability_Hunter_BeastTraining", 1, true) then
			return true
		end
		index = index + 1
		buff = UnitBuff("pet", index)
	end
	return false
end

local function MTH_FEED_GetCursorItemSnapshot()
	if type(GetCursorInfo) ~= "function" then
		return nil, nil, nil, nil
	end
	local infoType, idOrLink, maybeLink = GetCursorInfo()
	if tostring(infoType or "") ~= "item" then
		return nil, nil, nil, nil
	end

	local itemId = tonumber(idOrLink)
	local itemLink = nil
	if type(maybeLink) == "string" and maybeLink ~= "" then
		itemLink = maybeLink
	elseif type(idOrLink) == "string" and string.find(idOrLink, "|Hitem:", 1, true) then
		itemLink = idOrLink
	end

	local itemName = nil
	local itemIcon = nil
	if itemId and type(GetItemInfo) == "function" then
		itemName, _, _, _, _, _, _, _, _, itemIcon = GetItemInfo(itemId)
	end
	if (not itemIcon or itemIcon == "") and itemId and type(GetItemIcon) == "function" then
		itemIcon = GetItemIcon(itemId)
	end
	itemLink = MTH_FEED_NormalizeItemLink(itemId, itemName, itemLink)

	return itemId, itemName, itemLink, itemIcon
end

local function MTH_FEED_FindItemByNameInBags(foodName)
	local target = MTH_FEED_NormalizeItemName(foodName)
	if target == "" then
		return nil, nil
	end
	if type(GetContainerNumSlots) ~= "function" or type(GetContainerItemLink) ~= "function" then
		return nil, nil
	end

	for bag = 0, 4 do
		local slots = tonumber(GetContainerNumSlots(bag)) or 0
		for slot = 1, slots do
			local link = GetContainerItemLink(bag, slot)
			if link then
				local linkName = nil
				local _, _, parsedName = string.find(tostring(link), "|h%[([^%]]+)%]|h")
				if parsedName and parsedName ~= "" then
					linkName = parsedName
				end

				local itemId = nil
				local _, _, idText = string.find(tostring(link), "item:(%d+)")
				if idText then
					itemId = tonumber(idText)
				end

				local itemName = nil
				if itemId and type(GetItemInfo) == "function" then
					itemName = GetItemInfo(itemId)
					if itemName and itemName ~= "" then
						itemName = tostring(itemName)
					end
				end

				local resolvedName = itemName or linkName
				if resolvedName and MTH_FEED_NormalizeItemName(resolvedName) == target then
					return itemId, link
				end
			end
		end
	end

	local cached = MTH_FEED_NameToItemCache and MTH_FEED_NameToItemCache[target] or nil
	if type(cached) == "table" then
		return cached.itemId, cached.itemLink
	end

	return nil, nil
end

local function MTH_FEED_FindItemIconInBags(itemId, itemName)
	if type(GetContainerNumSlots) ~= "function" or type(GetContainerItemLink) ~= "function" or type(GetContainerItemInfo) ~= "function" then
		return nil
	end

	local targetId = tonumber(itemId)
	local targetName = MTH_FEED_NormalizeItemName(itemName)
	for bag = 0, 4 do
		local slots = tonumber(GetContainerNumSlots(bag)) or 0
		for slot = 1, slots do
			local link = GetContainerItemLink(bag, slot)
			if link then
				local matched = false
				if targetId then
					local _, _, idText = string.find(tostring(link), "item:(%d+)")
					if tonumber(idText) == targetId then
						matched = true
					end
				end
				if not matched and targetName ~= "" then
					local _, _, parsedName = string.find(tostring(link), "|h%[([^%]]+)%]|h")
					if parsedName and MTH_FEED_NormalizeItemName(parsedName) == targetName then
						matched = true
					end
				end
				if matched then
					local texture = GetContainerItemInfo(bag, slot)
					if texture and texture ~= "" then
						return texture
					end
				end
			end
		end
	end

	return nil
end

local function MTH_FEED_GetAttemptElapsed(attemptId)
	local row = MTH_FEED_Runtime.attempts[attemptId]
	if type(row) ~= "table" then
		return nil
	end
	local now = (type(GetTime) == "function") and (GetTime() or 0) or 0
	local startedAt = tonumber(row.startedAt) or 0
	return now - startedAt
end

local function MTH_FEED_ClearActiveCoreAttempt(attemptId)
	if tostring(MTH_FEED_ActiveCoreAttemptId or "") == tostring(attemptId or "") then
		MTH_FEED_ActiveCoreAttemptId = nil
	end
end

local function MTH_FEED_HandleCoreReject(reason, rawMessage)
	local attemptId = MTH_FEED_ActiveCoreAttemptId
	if attemptId == nil then
		return
	end
	MTH_FEED_RecordRejectEvent(attemptId, {
		reason = reason,
		rawMessage = rawMessage,
	})
	MTH_FEED_FinalizeAttempt(attemptId, {
		outcome = "rejected",
		reason = reason,
	})
	MTH_FEED_ClearActiveCoreAttempt(attemptId)
end

local function MTH_FEED_HandleCoreAccept()
	local attemptId = MTH_FEED_ActiveCoreAttemptId
	if attemptId == nil then
		return
	end
	local elapsed = MTH_FEED_GetAttemptElapsed(attemptId)
	MTH_FEED_RecordBuffOutcome(attemptId, {
		hasFeedBuff = true,
		elapsed = elapsed,
	})
	MTH_FEED_FinalizeAttempt(attemptId, {
		outcome = "accepted",
		reason = "accepted",
	})
	MTH_FEED_ClearActiveCoreAttempt(attemptId)
end

local function MTH_FEED_EnsureActiveAttemptFromCursor(sourceTag)
	if MTH_FEED_ActiveCoreAttemptId then
		return MTH_FEED_ActiveCoreAttemptId
	end
	if not (CursorHasItem and CursorHasItem()) then
		return nil
	end

	local itemId, itemName, itemLink, itemIcon = MTH_FEED_GetCursorItemSnapshot()
	local pet = MTH_FEED_GetCurrentPetContext()
	if type(pet) ~= "table" then
		return nil
	end

	local attemptId = MTH_FEED_BeginAttempt({
		itemId = itemId,
		itemName = itemName,
		itemLink = itemLink,
		itemIcon = itemIcon,
		source = sourceTag or "core:ui-error",
		petId = pet.petId,
		petName = pet.petName,
		family = pet.family,
		petLevel = pet.level,
		foodLevel = itemId and MTH_FEED_GetFoodLevel(itemId) or nil,
	})
	if attemptId then
		MTH_FEED_ActiveCoreAttemptId = attemptId
		MTH_FEED_RecordClientDropResult(attemptId, { consumedFromCursor = false })
		MTH_FEED_Trace("Core tracker bootstrapped attempt from cursor id=" .. tostring(attemptId)
			.. " itemId=" .. tostring(itemId)
			.. " source=" .. tostring(sourceTag or "core:ui-error"))
	end
	return attemptId
end

local function MTH_FEED_CoreTrackerOnEvent()
	local evt = event
	if evt == "UI_ERROR_MESSAGE" then
		local msg = tostring(arg1 or "")
		local lower = MTH_FEED_SafeLower(msg)
		local isLowLevel = (SPELL_FAILED_FOOD_LOWLEVEL and string.find(msg, SPELL_FAILED_FOOD_LOWLEVEL))
			or string.find(lower, "low level", 1, true)
			or string.find(lower, "too low level", 1, true)
			or string.find(lower, "level too low", 1, true)
		local isWrongFood = (SPELL_FAILED_WRONG_PET_FOOD and string.find(msg, SPELL_FAILED_WRONG_PET_FOOD))
			or string.find(lower, "wrong pet food", 1, true)
			or string.find(lower, "doesn't like", 1, true)
			or string.find(lower, "does not like", 1, true)

		if isLowLevel then
			MTH_FEED_EnsureActiveAttemptFromCursor("core:ui-error-low-level")
			MTH_FEED_Trace("Core tracker UI_ERROR_MESSAGE => low-level")
			MTH_FEED_HandleCoreReject("low-level", msg)
		elseif isWrongFood then
			MTH_FEED_EnsureActiveAttemptFromCursor("core:ui-error-wrong-food")
			MTH_FEED_Trace("Core tracker UI_ERROR_MESSAGE => wrong-food")
			MTH_FEED_HandleCoreReject("wrong-food", msg)
		end
	elseif evt == "CHAT_MSG_SPELL_TRADESKILLS" then
		local line = tostring(arg1 or "")
		local feedPattern = nil
		if FEEDPET_LOG_FIRSTPERSON then
			feedPattern = GFWUtils and GFWUtils.FormatToPattern and GFWUtils.FormatToPattern(FEEDPET_LOG_FIRSTPERSON) or nil
		end
		if feedPattern then
			local _, _, foodName = string.find(line, feedPattern)
			if foodName and foodName ~= "" then
				local nowTs = (type(GetTime) == "function") and (GetTime() or 0) or 0
				local suppressUntil = tonumber((_G and _G["MTH_FEED_SuppressChatUntil"]) or 0) or 0
				local suppressFood = tostring((_G and _G["MTH_FEED_SuppressChatFoodName"]) or "")
				if suppressUntil > 0 and nowTs > suppressUntil then
					if _G then
						_G["MTH_FEED_SuppressChatUntil"] = nil
						_G["MTH_FEED_SuppressChatFoodName"] = nil
					end
					suppressUntil = 0
					suppressFood = ""
				end
				if suppressUntil > 0 and nowTs <= suppressUntil then
					local normalizedSuppress = MTH_FEED_NormalizeItemName(suppressFood)
					local normalizedFood = MTH_FEED_NormalizeItemName(foodName)
					if normalizedSuppress == "" or normalizedSuppress == normalizedFood then
						MTH_FEED_Trace("Core tracker chat suppressed for food='" .. tostring(foodName) .. "' (owned by FeedOMatic)")
						return
					end
				end

				local itemId, itemLink = MTH_FEED_FindItemByNameInBags(foodName)
				local pet = MTH_FEED_GetCurrentPetContext()
				if pet and (itemId or foodName) then
					local attemptId = MTH_FEED_BeginAttempt({
						itemId = itemId,
						itemName = foodName,
						itemLink = itemLink,
						source = "core:manual-chat",
						petId = pet.petId,
						petName = pet.petName,
						family = pet.family,
						petLevel = pet.level,
						foodLevel = MTH_FEED_GetFoodLevel(itemId),
					})
					if attemptId then
						MTH_FEED_ActiveCoreAttemptId = attemptId
						MTH_FEED_Trace("Core tracker chat started attempt id=" .. tostring(attemptId)
							.. " food='" .. tostring(foodName) .. "' itemId=" .. tostring(itemId))
					end
				else
					MTH_FEED_Trace("Core tracker chat feed detected but item lookup failed for '" .. tostring(foodName) .. "'")
				end
			end
		end
	elseif evt == "BAG_UPDATE" then
		MTH_FEED_IndexBagFoods()
	elseif evt == "CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS" then
		if MTH_FEED_ActiveCoreAttemptId and MTH_FEED_HasPetFeedBuff() then
			MTH_FEED_Trace("Core tracker buff event confirms acceptance")
			MTH_FEED_HandleCoreAccept()
		end
	end
end

local function MTH_FEED_CoreTrackerOnUpdate()
	local attemptId = MTH_FEED_ActiveCoreAttemptId
	if attemptId == nil then
		return
	end
	local elapsed = MTH_FEED_GetAttemptElapsed(attemptId)
	if elapsed == nil then
		MTH_FEED_ClearActiveCoreAttempt(attemptId)
		return
	end

	if MTH_FEED_HasPetFeedBuff() then
		MTH_FEED_Trace("Core tracker OnUpdate detects feed buff")
		MTH_FEED_HandleCoreAccept()
		return
	end

	if elapsed >= 2.50 then
		MTH_FEED_Trace("Core tracker timeout => no-buff reject elapsed=" .. tostring(elapsed))
		MTH_FEED_RecordBuffOutcome(attemptId, {
			hasFeedBuff = false,
			elapsed = elapsed,
		})
		MTH_FEED_HandleCoreReject("no-buff", nil)
	end
end

local function MTH_FEED_EnsureTrackerFrame()
	if MTH_FEED_TrackerFrame then
		return MTH_FEED_TrackerFrame
	end
	local frame = CreateFrame("Frame", "MTH_FeedTrackingFrame")
	if not frame then
		return nil
	end
	frame:RegisterEvent("UI_ERROR_MESSAGE")
	frame:RegisterEvent("BAG_UPDATE")
	frame:RegisterEvent("CHAT_MSG_SPELL_TRADESKILLS")
	frame:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS")
	frame:SetScript("OnEvent", MTH_FEED_CoreTrackerOnEvent)
	frame:SetScript("OnUpdate", MTH_FEED_CoreTrackerOnUpdate)
	MTH_FEED_TrackerFrame = frame
	MTH_FEED_IndexBagFoods()
	return frame
end

local function MTH_FEED_CoreDropItemOnUnitHook(unit)
	local target = tostring(unit or "")
	local skip = (_G and _G["MTH_FEED_SuppressCoreDropHook"]) and true or false
	if skip then
		if type(MTH_FEED_Original_DropItemOnUnit) == "function" then
			return MTH_FEED_Original_DropItemOnUnit(unit)
		end
		MTH_FEED_Trace("Core hook bypass failed: original DropItemOnUnit missing")
		return
	end

	if target == "pet" and CursorHasItem and CursorHasItem() then
		MTH_FEED_EnsureTrackerFrame()
		local itemId, itemName, itemLink, itemIcon = MTH_FEED_GetCursorItemSnapshot()
		local pet = MTH_FEED_GetCurrentPetContext()
		if not itemId then
			MTH_FEED_Trace("Core hook pet drop detected but cursor item could not be resolved")
		end
		if pet and itemId then
			local attemptId = MTH_FEED_BeginAttempt({
				itemId = itemId,
				itemName = itemName,
				itemLink = itemLink,
				itemIcon = itemIcon,
				source = "core:manual-drop",
				petId = pet.petId,
				petName = pet.petName,
				family = pet.family,
				petLevel = pet.level,
				foodLevel = MTH_FEED_GetFoodLevel(itemId),
			})
			MTH_FEED_ActiveCoreAttemptId = attemptId
			MTH_FEED_Trace("Core hook started manual attempt id=" .. tostring(attemptId)
				.. " itemId=" .. tostring(itemId)
				.. " petId=" .. tostring(pet.petId))
		end
	end

	if type(MTH_FEED_Original_DropItemOnUnit) == "function" then
		MTH_FEED_Original_DropItemOnUnit(unit)
	else
		MTH_FEED_Trace("Core hook failed: original DropItemOnUnit missing")
		return
	end

	local activeId = MTH_FEED_ActiveCoreAttemptId
	if activeId then
		local consumed = (CursorHasItem and CursorHasItem()) and false or true
		MTH_FEED_RecordClientDropResult(activeId, { consumedFromCursor = consumed })
		if not consumed then
			MTH_FEED_Trace("Core hook immediate reject: cursor still has item")
			MTH_FEED_HandleCoreReject("client-drop-fail", nil)
		end
	end
end

local function MTH_FEED_InstallCoreHooks()
	if type(DropItemOnUnit) ~= "function" then
		MTH_FEED_Trace("InstallCoreHooks skipped: DropItemOnUnit unavailable")
		return false
	end

	if MTH_FEED_Original_DropItemOnUnit == nil or MTH_FEED_Original_DropItemOnUnit == MTH_FEED_CoreDropItemOnUnitHook then
		MTH_FEED_Original_DropItemOnUnit = DropItemOnUnit
	end
	if DropItemOnUnit ~= MTH_FEED_CoreDropItemOnUnitHook then
		DropItemOnUnit = MTH_FEED_CoreDropItemOnUnitHook
	end

	if MTH and MTH.CaptureHookBoundary then
		MTH:CaptureHookBoundary(MTH_FEED_CORE_HOOK_BOUNDARY_KEY, {
			{ globalName = "DropItemOnUnit", originalName = "MTH_FEED_Original_DropItemOnUnit" },
		})
	end

	return true
end

local function MTH_FEED_IsCoreHookInstalled()
	return type(DropItemOnUnit) == "function" and DropItemOnUnit == MTH_FEED_CoreDropItemOnUnitHook
end

function MTH_FEED_DebugStatus()
	local owner = nil
	if MTH and MTH.GetGlobalHookOwner then
		owner = MTH:GetGlobalHookOwner("DropItemOnUnit")
	end
	MTH_FEED_Trace("Status hookInstalled=" .. tostring(MTH_FEED_IsCoreHookInstalled())
		.. " owner=" .. tostring(owner)
		.. " trackerFrame=" .. tostring(MTH_FEED_TrackerFrame ~= nil)
		.. " activeAttemptId=" .. tostring(MTH_FEED_ActiveCoreAttemptId))
	return true
end

function MTH_FEED_ReinstallCoreTracking()
	local ok = MTH_FEED_InstallCoreHooks()
	return ok and true or false
end

local function MTH_FEED_EnsureBootstrapFrame()
	if MTH_FEED_BootstrapFrame ~= nil then
		return MTH_FEED_BootstrapFrame
	end
	local frame = CreateFrame("Frame", "MTH_FeedTrackingBootstrapFrame")
	if not frame then
		return nil
	end
	frame:RegisterEvent("VARIABLES_LOADED")
	frame:RegisterEvent("PLAYER_LOGIN")
	frame:RegisterEvent("PLAYER_ENTERING_WORLD")
	frame:SetScript("OnEvent", function(self)
		MTH_FEED_ReinstallCoreTracking()
		if self and self.UnregisterAllEvents then
			self:UnregisterAllEvents()
			self:SetScript("OnEvent", nil)
		end
	end)
	MTH_FEED_BootstrapFrame = frame
	return frame
end

local function MTH_FEED_EnsureStore()
	if type(MTH_CharSavedVariables) ~= "table" then
		MTH_CharSavedVariables = {}
	end
	if type(MTH_CharSavedVariables.feedTracking) ~= "table" then
		MTH_CharSavedVariables.feedTracking = {}
	end

	local store = MTH_CharSavedVariables.feedTracking
	if store.schemaVersion ~= MTH_FEED_SCHEMA_VERSION then
		store.schemaVersion = MTH_FEED_SCHEMA_VERSION
	end
	if store.updatedAt == nil then
		store.updatedAt = 0
	end

	if type(store.byPetId) ~= "table" then
		store.byPetId = {}
	end
	if type(store.levelRule) ~= "table" then
		store.levelRule = {}
	end
	if type(store.levelRule.observations) ~= "table" then
		store.levelRule.observations = {}
	end
	if type(store.levelRule.derived) ~= "table" then
		store.levelRule.derived = {}
	end
	if type(store.levelRule.derived.minAcceptedFoodLevelByPetLevel) ~= "table" then
		store.levelRule.derived.minAcceptedFoodLevelByPetLevel = {}
	end
	if type(store.levelRule.derived.confidenceByPetLevel) ~= "table" then
		store.levelRule.derived.confidenceByPetLevel = {}
	end
	if store.levelRule.derived.lastRecomputeAt == nil then
		store.levelRule.derived.lastRecomputeAt = 0
	end

	if type(store.exceptions) ~= "table" then
		store.exceptions = {}
	end
	if type(store.exceptions.byItemId) ~= "table" then
		store.exceptions.byItemId = {}
	end

	if type(store.unknownFoods) ~= "table" then
		store.unknownFoods = {}
	end
	if type(store.unknownFoods.byItemId) ~= "table" then
		store.unknownFoods.byItemId = {}
	end

	if type(store.runtime) ~= "table" then
		store.runtime = {}
	end
	if store.runtime.nextAttemptId == nil then
		store.runtime.nextAttemptId = 1
	end

	MTH_FEED_MigrateItemLinkShapes(store)

	return store
end

local function MTH_FEED_TouchStore(store)
	store.updatedAt = MTH_FEED_Now()
end

local function MTH_FEED_GetRuntimeAttemptId(store)
	local nextId = tonumber(store.runtime.nextAttemptId) or 1
	store.runtime.nextAttemptId = nextId + 1
	return "feed-attempt-" .. tostring(nextId)
end

local function MTH_FEED_EnsurePetRow(store, petContext)
	local petId = tostring((petContext and petContext.petId) or "")
	if petId == "" then
		return nil
	end

	local row = store.byPetId[petId]
	if type(row) ~= "table" then
		row = {
			petId = petId,
			petName = petContext and petContext.petName or nil,
			family = petContext and petContext.family or nil,
			totals = {
				attempts = 0,
				accepted = 0,
				rejected = 0,
				rejectedNoBuff = 0,
				rejectedLowLevel = 0,
				rejectedWrongFood = 0,
			},
			byItemId = {},
			recent = {},
		}
		store.byPetId[petId] = row
	end

	if type(row.totals) ~= "table" then
		row.totals = {}
	end
	row.totals.attempts = tonumber(row.totals.attempts) or 0
	row.totals.accepted = tonumber(row.totals.accepted) or 0
	row.totals.rejected = tonumber(row.totals.rejected) or 0
	row.totals.rejectedNoBuff = tonumber(row.totals.rejectedNoBuff) or 0
	row.totals.rejectedLowLevel = tonumber(row.totals.rejectedLowLevel) or 0
	row.totals.rejectedWrongFood = tonumber(row.totals.rejectedWrongFood) or 0

	if type(row.byItemId) ~= "table" then
		row.byItemId = {}
	end
	if type(row.recent) ~= "table" then
		row.recent = {}
	end

	if petContext then
		if petContext.petName and petContext.petName ~= "" then
			row.petName = petContext.petName
		end
		if petContext.family and petContext.family ~= "" then
			row.family = petContext.family
		end
	end

	return row
end

local function MTH_FEED_EnsurePetItemRow(petRow, itemId)
	local key = tonumber(itemId)
	if key == nil then
		key = itemId
	end
	if key == nil then
		return nil
	end
	if type(petRow.byItemId[key]) ~= "table" then
		petRow.byItemId[key] = {
			attempts = 0,
			accepted = 0,
			rejected = 0,
			lastOutcome = nil,
			lastReason = nil,
			itemName = nil,
			itemLink = nil,
			itemIcon = nil,
		}
	end
	local row = petRow.byItemId[key]
	row.attempts = tonumber(row.attempts) or 0
	row.accepted = tonumber(row.accepted) or 0
	row.rejected = tonumber(row.rejected) or 0
	return row
end

local function MTH_FEED_RecordPetRecent(petRow, entry)
	table.insert(petRow.recent, 1, entry)
	while table.getn(petRow.recent) > MTH_FEED_RECENT_LIMIT do
		table.remove(petRow.recent)
	end
end

local function MTH_FEED_NormalizeReason(reason, rawMessage)
	local normalized = MTH_FEED_SafeLower(reason)
	if normalized == "accepted" then return "accepted" end
	if normalized == "low-level" then return "low-level" end
	if normalized == "wrong-food" then return "wrong-food" end
	if normalized == "no-buff" then return "no-buff" end
	if normalized == "client-drop-fail" then return "client-drop-fail" end
	if normalized == "unknown" then return "unknown" end

	local msg = MTH_FEED_SafeLower(rawMessage)
	if msg ~= "" then
		if (SPELL_FAILED_FOOD_LOWLEVEL and string.find(msg, MTH_FEED_SafeLower(SPELL_FAILED_FOOD_LOWLEVEL), 1, true))
			or string.find(msg, "low level", 1, true)
			or string.find(msg, "too low level", 1, true)
			or string.find(msg, "level too low", 1, true) then
			return "low-level"
		end
		if (SPELL_FAILED_WRONG_PET_FOOD and string.find(msg, MTH_FEED_SafeLower(SPELL_FAILED_WRONG_PET_FOOD), 1, true))
			or string.find(msg, "wrong pet food", 1, true)
			or string.find(msg, "doesn't like", 1, true)
			or string.find(msg, "does not like", 1, true) then
			return "wrong-food"
		end
	end

	return "unknown"
end

local function MTH_FEED_GetDietByItemIdMap()
	local map = {}
	if type(FOM_Foods) ~= "table" then
		return map
	end
	for dietName, ids in pairs(FOM_Foods) do
		if type(ids) == "table" then
			for _, itemId in ids do
				local numeric = tonumber(itemId)
				if numeric then
					map[numeric] = dietName
				end
			end
		end
	end
	return map
end

local function MTH_FEED_ResolveFoodLevel(itemId)
	local numeric = tonumber(itemId)
	if not numeric then
		return nil
	end

	local store = MTH_FEED_EnsureStore()
	local unknown = store.unknownFoods and store.unknownFoods.byItemId and store.unknownFoods.byItemId[numeric] or nil
	if type(unknown) == "table" and type(unknown.resolved) == "table" and tonumber(unknown.resolved.foodLevel) then
		return tonumber(unknown.resolved.foodLevel)
	end

	if type(GetItemInfo) == "function" then
		local _, _, _, itemLevel, minLevel = GetItemInfo(numeric)
		local resolved = tonumber(minLevel) or tonumber(itemLevel)
		if resolved and resolved > 0 then
			return resolved
		end
	end

	return nil
end

function MTH_FEED_GetStore()
	return MTH_FEED_EnsureStore()
end

function MTH_FEED_GetCurrentPetContext()
	local info = (type(MTH_GetCurrentPetInfo) == "function") and MTH_GetCurrentPetInfo() or nil
	if type(info) ~= "table" then
		return nil
	end
	local petId = info.id
	if petId == nil or tostring(petId) == "" then
		return nil
	end
	return {
		petId = tostring(petId),
		petName = info.name,
		family = info.family,
		level = tonumber(info.level),
		happiness = tonumber(info.happiness),
	}
end

function MTH_FEED_GetFoodLevel(itemId)
	return MTH_FEED_ResolveFoodLevel(itemId)
end

function MTH_FEED_GetFoodMeta(itemId)
	local numeric = tonumber(itemId)
	if not numeric then
		return nil
	end
	local dietMap = MTH_FEED_GetDietByItemIdMap()
	local known = dietMap[numeric] ~= nil
	return {
		itemId = numeric,
		foodLevel = MTH_FEED_ResolveFoodLevel(numeric),
		diet = dietMap[numeric],
		known = known,
	}
end

function MTH_FEED_IsKnownFoodItem(itemId)
	local numeric = tonumber(itemId)
	if not numeric then
		return false
	end
	if type(FOM_IsKnownFood) == "function" then
		local ok, value = pcall(FOM_IsKnownFood, numeric)
		if ok and value then
			return true
		end
	end
	local dietMap = MTH_FEED_GetDietByItemIdMap()
	return dietMap[numeric] ~= nil
end

function MTH_FEED_BeginAttempt(payload)
	local store = MTH_FEED_EnsureStore()
	local currentPet = MTH_FEED_GetCurrentPetContext()
	local payloadPetId = payload and payload.petId or nil
	if payloadPetId ~= nil and tostring(payloadPetId) == "" then
		payloadPetId = nil
	end
	local petId = payloadPetId or (currentPet and currentPet.petId)
	if petId == nil or tostring(petId) == "" then
		return nil
	end
	local attemptId = MTH_FEED_GetRuntimeAttemptId(store)
	local itemId = payload and tonumber(payload.itemId) or nil
	local meta = itemId and MTH_FEED_GetFoodMeta(itemId) or nil
	local itemIcon = payload and payload.itemIcon or nil
	if (not itemIcon or itemIcon == "") and itemId and type(GetItemInfo) == "function" then
		local _, _, _, _, _, _, _, _, _, infoTexture = GetItemInfo(itemId)
		if infoTexture and infoTexture ~= "" then
			itemIcon = infoTexture
		end
	end

	MTH_FEED_Runtime.attempts[attemptId] = {
		id = attemptId,
		startedAt = GetTime and (GetTime() or 0) or 0,
		startedAtTs = MTH_FEED_Now(),
		petId = tostring(petId),
		petName = payload and payload.petName or (currentPet and currentPet.petName) or nil,
		family = payload and payload.family or (currentPet and currentPet.family) or nil,
		petLevel = payload and tonumber(payload.petLevel) or (currentPet and tonumber(currentPet.level) or nil),
		itemId = itemId,
		itemName = payload and payload.itemName or nil,
		itemLink = MTH_FEED_NormalizeItemLink(itemId, payload and payload.itemName or nil, payload and payload.itemLink or nil),
		itemIcon = itemIcon,
		foodLevel = (payload and tonumber(payload.foodLevel)) or (meta and meta.foodLevel) or nil,
		source = payload and payload.source or "unknown",
		consumedFromCursor = nil,
		rejectReason = nil,
		rejectRawMessage = nil,
		hasFeedBuff = nil,
		happinessTick = nil,
		elapsed = nil,
		finalized = false,
	}

	if itemId and not (meta and meta.known) then
		MTH_FEED_RecordUnknownFoodCandidate({
			itemId = itemId,
			itemName = payload and payload.itemName or nil,
			itemLink = MTH_FEED_NormalizeItemLink(itemId, payload and payload.itemName or nil, payload and payload.itemLink or nil),
			source = "feed-attempt",
			observedFoodLevel = meta and meta.foodLevel or nil,
			observedDietHint = nil,
			evidenceType = "feed-attempt",
		})
	end

	MTH_FEED_Trace("Begin attempt id=" .. tostring(attemptId)
		.. " petId=" .. tostring(petId)
		.. " itemId=" .. tostring(itemId)
		.. " foodLevel=" .. tostring((payload and tonumber(payload.foodLevel)) or (meta and meta.foodLevel) or nil)
		.. " source=" .. tostring(payload and payload.source or "unknown"))

	MTH_FEED_TouchStore(store)
	return attemptId
end

function MTH_FEED_RecordClientDropResult(attemptId, payload)
	local row = MTH_FEED_Runtime.attempts[attemptId]
	if type(row) ~= "table" then
		MTH_FEED_Trace("RecordClientDropResult missing attempt id=" .. tostring(attemptId))
		return false
	end
	row.consumedFromCursor = (payload and payload.consumedFromCursor) and true or false
	MTH_FEED_Trace("RecordClientDropResult id=" .. tostring(attemptId)
		.. " consumedFromCursor=" .. tostring(row.consumedFromCursor and true or false))
	return true
end

function MTH_FEED_RecordRejectEvent(attemptId, payload)
	local row = MTH_FEED_Runtime.attempts[attemptId]
	if type(row) ~= "table" then
		MTH_FEED_Trace("RecordRejectEvent missing attempt id=" .. tostring(attemptId))
		return false
	end
	local rawMessage = payload and payload.rawMessage or nil
	row.rejectReason = MTH_FEED_NormalizeReason(payload and payload.reason or nil, rawMessage)
	row.rejectRawMessage = rawMessage
	MTH_FEED_Trace("RecordRejectEvent id=" .. tostring(attemptId)
		.. " reason=" .. tostring(row.rejectReason)
		.. " raw='" .. tostring(rawMessage or "") .. "'")
	return true
end

function MTH_FEED_RecordBuffOutcome(attemptId, payload)
	local row = MTH_FEED_Runtime.attempts[attemptId]
	if type(row) ~= "table" then
		MTH_FEED_Trace("RecordBuffOutcome missing attempt id=" .. tostring(attemptId))
		return false
	end
	row.hasFeedBuff = (payload and payload.hasFeedBuff) and true or false
	row.elapsed = payload and tonumber(payload.elapsed) or row.elapsed
	MTH_FEED_Trace("RecordBuffOutcome id=" .. tostring(attemptId)
		.. " hasFeedBuff=" .. tostring(row.hasFeedBuff and true or false)
		.. " elapsed=" .. tostring(row.elapsed))
	return true
end

function MTH_FEED_RecordHappinessTick(attemptId, payload)
	local row = MTH_FEED_Runtime.attempts[attemptId]
	if type(row) ~= "table" then
		MTH_FEED_Trace("RecordHappinessTick missing attempt id=" .. tostring(attemptId))
		return false
	end
	row.happinessTick = payload and tonumber(payload.happinessTick) or row.happinessTick
	if payload and tonumber(payload.petLevel) then
		row.petLevel = tonumber(payload.petLevel)
	end
	MTH_FEED_Trace("RecordHappinessTick id=" .. tostring(attemptId)
		.. " happinessTick=" .. tostring(row.happinessTick)
		.. " petLevel=" .. tostring(row.petLevel))
	return true
end

function MTH_FEED_RecordLevelObservation(petLevel, foodLevel, outcome)
	return true
end

function MTH_FEED_RecomputeDerivedLevelRule()
	local store = MTH_FEED_EnsureStore()
	store.levelRule.derived.lastRecomputeAt = MTH_FEED_Now()
	MTH_FEED_TouchStore(store)
	return true
end

local function MTH_FEED_GetHardcodedMinFoodLevel(petLevel)
	local level = tonumber(petLevel)
	if not level then
		return nil
	end
	local minFood = nil
	for i = 1, table.getn(MTH_FEED_HARDCODED_LEVEL_RULES) do
		local row = MTH_FEED_HARDCODED_LEVEL_RULES[i]
		if level >= (tonumber(row.minPetLevel) or 0) then
			minFood = tonumber(row.minFoodLevel)
		else
			break
		end
	end
	return minFood
end

function MTH_FEED_GetDerivedMinFoodLevel(petLevel)
	return MTH_FEED_GetHardcodedMinFoodLevel(petLevel)
end

function MTH_FEED_GetFoodCompatibilityWindow(petLevel)
	local numericPet = tonumber(petLevel)
	if not numericPet then
		return nil, nil
	end
	local minAccepted = MTH_FEED_GetHardcodedMinFoodLevel(numericPet)
	if minAccepted == nil then
		minAccepted = numericPet - 15
		if minAccepted < 1 then
			minAccepted = 1
		end
	end
	local maxAccepted = numericPet
	if maxAccepted < 1 then
		maxAccepted = 1
	end
	return tonumber(minAccepted), tonumber(maxAccepted)
end

function MTH_FEED_IsFoodCompatible(petLevel, foodLevel)
	local numericPet = tonumber(petLevel)
	local numericFood = tonumber(foodLevel)
	if not numericPet or not numericFood then
		return false
	end
	local minAccepted, maxAccepted = MTH_FEED_GetFoodCompatibilityWindow(numericPet)
	if minAccepted and numericFood < minAccepted then
		return false
	end
	if maxAccepted and numericFood > maxAccepted then
		return false
	end
	return true
end

function MTH_FEED_IsExceptionReject(itemId, petLevel)
	local key = tonumber(itemId)
	if not key then
		return false
	end
	local store = MTH_FEED_EnsureStore()
	local row = store.exceptions.byItemId[key]
	if type(row) ~= "table" then
		return false
	end
	local numericPet = tonumber(petLevel)
	local blockedAtOrAbove = tonumber(row.blockAtOrAbovePetLevel)
	if blockedAtOrAbove and numericPet and numericPet >= blockedAtOrAbove then
		return true
	end
	if row.anomalyReject ~= true then
		return false
	end
	local lastObservedAt = tonumber(row.lastObservedAt) or 0
	if lastObservedAt > 0 then
		local age = MTH_FEED_Now() - lastObservedAt
		if age > 900 then
			return false
		end
	end
	local reasons = type(row.reasons) == "table" and row.reasons or nil
	if not reasons then
		return false
	end
	local lowLevelCount = tonumber(reasons.lowLevel) or 0
	if lowLevelCount >= 1 then
		local maxPetLevel = tonumber(row.maxPetLevel)
		if numericPet and maxPetLevel then
			if numericPet > maxPetLevel then
				return true
			end
		else
			return true
		end
	end
	local wrongFoodCount = tonumber(reasons.wrongFood) or 0
	if wrongFoodCount < 2 then
		return false
	end
	return true
end

function MTH_FEED_BlockItemForPetLevel(itemId, petLevel, reason)
	local key = tonumber(itemId)
	local numericPet = tonumber(petLevel)
	if not key or not numericPet then
		return false
	end
	if numericPet < 1 then
		numericPet = 1
	end
	local store = MTH_FEED_EnsureStore()
	if type(store.exceptions.byItemId[key]) ~= "table" then
		store.exceptions.byItemId[key] = {
			anomalyReject = true,
			reasons = { noBuff = 0, wrongFood = 0, lowLevel = 0, unknown = 0 },
			lastObservedAt = 0,
		}
	end
	local row = store.exceptions.byItemId[key]
	if type(row.reasons) ~= "table" then
		row.reasons = { noBuff = 0, wrongFood = 0, lowLevel = 0, unknown = 0 }
	end
	row.anomalyReject = true
	row.lastObservedAt = MTH_FEED_Now()
	if tonumber(row.blockAtOrAbovePetLevel) == nil or numericPet < tonumber(row.blockAtOrAbovePetLevel) then
		row.blockAtOrAbovePetLevel = numericPet
	end
	local normalizedReason = MTH_FEED_NormalizeReason(reason, nil)
	if normalizedReason == "no-buff" then
		row.reasons.noBuff = (tonumber(row.reasons.noBuff) or 0) + 1
	elseif normalizedReason == "low-level" then
		row.reasons.lowLevel = (tonumber(row.reasons.lowLevel) or 0) + 1
	elseif normalizedReason == "wrong-food" then
		row.reasons.wrongFood = (tonumber(row.reasons.wrongFood) or 0) + 1
	else
		row.reasons.unknown = (tonumber(row.reasons.unknown) or 0) + 1
	end
	MTH_FEED_TouchStore(store)
	MTH_FEED_Trace("BlockItemForPetLevel itemId=" .. tostring(key)
		.. " blockAtOrAbove=" .. tostring(row.blockAtOrAbovePetLevel)
		.. " reason=" .. tostring(normalizedReason))
	return true
end

function MTH_FEED_GetPetFeedStats(petId)
	local key = tostring(petId or "")
	if key == "" then
		return nil
	end
	local store = MTH_FEED_EnsureStore()
	return store.byPetId[key]
end

local function MTH_FEED_UpsertException(store, itemId, reason, petLevel)
	if not itemId then
		return
	end
	local key = tonumber(itemId) or itemId
	if type(store.exceptions.byItemId[key]) ~= "table" then
		store.exceptions.byItemId[key] = {
			anomalyReject = true,
			reasons = { noBuff = 0, wrongFood = 0, lowLevel = 0, unknown = 0 },
			lastObservedAt = 0,
		}
	end
	local row = store.exceptions.byItemId[key]
	if type(row.reasons) ~= "table" then
		row.reasons = { noBuff = 0, wrongFood = 0, lowLevel = 0, unknown = 0 }
	end
	if reason == "no-buff" then
		row.reasons.noBuff = (tonumber(row.reasons.noBuff) or 0) + 1
	elseif reason == "wrong-food" then
		row.reasons.wrongFood = (tonumber(row.reasons.wrongFood) or 0) + 1
	elseif reason == "low-level" then
		row.reasons.lowLevel = (tonumber(row.reasons.lowLevel) or 0) + 1
		local numericPetLevel = tonumber(petLevel)
		if numericPetLevel and numericPetLevel > 1 then
			local derivedMaxPetLevel = numericPetLevel - 1
			if derivedMaxPetLevel < 1 then
				derivedMaxPetLevel = 1
			end
			if tonumber(row.maxPetLevel) == nil or derivedMaxPetLevel < tonumber(row.maxPetLevel) then
				row.maxPetLevel = derivedMaxPetLevel
			end
		end
	else
		row.reasons.unknown = (tonumber(row.reasons.unknown) or 0) + 1
	end
	row.anomalyReject = true
	row.lastObservedAt = MTH_FEED_Now()
end

local function MTH_FEED_ClearStaleExceptionOnAccept(store, itemId)
	if not itemId or type(store) ~= "table" or type(store.exceptions) ~= "table" or type(store.exceptions.byItemId) ~= "table" then
		return
	end
	local key = tonumber(itemId) or itemId
	local row = store.exceptions.byItemId[key]
	if type(row) ~= "table" then
		return
	end
	if type(row.reasons) ~= "table" then
		store.exceptions.byItemId[key] = nil
		return
	end
	row.reasons.noBuff = 0
	row.lastObservedAt = MTH_FEED_Now()

	local noBuff = tonumber(row.reasons.noBuff) or 0
	local lowLevel = tonumber(row.reasons.lowLevel) or 0
	local wrongFood = tonumber(row.reasons.wrongFood) or 0
	local unknown = tonumber(row.reasons.unknown) or 0
	if noBuff <= 0
		and lowLevel <= 0
		and wrongFood <= 0
		and unknown <= 0
		and tonumber(row.blockAtOrAbovePetLevel) == nil
		and tonumber(row.maxPetLevel) == nil then
		store.exceptions.byItemId[key] = nil
	end
end

function MTH_FEED_FinalizeAttempt(attemptId, payload)
	local row = MTH_FEED_Runtime.attempts[attemptId]
	if type(row) ~= "table" then
		MTH_FEED_Trace("FinalizeAttempt missing attempt id=" .. tostring(attemptId))
		return false
	end
	if row.finalized then
		MTH_FEED_Trace("FinalizeAttempt already finalized id=" .. tostring(attemptId))
		return true
	end

	local store = MTH_FEED_EnsureStore()
	local outcome = MTH_FEED_SafeLower(payload and payload.outcome or "")
	local reason = MTH_FEED_NormalizeReason(payload and payload.reason or row.rejectReason, row.rejectRawMessage)
	if outcome ~= "accepted" and outcome ~= "rejected" then
		if row.hasFeedBuff == true then
			outcome = "accepted"
		else
			outcome = "rejected"
		end
	end

	if outcome == "accepted" then
		reason = "accepted"
	elseif reason == "accepted" then
		reason = "unknown"
	end

	local petContext = {
		petId = row.petId,
		petName = row.petName,
		family = row.family,
	}
	if petContext.petId == nil or tostring(petContext.petId) == "" then
		local currentPet = MTH_FEED_GetCurrentPetContext()
		if type(currentPet) == "table" and currentPet.petId and tostring(currentPet.petId) ~= "" then
			petContext.petId = tostring(currentPet.petId)
			if row.petId == nil or tostring(row.petId) == "" then
				row.petId = petContext.petId
			end
		end
	end
	local petRow = MTH_FEED_EnsurePetRow(store, petContext)
	if type(petRow) ~= "table" then
		MTH_FEED_Trace("FinalizeAttempt failed pet row id=" .. tostring(attemptId) .. " petId=" .. tostring(row.petId))
		return false
	end
	local itemRow = MTH_FEED_EnsurePetItemRow(petRow, row.itemId)

	petRow.totals.attempts = petRow.totals.attempts + 1
	if itemRow then
		itemRow.attempts = itemRow.attempts + 1
	end

	if outcome == "accepted" then
		petRow.totals.accepted = petRow.totals.accepted + 1
		if itemRow then
			itemRow.accepted = itemRow.accepted + 1
		end
		MTH_FEED_ClearStaleExceptionOnAccept(store, row.itemId)
		local petKey = tostring((petRow and petRow.petId) or row.petId or "")
		if petKey ~= "" then
			MTH_FEED_Runtime.sessionFeedsByPetId[petKey] = (tonumber(MTH_FEED_Runtime.sessionFeedsByPetId[petKey]) or 0) + 1
		end
	else
		petRow.totals.rejected = petRow.totals.rejected + 1
		if reason == "no-buff" then
			petRow.totals.rejectedNoBuff = petRow.totals.rejectedNoBuff + 1
		elseif reason == "low-level" then
			petRow.totals.rejectedLowLevel = petRow.totals.rejectedLowLevel + 1
		elseif reason == "wrong-food" then
			petRow.totals.rejectedWrongFood = petRow.totals.rejectedWrongFood + 1
		end
		if itemRow then
			itemRow.rejected = itemRow.rejected + 1
		end
		MTH_FEED_UpsertException(store, row.itemId, reason, row.petLevel)
	end

	if itemRow then
		itemRow.lastOutcome = outcome
		itemRow.lastReason = reason
		if row.itemName and row.itemName ~= "" then
			itemRow.itemName = row.itemName
		end
		itemRow.itemLink = MTH_FEED_NormalizeItemLink(row.itemId, row.itemName, row.itemLink)
		local persistedIcon = row.itemIcon
		if (not persistedIcon or persistedIcon == "") and row.itemId and type(GetItemInfo) == "function" then
			local _, _, _, _, _, _, _, _, _, infoTexture = GetItemInfo(row.itemId)
			if infoTexture and infoTexture ~= "" then
				persistedIcon = infoTexture
			end
		end
		if (not persistedIcon or persistedIcon == "") and row.itemId and type(GetItemIcon) == "function" then
			local directTexture = GetItemIcon(row.itemId)
			if directTexture and directTexture ~= "" then
				persistedIcon = directTexture
			end
		end
		if persistedIcon and persistedIcon ~= "" then
			itemRow.itemIcon = persistedIcon
		end
	end

	MTH_FEED_RecordPetRecent(petRow, {
		ts = MTH_FEED_Now(),
		itemId = row.itemId,
		itemName = row.itemName,
		petLevel = row.petLevel,
		foodLevel = row.foodLevel,
		outcome = outcome,
		reason = reason,
		source = row.source,
	})

	row.finalized = true
	MTH_FEED_Trace("FinalizeAttempt id=" .. tostring(attemptId)
		.. " outcome=" .. tostring(outcome)
		.. " reason=" .. tostring(reason)
		.. " petId=" .. tostring(row.petId)
		.. " itemId=" .. tostring(row.itemId)
		.. " petAttempts=" .. tostring(petRow.totals.attempts)
		.. " petAccepted=" .. tostring(petRow.totals.accepted)
		.. " petRejected=" .. tostring(petRow.totals.rejected))
	MTH_FEED_Runtime.attempts[attemptId] = nil
	MTH_FEED_TouchStore(store)
	return true
end

function MTH_FEED_GetSessionFeedCount(petId)
	local petKey = tostring(petId or "")
	if petKey == "" then
		local pet = MTH_FEED_GetCurrentPetContext()
		petKey = tostring((pet and pet.petId) or "")
	end
	if petKey == "" then
		return 0
	end
	return tonumber(MTH_FEED_Runtime.sessionFeedsByPetId[petKey]) or 0
end

function MTH_FEED_RecordUnknownFoodCandidate(payload)
	local store = MTH_FEED_EnsureStore()
	local itemId = payload and tonumber(payload.itemId) or nil
	if not itemId then
		MTH_FEED_Trace("RecordUnknownFoodCandidate ignored: missing itemId")
		return false
	end

	local queue = store.unknownFoods.byItemId
	if type(queue[itemId]) ~= "table" then
		queue[itemId] = {
			itemId = itemId,
			itemName = payload and payload.itemName or nil,
			itemLink = payload and payload.itemLink or nil,
			firstSeenAt = MTH_FEED_Now(),
			lastSeenAt = MTH_FEED_Now(),
			seenCount = 0,
			sources = {},
			observedFoodLevel = nil,
			observedDietHints = {},
			state = "unknown",
			confidence = 0,
			resolved = {
				foodLevel = nil,
				familyMask = nil,
				resolvedFrom = nil,
				resolvedAt = nil,
			},
		}
	end

	local row = queue[itemId]
	row.lastSeenAt = MTH_FEED_Now()
	row.seenCount = (tonumber(row.seenCount) or 0) + 1
	if payload and payload.itemName and payload.itemName ~= "" then
		row.itemName = payload.itemName
	end
	if payload and payload.itemLink and payload.itemLink ~= "" then
		row.itemLink = MTH_FEED_NormalizeItemLink(itemId, row.itemName, payload.itemLink)
	end

	local source = payload and tostring(payload.source or "") or ""
	if source ~= "" then
		local seen = false
		for i = 1, table.getn(row.sources) do
			if row.sources[i] == source then
				seen = true
				break
			end
		end
		if not seen then
			table.insert(row.sources, source)
		end
	end

	if payload and payload.observedFoodLevel ~= nil then
		row.observedFoodLevel = tonumber(payload.observedFoodLevel)
	end
	local dietHint = payload and payload.observedDietHint or nil
	if dietHint ~= nil and tostring(dietHint) ~= "" then
		local hint = tostring(dietHint)
		local seen = false
		for i = 1, table.getn(row.observedDietHints) do
			if row.observedDietHints[i] == hint then
				seen = true
				break
			end
		end
		if not seen then
			table.insert(row.observedDietHints, hint)
		end
	end

	if row.state == "unknown" then
		row.state = "candidate-food"
	end
	if payload and payload.evidenceType == "runtime-outcome" and row.state == "candidate-food" then
		row.confidence = math.min(1, (tonumber(row.confidence) or 0) + 0.2)
	else
		row.confidence = math.min(1, (tonumber(row.confidence) or 0) + 0.1)
	end

	MTH_FEED_Trace("RecordUnknownFoodCandidate itemId=" .. tostring(itemId)
		.. " state=" .. tostring(row.state)
		.. " confidence=" .. tostring(row.confidence)
		.. " source=" .. tostring(payload and payload.source or ""))

	MTH_FEED_TouchStore(store)
	return true
end

function MTH_FEED_TryClassifyUnknownFood(itemId, evidence)
	local store = MTH_FEED_EnsureStore()
	local key = tonumber(itemId)
	if not key then
		return false
	end
	local row = store.unknownFoods.byItemId[key]
	if type(row) ~= "table" then
		return false
	end

	local verdict = evidence and MTH_FEED_SafeLower(evidence.verdict or "") or ""
	if verdict == "confirmed-food" then
		row.state = "confirmed-food"
		row.confidence = 1
		if evidence.foodLevel ~= nil then
			row.resolved.foodLevel = tonumber(evidence.foodLevel)
		end
		if evidence.familyMask ~= nil then
			row.resolved.familyMask = evidence.familyMask
		end
		row.resolved.resolvedFrom = evidence.resolvedFrom or "runtime-observation"
		row.resolved.resolvedAt = MTH_FEED_Now()
	elseif verdict == "confirmed-not-food" then
		row.state = "confirmed-not-food"
		row.confidence = 1
	elseif verdict == "candidate-food" then
		row.state = "candidate-food"
		row.confidence = math.max(tonumber(row.confidence) or 0, 0.5)
	end

	MTH_FEED_TouchStore(store)
	return true
end

function MTH_FEED_GetUnknownFoodQueue()
	local store = MTH_FEED_EnsureStore()
	local rows = {}
	for _, row in pairs(store.unknownFoods.byItemId) do
		if type(row) == "table" and row.state ~= "confirmed-food" and row.state ~= "confirmed-not-food" then
			table.insert(rows, row)
		end
	end
	table.sort(rows, function(a, b)
		return (tonumber(a.lastSeenAt) or 0) > (tonumber(b.lastSeenAt) or 0)
	end)
	return rows
end

function MTH_FEED_ResolveFoodMeta(itemId, payload)
	local key = tonumber(itemId)
	if not key then
		MTH_FEED_Trace("ResolveFoodMeta ignored: invalid itemId")
		return false
	end
	local store = MTH_FEED_EnsureStore()
	if type(store.unknownFoods.byItemId[key]) ~= "table" then
		MTH_FEED_RecordUnknownFoodCandidate({
			itemId = key,
			itemName = payload and payload.itemName or nil,
			itemLink = MTH_FEED_NormalizeItemLink(key, payload and payload.itemName or nil, payload and payload.itemLink or nil),
			source = "manual-resolve",
			observedFoodLevel = payload and payload.foodLevel or nil,
			observedDietHint = nil,
			evidenceType = "manual",
		})
	end
	local row = store.unknownFoods.byItemId[key]
	if type(row.resolved) ~= "table" then
		row.resolved = {}
	end
	row.state = "confirmed-food"
	row.confidence = 1
	row.resolved.foodLevel = payload and tonumber(payload.foodLevel) or nil
	row.resolved.familyMask = payload and payload.familyMask or nil
	row.resolved.resolvedFrom = payload and payload.resolvedFrom or "manual"
	row.resolved.resolvedAt = MTH_FEED_Now()
	MTH_FEED_Trace("ResolveFoodMeta itemId=" .. tostring(key)
		.. " foodLevel=" .. tostring(row.resolved.foodLevel)
		.. " resolvedFrom=" .. tostring(row.resolved.resolvedFrom))
	MTH_FEED_TouchStore(store)
	return true
end

function MTH_FEED_DebugDumpCurrentPet(limit)
	local ctx = MTH_FEED_GetCurrentPetContext()
	if type(ctx) ~= "table" then
		MTH_FEED_Trace("DebugDumpCurrentPet: no active pet context")
		return false
	end
	local stats = MTH_FEED_GetPetFeedStats(ctx.petId)
	if type(stats) ~= "table" then
		MTH_FEED_Trace("DebugDumpCurrentPet: no stats for petId=" .. tostring(ctx.petId))
		return false
	end

	local totals = stats.totals or {}
	MTH_FEED_Trace("DebugDumpCurrentPet petId=" .. tostring(ctx.petId)
		.. " name='" .. tostring(stats.petName or "") .. "'"
		.. " attempts=" .. tostring(tonumber(totals.attempts) or 0)
		.. " accepted=" .. tostring(tonumber(totals.accepted) or 0)
		.. " rejected=" .. tostring(tonumber(totals.rejected) or 0)
		.. " noBuff=" .. tostring(tonumber(totals.rejectedNoBuff) or 0)
		.. " lowLevel=" .. tostring(tonumber(totals.rejectedLowLevel) or 0)
		.. " wrongFood=" .. tostring(tonumber(totals.rejectedWrongFood) or 0))

	local maxRows = tonumber(limit) or 5
	if maxRows < 1 then maxRows = 1 end
	if maxRows > 20 then maxRows = 20 end
	local recent = stats.recent or {}
	for i = 1, maxRows do
		local row = recent[i]
		if type(row) ~= "table" then
			break
		end
		MTH_FEED_Trace("Recent#" .. tostring(i)
			.. " itemId=" .. tostring(row.itemId)
			.. " foodLevel=" .. tostring(row.foodLevel)
			.. " petLevel=" .. tostring(row.petLevel)
			.. " outcome=" .. tostring(row.outcome)
			.. " reason=" .. tostring(row.reason)
			.. " source=" .. tostring(row.source))
	end
	return true
end

MTH_FEED_InstallCoreHooks()
MTH_FEED_EnsureBootstrapFrame()
