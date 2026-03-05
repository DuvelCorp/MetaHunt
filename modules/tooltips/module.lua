------------------------------------------------------
-- MetaHunt: Tooltips Module
-- Standalone beast tooltip augmentation from MetaHunt data
------------------------------------------------------

local MTH_Tooltips = {
	name = "tooltips",
	enabled = true,
	version = "1.0.6",
	events = {
		"UPDATE_MOUSEOVER_UNIT",
		"UNIT_NAME_UPDATE",
	},
	initialized = false,
	beastIndex = nil,
	vendorIndex = nil,
	debugState = {
		events = 0,
		pollTicks = 0,
		pollTriggers = 0,
		injectAttempts = 0,
		added = 0,
		lookupMiss = 0,
		skipNoUnit = 0,
		skipPlayerControlled = 0,
		skipTooltipApi = 0,
		skipNoName = 0,
		skipExistingLine = 0,
		lastUnitName = "",
		lastNormalized = "",
		lastOutcome = "",
	},
	hookInstalled = false,
	injectFrame = nil,
	pollFrame = nil,
	pollElapsed = 0,
	hintElapsed = 0,
	lastMouseoverKey = "",
}

local function MTH_TT_CopyValue(value)
	if type(value) ~= "table" then
		return value
	end
	local copy = {}
	for key, entry in pairs(value) do
		copy[key] = MTH_TT_CopyValue(entry)
	end
	return copy
end

local function MTH_TT_GetOptionsStore()
	if MTH and MTH.GetModuleCharSavedVariables then
		local store = MTH:GetModuleCharSavedVariables("tooltips")
		if type(store) == "table" then
			if MTH.GetModuleSavedVariables and next(store) == nil then
				local accountStore = MTH:GetModuleSavedVariables("tooltips")
				if type(accountStore) == "table" and next(accountStore) ~= nil then
					for key, value in pairs(accountStore) do
						store[key] = MTH_TT_CopyValue(value)
					end
				end
			end
			if store.beastTooltips == nil then
				store.beastTooltips = true
			end
			if store.ammoVendorTooltips == nil then
				store.ammoVendorTooltips = true
			end
			if store.foodItemTooltips == nil then
				if type(FOM_Config) == "table" and FOM_Config.Tooltip ~= nil then
					store.foodItemTooltips = FOM_Config.Tooltip and true or false
				else
					store.foodItemTooltips = true
				end
			end
			if store.ownPetTooltips == nil then
				store.ownPetTooltips = false
			end
			return store
		end
	end
	return nil
end

local function MTH_TT_IsBeastTooltipsEnabled()
	local store = MTH_TT_GetOptionsStore()
	if type(store) == "table" then
		return store.beastTooltips and true or false
	end
	return true
end

local function MTH_TT_IsAmmoVendorTooltipsEnabled()
	local store = MTH_TT_GetOptionsStore()
	if type(store) == "table" then
		return store.ammoVendorTooltips and true or false
	end
	return true
end

local function MTH_TT_IsFoodItemTooltipsEnabled()
	local store = MTH_TT_GetOptionsStore()
	if type(store) == "table" then
		return store.foodItemTooltips and true or false
	end
	return true
end

local function MTH_TT_IsOwnPetTooltipsEnabled()
	local store = MTH_TT_GetOptionsStore()
	if type(store) == "table" then
		return store.ownPetTooltips and true or false
	end
	return false
end

local function MTH_TT_Loc(key, fallback)
	if MTH and MTH.GetLocalization then
		return MTH:GetLocalization(key, fallback)
	end
	return fallback
end

local function MTH_TT_Lower(value)
	if value == nil then return "" end
	return string.lower(tostring(value))
end

local function MTH_TT_Trim(value)
	if value == nil then return "" end
	local text = tostring(value)
	text = string.gsub(text, "^%s+", "")
	text = string.gsub(text, "%s+$", "")
	return text
end

local function MTH_TT_NormalizeName(value)
	local text = MTH_TT_Trim(value)
	text = MTH_TT_Lower(text)
	text = string.gsub(text, "[^%w%s]", " ")
	text = string.gsub(text, "%s+", " ")
	text = MTH_TT_Trim(text)
	return text
end

local function MTH_TT_Log(line)
	return
end

local function MTH_TT_StateSet(outcome, unitName, normalized)
	local state = MTH_Tooltips and MTH_Tooltips.debugState
	if not state then return end
	state.lastOutcome = tostring(outcome or "")
	state.lastUnitName = tostring(unitName or "")
	state.lastNormalized = tostring(normalized or "")
end

local function MTH_TT_BuildIndex()
	local index = { byName = {} }
	if type(MTH_DS_Beasts) ~= "table" then
		MTH_TT_Log("build index skipped: MTH_DS_Beasts missing")
		return index
	end

	local count = 0
	for _, row in pairs(MTH_DS_Beasts) do
		if type(row) == "table" then
			local beastName = MTH_TT_Trim(row.name)
			if beastName ~= "" then
				local key = MTH_TT_NormalizeName(beastName)
				if not index.byName[key] then
					index.byName[key] = row
					count = count + 1
				end
			end
		end
	end

	MTH_TT_Log("build index complete: uniqueNames=" .. tostring(count))

	return index
end

local function MTH_TT_FindBeastRow(name)
	if not MTH_Tooltips.beastIndex then
		MTH_Tooltips.beastIndex = MTH_TT_BuildIndex()
	end

	local lookup = MTH_TT_NormalizeName(name)
	if lookup == "" then return nil end

	return MTH_Tooltips.beastIndex.byName[lookup]
end

local function MTH_TT_BuildVendorIndex()
	local index = { byName = {} }
	if type(MTH_DS_AmmoItems) ~= "table" or type(MTH_DS_Vendors) ~= "table" then
		MTH_TT_Log("build vendor index skipped: ammo items or vendors missing")
		return index
	end

	for _, item in pairs(MTH_DS_AmmoItems) do
		if type(item) == "table" and type(item.vendors) == "table" then
			local subtype = MTH_TT_Lower(item.subtype)
			local hasArrows = subtype == "arrow"
			local hasBullets = subtype == "bullet"
			if hasArrows or hasBullets then
				for vendorId in pairs(item.vendors) do
					local id = tonumber(vendorId) or vendorId
					local vendor = MTH_DS_Vendors[id]
					if type(vendor) == "table" then
						local vendorName = MTH_TT_Trim(vendor.name)
						local key = MTH_TT_NormalizeName(vendorName)
						if key ~= "" then
							local entry = index.byName[key]
							if not entry then
								entry = {
									name = vendorName,
									arrows = false,
									bullets = false,
								}
								index.byName[key] = entry
							end
							if hasArrows then
								entry.arrows = true
							end
							if hasBullets then
								entry.bullets = true
							end
						end
					end
				end
			end
		end
	end

	return index
