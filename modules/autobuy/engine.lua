------------------------------------------------------
-- MetaHunt: AutoBuy Engine
-- Foundation for vendor auto-buy logic (food + ammo)
------------------------------------------------------

MTH_AutoBuyEngine = MTH_AutoBuyEngine or {}

local Engine = MTH_AutoBuyEngine
local AB_AMMO_BY_NAME = nil
local AB_FOOD_DIET_BY_ITEM_ID = nil

local function AB_Trace(message)
	return
end

local function AB_ParseItemIdFromLink(link)
	if type(link) ~= "string" then
		return nil
	end
	local _, _, itemId = string.find(link, "item:(%d+)")
	if not itemId then
		return nil
	end
	return tonumber(itemId) or itemId
end

local function AB_GetAmmoSubtypeByItemId(itemId)
	if not itemId then
		return nil
	end
	local row = MTH_DS_AmmoItems and MTH_DS_AmmoItems[itemId] or nil
	if type(row) ~= "table" then
		row = MTH_DS_AmmoItems and MTH_DS_AmmoItems[tonumber(itemId) or -1] or nil
	end
	if type(row) ~= "table" then
		return nil
	end
	local subtype = string.lower(tostring(row.subtype or ""))
	if subtype == "arrow" or subtype == "bullet" then
		return subtype
	end
	return nil
end

local function AB_GetAmmoLookupByName()
	if type(AB_AMMO_BY_NAME) == "table" then
		return AB_AMMO_BY_NAME
	end
	AB_AMMO_BY_NAME = {}
	local data = MTH_DS_AmmoItems or {}
	for id, row in pairs(data) do
		if type(row) == "table" then
			local nameKey = string.lower(tostring(row.name or ""))
			local subtype = string.lower(tostring(row.subtype or ""))
			if nameKey ~= "" and (subtype == "arrow" or subtype == "bullet") then
				if type(AB_AMMO_BY_NAME[nameKey]) ~= "table" then
					AB_AMMO_BY_NAME[nameKey] = {
						itemId = tonumber(id) or id,
						subtype = subtype,
					}
				end
			end
		end
	end
	return AB_AMMO_BY_NAME
end

local function AB_NormalizeDietToken(token)
	local value = string.lower(tostring(token or ""))
	value = string.gsub(value, "^%s+", "")
	value = string.gsub(value, "%s+$", "")
	return value
end

local function AB_GetFoodDietMap()
	if type(AB_FOOD_DIET_BY_ITEM_ID) == "table" then
		return AB_FOOD_DIET_BY_ITEM_ID
	end

	AB_FOOD_DIET_BY_ITEM_ID = {}
	if type(FOM_Foods) ~= "table" then
		return AB_FOOD_DIET_BY_ITEM_ID
	end

	for dietName, itemIds in pairs(FOM_Foods) do
		local normalizedDiet = AB_NormalizeDietToken(dietName)
		if normalizedDiet ~= "" and type(itemIds) == "table" then
			for _, itemId in ipairs(itemIds) do
				local numericId = tonumber(itemId)
				if numericId then
					AB_FOOD_DIET_BY_ITEM_ID[numericId] = normalizedDiet
				end
			end
		end
	end

	return AB_FOOD_DIET_BY_ITEM_ID
end

local function AB_GetItemFoodLevel(itemId)
	if itemId and type(MTH_FEED_GetFoodLevel) == "function" then
		local ok, level = pcall(MTH_FEED_GetFoodLevel, itemId)
		local numeric = ok and tonumber(level) or nil
		if numeric and numeric > 0 then
			return numeric
		end
	end
	if not itemId or type(GetItemInfo) ~= "function" then
		return 1
	end
	local _, _, _, itemLevel, minLevel = GetItemInfo(itemId)
	local resolved = tonumber(minLevel) or tonumber(itemLevel) or 1
	if resolved < 1 then resolved = 1 end
	return resolved
end

local function AB_GetItemMaxStack(itemId, fallbackStack)
	local fallback = math.floor(tonumber(fallbackStack) or 1)
	if fallback < 1 then
		fallback = 1
	end

	local numericId = tonumber(itemId)
	if not numericId or type(GetItemInfo) ~= "function" then
		if fallback < 20 then
			return 20
		end
		return fallback
	end

	local _, _, _, _, _, _, _, maxStack = GetItemInfo(numericId)
	if (not maxStack or tonumber(maxStack) == nil or tonumber(maxStack) < 1) and type(MTH_PrimeItemCache) == "function" then
		pcall(MTH_PrimeItemCache, numericId)
		_, _, _, _, _, _, _, maxStack = GetItemInfo(numericId)
	end
	maxStack = math.floor(tonumber(maxStack) or 0)
	if maxStack < 1 then
		if fallback < 20 then
			return 20
		end
		return fallback
	end

	return maxStack
end

local function AB_IsFoodExceptionRejected(itemId)
	if not itemId then
		return false
	end
	if type(MTH_FEED_IsExceptionReject) ~= "function" then
		return false
	end
	local ok, rejected = pcall(MTH_FEED_IsExceptionReject, itemId)
	return ok and rejected and true or false
end

