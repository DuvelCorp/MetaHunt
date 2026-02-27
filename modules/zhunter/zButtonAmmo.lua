local function zButtonAmmo_GetRoot()
	return MTH_ZH_GetSavedRoot()
end

local root = zButtonAmmo_GetRoot()
if not root["zButtonAmmo"] then
	root["zButtonAmmo"] = {}
	root["zButtonAmmo"]["spells"] = {1, 2, 3, 4, 5, 6, 7, 8, 9}
	root["zButtonAmmo"]["visible"] = {1, 1, 1, 1, 1, 1, 1, 1, 1}
	root["zButtonAmmo"]["rows"] = 1
	root["zButtonAmmo"]["horizontal"] = nil
	root["zButtonAmmo"]["vertical"] = nil
	root["zButtonAmmo"]["firstbutton"] = "RIGHT"
	root["zButtonAmmo"]["enabled"] = 1
	root["zButtonAmmo"]["tooltip"] = 1
	root["zButtonAmmo"]["parent"] = {}
	root["zButtonAmmo"]["parent"]["size"] = 36
	root["zButtonAmmo"]["parent"]["hide"] = nil
	root["zButtonAmmo"]["parent"]["circle"] = 1
	root["zButtonAmmo"]["children"] = {}
	root["zButtonAmmo"]["children"]["size"] = 36
	root["zButtonAmmo"]["children"]["hideonclick"] = 1
	root["zButtonAmmo"]["showammoname"] = 1
	root["zButtonAmmo"]["lastEquipped"] = nil
end

ZHunterMod_Ammo_Buttons = nil

local ZHUNTER_AMMO_MAX_COUNT = math.max(table.getn(MTH_AMMO_ARROWS or {}), table.getn(MTH_AMMO_BULLETS or {}))
local zButtonAmmo_Cache = {}
local zButtonAmmo_LastCacheSignature = nil

local function zButtonAmmo_GetSaved()
	local currentRoot = zButtonAmmo_GetRoot()
	if not currentRoot["zButtonAmmo"] then
		currentRoot["zButtonAmmo"] = {}
	end
	return currentRoot["zButtonAmmo"]
end

local zButtonAmmo_ShortArrowLabels = {
	[ARROWS_ROUGH] = "Rough",
	[ARROWS_SHARP] = "Sharp",
	[ARROWS_RAZOR] = "Razor",
	[ARROWS_JAGGED] = "Jagged",
	[ARROWS_ICETHREADED] = "Ice",
	[ARROWS_THORIUM] = "Thorium",
	[ARROWS_DOOMSHOT] = "Doom",
}

local zButtonAmmo_ShortBulletLabels = {
	[BULLETS_LIGHT] = "Light",
	[BULLETS_CRAFTLIGHT] = "C.Light",
	[BULLETS_FLASH] = "Flash",
	[BULLETS_HEAVY] = "Heavy",
	[BULLETS_PEBBLE] = "Smooth",
	[BULLETS_CRAFTHEAVY] = "Heavy",
	[BULLETS_SOLID] = "Solid",
	[BULLETS_CRAFTSOLID] = "C.Solid",
	[BULLETS_EXPLODING] = "Explo",
	[BULLETS_ROCKSHARD] = "Rock",
	[BULLETS_CANNONBALL] = "Cannon",
	[BULLETS_MITHRILSLUG] = "Hi-imp",
	[BULLETS_ACCURATE] = "Accur",
	[BULLETS_GYROSHOT] = "Gyro",
	[BULLETS_THORIUM] = "Thorium",
	[BULLETS_ICETHREADED] = "Ice",
}

local function zButtonAmmo_GetColorGradient(perc)
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

local function zButtonAmmo_EnsureCountText(button)
	if button and not button.ammoCountText then
		button.ammoCountText = button:CreateFontString(nil, "OVERLAY")
		button.ammoCountText:SetPoint("BOTTOMRIGHT", button)
		button.ammoCountText:SetFont("Fonts\\ARIALN.ttf", 14, "OUTLINE")
	end
	return button and button.ammoCountText
end

