local MTH_ZBUTTONS_READY = MTH_OptionsRequire and MTH_OptionsRequire("options-zbuttons", {
	"MTH_GetFrame",
	"MTH_CreateSlider",
	"MTH_CreateCheckbox",
	"MTH_ClearContainer",
	"MTH_CreateActionButton",
})

local function MTH_ZB_RefreshTab(tabName)
	if type(MTH_ResetAndSelectOptionsTab) == "function" then
		MTH_ResetAndSelectOptionsTab(tabName)
	elseif type(MTH_SelectOptionsTab) == "function" then
		MTH_SelectOptionsTab(tabName)
	end
end

local function MTH_RebuildSpellOrder(buttonName, buttonObj, itemList, maxButtons)
	if not (buttonName and buttonObj and itemList and maxButtons) then return end
	local info = {}
	local visible = ZHunterMod_Saved[buttonName]["visible"] or {}
	local infoIndex = 1
	for i = 1, maxButtons do
		local spellIndex = ZHunterMod_Saved[buttonName]["spells"][i]
		if spellIndex and visible[spellIndex] ~= false then
			info[infoIndex] = itemList[spellIndex]
			infoIndex = infoIndex + 1
		end
	end
	if ZSpellButton_SetButtons then
		buttonObj.found = ZSpellButton_SetButtons(buttonObj, info)
	end
end

local function MTH_RefreshButtonLayout(buttonName, buttonObj, itemList, maxButtons)
	local resolvedButtonObj = buttonObj or getglobal(buttonName)
	if not resolvedButtonObj then return end
	MTH_RebuildSpellOrder(buttonName, resolvedButtonObj, itemList, maxButtons)
	local setupFunc = getglobal(buttonName.."_SetupSizeAndPosition")
	if type(setupFunc) == "function" then
		setupFunc()
	end
	if ZSpellButton_UpdateButton then
		ZSpellButton_UpdateButton(resolvedButtonObj)
	end
	if ZSpellButton_UpdateCooldown then
		ZSpellButton_UpdateCooldown(resolvedButtonObj)
	end
	if resolvedButtonObj.count and resolvedButtonObj.name then
		for i = 1, resolvedButtonObj.count do
			local child = getglobal(resolvedButtonObj.name .. i)
			if child and child.id then
				if ZSpellButton_UpdateButton then
					ZSpellButton_UpdateButton(child)
				end
				if ZSpellButton_UpdateCooldown then
					ZSpellButton_UpdateCooldown(child)
				end
			end
		end
	end
end

local function MTH_RefreshButtonGeometry(buttonName, buttonObj)
	local resolvedButtonObj = buttonObj or getglobal(buttonName)
	if not resolvedButtonObj then return end
	local setupFunc = getglobal(buttonName.."_SetupSizeAndPosition")
	if type(setupFunc) == "function" then
		setupFunc()
	end
	if ZSpellButton_UpdateButton then
		ZSpellButton_UpdateButton(resolvedButtonObj)
	end
	if ZSpellButton_UpdateCooldown then
		ZSpellButton_UpdateCooldown(resolvedButtonObj)
	end
	if resolvedButtonObj.count and resolvedButtonObj.name then
		for i = 1, resolvedButtonObj.count do
			local child = getglobal(resolvedButtonObj.name .. i)
			if child and child.id then
				if ZSpellButton_UpdateButton then
					ZSpellButton_UpdateButton(child)
				end
				if ZSpellButton_UpdateCooldown then
					ZSpellButton_UpdateCooldown(child)
				end
			end
		end
	end
end

local function MTH_SetButtonEnabledState(buttonName, buttonObj, enabled)
	if not (buttonName and ZHunterMod_Saved and ZHunterMod_Saved[buttonName]) then return end
	ZHunterMod_Saved[buttonName]["enabled"] = enabled and true or false

	local resolvedButtonObj = buttonObj or getglobal(buttonName)
	if not resolvedButtonObj then return end

	if not enabled then
		if resolvedButtonObj.Hide then
			resolvedButtonObj:Hide()
		end
		if resolvedButtonObj.count and resolvedButtonObj.name then
			for i = 1, resolvedButtonObj.count do
				local child = getglobal(resolvedButtonObj.name .. i)
				if child and child.Hide then
					child:Hide()
				end
			end
		end
		return
	end

	if ZHunterMod_Saved[buttonName]["parent"] and ZHunterMod_Saved[buttonName]["parent"]["hide"] then
		if resolvedButtonObj.Hide then
			resolvedButtonObj:Hide()
		end
		return
	end

	if resolvedButtonObj.Show then
		resolvedButtonObj:Show()
	end
	MTH_RefreshButtonGeometry(buttonName, resolvedButtonObj)
end

local function MTH_GetButtonItemList(buttonName)
	if buttonName == "zButtonPet" then
		return getglobal("ZHunterMod_Pet_Spells")
	elseif buttonName == "zButtonTrack" then
		return getglobal("ZHunterMod_Track_Spells")
	elseif buttonName == "zButtonAspect" then
		return getglobal("ZHunterMod_Aspect_Spells")
	elseif buttonName == "zButtonTrap" then
		return getglobal("ZHunterMod_Trap_Spells")
	elseif buttonName == "zButtonAmmo" then
		local sharedBullets = getglobal("MTH_AMMO_BULLETS")
		local sharedArrows = getglobal("MTH_AMMO_ARROWS")
		if GetInventoryItemLink and GetItemInfo then
			local link = GetInventoryItemLink("player", 18)
			if link then
				local _, _, itemId = string.find(link, "item:(%d+)")
				if itemId then
					local _, _, _, _, _, weaponType = GetItemInfo(itemId)
					if weaponType == MTH_WEAPON_GUNS then
						return sharedBullets or getglobal("ZHunterMod_Ammo_Buttons")
					elseif weaponType == MTH_WEAPON_BOWS or weaponType == MTH_WEAPON_CROSSBOWS then
						return sharedArrows or getglobal("ZHunterMod_Ammo_Buttons")
					end
				end
			end
		end
		return getglobal("ZHunterMod_Ammo_Buttons") or sharedArrows
	elseif buttonName == "zButtonMounts" or buttonName == "zButtonCompanions" or buttonName == "zButtonToys" then
		if ZHunterMod_Saved and ZHunterMod_Saved[buttonName] and ZHunterMod_Saved[buttonName]["spells"] then
			return ZHunterMod_Saved[buttonName]["spells"]
		end
	end
	return nil