local function AB_IsFoodCompatibleByRules(petLevel, foodLevel)
	local numericPetLevel = tonumber(petLevel) or 1
	local numericFoodLevel = tonumber(foodLevel) or 0
	if numericPetLevel < 1 then
		numericPetLevel = 1
	end

	if type(MTH_FEED_GetFoodCompatibilityWindow) == "function" then
		local ok, minAcceptedLevel, maxAcceptedLevel = pcall(MTH_FEED_GetFoodCompatibilityWindow, numericPetLevel)
		if ok then
			local minLevel = tonumber(minAcceptedLevel)
			local maxLevel = tonumber(maxAcceptedLevel)
			if minLevel and numericFoodLevel < minLevel then
				return false
			end
			if maxLevel and numericFoodLevel > maxLevel then
				return false
			end
			return true
		end
	end

	if type(MTH_FEED_IsFoodCompatible) == "function" then
		local ok, isCompatible = pcall(MTH_FEED_IsFoodCompatible, petLevel, foodLevel)
		if ok then
			return isCompatible and true or false
		end
	end
	local minAcceptedLevel = numericPetLevel - 15
	if minAcceptedLevel < 1 then
		minAcceptedLevel = 1
	end
	return numericFoodLevel >= minAcceptedLevel and numericFoodLevel <= numericPetLevel
end

local function AB_NormalizeFamilyToken(text)
	local value = string.lower(tostring(text or ""))
	value = string.gsub(value, "%b()", " ")
	value = string.gsub(value, "[^%a]", "")
	return value
end

local function AB_SingularizeFamilyToken(token)
	local value = tostring(token or "")
	if string.len(value) <= 3 then
		return value
	end
	if string.sub(value, -3) == "ves" and string.len(value) > 4 then
		return string.sub(value, 1, -4) .. "f"
	end
	if string.sub(value, -3) == "ies" and string.len(value) > 4 then
		return string.sub(value, 1, -4) .. "y"
	end
	if string.sub(value, -3) == "xes" and string.len(value) > 4 then
		return string.sub(value, 1, -3)
	end
	if string.sub(value, -4) == "ches" and string.len(value) > 5 then
		return string.sub(value, 1, -3)
	end
	if string.sub(value, -4) == "shes" and string.len(value) > 5 then
		return string.sub(value, 1, -3)
	end
	if string.sub(value, -3) == "zes" and string.len(value) > 4 then
		return string.sub(value, 1, -3)
	end
	if string.sub(value, -3) == "ses" then
		return string.sub(value, 1, -3)
	end
	if string.sub(value, -1) == "s" then
		return string.sub(value, 1, -2)
	end
	return value
end

local function AB_FindFamilyDietRow(familyName)
	if type(MTH_DS_Families) ~= "table" then
		return nil, nil
	end

	local needle = AB_NormalizeFamilyToken(familyName)
	if needle == "" then
		return nil, nil
	end
	local needleSingular = AB_SingularizeFamilyToken(needle)

	for key, row in pairs(MTH_DS_Families) do
		local candidate = AB_NormalizeFamilyToken(key)
		if candidate ~= "" then
			local candidateSingular = AB_SingularizeFamilyToken(candidate)
			if candidate == needle or candidate == needleSingular or candidateSingular == needle or candidateSingular == needleSingular then
				return row, tostring(key)
			end
		end
	end

	return nil, nil
end

local function AB_GetMerchantFoodsSnapshot(merchantSnapshot)
	if type(MTH_GetMerchantFoodsByDiet) == "function" then
		local ok, result = pcall(MTH_GetMerchantFoodsByDiet)
		if ok and type(result) == "table" then
			return result
		end
	end

	local dietMap = AB_GetFoodDietMap()
	local result = {
		byDiet = {},
		items = {},
		unknown = {},
	}

	if type(merchantSnapshot) ~= "table" or type(merchantSnapshot.items) ~= "table" then
		return result
	end

	for i = 1, table.getn(merchantSnapshot.items) do
		local row = merchantSnapshot.items[i]
		if type(row) == "table" and row.itemId then
			local numericId = tonumber(row.itemId)
			local diet = numericId and dietMap[numericId] or nil
			local foodRow = {
				index = row.index,
				id = numericId,
				name = row.name,
				link = row.link,
				diet = diet,
				price = row.price,
				stack = row.stackCount,
				available = row.numAvailable,
			}
			if diet then
				if type(result.byDiet[diet]) ~= "table" then
					result.byDiet[diet] = {}
				end
				table.insert(result.byDiet[diet], foodRow)
				table.insert(result.items, foodRow)
			else
				table.insert(result.unknown, foodRow)
			end
		end
	end

	return result
end

local function AB_CollectPetRows(scope)
	if type(MTH_PETS_RefreshCurrentPet) == "function" then
		pcall(MTH_PETS_RefreshCurrentPet)
	end

	local rows = {}
	local petsRoot = type(MTH_PETS_GetRootStore) == "function" and MTH_PETS_GetRootStore() or nil
	local petStore = petsRoot and petsRoot.petStore or nil
	local activeById = petStore and petStore.activeById or nil
	local stableSlotIndex = petStore and petStore.stableSlotIndex or nil

	local currentInfo = type(MTH_GetCurrentPetInfo) == "function" and MTH_GetCurrentPetInfo() or nil
	if currentInfo and currentInfo.liveExists then
		local currentName = tostring(currentInfo.name or "")
		if currentName ~= "" then
			table.insert(rows, {
				name = currentName,
				family = tostring(currentInfo.family or ""),
				level = tonumber(currentInfo.level) or 0,
				slot = 0,
			})
		end
	end

	if scope == "all" then
		for slot = 1, 4 do
			local petId = (type(stableSlotIndex) == "table") and stableSlotIndex[slot] or nil
			local row = (petId and type(activeById) == "table") and activeById[petId] or nil
			if type(row) ~= "table" and type(activeById) == "table" then
				for _, candidate in pairs(activeById) do
					if type(candidate) == "table" and tonumber(candidate.stableSlot) == slot then
						row = candidate
						break
					end
				end
			end
			if type(row) == "table" and tostring(row.name or "") ~= "" then
				table.insert(rows, {
					name = tostring(row.name or ""),
					family = tostring(row.family or ""),
					level = tonumber(row.level) or 0,
					slot = slot,
				})
			end
		end
	end

	if scope ~= "all" and table.getn(rows) > 1 then
		local filtered = {}
		for i = 1, table.getn(rows) do
			if rows[i].slot == 0 then
				table.insert(filtered, rows[i])
				break
			end
		end
		rows = filtered
	end

	return rows