local function zButtonAmmo_EnsureShortLabelText(button)
	if button and not button.ammoShortLabelText then
		button.ammoShortLabelText = button:CreateFontString(nil, "OVERLAY")
		button.ammoShortLabelText:SetPoint("TOPLEFT", button, "TOPLEFT", 1, -1)
		button.ammoShortLabelText:SetFont("Fonts\\ARIALN.ttf", 9, "OUTLINE")
	end
	return button and button.ammoShortLabelText
end

local function zButtonAmmo_GetQualityColor(quality)
	local tableRef = MTH_ITEM_QUALITY_COLORS or ITEM_QUALITY_COLORS
	if tableRef then
		local q = tonumber(quality)
		if q and tableRef[q] then
			local c = tableRef[q]
			if c.r and c.g and c.b then
				return c.r, c.g, c.b
			end
		end
	end
	return 1, 1, 1
end

local function zButtonAmmo_ShouldShowShortLabel()
	local saved = zButtonAmmo_GetSaved()
	if saved["showammoname"] == nil then
		saved["showammoname"] = 1
	end
	return saved["showammoname"] and true or false
end

local function zButtonAmmo_GetAmmoSlotId()
	if GetInventorySlotInfo then
		local slotId = GetInventorySlotInfo("AmmoSlot")
		if slotId and slotId > 0 then
			return slotId
		end
	end
	return 0
end

local function zButtonAmmo_GetEquippedAmmoLink()
	local link = GetInventoryItemLink("player", 0)
	if link then
		return link
	end

	local ammoSlot = zButtonAmmo_GetAmmoSlotId()
	if ammoSlot and ammoSlot ~= 0 then
		link = GetInventoryItemLink("player", ammoSlot)
		if link then
			return link
		end
	end

	if ZHunterModTooltip then
		ZHunterModTooltip:SetOwner(UIParent, "ANCHOR_NONE")
		if ZHunterModTooltip:SetInventoryItem("player", ammoSlot) and ZHunterModTooltipTextLeft1 then
			local tooltipName = ZHunterModTooltipTextLeft1:GetText()
			if tooltipName and tooltipName ~= "" then
				return "[" .. tooltipName .. "]"
			end
		end
	end

	return nil
end

local function zButtonAmmo_RebuildCache()
	local knownAmmo = {}
	for i = 1, table.getn(MTH_AMMO_ARROWS or {}) do
		knownAmmo[(MTH_AMMO_ARROWS or {})[i]] = "Arrow"
	end
	for i = 1, table.getn(MTH_AMMO_BULLETS or {}) do
		knownAmmo[(MTH_AMMO_BULLETS or {})[i]] = "Bullet"
	end

	local equippedAmmo = nil
	local equippedLink = zButtonAmmo_GetEquippedAmmoLink()
	if equippedLink then
		local _, _, equippedName = string.find(equippedLink, "%[(.+)%]")
		if equippedName then
			equippedAmmo = equippedName
		end
		local _, _, equippedId = string.find(equippedLink, "Hitem:((%d+).-)")
		if equippedId and not equippedAmmo then
			equippedAmmo = GetItemInfo(equippedId)
		end
	end

	zButtonAmmo_Cache = {}
	for bag = 0, 4 do
		for slot = 1, GetContainerNumSlots(bag) do
			local link = GetContainerItemLink(bag, slot)
			if link then
				local _, _, id = string.find(link, "Hitem:((%d+).-)")
				if id then
					local _, _, linkName = string.find(link, "%[(.+)%]")
					local itemTexture, itemCount = GetContainerItemInfo(bag, slot)
					local itemName, itemBrol, itemQuality, itemReqlvl, _, itemSubtype, _, itemSlot, itemIcon = GetItemInfo(id)
					local ammoName = itemName or linkName
					local ammoType = itemSubtype
					local isAmmo = false
					if itemName and itemSlot == "INVTYPE_AMMO" then
						isAmmo = true
					elseif ammoName and knownAmmo[ammoName] then
						isAmmo = true
						if not ammoType then
							ammoType = knownAmmo[ammoName]
						end
					end

					if isAmmo and ammoName then
						local ammoInfo = zButtonAmmo_Cache[ammoName]
						if not ammoInfo then
							ammoInfo = {
								ammo = ammoName,
								brol = itemBrol,
								quality = itemQuality,
								lvl = itemReqlvl,
								type = ammoType,
								bag = bag,
								slot = slot,
								id = id,
								link = link,
								icon = itemIcon or itemTexture,
								count = 0,
								equip = nil,
							}
							zButtonAmmo_Cache[ammoName] = ammoInfo
						end
						ammoInfo.count = (ammoInfo.count or 0) + (itemCount or 0)
						if equippedAmmo and equippedAmmo == ammoName then
							ammoInfo.equip = 1
						end
					end
				end
			end
		end
	end
