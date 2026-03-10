local MTH_ICU_OPT_READY = true
local MTH_ICU_OPT_MISSING = {}

if type(MTH_GetFrame) ~= "function" then table.insert(MTH_ICU_OPT_MISSING, "MTH_GetFrame") end
if type(MTH_ClearContainer) ~= "function" then table.insert(MTH_ICU_OPT_MISSING, "MTH_ClearContainer") end
if type(MTH_CreateCheckbox) ~= "function" then table.insert(MTH_ICU_OPT_MISSING, "MTH_CreateCheckbox") end

if table.getn(MTH_ICU_OPT_MISSING) > 0 then
	MTH_ICU_OPT_READY = false
	if MTH and MTH.Print then
		MTH:Print("[MTH ICU OPTIONS] missing dependencies: " .. table.concat(MTH_ICU_OPT_MISSING, ", "), "error")
	end
end

local MTH_ICU_OPT_STATE = {
	container = nil,
	built = false,
	controls = {},
}

local MTH_ICU_LAYOUT = {
	LEFT_X = 20,
	LEFT_DROPDOWN_X = 94,
	RIGHT_X = 280,
	RIGHT_DROPDOWN_X = 366,
	DROPDOWN_WIDTH = 108,
	COLOR_BUTTON_X = 378,
	COLOR_BUTTON_WIDTH = 78,
	COLOR_ROW_STEP = 24,
}