end

local function AB_SelectBestFoodRowForDiet(dietRows, petLevel)
	if type(dietRows) ~= "table" then
		return nil, 0
	end

	local numericPetLevel = tonumber(petLevel) or 1
	if numericPetLevel < 1 then
		numericPetLevel = 1
	end

	local bestRow = nil
	local bestLevel = -1
	for i = 1, table.getn(dietRows) do
		local row = dietRows[i]
		if type(row) == "table" and row.id and row.index then
			if AB_IsFoodExceptionRejected(row.id) then
				-- learned exception: skip this item from autobuy candidates
			else
				local level = AB_GetItemFoodLevel(tonumber(row.id))
				local isCompatible = AB_IsFoodCompatibleByRules(numericPetLevel, level)
				local underPetCap = (tonumber(level) or 0) <= numericPetLevel
				if isCompatible and underPetCap and level >= bestLevel then
					if level > bestLevel then
						bestLevel = level
						bestRow = row
					elseif bestRow == nil then
						bestRow = row
					end
				end
			end
		end
	end

	if bestRow then
		return bestRow, bestLevel
	end

	return nil, 0
end

local function AB_CountDietItemsInBags(dietName)
	local normalizedDiet = AB_NormalizeDietToken(dietName)
	if normalizedDiet == "" then
		return 0
	end

	local dietMap = AB_GetFoodDietMap()
	local getSlots = _G and _G["GetContainerNumSlots"] or nil
	local getLink = _G and _G["GetContainerItemLink"] or nil
	local getInfo = _G and _G["GetContainerItemInfo"] or nil
	if type(getSlots) ~= "function" or type(getLink) ~= "function" or type(getInfo) ~= "function" then
		return 0
	end

	local count = 0
	for bag = 0, 4 do
		local slots = tonumber(getSlots(bag)) or 0
		for slot = 1, slots do
			local link = getLink(bag, slot)
			local itemId = AB_ParseItemIdFromLink(link)
			local numericId = tonumber(itemId)
			if numericId and dietMap[numericId] == normalizedDiet then
				local _, itemCount = getInfo(bag, slot)
				itemCount = math.floor(tonumber(itemCount) or 1)
				if itemCount < 1 then
					itemCount = 1
				end
				count = count + itemCount
			end
		end
	end

	return count
end

local function AB_ResolveAmmoByName(name)
	if type(name) ~= "string" or name == "" then
		return nil, nil
	end
	local lookup = AB_GetAmmoLookupByName()
	local row = lookup[string.lower(name)]
	if type(row) ~= "table" then
		return nil, nil
	end
	return row.itemId, row.subtype
end

local function AB_GetInventoryBagSlotByContainerId(containerId)
	local toInv = _G and _G["ContainerIDToInventoryID"] or nil
	if type(toInv) == "function" then
		local invSlot = tonumber(toInv(containerId))
		if invSlot and invSlot > 0 then
			return invSlot
		end
	end
	local bag = tonumber(containerId)
	if bag and bag >= 1 and bag <= 4 then
		return bag + 19
	end
	return nil
end

local function AB_GetSpecialAmmoBagTargets()
	local targets = {
		arrow = {},
		bullet = {},
	}
	local getInvLink = _G and _G["GetInventoryItemLink"] or nil
	if type(getInvLink) ~= "function" then
		return targets
	end
	for bag = 1, 4 do
		local invSlot = AB_GetInventoryBagSlotByContainerId(bag)
		if invSlot then
			local bagLink = getInvLink("player", invSlot)
			local bagItemId = AB_ParseItemIdFromLink(bagLink)
			local bagRow = (MTH_DS_BagItems and bagItemId) and MTH_DS_BagItems[tonumber(bagItemId) or bagItemId] or nil
			local bagSubtype = bagRow and string.lower(tostring(bagRow.subtype or "")) or ""
			if bagSubtype == "quiver" then
				table.insert(targets.arrow, { bag = bag, invSlot = invSlot, itemId = bagItemId, subtype = bagSubtype })
			elseif bagSubtype == "ammo pouch" then
				table.insert(targets.bullet, { bag = bag, invSlot = invSlot, itemId = bagItemId, subtype = bagSubtype })
			end
		end
	end
	return targets
end