end

local function zButtonAmmo_AssignButtonFromAmmoInfo(button, ammoInfo)
	if not (button and ammoInfo) then
		return false
	end
	button.id = ammoInfo.id
	button.icon = ammoInfo.icon
	button.isspell = nil
	button.ammoname = ammoInfo.ammo
	button.ammobrol = ammoInfo.brol
	button.ammoqual = ammoInfo.quality
	button.ammolvl = ammoInfo.lvl
	button.ammotype = ammoInfo.type
	button.ammobag = ammoInfo.bag
	button.ammoslot = ammoInfo.slot
	button.ammoid = ammoInfo.id
	button.ammolink = ammoInfo.link
	button.ammocount = ammoInfo.count
	return true
end

local function zButtonAmmo_GetCacheSignature()
	local names = {}
	for ammoName, ammoInfo in pairs(zButtonAmmo_Cache or {}) do
		if ammoName and ammoInfo and (tonumber(ammoInfo.count) or 0) > 0 then
			table.insert(names, tostring(ammoName))
		end
	end
	table.sort(names)
	return table.concat(names, "|")
end

local function zButtonAmmo_GetEquippedAmmoInfo()
	local ammoLink = zButtonAmmo_GetEquippedAmmoLink()
	if not ammoLink then
		return nil
	end

	local _, _, ammoName = string.find(ammoLink, "%[(.+)%]")
	local _, _, ammoId = string.find(ammoLink, "Hitem:((%d+).-)")
	local itemName, itemBrol, itemQuality, itemReqlvl, _, itemSubtype, _, _, itemIcon
	if ammoId then
		itemName, itemBrol, itemQuality, itemReqlvl, _, itemSubtype, _, _, itemIcon = GetItemInfo(ammoId)
	end

	local ammoSlot = zButtonAmmo_GetAmmoSlotId()
	local slotForTexture = ammoSlot and ammoSlot ~= 0 and ammoSlot or 0
	local ammoIcon = itemIcon or GetInventoryItemTexture("player", slotForTexture)
	local ammoCount = nil
	if GetInventoryItemCount then
		ammoCount = GetInventoryItemCount("player", slotForTexture)
	end

	return {
		ammo = itemName or ammoName,
		brol = itemBrol,
		quality = itemQuality,
		lvl = itemReqlvl,
		type = itemSubtype,
		id = ammoId,
		link = ammoLink,
		icon = ammoIcon,
		count = ammoCount,
		bag = nil,
		slot = nil,
	}
end

function zButtonAmmo_UpdateButton(button)
	if not button then
		button = this
	end
	if not (button and button.id and button.icontexture) then
		return
	end
	if button.isspell then
		button.icontexture:SetTexture(button.icon or GetSpellTexture(button.id, "spell"))
		button.icontexture:Show()
		if button.ammoCountText then
			button.ammoCountText:SetText("")
		end
		if button.ammoShortLabelText then
			button.ammoShortLabelText:SetText("")
		end
		return
	end

	local ammoInfo = button.ammoname and zButtonAmmo_Cache[button.ammoname] or nil
	local countText = zButtonAmmo_EnsureCountText(button)
	local shortLabelText = zButtonAmmo_EnsureShortLabelText(button)
	local shortLabel = nil
	if button.ammoname then
		shortLabel = zButtonAmmo_ShortArrowLabels[button.ammoname] or zButtonAmmo_ShortBulletLabels[button.ammoname]
	end
	button.icontexture:SetTexture(button.icon)
	button.icontexture:Show()
	if shortLabelText then
		if shortLabel and zButtonAmmo_ShouldShowShortLabel() then
			local cr, cg, cb = zButtonAmmo_GetQualityColor(button.ammoqual)
			shortLabelText:SetTextColor(cr, cg, cb, 1)
			shortLabelText:SetText(shortLabel)
		else
			shortLabelText:SetText("")
		end
	end
	if ammoInfo then
		button.ammobag = ammoInfo.bag
		button.ammoslot = ammoInfo.slot
		button.ammocount = ammoInfo.count
		if countText then
			local r, g, b = zButtonAmmo_GetColorGradient((ammoInfo.count or 0) / 2000)
			countText:SetTextColor(r, g, b, 1)
			countText:SetText(ammoInfo.count)
		end
	else
		button.ammocount = 0
		if countText then
			countText:SetTextColor(1, 0, 0, 1)
			countText:SetText("Out!")
		end
	end