end

local MTH_AmmoOptionsWatcher = nil

local function MTH_RefreshAmmoOptionsIfVisible()
	if not MTH_GetFrame then return end
	local container = MTH_GetFrame("MetaHuntOptionsAmmo")
	if not (container and container:IsVisible()) then
		return
	end
	if type(MTH_SetupAmmoOptions) == "function" then
		MTH_SetupAmmoOptions()
	end
end

local function MTH_EnsureAmmoOptionsWatcher()
	if MTH_AmmoOptionsWatcher then
		return
	end
	MTH_AmmoOptionsWatcher = CreateFrame("Frame", "MTHAmmoOptionsWatcherFrame")
	if not MTH_AmmoOptionsWatcher then
		return
	end
	MTH_AmmoOptionsWatcher:RegisterEvent("UNIT_INVENTORY_CHANGED")
	MTH_AmmoOptionsWatcher:RegisterEvent("BAG_UPDATE")
	MTH_AmmoOptionsWatcher:SetScript("OnEvent", function(_, eventName, unit)
		eventName = eventName or event
		unit = unit or arg1
		if eventName == "UNIT_INVENTORY_CHANGED" and unit and unit ~= "player" then
			return
		end
		MTH_RefreshAmmoOptionsIfVisible()
	end)
end

local function MTH_SetupButtonOptions(containerName, buttonName, displayName, maxButtons)
	local container = MTH_GetFrame(containerName)
	if not container then
		if MTH and MTH.Print then
			MTH:Print("[MTH] Container not found: "..containerName, "error")
		end
		return
	end

	MTH_ClearContainer(container)

	if not ZHunterMod_Saved or not ZHunterMod_Saved[buttonName] then
		local errText = container:CreateFontString(containerName.."Error", "ARTWORK", "GameFontNormal")
		errText:SetPoint("CENTER", container, "CENTER", 0, 0)
		errText:SetText("Configuration not loaded for "..displayName)
		errText:SetTextColor(1, 0.5, 0.5)
		if MTH and MTH.Print then
			MTH:Print("[MTH] zhunter saved data missing for "..buttonName, "error")
		end
		return
	end

	local buttonObj = getglobal(buttonName)
	local containerWidth = container:GetWidth() or 500
	local leftWidth = 260
	local rightX = leftWidth + 44
	local rightWidth = containerWidth - rightX - 12

	local function MTH_ZB_EnsureSection(sectionName, titleText, yOffset, sectionHeight)
		local section = CreateFrame("Frame", sectionName, container, "OptionFrameBoxTemplate")
		if not section then return nil end
		section:ClearAllPoints()
		section:SetPoint("TOPLEFT", container, "TOPLEFT", 16, yOffset)
		section:SetWidth(leftWidth)
		section:SetHeight(sectionHeight)
		section:Show()

		local title = getglobal(sectionName .. "Title")
		if title then
			title:SetText(titleText)
		end

		return section
	end

	if ZHunterMod_Saved[buttonName]["enabled"] == nil then
		ZHunterMod_Saved[buttonName]["enabled"] = true
	end
	local enableLabel = tostring(displayName or "")
	if string.len(enableLabel) > 0 then
		enableLabel = string.lower(string.sub(enableLabel, 1, 1)) .. string.sub(enableLabel, 2)
	end

	local enableButton = MTH_CreateCheckbox(container, containerName.."EnableButton", "Enable "..enableLabel, -8)
	if enableButton then
		enableButton:SetChecked(ZHunterMod_Saved[buttonName]["enabled"] and true or false)
		enableButton.buttonName = buttonName
		enableButton.buttonObj = buttonObj
		enableButton:SetScript("OnClick", function(self)
			self = self or this
			if not self then return end
			local checked = self:GetChecked() and true or false
			MTH_SetButtonEnabledState(self.buttonName, self.buttonObj, checked)
		end)
	end

	local parentSection = MTH_ZB_EnsureSection(containerName.."ParentSection", "Parent Button", -52, 116)
	local childrenSection = MTH_ZB_EnsureSection(containerName.."ChildrenSection", "Children Buttons", -184, 235)

	local parentYOffset = -18
	local childrenYOffset = -18

	local btnSize = MTH_CreateSlider(childrenSection or container, containerName.."ButtonSize", "Button Size", 10, 100, 1, childrenYOffset)
	if btnSize then
		btnSize:SetWidth(leftWidth - 40)
		btnSize:SetValue(ZHunterMod_Saved[buttonName]["children"]["size"] or 36)
		btnSize.buttonName = buttonName
		btnSize.buttonObj = buttonObj
		btnSize.itemList = MTH_GetButtonItemList(buttonName)
		btnSize.maxButtons = maxButtons
		btnSize.onChange = function(val, slider)
			local frame = slider or btnSize
			local btnName = frame and frame.buttonName
			if not btnName or not (ZHunterMod_Saved and ZHunterMod_Saved[btnName]) then return end
			if not ZHunterMod_Saved[btnName]["children"] then
				ZHunterMod_Saved[btnName]["children"] = {}
			end
			local size = math.floor((val or 0) + 0.5)
			ZHunterMod_Saved[btnName]["children"]["size"] = size
			MTH_RefreshButtonGeometry(btnName, frame.buttonObj)
		end
	end
	childrenYOffset = childrenYOffset - 50

	local rowCount = MTH_CreateSlider(childrenSection or container, containerName.."RowCount", "Number of Rows", 1, maxButtons, 1, childrenYOffset)
	if rowCount then
		rowCount:SetWidth(leftWidth - 40)
		rowCount:SetValue(ZHunterMod_Saved[buttonName]["rows"] or 1)
		rowCount.buttonName = buttonName
		rowCount.buttonObj = buttonObj
		rowCount.itemList = MTH_GetButtonItemList(buttonName)
		rowCount.maxButtons = maxButtons
		rowCount.onChange = function(val, slider)
			local frame = slider or rowCount
			local btnName = frame and frame.buttonName
			if not btnName or not (ZHunterMod_Saved and ZHunterMod_Saved[btnName]) then return end
			ZHunterMod_Saved[btnName]["rows"] = math.floor((val or 1) + 0.5)
			MTH_RefreshButtonGeometry(btnName, frame.buttonObj)
		end
	end
	childrenYOffset = childrenYOffset - 40

	if ZHunterMod_Saved[buttonName]["firstbutton"] == nil then
		ZHunterMod_Saved[buttonName]["firstbutton"] = "RIGHT"
	end
	local expandLeft = MTH_CreateCheckbox(childrenSection or container, containerName.."ExpandLeft", "Expand Left (opposite side)", childrenYOffset)
	if expandLeft then
		expandLeft:SetChecked(ZHunterMod_Saved[buttonName]["firstbutton"] == "LEFT")
		expandLeft.buttonName = buttonName
		expandLeft.buttonObj = buttonObj
		expandLeft:SetScript("OnClick", function(self)
			self = self or this
			if not self then return end
			local checked = self:GetChecked() and true or false
			local btnName = self.buttonName
			if not btnName or not (ZHunterMod_Saved and ZHunterMod_Saved[btnName]) then return end
			ZHunterMod_Saved[btnName]["firstbutton"] = checked and "LEFT" or "RIGHT"
			ZHunterMod_Saved[btnName]["horizontal"] = checked and 1 or nil
			ZHunterMod_Saved[btnName]["vertical"] = checked and 1 or nil
			MTH_RefreshButtonGeometry(btnName, self.buttonObj)
		end)
	end
	childrenYOffset = childrenYOffset - 30

	local hideClick = MTH_CreateCheckbox(childrenSection or container, containerName.."HideOnClick", "Hide Buttons On Click", childrenYOffset)
	if hideClick then
		hideClick:SetChecked(ZHunterMod_Saved[buttonName]["children"]["hideonclick"])
		hideClick.buttonName = buttonName
		hideClick.buttonObj = buttonObj
		if hideClick.buttonObj then
			hideClick.buttonObj.hideonclick = ZHunterMod_Saved[buttonName]["children"]["hideonclick"] and true or false
		end
		hideClick:SetScript("OnClick", function(self)
			self = self or this
			if not self then return end
			local checked = self:GetChecked() and true or false
			ZHunterMod_Saved[self.buttonName]["children"]["hideonclick"] = checked
			local btnObj = self.buttonObj or getglobal(self.buttonName)
			if btnObj then btnObj.hideonclick = checked end
		end)
	end
	childrenYOffset = childrenYOffset - 25

	local showTooltip = MTH_CreateCheckbox(childrenSection or container, containerName.."ShowTooltip", "Show Tooltip", childrenYOffset)
	if showTooltip then
		showTooltip:SetChecked(ZHunterMod_Saved[buttonName]["tooltip"])
		showTooltip.buttonName = buttonName
		showTooltip.buttonObj = buttonObj
		if showTooltip.buttonObj then
			showTooltip.buttonObj.tooltip = ZHunterMod_Saved[buttonName]["tooltip"] and true or false
		end
		showTooltip:SetScript("OnClick", function(self)
			self = self or this
			if not self then return end
			local checked = self:GetChecked() and true or false
			ZHunterMod_Saved[self.buttonName]["tooltip"] = checked
			local btnObj = self.buttonObj or getglobal(self.buttonName)
			if btnObj then btnObj.tooltip = checked end
		end)
	end
	childrenYOffset = childrenYOffset - 25

	if buttonName == "zButtonAmmo" then
		if ZHunterMod_Saved[buttonName]["showammoname"] == nil then
			ZHunterMod_Saved[buttonName]["showammoname"] = 1
		end
		local showAmmoName = MTH_CreateCheckbox(childrenSection or container, containerName.."ShowAmmoName", "Show ammo name", childrenYOffset)
		if showAmmoName then
			showAmmoName:SetChecked(ZHunterMod_Saved[buttonName]["showammoname"])
			showAmmoName.buttonName = buttonName
			showAmmoName.buttonObj = buttonObj
			showAmmoName.maxButtons = maxButtons
			showAmmoName:SetScript("OnClick", function(self)
				self = self or this
				if not self then return end
				local checked = self:GetChecked() and true or false
				local btnName = self.buttonName
				ZHunterMod_Saved[btnName]["showammoname"] = checked
				local btnObj = self.buttonObj or getglobal(btnName)
				if btnObj then
					for i = 1, (btnObj.count or 0) do
						local child = getglobal(btnName..i)
						if child and child.ammoname and not child.isspell then
							zButtonAmmo_UpdateButton(child)
						end
					end
					if btnObj.ammoname and not btnObj.isspell then
						zButtonAmmo_UpdateButton(btnObj)
					end
				end
			end)
		end
		childrenYOffset = childrenYOffset - 35
	else
		childrenYOffset = childrenYOffset - 35
	end

	local mainSize = MTH_CreateSlider(parentSection or container, containerName.."MainButtonSize", "Button Size", 10, 100, 1, parentYOffset)
	if mainSize then
		mainSize:SetWidth(leftWidth - 40)
		mainSize:SetValue(ZHunterMod_Saved[buttonName]["parent"]["size"] or 36)
		mainSize.buttonName = buttonName
		mainSize.buttonObj = buttonObj
		mainSize.onChange = function(val, slider)
			local frame = slider or mainSize
			local btnName = frame and frame.buttonName
			local btnObj = (frame and frame.buttonObj) or (btnName and getglobal(btnName))
			if not btnName or not (ZHunterMod_Saved and ZHunterMod_Saved[btnName]) then return end
			if not ZHunterMod_Saved[btnName]["parent"] then
				ZHunterMod_Saved[btnName]["parent"] = {}
			end
			local size = math.floor((val or 0) + 0.5)
			ZHunterMod_Saved[btnName]["parent"]["size"] = size
			if btnObj then
				btnObj:SetWidth(size)
				btnObj:SetHeight(size)
			end
			MTH_RefreshButtonGeometry(btnName, btnObj)
		end
	end
	parentYOffset = parentYOffset - 35

	local hideButton = MTH_CreateCheckbox(parentSection or container, containerName.."HideButton", "Hide Button", parentYOffset)
	if hideButton then
		hideButton:SetChecked(ZHunterMod_Saved[buttonName]["parent"]["hide"])
		hideButton.buttonName = buttonName
		hideButton.buttonObj = buttonObj
		hideButton:SetScript("OnClick", function(self)
			self = self or this
			if not self then return end
			local checked = self:GetChecked() == 1
			ZHunterMod_Saved[self.buttonName]["parent"]["hide"] = checked
			if self.buttonObj then
				if checked then self.buttonObj:Hide() else self.buttonObj:Show() end
			end
		end)
	end
	parentYOffset = parentYOffset - 25

	local useCircle = MTH_CreateCheckbox(parentSection or container, containerName.."UseCircle", "Use Circle Button", parentYOffset)
	if useCircle then
		useCircle:SetChecked(ZHunterMod_Saved[buttonName]["parent"]["circle"])
		useCircle.buttonName = buttonName
		useCircle.buttonObj = buttonObj
		useCircle:SetScript("OnClick", function(self)
			self = self or this
			if not self then return end
			local checked = self:GetChecked() == 1
			ZHunterMod_Saved[self.buttonName]["parent"]["circle"] = checked
			if self.buttonObj and self.buttonObj.circle then
				if checked then self.buttonObj.circle:Show() else self.buttonObj.circle:Hide() end
			end
		end)
	end

	MTH_SetButtonEnabledState(buttonName, buttonObj, ZHunterMod_Saved[buttonName]["enabled"] and true or false)

	local advHeader = container:CreateFontString(containerName.."AdvHeader", "ARTWORK", "GameFontHighlight")
	advHeader:SetPoint("TOPLEFT", container, "TOPLEFT", rightX, -10)
	advHeader:SetText("Spell Order")

	local itemList = MTH_GetButtonItemList(buttonName)

	if not itemList or not ZHunterMod_Saved[buttonName]["spells"] then
		local noData = container:CreateFontString(containerName.."NoData", "ARTWORK", "GameFontNormalSmall")
		noData:SetPoint("TOPRIGHT", container, "TOPRIGHT", -80, -50)
		noData:SetText("Spell data not loaded")
		noData:SetTextColor(1, 0.5, 0.5)
		return
	end

	if not ZHunterMod_Saved[buttonName]["visible"] then
		ZHunterMod_Saved[buttonName]["visible"] = {}
	end
	for i = 1, maxButtons do
		if ZHunterMod_Saved[buttonName]["visible"][i] == nil then
			ZHunterMod_Saved[buttonName]["visible"][i] = 1
		end
	end

	local listY = -35

	for i = 1, maxButtons do
		local spellIndex = ZHunterMod_Saved[buttonName]["spells"][i]
		local spellName = itemList[spellIndex] or itemList[i] or ""
		local controlsOffset = 86
		local labelWidth = rightWidth - controlsOffset
		if labelWidth < 130 then labelWidth = 130 end
		local rowX = rightX
		local downX = rowX + 30
		local upX = downX + 22
		local labelX = upX + 26

		local showToggle = MTH_CreateCheckbox(container, containerName.."ShowToggle"..i, "", 0)
		if showToggle then
			showToggle:ClearAllPoints()
			showToggle:SetPoint("TOPLEFT", container, "TOPLEFT", rowX, listY + 2)
			showToggle.spellIndex = spellIndex or i
			showToggle.buttonName = buttonName
			showToggle.containerName = containerName
			showToggle.buttonObj = buttonObj
			showToggle.itemList = itemList
			showToggle.maxButtons = maxButtons
			local showText = getglobal(containerName.."ShowToggle"..i.."Text")
			if showText then
				showText:SetText("")
			end
			showToggle:SetChecked(ZHunterMod_Saved[buttonName]["visible"][showToggle.spellIndex] ~= false)
			showToggle:SetScript("OnClick", function(self)
				self = self or this
				if not self then return end
				local checked = self:GetChecked() == 1
				local btnName = self.buttonName
				local visibleIndex = self.spellIndex
				if not ZHunterMod_Saved[btnName]["visible"] then
					ZHunterMod_Saved[btnName]["visible"] = {}
				end
				ZHunterMod_Saved[btnName]["visible"][visibleIndex] = checked
				MTH_RefreshButtonLayout(btnName, self.buttonObj, self.itemList, self.maxButtons)
			end)
		end

		local downBtn = CreateFrame("Button", nil, container, "UIPanelButtonTemplate")
		downBtn:SetPoint("TOPLEFT", container, "TOPLEFT", downX, listY)
		downBtn:SetWidth(20)
		downBtn:SetHeight(20)
		downBtn:SetText("-")
		downBtn.spellIndex = i
		downBtn.buttonName = buttonName
		downBtn.containerName = containerName
		downBtn.buttonObj = buttonObj
		downBtn.itemList = itemList
		downBtn.maxButtons = maxButtons
		downBtn:SetScript("OnClick", function(self)
			self = self or this
			if not self then return end
			local idx = self.spellIndex
			local btnName = self.buttonName
			local contName = self.containerName
			local maxBtns = self.maxButtons
			if idx < maxBtns then
				local temp = ZHunterMod_Saved[btnName]["spells"][idx+1]
				ZHunterMod_Saved[btnName]["spells"][idx+1] = ZHunterMod_Saved[btnName]["spells"][idx]
				ZHunterMod_Saved[btnName]["spells"][idx] = temp
				MTH_RebuildSpellOrder(btnName, self.buttonObj, self.itemList, self.maxButtons)
				local tabName = gsub(contName, "MetaHuntOptions", "")
				MTH_ZB_RefreshTab(tabName)
			end
		end)

		local upBtn = CreateFrame("Button", nil, container, "UIPanelButtonTemplate")
		upBtn:SetPoint("TOPLEFT", container, "TOPLEFT", upX, listY)
		upBtn:SetWidth(20)
		upBtn:SetHeight(20)
		upBtn:SetText("+")
		upBtn.spellIndex = i
		upBtn.buttonName = buttonName
		upBtn.containerName = containerName
		upBtn.buttonObj = buttonObj
		upBtn.itemList = itemList
		upBtn.maxButtons = maxButtons
		upBtn:SetScript("OnClick", function(self)
			self = self or this
			if not self then return end
			local idx = self.spellIndex
			local btnName = self.buttonName
			local contName = self.containerName
			if idx > 1 then
				local temp = ZHunterMod_Saved[btnName]["spells"][idx-1]
				ZHunterMod_Saved[btnName]["spells"][idx-1] = ZHunterMod_Saved[btnName]["spells"][idx]
				ZHunterMod_Saved[btnName]["spells"][idx] = temp
				MTH_RebuildSpellOrder(btnName, self.buttonObj, self.itemList, self.maxButtons)
				local tabName = gsub(contName, "MetaHuntOptions", "")
				MTH_ZB_RefreshTab(tabName)
			end
		end)

		local label = container:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
		label:SetPoint("TOPLEFT", container, "TOPLEFT", labelX, listY)
		label:SetText(spellName)
		label:SetWidth(labelWidth)
		label:SetJustifyH("LEFT")

		listY = listY - 25
	end