local function AB_MoveAmmoStacksToSpecialBags(maxMoves)
	local getSlots = _G and _G["GetContainerNumSlots"] or nil
	local getLink = _G and _G["GetContainerItemLink"] or nil
	local pick = _G and _G["PickupContainerItem"] or nil
	local putInBag = _G and _G["PutItemInBag"] or nil
	local hasCursor = _G and _G["CursorHasItem"] or nil
	local clearCursor = _G and _G["ClearCursor"] or nil
	if type(getSlots) ~= "function" or type(getLink) ~= "function"
		or type(pick) ~= "function" or type(putInBag) ~= "function"
		or type(hasCursor) ~= "function" or type(clearCursor) ~= "function" then
		return 0
	end

	local targets = AB_GetSpecialAmmoBagTargets()
	local arrowTargets = targets.arrow or {}
	local bulletTargets = targets.bullet or {}
	if table.getn(arrowTargets) == 0 and table.getn(bulletTargets) == 0 then
		return 0
	end

	local moves = 0
	local moveLimit = math.floor(tonumber(maxMoves) or 200)
	if moveLimit < 1 then moveLimit = 200 end
	local isTargetBag = {}
	for i = 1, table.getn(arrowTargets) do
		local bagId = tonumber(arrowTargets[i].bag)
		if bagId then
			isTargetBag[bagId] = true
		end
	end
	for i = 1, table.getn(bulletTargets) do
		local bagId = tonumber(bulletTargets[i].bag)
		if bagId then
			isTargetBag[bagId] = true
		end
	end

	for sourceBag = 0, 4 do
		local isSpecialSource = isTargetBag[tonumber(sourceBag)] and true or false
		if not isSpecialSource then
			local slots = tonumber(getSlots(sourceBag)) or 0
			for sourceSlot = 1, slots do
				local link = getLink(sourceBag, sourceSlot)
				local itemId = AB_ParseItemIdFromLink(link)
				local ammoSubtype = itemId and AB_GetAmmoSubtypeByItemId(itemId) or nil
				if ammoSubtype then
					local destinationTargets = ammoSubtype == "arrow" and arrowTargets or bulletTargets
					if table.getn(destinationTargets) > 0 then
						pick(sourceBag, sourceSlot)
						if hasCursor() then
							for i = 1, table.getn(destinationTargets) do
								putInBag(destinationTargets[i].invSlot)
								if not hasCursor() then
									moves = moves + 1
									break
								end
							end
							if hasCursor() then
								clearCursor()
							end
							if moves >= moveLimit then
								return moves
							end
						end
					end
				end
			end
		end
	end

	return moves
end

local function AB_DefaultRule()
	return {
		enabled = false,
		itemId = nil,
		stacks = 1,
	}
end

local function AB_EnsureRuleList(bucket)
	if type(bucket) ~= "table" then
		bucket = {}
	end
	if type(bucket.rules) ~= "table" then
		bucket.rules = {}
	end
	for i = 1, 3 do
		if type(bucket.rules[i]) ~= "table" then
			bucket.rules[i] = AB_DefaultRule()
		end
		if bucket.rules[i].enabled == nil then
			bucket.rules[i].enabled = false
		end
		if bucket.rules[i].stacks == nil then
			bucket.rules[i].stacks = 1
		end
	end
	return bucket
end

local function AB_DeepCopy(value)
	if type(value) ~= "table" then
		return value
	end
	local copy = {}
	for key, entry in pairs(value) do
		copy[key] = AB_DeepCopy(entry)
	end
	return copy
end

function Engine:GetConfigStore()
	if MTH and MTH.GetModuleCharSavedVariables then
		local charStore = MTH:GetModuleCharSavedVariables("autobuy")
		if type(charStore) == "table" then
			if MTH.GetModuleSavedVariables then
				local accountStore = MTH:GetModuleSavedVariables("autobuy")
				if type(accountStore) == "table" and next(charStore) == nil and next(accountStore) ~= nil then
					for key, value in pairs(accountStore) do
						charStore[key] = AB_DeepCopy(value)
					end
				end
			end
			return charStore
		end
	end
	if MTH and MTH.GetModuleSavedVariables then
		local accountStore = MTH:GetModuleSavedVariables("autobuy")
		if type(accountStore) == "table" then
			return accountStore
		end
	end
	self._transientStore = self._transientStore or {}
	return self._transientStore
end

function Engine:EnsureDefaults()
	local store = self:GetConfigStore()
	if store.enabled == nil then
		store.enabled = true
	end
	if type(store.food) ~= "table" then
		store.food = {}
	end
	if type(store.ammo) ~= "table" then
		store.ammo = {}
	end
	if type(store.projectiles) ~= "table" then
		store.projectiles = {}
	end
	if type(store.petFood) ~= "table" then
		store.petFood = {}
	end
	if store.food.enabled == nil then
		store.food.enabled = true
	end
	if store.ammo.enabled == nil then
		store.ammo.enabled = true
	end
	if store.projectiles.enabled == nil then
		store.projectiles.enabled = true
	end
	if store.petFood.enabled == nil then
		store.petFood.enabled = false
	end
	if store.petFood.stacks == nil then
		store.petFood.stacks = 1
	end
	if store.petFood.scope == nil then
		store.petFood.scope = "current"
	end
	store.petFood.stacks = math.floor(tonumber(store.petFood.stacks) or 1)
	if store.petFood.stacks < 0 then
		store.petFood.stacks = 0
	end
	if store.petFood.scope ~= "current" and store.petFood.scope ~= "all" then
		store.petFood.scope = "current"
	end
	if store.food.minStock == nil then
		store.food.minStock = 200
	end
	if store.ammo.minStock == nil then
		store.ammo.minStock = 1000
	end
	if store.food.preferredDiet == nil then
		store.food.preferredDiet = nil
	end
	if store.ammo.preferredType == nil then
		store.ammo.preferredType = nil
	end
	store.projectiles.arrows = AB_EnsureRuleList(store.projectiles.arrows)
	store.projectiles.bullets = AB_EnsureRuleList(store.projectiles.bullets)
	return store
end