end

function zButtonAmmo_SetButtons(parent, ammoList)
	zButtonAmmo_RebuildCache()
	local previousByName = {}
	for i = 1, parent.count do
		local previous = getglobal(parent.name .. i)
		if previous and previous.ammoname and not previous.isspell then
			previousByName[previous.ammoname] = {
				ammo = previous.ammoname,
				brol = previous.ammobrol,
				quality = previous.ammoqual,
				lvl = previous.ammolvl,
				type = previous.ammotype,
				bag = nil,
				slot = nil,
				id = previous.ammoid or previous.id,
				link = previous.ammolink,
				icon = previous.icon,
				count = 0,
				equip = nil,
			}
		end
	end

	for i = 1, parent.count do
		local button = getglobal(parent.name .. i)
		button:Hide()
		button.id = nil
		button.icon = nil
		button.isspell = nil
		button.ammoname = nil
		button.ammoqual = nil
		button.ammobag = nil
		button.ammoslot = nil
		button.ammocount = nil
		if button.ammoShortLabelText then
			button.ammoShortLabelText:SetText("")
		end
	end

	local count = 1
	local parentSet = nil
	for i = 1, table.getn(ammoList) do
		if count > parent.count then
			break
		end
		local ammoName = ammoList[i]
		local ammoInfo = ammoName and zButtonAmmo_Cache[ammoName] or nil
		if not ammoInfo and ammoName then
			ammoInfo = previousByName[ammoName]
		end
		if ammoInfo then
			local button = getglobal(parent.name .. count)
			zButtonAmmo_AssignButtonFromAmmoInfo(button, ammoInfo)
			zButtonAmmo_UpdateButton(button)
			button:Show()

			if ammoInfo.equip then
				parentSet = 1
				parent.id = ammoInfo.id
				parent.icon = ammoInfo.icon
				parent.isspell = nil
				parent.ammoname = ammoInfo.ammo
				parent.ammobrol = ammoInfo.brol
				parent.ammoqual = ammoInfo.quality
				parent.ammolvl = ammoInfo.lvl
				parent.ammotype = ammoInfo.type
				parent.ammoid = ammoInfo.id
				parent.ammolink = ammoInfo.link
				zButtonAmmo_UpdateButton(parent)
				parent:Enable()
			end
			count = count + 1
		end
	end

	if not parentSet then
		for i = 1, table.getn(ammoList) do
			local ammoName = ammoList[i]
			local ammoInfo = ammoName and zButtonAmmo_Cache[ammoName] or nil
			if ammoInfo then
				parent.id = ammoInfo.id
				parent.icon = ammoInfo.icon
				parent.isspell = nil
				parent.ammoname = ammoInfo.ammo
				parent.ammobrol = ammoInfo.brol
				parent.ammoqual = ammoInfo.quality
				parent.ammolvl = ammoInfo.lvl
				parent.ammotype = ammoInfo.type
				parent.ammoid = ammoInfo.id
				parent.ammolink = ammoInfo.link
				zButtonAmmo_UpdateButton(parent)
				parent:Enable()
				break
			end
		end
	end

	if count - 1 == 0 then
		parent:Hide()
	else
		parent:Show()
	end
	zButtonAmmo_LastCacheSignature = zButtonAmmo_GetCacheSignature()
	return count - 1
end

