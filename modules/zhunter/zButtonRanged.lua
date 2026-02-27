local function zButtonRanged_GetRoot()
	return MTH_ZH_GetSavedRoot()
end

local root = zButtonRanged_GetRoot()
if not root["zButtonRanged"] then
	root["zButtonRanged"] = {}
	root["zButtonRanged"]["spells"] = {}
	root["zButtonRanged"]["visible"] = {}
	root["zButtonRanged"]["rows"] = 1
	root["zButtonRanged"]["horizontal"] = nil
	root["zButtonRanged"]["vertical"] = nil
	root["zButtonRanged"]["firstbutton"] = "RIGHT"
	root["zButtonRanged"]["enabled"] = false
	root["zButtonRanged"]["tooltip"] = 1
	root["zButtonRanged"]["parent"] = {}
	root["zButtonRanged"]["parent"]["size"] = 36
	root["zButtonRanged"]["parent"]["hide"] = nil
	root["zButtonRanged"]["parent"]["circle"] = 1
	root["zButtonRanged"]["children"] = {}
	root["zButtonRanged"]["children"]["size"] = 36
	root["zButtonRanged"]["children"]["hideonclick"] = 1
end

ZHunterMod_Ranged_Weapons = ZHunterMod_Ranged_Weapons or {}

local ZHUNTER_RANGED_MAX_COUNT = 80
local zButtonRanged_Cache = {}
local zButtonRanged_TooltipWarmed = false

local function zButtonRanged_GetKnownItemSpeed(itemId)
	local idNum = tonumber(itemId)
	if not idNum then
		return nil
	end
	local items = _G["MTH_DS_Items"] or MTH_DS_AmmoItems
	local item = items and items[idNum]
	local speedVal = item and tonumber(item.speed)
	if speedVal and speedVal > 0 then
		return speedVal
	end
	return nil
end

local function zButtonRanged_GetSaved()
	local currentRoot = zButtonRanged_GetRoot()
	if not currentRoot["zButtonRanged"] then
		currentRoot["zButtonRanged"] = {}
	end
	return currentRoot["zButtonRanged"]
end

local function zButtonRanged_GetColorGradient(perc)
	perc = perc > 1 and 1 or perc
	perc = perc < 0 and 0 or perc
	local r1, g1, b1, r2, g2, b2
	if perc <= 0.5 then
		perc = perc * 2
		r1, g1, b1 = 1, 0, 0
		r2, g2, b2 = 1, 1, 0
	else
		perc = perc * 2 - 1
		r1, g1, b1 = 1, 1, 0
		r2, g2, b2 = 0, 1, 0
	end
	local r = r1 + (r2 - r1) * perc
	local g = g1 + (g2 - g1) * perc
	local b = b1 + (b2 - b1) * perc
	return r, g, b
end

local function zButtonRanged_EnsureDurabilityText(button)
	if button and not button.rangedDurabilityText then
		button.rangedDurabilityText = button:CreateFontString(nil, "OVERLAY")
		button.rangedDurabilityText:SetPoint("BOTTOMRIGHT", button)
		button.rangedDurabilityText:SetFont("Fonts\\ARIALN.ttf", 13, "OUTLINE")
	end
	return button and button.rangedDurabilityText
end

local function zButtonRanged_EnsureSpeedText(button)
	if button and not button.rangedSpeedText then
		button.rangedSpeedText = button:CreateFontString(nil, "OVERLAY")
		button.rangedSpeedText:SetPoint("TOPLEFT", button, "TOPLEFT", 1, -1)
		button.rangedSpeedText:SetFont("Fonts\\ARIALN.ttf", 9, "OUTLINE")
	end
	return button and button.rangedSpeedText
end

local function zButtonRanged_IsRangedItem(subtype, equipLoc)
	local subtypeText = tostring(subtype or "")
	if subtypeText == tostring(MTH_WEAPON_BOWS or "Bows") then return true end
	if subtypeText == tostring(MTH_WEAPON_GUNS or "Guns") then return true end
	if subtypeText == tostring(MTH_WEAPON_CROSSBOWS or "Crossbows") then return true end
	if subtypeText == "Thrown" then return true end
	if equipLoc == "INVTYPE_RANGED" or equipLoc == "INVTYPE_RANGEDRIGHT" or equipLoc == "INVTYPE_THROWN" then
		return true
	end
	return false