function Engine:GetBuyableProjectileItems(subtype)
	local wanted = string.lower(tostring(subtype or ""))
	if wanted ~= "arrow" and wanted ~= "bullet" then
		return {}
	end

	local result = {}
	local data = MTH_DS_AmmoItems or {}
	for itemId, row in pairs(data) do
		if type(row) == "table" and string.lower(tostring(row.subtype or "")) == wanted then
			local vendorCount = 0
			if type(row.vendors) == "table" then
				for _ in pairs(row.vendors) do
					vendorCount = vendorCount + 1
					break
				end
			end
			if vendorCount > 0 then
				table.insert(result, {
					itemId = tonumber(itemId) or itemId,
					name = tostring(row.name or ("Item " .. tostring(itemId))),
					level = tonumber(row.level) or 0,
					reqlevel = tonumber(row.reqlevel) or 0,
				})
			end
		end
	end

	table.sort(result, function(a, b)
		if (a.level or 0) ~= (b.level or 0) then
			return (a.level or 0) < (b.level or 0)
		end
		if (a.reqlevel or 0) ~= (b.reqlevel or 0) then
			return (a.reqlevel or 0) < (b.reqlevel or 0)
		end
		if tostring(a.name or "") ~= tostring(b.name or "") then
			return tostring(a.name or "") < tostring(b.name or "")
		end
		return tonumber(a.itemId or 0) < tonumber(b.itemId or 0)
	end)

	return result
end

function Engine:IsEnabled()
	local store = self:EnsureDefaults()
	return store.enabled and true or false
end

function Engine:Init()
	self:EnsureDefaults()
end

function Engine:ScanMerchant()
	if type(GetMerchantNumItems) ~= "function" then
		return { count = 0, items = {} }
	end

	local result = {
		count = GetMerchantNumItems() or 0,
		items = {},
	}

	for index = 1, result.count do
		local name, _, price, stackCount, numAvailable = GetMerchantItemInfo(index)
		local link = GetMerchantItemLink(index)
		local itemId = AB_ParseItemIdFromLink(link)
		local subtype = AB_GetAmmoSubtypeByItemId(itemId)
		if (not itemId or not subtype) and type(name) == "string" and name ~= "" then
			local byNameItemId, byNameSubtype = AB_ResolveAmmoByName(name)
			if byNameItemId and byNameSubtype then
				itemId = byNameItemId
				subtype = byNameSubtype
			end
		end
		result.items[index] = {
			index = index,
			name = name,
			link = link,
			itemId = itemId,
			subtype = subtype,
			price = price,
			stackCount = stackCount,
			numAvailable = numAvailable,
		}
	end

	return result
end