local function zButtonAmmo_GetAmmoList()
	local bulletList = MTH_AMMO_BULLETS or {}
	local arrowList = MTH_AMMO_ARROWS or {}
	local link = GetInventoryItemLink("player", 18)
	if link then
		local _, _, id = string.find(link, "Hitem:((%d+).-)")
		local _, _, _, _, _, weaponType = GetItemInfo(id)
		if weaponType == MTH_WEAPON_GUNS then
			return bulletList
		elseif weaponType == MTH_WEAPON_BOWS or weaponType == MTH_WEAPON_CROSSBOWS then
			return arrowList
		end
	end
	local ammoLink = GetInventoryItemLink("player", 0)
	if ammoLink then
		local _, _, ammoId = string.find(ammoLink, "Hitem:((%d+).-)")
		if ammoId then
			local _, _, _, _, itemType, itemSubtype = GetItemInfo(ammoId)
			if itemType == "Projectile" then
				if itemSubtype == "Bullet" then
					return bulletList
				elseif itemSubtype == "Arrow" then
					return arrowList
				end
			end
		end
	end
	return arrowList
end

local function zButtonAmmo_EnsureSpellOrder(ammoList)
	local saved = zButtonAmmo_GetSaved()
	saved["count"] = nil
	if saved["rows"] == nil then
		saved["rows"] = 1
	end
	if saved["firstbutton"] == nil then
		saved["firstbutton"] = "RIGHT"
	end
	if saved["enabled"] == nil then
		saved["enabled"] = 1
	end
	if saved["tooltip"] == nil then
		saved["tooltip"] = 1
	end
	if saved["showammoname"] == nil then
		saved["showammoname"] = 1
	end
	if not saved["parent"] then
		saved["parent"] = {}
	end
	if saved["parent"]["size"] == nil then
		saved["parent"]["size"] = 36
	end
	if saved["parent"]["circle"] == nil then
		saved["parent"]["circle"] = 1
	end
	if not saved["children"] then
		saved["children"] = {}
	end
	if saved["children"]["size"] == nil then
		saved["children"]["size"] = 36
	end
	if saved["children"]["hideonclick"] == nil then
		saved["children"]["hideonclick"] = 1
	end
	local count = table.getn(ammoList)
	local spells = saved["spells"]
	local visible = saved["visible"]
	if not spells or table.getn(spells) ~= count then
		saved["spells"] = {}
		for i = 1, count do
			saved["spells"][i] = i
		end
	end
	if not visible then
		saved["visible"] = {}
		visible = saved["visible"]
	end
	for i = 1, count do
		if visible[i] == nil then
			visible[i] = 1
		end
	end
end

local function zButtonAmmo_ApplyRuntimeSettings()
	if not zButtonAmmo then
		return
	end
	local saved = zButtonAmmo_GetSaved()
	zButtonAmmo.tooltip = saved["tooltip"] and true or false
	zButtonAmmo.hideonclick = saved["children"] and saved["children"]["hideonclick"] and true or false
	if saved["showammoname"] == nil then
		saved["showammoname"] = 1
	end
	zButtonAmmo.showammoname = saved["showammoname"] and true or false
end

local function zButtonAmmo_GetEquippedAmmoName()
	local ammoLink = zButtonAmmo_GetEquippedAmmoLink()
	if not ammoLink then
		return nil
	end
	local _, _, ammoName = string.find(ammoLink, "%[(.+)%]")
	if ammoName then
		return ammoName
	end
	return ammoLink
end

local zButtonAmmo_EquipFromButton

local function zButtonAmmo_DeferredStartupSync()
	if not zButtonAmmo then
		return
	end

	local attempts = 0
	local syncFrame = CreateFrame("Frame", "zButtonAmmoStartupSync")
	if not syncFrame then
		return
	end

	syncFrame:SetScript("OnUpdate", function()
		attempts = attempts + 1
		if attempts < 5 then
			return
		end

		syncFrame:SetScript("OnUpdate", nil)
		local equippedNow = zButtonAmmo_GetEquippedAmmoName()
		local saved = zButtonAmmo_GetSaved()

		zButtonAmmo_RebuildCache()

		if equippedNow and (not saved["lastEquipped"] or saved["lastEquipped"] == "") then
			zButtonAmmo_SaveEquippedAmmo(equippedNow)
		end
	end)