end

local function zButtonRanged_RebuildCache()
	zButtonRanged_Cache = {}
	for bag = 0, 4 do
		for slot = 1, GetContainerNumSlots(bag) do
			local link = GetContainerItemLink(bag, slot)
			if link then
				local _, _, id = string.find(link, "Hitem:((%d+).-)")
				if id then
					local itemNameResolved, itemLink, itemQuality, itemReqLevel, _, itemSubtype, _, itemEquipLoc, itemIcon = GetItemInfo(id)
					local _, _, linkName = string.find(link, "%[(.+)%]")
					local itemName = itemNameResolved or linkName
					if itemName and zButtonRanged_IsRangedItem(itemSubtype, itemEquipLoc) then
						local _, itemCount = GetContainerItemInfo(bag, slot)
						local knownSpeed = zButtonRanged_GetKnownItemSpeed(id)
						local rangedInfo = zButtonRanged_Cache[itemName]
						if not rangedInfo then
							rangedInfo = {
								name = itemName,
								quality = itemQuality,
								reqLevel = itemReqLevel,
								subtype = itemSubtype,
								equipLoc = itemEquipLoc,
								bag = bag,
								slot = slot,
								id = id,
								link = link,
								icon = itemIcon,
								speed = knownSpeed,
								count = 0,
							}
							zButtonRanged_Cache[itemName] = rangedInfo
						end
						if rangedInfo.speed == nil and knownSpeed ~= nil then
							rangedInfo.speed = knownSpeed
						end
						rangedInfo.count = (rangedInfo.count or 0) + (itemCount or 0)
					end
				end
			end
		end
	end
end

local function zButtonRanged_GetOrderedWeapons()
	local names = {}
	for weaponName, weaponInfo in pairs(zButtonRanged_Cache) do
		if weaponName and weaponInfo and (tonumber(weaponInfo.count) or 0) > 0 then
			table.insert(names, weaponName)
		end
	end
	table.sort(names, function(a, b)
		local infoA = zButtonRanged_Cache[a] or {}
		local infoB = zButtonRanged_Cache[b] or {}
		local lvlA = tonumber(infoA.reqLevel) or 0
		local lvlB = tonumber(infoB.reqLevel) or 0
		if lvlA ~= lvlB then
			return lvlA < lvlB
		end
		local qualityA = tonumber(infoA.quality) or 0
		local qualityB = tonumber(infoB.quality) or 0
		if qualityA ~= qualityB then
			return qualityA < qualityB
		end
		return tostring(a) < tostring(b)
	end)
	return names
end

local function zButtonRanged_EnsureSpellOrder(weapons)
	local saved = zButtonRanged_GetSaved()
	if not saved["spells"] then
		saved["spells"] = {}
	end
	if not saved["visible"] then
		saved["visible"] = {}
	end

	local maxWeapons = table.getn(weapons or {})
	local needsReset = false
	for i = 1, maxWeapons do
		local index = saved["spells"][i]
		if not tonumber(index) or index < 1 or index > maxWeapons then
			needsReset = true
			break
		end
	end

	if needsReset or table.getn(saved["spells"]) ~= maxWeapons then
		saved["spells"] = {}
		for i = 1, maxWeapons do
			saved["spells"][i] = i
		end
	end

	for i = 1, maxWeapons do
		if saved["visible"][i] == nil then
			saved["visible"][i] = 1
		end
	end
end

local function zButtonRanged_AssignButtonFromInfo(button, weaponInfo)
	if not (button and weaponInfo) then
		return false
	end
	button.id = weaponInfo.id
	button.icon = weaponInfo.icon
	button.isspell = nil
	button.ammoname = weaponInfo.name
	button.ammobag = weaponInfo.bag
	button.ammoslot = weaponInfo.slot
	button.ammoid = weaponInfo.id
	button.ammolink = weaponInfo.link
	button.ammocount = weaponInfo.count
	button.rangedType = weaponInfo.subtype
	button.rangedReqLevel = weaponInfo.reqLevel
	button.rangedQuality = weaponInfo.quality
	button.rangedSpeed = weaponInfo.speed
	return true