function Engine:BuildFoodPlan(merchantSnapshot)
	local store = self:EnsureDefaults()
	local plan = {
		enabled = store.petFood and store.petFood.enabled and true or false,
		actions = {},
		reason = "",
		debugLines = {},
	}

	local function dbg(line)
		table.insert(plan.debugLines, tostring(line or ""))
	end

	if not plan.enabled then
		plan.reason = "petfood-disabled"
		dbg("petFood option disabled")
		return plan
	end

	local targetStacks = math.floor(tonumber(store.petFood.stacks) or 0)
	if targetStacks <= 0 then
		plan.reason = "petfood-quantity-zero"
		dbg("petFood target stacks <= 0")
		return plan
	end

	local merchantFoods = AB_GetMerchantFoodsSnapshot(merchantSnapshot)
	if type(merchantFoods) ~= "table" or type(merchantFoods.byDiet) ~= "table" then
		plan.reason = "merchant-foods-missing"
		dbg("merchant food scan missing")
		return plan
	end

	local scope = store.petFood.scope == "all" and "all" or "current"
	local petRows = AB_CollectPetRows(scope)
	if table.getn(petRows) == 0 then
		plan.reason = "no-pets-in-scope"
		dbg("no pets in scope=" .. tostring(scope))
		return plan
	end

	local families = {}
	for i = 1, table.getn(petRows) do
		local pet = petRows[i]
		local dsRow, familyKey = AB_FindFamilyDietRow(pet.family)
		if type(dsRow) == "table" and type(dsRow.food) == "table" and table.getn(dsRow.food) > 0 and familyKey then
			if type(families[familyKey]) ~= "table" then
				families[familyKey] = {
					key = familyKey,
					petCount = 0,
					levelCap = tonumber(pet.level) or 0,
					foodList = dsRow.food,
					petNames = {},
					candidates = {},
				}
			end
			local family = families[familyKey]
			family.petCount = family.petCount + 1
			local petName = tostring(pet.name or "")
			if petName ~= "" then
				table.insert(family.petNames, petName)
			end
			local petLevel = tonumber(pet.level) or 0
			if family.levelCap <= 0 then
				family.levelCap = petLevel
			elseif petLevel > family.levelCap then
				family.levelCap = petLevel
			end
		else
			dbg("skip pet with unknown family diet: " .. tostring(pet.name or "?") .. " family='" .. tostring(pet.family or "") .. "'")
		end
	end

	local familyList = {}
	local dietCoverage = {}
	for _, family in pairs(families) do
		for order = 1, table.getn(family.foodList or {}) do
			local diet = AB_NormalizeDietToken(family.foodList[order])
			if diet ~= "" then
				local bestRow, bestLevel = AB_SelectBestFoodRowForDiet(merchantFoods.byDiet[diet], family.levelCap)
				if bestRow then
					table.insert(family.candidates, {
						diet = diet,
						order = order,
						bestLevel = bestLevel,
					})
					dietCoverage[diet] = (dietCoverage[diet] or 0) + 1
				end
			end
		end
		if table.getn(family.candidates) > 0 then
			table.insert(familyList, family)
		else
			dbg("family has no vendor diet options: " .. tostring(family.key))
		end
	end

	if table.getn(familyList) == 0 then
		plan.reason = "no-family-food-match"
		dbg("no families have compatible vendor foods")
		return plan
	end

	table.sort(familyList, function(a, b)
		if (a.petCount or 0) ~= (b.petCount or 0) then
			return (a.petCount or 0) > (b.petCount or 0)
		end
		if table.getn(a.candidates or {}) ~= table.getn(b.candidates or {}) then
			return table.getn(a.candidates or {}) < table.getn(b.candidates or {})
		end
		return tostring(a.key or "") < tostring(b.key or "")
	end)

	local assignedPetCountByDiet = {}
	local chosenByFamily = {}
	for i = 1, table.getn(familyList) do
		local family = familyList[i]
		local bestChoice = nil
		for j = 1, table.getn(family.candidates) do
			local candidate = family.candidates[j]
			local scoreA = (assignedPetCountByDiet[candidate.diet] or 0) + (family.petCount or 0)
			local scoreB = dietCoverage[candidate.diet] or 0
			local scoreC = candidate.bestLevel or 0
			local scoreD = -(candidate.order or 99)
			if not bestChoice then
				bestChoice = {
					candidate = candidate,
					scoreA = scoreA,
					scoreB = scoreB,
					scoreC = scoreC,
					scoreD = scoreD,
				}
			else
				local better = false
				if scoreA > bestChoice.scoreA then
					better = true
				elseif scoreA == bestChoice.scoreA and scoreB > bestChoice.scoreB then
					better = true
				elseif scoreA == bestChoice.scoreA and scoreB == bestChoice.scoreB and scoreC > bestChoice.scoreC then
					better = true
				elseif scoreA == bestChoice.scoreA and scoreB == bestChoice.scoreB and scoreC == bestChoice.scoreC and scoreD > bestChoice.scoreD then
					better = true
				end
				if better then
					bestChoice = {
						candidate = candidate,
						scoreA = scoreA,
						scoreB = scoreB,
						scoreC = scoreC,
						scoreD = scoreD,
					}
				end
			end
		end

		if bestChoice and bestChoice.candidate then
			chosenByFamily[family.key] = {
				diet = bestChoice.candidate.diet,
				levelCap = family.levelCap,
				petCount = family.petCount,
				petNames = family.petNames,
			}
			assignedPetCountByDiet[bestChoice.candidate.diet] = (assignedPetCountByDiet[bestChoice.candidate.diet] or 0) + (family.petCount or 0)
			dbg("family " .. tostring(family.key)
				.. " -> diet " .. tostring(bestChoice.candidate.diet)
				.. " (pets=" .. tostring(family.petCount)
				.. ", levelCap=" .. tostring(family.levelCap)
				.. ")")
		end
	end

	local buckets = {}
	for familyKey, chosen in pairs(chosenByFamily) do
		local diet = chosen.diet
		if type(buckets[diet]) ~= "table" then
			buckets[diet] = {
				diet = diet,
				petCount = 0,
				familyCount = 0,
				levelCap = chosen.levelCap,
				petNames = {},
			}
		end
		local bucket = buckets[diet]
		bucket.petCount = bucket.petCount + (chosen.petCount or 0)
		bucket.familyCount = bucket.familyCount + 1
		if type(chosen.petNames) == "table" then
			for n = 1, table.getn(chosen.petNames) do
				local candidateName = tostring(chosen.petNames[n] or "")
				if candidateName ~= "" then
					local exists = false
					for e = 1, table.getn(bucket.petNames) do
						if bucket.petNames[e] == candidateName then
							exists = true
							break
						end
					end
					if not exists then
						table.insert(bucket.petNames, candidateName)
					end
				end
			end
		end
		if tonumber(chosen.levelCap) and tonumber(chosen.levelCap) > 0 then
			if (tonumber(bucket.levelCap) or 0) <= 0 or tonumber(chosen.levelCap) > tonumber(bucket.levelCap) then
				bucket.levelCap = tonumber(chosen.levelCap)
			end
		end
		dbg("bucket diet=" .. tostring(diet) .. " add family=" .. tostring(familyKey))
	end

	for dietName, bucket in pairs(buckets) do
		local bestRow, bestLevel = AB_SelectBestFoodRowForDiet(merchantFoods.byDiet[dietName], bucket.levelCap)
		if bestRow and bestRow.index then
			local stackCount = math.floor(tonumber(bestRow.stack) or 1)
			if stackCount < 1 then stackCount = 1 end
			local bagStackSize = AB_GetItemMaxStack(bestRow.id, stackCount)
			local targetItems = targetStacks * bagStackSize
			local ownedItems = AB_CountDietItemsInBags(dietName)
			local deficitItems = targetItems - ownedItems
			local deficit = 0
			if deficitItems > 0 then
				deficit = math.ceil(deficitItems / stackCount)
			end
			dbg("diet=" .. tostring(dietName)
				.. " targetStacks=" .. tostring(targetStacks)
				.. " bagStackSize=" .. tostring(bagStackSize)
				.. " vendorStackSize=" .. tostring(stackCount)
				.. " targetItems=" .. tostring(targetItems)
				.. " ownedItems=" .. tostring(ownedItems)
				.. " deficitItems=" .. tostring(deficitItems)
				.. " deficit=" .. tostring(deficit)
				.. " selectedLevel=" .. tostring(bestLevel)
				.. " levelCap=" .. tostring(bucket.levelCap)
				.. " pets=" .. tostring(bucket.petCount)
				.. " families=" .. tostring(bucket.familyCount))
			if deficit > 0 then
				table.insert(plan.actions, {
					index = bestRow.index,
					quantityStacks = deficit,
					quantityItems = deficit * stackCount,
					unitPrice = tonumber(bestRow.price) or 0,
					itemId = tonumber(bestRow.id) or bestRow.id,
					itemLink = bestRow.link,
					itemName = bestRow.name,
					diet = dietName,
					targetStacks = targetStacks,
					bagStackSize = bagStackSize,
					vendorStackSize = stackCount,
					targetItems = targetItems,
					ownedItems = ownedItems,
					deficitItems = deficitItems,
					deficit = deficit,
					stackCount = stackCount,
					petCount = bucket.petCount,
					familyCount = bucket.familyCount,
					petNames = bucket.petNames,
				})
			end
		else
			dbg("diet " .. tostring(dietName) .. " has no compatible row at levelCap=" .. tostring(bucket.levelCap))
		end
	end

	if table.getn(plan.actions) == 0 then
		plan.reason = "no-deficit"
	else
		plan.reason = "ok"
	end

	return plan