end

function MTH_SetupPetOptions()
	if not MTH_ZBUTTONS_READY then return end
	MTH_SetupButtonOptions("MetaHuntOptionsPet", "zButtonPet", "ZPet", 10)
end

function MTH_SetupTrackOptions()
	if not MTH_ZBUTTONS_READY then return end
	MTH_SetupButtonOptions("MetaHuntOptionsTrack", "zButtonTrack", "ZTrack", 11)
end

function MTH_SetupAspectOptions()
	if not MTH_ZBUTTONS_READY then return end
	MTH_SetupButtonOptions("MetaHuntOptionsAspect", "zButtonAspect", "ZAspect", 7)
end

function MTH_SetupTrapOptions()
	if not MTH_ZBUTTONS_READY then return end
	MTH_SetupButtonOptions("MetaHuntOptionsTrap", "zButtonTrap", "ZTrap", 4)
end

function MTH_SetupAmmoOptions()
	if not MTH_ZBUTTONS_READY then return end
	MTH_EnsureAmmoOptionsWatcher()
	local itemList = MTH_GetButtonItemList("zButtonAmmo")
	local maxButtons = itemList and table.getn(itemList) or 0
	if maxButtons < 1 then
		maxButtons = ZHunterMod_Ammo_Buttons and table.getn(ZHunterMod_Ammo_Buttons) or 11
	end
	MTH_SetupButtonOptions("MetaHuntOptionsAmmo", "zButtonAmmo", "ZAmmo", maxButtons)