end

local function zButtonRanged_ApplyRuntimeSettings()
	if not zButtonRanged then
		return
	end
	local saved = zButtonRanged_GetSaved()
	zButtonRanged.tooltip = saved["tooltip"] and true or false
	zButtonRanged.hideonclick = saved["children"] and saved["children"]["hideonclick"] and true or false
end

local function zButtonRanged_UpdateDurabilityText(button)
	local text = zButtonRanged_EnsureDurabilityText(button)
	if not text then
		return
	end

	if button ~= zButtonRanged then
		text:SetText("")
		return
	end

	if type(GetInventoryItemDurability) ~= "function" then
		text:SetText("")
		return
	end

	local cur, max = nil, nil
	local okPlayer, cPlayer, mPlayer = pcall(GetInventoryItemDurability, "player", 18)
	if okPlayer then
		cur, max = cPlayer, mPlayer
	else
		local okSlot, cSlot, mSlot = pcall(GetInventoryItemDurability, 18)
		if okSlot then
			cur, max = cSlot, mSlot
		end
	end

	cur = tonumber(cur)
	max = tonumber(max)
	if not cur or not max or max <= 0 then
		text:SetText("")
		return
	end

	local perc = math.floor(((cur / max) * 100) + 0.5)
	if perc >= 100 then
		text:SetText("")
		return
	end

	local r, g, b = zButtonRanged_GetColorGradient(cur / max)
	text:SetTextColor(r, g, b)
	text:SetText(tostring(perc) .. "%")
end

local function zButtonRanged_UpdateSpeedText(button)
	local text = zButtonRanged_EnsureSpeedText(button)
	if not text then
		return
	end
	local speedVal = tonumber(button and button.rangedSpeed)
	if not speedVal then
		text:SetText("")
		return
	end
	text:SetText(string.format("%.2f", speedVal))
end

local function zButtonRanged_UpdateParentFromEquipped()
	if not zButtonRanged then
		return false
	end

	local equippedLink = GetInventoryItemLink("player", 18)
	if not equippedLink then
		return false
	end
	local _, _, linkName = string.find(equippedLink, "%[(.+)%]")

	local _, _, itemId = string.find(equippedLink, "item:(%d+)")
	if not itemId then
		local _, _, altId = string.find(equippedLink, "Hitem:((%d+).-)")
		itemId = altId
	end

	local itemName, _, itemQuality, itemReqLevel, _, itemSubtype, _, itemEquipLoc, itemIcon = GetItemInfo(itemId)
	itemName = itemName or linkName
	if not itemName then
		return false
	end
	if (itemSubtype or itemEquipLoc) and not zButtonRanged_IsRangedItem(itemSubtype, itemEquipLoc) then
		return false
	end

	local cacheInfo = zButtonRanged_Cache[itemName]
	local info = {
		name = itemName,
		quality = itemQuality,
		reqLevel = itemReqLevel,
		subtype = itemSubtype,
		equipLoc = itemEquipLoc,
		bag = cacheInfo and cacheInfo.bag or nil,
		slot = cacheInfo and cacheInfo.slot or nil,
		id = itemId,
		link = equippedLink,
		icon = itemIcon or GetInventoryItemTexture("player", 18),
		speed = (cacheInfo and cacheInfo.speed) or zButtonRanged_GetKnownItemSpeed(itemId),
		count = cacheInfo and cacheInfo.count or 1,
	}

	if not info.icon then
		info.icon = GetInventoryItemTexture("player", 18)
	end

	zButtonRanged_AssignButtonFromInfo(zButtonRanged, info)
	zButtonRanged:Enable()
	zButtonRanged:Show()
	return true
end

