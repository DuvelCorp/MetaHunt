-- MetaHunt unified options window

function MTH_GetFrame(name)
	return getglobal(name)
end

function MTH_OptionsRequire(moduleName, requiredGlobals)
	local missing = {}
	for i = 1, table.getn(requiredGlobals) do
		local key = requiredGlobals[i]
		if _G[key] == nil then
			table.insert(missing, key)
		end
	end

	if table.getn(missing) == 0 then
		return true
	end

	local message = "[MTH OPTIONS] " .. tostring(moduleName) .. " missing dependencies: " .. table.concat(missing, ", ")
	if MTH and MTH.Print then
		MTH:Print(message, "error")
	elseif type(MTH_Log) == "function" then
		MTH_Log(message, "error")
	elseif DEFAULT_CHAT_FRAME and DEFAULT_CHAT_FRAME.AddMessage then
		DEFAULT_CHAT_FRAME:AddMessage(message)
	end

	return false
end

function MTH_CreateActionButton(parent, name, text, x, y, width, height, onClick)
	local button = CreateFrame("Button", name, parent, "UIPanelButtonTemplate")
	if not button then return nil end
	button:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
	button:SetWidth(width or 120)
	button:SetHeight(height or 24)
	button:SetText(text)
	if onClick then
		button:SetScript("OnClick", onClick)
	end
	return button
end

-- Helper: Create a slider control
function MTH_CreateSlider(parent, name, label, minVal, maxVal, step, yOffset)
	local slider = CreateFrame("Slider", name, parent, "OptionsSliderTemplate")
	if not slider then return nil end
	
	slider:SetPoint("TOPLEFT", parent, "TOPLEFT", 15, yOffset)
	slider:SetWidth(280)
	slider:SetMinMaxValues(minVal, maxVal)
	slider:SetValueStep(step)
	slider:SetValue(minVal)
	
	-- Labels
	local text = slider:CreateFontString(name.."Text", "ARTWORK", "GameFontNormalSmall")
	text:SetPoint("BOTTOM", slider, "TOP", 0, 2)
	text:SetText(label)
	
	local value = slider:CreateFontString(name.."Value", "ARTWORK", "GameFontHighlight")
	value:SetPoint("TOP", slider, "BOTTOM", 0, 2)
	value:SetText(tostring(minVal))
	
	-- Hide default low/high labels from OptionsSliderTemplate
	local lowLabel = getglobal(name.."Low")
	local highLabel = getglobal(name.."High")
	if lowLabel then lowLabel:Hide() end
	if highLabel then highLabel:Hide() end
	
	slider:SetScript("OnValueChanged", function(self, newValue)
		local activeSlider = self or this or slider
		local current = tonumber(newValue)
		if not current and activeSlider and activeSlider.GetValue then
			current = tonumber(activeSlider:GetValue())
		end
		if not current then
			current = minVal
		end
		value:SetText(tostring(math.floor(current + 0.5)))
		if slider.onChange then slider.onChange(current, activeSlider) end
	end)
	
	return slider
end

-- Helper: Create a checkbox control
MTH_CreateCheckbox = function(parent, name, label, yOffset, xOffset)
	local check = CreateFrame("CheckButton", name, parent, "UICheckButtonTemplate")
	if not check then return nil end
	
	check:SetPoint("TOPLEFT", parent, "TOPLEFT", xOffset or 15, yOffset)
	
	local text = check:CreateFontString(name.."Text", "ARTWORK", "GameFontNormalSmall")
	text:SetPoint("LEFT", check, "RIGHT", 5, 0)
	text:SetText(label)
	
	return check
end

-- Helper: Clear all children from a container
MTH_ClearContainer = function(container)
	if not container then return end
	-- Hide all child frames
	local children = { container:GetChildren() }
	for i = 1, table.getn(children) do
		local child = children[i]
		if child then
			child:Hide()
			child:ClearAllPoints()
		end
	end
	-- Hide all font strings and textures
	local regions = { container:GetRegions() }
	for i = 1, table.getn(regions) do
		local region = regions[i]
		if region and region ~= container then
			region:Hide()
			if region.ClearAllPoints then
				region:ClearAllPoints()
			end
		end
	end
end