end

function MTH_SetupMountsOptions()
	if not MTH_ZBUTTONS_READY then return end
	local itemList = MTH_GetButtonItemList("zButtonMounts")
	local maxButtons = itemList and table.getn(itemList) or 1
	MTH_SetupButtonOptions("MetaHuntOptionsMounts", "zButtonMounts", "ZMounts", maxButtons)
end

function MTH_SetupCompanionsOptions()
	if not MTH_ZBUTTONS_READY then return end
	local itemList = MTH_GetButtonItemList("zButtonCompanions")
	local maxButtons = itemList and table.getn(itemList) or 1
	MTH_SetupButtonOptions("MetaHuntOptionsCompanions", "zButtonCompanions", "ZCompanions", maxButtons)
end

function MTH_SetupToysOptions()
	if not MTH_ZBUTTONS_READY then return end
	local itemList = MTH_GetButtonItemList("zButtonToys")
	local maxButtons = itemList and table.getn(itemList) or 1
	MTH_SetupButtonOptions("MetaHuntOptionsToys", "zButtonToys", "ZToys", maxButtons)
end

function MTH_SetupSmartAmmoOptions()
	if not MTH_ZBUTTONS_READY then return end
	local container = MTH_GetFrame("MetaHuntOptionsSmartAmmo")
	if not container then return end

	MTH_ClearContainer(container)

	local title = container:CreateFontString("MetaHuntOptionsSmartAmmoTitle", "ARTWORK", "GameFontHighlight")
	title:SetPoint("TOPLEFT", container, "TOPLEFT", 20, -10)
	title:SetText("Smart Ammo")

	local body = container:CreateFontString("MetaHuntOptionsSmartAmmoBody", "ARTWORK", "GameFontNormalSmall")
	body:SetPoint("TOPLEFT", container, "TOPLEFT", 20, -38)
	body:SetWidth(390)
	body:SetJustifyH("LEFT")
	body:SetText("Configure Smart Ammo directly from MetaHunt.")

	local moduleToggle = MTH_CreateCheckbox(container, "MetaHuntOptionsSmartAmmoModule", "Enable SmartAmmo Module", -68)
	local moduleEnabled = true
	if MTH and MTH.IsModuleEnabled then
		moduleEnabled = MTH:IsModuleEnabled("smartammo", true) and true or false
	end
	if moduleToggle then
		moduleToggle:SetChecked(moduleEnabled)
		moduleToggle:SetScript("OnClick", function(self)
			self = self or this
			if not self then return end
			if MTH and MTH.SetModuleEnabled then
				MTH:SetModuleEnabled("smartammo", self:GetChecked() and true or false)
			end
			MTH_SetupSmartAmmoOptions()
		end)
	end

	local smartToggle = MTH_CreateCheckbox(container, "MetaHuntOptionsSmartAmmoEnabled", "Enable Smart Ammo Swaps", -94)
	if smartToggle then
		local enabled = type(MTHSmartAmmo_GetSmartEnabled) == "function" and MTHSmartAmmo_GetSmartEnabled() and true or false
		smartToggle:SetChecked(enabled)
		if not moduleEnabled then
			smartToggle:Disable()
		end
		smartToggle:SetScript("OnClick", function(self)
			self = self or this
			if not self then return end
			if type(MTHSmartAmmo_SetSmartEnabled) == "function" then
				MTHSmartAmmo_SetSmartEnabled(self:GetChecked() and 1 or nil)
			end
		end)
	end

	local reloadToggle = MTH_CreateCheckbox(container, "MetaHuntOptionsSmartAmmoReload", "Enable Auto-Fallback", -120)
	if reloadToggle then
		local reloadEnabled = true
		if type(MTHSmartAmmo_GetReloadEnabled) == "function" then
			reloadEnabled = MTHSmartAmmo_GetReloadEnabled() and true or false
		end
		reloadToggle:SetChecked(reloadEnabled)
		if not moduleEnabled then
			reloadToggle:Disable()
		end
		reloadToggle:SetScript("OnClick", function(self)
			self = self or this
			if not self then return end
			if type(MTHSmartAmmo_SetReloadEnabled) == "function" then
				MTHSmartAmmo_SetReloadEnabled(self:GetChecked() and 1 or nil)
			end
		end)
	end