local function zButtonRanged_SetButtons(parent, weaponNames)
	if not (parent and parent.count) then
		return 0
	end

	for i = 1, parent.count do
		local child = getglobal(parent.name .. i)
		if child then
			child:Hide()
			child.id = nil
			child.icon = nil
			child.isspell = nil
			child.ammoname = nil
			child.ammobag = nil
			child.ammoslot = nil
		end
	end

	local found = 0
	for i = 1, table.getn(weaponNames or {}) do
		if found >= parent.count then
			break
		end
		local weaponName = weaponNames[i]
		local weaponInfo = weaponName and zButtonRanged_Cache[weaponName] or nil
		if weaponInfo and weaponInfo.id then
			found = found + 1
			local child = getglobal(parent.name .. found)
			if child then
				zButtonRanged_AssignButtonFromInfo(child, weaponInfo)
				zButtonRanged_UpdateButton(child)
				child:Show()
			end
		end
	end

	local hasEquipped = zButtonRanged_UpdateParentFromEquipped()
	if not hasEquipped and found > 0 then
		local first = getglobal(parent.name .. 1)
		if first then
			zButtonRanged_AssignButtonFromInfo(parent, {
				name = first.ammoname,
				quality = first.rangedQuality,
				reqLevel = first.rangedReqLevel,
				subtype = first.rangedType,
				equipLoc = nil,
				bag = first.ammobag,
				slot = first.ammoslot,
				id = first.ammoid or first.id,
				link = first.ammolink,
				icon = first.icon,
				speed = first.rangedSpeed,
				count = first.ammocount,
			})
			zButtonRanged_UpdateButton(parent)
			parent:Enable()
			parent:Show()
		end
	end

	if found <= 0 and not hasEquipped then
		parent.id = nil
		parent.icon = nil
		parent.ammoname = nil
		parent:Hide()
	else
		parent:Show()
	end

	return found
end

function zButtonRanged_UpdateButton(button)
	if not button then
		button = this
	end
	if not (button and button.icontexture) then
		return
	end
	if not button.id then
		button.icontexture:Hide()
		zButtonRanged_UpdateSpeedText(button)
		zButtonRanged_UpdateDurabilityText(button)
		return
	end
	button.icontexture:SetTexture(button.icon)
	button.icontexture:Show()
	zButtonRanged_UpdateSpeedText(button)
	zButtonRanged_UpdateDurabilityText(button)
end

local function zButtonRanged_OnEnter(button)
	if not button then
		button = this
	end
	if not button then
		return
	end
	if not (zButtonRanged and zButtonRanged.tooltip) then
		return
	end
	GameTooltip:SetOwner(button, "ANCHOR_TOPLEFT")
	if button == zButtonRanged then
		if not GameTooltip:SetInventoryItem("player", 18) and button.ammobag and button.ammoslot then
			GameTooltip:SetBagItem(button.ammobag, button.ammoslot)
		end
	elseif button.ammobag and button.ammoslot then
		GameTooltip:SetBagItem(button.ammobag, button.ammoslot)
	elseif button.ammolink then
		GameTooltip:SetHyperlink(button.ammolink)
	end
	GameTooltip:Show()
end

local function zButtonRanged_PrewarmTooltipOnce()
	if zButtonRanged_TooltipWarmed then
		return
	end
	zButtonRanged_TooltipWarmed = true
	if not GameTooltip then
		return
	end
	GameTooltip:SetOwner(UIParent, "ANCHOR_NONE")
	GameTooltip:ClearLines()
	if zButtonRanged and zButtonRanged.ammolink then
		GameTooltip:SetHyperlink(zButtonRanged.ammolink)
	elseif zButtonRanged and zButtonRanged.ammobag and zButtonRanged.ammoslot then
		GameTooltip:SetBagItem(zButtonRanged.ammobag, zButtonRanged.ammoslot)
	else
		GameTooltip:SetInventoryItem("player", 18)
	end
	GameTooltip:Hide()
end

