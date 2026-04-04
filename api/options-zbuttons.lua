local MTH_ZBUTTONS_READY = MTH_OptionsRequire and MTH_OptionsRequire("options-zbuttons", {
	"MTH_GetFrame",
	"MTH_CreateSlider",
	"MTH_CreateCheckbox",
	"MTH_ClearContainer",
	"MTH_CreateActionButton",
})

local function MTH_ZB_L(key, default)
	if MTH and MTH.GetLocalization then
		return MTH:GetLocalization(key, default)
	end
	return default or key
end

local function MTH_ZB_RefreshTab(tabName)
	if type(MTH_ResetAndSelectOptionsTab) == "function" then
		MTH_ResetAndSelectOptionsTab(tabName)
	elseif type(MTH_SelectOptionsTab) == "function" then
		MTH_SelectOptionsTab(tabName)
	end
end

local function MTH_ZB_IsChecked(control)
	if not control or type(control.GetChecked) ~= "function" then
		return false
	end
	local checked = control:GetChecked()
	return checked == 1 or checked == true
end

local function MTH_RebuildSpellOrder(buttonName, buttonObj, itemList, maxButtons)
	if not (buttonName and buttonObj and itemList and maxButtons) then return end
	local info = {}
	local visible = ZHunterMod_Saved[buttonName]["visible"] or {}
	local infoIndex = 1
	for i = 1, maxButtons do
		local spellIndex = ZHunterMod_Saved[buttonName]["spells"][i]
		if spellIndex and visible[spellIndex] ~= false then
			-- String-based lists (zCraft) store names directly; numeric lists index into itemList
			local name = (type(spellIndex) == "number") and itemList[spellIndex] or spellIndex
			info[infoIndex] = name
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
	if resolvedButtonObj then
		if not enabled then
			if resolvedButtonObj.Hide then resolvedButtonObj:Hide() end
			if resolvedButtonObj.count and resolvedButtonObj.name then
				for i = 1, resolvedButtonObj.count do
					local child = getglobal(resolvedButtonObj.name .. i)
					if child and child.Hide then child:Hide() end
				end
			end
		elseif ZHunterMod_Saved[buttonName]["parent"] and ZHunterMod_Saved[buttonName]["parent"]["hide"] then
			if resolvedButtonObj.Hide then resolvedButtonObj:Hide() end
		else
			if resolvedButtonObj.Show then resolvedButtonObj:Show() end
			MTH_RefreshButtonGeometry(buttonName, resolvedButtonObj)
		end
	end
	-- If zBar is active, re-apply its layout so this button is included/excluded.
	-- When re-enabling a button, also un-exclude it from the bar so it appears
	-- in the bar rather than as a standalone button.
	if type(MTH_ZBar_GetSaved) == "function" then
		local zs = MTH_ZBar_GetSaved()
		if enabled and zs.visible[buttonName] == false then
			zs.visible[buttonName] = true
		end
		if zs.enabled and type(MTH_ZBar_ApplyLayout) == "function" then
			MTH_ZBar_ApplyLayout()
		end
	end
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
	elseif buttonName == "zButtonRanged" then
		local rangedList = getglobal("ZHunterMod_Ranged_Weapons")
		if rangedList and table.getn(rangedList) > 0 then
			return rangedList
		end
	elseif buttonName == "zButtonMounts" or buttonName == "zButtonCompanions" or buttonName == "zButtonToys" or buttonName == "zButtonCraft" then
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
	MTH_AmmoOptionsWatcher = CreateFrame("Frame", "MTH_AmmoOptionsWatcher")
	if not MTH_AmmoOptionsWatcher then
		return
	end
	MTH_AmmoOptionsWatcher:RegisterEvent("UNIT_INVENTORY_CHANGED")
	MTH_AmmoOptionsWatcher:RegisterEvent("BAG_UPDATE")
	MTH_AmmoOptionsWatcher:SetScript("OnEvent", function()
		local eventName = event
		local unit = arg1
		if eventName == "UNIT_INVENTORY_CHANGED" and unit and unit ~= "player" then
			return
		end
		MTH_RefreshAmmoOptionsIfVisible()
	end)
end

local function MTH_ZB_GetDefaultEnabled(buttonName)
	if buttonName == "zButtonMounts" or buttonName == "zButtonCompanions" or buttonName == "zButtonToys" or buttonName == "zButtonCraft" or buttonName == "zButtonRanged" then
		return false
	end
	return true
end