end

function Engine:BuildAmmoPlan(merchantSnapshot)
	local store = self:EnsureDefaults()
	local plan = {
		enabled = store.projectiles and store.projectiles.enabled and true or false,
		actions = {},
		reason = "",
		debugLines = {},
	}

	local function dbg(line)
		table.insert(plan.debugLines, tostring(line or ""))
	end

	if not plan.enabled then
		plan.reason = "projectiles-disabled"
		dbg("projectiles option disabled")
		return plan
	end

	if type(merchantSnapshot) ~= "table" or type(merchantSnapshot.items) ~= "table" then
		plan.reason = "merchant-snapshot-missing"
		dbg("merchant snapshot missing")
		return plan
	end

	local merchantByItemId = {}
	local hasAmmoVendor = false
	for i = 1, table.getn(merchantSnapshot.items) do
		local row = merchantSnapshot.items[i]
		if type(row) == "table" and row.itemId and row.subtype then
			dbg("merchant row index=" .. tostring(row.index) .. " itemId=" .. tostring(row.itemId) .. " subtype=" .. tostring(row.subtype) .. " stack=" .. tostring(row.stackCount))
			merchantByItemId[tonumber(row.itemId) or row.itemId] = row
			hasAmmoVendor = true
		end
	end

	if not hasAmmoVendor then
		plan.reason = "not-ammo-vendor"
		dbg("merchant has no recognized arrow/bullet rows")
		return plan
	end

	local function countStacksInBags(itemId)
		if not itemId then
			return 0
		end
		local count = 0
		local getSlots = _G and _G["GetContainerNumSlots"] or nil
		local getLink = _G and _G["GetContainerItemLink"] or nil
		if type(getSlots) ~= "function" or type(getLink) ~= "function" then
			return 0
		end
		for bag = 0, 4 do
			local slots = tonumber(getSlots(bag)) or 0
			for slot = 1, slots do
				local link = getLink(bag, slot)
				local bagItemId = AB_ParseItemIdFromLink(link)
				if bagItemId and tonumber(bagItemId) == tonumber(itemId) then
					count = count + 1
				end
			end
		end
		return count
	end

	local function appendRuleActions(bucket, subtype)
		if type(bucket) ~= "table" or type(bucket.rules) ~= "table" then
			dbg(subtype .. " rules bucket missing")
			return
		end
		for i = 1, table.getn(bucket.rules) do
			local rule = bucket.rules[i]
			if type(rule) == "table" and rule.enabled and rule.itemId then
				local desiredStacks = math.floor(tonumber(rule.stacks) or 0)
				if desiredStacks > 0 then
					local merchantRow = merchantByItemId[tonumber(rule.itemId) or rule.itemId]
					if merchantRow and merchantRow.subtype == subtype then
						local ownedStacks = countStacksInBags(rule.itemId)
						local deficit = desiredStacks - ownedStacks
						dbg(subtype .. "#" .. tostring(i) .. " item=" .. tostring(rule.itemId)
							.. " desired=" .. tostring(desiredStacks)
							.. " owned=" .. tostring(ownedStacks)
							.. " deficit=" .. tostring(deficit))
						if deficit > 0 then
							local merchantStack = math.floor(tonumber(merchantRow.stackCount) or 1)
							if merchantStack < 1 then merchantStack = 1 end
							local quantityStacks = deficit
							local quantityItems = quantityStacks * merchantStack
							table.insert(plan.actions, {
								index = merchantRow.index,
								quantityStacks = quantityStacks,
								quantityItems = quantityItems,
								unitPrice = tonumber(merchantRow.price) or 0,
								itemId = rule.itemId,
								itemLink = merchantRow.link,
								itemName = merchantRow.name,
								subtype = subtype,
								desiredStacks = desiredStacks,
								ownedStacks = ownedStacks,
								deficit = deficit,
								stackCount = merchantStack,
							})
						end
					else
						dbg(subtype .. "#" .. tostring(i) .. " item=" .. tostring(rule.itemId) .. " not sold by this vendor")
					end
				else
					dbg(subtype .. "#" .. tostring(i) .. " desired stacks <= 0")
				end
			else
				dbg(subtype .. "#" .. tostring(i) .. " disabled or no item")
			end
		end
	end

	appendRuleActions(store.projectiles.arrows, "arrow")
	appendRuleActions(store.projectiles.bullets, "bullet")

	if table.getn(plan.actions) == 0 then
		plan.reason = "no-deficit"
	else
		plan.reason = "ok"
	end

	return plan
end

function Engine:ExecutePlan(plan)
	if type(plan) ~= "table" or type(plan.actions) ~= "table" then
		AB_Trace("ExecutePlan skipped: invalid plan table")
		return 0, 0
	end
	local executedActions = 0
	local requestedStacks = 0
	for _, action in ipairs(plan.actions) do
		if type(action) == "table" and action.index then
			local stacksToBuy = math.floor(tonumber(action.quantityStacks) or 0)
			if stacksToBuy > 0 then
				AB_Trace("ExecutePlan action index=" .. tostring(action.index)
					.. " itemId=" .. tostring(action.itemId)
					.. " stacks=" .. tostring(stacksToBuy)
					.. " reason=" .. tostring(plan.reason or ""))
				for i = 1, stacksToBuy do
					BuyMerchantItem(action.index)
				end
				executedActions = executedActions + 1
				requestedStacks = requestedStacks + stacksToBuy
			end
		end
	end
	AB_Trace("ExecutePlan done actions=" .. tostring(executedActions) .. " stacks=" .. tostring(requestedStacks) .. " reason=" .. tostring(plan.reason or ""))
	return executedActions, requestedStacks