end

local function MTH_TT_FindVendorInfo(name)
	if not MTH_Tooltips.vendorIndex then
		MTH_Tooltips.vendorIndex = MTH_TT_BuildVendorIndex()
	end

	local lookup = MTH_TT_NormalizeName(name)
	if lookup == "" then return nil end

	return MTH_Tooltips.vendorIndex.byName[lookup]
end

local function MTH_TT_HasExistingTooltipLine()
	if not GameTooltip or not GameTooltip.NumLines then return false end
	for i = 1, GameTooltip:NumLines() do
		local fontString = getglobal("GameTooltipTextLeft" .. i)
		if fontString and fontString.GetText then
			local text = fontString:GetText()
			if text and (string.find(text, "Pet Abilities", 1, true) or string.find(text, "MetaHunt Abilities", 1, true)) then
				return true
			end
		end
	end
	return false
end

local function MTH_TT_HasExistingVendorTooltipLine()
	if not GameTooltip or not GameTooltip.NumLines then return false end
	for i = 1, GameTooltip:NumLines() do
		local fontString = getglobal("GameTooltipTextLeft" .. i)
		if fontString and fontString.GetText then
			local text = fontString:GetText()
			if text and (
				string.find(text, "Sells Arrows and Bullets", 1, true)
				or string.find(text, "Sells Arrows", 1, true)
				or string.find(text, "Sells Bullets", 1, true)
			) then
				return true
			end
		end
	end
	return false
end

local function MTH_TT_HasExistingFoodTooltipLine()
	if not GameTooltip or not GameTooltip.NumLines then return false end
	local markers = {
		MTH_TT_Loc("TOOLTIPS_FOOD_MARKER_UNKNOWN", "can eat this, but hasn't tried it yet."),
		MTH_TT_Loc("TOOLTIPS_FOOD_MARKER_UNDER", "doesn't like this anymore."),
		MTH_TT_Loc("TOOLTIPS_FOOD_MARKER_MIGHT", "might eat this."),
		MTH_TT_Loc("TOOLTIPS_FOOD_MARKER_WILL", "will eat this."),
		MTH_TT_Loc("TOOLTIPS_FOOD_MARKER_LIKE", "likes to eat this."),
		MTH_TT_Loc("TOOLTIPS_FOOD_MARKER_LOVE", "loves to eat this."),
	}
	for i = 1, GameTooltip:NumLines() do
		local fontString = getglobal("GameTooltipTextLeft" .. i)
		if fontString and fontString.GetText then
			local text = fontString:GetText()
			if text then
				for j = 1, table.getn(markers) do
					local marker = markers[j]
					if marker and marker ~= "" and string.find(text, marker, 1, true) then
						return true
					end
				end
			end
		end
	end
	return false
end

local function MTH_TT_ExtractItemIdFromLink(link)
	if type(link) ~= "string" then
		return nil
	end
	local _, _, itemIdText = string.find(link, "item:(%d+):")
	if itemIdText then
		return tonumber(itemIdText)
	end
	return nil
end

local function MTH_TT_GetQuestColor(name, defaultR, defaultG, defaultB)
	if type(QuestDifficultyColor) == "table" then
		local color = QuestDifficultyColor[name]
		if type(color) == "table" and color.r and color.g and color.b then
			return color.r, color.g, color.b
		end
	end
	return defaultR, defaultG, defaultB
end

local function MTH_TT_FormatElapsedStableStyle(timestamp)
	local value = tonumber(timestamp)
	if not value or value <= 0 then
		return nil
	end
	local now = tonumber(time()) or 0
	local elapsed = now - value
	if elapsed < 0 then elapsed = 0 end
	local days = math.floor(elapsed / 86400)
	local remAfterDays = elapsed - (days * 86400)
	local hours = math.floor(remAfterDays / 3600)
	local remAfterHours = remAfterDays - (hours * 3600)
	local mins = math.floor(remAfterHours / 60)
	if days > 0 then
		if hours > 0 then
			return tostring(days) .. " days " .. tostring(hours) .. " hours"
		end
		return tostring(days) .. " days"
	end
	if hours > 0 then
		if mins > 0 then
			return tostring(hours) .. " hours " .. tostring(mins) .. " minutes"
		end
		return tostring(hours) .. " hours"
	end
	return tostring(mins) .. " minutes"
end

local function MTH_TT_GetTooltipUnitToken()
	if not GameTooltip or type(GameTooltip.GetUnit) ~= "function" then
		return nil
	end
	local ok, unitA, unitB = pcall(function()
		return GameTooltip:GetUnit()
	end)
	if not ok then
		return nil
	end
	if type(unitB) == "string" and unitB ~= "" then
		return unitB
	end
	if type(unitA) == "string" and unitA ~= "" then
		return unitA
	end
	return nil
end

local function MTH_TT_IsOwnerUnderPetFrame(owner)
	if not owner then
		return false
	end
	local petFrame = (_G and _G["PetFrame"]) or (type(getglobal) == "function" and getglobal("PetFrame"))
	local petFrameHappiness = (_G and _G["PetFrameHappiness"]) or (type(getglobal) == "function" and getglobal("PetFrameHappiness"))
	local cursor = owner
	local guard = 0
	while cursor and guard < 20 do
		if cursor == petFrame or cursor == petFrameHappiness then
			return true
		end
		if type(cursor.GetParent) == "function" then
			cursor = cursor:GetParent()
		else
			break
		end
		guard = guard + 1
	end
	return false
end

local function MTH_TT_IsMouseOverPetFrame()
	if type(MouseIsOver) ~= "function" then
		return false
	end
	local petFrame = (_G and _G["PetFrame"]) or (type(getglobal) == "function" and getglobal("PetFrame"))
	local petFrameHappiness = (_G and _G["PetFrameHappiness"]) or (type(getglobal) == "function" and getglobal("PetFrameHappiness"))
	if petFrame and MouseIsOver(petFrame) then
		return true
	end
	if petFrameHappiness and MouseIsOver(petFrameHappiness) then
		return true
	end
	return false
end