end

local zButtonAmmo_LastEquipAttempt = { key = nil, time = 0 }

local function zButtonAmmo_CanEquip(button)
	if not (button and button.ammobag and button.ammoslot) then
		return false
	end
	local bag = tonumber(button.ammobag)
	local slot = tonumber(button.ammoslot)
	if not bag or not slot then
		return false
	end
	if bag < 0 or bag > 4 then
		return false
	end
	local bagSlots = GetContainerNumSlots(bag) or 0
	if slot < 1 or slot > bagSlots then
		return false
	end
	local link = GetContainerItemLink(bag, slot)
	if not link then
		return false
	end
	if button.ammoid then
		local _, _, linkId = string.find(link, "Hitem:((%d+).-)")
		if linkId and tostring(linkId) ~= tostring(button.ammoid) then
			return false
		end
	end
	return true
end

zButtonAmmo_EquipFromButton = function(button)
	if not zButtonAmmo_CanEquip(button) then
		return false
	end
	local now = GetTime and GetTime() or 0
	local key = tostring(button.ammoname or "") .. ":" .. tostring(button.ammobag) .. ":" .. tostring(button.ammoslot)
	if zButtonAmmo_LastEquipAttempt.key == key and now > 0 and (now - zButtonAmmo_LastEquipAttempt.time) < 0.5 then
		return false
	end
	zButtonAmmo_LastEquipAttempt.key = key
	zButtonAmmo_LastEquipAttempt.time = now

	PickupContainerItem(button.ammobag, button.ammoslot)
	if CursorHasItem() then
		EquipCursorItem(0)
	end
	if CursorHasItem() then
		if ClearCursor then ClearCursor() end
		return false
	end
	if button.ammoname then
		zButtonAmmo_SaveEquippedAmmo(button.ammoname)
	end
	return true
end


function zButtonAmmo_OnLoad()
	this:RegisterEvent("VARIABLES_LOADED")
end

function zButtonAmmo_OnEvent()
	if event == "VARIABLES_LOADED" then
		if not zButtonAmmo then
			return
		end
		if UnitClass("player") ~= ZHUNTER_HUNTER then
			zButtonAmmo:UnregisterAllEvents()
			zButtonAmmo:Hide()
			return
		end
		zButtonAmmo.customSetButtons = zButtonAmmo_SetButtons
		zButtonAmmo.customUpdateButton = zButtonAmmo_UpdateButton
		zButtonAmmo_CreateButtons()
			zButtonAmmoAdjustment = CreateFrame("Frame", "zButtonAmmoAdjustment")
		zButtonAmmoAdjustment:RegisterEvent("UNIT_INVENTORY_CHANGED")
		zButtonAmmoAdjustment:RegisterEvent("BAG_UPDATE")
		zButtonAmmoAdjustment:SetScript("OnEvent", zButtonAmmoAdjustment_OnEvent)
		zButtonAmmo_SetupSizeAndPosition()
		zButtonAmmo_DeferredStartupSync()
	end
end

function zButtonAmmo_SaveEquippedAmmo(ammoname)
	-- Save the currently equipped ammo to persistent storage
	local saved = zButtonAmmo_GetSaved()
	if saved["lastEquipped"] == ammoname then
		return
	end
	saved["lastEquipped"] = ammoname
end

function zButtonAmmo_LoadLastEquippedAmmo()
	-- Load the last equipped ammo from persistent storage
	local saved = zButtonAmmo_GetSaved()
	if saved["lastEquipped"] then
		return saved["lastEquipped"]
	end
	return nil
end

