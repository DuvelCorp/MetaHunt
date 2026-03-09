MTH_OPTIONS_TREE_STATE = MTH_OPTIONS_TREE_STATE or { zButtons = true, chronometer = true }
MTH_OPTIONS_TREE_BUTTONS = MTH_OPTIONS_TREE_BUTTONS or {}
MTH_OPTIONS_STATE = MTH_OPTIONS_STATE or {}
if MTH_OPTIONS_STATE.activeTab == nil and MTH_OPTIONS_ACTIVE_TAB ~= nil then
	MTH_OPTIONS_STATE.activeTab = MTH_OPTIONS_ACTIVE_TAB
end
MTH_OPTIONS_ACTIVE_TAB = MTH_OPTIONS_STATE.activeTab
MTH_OPTIONS_CONST = MTH_OPTIONS_CONST or {
	NAV_DEFAULT_WIDTH = 120,
	NAV_INNER_PADDING = 16,
	TREE_START_Y = -10,
	TREE_BUTTON_HEIGHT = 20,
	TREE_ROW_STEP = 22,
	TREE_INDENT_BASE = 8,
	TREE_CHILD_INDENT = 14,
	HIGHLIGHT_ALPHA = 0.25,
	SELECTED_BG_R = 0.35,
	SELECTED_BG_G = 0.25,
	SELECTED_BG_B = 0.10,
	SELECTED_BG_A = 0.55,
	SELECTED_TEXT_R = 1.00,
	SELECTED_TEXT_G = 0.82,
	SELECTED_TEXT_B = 0.00,
	GROUP_TEXT_R = 1.00,
	GROUP_TEXT_G = 0.82,
	GROUP_TEXT_B = 0.00,
}

MTH_OPTIONS_TABS = MTH_OPTIONS_TABS or {
	{ key = "General", label = "General", frame = "MetaHuntOptionsGeneral" },
	{ key = "Messages", label = "Messages", frame = "MetaHuntOptionsMessages" },
	{ key = "Pet", label = "ZPet", frame = "MetaHuntOptionsPet" },
	{ key = "Track", label = "ZTrack", frame = "MetaHuntOptionsTrack" },
	{ key = "Aspect", label = "ZAspect", frame = "MetaHuntOptionsAspect" },
	{ key = "Trap", label = "ZTrap", frame = "MetaHuntOptionsTrap" },
	{ key = "Ranged", label = "ZRanged", frame = "MetaHuntOptionsRanged" },
	{ key = "Ammo", label = "ZAmmo", frame = "MetaHuntOptionsAmmo" },
	{ key = "Mounts", label = "ZMounts", frame = "MetaHuntOptionsMounts" },
	{ key = "Companions", label = "ZCompanions", frame = "MetaHuntOptionsCompanions" },
	{ key = "Toys", label = "ZToys", frame = "MetaHuntOptionsToys" },
	{ key = "SmartAmmo", label = "Smart Ammo", frame = "MetaHuntOptionsSmartAmmo" },
	{ key = "FeedOMatic", label = "FeedOMatic", frame = "MetaHuntOptionsFeedOMatic" },
	{ key = "AutoBuy", label = "Auto Buy", frame = "MetaHuntOptionsAutoBuy" },
	{ key = "AutoQuest", label = "Auto Quest", frame = "MetaHuntOptionsAutoQuest" },
	{ key = "ICU", label = "ICU", frame = "MetaHuntOptionsICU" },
	{ key = "ChronometerGeneral", label = "General", frame = "MetaHuntOptionsChronometer" },
	{ key = "ChronometerBar", label = "Bar", frame = "MetaHuntOptionsChronometer" },
	{ key = "ChronometerClassSpells", label = "Hunter Spells", frame = "MetaHuntOptionsChronometer" },
	{ key = "ChronometerClassEvents", label = "Hunter Events", frame = "MetaHuntOptionsChronometer" },
	{ key = "ChronometerRacial", label = "Racial", frame = "MetaHuntOptionsChronometer" },
	{ key = "Credits", label = "Credits", frame = "MetaHuntOptionsCredits" },
}

MTH_OPTIONS_TREE = MTH_OPTIONS_TREE or {
	{ label = "General", key = "General" },
	{ label = "Messages", key = "Messages" },
	{ label = "Auto Buy", key = "AutoBuy" },
	{ label = "Auto Quest", key = "AutoQuest" },
	{ label = "Feed-O-Matic", key = "FeedOMatic" },
	{ label = "ICU", key = "ICU" },
	{
		label = "zButtons",
		node = "zButtons",
		children = {
			{ label = "zAmmo", key = "Ammo" },
			{ label = "zPet", key = "Pet" },
			{ label = "zAspect", key = "Aspect" },
			{ label = "zTrack", key = "Track" },
			{ label = "zTrap", key = "Trap" },
			{ label = "zRanged", key = "Ranged" },
			{ label = "zMounts", key = "Mounts" },
			{ label = "zCompanions", key = "Companions" },
			{ label = "zToys", key = "Toys" },
		},
	},
	{
		label = "Chronometer",
		node = "chronometer",
		children = {
			{ label = "General", key = "ChronometerGeneral" },
			{ label = "Bar", key = "ChronometerBar" },
			{ label = "Hunter Spells", key = "ChronometerClassSpells" },
			{ label = "Hunter Events", key = "ChronometerClassEvents" },
			{ label = "Racial", key = "ChronometerRacial" },
		},
	},
	{ label = "Credits", key = "Credits" },
}