local function MTH_TT_IsTooltipOnOwnPet()
	if type(UnitExists) ~= "function" or type(UnitIsUnit) ~= "function" then
		return false
	end
	if not UnitExists("pet") then
		return false
	end

	local owner = nil
	local ownerName = ""
	if GameTooltip and type(GameTooltip.GetOwner) == "function" then
		owner = GameTooltip:GetOwner()
		if owner and owner.GetName then
			ownerName = tostring(owner:GetName() or "")
		end
	end

	if ownerName ~= "" then
		if string.find(ownerName, "PetActionButton", 1, true)
			or string.find(ownerName, "PetActionBar", 1, true)
			or string.find(ownerName, "BT4PetButton", 1, true) then
			return false
		end
	end

	local token = MTH_TT_GetTooltipUnitToken()
	if token and token ~= "" then
		local ok, same = pcall(UnitIsUnit, token, "pet")
		if ok and same then
			return true
		end
	end

	if UnitExists("mouseover") then
		local ok, same = pcall(UnitIsUnit, "mouseover", "pet")
		if ok and same then
			return true
		end
	end

	if owner then
		if MTH_TT_IsOwnerUnderPetFrame(owner) then
			return true
		end
		if ownerName ~= "" and string.find(ownerName, "PetFrame", 1, true) then
			return true
		end
	end

	if MTH_TT_IsMouseOverPetFrame() then
		return true
	end

	local hasMouseover = UnitExists("mouseover") and true or false
	if (not hasMouseover) and (token == nil or token == "") then
		local petName = (type(UnitName) == "function") and tostring(UnitName("pet") or "") or ""
		if petName ~= "" then
			local titleRegion = (type(getglobal) == "function" and getglobal("GameTooltipTextLeft1")) or (_G and _G["GameTooltipTextLeft1"])
			if titleRegion and type(titleRegion.GetText) == "function" then
				local titleText = tostring(titleRegion:GetText() or "")
				if titleText ~= "" and MTH_TT_NormalizeName(titleText) == MTH_TT_NormalizeName(petName) then
					return true
				end
			end
		end
	end

	return false
end

local function MTH_TT_HasExistingOwnPetTooltipLines()
	if not GameTooltip or not GameTooltip.NumLines then return false end
	local function hasMarker(text)
		text = tostring(text or "")
		if text == "" then
			return false
		end
		if string.find(text, "Mood :", 1, true)
			or string.find(text, "Loyalty :", 1, true)
			or string.find(text, "XP :", 1, true)
			or string.find(text, "By my side for:", 1, true)
			or string.find(text, "Has eaten:", 1, true)
			or string.find(text, "times this session", 1, true) then
			return true
		end
		return false
	end
	for i = 1, GameTooltip:NumLines() do
		local left = getglobal("GameTooltipTextLeft" .. i)
		if left and left.GetText then
			if hasMarker(left:GetText()) then
				return true
			end
		end
		local right = getglobal("GameTooltipTextRight" .. i)
		if right and right.GetText then
			if hasMarker(right:GetText()) then
				return true
			end
		end
	end
	return false
end

local function MTH_TT_GetHeatColorByRatio(ratio)
	ratio = tonumber(ratio) or 0
	if ratio < 0 then ratio = 0 end
	if ratio > 1 then ratio = 1 end
	local red = 1 - ratio
	local green = ratio
	local blue = 0.15
	return red, green, blue
end

local function MTH_TT_GetLoyaltyHeatColor(level)
	local numeric = tonumber(level)
	if not numeric then
		return 0.90, 0.90, 0.90
	end
	if numeric < 1 then numeric = 1 end
	if numeric > 6 then numeric = 6 end
	return MTH_TT_GetHeatColorByRatio((numeric - 1) / 5)
end

local function MTH_TT_FormatPercentCompact(percentValue)
	local numeric = tonumber(percentValue)
	if not numeric then
		return "?"
	end
	local rounded = math.floor((numeric * 10) + 0.5) / 10
	local integerPart = math.floor(rounded)
	if math.abs(rounded - integerPart) < 0.001 then
		return tostring(integerPart)
	end
	return string.format("%.1f", rounded)
end

local function MTH_TT_ColorizeDigitsBlue(text)
	local source = tostring(text or "")
	if source == "" then
		return ""
	end
	return string.gsub(source, "(%d+)", "|cff73bfff%1|r")
end

local function MTH_TT_AddOwnPetTooltipHint()
	if not (MTH_Tooltips and MTH_Tooltips.enabled) then
		return
	end
	if not MTH_TT_IsOwnPetTooltipsEnabled() then
		return
	end
	if not GameTooltip or not GameTooltip.AddLine then
		return
	end
	if MTH_TT_HasExistingOwnPetTooltipLines() then
		return
	end
	if not MTH_TT_IsTooltipOnOwnPet() then
		return
	end
	if type(MTH_GetCurrentPetInfo) ~= "function" then
		return
	end
	local petInfo = MTH_GetCurrentPetInfo()
	if type(petInfo) ~= "table" then
		return
	end

	local happinessValue = tonumber(petInfo.happiness)
	local happinessText = "?"
	local happinessR, happinessG, happinessB = 0.90, 0.90, 0.90
	if type(GetPetHappiness) == "function" then
		local h = GetPetHappiness()
		if h ~= nil then
			happinessValue = tonumber(h) or happinessValue
		end
	end
	if happinessValue == 1 then
		happinessText = "Unhappy"
		happinessR, happinessG, happinessB = 1.00, 0.25, 0.25
	elseif happinessValue == 2 then
		happinessText = "Content"
		happinessR, happinessG, happinessB = 1.00, 0.90, 0.20
	elseif happinessValue == 3 then
		happinessText = "Happy"
		happinessR, happinessG, happinessB = 0.25, 1.00, 0.25
	end
	if type(GameTooltip.AddDoubleLine) == "function" then
		GameTooltip:AddDoubleLine("Mood :", tostring(happinessText), 0.90, 0.90, 0.90, happinessR, happinessG, happinessB)
	else
		GameTooltip:AddLine("Mood : " .. tostring(happinessText), happinessR, happinessG, happinessB)
	end

	local loyaltyDisplay = tostring(petInfo.loyaltyDisplay or "")
	if loyaltyDisplay == "" then
		local loyaltyText = tostring(petInfo.loyaltyText or "")
		if loyaltyText ~= "" then
			loyaltyDisplay = loyaltyText
		end
	end
	if loyaltyDisplay ~= "" then
		local loyaltyR, loyaltyG, loyaltyB = MTH_TT_GetLoyaltyHeatColor(petInfo.loyaltyLevel)
		if type(GameTooltip.AddDoubleLine) == "function" then
			GameTooltip:AddDoubleLine("Loyalty :", tostring(loyaltyDisplay), 0.90, 0.90, 0.90, loyaltyR, loyaltyG, loyaltyB)
		else
			GameTooltip:AddLine("Loyalty : " .. tostring(loyaltyDisplay), loyaltyR, loyaltyG, loyaltyB)
		end
	end

	local petLevel = tonumber(petInfo.level)
	local xpCur = tonumber(petInfo.xp)
	local xpTot = tonumber(petInfo.xpMax)
	if (petLevel == nil or petLevel < 60) and xpCur ~= nil and xpTot ~= nil and xpTot > 0 then
		local xpPercent = tonumber(petInfo.xpPercent)
		if xpPercent == nil then
			xpPercent = math.floor((xpCur / xpTot) * 1000 + 0.5) / 10
		end
		local xpRatio = xpCur / xpTot
		local xpR, xpG, xpB = MTH_TT_GetHeatColorByRatio(xpRatio)
		local xpCurInt = math.floor(xpCur + 0.5)
		local xpTotInt = math.floor(xpTot + 0.5)
		local xpValue = MTH_TT_FormatPercentCompact(xpPercent) .. "% (" .. tostring(xpCurInt) .. "/" .. tostring(xpTotInt) .. ")"
		if type(GameTooltip.AddDoubleLine) == "function" then
			GameTooltip:AddDoubleLine("XP :", xpValue, 0.90, 0.90, 0.90, xpR, xpG, xpB)
		else
			GameTooltip:AddLine("XP : " .. xpValue, xpR, xpG, xpB)
		end
	end

	local withMeAt = tonumber(petInfo.withMeSinceAt) or nil
	local withMeText = MTH_TT_FormatElapsedStableStyle(withMeAt)
	if withMeText and withMeText ~= "" then
		local withMeValue = MTH_TT_ColorizeDigitsBlue(tostring(withMeText))
		if type(GameTooltip.AddDoubleLine) == "function" then
			GameTooltip:AddDoubleLine("By my side for:", withMeValue, 0.90, 0.90, 0.90, 0.90, 0.90, 0.90)
		else
			GameTooltip:AddLine("By my side for: " .. withMeValue, 0.90, 0.90, 0.90)
		end
	end

	local sessionFeeds = 0
	if type(MTH_FEED_GetSessionFeedCount) == "function" then
		sessionFeeds = tonumber(MTH_FEED_GetSessionFeedCount(petInfo.id)) or 0
	end
	local feedValue = MTH_TT_ColorizeDigitsBlue(tostring(sessionFeeds) .. " times this session")
	if type(GameTooltip.AddDoubleLine) == "function" then
		GameTooltip:AddDoubleLine("Has eaten:", feedValue, 0.90, 0.90, 0.90, 0.90, 0.90, 0.90)
	else
		GameTooltip:AddLine("Has eaten: " .. feedValue, 0.90, 0.90, 0.90)
	end
	GameTooltip:Show()