function zButtonAmmo_CreateButtons()
	local ammoList = zButtonAmmo_GetAmmoList()
	ZHunterMod_Ammo_Buttons = ammoList
	zButtonAmmo_EnsureSpellOrder(ammoList)
	local saved = zButtonAmmo_GetSaved()
	if not zButtonAmmo.children then
		ZSpellButton_CreateChildren(zButtonAmmo, "zButtonAmmo", ZHUNTER_AMMO_MAX_COUNT)
	else
		zButtonAmmo.count = ZHUNTER_AMMO_MAX_COUNT
	end
	local info = {}
	local infoIndex = 1
	for i=1, table.getn(ammoList) do
		--DEFAULT_CHAT_FRAME:AddMessage(i.." "..saved["spells"][i], 0, 1, 1)
		if not tonumber(saved["spells"][i]) then
			info = ammoList
			zButtonAmmo_EnsureSpellOrder(ammoList)
			saved = zButtonAmmo_GetSaved()
			break
		end
		local ammoIndex = saved["spells"][i]
		if saved["visible"][ammoIndex] ~= false then
			info[infoIndex] = ammoList[ammoIndex]
			infoIndex = infoIndex + 1
		end
	end
	zButtonAmmo.found = ZSpellButton_SetButtons(zButtonAmmo, info)
	zButtonAmmo_ApplyRuntimeSettings()
	
	-- Try to restore the last equipped ammo from saved variables
	local lastEquipped = zButtonAmmo_LoadLastEquippedAmmo()
	local equippedAmmoNameAtInit = zButtonAmmo_GetEquippedAmmoName()
	if equippedAmmoNameAtInit then
		zButtonAmmo_SaveEquippedAmmo(equippedAmmoNameAtInit)
	end
end

function zButtonAmmo_SetupSizeAndPosition()
	zButtonAmmo_EnsureSpellOrder(ZHunterMod_Ammo_Buttons or zButtonAmmo_GetAmmoList())
	local saved = zButtonAmmo_GetSaved()
	if saved["enabled"] == false or saved["enabled"] == 0 then
		if zButtonAmmo and zButtonAmmo.Hide then
			zButtonAmmo:Hide()
		end
		return
	end
	local ammoList = ZHunterMod_Ammo_Buttons or zButtonAmmo_GetAmmoList()
	local arrangeCount = zButtonAmmo.found or table.getn(ammoList)
	if arrangeCount < 0 then
		arrangeCount = 0
	end
	ZSpellButton_SetSize(zButtonAmmo, saved["parent"]["size"])
	ZSpellButton_SetSize(zButtonAmmo, saved["children"]["size"], 1)
	ZSpellButton_SetExpandDirection(zButtonAmmo, saved["firstbutton"])
	ZSpellButton_ArrangeChildren(zButtonAmmo, saved["rows"], 
		arrangeCount, saved["horizontal"],
		saved["vertical"])
end

function zButtonAmmo_Reset()
	local ammoList = zButtonAmmo_GetAmmoList()
	local ammoCount = table.getn(ammoList)
	local currentRoot = zButtonAmmo_GetRoot()
	currentRoot["zButtonAmmo"] = {}
	local saved = zButtonAmmo_GetSaved()
	saved["spells"] = {}
	saved["visible"] = {}
	for i = 1, ammoCount do
		saved["spells"][i] = i
		saved["visible"][i] = 1
	end
	saved["rows"] = 1
	saved["horizontal"] = nil
	saved["vertical"] = nil
	saved["firstbutton"] = "RIGHT"
	saved["enabled"] = 1
	saved["tooltip"] = 1
	saved["parent"] = {}
	saved["parent"]["size"] = 36
	saved["parent"]["hide"] = nil
	saved["parent"]["circle"] = 1
	saved["children"] = {}
	saved["children"]["size"] = 36
	saved["children"]["hideonclick"] = 1
	saved["showammoname"] = 1
	saved["lastEquipped"] = nil
end