end

function MTH_SetupGeneralOptions()
	if not MTH_ZBUTTONS_READY then return end
	local parentFrame = MTH_GetFrame("MetaHuntOptionsGeneral")
	if not parentFrame then
		return
	end

	MTH_ClearContainer(parentFrame)

	local stripSaved = AutoStrip_GetSaved and AutoStrip_GetSaved() or {}

	local parentWidth = parentFrame:GetWidth() or 0
	if parentWidth < 460 then
		parentWidth = 520
	end

	local gutter = 16
	local colGap = 16
	local colWidth = math.floor((parentWidth - (gutter * 2) - colGap) / 2)
	if colWidth < 220 then
		colWidth = 220
	end

	local leftX = gutter
	local rightX = gutter + colWidth + colGap
	local topY = -8

	local function ensureSection(name, title, yOffset, height, column)
		local section = getglobal(name)
		if not section then
			section = CreateFrame("Frame", name, parentFrame, "OptionFrameBoxTemplate")
		end
		if not section then
			return nil
		end

		section:SetParent(parentFrame)
		section:ClearAllPoints()
		if column == "right" then
			section:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", rightX, yOffset)
		else
			section:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", leftX, yOffset)
		end
		section:SetWidth(colWidth)
		section:SetHeight(height)
		section:Show()

		local titleFrame = getglobal(name .. "Title")
		if titleFrame then
			titleFrame:SetText(title)
		end

		return section
	end

	local function ensureCheckbox(section, name, label, yOffset, checked)
		local check = getglobal(name)
		if not check then
			check = CreateFrame("CheckButton", name, section, "OptionsCheckButtonTemplate")
		end
		if not check then
			return nil
		end

		check:SetParent(section)
		check:ClearAllPoints()
		check:SetPoint("TOPLEFT", section, "TOPLEFT", 12, yOffset)
		check:SetChecked(checked and true or false)
		check:Show()

		local text = getglobal(name .. "Text")
		if text then
			text:SetText(label)
		else
			local lbl = section:CreateFontString(name .. "Text", "ARTWORK", "GameFontNormal")
			lbl:SetPoint("LEFT", check, "RIGHT", 5, 0)
			lbl:SetText(label)
		end

		return check
	end

	local function ensureHelpText(section, name, text, yOffset)
		local help = getglobal(name)
		if not help then
			help = section:CreateFontString(name, "ARTWORK")
			help:SetFont("Fonts\\FRIZQT__.TTF", 10)
			help:SetJustifyH("LEFT")
		end
		help:ClearAllPoints()
		help:SetPoint("TOPLEFT", section, "TOPLEFT", 14, yOffset)
		help:SetWidth(colWidth - 24)
		help:SetText(text)
		help:Show()
	end

	local smartAmmoSection = ensureSection("MetaHuntGeneralSmartAmmoBox", "Smart Ammo", topY, 186, "left")
	if smartAmmoSection then
		local smartModuleEnabled = MTH and MTH.IsModuleEnabled and MTH:IsModuleEnabled("smartammo", true)
		local smartModuleToggle = ensureCheckbox(smartAmmoSection, "MetaHuntGeneralSmartAmmoModuleToggle", "Enable module", -10, smartModuleEnabled)
		if smartModuleToggle then
			smartModuleToggle:SetScript("OnClick", function()
				local enabled = this:GetChecked() and true or false
				if MTH and MTH.SetModuleEnabled then
					local ok = MTH:SetModuleEnabled("smartammo", enabled)
					if not ok then
						this:SetChecked(smartModuleEnabled and true or false)
						return
					end
					smartModuleEnabled = enabled
				end
				MTH_SetupGeneralOptions()
			end)
		end

		ensureHelpText(smartAmmoSection, "MetaHuntGeneralSmartAmmoModuleHelp", "Automatically swaps arrows/bullets based on equipped ranged weapon.", -34)

		local smartEnabled = type(MTHSmartAmmo_GetSmartEnabled) == "function" and MTHSmartAmmo_GetSmartEnabled() and true or false
		local smartToggle = ensureCheckbox(smartAmmoSection, "MetaHuntGeneralSmartAmmoEnabledToggle", "Enable Smart Ammo Swaps", -68, smartEnabled)
		if smartToggle then
			if not smartModuleEnabled then
				smartToggle:Disable()
			end
			smartToggle:SetScript("OnClick", function()
				if type(MTHSmartAmmo_SetSmartEnabled) == "function" then
					MTHSmartAmmo_SetSmartEnabled(this:GetChecked() and 1 or nil)
				end
			end)
		end
		ensureHelpText(smartAmmoSection, "MetaHuntGeneralSmartAmmoEnabledHelp", "Auto-equips arrows or bullets matching your ranged weapon.", -96)

		local reloadEnabled = type(MTHSmartAmmo_GetReloadEnabled) == "function" and MTHSmartAmmo_GetReloadEnabled() and true or false
		local reloadToggle = ensureCheckbox(smartAmmoSection, "MetaHuntGeneralSmartAmmoReloadToggle", "Enable Auto-Fallback", -126, reloadEnabled)
		if reloadToggle then
			if not smartModuleEnabled then
				reloadToggle:Disable()
			end
			reloadToggle:SetScript("OnClick", function()
				if type(MTHSmartAmmo_SetReloadEnabled) == "function" then
					MTHSmartAmmo_SetReloadEnabled(this:GetChecked() and 1 or nil)
				end
			end)
		end
		ensureHelpText(smartAmmoSection, "MetaHuntGeneralSmartAmmoReloadHelp", "Falls back to any available ammo when preferred ammo is missing.", -154)
	end

	local stripSection = ensureSection("MetaHuntGeneralAutoStripBox", "Auto-Strip", topY - 202, 122, "left")
	if stripSection then
		local autoStripToggle = ensureCheckbox(stripSection, "MetaHuntGeneralAutoStripToggle", "Enable Auto-Strip on Combat Exit", -10, stripSaved["autostrip"] and true or false)
		if autoStripToggle then
			autoStripToggle:SetScript("OnClick", function()
				if type(AutoStrip_SetAutoStripToggle) == "function" then
					AutoStrip_SetAutoStripToggle(this:GetChecked())
				end
			end)
		end

		local displayToggle = ensureCheckbox(stripSection, "MetaHuntGeneralAutoStripDisplay", "Show Strip Button", -36, stripSaved["display"] and true or false)
		if displayToggle then
			displayToggle:SetScript("OnClick", function()
				if type(AutoStrip_SetDisplayToggle) == "function" then
					AutoStrip_SetDisplayToggle(this:GetChecked())
				end
			end)
		end

		ensureHelpText(stripSection, "MetaHuntGeneralAutoStripHelp", "Auto-strip unequips items when combat ends. Requires at least one empty bag slot.", -64)
	end

	local antiSection = ensureSection("MetaHuntGeneralAntiDazeBox", "Anti-Daze", topY - 338, 96, "left")
	if antiSection then
		local antiDazeEnabled = (AntiDaze_GetEnabled and AntiDaze_GetEnabled()) or false
		local antiToggle = ensureCheckbox(antiSection, "MetaHuntGeneralAntiDazeToggle", "Enable Anti-Daze", -10, antiDazeEnabled)
		if antiToggle then
			antiToggle:SetScript("OnClick", function()
				local enabled = this:GetChecked() and true or false
				if type(AntiDaze_SetEnabled) == "function" then
					AntiDaze_SetEnabled(enabled, 1)
				end
				if DEFAULT_CHAT_FRAME then
					if MTH and MTH.Print then
						MTH:Print("AntiDaze " .. (enabled and "Enabled." or "Disabled."))
					else
						DEFAULT_CHAT_FRAME:AddMessage("AntiDaze " .. (enabled and "Enabled." or "Disabled."))
					end
				end
			end)
		end

		ensureHelpText(antiSection, "MetaHuntGeneralAntiDazeHelp", "Cancels Cheetah/Pack when dazed.", -40)
	end

	local tooltipsSection = ensureSection("MetaHuntGeneralTooltipsBox", "Tooltips", topY, 356, "right")
	if tooltipsSection then
		local tooltipsStore = MTH and MTH.GetModuleSavedVariables and MTH:GetModuleSavedVariables("tooltips")
		if type(tooltipsStore) ~= "table" then
			tooltipsStore = {}
		end
		if tooltipsStore.beastTooltips == nil then
			tooltipsStore.beastTooltips = true
		end
		if tooltipsStore.ammoVendorTooltips == nil then
			tooltipsStore.ammoVendorTooltips = true
		end
		if tooltipsStore.foodItemTooltips == nil then
			if type(FOM_Config) == "table" and FOM_Config.Tooltip ~= nil then
				tooltipsStore.foodItemTooltips = FOM_Config.Tooltip and true or false
			else
				tooltipsStore.foodItemTooltips = true
			end
		end
		if tooltipsStore.ownPetTooltips == nil then
			tooltipsStore.ownPetTooltips = false
		end

		local moduleEnabled = MTH and MTH.IsModuleEnabled and MTH:IsModuleEnabled("tooltips", true)
		local foodLabel = (MTH and MTH.GetLocalization and MTH:GetLocalization("TOOLTIPS_OPTION_FOOD", "Activate on food")) or "Activate on food on food"
		local foodHelp = (MTH and MTH.GetLocalization and MTH:GetLocalization("TOOLTIPS_OPTION_FOOD_HELP", "Show your current pet's food preference directly in item tooltips.")) or "Show your current pet's food preference directly in item tooltips."

		local moduleToggle = ensureCheckbox(tooltipsSection, "MetaHuntGeneralTooltipsModuleToggle", "Enable module", -10, moduleEnabled)
		if moduleToggle then
			moduleToggle:SetScript("OnClick", function()
				local enabled = this:GetChecked() and true or false
				if MTH and MTH.SetModuleEnabled then
					local ok = MTH:SetModuleEnabled("tooltips", enabled)
					if not ok then
						this:SetChecked(moduleEnabled and true or false)
						return
					end
					moduleEnabled = enabled
				end
			end)
		end

		ensureHelpText(tooltipsSection, "MetaHuntGeneralTooltipsModuleHelp", "This module allows to enhance NPC tooltips with additional information useful for hunters.", -34)

		local beastToggle = ensureCheckbox(tooltipsSection, "MetaHuntGeneralTooltipsBeastToggle", "Activate on Beasts", -86, tooltipsStore.beastTooltips and true or false)
		if beastToggle then
			beastToggle:SetScript("OnClick", function()
				local enabled = this:GetChecked() and true or false
				tooltipsStore.beastTooltips = enabled
				local tooltipsModule = MTH and MTH.GetModule and MTH:GetModule("tooltips")
				if tooltipsModule and tooltipsModule.SetBeastTooltipsEnabled then
					tooltipsModule:SetBeastTooltipsEnabled(enabled)
				end
			end)
		end

		ensureHelpText(tooltipsSection, "MetaHuntGeneralTooltipsBeastHelp", "When mouseover on a Beast, its tooltip will show if it can learn you any pet abilities. They appear Green if you already know them, and Red if you don't know them yet.", -110)

		local ownPetLabel = (MTH and MTH.GetLocalization and MTH:GetLocalization("TOOLTIPS_OPTION_OWNPET", "Activate on my pet")) or "Activate on my pet"
		local ownPetHelp = (MTH and MTH.GetLocalization and MTH:GetLocalization("TOOLTIPS_OPTION_OWNPET_HELP", "Show your own pet status details in tooltip when hovering your pet context.")) or "Show your own pet status details in tooltip when hovering your pet context."
		local ownPetToggle = ensureCheckbox(tooltipsSection, "MetaHuntGeneralTooltipsOwnPetToggle", ownPetLabel, -158, tooltipsStore.ownPetTooltips and true or false)
		if ownPetToggle then
			ownPetToggle:SetScript("OnClick", function()
				local enabled = this:GetChecked() and true or false
				tooltipsStore.ownPetTooltips = enabled
				local tooltipsModule = MTH and MTH.GetModule and MTH:GetModule("tooltips")
				if tooltipsModule and tooltipsModule.SetOwnPetTooltipsEnabled then
					tooltipsModule:SetOwnPetTooltipsEnabled(enabled)
				end
			end)
		end

		ensureHelpText(tooltipsSection, "MetaHuntGeneralTooltipsOwnPetHelp", ownPetHelp, -182)

		local ammoToggle = ensureCheckbox(tooltipsSection, "MetaHuntGeneralTooltipsAmmoVendorToggle", "Activate on Vendors", -222, tooltipsStore.ammoVendorTooltips and true or false)
		if ammoToggle then
			ammoToggle:SetScript("OnClick", function()
				local enabled = this:GetChecked() and true or false
				tooltipsStore.ammoVendorTooltips = enabled
				local tooltipsModule = MTH and MTH.GetModule and MTH:GetModule("tooltips")
				if tooltipsModule and tooltipsModule.SetAmmoVendorTooltipsEnabled then
					tooltipsModule:SetAmmoVendorTooltipsEnabled(enabled)
				end
			end)
		end

		ensureHelpText(tooltipsSection, "MetaHuntGeneralTooltipsVendorHelp", "When mouseover on a vendor, its tooltip will tell if it sells Arrows and/or Bullets.", -246)

		local foodToggle = ensureCheckbox(tooltipsSection, "MetaHuntGeneralTooltipsFoodToggle", foodLabel, -274, tooltipsStore.foodItemTooltips and true or false)
		if foodToggle then
			foodToggle:SetScript("OnClick", function()
				local enabled = this:GetChecked() and true or false
				tooltipsStore.foodItemTooltips = enabled
				local tooltipsModule = MTH and MTH.GetModule and MTH:GetModule("tooltips")
				if tooltipsModule and tooltipsModule.SetFoodItemTooltipsEnabled then
					tooltipsModule:SetFoodItemTooltipsEnabled(enabled)
				end
			end)
		end

		ensureHelpText(tooltipsSection, "MetaHuntGeneralTooltipsFoodHelp", foodHelp, -298)
	end

end