end

local function MTH_TT_BuildFoodOpinionLine(itemLink)
	if type(itemLink) ~= "string" then
		return nil
	end

	local pet = type(MTH_FEED_GetCurrentPetContext) == "function" and MTH_FEED_GetCurrentPetContext() or nil
	if type(pet) ~= "table" or not pet.liveExists then
		return nil
	end

	local petName = MTH_TT_Trim(pet.name)
	if petName == "" then
		return nil
	end

	local itemId = MTH_TT_ExtractItemIdFromLink(itemLink)
	if not itemId then
		return nil
	end

	if type(FOM_IsInDiet) == "function" then
		local ok, inDiet = pcall(FOM_IsInDiet, itemId)
		if not ok or not inDiet then
			return nil
		end
	elseif type(MTH_FEED_GetFoodMeta) == "function" then
		local foodMeta = MTH_FEED_GetFoodMeta(itemId)
		if type(foodMeta) ~= "table" or not foodMeta.diet then
			return nil
		end
	end

	local realmPlayer = tostring(FOM_RealmPlayer or "")
	if realmPlayer == "" and type(GetCVar) == "function" and type(UnitName) == "function" then
		local realmName = tostring(GetCVar("realmName") or "")
		local playerName = tostring(UnitName("player") or "")
		if realmName ~= "" and playerName ~= "" then
			realmPlayer = realmName .. "." .. playerName
		end
	end

	local absoluteQuality = nil
	if realmPlayer ~= "" and type(FOM_FoodQuality) == "table" then
		local realmMap = FOM_FoodQuality[realmPlayer]
		if type(realmMap) == "table" then
			local petMap = realmMap[petName]
			if type(petMap) == "table" then
				absoluteQuality = petMap[itemId]
			end
		end
	end

	if absoluteQuality == nil then
		local text = string.format(MTH_TT_Loc("TOOLTIPS_FOOD_QUALITY_UNKNOWN", "%s can eat this, but hasn't tried it yet."), petName)
		local color = HIGHLIGHT_FONT_COLOR
		if color and color.r and color.g and color.b then
			return text, color.r, color.g, color.b
		end
		return text, 1.0, 0.82, 0.0
	end

	local petLevel = tonumber(pet.level) or 0
	if petLevel <= 0 then
		return nil
	end

	local currentQuality = tonumber(absoluteQuality) / petLevel
	if currentQuality < 0 then
		local r, g, b = MTH_TT_GetQuestColor("trivial", 0.5, 0.5, 0.5)
		return string.format(MTH_TT_Loc("TOOLTIPS_FOOD_QUALITY_UNDER", "%s doesn't like this anymore."), petName), r, g, b
	elseif currentQuality == 0 then
		local r, g, b = MTH_TT_GetQuestColor("trivial", 0.5, 0.5, 0.5)
		return string.format(MTH_TT_Loc("TOOLTIPS_FOOD_QUALITY_MIGHT", "%s might eat this."), petName), r, g, b
	elseif currentQuality <= 8 then
		local r, g, b = MTH_TT_GetQuestColor("standard", 1.0, 1.0, 0.0)
		return string.format(MTH_TT_Loc("TOOLTIPS_FOOD_QUALITY_WILL", "%s will eat this."), petName), r, g, b
	elseif currentQuality <= 17 then
		local r, g, b = MTH_TT_GetQuestColor("difficult", 1.0, 0.5, 0.0)
		return string.format(MTH_TT_Loc("TOOLTIPS_FOOD_QUALITY_LIKE", "%s likes to eat this."), petName), r, g, b
	elseif currentQuality <= 35 then
		local r, g, b = MTH_TT_GetQuestColor("verydifficult", 1.0, 0.1, 0.1)
		return string.format(MTH_TT_Loc("TOOLTIPS_FOOD_QUALITY_LOVE", "%s loves to eat this."), petName), r, g, b
	end

	return nil
end

local function MTH_TT_AddFoodTooltipHint()
	if not (MTH_Tooltips and MTH_Tooltips.enabled) then
		return
	end
	if not MTH_TT_IsFoodItemTooltipsEnabled() then
		return
	end
	if not GameTooltip or not GameTooltip.GetItem or not GameTooltip.AddLine then
		return
	end
	if MTH_TT_HasExistingFoodTooltipLine() then
		return
	end

	local _, itemLink = GameTooltip:GetItem()
	if not itemLink then
		return
	end

	local text, r, g, b = MTH_TT_BuildFoodOpinionLine(itemLink)
	if text and text ~= "" then
		GameTooltip:AddLine(text, r or 1.0, g or 1.0, b or 1.0)
		GameTooltip:Show()
	end