function zButtonAmmoAdjustment_OnEvent()
	if not zButtonAmmo or not zButtonAmmo.count then
		return
	end
	local saved = zButtonAmmo_GetSaved()
	
	if event == "UNIT_INVENTORY_CHANGED" or event == "BAG_UPDATE" then
		local ammoList = zButtonAmmo_GetAmmoList()
		local listChanged = (ZHunterMod_Ammo_Buttons ~= ammoList)
		ZHunterMod_Ammo_Buttons = ammoList
		zButtonAmmo_RebuildCache()
		local cacheSignature = zButtonAmmo_GetCacheSignature()
		if listChanged or cacheSignature ~= zButtonAmmo_LastCacheSignature then
			zButtonAmmo_EnsureSpellOrder(ammoList)
			local info = {}
			local infoIndex = 1
			for i=1, table.getn(ammoList) do
				local ammoIndex = saved["spells"][i]
				if saved["visible"][ammoIndex] ~= false then
					info[infoIndex] = ammoList[ammoIndex]
					infoIndex = infoIndex + 1
				end
			end
			zButtonAmmo.found = ZSpellButton_SetButtons(zButtonAmmo, info)
			zButtonAmmo_SetupSizeAndPosition()
			zButtonAmmo_LastCacheSignature = zButtonAmmo_GetCacheSignature()
		end
		-- Update ammo counts for child buttons
		for i=1, zButtonAmmo.count do
			local button = getglobal("zButtonAmmo"..i)
			if button and button.ammoname and not button.isspell then
				zButtonAmmo_UpdateButton(button)
			end
		end
		local equippedAmmoName = zButtonAmmo_GetEquippedAmmoName()
		local equippedInfo = nil
		if equippedAmmoName then
			equippedInfo = zButtonAmmo_Cache[equippedAmmoName]
			if not equippedInfo then
				for i=1, zButtonAmmo.count do
					local child = getglobal("zButtonAmmo"..i)
					if child and child.ammoname == equippedAmmoName and not child.isspell then
						equippedInfo = {
							ammo = child.ammoname,
							brol = child.ammobrol,
							quality = child.ammoqual,
							lvl = child.ammolvl,
							type = child.ammotype,
							bag = child.ammobag,
							slot = child.ammoslot,
							id = child.ammoid or child.id,
							link = child.ammolink,
							icon = child.icon,
							count = child.ammocount,
						}
						break
					end
				end
			end
		end

		if not equippedInfo then
			equippedInfo = zButtonAmmo_GetEquippedAmmoInfo()
			if equippedInfo and equippedInfo.ammo and not equippedAmmoName then
				equippedAmmoName = equippedInfo.ammo
			end
		end

		if equippedInfo and equippedInfo.ammo and equippedInfo.ammo ~= zButtonAmmo.ammoname then
			zButtonAmmo_AssignButtonFromAmmoInfo(zButtonAmmo, equippedInfo)
		end

		-- Also update parent if it's showing ammo (not a spell)
		if zButtonAmmo and not zButtonAmmo.isspell and zButtonAmmo.ammoname then
			zButtonAmmo_UpdateButton(zButtonAmmo)
		end

		-- Save the currently equipped ammo for restoration on next reload
		if equippedAmmoName then
			zButtonAmmo_SaveEquippedAmmo(equippedAmmoName)
		end
	end	
end

function zButtonAmmo_KeyBinding(index)
	if MTH_ZH_IsModuleEnabled and not MTH_ZH_IsModuleEnabled() then
		return
	end

	local button
	if index then
		button = getglobal("zButtonAmmo"..index)
	else
		button = zButtonAmmo
	end
	if button and button.id then
		if button.isspell then
			CastSpell(button.id, "spell")
		elseif button.ammobag and button.ammoslot then
			zButtonAmmo_EquipFromButton(button)
		end
		if zButtonAmmo.hideonclick then
			if type(ZSpellButton_SetChildrenExpanded) == "function" then
				ZSpellButton_SetChildrenExpanded(zButtonAmmo, false)
			elseif zButtonAmmo.children then
				zButtonAmmo.children:Hide()
			end
		end
	end
end

SLASH_zButtonAmmo1 = "/zammobutton"
SLASH_zButtonAmmo2 = "/zammo"
SlashCmdList["zButtonAmmo"] = function(msg)
	if MTH_ZH_HandleDisabledSlash and MTH_ZH_HandleDisabledSlash("Ammo button is disabled while module 'zhunter' is disabled.") then
		return
	end
	if msg == "reset" then
		zButtonAmmo_Reset()
		zButtonAmmo:ClearAllPoints()
		zButtonAmmo:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
	elseif msg == "options" then
		MTH_OpenOptions("Ammo")
	else
		MTH_ZH_Print("Possible Commands: \"options\", \"reset\"")
	end
end