local function zButtonRanged_EquipFromButton(button)
	if not (button and button.ammobag and button.ammoslot) then
		return false
	end

	PickupContainerItem(button.ammobag, button.ammoslot)
	if CursorHasItem() then
		EquipCursorItem(18)
	end
	if CursorHasItem() then
		if ClearCursor then ClearCursor() end
		return false
	end

	zButtonRanged_UpdateParentFromEquipped()
	zButtonRanged_UpdateButton(zButtonRanged)
	return true
end

local function zButtonRanged_BeforeClick(button)
	if not button then
		return false
	end
	if button.isspell then
		return false
	end
	zButtonRanged_EquipFromButton(button)
	return true
end

local function zButtonRanged_RefreshButtonsFromState()
	if not zButtonRanged then
		return
	end

	local saved = zButtonRanged_GetSaved()
	zButtonRanged_RebuildCache()
	local weapons = zButtonRanged_GetOrderedWeapons()
	ZHunterMod_Ranged_Weapons = weapons
	zButtonRanged_EnsureSpellOrder(weapons)

	local info = {}
	local infoIndex = 1
	for i = 1, table.getn(weapons) do
		local weaponIndex = saved["spells"][i]
		if weaponIndex and saved["visible"][weaponIndex] ~= false then
			info[infoIndex] = weapons[weaponIndex]
			infoIndex = infoIndex + 1
		end
	end

	zButtonRanged.found = ZSpellButton_SetButtons(zButtonRanged, info)
	zButtonRanged_ApplyRuntimeSettings()
end

local function zButtonRanged_EnsureConfig()
	local saved = zButtonRanged_GetSaved()
	saved["count"] = nil
	if saved["enabled"] == nil then
		saved["enabled"] = false
	end
	if saved["tooltip"] == nil then
		saved["tooltip"] = 1
	end
	if not saved["children"] then
		saved["children"] = {}
	end
	if saved["children"]["hideonclick"] == nil then
		saved["children"]["hideonclick"] = 1
	end
	if not saved["spells"] then
		saved["spells"] = {}
	end
	if not saved["visible"] then
		saved["visible"] = {}
	end
	if not saved["parent"] then
		saved["parent"] = {}
	end
	if not saved["children"]["size"] then
		saved["children"]["size"] = 36
	end
	if not saved["parent"]["size"] then
		saved["parent"]["size"] = 36
	end
	if saved["parent"]["circle"] == nil then
		saved["parent"]["circle"] = 1
	end
	if not saved["rows"] or saved["rows"] < 1 then
		saved["rows"] = 1
	end
	if not saved["firstbutton"] then
		saved["firstbutton"] = "RIGHT"
	end
end

function zButtonRanged_OnLoad()
	this:RegisterEvent("VARIABLES_LOADED")
end

function zButtonRanged_OnEvent()
	if event == "VARIABLES_LOADED" then
		if not zButtonRanged then
			return
		end
		if UnitClass("player") ~= ZHUNTER_HUNTER then
			zButtonRanged:UnregisterAllEvents()
			zButtonRanged:Hide()
			return
		end
		zButtonRanged.customSetButtons = zButtonRanged_SetButtons
		zButtonRanged.customUpdateButton = zButtonRanged_UpdateButton
		zButtonRanged.beforeclick = zButtonRanged_BeforeClick
		zButtonRanged_CreateButtons()
		zButtonRangedAdjustment = CreateFrame("Frame", "zButtonRangedAdjustment")
		zButtonRangedAdjustment:RegisterEvent("UNIT_INVENTORY_CHANGED")
		zButtonRangedAdjustment:RegisterEvent("BAG_UPDATE")
		zButtonRangedAdjustment:RegisterEvent("PLAYER_ENTERING_WORLD")
		zButtonRangedAdjustment:SetScript("OnEvent", zButtonRangedAdjustment_OnEvent)
		zButtonRanged_SetupSizeAndPosition()
	end
end

function zButtonRanged_CreateButtons()
	zButtonRanged_EnsureConfig()
	if not zButtonRanged.children then
		ZSpellButton_CreateChildren(zButtonRanged, "zButtonRanged", ZHUNTER_RANGED_MAX_COUNT)
	else
		zButtonRanged.count = ZHUNTER_RANGED_MAX_COUNT
	end
	zButtonRanged:SetScript("OnEnter", function()
		zButtonRanged_OnEnter(this)
	end)
	for i = 1, zButtonRanged.count do
		local child = getglobal("zButtonRanged" .. i)
		if child then
			child:SetScript("OnEnter", function()
				zButtonRanged_OnEnter(this)
			end)
		end
	end
	zButtonRanged_RefreshButtonsFromState()