end

local function MTH_TT_HasExistingNotLearnedLine()
	if not GameTooltip or not GameTooltip.NumLines then return false end
	for i = 1, GameTooltip:NumLines() do
		local fontString = getglobal("GameTooltipTextLeft" .. i)
		if fontString and fontString.GetText then
			local text = fontString:GetText()
			if text and string.find(text, "Not learned yet, keep going !", 1, true) then
				return true
			end
		end
	end
	return false
end

local function MTH_TT_GetKnownSpellMap()
	if type(MTH_GetKnownPetSpellMap) == "function" then
		return MTH_GetKnownPetSpellMap()
	end
	if not MTH_CharSavedVariables or not MTH_CharSavedVariables.petTraining then
		return nil
	end
	return MTH_CharSavedVariables.petTraining.spellMap
end

local function MTH_TT_ParseAbilityToken(token)
	local text = MTH_TT_Trim(token)
	if text == "" then
		return "", "", nil
	end

	local _, _, abilityName, rankText = string.find(text, "^(.-)%s+(%d+)$")
	if abilityName and abilityName ~= "" then
		abilityName = MTH_TT_Trim(abilityName)
		return abilityName, MTH_TT_Lower(abilityName), tonumber(rankText)
	end

	return text, MTH_TT_Lower(text), nil
end

local function MTH_TT_HunterKnowsAbility(abilityLower, rankNumber)
	if abilityLower == "" then return false end

	local spellMap = MTH_TT_GetKnownSpellMap()
	if type(spellMap) ~= "table" then
		return false
	end

	for _, row in pairs(spellMap) do
		if row and row.name and row.isKnown ~= false then
			if MTH_TT_Lower(row.name) == abilityLower then
				if rankNumber then
					if tonumber(row.rankNumber) == tonumber(rankNumber) then
						return true
					end
				else
					return true
				end
			end
		end
	end

	return false
end

local function MTH_TT_FindAbilityCanonicalName(abilityName)
	local name = MTH_TT_Trim(abilityName)
	if name == "" then
		return nil
	end
	if not (MTH_DS_PetSpells and type(MTH_DS_PetSpells.byAbility) == "table") then
		return nil
	end
	if MTH_DS_PetSpells.byAbility[name] then
		return name
	end
	local key = MTH_TT_Lower(name)
	for abilityKey in pairs(MTH_DS_PetSpells.byAbility) do
		if MTH_TT_Lower(abilityKey) == key then
			return abilityKey
		end
	end
	return nil
end

local function MTH_TT_AbilityHasPositiveRanks(canonicalAbilityName)
	if canonicalAbilityName == nil or canonicalAbilityName == "" then
		return false
	end
	if not (MTH_DS_PetSpells and type(MTH_DS_PetSpells.byAbility) == "table") then
		return false
	end

	local bucket = MTH_DS_PetSpells.byAbility[canonicalAbilityName]
	if not (bucket and type(bucket.spells) == "table") then
		return false
	end

	for i = 1, table.getn(bucket.spells) do
		local spell = bucket.spells[i]
		if spell then
			local rank = tonumber(spell.rankNumber)
			if not rank and spell.rank then
				local _, _, parsed = string.find(tostring(spell.rank), "(%d+)")
				rank = tonumber(parsed)
			end
			if rank and rank > 0 then
				return true
			end
		end
	end

	return false
end

local function MTH_TT_ParseRankFromText(value, allowTrailingNumber)
	local text = MTH_TT_Trim(value)
	if text == "" then
		return nil
	end
	local _, _, rankText = string.find(text, "[Rr]ank%s*(%d+)")
	if rankText then
		return tonumber(rankText)
	end
	if allowTrailingNumber == true then
		local _, _, trailing = string.find(text, "(%d+)$")
		if trailing then
			return tonumber(trailing)
		end
	end
	return nil
end

local function MTH_TT_CleanSpellName(value)
	local text = MTH_TT_Trim(value)
	if text == "" then
		return ""
	end
	text = string.gsub(text, "%s*%([Rr]ank%s*%d+%)", "")
	text = string.gsub(text, "%s+[Rr]ank%s*%d+$", "")
	text = string.gsub(text, "%s+%d+$", "")
	text = MTH_TT_Trim(text)
	return text
end

local function MTH_TT_GetTooltipSpellNameAndRank()
	local spellName = nil
	local rankNumber = nil

	if GameTooltip and type(GameTooltip.GetSpell) == "function" then
		local ok, a, b = pcall(function()
			return GameTooltip:GetSpell()
		end)
		if ok then
			if type(a) == "string" then
				spellName = a
				rankNumber = MTH_TT_ParseRankFromText(b, true)
			elseif type(b) == "string" then
				spellName = b
				rankNumber = MTH_TT_ParseRankFromText(a, true)
			end
		end
	end

	if not spellName or spellName == "" then
		local left1 = getglobal("GameTooltipTextLeft1")
		if left1 and left1.GetText then
			spellName = MTH_TT_Trim(left1:GetText())
		end
	end

	if not rankNumber then
		rankNumber = MTH_TT_ParseRankFromText(spellName, true)
	end

	if not rankNumber then
		local right1 = getglobal("GameTooltipTextRight1")
		if right1 and right1.GetText then
			rankNumber = MTH_TT_ParseRankFromText(right1:GetText(), false)
		end
	end

	if not rankNumber then
		local left2 = getglobal("GameTooltipTextLeft2")
		if left2 and left2.GetText then
			rankNumber = MTH_TT_ParseRankFromText(left2:GetText(), false)
		end
	end

	if not rankNumber then
		local right2 = getglobal("GameTooltipTextRight2")
		if right2 and right2.GetText then
			rankNumber = MTH_TT_ParseRankFromText(right2:GetText(), false)
		end
	end

	if (not rankNumber) and GameTooltip and GameTooltip.NumLines then
		for i = 2, GameTooltip:NumLines() do
			local left = getglobal("GameTooltipTextLeft" .. i)
			if left and left.GetText then
				local text = MTH_TT_Trim(left:GetText())
				local parsed = MTH_TT_ParseRankFromText(text, false)
				if parsed and parsed > 0 then
					rankNumber = parsed
					break
				end
			end
			local right = getglobal("GameTooltipTextRight" .. i)
			if right and right.GetText then
				local parsedRight = MTH_TT_ParseRankFromText(right:GetText(), false)
				if parsedRight and parsedRight > 0 then
					rankNumber = parsedRight
					break
				end
			end
		end
	end

	return MTH_TT_CleanSpellName(spellName), rankNumber
end