function MTH_BuildOptionsTree()
	local nav = MTH_GetFrame and MTH_GetFrame("MetaHuntOptionsNav") or nil
	if not nav then
		return
	end
	local navInnerWidth = (nav:GetWidth() or MTH_OPTIONS_CONST.NAV_DEFAULT_WIDTH) - MTH_OPTIONS_CONST.NAV_INNER_PADDING

	local yOffset = MTH_OPTIONS_CONST.TREE_START_Y
	local buttonIndex = 1

	local function acquireButton()
		local button = MTH_OPTIONS_TREE_BUTTONS[buttonIndex]
		if not button then
			button = CreateFrame("Button", "MetaHuntOptionsNavItem"..buttonIndex, nav)
			button:SetHeight(MTH_OPTIONS_CONST.TREE_BUTTON_HEIGHT)
			button:SetNormalTexture("")
			button:SetPushedTexture("")
			button:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
			button.highlight = button:GetHighlightTexture()
			if button.highlight then
				button.highlight:SetBlendMode("ADD")
				button.highlight:SetVertexColor(1, 1, 1, MTH_OPTIONS_CONST.HIGHLIGHT_ALPHA)
			end

			button.selectedTexture = button:CreateTexture(nil, "BACKGROUND")
			button.selectedTexture:SetTexture("Interface\\Buttons\\WHITE8X8")
			button.selectedTexture:SetVertexColor(MTH_OPTIONS_CONST.SELECTED_BG_R, MTH_OPTIONS_CONST.SELECTED_BG_G, MTH_OPTIONS_CONST.SELECTED_BG_B, MTH_OPTIONS_CONST.SELECTED_BG_A)
			button.selectedTexture:SetPoint("TOPLEFT", button, "TOPLEFT", 0, -1)
			button.selectedTexture:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, 1)
			button.selectedTexture:Hide()

			button.expander = button:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
			button.expander:SetPoint("LEFT", button, "LEFT", 4, 0)

			button.label = button:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
			button.label:SetJustifyH("LEFT")
			button.label:SetPoint("LEFT", button, "LEFT", 18, 0)
			button.label:SetPoint("RIGHT", button, "RIGHT", -4, 0)

			MTH_OPTIONS_TREE_BUTTONS[buttonIndex] = button
		end
		button:Show()
		buttonIndex = buttonIndex + 1
		return button
	end

	local function placeLeaf(node, indent)
		local button = acquireButton()
		local xOffset = MTH_OPTIONS_CONST.TREE_INDENT_BASE + (indent or 0)
		local width = navInnerWidth - (indent or 0)
		button:ClearAllPoints()
		button:SetPoint("TOPLEFT", nav, "TOPLEFT", xOffset, yOffset)
		button:SetWidth(width)
		button.expander:SetText("")
		button.label:SetPoint("LEFT", button, "LEFT", 4, 0)
		button.label:SetText(node.label)
		button:SetScript("OnClick", function() MTH_SelectOptionsTab(node.key) end)
		if MTH_OPTIONS_STATE.activeTab == node.key then
			button.selectedTexture:Show()
			button.label:SetTextColor(MTH_OPTIONS_CONST.SELECTED_TEXT_R, MTH_OPTIONS_CONST.SELECTED_TEXT_G, MTH_OPTIONS_CONST.SELECTED_TEXT_B)
		else
			button.selectedTexture:Hide()
			button.label:SetTextColor(1, 1, 1)
		end
		button.expander:SetTextColor(1, 1, 1)
		yOffset = yOffset - MTH_OPTIONS_CONST.TREE_ROW_STEP
	end

	for i = 1, table.getn(MTH_OPTIONS_TREE) do
		local node = MTH_OPTIONS_TREE[i]
		if node.children then
			local expanded = MTH_OPTIONS_TREE_STATE[node.node] and true or false
			local button = acquireButton()
			button:ClearAllPoints()
			button:SetPoint("TOPLEFT", nav, "TOPLEFT", MTH_OPTIONS_CONST.TREE_INDENT_BASE, yOffset)
			button:SetWidth(navInnerWidth)
			button.expander:SetText(expanded and "-" or "+")
			button.expander:SetTextColor(MTH_OPTIONS_CONST.GROUP_TEXT_R, MTH_OPTIONS_CONST.GROUP_TEXT_G, MTH_OPTIONS_CONST.GROUP_TEXT_B)
			button.label:SetPoint("LEFT", button, "LEFT", 18, 0)
			button.label:SetText(node.label)
			button.label:SetTextColor(MTH_OPTIONS_CONST.GROUP_TEXT_R, MTH_OPTIONS_CONST.GROUP_TEXT_G, MTH_OPTIONS_CONST.GROUP_TEXT_B)
			button.selectedTexture:Hide()
			button:SetScript("OnClick", function()
				MTH_OPTIONS_TREE_STATE[node.node] = not MTH_OPTIONS_TREE_STATE[node.node]
				MTH_BuildOptionsTree()
			end)
			yOffset = yOffset - MTH_OPTIONS_CONST.TREE_ROW_STEP
			if expanded then
				for j = 1, table.getn(node.children) do
					placeLeaf(node.children[j], MTH_OPTIONS_CONST.TREE_CHILD_INDENT)
				end
			end
		else
			placeLeaf(node, 0)
		end
	end

	for i = buttonIndex, table.getn(MTH_OPTIONS_TREE_BUTTONS) do
		if MTH_OPTIONS_TREE_BUTTONS[i] then
			MTH_OPTIONS_TREE_BUTTONS[i]:Hide()
		end
	end
end