end

function zButtonRanged_SetupSizeAndPosition()
	local saved = zButtonRanged_GetSaved()
	if saved["enabled"] == false or saved["enabled"] == 0 then
		if zButtonRanged and zButtonRanged.Hide then
			zButtonRanged:Hide()
		end
		return
	end
	local displayCount = zButtonRanged.found or 0
	if displayCount < 0 then
		displayCount = 0
	end
	ZSpellButton_SetSize(zButtonRanged, saved["parent"]["size"])
	ZSpellButton_SetSize(zButtonRanged, saved["children"]["size"], 1)
	ZSpellButton_SetExpandDirection(zButtonRanged, saved["firstbutton"])
	ZSpellButton_ArrangeChildren(zButtonRanged, saved["rows"], displayCount, saved["horizontal"], saved["vertical"])
	zButtonRanged_UpdateButton(zButtonRanged)
end

function zButtonRanged_Reset()
	local currentRoot = zButtonRanged_GetRoot()
	currentRoot["zButtonRanged"] = {}
	local saved = zButtonRanged_GetSaved()
	saved["spells"] = {}
	saved["visible"] = {}
	saved["rows"] = 1
	saved["horizontal"] = nil
	saved["vertical"] = nil
	saved["firstbutton"] = "RIGHT"
	saved["enabled"] = false
	saved["tooltip"] = 1
	saved["parent"] = {}
	saved["parent"]["size"] = 36
	saved["parent"]["hide"] = nil
	saved["parent"]["circle"] = 1
	saved["children"] = {}
	saved["children"]["size"] = 36
	saved["children"]["hideonclick"] = 1
	zButtonRanged_EnsureConfig()
end

function zButtonRangedAdjustment_OnEvent()
	if not zButtonRanged then
		return
	end
	if event == "UNIT_INVENTORY_CHANGED" and arg1 and arg1 ~= "player" then
		return
	end
	zButtonRanged_RefreshButtonsFromState()
	zButtonRanged_SetupSizeAndPosition()
	if event == "PLAYER_ENTERING_WORLD" then
		zButtonRanged_PrewarmTooltipOnce()
	end
	if GameTooltip:IsOwned(zButtonRanged) then
		zButtonRanged_OnEnter(zButtonRanged)
	end
end

function zButtonRanged_KeyBinding(index)
	if MTH_ZH_IsModuleEnabled and not MTH_ZH_IsModuleEnabled() then
		return
	end

	local button
	if index then
		button = getglobal("zButtonRanged" .. index)
	else
		button = zButtonRanged
	end
	if button then
		zButtonRanged_EquipFromButton(button)
		if zButtonRanged.hideonclick then
			if type(ZSpellButton_SetChildrenExpanded) == "function" then
				ZSpellButton_SetChildrenExpanded(zButtonRanged, false)
			elseif zButtonRanged.children then
				zButtonRanged.children:Hide()
			end
		end
	end
end

SLASH_zButtonRanged1 = "/ZRanged"
SlashCmdList["zButtonRanged"] = function(msg)
	if MTH_ZH_HandleDisabledSlash and MTH_ZH_HandleDisabledSlash("Ranged button is disabled while module 'zhunter' is disabled.") then
		return
	end
	if msg == "reset" then
		zButtonRanged_Reset()
		zButtonRanged:ClearAllPoints()
		zButtonRanged:SetPoint("CENTER", UIParent, "CENTER", 120, 0)
		zButtonRanged_RefreshButtonsFromState()
		zButtonRanged_SetupSizeAndPosition()
	elseif msg == "options" then
		MTH_OpenOptions("Ranged")
	else
		MTH_ZH_Print("Possible Commands: \"reset\", \"options\"")
	end
end