local function MTH_TT_GetCurrentPetRowForTooltip()
	local pets = nil
	if type(MTH_PETS_GetRootStore) == "function" then
		pets = MTH_PETS_GetRootStore()
	elseif type(MTH_CharSavedVariables) == "table" then
		pets = MTH_CharSavedVariables.MTH_Pets
	end
	if type(pets) ~= "table" then
		return nil
	end

	local currentId = pets.currentPetId
	if (currentId == nil or tostring(currentId) == "") and type(pets.currentPet) == "table" and pets.currentPet.exists == true then
		currentId = pets.currentPet.id
	end
	if currentId == nil or tostring(currentId) == "" then
		return nil
	end

	local activeById = type(pets.petStore) == "table" and pets.petStore.activeById or nil
	if type(activeById) ~= "table" then
		return nil
	end
	return activeById[currentId] or activeById[tostring(currentId)]
end

local function MTH_TT_CurrentPetKnowsAbility(abilityLower, rankNumber)
	if abilityLower == "" then
		return false
	end
	local row = MTH_TT_GetCurrentPetRowForTooltip()
	if type(row) ~= "table" then
		return false
	end

	local wantedRank = tonumber(rankNumber)

	local spellbook = row.petSpellbook
	if type(spellbook) == "table" and type(spellbook.spells) == "table" then
		for i = 1, table.getn(spellbook.spells) do
			local spell = spellbook.spells[i]
			if type(spell) == "table" then
				local spellLower = MTH_TT_Lower(MTH_TT_CleanSpellName(spell.name))
				if spellLower == abilityLower then
					if wantedRank then
						local spellRank = tonumber(spell.rank)
						if not spellRank then
							spellRank = MTH_TT_ParseRankFromText(spell.name, true)
						end
						if spellRank and tonumber(spellRank) == wantedRank then
							return true
						end
					else
						return true
					end
				end
			end
		end
	end

	if type(row.abilities) == "table" then
		for _, ability in pairs(row.abilities) do
			if type(ability) == "table" then
				local abilityLowerName = MTH_TT_Lower(MTH_TT_CleanSpellName(ability.name))
				if abilityLowerName == abilityLower then
					if wantedRank then
						local abilityRank = tonumber(ability.rank)
						if abilityRank and abilityRank == wantedRank then
							return true
						end
					else
						return true
					end
				end
			end
		end
	end

	return false
end

local function MTH_TT_IsPetActionTooltipOwner()
	if not GameTooltip or type(GameTooltip.GetOwner) ~= "function" then
		return false
	end
	local owner = GameTooltip:GetOwner()
	if not owner then
		return false
	end
	local ownerName = owner.GetName and owner:GetName() or ""
	ownerName = tostring(ownerName or "")
	if ownerName ~= "" and (
		string.find(ownerName, "PetActionButton", 1, true)
		or string.find(ownerName, "PetActionBar", 1, true)
		or string.find(ownerName, "BT4PetButton", 1, true)
	) then
		return true
	end

	return false
end

local function MTH_TT_IsSpellOnPetActionBar(spellName)
	local wanted = MTH_TT_Lower(MTH_TT_CleanSpellName(spellName))
	if wanted == "" then
		return false
	end
	if type(GetPetActionInfo) ~= "function" then
		return false
	end
	for slot = 1, 12 do
		local name = GetPetActionInfo(slot)
		if type(name) == "string" and name ~= "" then
			local normalized = MTH_TT_Lower(MTH_TT_CleanSpellName(name))
			if normalized == wanted then
				return true
			end
		end
	end
	return false
end

local function MTH_TT_GetTooltipOwnerName()
	if not GameTooltip or type(GameTooltip.GetOwner) ~= "function" then
		return "<no-owner-api>"
	end
	local owner = GameTooltip:GetOwner()
	if not owner then
		return "<nil-owner>"
	end
	if owner.GetName then
		local name = tostring(owner:GetName() or "")
		if name ~= "" then
			return name
		end
	end
	return "<anon-owner>"
end

local function MTH_TT_AddPetActionNotLearnedHint()
	if not (MTH_Tooltips and MTH_Tooltips.enabled) then
		return
	end
	if not GameTooltip or not GameTooltip.AddLine then
		return
	end
	if MTH_TT_HasExistingNotLearnedLine() then
		return
	end

	local spellName, rankNumber = MTH_TT_GetTooltipSpellNameAndRank()
	if not spellName or spellName == "" then
		return
	end

	local ownerName = MTH_TT_GetTooltipOwnerName()
	local ownerMatch = MTH_TT_IsPetActionTooltipOwner()
	local barMatch = MTH_TT_IsSpellOnPetActionBar(spellName)
	if not ownerMatch and not barMatch then
		return
	end

	local canonical = MTH_TT_FindAbilityCanonicalName(spellName)
	if not canonical then
		return
	end

	if rankNumber and rankNumber > 0 and not MTH_TT_AbilityHasPositiveRanks(canonical) then
		rankNumber = nil
	end

	local canonicalLower = MTH_TT_Lower(canonical)
	local known = MTH_TT_HunterKnowsAbility(canonicalLower, rankNumber)
	if not known then
		known = MTH_TT_CurrentPetKnowsAbility(canonicalLower, rankNumber)
	end
	if known then
		return
	end

	GameTooltip:AddLine("Not learned yet, keep going ! ", 1.0, 0.25, 0.25)
	GameTooltip:Show()
end

local function MTH_TT_ParseAbilities(abilitiesText)
	local text = MTH_TT_Trim(abilitiesText)
	local parsed = {}
	if text == "" or text == "None" then
		return parsed
	end

	local startPos = 1
	local len = string.len(text)
	while startPos <= len do
		local commaPos = string.find(text, ",", startPos, true)
		local token
		if commaPos then
			token = string.sub(text, startPos, commaPos - 1)
			startPos = commaPos + 1
		else
			token = string.sub(text, startPos)
			startPos = len + 1
		end

		token = MTH_TT_Trim(token)
		if token ~= "" then
			local _, abilityLower, rankNumber = MTH_TT_ParseAbilityToken(token)
			local known = MTH_TT_HunterKnowsAbility(abilityLower, rankNumber)
			table.insert(parsed, { text = token, known = known })
		end
	end

	return parsed
end