local MTH_ICU_OPTIONS_FALLBACK = {
	ALERT = { "AUTO", "PARTY", "RAID", "SELF", "MTH Message", "OFF" },
	ANNOUNCE = { "AUTO", "SAY", "YELL", "PARTY", "RAID", "SELF", "MTH Message", "OFF" },
	ANCHOR = { "TOP", "TOPLEFT", "TOPRIGHT", "BOTTOM", "BOTTOMLEFT", "BOTTOMRIGHT", "LEFT", "RIGHT", "CUSTOM" },
	POPUP_HIDE_DELAY = { "INSTANT", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10" },
	HEALTH_TEXT_MODE = { "NONE", "PERCENT", "HP", "BOTH" },
	PLAYER_COLOR_MODE = { "CLASS", "REACTION", "FACTION", "CUSTOM" },
}

local MTH_ICU_DEFAULT_BG_COLORS = {
	PLAYER_HOSTILE = { 1.00, 0.20, 0.20 },
	PLAYER_NEUTRAL = { 1.00, 0.85, 0.10 },
	PLAYER_FRIENDLY = { 0.20, 0.75, 1.00 },
	NPC_HOSTILE = { 1.00, 0.20, 0.20 },
	NPC_NEUTRAL = { 1.00, 0.85, 0.10 },
	NPC_FRIENDLY = { 0.10, 0.90, 0.10 },
	UNKNOWN = { 0.70, 0.70, 0.70 },
}

local MTH_ICU_COLOR_ROWS = {
	{ key = "PLAYER_HOSTILE", label = "Player hostile" },
	{ key = "PLAYER_NEUTRAL", label = "Player neutral" },
	{ key = "PLAYER_FRIENDLY", label = "Player friendly" },
	{ key = "NPC_HOSTILE", label = "NPC hostile" },
	{ key = "NPC_NEUTRAL", label = "NPC neutral" },
	{ key = "NPC_FRIENDLY", label = "NPC friendly" },
	{ key = "UNKNOWN", label = "Unknown fallback" },
}

local function MTH_ICU_GetStore()
	local store = nil
	if MTH and MTH.GetModuleCharSavedVariables then
		store = MTH:GetModuleCharSavedVariables("icu")
	end
	if type(store) ~= "table" then
		ICUvars = ICUvars or {}
		store = ICUvars
	end

	if store.ALERT == nil then store.ALERT = "MTH Message" end
	if store.ALERT == "SAY" or store.ALERT == "YELL" then store.ALERT = "SELF" end
	if store.ANNOUNCE == nil then store.ANNOUNCE = "MTH Message" end
	if store.ANCHOR == nil then store.ANCHOR = "BOTTOMRIGHT" end
	if store.POPUP_HIDE_DELAY == nil then
		store.POPUP_HIDE_DELAY = "INSTANT"
	else
		local rawDelay = tostring(store.POPUP_HIDE_DELAY)
		if rawDelay ~= "INSTANT" then
			local n = tonumber(rawDelay)
			if not n then
				store.POPUP_HIDE_DELAY = "INSTANT"
			else
				n = math.floor(n)
				if n < 1 then
					store.POPUP_HIDE_DELAY = "INSTANT"
				elseif n > 10 then
					store.POPUP_HIDE_DELAY = "10"
				else
					store.POPUP_HIDE_DELAY = tostring(n)
				end
			end
		end
	end
	if store.mouseOver == nil then store.mouseOver = false end
	if store.HEALTH_TEXT_MODE == nil then store.HEALTH_TEXT_MODE = "BOTH" end
	if store.HEALTH_TEXT_MODE == "AUTO" then store.HEALTH_TEXT_MODE = "BOTH" end
	if store.PLAYER_COLOR_MODE == nil then store.PLAYER_COLOR_MODE = "CLASS" end
	if store.REACTION_ONLY_PVP_PLAYERS == nil then store.REACTION_ONLY_PVP_PLAYERS = true end
	if store.SHOW_GUILD_NAME == nil then store.SHOW_GUILD_NAME = false end
	if store.SHOW_PLAYER_CLASS == nil then store.SHOW_PLAYER_CLASS = true end
	if store.SHOW_PLAYER_RACE == nil then store.SHOW_PLAYER_RACE = true end
	if store.SHOW_CUSTOM_TITLES == nil then store.SHOW_CUSTOM_TITLES = false end
	if store.EXPAND_UP == nil then store.EXPAND_UP = false end

	if type(store.COLORS) ~= "table" then
		store.COLORS = {}
	end
	for key, def in pairs(MTH_ICU_DEFAULT_BG_COLORS) do
		if type(store.COLORS[key]) ~= "table" then
			store.COLORS[key] = { def[1], def[2], def[3] }
		end
	end

	ICUvars = store
	return store
end

local function MTH_ICU_GetOptionValues(key)
	if type(ICU_OPTIONS) == "table" and type(ICU_OPTIONS[key]) == "table" then
		return ICU_OPTIONS[key]
	end
	return MTH_ICU_OPTIONS_FALLBACK[key] or {}
end

local function MTH_ICU_SetValue(key, value)
	local store = MTH_ICU_GetStore()
	store[key] = tostring(value or "")
	if key == "ANCHOR" and type(ICU_SetPoints) == "function" then
		ICU_SetPoints()
	end
end

local function MTH_ICU_DropdownSetText(frame, text)
	if UIDropDownMenu_SetText then
		UIDropDownMenu_SetText(tostring(text or ""), frame)
		return
	end
	if not frame or not frame.GetName then return end
	local textRegion = getglobal(frame:GetName() .. "Text")
	if textRegion and textRegion.SetText then
		textRegion:SetText(tostring(text or ""))
	end
end

local function MTH_ICU_GetColor(key)
	local store = MTH_ICU_GetStore()
	local row = store.COLORS and store.COLORS[key]
	if type(row) == "table" then
		return tonumber(row[1]) or 0, tonumber(row[2]) or 0, tonumber(row[3]) or 0
	end
	local def = MTH_ICU_DEFAULT_BG_COLORS[key] or MTH_ICU_DEFAULT_BG_COLORS.UNKNOWN
	return def[1], def[2], def[3]
end

local function MTH_ICU_SetColor(key, r, g, b)
	local store = MTH_ICU_GetStore()
	if type(store.COLORS) ~= "table" then
		store.COLORS = {}
	end
	store.COLORS[key] = {
		math.max(0, math.min(1, tonumber(r) or 0)),
		math.max(0, math.min(1, tonumber(g) or 0)),
		math.max(0, math.min(1, tonumber(b) or 0)),
	}
end

local function MTH_ICU_OpenColorPicker(colorKey)
	if not ColorPickerFrame then
		if MTH and MTH.Print then
			MTH:Print("ColorPickerFrame is not available in this client", "error")
		end
		return
	end

	local currentR, currentG, currentB = MTH_ICU_GetColor(colorKey)
	local function applyColor()
		local r, g, b = ColorPickerFrame:GetColorRGB()
		MTH_ICU_SetColor(colorKey, r, g, b)
		MTH_RefreshICUOptions()
	end

	ColorPickerFrame.func = applyColor
	ColorPickerFrame.cancelFunc = function(prev)
		if type(prev) == "table" then
			local r = prev.r or prev[1] or currentR
			local g = prev.g or prev[2] or currentG
			local b = prev.b or prev[3] or currentB
			MTH_ICU_SetColor(colorKey, r, g, b)
			MTH_RefreshICUOptions()
		end
	end
	ColorPickerFrame:SetColorRGB(currentR, currentG, currentB)
	ColorPickerFrame.hasOpacity = false
	ColorPickerFrame.opacity = 1
	ColorPickerFrame.previousValues = { currentR, currentG, currentB }
	ColorPickerFrame:Show()
end

local function MTH_ICU_CreateOptionRow(container, rowName, label, key, y, labelX, dropdownX)
	labelX = labelX or MTH_ICU_LAYOUT.LEFT_X
	dropdownX = dropdownX or MTH_ICU_LAYOUT.LEFT_DROPDOWN_X

	local labelFs = container:CreateFontString(rowName .. "Label", "ARTWORK", "GameFontNormalSmall")
	labelFs:SetPoint("TOPLEFT", container, "TOPLEFT", labelX, y)
	labelFs:SetText(label)

	local dropdown = CreateFrame("Frame", rowName .. "Drop", container, "UIDropDownMenuTemplate")
	dropdown:ClearAllPoints()
	dropdown:SetPoint("TOPLEFT", container, "TOPLEFT", dropdownX, y + 12)
	if UIDropDownMenu_SetWidth then
		UIDropDownMenu_SetWidth(MTH_ICU_LAYOUT.DROPDOWN_WIDTH, dropdown)
	end
	if UIDropDownMenu_JustifyText then
		UIDropDownMenu_JustifyText("LEFT", dropdown)
	end

	if UIDropDownMenu_Initialize then
		UIDropDownMenu_Initialize(dropdown, function()
			local values = MTH_ICU_GetOptionValues(key)
			local store = MTH_ICU_GetStore()
			local current = tostring(store[key] or "")
			local infoFactory = UIDropDownMenu_CreateInfo

			for i = 1, table.getn(values) do
				local optionValue = tostring(values[i])
				local info = type(infoFactory) == "function" and infoFactory() or {}
				info.text = optionValue
				info.checked = optionValue == current and 1 or nil
				info.func = function()
					MTH_ICU_SetValue(key, optionValue)
					MTH_RefreshICUOptions()
				end
				if UIDropDownMenu_AddButton then UIDropDownMenu_AddButton(info) end
			end
		end)
	end

	MTH_ICU_OPT_STATE.controls[key] = {
		label = labelFs,
		dropdown = dropdown,
	}
end

local function MTH_ICU_CreateColorRow(container, rowName, label, colorKey, y, labelX, buttonX)
	labelX = labelX or MTH_ICU_LAYOUT.RIGHT_X
	buttonX = buttonX or MTH_ICU_LAYOUT.COLOR_BUTTON_X

	local labelFs = container:CreateFontString(rowName .. "Label", "ARTWORK", "GameFontNormalSmall")
	labelFs:SetPoint("TOPLEFT", container, "TOPLEFT", labelX, y)
	labelFs:SetText(label)

	local button = CreateFrame("Button", rowName .. "Button", container, "UIPanelButtonTemplate")
	button:SetPoint("TOPLEFT", container, "TOPLEFT", buttonX, y + 8)
	button:SetWidth(MTH_ICU_LAYOUT.COLOR_BUTTON_WIDTH)
	button:SetHeight(22)
	button:SetText("Pick")
	button:SetScript("OnClick", function()
		MTH_ICU_OpenColorPicker(colorKey)
	end)

	local swatch = button:CreateTexture(rowName .. "Swatch", "ARTWORK")
	swatch:SetTexture("Interface\\Buttons\\WHITE8X8")
	swatch:SetPoint("LEFT", button, "LEFT", 6, 0)
	swatch:SetWidth(14)
	swatch:SetHeight(14)

	MTH_ICU_OPT_STATE.controls[colorKey] = {
		label = labelFs,
		button = button,
		swatch = swatch,
		isColor = true,
	}
end

local function MTH_ICU_BuildUI(container)
	if MTH_ICU_OPT_STATE.built and MTH_ICU_OPT_STATE.container == container then
		return
	end

	MTH_ClearContainer(container)
	MTH_ICU_OPT_STATE.controls = {}
	MTH_ICU_OPT_STATE.container = container
	MTH_ICU_OPT_STATE.built = true

	local title = container:CreateFontString("MetaHuntOptionsICUTitle", "ARTWORK", "GameFontHighlight")
	title:SetPoint("TOPLEFT", container, "TOPLEFT", 20, -10)
	title:SetText("MTH ICU")

	local note = container:CreateFontString("MetaHuntOptionsICUNote", "ARTWORK", "GameFontNormalSmall")
	note:SetPoint("TOPLEFT", container, "TOPLEFT", 20, -32)
	note:SetWidth(560)
	note:SetJustifyH("LEFT")
	note:SetJustifyV("TOP")
	note:SetTextColor(0.35, 0.65, 1)
	note:SetText("ICU is a minimap targeting utility module for your Trackings.\nIt provides enhanced target information and click actions for players and NPCs on the minimap.")

	local moduleEnabled = MTH_CreateCheckbox(container, "MetaHuntOptionsICUModuleEnabled", "Enable ICU module", -72, MTH_ICU_LAYOUT.LEFT_X)
	if moduleEnabled then
		moduleEnabled:SetScript("OnClick", function()
			if not this then return end
			if MTH and MTH.SetModuleEnabled then
				local ok, err = MTH:SetModuleEnabled("icu", this:GetChecked() == 1)
				if not ok and MTH and MTH.Print then
					MTH:Print("Failed to change ICU module state: " .. tostring(err), "error")
				end
			end
			MTH_RefreshICUOptions()
		end)
		MTH_ICU_OPT_STATE.controls.moduleEnabled = moduleEnabled
	end

	local mouseOver = MTH_CreateCheckbox(container, "MetaHuntOptionsICUMouseOver", "Enable CTRL mouseover scan", -98, MTH_ICU_LAYOUT.LEFT_X)
	if mouseOver then
		mouseOver:SetScript("OnClick", function()
			if not this then return end
			local store = MTH_ICU_GetStore()
			store.mouseOver = this:GetChecked() == 1 and true or false
		end)
		MTH_ICU_OPT_STATE.controls.mouseOver = mouseOver
	end

	local sectionHeader = container:CreateFontString("MetaHuntOptionsICUSectionHeader", "ARTWORK", "GameFontHighlight")
	sectionHeader:SetPoint("TOPLEFT", container, "TOPLEFT", MTH_ICU_LAYOUT.LEFT_X, -146)
	sectionHeader:SetText("General Settings")

	MTH_ICU_CreateOptionRow(container, "MetaHuntOptionsICUAlert", "ALERT PVP", "ALERT", -172, MTH_ICU_LAYOUT.LEFT_X, MTH_ICU_LAYOUT.LEFT_DROPDOWN_X)
	MTH_ICU_CreateOptionRow(container, "MetaHuntOptionsICUAnnounce", "ANNOUNCE on click", "ANNOUNCE", -198, MTH_ICU_LAYOUT.LEFT_X, MTH_ICU_LAYOUT.LEFT_DROPDOWN_X)
	MTH_ICU_CreateOptionRow(container, "MetaHuntOptionsICUHealthMode", "Health text", "HEALTH_TEXT_MODE", -224, MTH_ICU_LAYOUT.LEFT_X, MTH_ICU_LAYOUT.LEFT_DROPDOWN_X)
	MTH_ICU_CreateOptionRow(container, "MetaHuntOptionsICUHideDelay", "List hide delay", "POPUP_HIDE_DELAY", -250, MTH_ICU_LAYOUT.LEFT_X, MTH_ICU_LAYOUT.LEFT_DROPDOWN_X)
	MTH_ICU_CreateOptionRow(container, "MetaHuntOptionsICUAnchor", "ANCHOR", "ANCHOR", -276, MTH_ICU_LAYOUT.LEFT_X, MTH_ICU_LAYOUT.LEFT_DROPDOWN_X)

	local toggleAnchorButton = CreateFrame("Button", "MetaHuntOptionsICUToggleAnchorButton", container, "UIPanelButtonTemplate")
	toggleAnchorButton:SetPoint("TOPLEFT", container, "TOPLEFT", MTH_ICU_LAYOUT.LEFT_X, -302)
	toggleAnchorButton:SetWidth(116)
	toggleAnchorButton:SetHeight(22)
	toggleAnchorButton:SetText("Toggle Anchor")
	toggleAnchorButton:SetScript("OnClick", function()
		if type(ICU_ToggleAnchor) == "function" then
			ICU_ToggleAnchor()
		end
	end)
	MTH_ICU_OPT_STATE.controls.customAnchorButton = toggleAnchorButton

	local expandUp = MTH_CreateCheckbox(container, "MetaHuntOptionsICUExpandUp", "Expand Up", -301, MTH_ICU_LAYOUT.LEFT_X + 132)
	if expandUp then
		expandUp:SetScript("OnClick", function()
			if not this then return end
			local store = MTH_ICU_GetStore()
			store.EXPAND_UP = this:GetChecked() == 1 and true or false
			if type(ICU_SetPoints) == "function" then
				ICU_SetPoints()
			end
		end)
		MTH_ICU_OPT_STATE.controls.expandUp = expandUp
	end

	local showGuild = MTH_CreateCheckbox(container, "MetaHuntOptionsICUShowGuild", "Show player guild names", -344, MTH_ICU_LAYOUT.LEFT_X)
	if showGuild then
		showGuild:SetScript("OnClick", function()
			if not this then return end
			local store = MTH_ICU_GetStore()
			store.SHOW_GUILD_NAME = this:GetChecked() == 1 and true or false
		end)
		MTH_ICU_OPT_STATE.controls.showGuildName = showGuild
	end

	local showClass = MTH_CreateCheckbox(container, "MetaHuntOptionsICUShowClass", "Show player class", -368, MTH_ICU_LAYOUT.LEFT_X)
	if showClass then
		showClass:SetScript("OnClick", function()
			if not this then return end
			local store = MTH_ICU_GetStore()
			store.SHOW_PLAYER_CLASS = this:GetChecked() == 1 and true or false
		end)
		MTH_ICU_OPT_STATE.controls.showPlayerClass = showClass
	end

	local showRace = MTH_CreateCheckbox(container, "MetaHuntOptionsICUShowRace", "Show player race", -392, MTH_ICU_LAYOUT.LEFT_X)
	if showRace then
		showRace:SetScript("OnClick", function()
			if not this then return end
			local store = MTH_ICU_GetStore()
			store.SHOW_PLAYER_RACE = this:GetChecked() == 1 and true or false
		end)
		MTH_ICU_OPT_STATE.controls.showPlayerRace = showRace
	end

	local showTitles = MTH_CreateCheckbox(container, "MetaHuntOptionsICUShowTitles", "Show custom titles in alerts", -416, MTH_ICU_LAYOUT.LEFT_X)
	if showTitles then
		showTitles:SetScript("OnClick", function()
			if not this then return end
			local store = MTH_ICU_GetStore()
			store.SHOW_CUSTOM_TITLES = this:GetChecked() == 1 and true or false
		end)
		MTH_ICU_OPT_STATE.controls.showCustomTitles = showTitles
	end

	local rightHeader = container:CreateFontString("MetaHuntOptionsICURightHeader", "ARTWORK", "GameFontHighlight")
	rightHeader:SetPoint("TOPLEFT", container, "TOPLEFT", MTH_ICU_LAYOUT.RIGHT_X, -146)
	rightHeader:SetText("Background Colors")

	MTH_ICU_CreateOptionRow(container, "MetaHuntOptionsICUPlayerColorMode", "Player colors", "PLAYER_COLOR_MODE", -172, MTH_ICU_LAYOUT.RIGHT_X, MTH_ICU_LAYOUT.RIGHT_DROPDOWN_X)

	local reactionOnlyPvp = MTH_CreateCheckbox(container, "MetaHuntOptionsICUReactionOnlyPvp", "Reaction only when PvP-flagged", -200, MTH_ICU_LAYOUT.RIGHT_X)
	if reactionOnlyPvp then
		reactionOnlyPvp:SetScript("OnClick", function()
			if not this then return end
			local store = MTH_ICU_GetStore()
			store.REACTION_ONLY_PVP_PLAYERS = this:GetChecked() == 1 and true or false
		end)
		MTH_ICU_OPT_STATE.controls.reactionOnlyPvp = reactionOnlyPvp
	end

	local colorHeader = container:CreateFontString("MetaHuntOptionsICUColorsHeader", "ARTWORK", "GameFontHighlight")
	colorHeader:SetPoint("TOPLEFT", container, "TOPLEFT", MTH_ICU_LAYOUT.RIGHT_X, -224)

	local colorScope = container:CreateFontString("MetaHuntOptionsICUColorsScope", "ARTWORK", "GameFontNormalSmall")
	colorScope:SetPoint("TOPLEFT", container, "TOPLEFT", MTH_ICU_LAYOUT.RIGHT_X, -242)
	colorScope:SetWidth(250)
	colorScope:SetJustifyH("LEFT")
	colorScope:SetJustifyV("TOP")
	colorScope:SetTextColor(0.35, 0.65, 1)
	colorScope:SetText("Player pickers: REACTION / FACTION / CUSTOM\nNPC pickers: always")

	local colorY = -284
	for i = 1, table.getn(MTH_ICU_COLOR_ROWS) do
		local row = MTH_ICU_COLOR_ROWS[i]
		MTH_ICU_CreateColorRow(container, "MetaHuntOptionsICUColor" .. tostring(i), row.label, row.key, colorY, MTH_ICU_LAYOUT.RIGHT_X, MTH_ICU_LAYOUT.COLOR_BUTTON_X)
		colorY = colorY - MTH_ICU_LAYOUT.COLOR_ROW_STEP
	end


end

function MTH_RefreshICUOptions()
	if not MTH_ICU_OPT_READY then return end

	local controls = MTH_ICU_OPT_STATE.controls
	if type(controls) ~= "table" then
		return
	end

	local store = MTH_ICU_GetStore()
	local moduleEnabled = MTH and MTH.IsModuleEnabled and MTH:IsModuleEnabled("icu", false) or false

	if controls.moduleEnabled then
		controls.moduleEnabled:SetChecked(moduleEnabled and 1 or nil)
	end

	if controls.mouseOver then
		controls.mouseOver:SetChecked(store.mouseOver and 1 or nil)
		if controls.mouseOver.Enable then
			if moduleEnabled then controls.mouseOver:Enable() else controls.mouseOver:Disable() end
		end
	end

	if controls.showGuildName then
		controls.showGuildName:SetChecked(store.SHOW_GUILD_NAME and 1 or nil)
		if controls.showGuildName.Enable then
			if moduleEnabled then controls.showGuildName:Enable() else controls.showGuildName:Disable() end
		end
	end

	if controls.showPlayerClass then
		controls.showPlayerClass:SetChecked(store.SHOW_PLAYER_CLASS and 1 or nil)
		if controls.showPlayerClass.Enable then
			if moduleEnabled then controls.showPlayerClass:Enable() else controls.showPlayerClass:Disable() end
		end
	end

	if controls.showPlayerRace then
		controls.showPlayerRace:SetChecked(store.SHOW_PLAYER_RACE and 1 or nil)
		if controls.showPlayerRace.Enable then
			if moduleEnabled then controls.showPlayerRace:Enable() else controls.showPlayerRace:Disable() end
		end
	end

	if controls.showCustomTitles then
		controls.showCustomTitles:SetChecked(store.SHOW_CUSTOM_TITLES and 1 or nil)
		if controls.showCustomTitles.Enable then
			if moduleEnabled then controls.showCustomTitles:Enable() else controls.showCustomTitles:Disable() end
		end
	end

	local isCustomAnchor = tostring(store.ANCHOR or "") == "CUSTOM"

	if controls.customAnchorButton then
		if moduleEnabled and isCustomAnchor then
			controls.customAnchorButton:Show()
			if controls.customAnchorButton.Enable then controls.customAnchorButton:Enable() end
		else
			controls.customAnchorButton:Hide()
		end
	end

	if controls.expandUp then
		controls.expandUp:SetChecked(store.EXPAND_UP and 1 or nil)
		if moduleEnabled and isCustomAnchor then
			controls.expandUp:Show()
			if controls.expandUp.Enable then controls.expandUp:Enable() end
		else
			controls.expandUp:Hide()
		end
	end

	local optionKeys = { "ALERT", "ANNOUNCE", "ANCHOR", "HEALTH_TEXT_MODE", "POPUP_HIDE_DELAY", "PLAYER_COLOR_MODE" }
	for i = 1, table.getn(optionKeys) do
		local key = optionKeys[i]
		local row = controls[key]
		if row and row.dropdown then
			MTH_ICU_DropdownSetText(row.dropdown, tostring(store[key] or ""))
			if UIDropDownMenu_EnableDropDown and UIDropDownMenu_DisableDropDown then
				if moduleEnabled then
					UIDropDownMenu_EnableDropDown(row.dropdown)
				else
					UIDropDownMenu_DisableDropDown(row.dropdown)
				end
			end
		end
	end

	if controls.reactionOnlyPvp then
		controls.reactionOnlyPvp:SetChecked(store.REACTION_ONLY_PVP_PLAYERS and 1 or nil)
		if controls.reactionOnlyPvp.Enable then
			if moduleEnabled and tostring(store.PLAYER_COLOR_MODE or "") == "REACTION" then
				controls.reactionOnlyPvp:Enable()
			else
				controls.reactionOnlyPvp:Disable()
			end
		end
	end

	for i = 1, table.getn(MTH_ICU_COLOR_ROWS) do
		local row = MTH_ICU_COLOR_ROWS[i]
		local ctrl = controls[row.key]
		if ctrl and ctrl.swatch then
			local r, g, b = MTH_ICU_GetColor(row.key)
			ctrl.swatch:SetVertexColor(r, g, b)
			if ctrl.button and ctrl.button.Enable then
				if moduleEnabled then ctrl.button:Enable() else ctrl.button:Disable() end
			end
		end
	end
end

function MTH_SetupICUOptions()
	local container = MTH_GetFrame("MetaHuntOptionsICU")
	if not container then return end

	if not MTH_ICU_OPT_READY then
		if type(MTH_ClearContainer) == "function" then
			MTH_ClearContainer(container)
		end
		local title = container:CreateFontString("MetaHuntOptionsICUErrorTitle", "ARTWORK", "GameFontHighlight")
		title:SetPoint("TOPLEFT", container, "TOPLEFT", 20, -10)
		title:SetText("MTH ICU")

		local body = container:CreateFontString("MetaHuntOptionsICUErrorBody", "ARTWORK", "GameFontNormalSmall")
		body:SetPoint("TOPLEFT", container, "TOPLEFT", 20, -34)
		body:SetWidth(620)
		body:SetJustifyH("LEFT")
		body:SetJustifyV("TOP")
		body:SetTextColor(1, 0.3, 0.3)
		body:SetText("ICU options cannot initialize. Missing dependencies: " .. table.concat(MTH_ICU_OPT_MISSING, ", "))
		return
	end

	local ok, err = pcall(function()
		MTH_ICU_BuildUI(container)
		MTH_RefreshICUOptions()
	end)
	if not ok then
		if MTH and MTH.Print then
			MTH:Print("[MTH ICU OPTIONS] setup failed: " .. tostring(err), "error")
		end
		if type(MTH_ClearContainer) == "function" then
			MTH_ClearContainer(container)
		end
		local title = container:CreateFontString("MetaHuntOptionsICUCrashTitle", "ARTWORK", "GameFontHighlight")
		title:SetPoint("TOPLEFT", container, "TOPLEFT", 20, -10)
		title:SetText("MTH ICU")
		local body = container:CreateFontString("MetaHuntOptionsICUCrashBody", "ARTWORK", "GameFontNormalSmall")
		body:SetPoint("TOPLEFT", container, "TOPLEFT", 20, -34)
		body:SetWidth(620)
		body:SetJustifyH("LEFT")
		body:SetJustifyV("TOP")
		body:SetTextColor(1, 0.3, 0.3)
		body:SetText("ICU options failed to render. Check chat/debug for details.")
	end
end