end

local function AB_AnnouncePurchases(actions)
	if type(actions) ~= "table" or table.getn(actions) == 0 then
		return
	end

	local function formatMoney(money)
		if MTH and MTH.FormatMoney then
			return MTH:FormatMoney(money)
		end
		if type(MTH_FormatMoney) == "function" then
			return MTH_FormatMoney(money)
		end
		return tostring(tonumber(money) or 0)
	end

	for i = 1, table.getn(actions) do
		local action = actions[i]
		if type(action) == "table" then
			local stacks = math.floor(tonumber(action.quantityStacks) or 0)
			if stacks > 0 then
				local linkText = tostring(action.itemLink or "")
				if linkText == "" then
					linkText = tostring(action.itemName or ("item:" .. tostring(action.itemId or "?")))
				end
				local totalPrice = (tonumber(action.unitPrice) or 0) * stacks
				local petsSuffix = ""
				if type(action.petNames) == "table" and table.getn(action.petNames) > 0 then
					local names = {}
					for n = 1, table.getn(action.petNames) do
						local petName = tostring(action.petNames[n] or "")
						if petName ~= "" then
							table.insert(names, petName)
						end
					end
					if table.getn(names) > 0 then
						table.sort(names)
						if table.getn(names) == 1 then
							petsSuffix = " " .. tostring(names[1]) .. " likes this !"
						else
							petsSuffix = " " .. table.concat(names, ", ") .. " like this !"
						end
					end
				end
				local line = "[AutoBuy] Bought " .. tostring(stacks)
					.. " stack" .. (stacks > 1 and "s" or "")
					.. " of " .. linkText
					.. " for " .. formatMoney(totalPrice) .. "."
					.. petsSuffix
				if MTH and MTH.Print then
					MTH:Print(line)
				elseif type(MTH_Log) == "function" then
					MTH_Log(line)
				end
			end
		end
	end
end

function Engine:OnMerchantEvent(eventName)
	AB_Trace("OnMerchantEvent start event=" .. tostring(eventName)
		.. " sessionExecuted=" .. tostring(self._merchantSessionExecuted and true or false)
		.. " engineEnabled=" .. tostring(self:IsEnabled() and true or false))

	if eventName == "MERCHANT_SHOW" then
		self._merchantSessionExecuted = false
		AB_Trace("MERCHANT_SHOW resets session execution flag")
	elseif eventName == "MERCHANT_UPDATE" and self._merchantSessionExecuted then
		AB_Trace("MERCHANT_UPDATE ignored: already executed this merchant session")
		return
	end

	if not self:IsEnabled() then
		AB_Trace("event ignored: autobuy module disabled")
		return
	end

	local snapshot = self:ScanMerchant()
	AB_Trace("snapshot rows=" .. tostring(snapshot and snapshot.count or 0))
	local foodPlan = self:BuildFoodPlan(snapshot)
	local ammoPlan = self:BuildAmmoPlan(snapshot)

	AB_Trace("foodPlan reason=" .. tostring(foodPlan.reason) .. " actions=" .. tostring(table.getn(foodPlan.actions or {})))
	for i = 1, table.getn(foodPlan.debugLines or {}) do
		AB_Trace("food#" .. tostring(i) .. " " .. tostring(foodPlan.debugLines[i]))
	end
	AB_Trace("ammoPlan reason=" .. tostring(ammoPlan.reason) .. " actions=" .. tostring(table.getn(ammoPlan.actions or {})))
	for i = 1, table.getn(ammoPlan.debugLines or {}) do
		AB_Trace("ammo#" .. tostring(i) .. " " .. tostring(ammoPlan.debugLines[i]))
	end

	local totalRequestedStacks = 0
	if table.getn(foodPlan.actions or {}) > 0 then
		local _, requestedStacks = self:ExecutePlan(foodPlan)
		totalRequestedStacks = totalRequestedStacks + requestedStacks
		AB_Trace("food plan executed requestedStacks=" .. tostring(requestedStacks))
		if requestedStacks > 0 then
			AB_AnnouncePurchases(foodPlan.actions)
		end
	end

	if table.getn(ammoPlan.actions or {}) > 0 then
		local _, requestedStacks = self:ExecutePlan(ammoPlan)
		totalRequestedStacks = totalRequestedStacks + requestedStacks
		AB_Trace("ammo plan executed requestedStacks=" .. tostring(requestedStacks))
		if requestedStacks > 0 then
			local moved = AB_MoveAmmoStacksToSpecialBags(300)
			AB_Trace("ammo restack moved=" .. tostring(moved))
			AB_AnnouncePurchases(ammoPlan.actions)
		end
	end

	if totalRequestedStacks > 0 then
		self._merchantSessionExecuted = true
		AB_Trace("session marked executed requestedStacks=" .. tostring(totalRequestedStacks))
	else
		AB_Trace("no purchases requested in this event")
	end
end

function Engine:OnMerchantClosed()
	self._merchantSessionExecuted = false
end

function MTH_AutoBuy_GetMerchantSnapshot()
	return Engine:ScanMerchant()
end

function MTH_AutoBuy_GetProjectileItems(subtype)
	return Engine:GetBuyableProjectileItems(subtype)
end