local function MTH_TT_AddTooltip(unit)
	local state = MTH_Tooltips.debugState
	state.injectAttempts = (state.injectAttempts or 0) + 1

	if not UnitExists(unit) then
		state.skipNoUnit = (state.skipNoUnit or 0) + 1
		MTH_TT_StateSet("skip-no-unit")
		return
	end
	if UnitPlayerControlled(unit) then
		state.skipPlayerControlled = (state.skipPlayerControlled or 0) + 1
		MTH_TT_StateSet("skip-player-controlled")
		return
	end
	if not GameTooltip or not GameTooltip.AddLine then
		state.skipTooltipApi = (state.skipTooltipApi or 0) + 1
		MTH_TT_StateSet("skip-tooltip-api")
		MTH_TT_Log("skip: GameTooltip API unavailable")
		return
	end

	local name = UnitName(unit)
	if not name or name == "" then
		state.skipNoName = (state.skipNoName or 0) + 1
		MTH_TT_StateSet("skip-no-name")
		MTH_TT_Log("skip: mouseover has no unit name")
		return
	end

	local normalized = MTH_TT_NormalizeName(name)
	MTH_TT_StateSet("lookup", name, normalized)

	local beastTooltipsEnabled = MTH_TT_IsBeastTooltipsEnabled()
	local ammoVendorTooltipsEnabled = MTH_TT_IsAmmoVendorTooltipsEnabled()
	local vendorInfo = ammoVendorTooltipsEnabled and MTH_TT_FindVendorInfo(name) or nil
	local row = beastTooltipsEnabled and MTH_TT_FindBeastRow(name) or nil
	if not row and not vendorInfo then
		state.lookupMiss = (state.lookupMiss or 0) + 1
		MTH_TT_StateSet("lookup-miss", name, normalized)
		MTH_TT_Log("lookup miss: unit='" .. tostring(name) .. "' normalized='" .. tostring(normalized) .. "'")
		return
	end

	local addedAnything = nil

	if vendorInfo and (vendorInfo.arrows or vendorInfo.bullets) and not MTH_TT_HasExistingVendorTooltipLine() then
		if vendorInfo.arrows and vendorInfo.bullets then
			GameTooltip:AddLine("Sells Arrows and Bullets", 0.45, 0.90, 1.00)
		elseif vendorInfo.arrows then
			GameTooltip:AddLine("Sells Arrows", 0.45, 0.90, 1.00)
		elseif vendorInfo.bullets then
			GameTooltip:AddLine("Sells Bullets", 0.45, 0.90, 1.00)
		end
		addedAnything = 1
		MTH_TT_Log("vendor tooltip added: unit='" .. tostring(name) .. "'")
	end

	if row then
		local abilities = MTH_TT_ParseAbilities(row.abilities)
		if table.getn(abilities) == 0 then
			MTH_TT_StateSet("skip-no-abilities", name, normalized)
			MTH_TT_Log("skip: beast has no abilities ('" .. tostring(name) .. "')")
		elseif MTH_TT_HasExistingTooltipLine() then
			state.skipExistingLine = (state.skipExistingLine or 0) + 1
			MTH_TT_StateSet("skip-existing-line", name, normalized)
			MTH_TT_Log("skip: tooltip line already present for '" .. tostring(name) .. "'")
		else
			GameTooltip:AddLine("Pet Abilities:", 1.0, 0.95, 0.45)
			for i = 1, table.getn(abilities) do
				local entry = abilities[i]
				if entry and entry.known then
					GameTooltip:AddLine("  " .. tostring(entry.text or ""), 0.2, 1.0, 0.2)
				else
					GameTooltip:AddLine("  " .. tostring(entry and entry.text or ""), 1.0, 0.25, 0.25)
				end
			end
			addedAnything = 1
			MTH_TT_Log("beast tooltip added: unit='" .. tostring(name) .. "' entries='" .. tostring(table.getn(abilities)) .. "'")
		end
	end

	if addedAnything then
		GameTooltip:Show()
		state.added = (state.added or 0) + 1
		MTH_TT_StateSet("added", name, normalized)
	end
end

local function MTH_TT_EnsureInjectFrame()
	if MTH_Tooltips.injectFrame then
		return MTH_Tooltips.injectFrame
	end
	local frame = CreateFrame("Frame", "MTH_TooltipsInjectFrame")
	frame.pending = false
	frame.onUpdate = function(self)
		self = self or this
		if not self then
			return
		end
		if not self.pending then
			self:SetScript("OnUpdate", nil)
			return
		end
		self.pending = false
		self:SetScript("OnUpdate", nil)
		if MTH_Tooltips and MTH_Tooltips.enabled then
			MTH_TT_AddTooltip("mouseover")
		end
	end
	MTH_Tooltips.injectFrame = frame
	return frame
end

local function MTH_TT_RequestInject()
	local frame = MTH_TT_EnsureInjectFrame()
	if frame then
		frame.pending = true
		if not frame:GetScript("OnUpdate") then
			frame:SetScript("OnUpdate", frame.onUpdate)
		end
	end
end

local function MTH_TT_EnsurePollFrame()
	if MTH_Tooltips.pollFrame then
		return MTH_Tooltips.pollFrame
	end

	local frame = CreateFrame("Frame", "MTH_TooltipsPollFrame")
	frame:SetScript("OnUpdate", function(_, elapsed)
		if not (MTH_Tooltips and MTH_Tooltips.enabled) then
			return
		end

		elapsed = elapsed or arg1
		MTH_Tooltips.hintElapsed = (MTH_Tooltips.hintElapsed or 0) + (elapsed or 0)
		if MTH_Tooltips.hintElapsed >= 0.25 then
			MTH_Tooltips.hintElapsed = 0
			if GameTooltip and GameTooltip.IsShown and GameTooltip:IsShown() then
				MTH_TT_AddOwnPetTooltipHint()
				if not MTH_TT_HasExistingNotLearnedLine() then
					MTH_TT_AddPetActionNotLearnedHint()
				end
			end
		end

		MTH_Tooltips.pollElapsed = (MTH_Tooltips.pollElapsed or 0) + (elapsed or 0)
		if MTH_Tooltips.pollElapsed < 0.15 then
			return
		end
		MTH_Tooltips.pollElapsed = 0

		local state = MTH_Tooltips.debugState
		state.pollTicks = (state.pollTicks or 0) + 1

		if not UnitExists("mouseover") then
			MTH_Tooltips.lastMouseoverKey = ""
			return
		end

		local name = UnitName("mouseover")
		if not name or name == "" then
			return
		end
		local lvl = UnitLevel and UnitLevel("mouseover") or 0
		local key = tostring(name) .. "#" .. tostring(lvl)

		if key ~= MTH_Tooltips.lastMouseoverKey then
			MTH_Tooltips.lastMouseoverKey = key
			state.pollTriggers = (state.pollTriggers or 0) + 1
			MTH_TT_RequestInject()
			return
		end

		if not MTH_TT_HasExistingTooltipLine() then
			MTH_TT_RequestInject()
		end
	end)

	MTH_Tooltips.pollFrame = frame
	return frame
end