local function MTH_ZB_EnsureButtonOptionDefaults(buttonName)
	if not (ZHunterMod_Saved and buttonName) then
		return nil
	end

	if type(ZHunterMod_Saved[buttonName]) ~= "table" then
		ZHunterMod_Saved[buttonName] = {}
	end

	local saved = ZHunterMod_Saved[buttonName]

	if saved["enabled"] == nil then
		saved["enabled"] = MTH_ZB_GetDefaultEnabled(buttonName)
	end
	saved["enabled"] = saved["enabled"] and true or false

	if saved["tooltip"] == nil then
		saved["tooltip"] = true
	end
	saved["tooltip"] = saved["tooltip"] and true or false

	if type(saved["children"]) ~= "table" then
		saved["children"] = {}
	end
	if saved["children"]["hideonclick"] == nil then
		saved["children"]["hideonclick"] = true
	end
	saved["children"]["hideonclick"] = saved["children"]["hideonclick"] and true or false

	if saved["children"]["expandonhover"] == nil then
		saved["children"]["expandonhover"] = false
	end
	saved["children"]["expandonhover"] = saved["children"]["expandonhover"] and true or false

	if saved["children"]["fadetimer"] == nil then
		saved["children"]["fadetimer"] = 0
	end
	saved["children"]["fadetimer"] = tonumber(saved["children"]["fadetimer"]) or 0

	if type(saved["parent"]) ~= "table" then
		saved["parent"] = {}
	end
	if saved["parent"]["hide"] == nil then
		saved["parent"]["hide"] = false
	end
	saved["parent"]["hide"] = saved["parent"]["hide"] and true or false
	if saved["parent"]["circle"] == nil then
		saved["parent"]["circle"] = true
	end
	saved["parent"]["circle"] = saved["parent"]["circle"] and true or false

	if buttonName == "zButtonAspect" or buttonName == "zButtonTrack" or buttonName == "zButtonPet" then
		if saved["parent"]["smart"] == nil then
			saved["parent"]["smart"] = true
		end
		saved["parent"]["smart"] = saved["parent"]["smart"] and true or false
	end

	if buttonName == "zButtonMounts" or buttonName == "zButtonCompanions" then
		if saved["parent"]["random"] == nil then
			saved["parent"]["random"] = false
		end
		saved["parent"]["random"] = saved["parent"]["random"] and true or false
	end

	if buttonName == "zButtonMounts" then
		if saved["parent"]["aqfilter"] == nil then
			saved["parent"]["aqfilter"] = true
		end
		saved["parent"]["aqfilter"] = saved["parent"]["aqfilter"] and true or false
	end

	if saved["firstbutton"] ~= "LEFT" and saved["firstbutton"] ~= "RIGHT" then
		saved["firstbutton"] = "RIGHT"
	end

	if buttonName == "zButtonAmmo" then
		if saved["showammoname"] == nil then
			saved["showammoname"] = true
		end
		saved["showammoname"] = saved["showammoname"] and true or false
	end

	return saved
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
		errText:SetText(string.format(MTH_ZB_L("ZB_ERR_CONFIG_NOT_LOADED", "Configuration not loaded for %s"), tostring(displayName)))
		errText:SetTextColor(1, 0.5, 0.5)
		if MTH and MTH.Print then
			MTH:Print("[MTH] zhunter saved data missing for "..buttonName, "error")
		end
		return
	end

	local buttonObj = getglobal(buttonName)
	local saved = MTH_ZB_EnsureButtonOptionDefaults(buttonName)
	if not saved then
		return
	end
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

	local enabledValue = saved["enabled"] and true or false
	local enableLabel = tostring(displayName or "")
	if string.len(enableLabel) > 0 then
		enableLabel = string.lower(string.sub(enableLabel, 1, 1)) .. string.sub(enableLabel, 2)
	end

	local enableButton = MTH_CreateCheckbox(container, containerName.."EnableButton", string.format(MTH_ZB_L("ZB_LABEL_ENABLE_FMT", "Enable %s"), enableLabel), -8)
	if enableButton then
		enableButton:SetChecked(enabledValue and true or false)
		enableButton.buttonName = buttonName
		enableButton.buttonObj = buttonObj
		enableButton:SetScript("OnClick", function()
			if not this then return end
			local checked = MTH_ZB_IsChecked(this)
			MTH_SetButtonEnabledState(this.buttonName, this.buttonObj, checked)
		end)
	end

	local parentSectionHeight = 116
	if buttonName == "zButtonAspect" or buttonName == "zButtonTrack" or buttonName == "zButtonPet" then
		parentSectionHeight = 200
	elseif buttonName == "zButtonMounts" then
		parentSectionHeight = 225
	elseif buttonName == "zButtonCompanions" then
		parentSectionHeight = 196
	end
	local childrenSectionY = -52 - parentSectionHeight - 16
	local parentSection = MTH_ZB_EnsureSection(containerName.."ParentSection", MTH_ZB_L("ZB_SECTION_PARENT_BUTTON", "Parent Button"), -52, parentSectionHeight)
	local childrenSection = MTH_ZB_EnsureSection(containerName.."ChildrenSection", MTH_ZB_L("ZB_SECTION_CHILDREN_BUTTONS", "Children Buttons"), childrenSectionY, 290)

	local parentYOffset = -18
	local childrenYOffset = -18

	local btnSize = MTH_CreateSlider(childrenSection or container, containerName.."ButtonSize", MTH_ZB_L("ZB_LABEL_BUTTON_SIZE", "Button Size"), 10, 100, 1, childrenYOffset)
	if btnSize then
		btnSize:SetWidth(leftWidth - 40)
		btnSize:SetValue(saved["children"]["size"] or 36)
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

	local rowCount = MTH_CreateSlider(childrenSection or container, containerName.."RowCount", MTH_ZB_L("ZB_LABEL_NUMBER_OF_ROWS", "Number of Rows"), 1, maxButtons, 1, childrenYOffset)
	if rowCount then
		rowCount:SetWidth(leftWidth - 40)
		rowCount:SetValue(saved["rows"] or 1)
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

	local expandLeft = MTH_CreateCheckbox(childrenSection or container, containerName.."ExpandLeft", MTH_ZB_L("ZB_LABEL_EXPAND_LEFT", "Expand Left (opposite side)"), childrenYOffset)
	if expandLeft then
		expandLeft:SetChecked(saved["firstbutton"] == "LEFT")
		expandLeft.buttonName = buttonName
		expandLeft.buttonObj = buttonObj
		expandLeft:SetScript("OnClick", function()
			if not this then return end
			local checked = MTH_ZB_IsChecked(this)
			local btnName = this.buttonName
			if not btnName or not (ZHunterMod_Saved and ZHunterMod_Saved[btnName]) then return end
			ZHunterMod_Saved[btnName]["firstbutton"] = checked and "LEFT" or "RIGHT"
			ZHunterMod_Saved[btnName]["horizontal"] = checked and 1 or nil
			ZHunterMod_Saved[btnName]["vertical"] = checked and 1 or nil
			MTH_RefreshButtonGeometry(btnName, this.buttonObj)
		end)
	end
	childrenYOffset = childrenYOffset - 30

	local hideClick = MTH_CreateCheckbox(childrenSection or container, containerName.."HideOnClick", MTH_ZB_L("ZB_LABEL_HIDE_BUTTONS_ON_CLICK", "Hide Buttons On Click"), childrenYOffset)
	if hideClick then
		hideClick:SetChecked(saved["children"]["hideonclick"])
		hideClick.buttonName = buttonName
		hideClick.buttonObj = buttonObj
		if hideClick.buttonObj then
			hideClick.buttonObj.hideonclick = saved["children"]["hideonclick"] and true or false
		end
		hideClick:SetScript("OnClick", function()
			if not this then return end
			local checked = MTH_ZB_IsChecked(this)
			ZHunterMod_Saved[this.buttonName]["children"]["hideonclick"] = checked
			local btnObj = this.buttonObj or getglobal(this.buttonName)
			if btnObj then btnObj.hideonclick = checked end
		end)
	end
	childrenYOffset = childrenYOffset - 25

	local expandOnHover = MTH_CreateCheckbox(childrenSection or container, containerName.."ExpandOnHover", MTH_ZB_L("ZB_LABEL_EXPAND_ON_HOVER", "Expand on Hover"), childrenYOffset)
	if expandOnHover then
		expandOnHover:SetChecked(saved["children"]["expandonhover"])
		expandOnHover.buttonName = buttonName
		expandOnHover.buttonObj = buttonObj
		expandOnHover:SetScript("OnClick", function()
			if not this then return end
			local checked = MTH_ZB_IsChecked(this)
			local btnName = this.buttonName
			if not btnName or not (ZHunterMod_Saved and ZHunterMod_Saved[btnName]) then return end
			if not ZHunterMod_Saved[btnName]["children"] then
				ZHunterMod_Saved[btnName]["children"] = {}
			end
			ZHunterMod_Saved[btnName]["children"]["expandonhover"] = checked
			local btnObj = this.buttonObj or getglobal(btnName)
			if btnObj then btnObj.expandonhover = checked end
		end)
	end
	childrenYOffset = childrenYOffset - 40

	local fadeTimer = MTH_CreateSlider(childrenSection or container, containerName.."FadeTimer", MTH_ZB_L("ZB_LABEL_AUTO_HIDE_TIMER", "Auto-Hide Timer (seconds)"), 0, 10, 1, childrenYOffset)
	if fadeTimer then
		fadeTimer:SetWidth(leftWidth - 40)
		fadeTimer:SetValue(saved["children"]["fadetimer"] or 0)
		fadeTimer.buttonName = buttonName
		fadeTimer.buttonObj = buttonObj
		fadeTimer.onChange = function(val, slider)
			local frame = slider or fadeTimer
			local btnName = frame and frame.buttonName
			if not btnName or not (ZHunterMod_Saved and ZHunterMod_Saved[btnName]) then return end
			if not ZHunterMod_Saved[btnName]["children"] then
				ZHunterMod_Saved[btnName]["children"] = {}
			end
			local secs = math.floor((val or 0) + 0.5)
			ZHunterMod_Saved[btnName]["children"]["fadetimer"] = secs
			local btnObj = frame.buttonObj or getglobal(btnName)
			if btnObj then
				btnObj.fadetimer = secs
				if secs <= 0 then
					ZSpellButton_StopFadeTimer(btnObj)
				elseif btnObj.children and btnObj.children:IsVisible() then
					ZSpellButton_StartFadeTimer(btnObj)
				end
			end
		end
	end
	childrenYOffset = childrenYOffset - 40

	local showTooltip = MTH_CreateCheckbox(childrenSection or container, containerName.."ShowTooltip", MTH_ZB_L("ZB_LABEL_SHOW_TOOLTIP", "Show Tooltip"), childrenYOffset)
	if showTooltip then
		showTooltip:SetChecked(saved["tooltip"])
		showTooltip.buttonName = buttonName
		showTooltip.buttonObj = buttonObj
		if showTooltip.buttonObj then
			showTooltip.buttonObj.tooltip = saved["tooltip"] and true or false
		end
		showTooltip:SetScript("OnClick", function()
			if not this then return end
			local checked = MTH_ZB_IsChecked(this)
			ZHunterMod_Saved[this.buttonName]["tooltip"] = checked
			local btnObj = this.buttonObj or getglobal(this.buttonName)
			if btnObj then btnObj.tooltip = checked end
		end)
	end
	childrenYOffset = childrenYOffset - 20

	if buttonName == "zButtonAmmo" then
		local showAmmoName = MTH_CreateCheckbox(childrenSection or container, containerName.."ShowAmmoName", MTH_ZB_L("ZB_LABEL_SHOW_AMMO_NAME", "Show ammo name"), childrenYOffset)
		if showAmmoName then
			showAmmoName:SetChecked(saved["showammoname"])
			showAmmoName.buttonName = buttonName
			showAmmoName.buttonObj = buttonObj
			showAmmoName.maxButtons = maxButtons
			showAmmoName:SetScript("OnClick", function()
				if not this then return end
				local checked = MTH_ZB_IsChecked(this)
				local btnName = this.buttonName
				ZHunterMod_Saved[btnName]["showammoname"] = checked
				local btnObj = this.buttonObj or getglobal(btnName)
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
		childrenYOffset = childrenYOffset - 25
	else
		childrenYOffset = childrenYOffset - 25
	end

	local mainSize = MTH_CreateSlider(parentSection or container, containerName.."MainButtonSize", MTH_ZB_L("ZB_LABEL_BUTTON_SIZE", "Button Size"), 10, 100, 1, parentYOffset)
	if mainSize then
		mainSize:SetWidth(leftWidth - 40)
		mainSize:SetValue(saved["parent"]["size"] or 36)
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

	local hideButton = MTH_CreateCheckbox(parentSection or container, containerName.."HideButton", MTH_ZB_L("ZB_LABEL_HIDE_BUTTON", "Hide Button"), parentYOffset)
	if hideButton then
		hideButton:SetChecked(saved["parent"]["hide"])
		hideButton.buttonName = buttonName
		hideButton.buttonObj = buttonObj
		hideButton:SetScript("OnClick", function()
			if not this then return end
			local checked = this:GetChecked() == 1
			ZHunterMod_Saved[this.buttonName]["parent"]["hide"] = checked
			if this.buttonObj then
				if checked then this.buttonObj:Hide() else this.buttonObj:Show() end
			end
		end)
	end
	parentYOffset = parentYOffset - 25

	local useCircle = MTH_CreateCheckbox(parentSection or container, containerName.."UseCircle", MTH_ZB_L("ZB_LABEL_USE_CIRCLE_BUTTON", "Use Circle Button"), parentYOffset)
	if useCircle then
		useCircle:SetChecked(saved["parent"]["circle"])
		useCircle.buttonName = buttonName
		useCircle.buttonObj = buttonObj
		useCircle:SetScript("OnClick", function()
			if not this then return end
			local checked = this:GetChecked() == 1
			ZHunterMod_Saved[this.buttonName]["parent"]["circle"] = checked
			if this.buttonObj and this.buttonObj.circle then
				if checked then this.buttonObj.circle:Show() else this.buttonObj.circle:Hide() end
			end
		end)
	end

	-- Smart Parent: Aspect/Track/Pet
	if buttonName == "zButtonAspect" or buttonName == "zButtonTrack" or buttonName == "zButtonPet" then
		parentYOffset = parentYOffset - 25
		local smartParent = MTH_CreateCheckbox(parentSection or container, containerName.."SmartParent", MTH_ZB_L("ZB_LABEL_SMART_PARENT", "Smart Parent"), parentYOffset)
		if smartParent then
			smartParent:SetChecked(saved["parent"]["smart"])
			smartParent.buttonName = buttonName
			smartParent.buttonObj = buttonObj
			smartParent:SetScript("OnClick", function()
				if not this then return end
				local checked = this:GetChecked() == 1
				ZHunterMod_Saved[this.buttonName]["parent"]["smart"] = checked
				local btn = this.buttonObj or getglobal(this.buttonName)
				if btn then
					if not checked then
						local firstChild = getglobal(this.buttonName .. "1")
						if firstChild and firstChild.id then
							btn.id = firstChild.id
							ZSpellButton_UpdateButton(btn)
							ZSpellButton_UpdateCooldown(btn)
						end
					else
						local setupFunc = getglobal(this.buttonName .. "_SetupSizeAndPosition")
						if type(setupFunc) == "function" then
							setupFunc()
						end
					end
				end
			end)
		end
		local smartDescText
		if buttonName == "zButtonAspect" then
			smartDescText = "When ON, the parent toggles between your 1st and 2nd aspect. If the 1st is active, the parent shows the 2nd and vice-versa. Useful for quickly swapping between two aspects in combat. When OFF, the parent always shows the 1st aspect."
		elseif buttonName == "zButtonTrack" then
			smartDescText = "When ON, the parent toggles between your 1st and 2nd tracking. If the 1st is active, the parent shows the 2nd and vice-versa. Great for PvP to swap between Track Hidden and Track Humanoids. When OFF, the parent always shows the 1st tracking."
		elseif buttonName == "zButtonPet" then
			smartDescText = "When ON, the parent dynamically changes based on your pet state: Revive if dead, Mend if hurt, Feed if unhappy, or your default spell otherwise. When OFF, the parent always shows the 1st spell."
		else
			smartDescText = "Dynamically swap the parent icon based on context."
		end
		local smartDesc = (parentSection or container):CreateFontString(containerName.."SmartParentDesc", "ARTWORK", "GameFontNormalSmall")
		smartDesc:SetPoint("TOPLEFT", parentSection or container, "TOPLEFT", 40, parentYOffset - 24)
		smartDesc:SetWidth(leftWidth - 50)
		smartDesc:SetJustifyH("LEFT")
		smartDesc:SetText(smartDescText)
		smartDesc:SetTextColor(0.5, 0.7, 1.0)
	end

	-- Random Parent: Mounts/Companions
	if buttonName == "zButtonMounts" or buttonName == "zButtonCompanions" then
		parentYOffset = parentYOffset - 25
		local randomParent = MTH_CreateCheckbox(parentSection or container, containerName.."RandomParent", MTH_ZB_L("ZB_LABEL_RANDOM_PARENT", "Random Parent"), parentYOffset)
		if randomParent then
			randomParent:SetChecked(saved["parent"]["random"])
			randomParent.buttonName = buttonName
			randomParent.buttonObj = buttonObj
			randomParent:SetScript("OnClick", function()
				if not this then return end
				local checked = this:GetChecked() == 1
				ZHunterMod_Saved[this.buttonName]["parent"]["random"] = checked
			end)
		end
		local randomDesc = (parentSection or container):CreateFontString(containerName.."RandomParentDesc", "ARTWORK", "GameFontNormalSmall")
		randomDesc:SetPoint("TOPLEFT", parentSection or container, "TOPLEFT", 40, parentYOffset - 24)
		randomDesc:SetWidth(leftWidth - 50)
		randomDesc:SetJustifyH("LEFT")
		randomDesc:SetText(MTH_ZB_L("ZB_DESC_RANDOM_PARENT", "Pick a random child as parent on each login and after each use."))
		randomDesc:SetTextColor(0.5, 0.7, 1.0)
	end

	-- AQ Mount Filter: Mounts only
	if buttonName == "zButtonMounts" then
		parentYOffset = parentYOffset - 45
		local aqFilter = MTH_CreateCheckbox(parentSection or container, containerName.."AQFilter", MTH_ZB_L("ZB_LABEL_AQ_FILTER", "AQ Mount Filter"), parentYOffset)
		if aqFilter then
			aqFilter:SetChecked(saved["parent"]["aqfilter"])
			aqFilter.buttonName = buttonName
			aqFilter.buttonObj = buttonObj
			aqFilter:SetScript("OnClick", function()
				if not this then return end
				local checked = this:GetChecked() == 1
				ZHunterMod_Saved[this.buttonName]["parent"]["aqfilter"] = checked
			end)
		end
		local aqDesc = (parentSection or container):CreateFontString(containerName.."AQFilterDesc", "ARTWORK", "GameFontNormalSmall")
		aqDesc:SetPoint("TOPLEFT", parentSection or container, "TOPLEFT", 40, parentYOffset - 24)
		aqDesc:SetWidth(leftWidth - 50)
		aqDesc:SetJustifyH("LEFT")
		aqDesc:SetText(MTH_ZB_L("ZB_DESC_AQ_FILTER", "Hide Qiraji mounts outside AQ40. Show only Qiraji inside."))
		aqDesc:SetTextColor(0.5, 0.7, 1.0)
	end

	MTH_SetButtonEnabledState(buttonName, buttonObj, saved["enabled"] and true or false)

	local advHeader = container:CreateFontString(containerName.."AdvHeader", "ARTWORK", "GameFontHighlight")
	advHeader:SetPoint("TOPLEFT", container, "TOPLEFT", rightX, -10)
	advHeader:SetText(MTH_ZB_L("ZB_HEADER_SPELL_ORDER", "Spell Order"))

	local itemList = MTH_GetButtonItemList(buttonName)

	if not itemList or not ZHunterMod_Saved[buttonName]["spells"] then
		local noData = container:CreateFontString(containerName.."NoData", "ARTWORK", "GameFontNormalSmall")
		noData:SetPoint("TOPRIGHT", container, "TOPRIGHT", -80, -50)
		noData:SetText(MTH_ZB_L("ZB_TEXT_SPELL_DATA_NOT_LOADED", "Spell data not loaded"))
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
			showToggle:SetScript("OnClick", function()
				if not this then return end
				local checked = this:GetChecked() == 1
				local btnName = this.buttonName
				local visibleIndex = this.spellIndex
				if not ZHunterMod_Saved[btnName]["visible"] then
					ZHunterMod_Saved[btnName]["visible"] = {}
				end
				ZHunterMod_Saved[btnName]["visible"][visibleIndex] = checked
				MTH_RefreshButtonLayout(btnName, this.buttonObj, this.itemList, this.maxButtons)
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
		downBtn:SetScript("OnClick", function()
			if not this then return end
			local idx = this.spellIndex
			local btnName = this.buttonName
			local contName = this.containerName
			local maxBtns = this.maxButtons
			if idx < maxBtns then
				local temp = ZHunterMod_Saved[btnName]["spells"][idx+1]
				ZHunterMod_Saved[btnName]["spells"][idx+1] = ZHunterMod_Saved[btnName]["spells"][idx]
				ZHunterMod_Saved[btnName]["spells"][idx] = temp
				MTH_RebuildSpellOrder(btnName, this.buttonObj, this.itemList, this.maxButtons)
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
		upBtn:SetScript("OnClick", function()
			if not this then return end
			local idx = this.spellIndex
			local btnName = this.buttonName
			local contName = this.containerName
			if idx > 1 then
				local temp = ZHunterMod_Saved[btnName]["spells"][idx-1]
				ZHunterMod_Saved[btnName]["spells"][idx-1] = ZHunterMod_Saved[btnName]["spells"][idx]
				ZHunterMod_Saved[btnName]["spells"][idx] = temp
				MTH_RebuildSpellOrder(btnName, this.buttonObj, this.itemList, this.maxButtons)
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

-- ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
-- zBar options
-- ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

function MTH_SetupZBarOptions()
	if not MTH_ZBUTTONS_READY then return end
	local container = MTH_GetFrame("MetaHuntOptionsZBar")
	if not container then return end
	MTH_ClearContainer(container)

	if type(MTH_ZBar_GetSaved) ~= "function" then
		local err = container:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		err:SetPoint("CENTER", container, "CENTER", 0, 0)
		err:SetText("zBar module not loaded")
		err:SetTextColor(1, 0.5, 0.5)
		return
	end

	local s               = MTH_ZBar_GetSaved()
	local containerWidth  = container:GetWidth() or 500
	local leftWidth       = 260
	local rightX          = leftWidth + 44
	local rightWidth      = containerWidth - rightX - 12

	-- ===== Enable checkbox =====
	local enableBtn = MTH_CreateCheckbox(container, "MetaHuntOptionsZBarEnable",
		"Enable zBar — group all zButtons into a single draggable bar", -8)
	if enableBtn then
		enableBtn:SetChecked(s.enabled and true or false)
		enableBtn:SetScript("OnClick", function()
			if type(MTH_ZBar_SetEnabled) == "function" then
				MTH_ZBar_SetEnabled(this:GetChecked() == 1)
			end
		end)
	end

	-- ===== Direction header =====
	local dirLabel = container:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	dirLabel:SetPoint("TOPLEFT", container, "TOPLEFT", 16, -46)
	dirLabel:SetText("Bar Direction")

	-- ===== Horizontal radio =====
	local horizBtn = MTH_CreateCheckbox(container, "MetaHuntOptionsZBarHoriz",
		"Horizontal (side by side)", -64)
	if horizBtn then
		horizBtn:SetChecked(s.direction ~= "VERTICAL")
		horizBtn:SetScript("OnClick", function()
			if this:GetChecked() == 1 then
				local sv = MTH_ZBar_GetSaved()
				sv.direction = "HORIZONTAL"
				-- Auto-correct childexpand to a valid side for a horizontal bar
				if sv.childexpand ~= "TOP" and sv.childexpand ~= "BOTTOM" then
					sv.childexpand = "BOTTOM"
				end
				local v = getglobal("MetaHuntOptionsZBarVert")
				if v then v:SetChecked(false) end
				if sv.enabled and type(MTH_ZBar_ApplyLayout) == "function" then
					MTH_ZBar_ApplyLayout()
				end
				MTH_ResetAndSelectOptionsTab("ZBar")
			else
				this:SetChecked(true)
			end
		end)
	end

	-- ===== Vertical radio =====
	local vertBtn = MTH_CreateCheckbox(container, "MetaHuntOptionsZBarVert",
		"Vertical (stacked)", -90)
	if vertBtn then
		vertBtn:SetChecked(s.direction == "VERTICAL")
		vertBtn:SetScript("OnClick", function()
			if this:GetChecked() == 1 then
				local sv = MTH_ZBar_GetSaved()
				sv.direction = "VERTICAL"
				-- Auto-correct childexpand to a valid side for a vertical bar
				if sv.childexpand ~= "LEFT" and sv.childexpand ~= "RIGHT" then
					sv.childexpand = "RIGHT"
				end
				local h = getglobal("MetaHuntOptionsZBarHoriz")
				if h then h:SetChecked(false) end
				if sv.enabled and type(MTH_ZBar_ApplyLayout) == "function" then
					MTH_ZBar_ApplyLayout()
				end
				MTH_ResetAndSelectOptionsTab("ZBar")
			else
				this:SetChecked(true)
			end
		end)
	end

	-- ===== Children expand side (contextual to bar direction) =====
	local expandLbl = container:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	expandLbl:SetPoint("TOPLEFT", container, "TOPLEFT", 16, -120)
	if s.direction == "VERTICAL" then
		expandLbl:SetText("Children expand side (Vertical bar):")
	else
		expandLbl:SetText("Children expand side (Horizontal bar):")
	end

	local exp1Val, exp2Val, exp1Lbl, exp2Lbl
	if s.direction == "VERTICAL" then
		exp1Val = "LEFT"  ; exp1Lbl = "Left"
		exp2Val = "RIGHT" ; exp2Lbl = "Right"
	else
		exp1Val = "TOP"    ; exp1Lbl = "Top (above)"
		exp2Val = "BOTTOM" ; exp2Lbl = "Bottom (below)"
	end

	local exp1Btn = MTH_CreateCheckbox(container, "MetaHuntOptionsZBarExp1", exp1Lbl, -138, 30)
	if exp1Btn then
		exp1Btn:SetChecked(s.childexpand == exp1Val)
		exp1Btn.zbarVal = exp1Val
		exp1Btn:SetScript("OnClick", function()
			if this:GetChecked() == 1 then
				local sv = MTH_ZBar_GetSaved()
				sv.childexpand = this.zbarVal
				if sv.enabled and type(MTH_ZBar_ApplyLayout) == "function" then MTH_ZBar_ApplyLayout() end
				MTH_ResetAndSelectOptionsTab("ZBar")
			else
				this:SetChecked(true)
			end
		end)
	end

	local exp2Btn = MTH_CreateCheckbox(container, "MetaHuntOptionsZBarExp2", exp2Lbl, -164, 30)
	if exp2Btn then
		exp2Btn:SetChecked(s.childexpand == exp2Val)
		exp2Btn.zbarVal = exp2Val
		exp2Btn:SetScript("OnClick", function()
			if this:GetChecked() == 1 then
				local sv = MTH_ZBar_GetSaved()
				sv.childexpand = this.zbarVal
				if sv.enabled and type(MTH_ZBar_ApplyLayout) == "function" then MTH_ZBar_ApplyLayout() end
				MTH_ResetAndSelectOptionsTab("ZBar")
			else
				this:SetChecked(true)
			end
		end)
	end

	-- ===== Children layout (how children #2+ are arranged relative to #1) =====
	local arrLbl = container:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	arrLbl:SetPoint("TOPLEFT", container, "TOPLEFT", 16, -196)
	arrLbl:SetText("Children layout:")

	local arrVBtn = MTH_CreateCheckbox(container, "MetaHuntOptionsZBarArrV",
		"Vertical (stacked column)", -214, 30)
	if arrVBtn then
		arrVBtn:SetChecked((s.childarrange or "VERTICAL") == "VERTICAL")
		arrVBtn:SetScript("OnClick", function()
			if this:GetChecked() == 1 then
				local sv = MTH_ZBar_GetSaved()
				sv.childarrange = "VERTICAL"
				if sv.enabled and type(MTH_ZBar_ApplyLayout) == "function" then MTH_ZBar_ApplyLayout() end
				MTH_ResetAndSelectOptionsTab("ZBar")
			else
				this:SetChecked(true)
			end
		end)
	end

	local arrHBtn = MTH_CreateCheckbox(container, "MetaHuntOptionsZBarArrH",
		"Horizontal (side-by-side row)", -240, 30)
	if arrHBtn then
		arrHBtn:SetChecked((s.childarrange or "VERTICAL") == "HORIZONTAL")
		arrHBtn:SetScript("OnClick", function()
			if this:GetChecked() == 1 then
				local sv = MTH_ZBar_GetSaved()
				sv.childarrange = "HORIZONTAL"
				if sv.enabled and type(MTH_ZBar_ApplyLayout) == "function" then MTH_ZBar_ApplyLayout() end
				MTH_ResetAndSelectOptionsTab("ZBar")
			else
				this:SetChecked(true)
			end
		end)
	end

	-- ===== Spacing slider =====
	local spacingSlider = MTH_CreateSlider(container, "MetaHuntOptionsZBarSpacing",
		"Spacing (px)", 0, 30, 1, -300)
	if spacingSlider then
		spacingSlider:SetWidth(leftWidth - 40)
		spacingSlider:SetValue(tonumber(s.spacing) or 4)
		spacingSlider.onChange = function(val)
			local sv = MTH_ZBar_GetSaved()
			sv.spacing = math.floor((tonumber(val) or 4) + 0.5)
			if sv.enabled and type(MTH_ZBar_ApplyLayout) == "function" then
				MTH_ZBar_ApplyLayout()
			end
		end
	end

	-- ===== Button size slider =====
	local sizeSlider = MTH_CreateSlider(container, "MetaHuntOptionsZBarSize",
		"Button Size", 10, 100, 1, -360)
	if sizeSlider then
		sizeSlider:SetWidth(leftWidth - 40)
		sizeSlider:SetValue(tonumber(s.size) or 36)
		sizeSlider.onChange = function(val)
			if type(MTH_ZBar_SetSize) == "function" then
				MTH_ZBar_SetSize(val)
			end
		end
	end

	-- ===== Right column: Bar Order =====
	local orderHeader = container:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	orderHeader:SetPoint("TOPLEFT", container, "TOPLEFT", rightX, -10)
	orderHeader:SetText("Bar Order")

	local LABELS    = MTH_ZBar_GetAllButtonLabels()
	local numBars   = table.getn(s.order)
	local listY     = -35
	local downX     = rightX + 28
	local upX       = downX + 22
	local labelX    = upX + 26
	local labelWidth = rightWidth - (labelX - rightX) - 8
	if labelWidth < 80 then labelWidth = 80 end

	for i = 1, numBars do
		local buttonName  = s.order[i]
		local displayName = (LABELS and LABELS[buttonName]) or buttonName

		-- Include/exclude visibility toggle
		local toggleName = "MetaHuntOptionsZBarToggle" .. i
		local showToggle = CreateFrame("CheckButton", toggleName, container, "UICheckButtonTemplate")
		if showToggle then
			showToggle:ClearAllPoints()
			showToggle:SetPoint("TOPLEFT", container, "TOPLEFT", rightX, listY + 2)
			local tText = getglobal(toggleName .. "Text")
			if tText then tText:SetText("") end
			showToggle:SetChecked(s.visible[buttonName] ~= false)
			showToggle.zbarName = buttonName
			showToggle:SetScript("OnClick", function()
				local sv = MTH_ZBar_GetSaved()
				sv.visible[this.zbarName] = (this:GetChecked() == 1)
				if sv.enabled and type(MTH_ZBar_ApplyLayout) == "function" then
					MTH_ZBar_ApplyLayout()
				end
			end)
		end

		-- Move Down (-)
		local downBtn = CreateFrame("Button", nil, container, "UIPanelButtonTemplate")
		downBtn:SetPoint("TOPLEFT", container, "TOPLEFT", downX, listY)
		downBtn:SetWidth(20)
		downBtn:SetHeight(20)
		downBtn:SetText("-")
		downBtn.zbarIndex = i
		downBtn:SetScript("OnClick", function()
			local idx = this.zbarIndex
			local sv  = MTH_ZBar_GetSaved()
			local tot = table.getn(sv.order)
			if idx < tot then
				local tmp      = sv.order[idx + 1]
				sv.order[idx + 1] = sv.order[idx]
				sv.order[idx]     = tmp
				MTH_ResetAndSelectOptionsTab("ZBar")
				if sv.enabled and type(MTH_ZBar_ApplyLayout) == "function" then
					MTH_ZBar_ApplyLayout()
				end
			end
		end)

		-- Move Up (+)
		local upBtn = CreateFrame("Button", nil, container, "UIPanelButtonTemplate")
		upBtn:SetPoint("TOPLEFT", container, "TOPLEFT", upX, listY)
		upBtn:SetWidth(20)
		upBtn:SetHeight(20)
		upBtn:SetText("+")
		upBtn.zbarIndex = i
		upBtn:SetScript("OnClick", function()
			local idx = this.zbarIndex
			local sv  = MTH_ZBar_GetSaved()
			if idx > 1 then
				local tmp         = sv.order[idx - 1]
				sv.order[idx - 1] = sv.order[idx]
				sv.order[idx]     = tmp
				MTH_ResetAndSelectOptionsTab("ZBar")
				if sv.enabled and type(MTH_ZBar_ApplyLayout) == "function" then
					MTH_ZBar_ApplyLayout()
				end
			end
		end)

		-- Bar name label
		local lbl = container:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
		lbl:SetPoint("TOPLEFT", container, "TOPLEFT", labelX, listY)
		lbl:SetText(displayName)
		lbl:SetWidth(labelWidth)
		lbl:SetJustifyH("LEFT")

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

function MTH_SetupRangedOptions()
	if not MTH_ZBUTTONS_READY then return end
	local itemList = MTH_GetButtonItemList("zButtonRanged")
	local maxButtons = itemList and table.getn(itemList) or 1
	MTH_SetupButtonOptions("MetaHuntOptionsRanged", "zButtonRanged", "ZRanged", maxButtons)
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

function MTH_SetupCraftOptions()
	if not MTH_ZBUTTONS_READY then return end
	local itemList = MTH_GetButtonItemList("zButtonCraft")
	local maxButtons = itemList and table.getn(itemList) or 1
	MTH_SetupButtonOptions("MetaHuntOptionsCraft", "zButtonCraft", "ZCraft", maxButtons)
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
		moduleToggle:SetScript("OnClick", function()
			if not this then return end
			if MTH and MTH.SetModuleEnabled then
				MTH:SetModuleEnabled("smartammo", MTH_ZB_IsChecked(this))
			end
			MTH_SetupSmartAmmoOptions()
		end)
	end

	local smartToggle = MTH_CreateCheckbox(container, "MetaHuntOptionsSmartAmmoEnabled", "Enable Junk Shot Swaps", -94)
	if smartToggle then
		local enabled = type(MTHSmartAmmo_GetSmartEnabled) == "function" and MTHSmartAmmo_GetSmartEnabled() and true or false
		smartToggle:SetChecked(enabled)
		if not moduleEnabled then
			smartToggle:Disable()
		end
		smartToggle:SetScript("OnClick", function()
			if not this then return end
			if type(MTHSmartAmmo_SetSmartEnabled) == "function" then
				MTHSmartAmmo_SetSmartEnabled(MTH_ZB_IsChecked(this) and 1 or nil)
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
		reloadToggle:SetScript("OnClick", function()
			if not this then return end
			if type(MTHSmartAmmo_SetReloadEnabled) == "function" then
				MTHSmartAmmo_SetReloadEnabled(MTH_ZB_IsChecked(this) and 1 or nil)
			end
		end)
	end
end

function MTH_SetupMessagesOptions()
	if not MTH_ZBUTTONS_READY then return end
	local container = MTH_GetFrame("MetaHuntOptionsMessages")
	if not container then return end

	MTH_ClearContainer(container)

	local section = CreateFrame("Frame", "MetaHuntMessagesSection", container, "OptionFrameBoxTemplate")
	if not section then return end
	section:SetPoint("TOPLEFT", container, "TOPLEFT", 8, -8)
	section:SetPoint("TOPRIGHT", container, "TOPRIGHT", -8, -8)
	section:SetHeight(268)

	local titleFrame = getglobal("MetaHuntMessagesSectionTitle")
	if titleFrame then
		titleFrame:SetText("Messages")
	end

	local help = section:CreateFontString("MetaHuntMessagesHelp", "ARTWORK")
	help:SetFont("Fonts\\FRIZQT__.TTF", 10)
	help:SetJustifyH("LEFT")
	help:SetPoint("TOPLEFT", section, "TOPLEFT", 14, -12)
	help:SetPoint("TOPRIGHT", section, "TOPRIGHT", -14, -12)
	help:SetText("Enable or Disable Metahunt chat messages")

	local msgSettings = (MTH and MTH.GetMessageSettings and MTH:GetMessageSettings()) or {}

	local initModulesToggle = MTH_CreateCheckbox(section, "MetaHuntMessagesInitModules", "Init : modules loaded", -36)
	if initModulesToggle then
		initModulesToggle:SetChecked(msgSettings.initModulesLoaded and true or false)
		initModulesToggle:SetScript("OnClick", function()
			if not this then return end
			if MTH and MTH.SetMessageEnabled then
				MTH:SetMessageEnabled("initModulesLoaded", MTH_ZB_IsChecked(this))
			end
		end)
	end

	local initWelcomeToggle = MTH_CreateCheckbox(section, "MetaHuntMessagesInitWelcome", "Init : Sarcastic welcome message", -64)
	if initWelcomeToggle then
		initWelcomeToggle:SetChecked(msgSettings.initSarcasticWelcome ~= false)
		initWelcomeToggle:SetScript("OnClick", function()
			if not this then return end
			if MTH and MTH.SetMessageEnabled then
				MTH:SetMessageEnabled("initSarcasticWelcome", MTH_ZB_IsChecked(this))
			end
		end)
	end

	local petHungryToggle = MTH_CreateCheckbox(section, "MetaHuntMessagesPetHungry", "Pet is hungry (spam)", -92)
	if petHungryToggle then
		petHungryToggle:SetChecked(msgSettings.petHungry and true or false)
		petHungryToggle:SetScript("OnClick", function()
			if not this then return end
			if MTH and MTH.SetMessageEnabled then
				MTH:SetMessageEnabled("petHungry", MTH_ZB_IsChecked(this))
			end
		end)
	end

	local beastTrainingScanToggle = MTH_CreateCheckbox(section, "MetaHuntMessagesBeastTrainingScan", "Beasttraining scan", -120)
	if beastTrainingScanToggle then
		beastTrainingScanToggle:SetChecked(msgSettings.beastTrainingScan ~= false)
		beastTrainingScanToggle:SetScript("OnClick", function()
			if not this then return end
			if MTH and MTH.SetMessageEnabled then
				MTH:SetMessageEnabled("beastTrainingScan", MTH_ZB_IsChecked(this))
			end
		end)
	end

	local spellbookScanToggle = MTH_CreateCheckbox(section, "MetaHuntMessagesSpellbookScan", "Spellbook scan", -148)
	if spellbookScanToggle then
		spellbookScanToggle:SetChecked(msgSettings.spellbookScan and true or false)
		spellbookScanToggle:SetScript("OnClick", function()
			if not this then return end
			if MTH and MTH.SetMessageEnabled then
				MTH:SetMessageEnabled("spellbookScan", MTH_ZB_IsChecked(this))
			end
		end)
	end

	local petRanAwayToggle = MTH_CreateCheckbox(section, "MetaHuntMessagesPetRanAway", "Pet ran away", -176)
	if petRanAwayToggle then
		petRanAwayToggle:SetChecked(msgSettings.petRanAway ~= false)
		petRanAwayToggle:SetScript("OnClick", function()
			if not this then return end
			if MTH and MTH.SetMessageEnabled then
				MTH:SetMessageEnabled("petRanAway", MTH_ZB_IsChecked(this))
			end
		end)
	end

	local mapMarkersToggle = MTH_CreateCheckbox(section, "MetaHuntMessagesMapMarkers", "Map markers", -204)
	if mapMarkersToggle then
		mapMarkersToggle:SetChecked(msgSettings.mapMarkers ~= false)
		mapMarkersToggle:SetScript("OnClick", function()
			if not this then return end
			if MTH and MTH.SetMessageEnabled then
				MTH:SetMessageEnabled("mapMarkers", MTH_ZB_IsChecked(this))
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

	local smartAmmoSection = ensureSection("MetaHuntGeneralSmartAmmoBox", "Smart Ammo", topY, 254, "left")
	if smartAmmoSection then
		local smartModuleEnabled = MTH and MTH.IsModuleEnabled and MTH:IsModuleEnabled("smartammo", true)
		local smartModuleToggle = ensureCheckbox(smartAmmoSection, "MetaHuntGeneralSmartAmmoModuleToggle", "Enable module", -10, smartModuleEnabled)
		if smartModuleToggle then
			smartModuleToggle:SetScript("OnClick", function()
				local enabled = MTH_ZB_IsChecked(this)
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

		local moduleHelp = getglobal("MetaHuntGeneralSmartAmmoModuleHelp")
		if moduleHelp then
			moduleHelp:Hide()
		end

		local smartEnabled = true
		if type(MTHSmartAmmo_GetSmartEnabled) == "function" then
			smartEnabled = MTHSmartAmmo_GetSmartEnabled() and true or false
		end
		local smartToggle = ensureCheckbox(smartAmmoSection, "MetaHuntGeneralSmartAmmoEnabledToggle", "Enable Junk Shot Swaps", -58, smartEnabled)
		if smartToggle then
			if not smartModuleEnabled then
				smartToggle:Disable()
			end
			smartToggle:SetScript("OnClick", function()
				if type(MTHSmartAmmo_SetSmartEnabled) == "function" then
					MTHSmartAmmo_SetSmartEnabled(MTH_ZB_IsChecked(this) and 1 or nil)
				end
			end)
		end
		ensureHelpText(smartAmmoSection, "MetaHuntGeneralSmartAmmoEnabledHelp", "Swaps to low-tier ammo for shots that don't scale on weapon damage, then swaps back to your previous ammo.", -86)

		local reloadEnabled = type(MTHSmartAmmo_GetReloadEnabled) == "function" and MTHSmartAmmo_GetReloadEnabled() and true or false
		local reloadToggle = ensureCheckbox(smartAmmoSection, "MetaHuntGeneralSmartAmmoReloadToggle", "Enable Auto-Fallback", -126, reloadEnabled)
		if reloadToggle then
			if not smartModuleEnabled then
				reloadToggle:Disable()
			end
			reloadToggle:SetScript("OnClick", function()
				if type(MTHSmartAmmo_SetReloadEnabled) == "function" then
					MTHSmartAmmo_SetReloadEnabled(MTH_ZB_IsChecked(this) and 1 or nil)
				end
			end)
		end
		ensureHelpText(smartAmmoSection, "MetaHuntGeneralSmartAmmoReloadHelp", "Falls back to any available ammo when equipped ammo is out of stock.", -154)

		local weaponSwapEnabled = type(MTHSmartAmmo_GetWeaponSwapEnabled) == "function" and MTHSmartAmmo_GetWeaponSwapEnabled() and true or false
		local weaponSwapToggle = ensureCheckbox(smartAmmoSection, "MetaHuntGeneralSmartAmmoWeaponSwapToggle", "Enable Weapon-Swap Auto Ammo", -180, weaponSwapEnabled)
		if weaponSwapToggle then
			if not smartModuleEnabled then
				weaponSwapToggle:Disable()
			end
			weaponSwapToggle:SetScript("OnClick", function()
				if type(MTHSmartAmmo_SetWeaponSwapEnabled) == "function" then
					MTHSmartAmmo_SetWeaponSwapEnabled(MTH_ZB_IsChecked(this) and 1 or nil)
				end
			end)
		end
		ensureHelpText(smartAmmoSection, "MetaHuntGeneralSmartAmmoWeaponSwapHelp", "When you swap between gun and bow/crossbow, instantly equips the best matching ammo from your bags.", -208)
	end

	local stripSection = ensureSection("MetaHuntGeneralAutoStripBox", "Auto-Strip", topY - 270, 122, "left")
	if stripSection then
		local autoStripToggle = ensureCheckbox(stripSection, "MetaHuntGeneralAutoStripToggle", "Enable Auto-Strip on Combat Exit", -10, stripSaved["autostrip"] and true or false)
		if autoStripToggle then
			autoStripToggle:SetScript("OnClick", function()
				if type(AutoStrip_SetAutoStripToggle) == "function" then
					AutoStrip_SetAutoStripToggle(MTH_ZB_IsChecked(this))
				end
			end)
		end

		local displayToggle = ensureCheckbox(stripSection, "MetaHuntGeneralAutoStripDisplay", "Show Strip Button", -36, stripSaved["display"] and true or false)
		if displayToggle then
			displayToggle:SetScript("OnClick", function()
				if type(AutoStrip_SetDisplayToggle) == "function" then
					AutoStrip_SetDisplayToggle(MTH_ZB_IsChecked(this))
				end
			end)
		end

		ensureHelpText(stripSection, "MetaHuntGeneralAutoStripHelp", "Auto-strip unequips items when combat ends. Requires at least one empty bag slot.", -64)
	end

	local antiSection = ensureSection("MetaHuntGeneralAntiDazeBox", "Anti-Daze", topY - 406, 96, "left")
	if antiSection then
		local antiDazeEnabled = (AntiDaze_GetEnabled and AntiDaze_GetEnabled()) or false
		local antiToggle = ensureCheckbox(antiSection, "MetaHuntGeneralAntiDazeToggle", "Enable Anti-Daze", -10, antiDazeEnabled)
		if antiToggle then
			antiToggle:SetScript("OnClick", function()
				local enabled = MTH_ZB_IsChecked(this)
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
		local tooltipsStore = MTH and MTH.GetModuleCharSavedVariables and MTH:GetModuleCharSavedVariables("tooltips")
		if type(tooltipsStore) ~= "table" then
			tooltipsStore = {}
		end
		if MTH and MTH.GetModuleSavedVariables and next(tooltipsStore) == nil then
			local accountStore = MTH:GetModuleSavedVariables("tooltips")
			if type(accountStore) == "table" and next(accountStore) ~= nil then
				for key, value in pairs(accountStore) do
					if type(value) == "table" then
						local copied = {}
						for subKey, subValue in pairs(value) do
							copied[subKey] = subValue
						end
						tooltipsStore[key] = copied
					else
						tooltipsStore[key] = value
					end
				end
			end
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
				local enabled = MTH_ZB_IsChecked(this)
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
				local enabled = MTH_ZB_IsChecked(this)
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
				local enabled = MTH_ZB_IsChecked(this)
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
				local enabled = MTH_ZB_IsChecked(this)
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
				local enabled = MTH_ZB_IsChecked(this)
				tooltipsStore.foodItemTooltips = enabled
				local tooltipsModule = MTH and MTH.GetModule and MTH:GetModule("tooltips")
				if tooltipsModule and tooltipsModule.SetFoodItemTooltipsEnabled then
					tooltipsModule:SetFoodItemTooltipsEnabled(enabled)
				end
			end)
		end

		ensureHelpText(tooltipsSection, "MetaHuntGeneralTooltipsFoodHelp", foodHelp, -298)
	end

	local bagsSection = ensureSection("MetaHuntGeneralBagsBox", "Bag Ammo Labels", topY - 372, 168, "right")
	if bagsSection then
		local bagLabels = ensureCheckbox(bagsSection, "MetaHuntGeneralBagLabelsToggle", "Add text to ammunitions in bags", -10,
			MTH_BagAmmoLabels_GetEnabled and MTH_BagAmmoLabels_GetEnabled() or false)
		if bagLabels then
			bagLabels:SetScript("OnClick", function()
				local enabled = MTH_ZB_IsChecked(this)
				if MTH_BagAmmoLabels_SetEnabled then MTH_BagAmmoLabels_SetEnabled(enabled) end
			end)
		end

		local bankLabels = ensureCheckbox(bagsSection, "MetaHuntGeneralBankLabelsToggle", "Add text to ammunitions in bank", -36,
			MTH_BankAmmoLabels_GetEnabled and MTH_BankAmmoLabels_GetEnabled() or false)
		if bankLabels then
			bankLabels:SetScript("OnClick", function()
				local enabled = MTH_ZB_IsChecked(this)
				if MTH_BankAmmoLabels_SetEnabled then MTH_BankAmmoLabels_SetEnabled(enabled) end
			end)
		end

		local dmgLabels = ensureCheckbox(bagsSection, "MetaHuntGeneralBagDmgToggle", "Show ammo damage (heat-coloured)", -62,
			MTH_BagAmmoDamage_GetEnabled and MTH_BagAmmoDamage_GetEnabled() or false)
		if dmgLabels then
			dmgLabels:SetScript("OnClick", function()
				local enabled = MTH_ZB_IsChecked(this)
				if MTH_BagAmmoDamage_SetEnabled then MTH_BagAmmoDamage_SetEnabled(enabled) end
			end)
		end

		ensureHelpText(bagsSection, "MetaHuntGeneralBagDmgHelp", "Damage is heat-coloured from red (7.5) to green (20.5).", -88)
	end

end
