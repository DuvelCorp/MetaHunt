MTH_UIRenderer = MTH_UIRenderer or {}

MTH_UIRenderer.activeWidgets = MTH_UIRenderer.activeWidgets or {}

local function MTH_UIR_Clear(frame)
	if not frame then return end
	local widgets = frame._mthWidgets
	if not widgets then return end
	for _, widget in ipairs(widgets) do
		if widget and widget.Hide then
			widget:Hide()
		end
	end
	frame._mthWidgets = {}
end

local function MTH_UIR_AddWidget(frame, widget)
	if not frame._mthWidgets then
		frame._mthWidgets = {}
	end
	table.insert(frame._mthWidgets, widget)
end

local function MTH_UIR_MakeLabel(frame, text, x, y, width, template)
	local label = frame:CreateFontString(nil, "ARTWORK", template or "GameFontNormalSmall")
	label:SetPoint("TOPLEFT", frame, "TOPLEFT", x, y)
	label:SetWidth(width)
	label:SetJustifyH("LEFT")
	label:SetText(text or "")
	MTH_UIR_AddWidget(frame, label)
	return label
end

local function MTH_UIR_SetCheckboxLabel(checkButton, text)
	local textRegion = nil
	local checkName = checkButton and checkButton.GetName and checkButton:GetName()
	if type(checkName) == "string" and checkName ~= "" then
		textRegion = getglobal(checkName .. "Text")
	end
	if not textRegion and checkButton and checkButton.Text then
		textRegion = checkButton.Text
	end
	if textRegion then
		textRegion:SetText(text or "")
	end
end

local function MTH_UIR_CreateControl(frame, key, option, context, x, y, width)
	local optionType = option.type or "description"
	local optionName = MTH_UI.ResolveValue(option.name, context)
	if optionType == "description" then
		local label = MTH_UIR_MakeLabel(frame, optionName or "", x, y, width, "GameFontHighlightSmall")
		if label then label:SetTextColor(0.90, 0.90, 0.90) end
		return 18
	end

	if optionType == "header" then
		local label = MTH_UIR_MakeLabel(frame, optionName or "", x, y, width, "GameFontNormal")
		if label then label:SetTextColor(1.00, 0.82, 0.00) end
		return 24
	end

	if optionType == "toggle" then
		local checkButton = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
		checkButton:SetPoint("TOPLEFT", frame, "TOPLEFT", x, y + 2)
		checkButton:SetChecked(MTH_UI.ResolveValue(option.get, context) and 1 or nil)
		MTH_UIR_SetCheckboxLabel(checkButton, optionName or "")
		checkButton:SetScript("OnClick", function()
			if not this then return end
			if option.set then
				option.set(context, this:GetChecked() == 1)
			end
		end)
		if MTH_UI.ResolveValue(option.disabled, context) then
			checkButton:Disable()
		end
		MTH_UIR_AddWidget(frame, checkButton)
		return 24
	end

	if optionType == "execute" then
		local button = CreateFrame("Button", nil, frame)
		button:SetPoint("TOPLEFT", frame, "TOPLEFT", x, y)
		button:SetHeight(20)
		button:SetWidth(math.min(180, width))
		button:SetBackdrop({
			bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
			edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
			tile = true,
			tileSize = 16,
			edgeSize = 16,
			insets = { left = 3, right = 3, top = 3, bottom = 3 },
		})
		button:SetBackdropColor(0.1, 0.1, 0.1, 0.5)
		button:SetBackdropBorderColor(0.4, 0.4, 0.4)

		local text = button:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
		text:SetPoint("CENTER", button, "CENTER", 0, 0)
		text:SetText(optionName or "Run")
		text:SetTextColor(1.00, 0.82, 0.00)

		button:SetScript("OnEnter", function() if this then this:SetBackdropBorderColor(0.6, 0.6, 0.6) end end)
		button:SetScript("OnLeave", function() if this then this:SetBackdropBorderColor(0.4, 0.4, 0.4) end end)
		button:SetScript("OnClick", function()
			if option.func then
				option.func(context)
			end
		end)
		if MTH_UI.ResolveValue(option.disabled, context) then
			button:Disable()
		end
		MTH_UIR_AddWidget(frame, button)
		return 24
	end

	if optionType == "select" then
		local label = MTH_UIR_MakeLabel(frame, optionName or "Select", x, y, width, "GameFontNormalSmall")
		if label then label:SetTextColor(1.00, 0.82, 0.00) end

		local button = CreateFrame("Button", nil, frame)
		button:SetPoint("TOPLEFT", frame, "TOPLEFT", x, y - 16)
		button:SetHeight(20)
		button:SetWidth(math.min(220, width))
		button:SetBackdrop({
			bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
			edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
			tile = true,
			tileSize = 16,
			edgeSize = 16,
			insets = { left = 3, right = 3, top = 3, bottom = 3 },
		})
		button:SetBackdropColor(0.1, 0.1, 0.1, 0.5)
		button:SetBackdropBorderColor(0.4, 0.4, 0.4)

		local currentValue = MTH_UI.ResolveValue(option.get, context)
		local text = button:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
		text:SetPoint("CENTER", button, "CENTER", 0, 0)
		text:SetText(tostring(currentValue or "Choose"))
		text:SetTextColor(0.90, 0.90, 0.90)

		button:SetScript("OnEnter", function() if this then this:SetBackdropBorderColor(0.6, 0.6, 0.6) end end)
		button:SetScript("OnLeave", function() if this then this:SetBackdropBorderColor(0.4, 0.4, 0.4) end end)
		button:SetScript("OnClick", function()
			if option.onClick then
				option.onClick(context, option)
			end
		end)
		if MTH_UI.ResolveValue(option.disabled, context) then
			button:Disable()
		end
		MTH_UIR_AddWidget(frame, button)
		return 42
	end

	MTH_UIR_MakeLabel(frame, optionName or ("Unsupported type: " .. tostring(optionType)), x, y, width, "GameFontDisableSmall")
	return 18
end

function MTH_UIRenderer.RenderPage(frame, pageDefinition, context)
	if not frame or not pageDefinition then return false, "invalid render target" end

	MTH_UIR_Clear(frame)

	local args = pageDefinition.args or {}
	local orderedKeys = {}
	for key in pairs(args) do
		table.insert(orderedKeys, key)
	end
	table.sort(orderedKeys, function(leftKey, rightKey)
		local leftOrder = (args[leftKey] and args[leftKey].order) or 9999
		local rightOrder = (args[rightKey] and args[rightKey].order) or 9999
		if leftOrder ~= rightOrder then return leftOrder < rightOrder end
		return tostring(leftKey) < tostring(rightKey)
	end)

	local cursorY = -8
	for _, key in ipairs(orderedKeys) do
		local option = args[key]
		if option then
			local hidden = MTH_UI.ResolveValue(option.hidden, context)
			if not hidden then
				local consumedHeight = MTH_UIR_CreateControl(frame, key, option, context, 8, cursorY, frame:GetWidth() - 16)
				cursorY = cursorY - consumedHeight
			end
		end
	end

	return true
end