local function MTH_TT_SetRuntimeActive(active)
	local injectFrame = MTH_Tooltips.injectFrame
	if injectFrame then
		if not active then
			injectFrame.pending = false
			injectFrame:SetScript("OnUpdate", nil)
		end
	end

	local pollFrame = MTH_Tooltips.pollFrame
	if pollFrame then
		if active then
			pollFrame:SetScript("OnUpdate", pollFrame:GetScript("OnUpdate") or function(_, elapsed)
				if not (MTH_Tooltips and MTH_Tooltips.enabled) then
					return
				end

				elapsed = elapsed or arg1
				MTH_Tooltips.hintElapsed = (MTH_Tooltips.hintElapsed or 0) + (elapsed or 0)
				if MTH_Tooltips.hintElapsed >= 0.25 then
					MTH_Tooltips.hintElapsed = 0
					if GameTooltip and GameTooltip.IsShown and GameTooltip:IsShown() then
						MTH_TT_AddOwnPetTooltipHint()
						if not MTH_TT_HasExistingNotLearnedLine() then
							MTH_TT_AddPetActionNotLearnedHint()
						end
					end
				end

				MTH_Tooltips.pollElapsed = (MTH_Tooltips.pollElapsed or 0) + (elapsed or 0)
				if MTH_Tooltips.pollElapsed < 0.15 then
					return
				end
				MTH_Tooltips.pollElapsed = 0

				local state = MTH_Tooltips.debugState
				state.pollTicks = (state.pollTicks or 0) + 1

				if not UnitExists("mouseover") then
					MTH_Tooltips.lastMouseoverKey = ""
					return
				end

				local name = UnitName("mouseover")
				if not name or name == "" then
					return
				end
				local lvl = UnitLevel and UnitLevel("mouseover") or 0
				local key = tostring(name) .. "#" .. tostring(lvl)

				if key ~= MTH_Tooltips.lastMouseoverKey then
					MTH_Tooltips.lastMouseoverKey = key
					state.pollTriggers = (state.pollTriggers or 0) + 1
					MTH_TT_RequestInject()
					return
				end

				if not MTH_TT_HasExistingTooltipLine() then
					MTH_TT_RequestInject()
				end
			end)
		else
			MTH_Tooltips.pollElapsed = 0
			MTH_Tooltips.hintElapsed = 0
			pollFrame:SetScript("OnUpdate", nil)
		end
	end
end

local function MTH_TT_InstallTooltipHook()
	if MTH_Tooltips.hookInstalled then
		return
	end
	if not GameTooltip then
		MTH_TT_Log("hook skipped: GameTooltip missing")
		return
	end
	if type(GameTooltip.HookScript) == "function" then
		local ok, err = pcall(function()
			GameTooltip:HookScript("OnTooltipSetUnit", function()
				if not (MTH_Tooltips and MTH_Tooltips.enabled) then
					return
				end
				MTH_TT_AddOwnPetTooltipHint()
				MTH_TT_RequestInject()
			end)
			GameTooltip:HookScript("OnTooltipSetItem", function()
				if not (MTH_Tooltips and MTH_Tooltips.enabled) then
					return
				end
				MTH_TT_AddFoodTooltipHint()
			end)
			GameTooltip:HookScript("OnTooltipSetSpell", function()
				if not (MTH_Tooltips and MTH_Tooltips.enabled) then
					return
				end
				MTH_TT_AddPetActionNotLearnedHint()
			end)
		end)
		if ok then
			MTH_Tooltips.hookInstalled = true
			MTH_TT_Log("hook installed: GameTooltip OnTooltipSetUnit+OnTooltipSetItem+OnTooltipSetSpell")
		else
			MTH_TT_Log("hook skipped: OnTooltipSetUnit unavailable (" .. tostring(err or "unknown") .. ")")
		end
	else
		MTH_TT_Log("hook skipped: HookScript API unavailable")
	end

end

function MTH_Tooltips:init()
	self.beastIndex = MTH_TT_BuildIndex()
	self.initialized = true
	MTH_TT_InstallTooltipHook()
	MTH_TT_EnsureInjectFrame()
	MTH_TT_EnsurePollFrame()
	MTH_TT_SetRuntimeActive(self.enabled)
	MTH_TT_Log("module init complete")
end

function MTH_Tooltips:onEvent(evt, arg1)
	if evt ~= "UPDATE_MOUSEOVER_UNIT" and evt ~= "UNIT_NAME_UPDATE" then return end
	if not self.enabled then return end
	if evt == "UNIT_NAME_UPDATE" and arg1 ~= "mouseover" then return end
	self.debugState.events = (self.debugState.events or 0) + 1
	MTH_TT_Log("event: UPDATE_MOUSEOVER_UNIT")
	if not self.initialized then
		self:init()
	end
	MTH_TT_RequestInject()
end

function MTH_Tooltips:setEnabled(enabled)
	self.enabled = enabled and true or false
	MTH_TT_Log("setEnabled: " .. tostring(self.enabled))
	if self.enabled and not self.initialized then
		self:init()
	elseif self.enabled then
		MTH_TT_EnsurePollFrame()
		MTH_TT_EnsureInjectFrame()
		MTH_TT_SetRuntimeActive(true)
	else
		MTH_TT_SetRuntimeActive(false)
	end
end

function MTH_Tooltips:SetBeastTooltipsEnabled(enabled)
	local store = MTH_TT_GetOptionsStore()
	if type(store) == "table" then
		store.beastTooltips = enabled and true or false
	end
end

function MTH_Tooltips:SetAmmoVendorTooltipsEnabled(enabled)
	local store = MTH_TT_GetOptionsStore()
	if type(store) == "table" then
		store.ammoVendorTooltips = enabled and true or false
	end
	self.vendorIndex = nil
end

function MTH_Tooltips:SetFoodItemTooltipsEnabled(enabled)
	local store = MTH_TT_GetOptionsStore()
	if type(store) == "table" then
		store.foodItemTooltips = enabled and true or false
	end
end

function MTH_Tooltips:SetOwnPetTooltipsEnabled(enabled)
	local store = MTH_TT_GetOptionsStore()
	if type(store) == "table" then
		store.ownPetTooltips = enabled and true or false
	end
end

function MTH_Tooltips:GetBeastTooltipsEnabled()
	return MTH_TT_IsBeastTooltipsEnabled()
end

function MTH_Tooltips:GetAmmoVendorTooltipsEnabled()
	return MTH_TT_IsAmmoVendorTooltipsEnabled()
end

function MTH_Tooltips:GetFoodItemTooltipsEnabled()
	return MTH_TT_IsFoodItemTooltipsEnabled()
end

function MTH_Tooltips:GetOwnPetTooltipsEnabled()
	return MTH_TT_IsOwnPetTooltipsEnabled()
end

function MTH_Tooltips:cleanup()
	self.enabled = false
	MTH_TT_SetRuntimeActive(false)
end

function MTH_Tooltips:GetDebugSnapshot()
	return self.debugState
end

MTH:RegisterModule("tooltips", MTH_Tooltips)
