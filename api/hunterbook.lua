-- MetaHunt standalone Hunter Book UI (XML + Lua)

MTH_HUNTERBOOK_LOADED = true
MTH_HUNTERBOOK_TABS = MTH_HUNTERBOOK_TABS or {}

local function MTH_BOOK_GetTabDefinition(mode)
	if type(MTH_HUNTERBOOK_TABS) ~= "table" then return nil end
	return MTH_HUNTERBOOK_TABS[tostring(mode or "")]
end

local function MTH_BOOK_IsItemMode(mode)
	local resolved = tostring(mode or (MTH_BOOK_STATE and MTH_BOOK_STATE.mode) or "")
	return resolved == "items" or resolved == "projectiles" or resolved == "ammobags"
end

MTH_BOOK_Browser = nil
local MTH_BOOK_RefreshFilter
local MTH_BOOK_UpdateResults
local MTH_BOOK_GetZoneName
local MTH_BOOK_GetPlayerLevelValue
local MTH_BOOK_IsSpellInLevelScope
local MTH_BOOK_GetScopedRankSummary
local MTH_BOOK_BEAST_DATABASE_URL = "https://database.turtlecraft.gg/?npc=%d"
local MTH_BOOK_NPC_DATABASE_URL = "https://database.turtlecraft.gg/?npc=%d"
local MTH_BOOK_ITEM_DATABASE_URL = "https://database.turtlecraft.gg/?item=%d"
local MTH_BOOK_STABLE_CURRENT_ID_CACHE = nil

local MTH_BOOK_FALLBACK_BAG_ITEMS = {
	[2101] = { name = "Light Quiver", subtype = "quiver", slots = 6, reqlevel = nil, quality = 1, sourceUrl = "https://database.turtlecraft.gg/?item=2101" },
	[2102] = { name = "Small Ammo Pouch", subtype = "ammo pouch", slots = 6, reqlevel = nil, quality = 1, sourceUrl = "https://database.turtlecraft.gg/?item=2102" },
	[2662] = { name = "Ribbly's Quiver", subtype = "quiver", slots = 16, reqlevel = 50, quality = 2, sourceUrl = "https://database.turtlecraft.gg/?item=2662" },
	[2663] = { name = "Ribbly's Bandolier", subtype = "ammo pouch", slots = 16, reqlevel = 50, quality = 2, sourceUrl = "https://database.turtlecraft.gg/?item=2663" },
	[3573] = { name = "Hunting Quiver", subtype = "quiver", slots = 10, reqlevel = nil, quality = 1, sourceUrl = "https://database.turtlecraft.gg/?item=3573" },
	[3574] = { name = "Hunting Ammo Sack", subtype = "ammo pouch", slots = 10, reqlevel = nil, quality = 1, sourceUrl = "https://database.turtlecraft.gg/?item=3574" },
	[3604] = { name = "Bandolier of the Night Watch", subtype = "ammo pouch", slots = 12, reqlevel = nil, quality = 2, sourceUrl = "https://database.turtlecraft.gg/?item=3604" },
	[3605] = { name = "Quiver of the Night Watch", subtype = "quiver", slots = 12, reqlevel = nil, quality = 2, sourceUrl = "https://database.turtlecraft.gg/?item=3605" },
	[5439] = { name = "Small Quiver", subtype = "quiver", slots = 8, reqlevel = nil, quality = 1, sourceUrl = "https://database.turtlecraft.gg/?item=5439" },
	[5441] = { name = "Small Shot Pouch", subtype = "ammo pouch", slots = 8, reqlevel = nil, quality = 1, sourceUrl = "https://database.turtlecraft.gg/?item=5441" },
	[7278] = { name = "Light Leather Quiver", subtype = "quiver", slots = 8, reqlevel = nil, quality = 1, sourceUrl = "https://database.turtlecraft.gg/?item=7278" },
	[7279] = { name = "Small Leather Ammo Pouch", subtype = "ammo pouch", slots = 8, reqlevel = nil, quality = 1, sourceUrl = "https://database.turtlecraft.gg/?item=7279" },
	[7371] = { name = "Heavy Quiver", subtype = "quiver", slots = 14, reqlevel = 30, quality = 2, sourceUrl = "https://database.turtlecraft.gg/?item=7371" },
	[7372] = { name = "Heavy Leather Ammo Pouch", subtype = "ammo pouch", slots = 14, reqlevel = 30, quality = 2, sourceUrl = "https://database.turtlecraft.gg/?item=7372" },
	[8217] = { name = "Quickdraw Quiver", subtype = "quiver", slots = 16, reqlevel = 40, quality = 2, sourceUrl = "https://database.turtlecraft.gg/?item=8217" },
	[8218] = { name = "Thick Leather Ammo Pouch", subtype = "ammo pouch", slots = 16, reqlevel = 40, quality = 2, sourceUrl = "https://database.turtlecraft.gg/?item=8218" },
	[11362] = { name = "Medium Quiver", subtype = "quiver", slots = 10, reqlevel = 10, quality = 1, sourceUrl = "https://database.turtlecraft.gg/?item=11362" },
	[11363] = { name = "Medium Shot Pouch", subtype = "ammo pouch", slots = 10, reqlevel = 10, quality = 1, sourceUrl = "https://database.turtlecraft.gg/?item=11363" },
	[18714] = { name = "Ancient Sinew Wrapped Lamina", subtype = "quiver", slots = 18, reqlevel = 60, quality = 4, sourceUrl = "https://database.turtlecraft.gg/?item=18714" },
	[19319] = { name = "Harpy Hide Quiver", subtype = "quiver", slots = 16, reqlevel = 55, quality = 3, sourceUrl = "https://database.turtlecraft.gg/?item=19319" },
	[19320] = { name = "Gnoll Skin Bandolier", subtype = "ammo pouch", slots = 16, reqlevel = 55, quality = 3, sourceUrl = "https://database.turtlecraft.gg/?item=19320" },
	[61549] = { name = "Swiftfeather Quiver", subtype = "quiver", slots = 16, reqlevel = 57, quality = 3, sourceUrl = "https://database.turtlecraft.gg/?item=61549" },
}

local function MTH_BOOK_FamiliesTrace(message)
	return
end

local MTH_BOOK_STATE = {
	mode = "stable",
	search = "",
	quick = "all",
	minLevel = nil,
	maxLevel = nil,
	flag1 = false,
	flag2 = false,
	flag3 = false,
	petAbility = "all",
	petRank = "all",
	petLearnSource = "beast",
	petOnlyMyLevel = true,
	itemOnlyMyLevel = false,
	petInZoneOnly = false,
	itemSubtype = "all",
	npcFunction = "all",
	npcZone = "all",
	npcInZoneOnly = false,
	npcHideNoZone = true,
	petHideNoAbilities = true,
	petHideUnknown = true,
	forcedBeastId = nil,
	page = 1,
	pageSize = 16,
	petLeftOffset = 0,
	results = {},
	selectedEntry = nil,
	selectedPetRankEntry = nil,
	petRankRows = {},
	petUI = nil,
	stableUI = nil,
	buttons = {},
	headerCols = {},
	headerButtons = {},
	sortByMode = {
		pets = { col = nil, asc = true },
		families = { col = nil, asc = true },
		abilities = { col = nil, asc = true },
		items = { col = nil, asc = true },
		projectiles = { col = nil, asc = true },
		ammobags = { col = nil, asc = true },
		npcs = { col = nil, asc = true },
		stable = { col = nil, asc = true },
		pethistory = { col = 5, asc = false },
	},
	sliderDragging = false,
}

_G.MTH_BOOK_STATE = MTH_BOOK_STATE

local function MTH_HB_ReportGuard(message)
	local text = "[MTH HUNTERBOOK] " .. tostring(message)
	if MTH and MTH.Print then
		MTH:Print(text, "error")
	elseif type(MTH_Log) == "function" then
		MTH_Log(text, "error")
	elseif DEFAULT_CHAT_FRAME and DEFAULT_CHAT_FRAME.AddMessage then
		DEFAULT_CHAT_FRAME:AddMessage(text)
	end
end

function MTH_BOOK_DebugTrace(message)
	return
end

local function MTH_BOOK_GetLoyaltyNameByLevel(level)
	local resolvedLevel = tonumber(level)
	if not resolvedLevel or resolvedLevel < 1 or resolvedLevel > 6 then
		return "-"
	end
	local key = "PET_LOYALTY" .. tostring(resolvedLevel)
	local name = (_G and _G[key]) or (type(getglobal) == "function" and getglobal(key))
	name = tostring(name or "")
	if name == "" then
		local defaults = {
			[1] = "Rebellious",
			[2] = "Unruly",
			[3] = "Submissive",
			[4] = "Dependable",
			[5] = "Faithful",
			[6] = "Best Friend",
		}
		name = defaults[resolvedLevel] or "-"
	end
	return tostring(name)
end

local function MTH_HB_RequireOpenDeps()
	if type(MTH_BOOK_RefreshFilter) ~= "function" then
		MTH_HB_ReportGuard("Missing dependency: MTH_BOOK_RefreshFilter")
		return false
	end
	return true
end

local MTH_BOOK_MAX_COLS = 9
local MTH_BOOK_MAX_ROWS = 20

local MTH_BOOK_PetFamilyOptions = {
	{ value = "all", label = "All Families" },
}

local MTH_BOOK_PetAbilityOptions = {
	{ value = "all", label = "All Abilities" },
}

local MTH_BOOK_PetRankOptions = {
	{ value = "all", label = "All Ranks" },
}

local MTH_BOOK_PetLearnSourceOptions = {
	{ value = "all", label = "All Abilities" },
	{ value = "beast", label = "Beast Learned" },
	{ value = "trainer", label = "Trainer Learned" },
}

local MTH_BOOK_NPCFunctionOptions = {
	{ value = "all", label = "All Hunter Friends" },
	{ value = "huntertrainer", label = "Hunter Trainer" },
	{ value = "pettrainer", label = "Pet Trainer" },
	{ value = "vendor", label = "Ammo Vendor" },
}

local MTH_BOOK_NPCZoneOptions = {
	{ value = "all", label = "All Zones" },
}

local MTH_BOOK_ItemSubtypeOptions = {
	{ value = "all", label = "All Ranged" },
	{ value = "bow", label = "Bow" },
	{ value = "gun", label = "Gun" },
	{ value = "crossbow", label = "Crossbow" },
}

local MTH_BOOK_ItemSubtypeOptionsProjectiles = {
	{ value = "all", label = "All Projectiles" },
	{ value = "arrow", label = "Arrow" },
	{ value = "bullet", label = "Bullet" },
}

local MTH_BOOK_ItemSubtypeOptionsAmmoBags = {
	{ value = "all", label = "All Ammo Bags" },
	{ value = "quiver", label = "Quiver" },
	{ value = "ammopouch", label = "Ammo Pouch" },
}

local function MTH_BOOK_GetItemSubtypeOptions(mode)
	local resolved = tostring(mode or MTH_BOOK_STATE.mode or "")
	if resolved == "projectiles" then
		return MTH_BOOK_ItemSubtypeOptionsProjectiles
	end
	if resolved == "ammobags" then
		return MTH_BOOK_ItemSubtypeOptionsAmmoBags
	end
	return MTH_BOOK_ItemSubtypeOptions
end

local MTH_BOOK_PetAbilityRanks = {}

local MTH_BOOK_CONTENT_LAYOUT_DEFAULT = {
	listX = 16,
	listY = -166,
	listW = 564,
	listH = 354,
	detailX = 608,
	detailY = -166,
	detailW = 136,
	detailH = 324,
}

local MTH_BOOK_CONTENT_LAYOUT_ITEMS = {
	listX = 16,
	listY = -124,
	listW = 564,
	listH = 396,
	detailX = 608,
	detailY = -124,
	detailW = 136,
	detailH = 366,
}

local MTH_BOOK_CONTENT_LAYOUT_PETABILITIES = {
	listX = 16,
	listY = -106,
	listW = 564,
	listH = 424,
	detailX = 608,
	detailY = -106,
	detailW = 136,
	detailH = 424,
}

local MTH_BOOK_CONTENT_LAYOUT_NPCS = {
	listX = 16,
	listY = -142,
	listW = 564,
	listH = 378,
	detailX = 608,
	detailY = -142,
	detailW = 136,
	detailH = 348,
}

local MTH_BOOK_CONTENT_LAYOUT_STABLE = {
	listX = 16,
	listY = -74,
	listW = 728,
	listH = 456,
	detailX = 748,
	detailY = -74,
	detailW = 1,
	detailH = 1,
}

local MTH_BOOK_CONTENT_LAYOUT_FAMILIES = {
	listX = 16,
	listY = -74,
	listW = 728,
	listH = 376,
	detailX = 748,
	detailY = -74,
	detailW = 1,
	detailH = 1,
}

local MTH_BOOK_CONTENT_LAYOUT_HISTORY = {
	listX = 16,
	listY = -74,
	listW = 520,
	listH = 446,
	detailX = 564,
	detailY = -74,
	detailW = 180,
	detailH = 446,
}

local function MTH_BOOK_ApplyContentLayoutForMode()
	local listParent = getglobal("MTH_BOOK_ListBackdrop")
	local detailParent = getglobal("MTH_BOOK_DetailBackdrop")
	local detailText = getglobal("MTH_BOOK_DetailBackdropDetailText")
	local sliderBackdrop = getglobal("MTH_BOOK_ListSliderBackdrop")
	local listSlider = getglobal("MTH_BOOK_ListSlider")
	if not (listParent and detailParent) then return end

	local layout = MTH_BOOK_CONTENT_LAYOUT_DEFAULT
	if MTH_BOOK_STATE.mode == "petabilities" then
		layout = MTH_BOOK_CONTENT_LAYOUT_PETABILITIES
	elseif MTH_BOOK_IsItemMode() then
		layout = MTH_BOOK_CONTENT_LAYOUT_ITEMS
	elseif MTH_BOOK_STATE.mode == "npcs" then
		layout = MTH_BOOK_CONTENT_LAYOUT_NPCS
	elseif MTH_BOOK_STATE.mode == "families" then
		layout = MTH_BOOK_CONTENT_LAYOUT_FAMILIES
	elseif MTH_BOOK_STATE.mode == "stable" then
		layout = MTH_BOOK_CONTENT_LAYOUT_STABLE
	elseif MTH_BOOK_STATE.mode == "pethistory" then
		layout = MTH_BOOK_CONTENT_LAYOUT_HISTORY
	end

	local browserFrame = listParent:GetParent()
	listParent:ClearAllPoints()
	listParent:SetPoint("TOPLEFT", browserFrame, "TOPLEFT", layout.listX, layout.listY)
	listParent:SetWidth(layout.listW)
	listParent:SetHeight(layout.listH)

	detailParent:ClearAllPoints()
	detailParent:SetPoint("TOPLEFT", browserFrame, "TOPLEFT", layout.detailX, layout.detailY)
	detailParent:SetWidth(layout.detailW)
	detailParent:SetHeight(layout.detailH)
	if detailText then
		detailText:ClearAllPoints()
		detailText:SetPoint("TOPLEFT", detailParent, "TOPLEFT", 6, -6)
		detailText:SetWidth(layout.detailW - 12)
		detailText:SetHeight(layout.detailH - 12)
	end

	local sliderHeight = layout.listH - 32
	if sliderHeight < 120 then sliderHeight = 120 end
	if sliderBackdrop then
		sliderBackdrop:SetHeight(sliderHeight)
	end
	if listSlider then
		listSlider:SetHeight(sliderHeight)
	end

	if MTH_BOOK_STATE.petUI then
		local paneHeight = layout.listH - 8
		if paneHeight < 200 then paneHeight = 200 end
		if MTH_BOOK_STATE.petUI.leftPane then MTH_BOOK_STATE.petUI.leftPane:SetHeight(paneHeight) end
		if MTH_BOOK_STATE.petUI.rightPane then MTH_BOOK_STATE.petUI.rightPane:SetHeight(paneHeight) end

		local detailAvailable = layout.detailH - 60
		if detailAvailable < 120 then detailAvailable = 120 end
		local topHeight = math.floor(detailAvailable * 0.54)
		local bottomHeight = detailAvailable - topHeight
		if MTH_BOOK_STATE.petUI.detailTop then MTH_BOOK_STATE.petUI.detailTop:SetHeight(topHeight) end
		if MTH_BOOK_STATE.petUI.detailBottom then MTH_BOOK_STATE.petUI.detailBottom:SetHeight(bottomHeight) end
	end
end

local function MTH_BOOK_UpdateCheckboxLayoutByMode()
	local controls = {
		getglobal("MTH_BOOK_RequireVendor"),
		getglobal("MTH_BOOK_RequireDrop"),
		getglobal("MTH_BOOK_RequireObject"),
		getglobal("MTH_BOOK_HideNoAbilities"),
		getglobal("MTH_BOOK_HideUnknown"),
	}
	local xOffsets = { 18, 86, 154, 232, 372 }
	local yOffset = -140
	if MTH_BOOK_STATE.mode == "npcs" then
		yOffset = -116
	end
	for i = 1, table.getn(controls) do
		local control = controls[i]
		if control then
			control:ClearAllPoints()
			control:SetPoint("TOPLEFT", control:GetParent(), "TOPLEFT", xOffsets[i], yOffset)
		end
	end
end

local function MTH_BOOK_DropdownSetText(frame, text)
	local value = text or ""
	if frame and frame.GetName then
		local frameName = frame:GetName()
		local txt = getglobal(frameName .. "Text")
		if txt and txt.SetText then
			txt:SetText(value)
		end
		local button = getglobal(frameName .. "Button")
		if button and button.GetFontString and button:GetFontString() and button:GetFontString().SetText then
			button:GetFontString():SetText(value)
		end
		local buttonText = getglobal(frameName .. "ButtonNormalText")
		if buttonText and buttonText.SetText then
			buttonText:SetText(value)
		end
	end
	if frame and frame.Text and frame.Text.SetText then
		frame.Text:SetText(value)
	end
end

local function MTH_BOOK_DropdownCreateInfo()
	local createInfo = _G["UIDropDownMenu_CreateInfo"]
	if createInfo then return createInfo() end
	return {}
end

local function MTH_BOOK_SetSliderFromCursor(slider)
	if not slider then return end
	local minValue, maxValue = slider:GetMinMaxValues()
	if not minValue or not maxValue then return end
	if maxValue <= minValue then
		slider:SetValue(minValue)
		return
	end
	local cursorX, cursorY = GetCursorPosition()
	local scale = slider:GetEffectiveScale() or 1
	local y = cursorY / scale
	local bottom = slider:GetBottom()
	local top = slider:GetTop()
	if not bottom or not top or top <= bottom then return end
	local pct = (y - bottom) / (top - bottom)
	if pct < 0 then pct = 0 end
	if pct > 1 then pct = 1 end
	local value = minValue + (maxValue - minValue) * (1 - pct)
	slider:SetValue(value)
end

local function MTH_BOOK_UpdateSliderMarker(slider)
	if not slider then return end
	local lane = getglobal("MTH_BOOK_ListSliderBackdrop")
	if not lane then return end

	if not lane._mthMarker then
		lane._mthMarker = lane:CreateTexture(nil, "ARTWORK")
		lane._mthMarker:SetTexture("Interface\\Buttons\\WHITE8X8")
		lane._mthMarker:SetWidth(14)
		lane._mthMarker:SetHeight(3)
		lane._mthMarker:SetVertexColor(1.00, 0.82, 0.00, 0.90)
	end

	local marker = lane._mthMarker
	local minValue, maxValue = slider:GetMinMaxValues()
	local value = slider:GetValue() or minValue or 1
	if not minValue or not maxValue or maxValue <= minValue then
		marker:ClearAllPoints()
		marker:SetPoint("TOP", lane, "TOP", 0, -4)
		marker:Show()
		return
	end

	local pct = (value - minValue) / (maxValue - minValue)
	if pct < 0 then pct = 0 end
	if pct > 1 then pct = 1 end

	local travel = lane:GetHeight() - 8 - 8
	if travel < 0 then travel = 0 end

	marker:ClearAllPoints()
	marker:SetPoint("BOTTOM", lane, "BOTTOM", 0, 4 + (travel * (1 - pct)))
	marker:Show()
end

local function MTH_BOOK_HideSliderTemplateTexts()
	local sliderLow = getglobal("MTH_BOOK_ListSliderLow")
	local sliderHigh = getglobal("MTH_BOOK_ListSliderHigh")
	local sliderText = getglobal("MTH_BOOK_ListSliderText")
	if sliderLow then sliderLow:Hide() end
	if sliderHigh then sliderHigh:Hide() end
	if sliderText then sliderText:Hide() end
end

local function MTH_BOOK_SetFontSizeDelta(fontString, delta)
	if not (fontString and fontString.GetFont and fontString.SetFont) then return end
	local baseFont = fontString._mthBaseFont
	local baseSize = fontString._mthBaseSize
	local baseFlags = fontString._mthBaseFlags
	if not baseFont or not baseSize then
		local currentFont, currentSize, currentFlags = fontString:GetFont()
		if not currentFont or not currentSize then return end
		baseFont = currentFont
		baseSize = currentSize
		baseFlags = currentFlags
		fontString._mthBaseFont = baseFont
		fontString._mthBaseSize = baseSize
		fontString._mthBaseFlags = baseFlags
	end
	fontString:SetFont(baseFont, baseSize + (delta or 0), baseFlags)
end

local function MTH_BOOK_SetFamiliesListVisualScale(enabled)
	local rowHeight = enabled and 20 or 19
	local textHeight = enabled and 15 or 14
	local iconSize = enabled and 15 or 14
	local chipHeight = enabled and 15 or 14
	local chipIcon = enabled and 13 or 12
	local fontDelta = enabled and 1 or 0

	for i = 1, MTH_BOOK_MAX_COLS do
		local header = MTH_BOOK_STATE.headerCols and MTH_BOOK_STATE.headerCols[i] or nil
		if header then
			header:SetHeight(textHeight)
			MTH_BOOK_SetFontSizeDelta(header, fontDelta)
		end
	end

	for i = 1, table.getn(MTH_BOOK_STATE.buttons or {}) do
		local button = MTH_BOOK_STATE.buttons[i]
		if button then
			button:SetHeight(rowHeight)
			if button.bookLinkButton then button.bookLinkButton:SetHeight(rowHeight) end
			if button.nameHoverButton then button.nameHoverButton:SetHeight(rowHeight) end
			if button.itemLinkButton then button.itemLinkButton:SetHeight(rowHeight) end
			if button.itemIcon then
				button.itemIcon:SetWidth(iconSize)
				button.itemIcon:SetHeight(iconSize)
			end
			for c = 1, table.getn(button.cols or {}) do
				local col = button.cols[c]
				if col then
					col:SetHeight(textHeight)
					MTH_BOOK_SetFontSizeDelta(col, fontDelta)
				end
			end
			for chipIndex = 1, table.getn(button.familyAbilityButtons or {}) do
				local chip = button.familyAbilityButtons[chipIndex]
				if chip then
					chip:SetHeight(chipHeight)
					if chip.icon then
						chip.icon:SetWidth(chipIcon)
						chip.icon:SetHeight(chipIcon)
					end
					if chip.text then
						MTH_BOOK_SetFontSizeDelta(chip.text, fontDelta)
					end
				end
			end
		end
	end
end


local function MTH_BOOK_OpenNPCLink(npcId)
	local id = tonumber(npcId)
	if not id then return end
	local url = string.format(MTH_BOOK_NPC_DATABASE_URL, id)
	local chatEditBox = _G["ChatFrameEditBox"]

	if chatEditBox then
		chatEditBox:Show()
		chatEditBox:SetText(url)
		chatEditBox:HighlightText()
	end

	if DEFAULT_CHAT_FRAME then
		MTH:Print("[MetaHunt Book] " .. url)
	end
end

local function MTH_BOOK_OpenItemDatabaseLink(itemId)
	local id = tonumber(itemId)
	if not id then return end
	local url = string.format(MTH_BOOK_ITEM_DATABASE_URL, id)
	local chatEditBox = _G["ChatFrameEditBox"]

	if chatEditBox then
		chatEditBox:Show()
		chatEditBox:SetText(url)
		chatEditBox:HighlightText()
	end

	if DEFAULT_CHAT_FRAME then
		MTH:Print("[MetaHunt Book] " .. url)
	end
end

local function MTH_BOOK_InsertItemLinkToChat(itemId)
	local id = tonumber(itemId)
	if not id then return false end

	local itemName = nil
	local items = _G["MTH_DS_Items"] or MTH_DS_AmmoItems
	if items and items[id] and items[id].name then
		itemName = items[id].name
	end

	local itemLink = nil
	if type(MTH_GetClickableItemLink) == "function" then
		itemLink = MTH_GetClickableItemLink(id, itemName, true)
	end
	if not itemLink or itemLink == "" then return false end

	if type(MTH_InsertLinkToChat) == "function" then
		return MTH_InsertLinkToChat(itemLink)
	end

	local chatEditBox = _G["ChatFrameEditBox"]
	if chatEditBox then
		chatEditBox:Show()
		chatEditBox:SetText(itemLink)
		chatEditBox:HighlightText()
		return true
	end

	return false
end

local function MTH_BOOK_ShowItemTooltip(anchorFrame, itemId)
	local id = tonumber(itemId)
	if not id then return end
	if not GameTooltip then return end
	if type(MTH_PrimeItemCache) == "function" then
		MTH_PrimeItemCache(id)
	end
	GameTooltip:SetOwner(anchorFrame or UIParent, "ANCHOR_CURSOR")
	GameTooltip:SetHyperlink("item:" .. tostring(id) .. ":0:0:0")
	GameTooltip:Show()
end

local function MTH_BOOK_HideItemTooltip()
	if GameTooltip then
		GameTooltip:Hide()
	end
end

local function MTH_BOOK_GetSelectedBeastForMap()
	if MTH_BOOK_STATE.mode ~= "pets" then return nil, nil end
	local selected = MTH_BOOK_STATE.selectedEntry
	if not selected or not selected.beastId then return nil, nil end
	local beastId = tonumber(selected.beastId)
	if not beastId then return nil, nil end
	local beast = MTH_DS_Beasts and MTH_DS_Beasts[beastId]
	if not beast then return nil, nil end
	local coords = beast and beast.coords
	if not coords or table.getn(coords) == 0 then return nil, nil end
	return beastId, beast
end

local function MTH_BOOK_GetSelectedNPCForMap()
	if MTH_BOOK_STATE.mode ~= "npcs" then return nil, nil end
	local selected = MTH_BOOK_STATE.selectedEntry
	if not selected or not selected.npcId then return nil, nil end
	local npcId = tonumber(selected.npcId)
	if not npcId then return nil, nil end
	local npc = MTH_DS_Vendors and MTH_DS_Vendors[npcId]
	if not npc then return nil, nil end
	local coords = npc.coords
	if not coords or table.getn(coords) == 0 then return nil, nil end
	return npcId, npc
end

local function MTH_BOOK_UpdateOpenMapButton()
	local openMapButton = getglobal("MTH_BOOK_OpenMapButton")
	if not openMapButton then return end
	local beastId = MTH_BOOK_GetSelectedBeastForMap()
	local npcId = MTH_BOOK_GetSelectedNPCForMap()
	if beastId or npcId then
		openMapButton:Show()
		openMapButton:Enable()
	else
		openMapButton:Hide()
	end
end

local function MTH_BOOK_OpenSelectedBeastOnMap()
	local beastId, beast = MTH_BOOK_GetSelectedBeastForMap()
	if not beastId then
		local npcId, npc = MTH_BOOK_GetSelectedNPCForMap()
		if not npcId then return end
		if not MTH_Map or not MTH_Map.FocusVendor then return end
		local okNpc = MTH_Map:FocusVendor(npcId, npc)
		if not okNpc then return end
		if DEFAULT_CHAT_FRAME and MTH:IsMessageEnabled("mapMarkers", true) then
			local npcName = (MTH and MTH.GetLocalizedNPCNameById and MTH:GetLocalizedNPCNameById(npcId, npc and npc.name)) or (npc and npc.name) or "Unknown"
			MTH:Print("Focused map markers for " .. tostring(npcName) .. " (" .. tostring(npcId) .. ")")
		end
		return
	end
	if not MTH_Map or not MTH_Map.FocusBeast then
		return
	end

	local ok = MTH_Map:FocusBeast(beastId, beast)
	if not ok then
		return
	end

	if DEFAULT_CHAT_FRAME and MTH:IsMessageEnabled("mapMarkers", true) then
		local beastName = (MTH and MTH.GetLocalizedBeastName and MTH:GetLocalizedBeastName(beastId, beast and beast.name)) or (beast and beast.name) or "Unknown"
		MTH:Print("Focused map markers for " .. tostring(beastName) .. " (" .. tostring(beastId) .. ")")
	end
end

function MTH_BOOK_OpenTamePointOnMap(zoneId, x, y, title, detail)
	local zid = tonumber(zoneId)
	local nx = tonumber(x)
	local ny = tonumber(y)
	if not (zid and nx and ny) then
		return false
	end
	if nx > 0 and nx <= 1 then
		nx = nx * 100
	end
	if ny > 0 and ny <= 1 then
		ny = ny * 100
	end
	if not (MTH_Map and MTH_Map.SetSource and MTH_Map.UpdateWorldMap and MTH_Map.UpdateMinimap) then
		return false
	end

	MTH_Map.focusNodes = {
		{
			zoneId = zid,
			x = nx,
			y = ny,
			title = tostring(title or "Tame Location"),
			detail = tostring(detail or ""),
			color = { 0.95, 0.82, 0.10 },
		}
	}

	if not MTH_Map:SetSource("focus") then
		return false
	end
	if MTH_Map.OpenWorldMapForZone then
		MTH_Map:OpenWorldMapForZone(zid)
	end
	MTH_Map:UpdateWorldMap()
	MTH_Map:UpdateMinimap()
	return true
end

local function MTH_BOOK_ShouldShowAllOnMapButton()
	return MTH_BOOK_STATE.mode == "pets" and MTH_BOOK_STATE.petInZoneOnly and true or false
end

local function MTH_BOOK_UpdateShowAllOnMapButton()
	local showAllButton = getglobal("MTH_BOOK_ShowAllOnMapButton")
	if not showAllButton then return end
	if MTH_BOOK_ShouldShowAllOnMapButton() then
		showAllButton:Show()
	else
		showAllButton:Hide()
	end
end

local function MTH_BOOK_ShowAllFilteredBeastsOnMap()
	if not MTH_BOOK_ShouldShowAllOnMapButton() then
		return
	end
	if not (MTH_Map and MTH_Map.SetSource and MTH_Map.UpdateWorldMap and MTH_Map.UpdateMinimap) then
		return
	end

	local nodes = {}
	local firstZoneId = nil
	for i = 1, table.getn(MTH_BOOK_STATE.results or {}) do
		local beastId = tonumber(MTH_BOOK_STATE.results[i])
		local beast = beastId and MTH_DS_Beasts and MTH_DS_Beasts[beastId]
		if beast and beast.coords then
			local beastDisplayName = (MTH and MTH.GetLocalizedBeastName and MTH:GetLocalizedBeastName(beastId, beast.name)) or beast.name or "Unknown"
			for j = 1, table.getn(beast.coords) do
				local c = beast.coords[j]
				if c and c[1] and c[2] and c[3] then
					local x = tonumber(c[1])
					local y = tonumber(c[2])
					local zoneId = tonumber(c[3])
					if x and y and zoneId then
						if not firstZoneId then
							firstZoneId = zoneId
						end
						local details = string.format("Family: %s\nLevel: %s\nAbilities: %s", beast.family or "?", beast.lvl or "?", beast.abilities or "None")
						table.insert(nodes, {
							zoneId = zoneId,
							x = x,
							y = y,
							title = string.format("%s (%d)", beastDisplayName, beastId),
							detail = details,
							beastId = beastId,
							color = { 0.95, 0.82, 0.10 },
						})
					end
				end
			end
		end
	end

	if table.getn(nodes) == 0 then
		return
	end

	MTH_Map.focusNodes = nodes
	if not MTH_Map:SetSource("focus") then
		return
	end
	if firstZoneId and MTH_Map.OpenWorldMapForZone then
		MTH_Map:OpenWorldMapForZone(firstZoneId)
	end
	MTH_Map:UpdateWorldMap()
	MTH_Map:UpdateMinimap()

	if MTH and MTH.Print and MTH:IsMessageEnabled("mapMarkers", true) then
		MTH:Print("Focused map markers for " .. tostring(table.getn(nodes)) .. " beasts in this zone.")
	end
end

local function MTH_BOOK_TryTargetSelectedEntry()
	local entry = MTH_BOOK_STATE and MTH_BOOK_STATE.selectedEntry
	if not entry then return false end
	local name = entry.name
	if not name or name == "" then return false end
	local targetByName = _G["TargetByName"]
	if type(targetByName) == "function" then
		targetByName(name, true)
		return true
	end
	return false
end

local function MTH_BOOK_SyncTopAreaColorWithSelectedTab()
	local topAreaBackdrop = getglobal("MTH_BOOK_TopAreaBackdrop")
	if not topAreaBackdrop then return end
	topAreaBackdrop:SetBackdropColor(0.10, 0.10, 0.10, 1.00)
	topAreaBackdrop:SetBackdropBorderColor(0.28, 0.28, 0.28, 1.00)
end

function MTH_BOOK_GetItemsTable()
	if MTH_BOOK_STATE.mode == "ammobags" then
		local bagItems = MTH_DS_BagItems or MTH_DS_Bags
		if (not bagItems) and type(getglobal) == "function" then
			bagItems = getglobal("MTH_DS_BagItems") or getglobal("MTH_DS_Bags")
		end
		if bagItems then return bagItems end
		return MTH_BOOK_FALLBACK_BAG_ITEMS
	end
	if MTH_BOOK_STATE.mode == "projectiles" then
		local ammoItems = MTH_DS_AmmoItems
		if (not ammoItems) and type(getglobal) == "function" then
			ammoItems = getglobal("MTH_DS_AmmoItems")
		end
		if ammoItems then return ammoItems end
		return {}
	end
	local items = MTH_DS_Items
	if (not items) and type(getglobal) == "function" then
		items = getglobal("MTH_DS_Items")
	end
	if items then return items end
	return MTH_DS_AmmoItems or {}
end

local function MTH_BOOK_CountMap(map)
	local count = 0
	if not map then return 0 end
	for _ in pairs(map) do count = count + 1 end
	return count
end

local function MTH_BOOK_GetSourceBlockCount(block)
	if type(block) ~= "table" then return 0 end
	if tonumber(block.count) and tonumber(block.count) > 0 then
		return tonumber(block.count)
	end
	if type(block.entries) == "table" then
		return MTH_BOOK_CountMap(block.entries)
	end
	return MTH_BOOK_CountMap(block)
end

local function MTH_BOOK_BuildAtlasSourceTags(atlas)
	local tags = {}
	if type(atlas) ~= "table" then return tags end
	if atlas.vendor then table.insert(tags, "Vendor") end
	if atlas.quest then table.insert(tags, "Quest") end
	if atlas.crafted then table.insert(tags, "Crafted") end
	if atlas.boss then table.insert(tags, "Boss") end
	if atlas.pvp then table.insert(tags, "PvP") end
	if atlas.worlddrop then table.insert(tags, "World Drop") end
	if atlas.world then table.insert(tags, "World") end
	if atlas.event then table.insert(tags, "Event") end
	return tags
end

local function MTH_BOOK_GetItemSourceInfo(item)
	local info = {
		vendors = MTH_BOOK_CountMap(item and item.vendors),
		drops = MTH_BOOK_CountMap(item and item.drops),
		objects = MTH_BOOK_CountMap(item and item.objects),
		sourceTypes = {},
		atlasTags = MTH_BOOK_BuildAtlasSourceTags(item and item.atlas_sources),
		primary = "-",
	}

	if type(item) == "table" and type(item.sources) == "table" then
		for rawKey, block in pairs(item.sources) do
			local template = (type(block) == "table" and block.template) and tostring(block.template) or "?"
			table.insert(info.sourceTypes, tostring(rawKey) .. " : " .. template)
		end
	end

	if table.getn(info.sourceTypes) == 0 then
		if info.vendors > 0 then table.insert(info.sourceTypes, "sold-by : npc") end
		if info.drops > 0 then table.insert(info.sourceTypes, "dropped-by : npc") end
		if info.objects > 0 then table.insert(info.sourceTypes, "contained-in : object") end
		for i = 1, table.getn(info.atlasTags) do
			table.insert(info.sourceTypes, "atlas : " .. tostring(info.atlasTags[i]))
		end
	end

	table.sort(info.sourceTypes)
	if table.getn(info.sourceTypes) > 0 then
		info.primary = info.sourceTypes[1]
	end

	return info
end

function MTH_BOOK_HasEntries(map)
	if not map then return false end
	for _ in pairs(map) do return true end
	return false
end

function MTH_BOOK_SafeLower(text)
	if not text then return "" end
	return string.lower(text)
end

local function MTH_BOOK_ParseBoxNumber(name)
	local box = getglobal(name)
	if not box then return nil end
	local txt = box:GetText() or ""
	txt = string.gsub(txt, "^%s+", "")
	txt = string.gsub(txt, "%s+$", "")
	if txt == "" then return nil end
	return tonumber(txt)
end

function MTH_BOOK_ParseLevel(value)
	if not value then return nil end
	if type(value) == "number" then return value end
	if type(value) ~= "string" then return nil end
	local _, _, first = string.find(value, "(%d+)")
	if not first then return nil end
	return tonumber(first)
end

local function MTH_BOOK_GetItemQualityColorCode(quality)
	local q = tonumber(quality)
	if not q and type(quality) == "string" then
		local lowered = string.lower(quality)
		if lowered == "poor" then q = 0 end
		if lowered == "common" then q = 1 end
		if lowered == "uncommon" then q = 2 end
		if lowered == "rare" then q = 3 end
		if lowered == "epic" then q = 4 end
		if lowered == "legendary" then q = 5 end
		if lowered == "artifact" then q = 6 end
	end
	if q ~= nil and type(GetItemQualityColor) == "function" then
		local _, _, _, colorCode = GetItemQualityColor(q)
		if colorCode and colorCode ~= "" then
			local hex = string.gsub(tostring(colorCode), "|c", "")
			hex = string.gsub(hex, "|r", "")
			hex = string.gsub(hex, "^#", "")
			if string.len(hex) == 8 then return string.upper(hex) end
			if string.len(hex) == 6 then return "FF" .. string.upper(hex) end
		end
	end
	if q ~= nil and ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[q] then
		local c = ITEM_QUALITY_COLORS[q]
		if c and c.r and c.g and c.b then
			local r = math.floor((tonumber(c.r) or 1) * 255 + 0.5)
			local g = math.floor((tonumber(c.g) or 1) * 255 + 0.5)
			local b = math.floor((tonumber(c.b) or 1) * 255 + 0.5)
			return string.format("FF%02X%02X%02X", r, g, b)
		end
	end
	return "FFFFFFFF"
end

local function MTH_BOOK_GetWeaponLegacyQualityColorCode(quality)
	local q = tonumber(quality)
	if not q and type(quality) == "string" then
		local lowered = string.lower(quality)
		if lowered == "poor" then q = 6 end
		if lowered == "common" then q = 5 end
		if lowered == "uncommon" then q = 4 end
		if lowered == "rare" then q = 3 end
		if lowered == "epic" then q = 2 end
		if lowered == "legendary" then q = 1 end
		if lowered == "artifact" then q = 1 end
	end
	if q == 2 then return "FFAA66FF" end
	if q == 3 then return "FF0070DD" end
	if q == 4 then return "FF1EFF00" end
	if q == 5 then return "FFFFFFFF" end
	if q == 6 then return "FF9D9D9D" end
	return "FFFFFFFF"
end

local function MTH_BOOK_ParseProjectileDPSFromText(text)
	if type(text) ~= "string" or text == "" then return nil end
	local lowered = string.lower(text)
	local _, _, raw = string.find(lowered, "adds%s+([%d]+[%.,]?[%d]*)%s+damage%s+per%s+seconds?")
	if not raw then
		_, _, raw = string.find(lowered, "([%d]+[%.,]?[%d]*)%s+damage%s+per%s+seconds?")
	end
	if not raw then return nil end
	local normalized = string.gsub(raw, ",", ".")
	return tonumber(normalized)
end

local function MTH_BOOK_GetProjectileDPSValue(item)
	if type(item) ~= "table" then return nil end
	local existing = tonumber(item.dps)
	if existing then return existing end

	local dps = MTH_BOOK_ParseProjectileDPSFromText(item.tooltip)
	if not dps then dps = MTH_BOOK_ParseProjectileDPSFromText(item.description) end
	if dps then
		item.dps = dps
		return dps
	end

	return nil
end

local function MTH_BOOK_GetPlayerReactDefaults()
	local faction = UnitFactionGroup and UnitFactionGroup("player")
	if faction == "Alliance" then
		return true, false, true
	end
	if faction == "Horde" then
		return false, true, true
	end
	return true, true, true
end

local function MTH_BOOK_GetNPCReactBucket(fac)
	if type(MTH_BOOKTAB_GetNPCReactBucket) == "function" then
		return MTH_BOOKTAB_GetNPCReactBucket(fac)
	end
	return "AH"
end

local function MTH_BOOK_GetNPCFunctionLabel(key)
	if type(MTH_BOOKTAB_GetNPCFunctionLabel) == "function" then
		return MTH_BOOKTAB_GetNPCFunctionLabel(key)
	end
	return tostring(key or "")
end

local function MTH_BOOK_GetNPCFunctions(vendor)
	if type(MTH_BOOKTAB_GetNPCFunctions) == "function" then
		return MTH_BOOKTAB_GetNPCFunctions(vendor)
	end
	return {}
end

local function MTH_BOOK_GetNPCFunctionSummary(vendor)
	if type(MTH_BOOKTAB_GetNPCFunctionSummary) == "function" then
		return MTH_BOOKTAB_GetNPCFunctionSummary(vendor)
	end
	return "-", {}
end

local function MTH_BOOK_GetNPCZoneSummary(vendor)
	if type(MTH_BOOKTAB_GetNPCZoneSummary) == "function" then
		return MTH_BOOKTAB_GetNPCZoneSummary(vendor)
	end
	return "-", "-", {}
end

MTH_BOOK_GetZoneName = function(zoneId)
	local normalizedId = tonumber(zoneId) or zoneId
	if not normalizedId then return "Zone " .. tostring(zoneId or "?") end
	if MTH_DS_ZoneNamesFallback and MTH_DS_ZoneNamesFallback[normalizedId] then
		return MTH_DS_ZoneNamesFallback[normalizedId]
	end
	if not MTH_DS_Zones then return "Zone " .. tostring(zoneId or "?") end
	local row = MTH_DS_Zones[normalizedId] or MTH_DS_Zones[tostring(normalizedId)]
	if not row then return "Zone " .. tostring(normalizedId) end
	local names = row.names
	if not names then return "Zone " .. tostring(normalizedId) end
	return names.enUS or names[GetLocale()] or names.deDE or names.frFR or ("Zone " .. tostring(normalizedId))
end
_G.MTH_BOOK_GetZoneName = MTH_BOOK_GetZoneName

function MTH_BOOK_NormalizeZoneLookupName(name)
	if not name then return "" end
	local lowered = string.lower(tostring(name))
	return string.gsub(lowered, "[^%w]", "")
end

function MTH_BOOK_GetCurrentZoneId()
	local zoneName = nil
	if type(GetRealZoneText) == "function" then
		zoneName = GetRealZoneText()
	end
	if (not zoneName or zoneName == "") and type(GetZoneText) == "function" then
		zoneName = GetZoneText()
	end
	if not zoneName or zoneName == "" then
		return nil
	end

	if MTH_Map and type(MTH_Map.GetMapIDByName) == "function" then
		local mapId = MTH_Map:GetMapIDByName(zoneName)
		if mapId then
			return tonumber(mapId) or mapId
		end
	end

	local normalized = MTH_BOOK_NormalizeZoneLookupName(zoneName)
	if normalized == "" then
		return nil
	end

	if MTH_DS_Zones then
		for zoneId, row in pairs(MTH_DS_Zones) do
			if row and row.names then
				for _, value in pairs(row.names) do
					if MTH_BOOK_NormalizeZoneLookupName(value) == normalized then
						return tonumber(zoneId) or zoneId
					end
				end
			end
		end
	end

	if MTH_DS_ZoneNamesFallback then
		for zoneId, value in pairs(MTH_DS_ZoneNamesFallback) do
			if MTH_BOOK_NormalizeZoneLookupName(value) == normalized then
				return tonumber(zoneId) or zoneId
			end
		end
	end

	return nil
end

function MTH_BOOK_BeastHasZoneId(beast, zoneId)
	local zid = tonumber(zoneId)
	if not zid or not beast or not beast.coords then
		return false
	end
	for i = 1, table.getn(beast.coords) do
		local c = beast.coords[i]
		if c and tonumber(c[3]) == zid then
			return true
		end
	end
	return false
end

function MTH_BOOK_IsUnknownText(value)
	local text = MTH_BOOK_SafeLower(value)
	if text == "" then return true end
	if text == "unknown" then return true end
	if text == "?" or text == "??" or text == "???" then return true end
	return false
end


local function MTH_BOOK_GetSortState()
	local mode = MTH_BOOK_STATE.mode or "pets"
	if not MTH_BOOK_STATE.sortByMode[mode] then
		MTH_BOOK_STATE.sortByMode[mode] = { col = nil, asc = true }
	end
	return MTH_BOOK_STATE.sortByMode[mode]
end

function MTH_BOOK_GetPetDatastore()
	if type(MTH_GetPetDatastoreSnapshot) == "function" then
		local snapshot = MTH_GetPetDatastoreSnapshot()
		if type(snapshot) == "table" then
			return snapshot
		end
	end
	if type(MTH_PETS_GetRootStore) == "function" then
		local pets = MTH_PETS_GetRootStore()
		if type(pets) == "table" and type(pets.petStore) == "table" then
			return pets.petStore
		end
	end
	return nil
end

function MTH_BOOK_GetPetStoreRow(petId)
	local store = MTH_BOOK_GetPetDatastore()
	if type(store) ~= "table" then return nil end
	if MTH_BOOK_STATE.mode == "stable" and type(store.activeById) == "table" then
		return store.activeById[petId]
	end
	if MTH_BOOK_STATE.mode == "pethistory" and type(store.historyById) == "table" then
		return store.historyById[petId]
	end
	return nil
end

function MTH_BOOK_IsCurrentActivePetId(store, petId)
	if type(store) ~= "table" then return false end
	if petId == nil then return false end
	if MTH_BOOK_STABLE_CURRENT_ID_CACHE and tostring(petId) == tostring(MTH_BOOK_STABLE_CURRENT_ID_CACHE) then
		return true
	end
	return tostring(store.activeCurrentId or "") == tostring(petId)
end

function MTH_BOOK_ResolveCurrentPetId(store)
	if type(store) == "table" and store.activeCurrentId ~= nil and tostring(store.activeCurrentId) ~= "" then
		local activeId = tostring(store.activeCurrentId)
		if type(store.activeById) == "table" and type(store.activeById[activeId]) == "table" then
			return activeId
		end
	end

	if type(MTH_PETS_GetRootStore) == "function" then
		local pets = MTH_PETS_GetRootStore()
		if type(pets) == "table" and pets.currentPetSuppressed == true then
			return nil
		end
		local persistedCurrentId = pets and pets.currentPetId
		if persistedCurrentId ~= nil and tostring(persistedCurrentId) ~= "" then
			local currentId = tostring(persistedCurrentId)
			if type(store) == "table" and type(store.activeById) == "table" and type(store.activeById[currentId]) == "table" then
				return currentId
			end
		end
		local cp = pets and pets.currentPet
		if type(cp) == "table" and cp.id ~= nil and tostring(cp.id) ~= "" then
			local currentId = tostring(cp.id)
			if type(store) == "table" and type(store.activeById) == "table" and type(store.activeById[currentId]) == "table" then
				return currentId
			end
		end
	end

	return nil
end

function MTH_BOOK_GetStableDisplaySlot(petId, row, store)
	if type(row) ~= "table" then return nil end
	if type(store) ~= "table" then
		store = MTH_BOOK_GetPetDatastore()
	end
	if MTH_BOOK_IsCurrentActivePetId(store, petId) then
		return 0
	end
	local slotNumber = tonumber(row.stableSlot)
	if slotNumber and slotNumber > 0 then
		return slotNumber
	end
	return nil
end

local function MTH_BOOK_IsStableListPet(petId, row, store)
	return MTH_BOOK_GetStableDisplaySlot(petId, row, store) ~= nil
end

local function MTH_BOOK_StableSort(a, b)
	if type(MTH_BOOKTAB_StableSort) == "function" then
		return MTH_BOOKTAB_StableSort(a, b)
	end
	return tostring(a) < tostring(b)
end

local function MTH_BOOK_GetSortKey(entry, col)
	if MTH_BOOK_STATE.mode == "pets" then
		local beast = MTH_DS_Beasts and MTH_DS_Beasts[entry]
		if not beast then return nil end
		local beastName = (MTH and MTH.GetLocalizedBeastName and MTH:GetLocalizedBeastName(entry, beast.name)) or beast.name
		local traits = MTH_BOOK_ParseBeastTraits(beast)
		if col == 1 then return tonumber(entry) or 0 end
		if col == 2 then return MTH_BOOK_ParseLevel(beast.lvl) or 0 end
		if col == 3 then return MTH_BOOK_SafeLower(beast.family) end
		if col == 4 then return MTH_BOOK_SafeLower(beastName) end
		if col == 5 then return MTH_BOOK_SafeLower(MTH_BOOK_GetBeastAbilitiesSummary(beast)) end
		if col == 6 then return MTH_BOOK_SafeLower(MTH_BOOK_GetBeastZoneSummary(beast)) end
		if col == 7 then return traits.rare and 1 or 0 end
		if col == 8 then return traits.elite and 1 or 0 end
		if col == 9 then return traits.unique and 1 or 0 end
	end

	if MTH_BOOK_STATE.mode == "abilities" then
		if col == 1 then return MTH_BOOK_SafeLower(entry.abilityToken) end
		if col == 2 then return tonumber(entry.level) or 0 end
		if col == 3 then return MTH_BOOK_SafeLower(entry.family) end
		if col == 4 then return MTH_BOOK_SafeLower(entry.name) end
		if col == 5 then return entry.rare and 1 or 0 end
	end

	if MTH_BOOK_STATE.mode == "petabilities" then
		if col == 1 then return MTH_BOOK_SafeLower(entry.ability) end
		if col == 2 then return tonumber(entry.rankCount) or 0 end
		if col == 3 then
			local familyCount = tonumber(entry.familyCount) or 0
			return (familyCount * 10000) + string.len(MTH_BOOK_SafeLower(entry.familyList or ""))
		end
	end

	if MTH_BOOK_STATE.mode == "families" then
		if col == 1 then return MTH_BOOK_SafeLower(entry.family) end
		if col == 2 then return tonumber(entry.named) or 0 end
		if col == 3 then return tonumber(entry.coords) or 0 end
		if col == 4 then return tonumber(entry.abilities and table.getn(entry.abilities) or 0) end
		if col == 5 then return MTH_BOOK_SafeLower(entry.dietText or "") end
	end

	if MTH_BOOK_STATE.mode == "npcs" then
		local vendors = MTH_DS_Vendors
		local npc = vendors and vendors[entry]
		if not npc then return nil end
		local react = MTH_BOOK_GetNPCReactBucket(npc.fac)
		local functionSummary = MTH_BOOK_GetNPCFunctionSummary(npc)
		local zoneName = MTH_BOOK_GetNPCZoneSummary(npc)
		if col == 1 then return tonumber(entry) or 0 end
		if col == 2 then
			local npcName = (MTH and MTH.GetLocalizedNPCNameById and MTH:GetLocalizedNPCNameById(entry, npc.name)) or npc.name
			return MTH_BOOK_SafeLower(npcName)
		end
		if col == 3 then return react end
		if col == 4 then return MTH_BOOK_SafeLower(functionSummary) end
		if col == 5 then return MTH_BOOK_SafeLower(zoneName) end
	end

	if MTH_BOOK_STATE.mode == "stable" then
		local store = MTH_BOOK_GetPetDatastore()
		local row = MTH_BOOK_GetPetStoreRow(entry)
		if not row then return nil end
		if col == 1 then return tostring(entry) end
		if col == 2 then return MTH_BOOK_GetStableDisplaySlot(entry, row, store) or 9999 end
		if col == 3 then return MTH_BOOK_SafeLower(row.name) end
		if col == 4 then return MTH_BOOK_SafeLower(row.family) end
		if col == 5 then return tonumber(row.level) or 0 end
		if col == 6 then return tonumber(row.loyaltyLevel) or (row.stableInfo and tonumber(row.stableInfo.loyaltyLevel)) or 0 end
		if col == 7 then return tonumber(row.lastSeen) or 0 end
	end

	if MTH_BOOK_STATE.mode == "pethistory" then
		local row = MTH_BOOK_GetPetStoreRow(entry)
		if not row then return nil end
		if col == 1 then return tostring(entry) end
		if col == 2 then return MTH_BOOK_SafeLower(row.name) end
		if col == 3 then return MTH_BOOK_SafeLower(row.family) end
		if col == 4 then return tonumber(row.level) or 0 end
		if col == 5 then return tonumber(row.abandonedAt) or 0 end
		if col == 6 then return MTH_BOOK_SafeLower(tostring(row.abandonReason or "")) end
	end

	local items = MTH_BOOK_GetItemsTable()
	local item = items and items[entry]
	if not item then return nil end
	local localizedItemName = (MTH and MTH.GetLocalizedItemName)
		and MTH:GetLocalizedItemName(entry, item.name)
		or item.name
	if col == 1 then return tonumber(entry) or 0 end
	if col == 2 then return tonumber(item.reqlevel) or 0 end
	if col == 3 then return tonumber(item.level) or 0 end
	if MTH_BOOK_STATE.mode == "ammobags" then
		if col == 4 then return tonumber(item.slots) or 0 end
		if col == 5 then return MTH_BOOK_SafeLower(item.subtype) end
		if col == 6 then return MTH_BOOK_SafeLower(localizedItemName) end
		if col == 7 then
			local hasVendors = MTH_BOOK_CountMap(item.vendors) > 0
			local hasDrops = MTH_BOOK_CountMap(item.drops) > 0
			local hasObjects = MTH_BOOK_CountMap(item.objects) > 0
			if hasVendors and (hasDrops or hasObjects) then return "mixed" end
			if hasDrops and hasObjects then return "mixed" end
			if hasVendors then return "vendor" end
			if hasDrops then return "drop" end
			if hasObjects then return "object" end
			return ""
		end
	else
		if col == 4 then return MTH_BOOK_SafeLower(item.subtype) end
		if col == 5 then return MTH_BOOK_SafeLower(localizedItemName) end
		if MTH_BOOK_STATE.mode == "projectiles" then
			if col == 6 then return MTH_BOOK_GetProjectileDPSValue(item) or 0 end
			if col == 7 then
				local sourceInfo = MTH_BOOK_GetItemSourceInfo(item)
				return MTH_BOOK_SafeLower(sourceInfo and sourceInfo.primary or "")
			end
		else
			if col == 6 then return tonumber(item.dps) or 0 end
			if col == 7 then return tonumber(item.speed) or 0 end
		end
	end

	return nil
end

local function MTH_BOOK_DefaultCompare(a, b)
	if MTH_BOOK_STATE.mode == "pets" then return MTH_BOOK_BeastSort(a, b) end
	if MTH_BOOK_STATE.mode == "families" then
		local fa = MTH_BOOK_SafeLower(a and a.family)
		local fb = MTH_BOOK_SafeLower(b and b.family)
		if fa ~= fb then return fa < fb end
		return tostring(a and a.family or "") < tostring(b and b.family or "")
	end
	if MTH_BOOK_STATE.mode == "abilities" then return MTH_BOOK_AbilitySort(a, b) end
	if MTH_BOOK_STATE.mode == "petabilities" then return MTH_BOOK_PetAbilitySort(a, b) end
	if MTH_BOOK_STATE.mode == "npcs" then return MTH_BOOK_NPCSort(a, b) end
	if MTH_BOOK_STATE.mode == "stable" then return MTH_BOOK_StableSort(a, b) end
	if MTH_BOOK_STATE.mode == "pethistory" then return MTH_BOOK_PetHistorySort(a, b) end
	return MTH_BOOK_ItemSort(a, b)
end

local function MTH_BOOK_ApplyActiveSort(results)
	local state = MTH_BOOK_GetSortState()
	if not state.col then return end

	table.sort(results, function(a, b)
		local ka = MTH_BOOK_GetSortKey(a, state.col)
		local kb = MTH_BOOK_GetSortKey(b, state.col)
		if ka ~= kb then
			if ka == nil then return not state.asc end
			if kb == nil then return state.asc end
			if state.asc then
				return ka < kb
			end
			return ka > kb
		end
		return MTH_BOOK_DefaultCompare(a, b)
	end)
end

local function MTH_BOOK_BuildResults()
	local results = {}

	if MTH_BOOK_STATE.mode == "pets" then
		if not MTH_DS_Beasts then return results end
		for beastId, beast in pairs(MTH_DS_Beasts) do
			if MTH_BOOK_BeastMatches(beastId, beast) then
				table.insert(results, beastId)
			end
		end
		table.sort(results, MTH_BOOK_BeastSort)
		MTH_BOOK_ApplyActiveSort(results)
		return results
	end

	if MTH_BOOK_STATE.mode == "abilities" then
		if not MTH_DS_Beasts then return results end
		for beastId, beast in pairs(MTH_DS_Beasts) do
			local beastLevel = MTH_BOOK_ParseLevel(beast.lvl)
			if (not MTH_BOOK_STATE.minLevel or (beastLevel and beastLevel >= MTH_BOOK_STATE.minLevel))
				and (not MTH_BOOK_STATE.maxLevel or (beastLevel and beastLevel <= MTH_BOOK_STATE.maxLevel))
				and (not MTH_BOOK_STATE.flag2 or beast.rare)
				and (not MTH_BOOK_STATE.flag3 or (beast.coords and table.getn(beast.coords) > 0))
			then
				local abilities = MTH_BOOK_SplitAbilities(beast.abilities)
				for _, abilityToken in ipairs(abilities) do
					local abilityLower = MTH_BOOK_SafeLower(abilityToken)
					local _, _, rank = string.find(abilityToken, "(%d+)$")
					local abilityName = abilityToken
					if rank then
						abilityName = string.gsub(abilityToken, "%s*%d+$", "")
					end
					local abilityNameLower = MTH_BOOK_SafeLower(abilityName)
					if (MTH_BOOK_STATE.quick == "all" or string.find(abilityNameLower, MTH_BOOK_STATE.quick, 1, true) ~= nil)
						and (not MTH_BOOK_STATE.flag1 or rank ~= nil)
					then
						if MTH_BOOK_STATE.search == ""
							or string.find(abilityLower, MTH_BOOK_STATE.search, 1, true) ~= nil
							or string.find(MTH_BOOK_SafeLower((MTH and MTH.GetLocalizedBeastName and MTH:GetLocalizedBeastName(beastId, beast.name)) or beast.name), MTH_BOOK_STATE.search, 1, true) ~= nil
							or string.find(MTH_BOOK_SafeLower(beast.family), MTH_BOOK_STATE.search, 1, true) ~= nil
						then
							local beastDisplayName = (MTH and MTH.GetLocalizedBeastName and MTH:GetLocalizedBeastName(beastId, beast.name)) or beast.name or "Unknown"
							table.insert(results, {
								beastId = beastId,
								name = beastDisplayName,
								family = beast.family or "?",
								level = beastLevel or 0,
								rare = beast.rare and true or false,
								ability = abilityName,
								rank = rank,
								abilityToken = abilityToken,
							})
						end
					end
				end
			end
		end
		table.sort(results, MTH_BOOK_AbilitySort)
		MTH_BOOK_ApplyActiveSort(results)
		return results
	end

	if MTH_BOOK_STATE.mode == "petabilities" then
		results = MTH_BOOK_BuildPetAbilitiesRows(false)
		MTH_BOOK_ApplyActiveSort(results)
		return results
	end

	if MTH_BOOK_STATE.mode == "families" then
		if type(MTH_BOOKTAB_BuildFamiliesRows) == "function" then
			results = MTH_BOOKTAB_BuildFamiliesRows()
			MTH_BOOK_FamiliesTrace("BuildResults families rows=" .. tostring(table.getn(results or {})))
		else
			MTH_BOOK_FamiliesTrace("BuildResults families missing MTH_BOOKTAB_BuildFamiliesRows")
		end
		MTH_BOOK_ApplyActiveSort(results)
		return results
	end

	if MTH_BOOK_STATE.mode == "npcs" then
		if not MTH_DS_Vendors then return results end
		for npcId, vendor in pairs(MTH_DS_Vendors) do
			if MTH_BOOK_NPCMatches(npcId, vendor) then
				table.insert(results, npcId)
			end
		end
		table.sort(results, MTH_BOOK_NPCSort)
		MTH_BOOK_ApplyActiveSort(results)
		return results
	end

	if MTH_BOOK_STATE.mode == "stable" then
		local store = MTH_BOOK_GetPetDatastore()
		if type(store) ~= "table" or type(store.activeById) ~= "table" then return results end
		MTH_BOOK_STABLE_CURRENT_ID_CACHE = MTH_BOOK_ResolveCurrentPetId(store)
		local activeCount = MTH_BOOK_CountMap(store.activeById)
		MTH_BOOK_DebugTrace("BuildResults stable: activeById=" .. tostring(activeCount) .. " activeCurrentId=" .. tostring(store.activeCurrentId) .. " resolvedCurrentId=" .. tostring(MTH_BOOK_STABLE_CURRENT_ID_CACHE))
		for petId, row in pairs(store.activeById) do
			if type(row) == "table" and MTH_BOOK_IsStableListPet(petId, row, store) then
				table.insert(results, petId)
			end
		end
		MTH_BOOK_DebugTrace("BuildResults stable: included=" .. tostring(table.getn(results)))
		table.sort(results, MTH_BOOK_StableSort)
		MTH_BOOK_ApplyActiveSort(results)
		return results
	end

	if MTH_BOOK_STATE.mode == "pethistory" then
		local store = MTH_BOOK_GetPetDatastore()
		if type(store) ~= "table" or type(store.historyById) ~= "table" then return results end
		for petId, row in pairs(store.historyById) do
			if type(row) == "table" then
				table.insert(results, petId)
			end
		end
		table.sort(results, MTH_BOOK_PetHistorySort)
		MTH_BOOK_ApplyActiveSort(results)
		return results
	end

	local items = MTH_BOOK_GetItemsTable()
	if not items then return results end
	for itemId, item in pairs(items) do
		if MTH_BOOK_ItemMatches(itemId, item) then
			table.insert(results, itemId)
		end
	end
	table.sort(results, MTH_BOOK_ItemSort)
	MTH_BOOK_ApplyActiveSort(results)
	return results
end

local function MTH_BOOK_GetTotalCount()
	if MTH_BOOK_STATE.mode == "pets" or MTH_BOOK_STATE.mode == "abilities" then
		return MTH_DS_Beasts and MTH_BOOK_CountMap(MTH_DS_Beasts) or 0
	end
	if MTH_BOOK_STATE.mode == "petabilities" then
		return table.getn(MTH_BOOK_BuildPetAbilitiesRows(true))
	end
	if MTH_BOOK_STATE.mode == "families" then
		if type(MTH_BOOKTAB_BuildFamiliesRows) == "function" then
			return table.getn(MTH_BOOKTAB_BuildFamiliesRows())
		end
		return 0
	end
	if MTH_BOOK_STATE.mode == "npcs" then
		return MTH_DS_Vendors and MTH_BOOK_CountMap(MTH_DS_Vendors) or 0
	end
	if MTH_BOOK_STATE.mode == "stable" then
		local store = MTH_BOOK_GetPetDatastore()
		if type(store) ~= "table" or type(store.activeById) ~= "table" then return 0 end
		local total = 0
		for petId, row in pairs(store.activeById) do
			if type(row) == "table" and MTH_BOOK_IsStableListPet(petId, row, store) then
				total = total + 1
			end
		end
		return total
	end
	if MTH_BOOK_STATE.mode == "pethistory" then
		local store = MTH_BOOK_GetPetDatastore()
		return (type(store) == "table" and type(store.historyById) == "table") and MTH_BOOK_CountMap(store.historyById) or 0
	end
	local items = MTH_BOOK_GetItemsTable()
	return items and MTH_BOOK_CountMap(items) or 0
end

local function MTH_BOOK_BuildPetFamilyOptions()
	local familyMap = {}

	if MTH_DS_Families then
		for familyName in pairs(MTH_DS_Families) do
			if familyName and familyName ~= "" then
				familyMap[MTH_BOOK_SafeLower(familyName)] = familyName
			end
		end
	end

	if MTH_DS_Beasts then
		for _, beast in pairs(MTH_DS_Beasts) do
			if beast and beast.family and beast.family ~= "" then
				local lower = MTH_BOOK_SafeLower(beast.family)
				if not familyMap[lower] then
					familyMap[lower] = beast.family
				end
			end
		end
	end

	local rows = {}
	for value, label in pairs(familyMap) do
		table.insert(rows, { value = value, label = label })
	end

	table.sort(rows, function(a, b)
		return MTH_BOOK_SafeLower(a.label) < MTH_BOOK_SafeLower(b.label)
	end)

	MTH_BOOK_PetFamilyOptions = {
		{ value = "all", label = "All Families" },
	}

	for i = 1, table.getn(rows) do
		table.insert(MTH_BOOK_PetFamilyOptions, rows[i])
	end

	if MTH_BOOK_STATE.quick ~= "all" and not familyMap[MTH_BOOK_STATE.quick] then
		MTH_BOOK_STATE.quick = "all"
	end
end

local function MTH_BOOK_GetPetFamilyLabel(value)
	for i = 1, table.getn(MTH_BOOK_PetFamilyOptions) do
		local option = MTH_BOOK_PetFamilyOptions[i]
		if option and option.value == value then
			return option.label, i
		end
	end
	return "All Families", 1
end

local function MTH_BOOK_BuildPetAbilityOptions()
	local abilityMap = {}
	local selectedFamily = MTH_BOOK_SafeLower(MTH_BOOK_STATE.quick)

	if MTH_DS_Beasts then
		for _, beast in pairs(MTH_DS_Beasts) do
			local beastFamily = MTH_BOOK_SafeLower(beast and beast.family or "")
			if selectedFamily == "all" or beastFamily == selectedFamily then
				local abilities = MTH_BOOK_SplitAbilities(beast and beast.abilities)
			for i = 1, table.getn(abilities) do
				local abilityLower, abilityLabel, rank = MTH_BOOK_ParseAbilityToken(abilities[i])
				if abilityLower ~= "" and abilityLower ~= "none" and abilityLower ~= "unknown" then
					local row = abilityMap[abilityLower]
					if not row then
						row = { value = abilityLower, label = abilityLabel, ranks = {} }
						abilityMap[abilityLower] = row
					end
					if rank then
						row.ranks[rank] = true
					end
				end
			end
			end
		end
	end

	if MTH_DS_PetSpells and MTH_DS_PetSpells.byAbility then
		for abilityName, bucket in pairs(MTH_DS_PetSpells.byAbility) do
			local abilityLabel = tostring(abilityName or "")
			local abilityLower = MTH_BOOK_SafeLower(abilityLabel)
			if abilityLower ~= "" and abilityLower ~= "none" and abilityLower ~= "unknown" then
				local row = abilityMap[abilityLower]
				if row and bucket and bucket.spells then
					for i = 1, table.getn(bucket.spells) do
						local spell = bucket.spells[i]
						if spell and MTH_BOOK_SafeLower(spell.learnMethod or "beast") ~= "trainer" then
							local rank = tonumber(spell.rankNumber)
							if rank and rank > 0 then
								row.ranks[rank] = true
							end
						end
					end
				end
			end
		end
	end

	local rows = {}
	for _, row in pairs(abilityMap) do
		table.insert(rows, row)
	end

	table.sort(rows, function(a, b)
		return MTH_BOOK_SafeLower(a.label) < MTH_BOOK_SafeLower(b.label)
	end)

	MTH_BOOK_PetAbilityOptions = {
		{ value = "all", label = "All abilities" },
	}
	MTH_BOOK_PetAbilityRanks = {}
	for i = 1, table.getn(rows) do
		local row = rows[i]
		table.insert(MTH_BOOK_PetAbilityOptions, { value = row.value, label = row.label })
		MTH_BOOK_PetAbilityRanks[row.value] = row.ranks
	end

	if MTH_BOOK_STATE.petAbility ~= "all" and not abilityMap[MTH_BOOK_STATE.petAbility] then
		MTH_BOOK_STATE.petAbility = "all"
		MTH_BOOK_STATE.petRank = "all"
	end
end

local function MTH_BOOK_BuildPetRankOptions()
	MTH_BOOK_PetRankOptions = {
		{ value = "all", label = "All ranks" },
	}

	if MTH_BOOK_STATE.petAbility == "all" then
		MTH_BOOK_STATE.petRank = "all"
		return false
	end

	local ranksMap = MTH_BOOK_PetAbilityRanks and MTH_BOOK_PetAbilityRanks[MTH_BOOK_STATE.petAbility]
	if not ranksMap then
		MTH_BOOK_STATE.petRank = "all"
		return false
	end

	local ranks = {}
	for rank in pairs(ranksMap) do
		table.insert(ranks, tonumber(rank))
	end
	table.sort(ranks)

	if table.getn(ranks) == 0 then
		MTH_BOOK_STATE.petRank = "all"
		return false
	end

	for i = 1, table.getn(ranks) do
		local rank = ranks[i]
		table.insert(MTH_BOOK_PetRankOptions, { value = tostring(rank), label = "Rank " .. tostring(rank) })
	end

	if MTH_BOOK_STATE.petRank ~= "all" then
		local keep = false
		for i = 1, table.getn(ranks) do
			if tostring(ranks[i]) == tostring(MTH_BOOK_STATE.petRank) then
				keep = true
				break
			end
		end
		if not keep then
			MTH_BOOK_STATE.petRank = "all"
		end
	end

	return true
end

local function MTH_BOOK_GetPetAbilityLabel(value)
	for i = 1, table.getn(MTH_BOOK_PetAbilityOptions) do
		local option = MTH_BOOK_PetAbilityOptions[i]
		if option and option.value == value then
			return option.label, i
		end
	end
	return "All abilities", 1
end

local function MTH_BOOK_GetPetRankLabel(value)
	for i = 1, table.getn(MTH_BOOK_PetRankOptions) do
		local option = MTH_BOOK_PetRankOptions[i]
		if option and option.value == value then
			return option.label, i
		end
	end
	return "All ranks", 1
end

local function MTH_BOOK_GetPetLearnSourceLabel(value)
	for i = 1, table.getn(MTH_BOOK_PetLearnSourceOptions) do
		local option = MTH_BOOK_PetLearnSourceOptions[i]
		if option and option.value == value then
			return option.label
		end
	end
	return "All Abilities"
end

MTH_BOOK_GetPlayerLevelValue = function()
	if type(UnitLevel) == "function" then
		local lvl = tonumber(UnitLevel("player"))
		if lvl and lvl > 0 then
			return lvl
		end
	end
	return nil
end
_G.MTH_BOOK_GetPlayerLevelValue = MTH_BOOK_GetPlayerLevelValue

MTH_BOOK_IsSpellInLevelScope = function(trainLevel)
	if not MTH_BOOK_STATE.petOnlyMyLevel then
		return true
	end
	local playerLevel = MTH_BOOK_GetPlayerLevelValue()
	if not playerLevel then
		return true
	end
	local req = tonumber(trainLevel)
	if not req then
		return true
	end
	return req <= playerLevel
end
_G.MTH_BOOK_IsSpellInLevelScope = MTH_BOOK_IsSpellInLevelScope

MTH_BOOK_GetScopedRankSummary = function(abilityName)
	local rankMap = {}
	local knownRankMap = {}
	local minRank = nil
	local maxRank = nil
	local minTrainLevel = nil
	local maxTrainLevel = nil

	if not (MTH_DS_PetSpells and MTH_DS_PetSpells.byAbility) then
		return 0, 0, nil, nil, nil, nil
	end

	local bucket = MTH_DS_PetSpells.byAbility[abilityName]
	if not (bucket and bucket.spells) then
		return 0, 0, nil, nil, nil, nil
	end

	for i = 1, table.getn(bucket.spells) do
		local spell = bucket.spells[i]
		if spell and MTH_BOOK_IsSpellInLevelScope(tonumber(spell.trainLevel)) then
			local rankNumber = tonumber(spell.rankNumber)
			if not rankNumber and spell.rank then
				local _, _, parsed = string.find(tostring(spell.rank), "(%d+)")
				rankNumber = tonumber(parsed)
			end
			if rankNumber and rankNumber > 0 then
				rankMap[rankNumber] = true
				if MTH_BOOK_IsKnownRankForAbility(abilityName, rankNumber) then
					knownRankMap[rankNumber] = true
				end
				if not minRank or rankNumber < minRank then minRank = rankNumber end
				if not maxRank or rankNumber > maxRank then maxRank = rankNumber end
			end
			local trainLevel = tonumber(spell.trainLevel)
			if trainLevel then
				if not minTrainLevel or trainLevel < minTrainLevel then minTrainLevel = trainLevel end
				if not maxTrainLevel or trainLevel > maxTrainLevel then maxTrainLevel = trainLevel end
			end
		end
	end

	local rankCount = 0
	for _ in pairs(rankMap) do rankCount = rankCount + 1 end
	local knownCount = 0
	for _ in pairs(knownRankMap) do knownCount = knownCount + 1 end
	if rankCount == 0 then
		local hasAnyScopedRows = false
		for i = 1, table.getn(bucket.spells) do
			local spell = bucket.spells[i]
			if spell and MTH_BOOK_IsSpellInLevelScope(tonumber(spell.trainLevel)) then
				hasAnyScopedRows = true
				break
			end
		end
		if hasAnyScopedRows then
			rankCount = 1
			if MTH_BOOK_IsKnownRankForAbility(abilityName, 0) then
				knownCount = 1
			end
		end
	end
	if knownCount > rankCount then knownCount = rankCount end

	return knownCount, rankCount, minRank, maxRank, minTrainLevel, maxTrainLevel
end
_G.MTH_BOOK_GetScopedRankSummary = MTH_BOOK_GetScopedRankSummary

local function MTH_BOOK_BuildNPCFunctionOptions()
	MTH_BOOK_NPCFunctionOptions = {
		{ value = "all", label = "All Hunter Friends" },
		{ value = "huntertrainer", label = "Hunter Trainer" },
		{ value = "pettrainer", label = "Pet Trainer" },
		{ value = "vendor", label = "Ammo Vendor" },
	}

	local allowed = {
		all = true,
		huntertrainer = true,
		pettrainer = true,
		vendor = true,
	}
	if not allowed[MTH_BOOK_STATE.npcFunction] then
		MTH_BOOK_STATE.npcFunction = "all"
	end
end

local function MTH_BOOK_BuildNPCZoneOptions()
	local seen = {}
	local rows = {}
	if MTH_DS_Vendors then
		for _, vendor in pairs(MTH_DS_Vendors) do
			local _, _, zones = MTH_BOOK_GetNPCZoneSummary(vendor)
			for i = 1, table.getn(zones) do
				local zone = zones[i]
				if zone ~= "-" and not seen[zone] then
					seen[zone] = true
					table.insert(rows, { value = zone, label = zone })
				end
			end
		end
	end

	table.sort(rows, function(a, b)
		return MTH_BOOK_SafeLower(a.label) < MTH_BOOK_SafeLower(b.label)
	end)

	MTH_BOOK_NPCZoneOptions = {
		{ value = "all", label = "All Zones" },
	}
	for i = 1, table.getn(rows) do
		table.insert(MTH_BOOK_NPCZoneOptions, rows[i])
	end

	if MTH_BOOK_STATE.npcZone ~= "all" and not seen[MTH_BOOK_STATE.npcZone] then
		MTH_BOOK_STATE.npcZone = "all"
	end
end

local function MTH_BOOK_GetNPCFunctionLabelByValue(value)
	for i = 1, table.getn(MTH_BOOK_NPCFunctionOptions) do
		local option = MTH_BOOK_NPCFunctionOptions[i]
		if option and option.value == value then
			return option.label
		end
	end
	return "All Hunter Friends"
end

local function MTH_BOOK_GetNPCZoneLabelByValue(value)
	for i = 1, table.getn(MTH_BOOK_NPCZoneOptions) do
		local option = MTH_BOOK_NPCZoneOptions[i]
		if option and option.value == value then
			return option.label
		end
	end
	return "All Zones"
end

local function MTH_BOOK_UpdateFamilyDropdownText()
	local familyDropdown = getglobal("MTH_BOOK_FamilyDropdown")
	if not familyDropdown then return end
	local label, index = MTH_BOOK_GetPetFamilyLabel(MTH_BOOK_STATE.quick)
	MTH_BOOK_DropdownSetText(familyDropdown, label)
end

local function MTH_BOOK_UpdateAbilityDropdownText()
	local abilityDropdown = getglobal("MTH_BOOK_AbilityDropdown")
	if not abilityDropdown then return end
	local label, index = MTH_BOOK_GetPetAbilityLabel(MTH_BOOK_STATE.petAbility)
	MTH_BOOK_DropdownSetText(abilityDropdown, label)
end

local function MTH_BOOK_UpdateRankDropdownText()
	local rankDropdown = getglobal("MTH_BOOK_RankDropdown")
	if not rankDropdown then return end
	local label, index = MTH_BOOK_GetPetRankLabel(MTH_BOOK_STATE.petRank)
	MTH_BOOK_DropdownSetText(rankDropdown, label)
end

local function MTH_BOOK_UpdatePetLearnSourceDropdownText()
	local sourceDropdown = getglobal("MTH_BOOK_PetLearnSourceDropdown")
	if not sourceDropdown then return end
	MTH_BOOK_DropdownSetText(sourceDropdown, MTH_BOOK_GetPetLearnSourceLabel(MTH_BOOK_STATE.petLearnSource))
end

local function MTH_BOOK_GetItemSubtypeLabelByValue(value)
	local options = MTH_BOOK_GetItemSubtypeOptions()
	for i = 1, table.getn(options) do
		local option = options[i]
		if option and option.value == value then
			return option.label
		end
	end
	if MTH_BOOK_STATE.mode == "projectiles" then return "All Projectiles" end
	if MTH_BOOK_STATE.mode == "ammobags" then return "All Ammo Bags" end
	return "All Ranged"
end

local function MTH_BOOK_UpdateItemSubtypeDropdownText()
	local itemDropdown = getglobal("MTH_BOOK_ItemSubtypeDropdown")
	if not itemDropdown then return end
	MTH_BOOK_DropdownSetText(itemDropdown, MTH_BOOK_GetItemSubtypeLabelByValue(MTH_BOOK_STATE.itemSubtype))
end

local function MTH_BOOK_UpdateNPCDropdownTexts()
	local functionDropdown = getglobal("MTH_BOOK_NPCFunctionDropdown")
	local zoneDropdown = getglobal("MTH_BOOK_NPCZoneDropdown")
	if functionDropdown then
		MTH_BOOK_DropdownSetText(functionDropdown, MTH_BOOK_GetNPCFunctionLabelByValue(MTH_BOOK_STATE.npcFunction))
	end
	if zoneDropdown then
		MTH_BOOK_DropdownSetText(zoneDropdown, MTH_BOOK_GetNPCZoneLabelByValue(MTH_BOOK_STATE.npcZone))
	end
end

local function MTH_BOOK_UpdateQuickFilterControls()
	MTH_BOOK_UpdateCheckboxLayoutByMode()
	if MTH_BOOK_IsItemMode() then
		MTH_BOOK_STATE.pageSize = 18
	elseif MTH_BOOK_STATE.mode == "families" then
		MTH_BOOK_STATE.pageSize = 16
	elseif MTH_BOOK_STATE.mode == "stable" then
		MTH_BOOK_STATE.pageSize = 5
	elseif MTH_BOOK_STATE.mode == "pethistory" then
		MTH_BOOK_STATE.pageSize = 20
	else
		MTH_BOOK_STATE.pageSize = 16
	end

	local familyDropdown = getglobal("MTH_BOOK_FamilyDropdown")
	local abilityDropdown = getglobal("MTH_BOOK_AbilityDropdown")
	local rankDropdown = getglobal("MTH_BOOK_RankDropdown")
	local petLearnSourceDropdown = getglobal("MTH_BOOK_PetLearnSourceDropdown")
	local itemSubtypeDropdown = getglobal("MTH_BOOK_ItemSubtypeDropdown")
	local npcFunctionDropdown = getglobal("MTH_BOOK_NPCFunctionDropdown")
	local npcZoneDropdown = getglobal("MTH_BOOK_NPCZoneDropdown")
	local searchLabel = getglobal("MTH_BOOK_SearchLabel")
	local minLabel = getglobal("MTH_BOOK_MinLabel")
	local maxLabel = getglobal("MTH_BOOK_MaxLabel")
	local search = getglobal("MTH_BOOK_Search")
	local applyButton = getglobal("MTH_BOOK_ApplyButton")
	local scanButton = getglobal("MTH_BOOK_PetBookScanButton")
	local hideNoAbilities = getglobal("MTH_BOOK_HideNoAbilities")
	local hideUnknown = getglobal("MTH_BOOK_HideUnknown")
	local petOnlyMyLevel = getglobal("MTH_BOOK_PetOnlyMyLevel")
	local petInZoneOnly = getglobal("MTH_BOOK_PetInZoneOnly")
	local npcInZoneOnly = getglobal("MTH_BOOK_NPCInZoneOnly")
	local showAllOnMapButton = getglobal("MTH_BOOK_ShowAllOnMapButton")
	local minLevel = getglobal("MTH_BOOK_MinLevel")
	local maxLevel = getglobal("MTH_BOOK_MaxLevel")
	local stats = getglobal("MTH_BOOK_StatsText")
	local prevButton = getglobal("MTH_BOOK_PrevButton")
	local nextButton = getglobal("MTH_BOOK_NextButton")
	local listSlider = getglobal("MTH_BOOK_ListSlider")
	local sliderBackdrop = getglobal("MTH_BOOK_ListSliderBackdrop")

	if MTH_BOOK_STATE.mode == "petabilities" or MTH_BOOK_STATE.mode == "stable" then
		if stats then stats:Hide() end
		if prevButton then prevButton:Hide() end
		if nextButton then nextButton:Hide() end
		if listSlider then listSlider:Hide() end
		if sliderBackdrop then sliderBackdrop:Hide() end
	elseif MTH_BOOK_STATE.mode == "families" then
		if stats then stats:Show() end
		if prevButton then prevButton:Hide() end
		if nextButton then nextButton:Hide() end
		if listSlider then listSlider:Hide() end
		if sliderBackdrop then sliderBackdrop:Hide() end
	else
		if stats then stats:Show() end
		if prevButton then prevButton:Show() end
		if nextButton then nextButton:Show() end
		if listSlider then listSlider:Show() end
		if sliderBackdrop then sliderBackdrop:Show() end
	end

	if MTH_BOOK_STATE.mode == "pets" then
		if searchLabel then searchLabel:Show() end
		if minLabel then minLabel:Show() end
		if maxLabel then maxLabel:Show() end
		if searchLabel then
			searchLabel:ClearAllPoints()
			searchLabel:SetPoint("TOPLEFT", searchLabel:GetParent(), "TOPLEFT", 18, -82)
		end
		if minLabel then
			minLabel:ClearAllPoints()
			minLabel:SetPoint("TOPLEFT", minLabel:GetParent(), "TOPLEFT", 248, -82)
		end
		if maxLabel then
			maxLabel:ClearAllPoints()
			maxLabel:SetPoint("TOPLEFT", maxLabel:GetParent(), "TOPLEFT", 356, -82)
		end
		if search then search:Show() end
		if search then
			search:ClearAllPoints()
			search:SetPoint("TOPLEFT", search:GetParent(), "TOPLEFT", 66, -80)
			search:SetWidth(160)
		end
		if minLevel then
			minLevel:ClearAllPoints()
			minLevel:SetPoint("TOPLEFT", minLevel:GetParent(), "TOPLEFT", 302, -80)
			minLevel:Show()
		end
		if maxLevel then
			maxLevel:ClearAllPoints()
			maxLevel:SetPoint("TOPLEFT", maxLevel:GetParent(), "TOPLEFT", 414, -80)
			maxLevel:Show()
		end
		if applyButton then applyButton:Show() end
		if applyButton then
			applyButton:ClearAllPoints()
			applyButton:SetPoint("TOPLEFT", applyButton:GetParent(), "TOPLEFT", 478, -80)
		end
		local resetButton = getglobal("MTH_BOOK_ResetButton")
		if resetButton then
			resetButton:ClearAllPoints()
			resetButton:SetPoint("TOPLEFT", resetButton:GetParent(), "TOPLEFT", 546, -80)
		end
		if scanButton then scanButton:Hide() end
		MTH_BOOK_BuildPetAbilityOptions()
		for i = 1, 6 do
			local btn = getglobal("MTH_BOOK_Filter" .. i)
			if btn then btn:Hide() end
		end
		if familyDropdown then
			familyDropdown:Show()
			MTH_BOOK_UpdateFamilyDropdownText()
		end
		if abilityDropdown then
			abilityDropdown:Show()
			MTH_BOOK_UpdateAbilityDropdownText()
		end
		local rankVisible = MTH_BOOK_BuildPetRankOptions()
		if rankDropdown then
			if rankVisible then
				rankDropdown:Show()
				MTH_BOOK_UpdateRankDropdownText()
			else
				rankDropdown:Hide()
			end
		end
		if petInZoneOnly then
			petInZoneOnly:Show()
			petInZoneOnly:SetChecked(MTH_BOOK_STATE.petInZoneOnly and 1 or nil)
		end
		if showAllOnMapButton then
			if MTH_BOOK_STATE.petInZoneOnly then
				showAllOnMapButton:Show()
			else
				showAllOnMapButton:Hide()
			end
		end
		if petLearnSourceDropdown then petLearnSourceDropdown:Hide() end
		if itemSubtypeDropdown then itemSubtypeDropdown:Hide() end
		if npcFunctionDropdown then npcFunctionDropdown:Hide() end
		if npcZoneDropdown then npcZoneDropdown:Hide() end
		MTH_BOOK_UpdateFamilyDropdownText()
		MTH_BOOK_UpdateAbilityDropdownText()
		if hideNoAbilities then hideNoAbilities:Show() end
		if hideUnknown then hideUnknown:Show() end
		if petOnlyMyLevel then petOnlyMyLevel:Hide() end
		if npcInZoneOnly then npcInZoneOnly:Hide() end
		local requireVendor = getglobal("MTH_BOOK_RequireVendor")
		local requireDrop = getglobal("MTH_BOOK_RequireDrop")
		local requireObject = getglobal("MTH_BOOK_RequireObject")
		if requireVendor then requireVendor:Show() end
		if requireDrop then requireDrop:Show() end
		if requireObject then requireObject:Show() end
	elseif MTH_BOOK_STATE.mode == "petabilities" then
		if searchLabel then searchLabel:Hide() end
		if minLabel then minLabel:Hide() end
		if maxLabel then maxLabel:Hide() end
		if search then search:Hide() end
		if applyButton then applyButton:Hide() end
		if scanButton then scanButton:Show() end
		if minLevel then minLevel:Hide() end
		if maxLevel then maxLevel:Hide() end
		for i = 1, 6 do
			local btn = getglobal("MTH_BOOK_Filter" .. i)
			if btn then btn:Hide() end
		end
		if familyDropdown then familyDropdown:Hide() end
		if abilityDropdown then abilityDropdown:Hide() end
		if rankDropdown then rankDropdown:Hide() end
		if petLearnSourceDropdown then
			petLearnSourceDropdown:Show()
			MTH_BOOK_UpdatePetLearnSourceDropdownText()
		end
		if itemSubtypeDropdown then itemSubtypeDropdown:Hide() end
		if petOnlyMyLevel then
			petOnlyMyLevel:ClearAllPoints()
			petOnlyMyLevel:SetPoint("TOPLEFT", petOnlyMyLevel:GetParent(), "TOPLEFT", 228, -80)
			petOnlyMyLevel:Show()
			petOnlyMyLevel:SetChecked(MTH_BOOK_STATE.petOnlyMyLevel and 1 or nil)
		end
		if petInZoneOnly then petInZoneOnly:Hide() end
		if npcInZoneOnly then npcInZoneOnly:Hide() end
		if showAllOnMapButton then showAllOnMapButton:Hide() end
		if npcFunctionDropdown then npcFunctionDropdown:Hide() end
		if npcZoneDropdown then npcZoneDropdown:Hide() end
		if hideNoAbilities then hideNoAbilities:Hide() end
		if hideUnknown then hideUnknown:Hide() end
		local requireVendor = getglobal("MTH_BOOK_RequireVendor")
		local requireDrop = getglobal("MTH_BOOK_RequireDrop")
		local requireObject = getglobal("MTH_BOOK_RequireObject")
		if requireVendor then requireVendor:Hide() end
		if requireDrop then requireDrop:Hide() end
		if requireObject then requireObject:Hide() end
		local resetButton = getglobal("MTH_BOOK_ResetButton")
		if resetButton then
			resetButton:ClearAllPoints()
			resetButton:SetPoint("TOPLEFT", resetButton:GetParent(), "TOPLEFT", 546, -80)
		end
	elseif MTH_BOOK_STATE.mode == "npcs" then
		if searchLabel then searchLabel:Show() end
		if minLabel then minLabel:Hide() end
		if maxLabel then maxLabel:Hide() end
		if search then search:Show() end
		if search then
			search:ClearAllPoints()
			search:SetPoint("TOPLEFT", search:GetParent(), "TOPLEFT", 54, -80)
			search:SetWidth(180)
		end
		if applyButton then applyButton:Show() end
		if applyButton then
			applyButton:ClearAllPoints()
			applyButton:SetPoint("TOPLEFT", applyButton:GetParent(), "TOPLEFT", 612, -80)
		end
		local resetButton = getglobal("MTH_BOOK_ResetButton")
		if resetButton then
			resetButton:ClearAllPoints()
			resetButton:SetPoint("TOPLEFT", resetButton:GetParent(), "TOPLEFT", 678, -80)
		end
		if scanButton then scanButton:Hide() end
		if minLevel then minLevel:Hide() end
		if maxLevel then maxLevel:Hide() end
		for i = 1, 6 do
			local btn = getglobal("MTH_BOOK_Filter" .. i)
			if btn then btn:Hide() end
		end
		if familyDropdown then familyDropdown:Hide() end
		if abilityDropdown then abilityDropdown:Hide() end
		if rankDropdown then rankDropdown:Hide() end
		if petLearnSourceDropdown then petLearnSourceDropdown:Hide() end
		if itemSubtypeDropdown then itemSubtypeDropdown:Hide() end
		if npcFunctionDropdown then npcFunctionDropdown:Show() end
		if npcZoneDropdown then npcZoneDropdown:Hide() end
		MTH_BOOK_BuildNPCFunctionOptions()
		MTH_BOOK_BuildNPCZoneOptions()
		MTH_BOOK_UpdateNPCDropdownTexts()
		if hideNoAbilities then hideNoAbilities:Hide() end
		if hideUnknown then hideUnknown:Show() end
		if petOnlyMyLevel then petOnlyMyLevel:Hide() end
		if petInZoneOnly then petInZoneOnly:Hide() end
		if npcInZoneOnly then
			npcInZoneOnly:ClearAllPoints()
			npcInZoneOnly:SetPoint("TOPLEFT", npcInZoneOnly:GetParent(), "TOPLEFT", 438, -82)
			npcInZoneOnly:Show()
			npcInZoneOnly:SetChecked(MTH_BOOK_STATE.npcInZoneOnly and 1 or nil)
		end
		if showAllOnMapButton then showAllOnMapButton:Hide() end
		local requireVendor = getglobal("MTH_BOOK_RequireVendor")
		local requireDrop = getglobal("MTH_BOOK_RequireDrop")
		local requireObject = getglobal("MTH_BOOK_RequireObject")
		if requireVendor then requireVendor:Show() end
		if requireDrop then requireDrop:Show() end
		if requireObject then requireObject:Show() end
	elseif MTH_BOOK_IsItemMode() then
		if searchLabel then searchLabel:Show() end
		if minLabel then minLabel:Hide() end
		if maxLabel then maxLabel:Hide() end
		if search then search:Show() end
		if search then
			search:ClearAllPoints()
			search:SetPoint("TOPLEFT", search:GetParent(), "TOPLEFT", 54, -80)
			search:SetWidth(180)
		end
		if applyButton then applyButton:Show() end
		if applyButton then
			applyButton:ClearAllPoints()
			applyButton:SetPoint("TOPLEFT", applyButton:GetParent(), "TOPLEFT", 612, -80)
		end
		local resetButton = getglobal("MTH_BOOK_ResetButton")
		if resetButton then
			resetButton:ClearAllPoints()
			resetButton:SetPoint("TOPLEFT", resetButton:GetParent(), "TOPLEFT", 678, -80)
		end
		if scanButton then scanButton:Hide() end
		if minLevel then minLevel:Hide() end
		if maxLevel then maxLevel:Hide() end
		for i = 1, 6 do
			local btn = getglobal("MTH_BOOK_Filter" .. i)
			if btn then btn:Hide() end
		end
		if familyDropdown then familyDropdown:Hide() end
		if abilityDropdown then abilityDropdown:Hide() end
		if rankDropdown then rankDropdown:Hide() end
		if petLearnSourceDropdown then petLearnSourceDropdown:Hide() end
		if itemSubtypeDropdown then
			itemSubtypeDropdown:ClearAllPoints()
			itemSubtypeDropdown:SetPoint("TOPLEFT", itemSubtypeDropdown:GetParent(), "TOPLEFT", 238, -80)
			itemSubtypeDropdown:Show()
			MTH_BOOK_UpdateItemSubtypeDropdownText()
		end
		if npcFunctionDropdown then npcFunctionDropdown:Hide() end
		if npcZoneDropdown then npcZoneDropdown:Hide() end
		if hideNoAbilities then hideNoAbilities:Hide() end
		if hideUnknown then hideUnknown:Hide() end
		if petOnlyMyLevel then
			petOnlyMyLevel:ClearAllPoints()
			petOnlyMyLevel:SetPoint("TOPLEFT", petOnlyMyLevel:GetParent(), "TOPLEFT", 430, -82)
			petOnlyMyLevel:Show()
			petOnlyMyLevel:SetChecked(MTH_BOOK_STATE.itemOnlyMyLevel and 1 or nil)
		end
		if petInZoneOnly then petInZoneOnly:Hide() end
		if npcInZoneOnly then npcInZoneOnly:Hide() end
		if showAllOnMapButton then showAllOnMapButton:Hide() end
		local requireVendor = getglobal("MTH_BOOK_RequireVendor")
		local requireDrop = getglobal("MTH_BOOK_RequireDrop")
		local requireObject = getglobal("MTH_BOOK_RequireObject")
		if requireVendor then requireVendor:Hide() end
		if requireDrop then requireDrop:Hide() end
		if requireObject then requireObject:Hide() end
	elseif MTH_BOOK_STATE.mode == "stable" then
		if searchLabel then searchLabel:Hide() end
		if minLabel then minLabel:Hide() end
		if maxLabel then maxLabel:Hide() end
		if search then search:Hide() end
		if applyButton then applyButton:Hide() end
		local resetButton = getglobal("MTH_BOOK_ResetButton")
		if resetButton then resetButton:Hide() end
		if scanButton then scanButton:Hide() end
		if minLevel then minLevel:Hide() end
		if maxLevel then maxLevel:Hide() end
		for i = 1, 6 do
			local btn = getglobal("MTH_BOOK_Filter" .. i)
			if btn then btn:Hide() end
		end
		if familyDropdown then familyDropdown:Hide() end
		if abilityDropdown then abilityDropdown:Hide() end
		if rankDropdown then rankDropdown:Hide() end
		if petLearnSourceDropdown then petLearnSourceDropdown:Hide() end
		if itemSubtypeDropdown then itemSubtypeDropdown:Hide() end
		if npcFunctionDropdown then npcFunctionDropdown:Hide() end
		if npcZoneDropdown then npcZoneDropdown:Hide() end
		if hideNoAbilities then hideNoAbilities:Hide() end
		if hideUnknown then hideUnknown:Hide() end
		if petOnlyMyLevel then petOnlyMyLevel:Hide() end
		if petInZoneOnly then petInZoneOnly:Hide() end
		if npcInZoneOnly then npcInZoneOnly:Hide() end
		if showAllOnMapButton then showAllOnMapButton:Hide() end
		local requireVendor = getglobal("MTH_BOOK_RequireVendor")
		local requireDrop = getglobal("MTH_BOOK_RequireDrop")
		local requireObject = getglobal("MTH_BOOK_RequireObject")
		if requireVendor then requireVendor:Hide() end
		if requireDrop then requireDrop:Hide() end
		if requireObject then requireObject:Hide() end
	elseif MTH_BOOK_STATE.mode == "families" then
		if searchLabel then searchLabel:Hide() end
		if minLabel then minLabel:Hide() end
		if maxLabel then maxLabel:Hide() end
		if search then search:Hide() end
		if applyButton then applyButton:Hide() end
		local resetButton = getglobal("MTH_BOOK_ResetButton")
		if resetButton then resetButton:Hide() end
		if scanButton then scanButton:Hide() end
		if minLevel then minLevel:Hide() end
		if maxLevel then maxLevel:Hide() end
		for i = 1, 6 do
			local btn = getglobal("MTH_BOOK_Filter" .. i)
			if btn then btn:Hide() end
		end
		if familyDropdown then familyDropdown:Hide() end
		if abilityDropdown then abilityDropdown:Hide() end
		if rankDropdown then rankDropdown:Hide() end
		if petLearnSourceDropdown then petLearnSourceDropdown:Hide() end
		if itemSubtypeDropdown then itemSubtypeDropdown:Hide() end
		if npcFunctionDropdown then npcFunctionDropdown:Hide() end
		if npcZoneDropdown then npcZoneDropdown:Hide() end
		if hideNoAbilities then hideNoAbilities:Hide() end
		if hideUnknown then hideUnknown:Hide() end
		if petOnlyMyLevel then petOnlyMyLevel:Hide() end
		if petInZoneOnly then petInZoneOnly:Hide() end
		if npcInZoneOnly then npcInZoneOnly:Hide() end
		if showAllOnMapButton then showAllOnMapButton:Hide() end
		local requireVendor = getglobal("MTH_BOOK_RequireVendor")
		local requireDrop = getglobal("MTH_BOOK_RequireDrop")
		local requireObject = getglobal("MTH_BOOK_RequireObject")
		if requireVendor then requireVendor:Hide() end
		if requireDrop then requireDrop:Hide() end
		if requireObject then requireObject:Hide() end
	elseif MTH_BOOK_STATE.mode == "pethistory" then
		if searchLabel then searchLabel:Hide() end
		if minLabel then minLabel:Hide() end
		if maxLabel then maxLabel:Hide() end
		if search then search:Hide() end
		if applyButton then applyButton:Hide() end
		local resetButton = getglobal("MTH_BOOK_ResetButton")
		if resetButton then resetButton:Hide() end
		if scanButton then scanButton:Hide() end
		if minLevel then minLevel:Hide() end
		if maxLevel then maxLevel:Hide() end
		for i = 1, 6 do
			local btn = getglobal("MTH_BOOK_Filter" .. i)
			if btn then btn:Hide() end
		end
		if familyDropdown then familyDropdown:Hide() end
		if abilityDropdown then abilityDropdown:Hide() end
		if rankDropdown then rankDropdown:Hide() end
		if petLearnSourceDropdown then petLearnSourceDropdown:Hide() end
		if itemSubtypeDropdown then itemSubtypeDropdown:Hide() end
		if npcFunctionDropdown then npcFunctionDropdown:Hide() end
		if npcZoneDropdown then npcZoneDropdown:Hide() end
		if hideNoAbilities then hideNoAbilities:Hide() end
		if hideUnknown then hideUnknown:Hide() end
		if petOnlyMyLevel then petOnlyMyLevel:Hide() end
		if petInZoneOnly then petInZoneOnly:Hide() end
		if npcInZoneOnly then npcInZoneOnly:Hide() end
		if showAllOnMapButton then showAllOnMapButton:Hide() end
		local requireVendor = getglobal("MTH_BOOK_RequireVendor")
		local requireDrop = getglobal("MTH_BOOK_RequireDrop")
		local requireObject = getglobal("MTH_BOOK_RequireObject")
		if requireVendor then requireVendor:Hide() end
		if requireDrop then requireDrop:Hide() end
		if requireObject then requireObject:Hide() end
	else
		if itemSubtypeDropdown then itemSubtypeDropdown:Hide() end
	end

	if MTH_BOOK_STATE.mode ~= "petabilities" and not MTH_BOOK_IsItemMode() and petOnlyMyLevel then
		petOnlyMyLevel:Hide()
	end
	if MTH_BOOK_STATE.mode ~= "pets" and petInZoneOnly then
		petInZoneOnly:Hide()
	end
	if MTH_BOOK_STATE.mode ~= "npcs" and npcInZoneOnly then
		npcInZoneOnly:Hide()
	end
	local resetButton = getglobal("MTH_BOOK_ResetButton")
	if resetButton and MTH_BOOK_STATE.mode ~= "stable" and MTH_BOOK_STATE.mode ~= "families" and MTH_BOOK_STATE.mode ~= "pethistory" then
		resetButton:Show()
	end
	MTH_BOOK_UpdateShowAllOnMapButton()

	MTH_BOOK_ApplyContentLayoutForMode()
end

local function MTH_BOOK_InitFamilyDropdown()
	local familyDropdown = getglobal("MTH_BOOK_FamilyDropdown")
	if not familyDropdown then return end
	MTH_BOOK_BuildPetFamilyOptions()

	UIDropDownMenu_Initialize(familyDropdown, function()
		for i = 1, table.getn(MTH_BOOK_PetFamilyOptions) do
			local option = MTH_BOOK_PetFamilyOptions[i]
			local value = option.value
			local label = option.label
			local index = i
			local info = MTH_BOOK_DropdownCreateInfo()
			info.text = label
			info.func = function()
				MTH_BOOK_STATE.quick = value
				MTH_BOOK_STATE.page = 1
				MTH_BOOK_STATE.selectedEntry = nil
				MTH_BOOK_DropdownSetText(familyDropdown, label)
				MTH_BOOK_RefreshFilter()
			end
			info.checked = (MTH_BOOK_STATE.quick == value)
			UIDropDownMenu_AddButton(info)
		end
	end)

	UIDropDownMenu_SetWidth(150, familyDropdown)
	UIDropDownMenu_JustifyText("LEFT", familyDropdown)
	MTH_BOOK_UpdateFamilyDropdownText()
end

local function MTH_BOOK_InitAbilityDropdown()
	local abilityDropdown = getglobal("MTH_BOOK_AbilityDropdown")
	if not abilityDropdown then return end
	MTH_BOOK_BuildPetAbilityOptions()

	UIDropDownMenu_Initialize(abilityDropdown, function()
		for i = 1, table.getn(MTH_BOOK_PetAbilityOptions) do
			local option = MTH_BOOK_PetAbilityOptions[i]
			local value = option.value
			local label = option.label
			local index = i
			local info = MTH_BOOK_DropdownCreateInfo()
			info.text = label
			info.func = function()
				MTH_BOOK_STATE.petAbility = value
				MTH_BOOK_STATE.petRank = "all"
				MTH_BOOK_BuildPetRankOptions()
				MTH_BOOK_STATE.page = 1
				MTH_BOOK_STATE.selectedEntry = nil
				MTH_BOOK_DropdownSetText(abilityDropdown, label)
				MTH_BOOK_UpdateQuickFilterControls()
				MTH_BOOK_RefreshFilter()
			end
			info.checked = (MTH_BOOK_STATE.petAbility == value)
			UIDropDownMenu_AddButton(info)
		end
	end)

	UIDropDownMenu_SetWidth(150, abilityDropdown)
	UIDropDownMenu_JustifyText("LEFT", abilityDropdown)
	MTH_BOOK_UpdateAbilityDropdownText()
end

local function MTH_BOOK_InitRankDropdown()
	local rankDropdown = getglobal("MTH_BOOK_RankDropdown")
	if not rankDropdown then return end
	MTH_BOOK_BuildPetRankOptions()

	UIDropDownMenu_Initialize(rankDropdown, function()
		for i = 1, table.getn(MTH_BOOK_PetRankOptions) do
			local option = MTH_BOOK_PetRankOptions[i]
			local value = option.value
			local label = option.label
			local index = i
			local info = MTH_BOOK_DropdownCreateInfo()
			info.text = label
			info.func = function()
				MTH_BOOK_STATE.petRank = value
				MTH_BOOK_STATE.page = 1
				MTH_BOOK_STATE.selectedEntry = nil
				MTH_BOOK_DropdownSetText(rankDropdown, label)
				MTH_BOOK_RefreshFilter()
			end
			info.checked = (tostring(MTH_BOOK_STATE.petRank) == tostring(value))
			UIDropDownMenu_AddButton(info)
		end
	end)

	UIDropDownMenu_SetWidth(120, rankDropdown)
	UIDropDownMenu_JustifyText("LEFT", rankDropdown)
	MTH_BOOK_UpdateRankDropdownText()
end

local function MTH_BOOK_InitPetLearnSourceDropdown()
	local sourceDropdown = getglobal("MTH_BOOK_PetLearnSourceDropdown")
	if not sourceDropdown then return end

	UIDropDownMenu_Initialize(sourceDropdown, function()
		for i = 1, table.getn(MTH_BOOK_PetLearnSourceOptions) do
			local option = MTH_BOOK_PetLearnSourceOptions[i]
			local info = MTH_BOOK_DropdownCreateInfo()
			info.text = option.label
			info.func = function()
				MTH_BOOK_STATE.petLearnSource = option.value
				MTH_BOOK_STATE.page = 1
				MTH_BOOK_STATE.selectedEntry = nil
				MTH_BOOK_STATE.selectedPetRankEntry = nil
				MTH_BOOK_STATE.petRankRows = {}
				MTH_BOOK_DropdownSetText(sourceDropdown, option.label)
				MTH_BOOK_RefreshFilter()
			end
			info.checked = (MTH_BOOK_STATE.petLearnSource == option.value)
			UIDropDownMenu_AddButton(info)
		end
	end)

	UIDropDownMenu_SetWidth(140, sourceDropdown)
	UIDropDownMenu_JustifyText("LEFT", sourceDropdown)
	MTH_BOOK_UpdatePetLearnSourceDropdownText()
end

local function MTH_BOOK_InitItemSubtypeDropdown()
	local itemDropdown = getglobal("MTH_BOOK_ItemSubtypeDropdown")
	if not itemDropdown then return end

	UIDropDownMenu_Initialize(itemDropdown, function()
		local options = MTH_BOOK_GetItemSubtypeOptions()
		for i = 1, table.getn(options) do
			local option = options[i]
			local info = MTH_BOOK_DropdownCreateInfo()
			info.text = option.label
			info.func = function()
				MTH_BOOK_STATE.itemSubtype = option.value
				MTH_BOOK_STATE.page = 1
				MTH_BOOK_STATE.selectedEntry = nil
				MTH_BOOK_DropdownSetText(itemDropdown, option.label)
				MTH_BOOK_RefreshFilter()
			end
			info.checked = (MTH_BOOK_STATE.itemSubtype == option.value)
			UIDropDownMenu_AddButton(info)
		end
	end)

	UIDropDownMenu_SetWidth(120, itemDropdown)
	UIDropDownMenu_JustifyText("LEFT", itemDropdown)
	MTH_BOOK_UpdateItemSubtypeDropdownText()
end

local function MTH_BOOK_InitNPCFunctionDropdown()
	local functionDropdown = getglobal("MTH_BOOK_NPCFunctionDropdown")
	if not functionDropdown then return end
	MTH_BOOK_BuildNPCFunctionOptions()

	UIDropDownMenu_Initialize(functionDropdown, function()
		for i = 1, table.getn(MTH_BOOK_NPCFunctionOptions) do
			local option = MTH_BOOK_NPCFunctionOptions[i]
			local info = MTH_BOOK_DropdownCreateInfo()
			info.text = option.label
			info.func = function()
				MTH_BOOK_STATE.npcFunction = option.value
				MTH_BOOK_STATE.page = 1
				MTH_BOOK_STATE.selectedEntry = nil
				MTH_BOOK_DropdownSetText(functionDropdown, option.label)
				MTH_BOOK_RefreshFilter()
			end
			info.checked = (MTH_BOOK_STATE.npcFunction == option.value)
			UIDropDownMenu_AddButton(info)
		end
	end)

	UIDropDownMenu_SetWidth(150, functionDropdown)
	UIDropDownMenu_JustifyText("LEFT", functionDropdown)
	MTH_BOOK_UpdateNPCDropdownTexts()
end
local function MTH_BOOK_AddDetailSection(lines, title)
	table.insert(lines, "")
	table.insert(lines, "|cFFFFD100" .. tostring(title) .. "|r")
end

local function MTH_BOOK_AddDetailKV(lines, label, value)
	table.insert(lines, tostring(label) .. ": " .. tostring(value))
end

local function MTH_BOOK_AddStableStyleKV(lines, label, value)
	table.insert(lines, "|cff9a9a9a" .. tostring(label or "") .. ":|r |cffffffff" .. tostring(value or "-") .. "|r")
end

local function MTH_BOOK_FormatDateTimeValue(value)
	local ts = tonumber(value)
	if not ts or ts <= 0 then
		return "-"
	end
	if type(date) == "function" then
		return date("%Y-%m-%d %H:%M:%S", ts)
	end
	return tostring(ts)
end

local function MTH_BOOK_GetPetHistoryLostCause(row)
	local reason = MTH_BOOK_SafeLower(type(row) == "table" and row.abandonReason or "")
	if reason == "pet-runaway" then
		return "Ran Away"
	end
	if string.find(reason, "runaway", 1, true) or string.find(reason, "run away", 1, true) then
		return "Ran Away"
	end
	return "Abandonned"
end

local function MTH_BOOK_FormatRespawnWindow(beast)
	if not beast then return nil end
	local minSec = tonumber(beast.respawnMinSeconds)
	local maxSec = tonumber(beast.respawnMaxSeconds)
	local samples = tonumber(beast.respawnSamples)
	if not minSec and not maxSec then return nil end
	if not minSec then minSec = maxSec end
	if not maxSec then maxSec = minSec end

	local function fmt(sec)
		sec = math.floor((tonumber(sec) or 0) + 0.5)
		if sec < 0 then sec = 0 end
		if SecondsToTime then
			return SecondsToTime(sec)
		end
		if sec >= 3600 then
			return string.format("%.1fh", sec / 3600)
		elseif sec >= 60 then
			return string.format("%.1fm", sec / 60)
		end
		return tostring(sec) .. "s"
	end

	local value
	if minSec == maxSec then
		value = fmt(minSec)
	else
		value = fmt(minSec) .. " - " .. fmt(maxSec)
	end

	if samples and samples > 0 then
		value = value .. " (" .. tostring(samples) .. " samples)"
	end

	return value
end

function MTH_BOOK_ResolveIconPath(icon)
	if not icon or icon == "" then return nil end
	local iconText = tostring(icon)
	if string.find(iconText, "\\", 1, true) then
		return iconText
	end
	return "Interface\\Icons\\" .. iconText
end

local MTH_BOOK_SpellTooltip = nil

function MTH_BOOK_GetSpellTooltip()
	if MTH_BOOK_SpellTooltip then return MTH_BOOK_SpellTooltip end
	if not CreateFrame then return GameTooltip end
	MTH_BOOK_SpellTooltip = CreateFrame("GameTooltip", "MTH_BOOK_SpellTooltip", UIParent, "GameTooltipTemplate")
	MTH_BOOK_SpellTooltip.mthIcon = MTH_BOOK_SpellTooltip:CreateTexture(nil, "ARTWORK")
	MTH_BOOK_SpellTooltip.mthIcon:SetPoint("TOPRIGHT", MTH_BOOK_SpellTooltip, "TOPRIGHT", -8, -8)
	MTH_BOOK_SpellTooltip.mthIcon:SetWidth(36)
	MTH_BOOK_SpellTooltip.mthIcon:SetHeight(36)
	MTH_BOOK_SpellTooltip.mthIcon:Hide()
	return MTH_BOOK_SpellTooltip
end

function MTH_BOOK_SetSpellTooltipIcon(tooltip, icon)
	if not tooltip then return end
	if not tooltip.mthIcon then return end
	local iconPath = MTH_BOOK_ResolveIconPath(icon)
	if iconPath then
		tooltip.mthIcon:SetTexture(iconPath)
		tooltip.mthIcon:Show()
	else
		tooltip.mthIcon:Hide()
	end
end

function MTH_BOOK_HideSpellTooltip()
	local tooltip = MTH_BOOK_SpellTooltip
	if tooltip and tooltip.mthIcon then
		tooltip.mthIcon:Hide()
	end
	if tooltip and tooltip.Hide then
		tooltip:Hide()
	end
end

function MTH_BOOK_ShowBaselineTooltip(anchor, entry)
	if not anchor or not entry then return end
	local tooltip = MTH_BOOK_GetSpellTooltip()
	if not tooltip then return end

	tooltip:SetOwner(anchor, "ANCHOR_RIGHT")
	tooltip:ClearLines()
	MTH_BOOK_SetSpellTooltipIcon(tooltip, entry.icon)
	tooltip:AddLine(tostring(entry.ability or "Unknown"), 1.00, 0.82, 0.00)
	tooltip:AddLine(" ")
	tooltip:AddLine("Spell Baseline", 1.00, 0.82, 0.00)
	tooltip:AddDoubleLine("Known Ranks", tostring(entry.knownRankCount or 0) .. "/" .. tostring(entry.rankCount or 0), 0.85, 0.85, 0.85, 1, 1, 1)
	tooltip:AddDoubleLine("Families", tostring(entry.familyCount or 0), 0.85, 0.85, 0.85, 1, 1, 1)
	tooltip:AddDoubleLine("Spell Rows", tostring(entry.spellRows or 0), 0.85, 0.85, 0.85, 1, 1, 1)
	if entry.minRank and entry.maxRank then
		if entry.minRank == entry.maxRank then
			tooltip:AddDoubleLine("Rank Span", tostring(entry.minRank), 0.85, 0.85, 0.85, 1, 1, 1)
		else
			tooltip:AddDoubleLine("Rank Span", tostring(entry.minRank) .. "-" .. tostring(entry.maxRank), 0.85, 0.85, 0.85, 1, 1, 1)
		end
	end

	if entry.families and table.getn(entry.families) > 0 then
		tooltip:AddLine(" ")
		tooltip:AddLine("Families", 1.00, 0.82, 0.00)
		for i = 1, table.getn(entry.families) do
			tooltip:AddLine("- " .. tostring(entry.families[i]), 0.90, 0.90, 0.90)
			if i >= 10 then
				local remaining = table.getn(entry.families) - i
				if remaining > 0 then
					tooltip:AddLine("... +" .. tostring(remaining) .. " more", 0.70, 0.70, 0.70)
				end
				break
			end
		end
	end

	tooltip:Show()
end

function MTH_BOOK_ShowRankTooltip(anchor, rankEntry)
	if not anchor or not rankEntry then return end
	local tooltip = MTH_BOOK_GetSpellTooltip()
	if not tooltip then return end

	tooltip:SetOwner(anchor, "ANCHOR_RIGHT")
	tooltip:ClearLines()
	MTH_BOOK_SetSpellTooltipIcon(tooltip, rankEntry.icon)

	local header = tostring(rankEntry.ability or "Spell")
	header = header .. " (" .. MTH_BOOK_GetRankLabel(rankEntry.rankNumber, true) .. ")"
	tooltip:AddLine(header, 1.00, 0.82, 0.00)
	tooltip:AddLine(" ")
	tooltip:AddLine("Current Rank", 1.00, 0.82, 0.00)
	tooltip:AddDoubleLine("Rank", MTH_BOOK_GetRankLabel(rankEntry.rankNumber, true), 0.85, 0.85, 0.85, 1, 1, 1)
	tooltip:AddDoubleLine("Known", rankEntry.isKnown and "v" or "-", 0.85, 0.85, 0.85, rankEntry.isKnown and 0.18 or 0.90, rankEntry.isKnown and 0.90 or 0.90, rankEntry.isKnown and 0.18 or 0.90)
	tooltip:AddDoubleLine("Train Level", rankEntry.trainLevel and tostring(rankEntry.trainLevel) or "-", 0.85, 0.85, 0.85, 1, 1, 1)
	tooltip:AddDoubleLine("Spell ID", rankEntry.id and tostring(rankEntry.id) or "-", 0.85, 0.85, 0.85, 1, 1, 1)
	if rankEntry.cost and rankEntry.cost ~= "" then
		tooltip:AddDoubleLine("Cost", tostring(rankEntry.cost), 0.85, 0.85, 0.85, 1, 1, 1)
	end
	if rankEntry.castTime and rankEntry.castTime ~= "" then
		tooltip:AddDoubleLine("Cast", tostring(rankEntry.castTime), 0.85, 0.85, 0.85, 1, 1, 1)
	end
	if rankEntry.range and rankEntry.range ~= "" then
		tooltip:AddDoubleLine("Range", tostring(rankEntry.range), 0.85, 0.85, 0.85, 1, 1, 1)
	end
	if rankEntry.school and rankEntry.school ~= "" then
		tooltip:AddDoubleLine("School", tostring(rankEntry.school), 0.85, 0.85, 0.85, 1, 1, 1)
	end

	if rankEntry.description and rankEntry.description ~= "" then
		tooltip:AddLine(" ")
		tooltip:AddLine("Description", 1.00, 0.82, 0.00)
		tooltip:AddLine(tostring(rankEntry.description), 0.90, 0.90, 0.90, true)
	end

	if rankEntry.effects then
		local effectsType = type(rankEntry.effects)
		if effectsType == "table" and table.getn(rankEntry.effects) > 0 then
			tooltip:AddLine(" ")
			tooltip:AddLine("Effects", 1.00, 0.82, 0.00)
			for i = 1, table.getn(rankEntry.effects) do
				tooltip:AddLine("- " .. tostring(rankEntry.effects[i]), 0.90, 0.90, 0.90, true)
			end
		elseif effectsType == "string" and rankEntry.effects ~= "" then
			tooltip:AddLine(" ")
			tooltip:AddLine("Effects", 1.00, 0.82, 0.00)
			tooltip:AddLine(tostring(rankEntry.effects), 0.90, 0.90, 0.90, true)
		end
	end

	tooltip:Show()
end

local function MTH_BOOK_WrapLine(text, maxChars)
	local line = tostring(text or "")
	if string.len(line) <= maxChars then return line end
	local out = {}
	local remaining = line
	while string.len(remaining) > maxChars do
		local chunk = string.sub(remaining, 1, maxChars)
		local cut = nil
		for i = maxChars, 1, -1 do
			if string.sub(chunk, i, i) == " " then
				cut = i
				break
			end
		end
		if not cut or cut < 8 then cut = maxChars end
		table.insert(out, string.sub(remaining, 1, cut))
		remaining = string.gsub(string.sub(remaining, cut + 1), "^%s+", "")
	end
	if remaining ~= "" then table.insert(out, remaining) end
	return table.concat(out, "\n")
end

local function MTH_BOOK_WrapDetailText(text)
	local src = tostring(text or "")
	local lines = {}
	local startPos = 1
	while true do
		local nl = string.find(src, "\n", startPos, true)
		if not nl then
			table.insert(lines, MTH_BOOK_WrapLine(string.sub(src, startPos), 28))
			break
		end
		table.insert(lines, MTH_BOOK_WrapLine(string.sub(src, startPos, nl - 1), 28))
		startPos = nl + 1
	end
	return table.concat(lines, "\n")
end

function MTH_BOOK_SetDetailText(detail, text)
	if not detail then return end
	local wrapped = tostring(text or "")
	if MTH_BOOK_STATE.mode ~= "pethistory" then
		wrapped = MTH_BOOK_WrapDetailText(wrapped)
	end
	detail._mthLocking = true
	detail:SetText(wrapped)
	detail._mthLockedText = wrapped
	detail._mthLocking = false
end

function MTH_BOOK_ConfigureReadOnlyEditBox(detail)
	if not detail then return end
	if detail.SetFontObject then detail:SetFontObject(GameFontNormalSmall) end
	if detail.SetJustifyH then detail:SetJustifyH("LEFT") end
	if detail.SetJustifyV then detail:SetJustifyV("TOP") end
	if detail.SetMultiLine then detail:SetMultiLine(true) end
	if detail.SetAutoFocus then detail:SetAutoFocus(false) end
	if detail.SetMaxLetters then detail:SetMaxLetters(0) end
	if detail.SetTextInsets then detail:SetTextInsets(4, 4, 4, 4) end
	if detail.EnableMouse then detail:EnableMouse(true) end
	if detail.EnableKeyboard then detail:EnableKeyboard(true) end
	if detail.SetScript then
		detail:SetScript("OnChar", function()
			if this._mthLockedText then
				this._mthLocking = true
				this:SetText(this._mthLockedText)
				this._mthLocking = false
			end
		end)
		detail:SetScript("OnKeyDown", function()
			if this._mthLockedText then
				this._mthLocking = true
				this:SetText(this._mthLockedText)
				this._mthLocking = false
			end
		end)
		detail:SetScript("OnTextChanged", function()
			if this._mthLocking then return end
			local current = this:GetText() or ""
			if this._mthLockedText and current ~= this._mthLockedText then
				this._mthLocking = true
				this:SetText(this._mthLockedText)
				this._mthLocking = false
			end
		end)
		detail:SetScript("OnEscapePressed", function() this:ClearFocus() end)
		detail:SetScript("OnEnterPressed", function() this:ClearFocus() end)
	end
	detail._mthLockedText = detail:GetText() or ""
end

function MTH_BOOK_UpdateDetail()
	local detail = getglobal("MTH_BOOK_DetailBackdropDetailText")
	if not detail then return end
	local petTop = MTH_BOOK_STATE.petUI and MTH_BOOK_STATE.petUI.detailTop
	local petBottom = MTH_BOOK_STATE.petUI and MTH_BOOK_STATE.petUI.detailBottom
	if not MTH_BOOK_STATE.selectedEntry then
		if MTH_BOOK_STATE.mode == "petabilities" then
			if petTop and petBottom then
				MTH_BOOK_SetDetailText(petTop, "|cFFFFD100Baseline|r\n\nSelect a spell baseline from the left list.")
				MTH_BOOK_SetDetailText(petBottom, "|cFFFFD100Rank|r\n\nSelect a rank from the right list.")
			else
				MTH_BOOK_SetDetailText(detail, "|cFFFFD100Pet Abilities|r\n\nSelect a spell baseline to inspect rank coverage and families.")
			end
		else
			MTH_BOOK_SetDetailText(detail, "|cFFFFD100Inspector|r\n\nSelect an entry from the list to view identity, stats, sources and locations.")
		end
		MTH_BOOK_UpdateOpenMapButton()
		return
	end

	if MTH_BOOK_STATE.mode == "npcs" then
		local selected = MTH_BOOK_STATE.selectedEntry
		if not selected or not selected.npcId then
			MTH_BOOK_SetDetailText(detail, "|cFFFFD100Inspector|r\n\nSelect an NPC to view details and map locations.")
			MTH_BOOK_UpdateOpenMapButton()
			return
		end
		local npcId = selected.npcId
		local npc = MTH_DS_Vendors and MTH_DS_Vendors[npcId]
		if not npc then
			MTH_BOOK_SetDetailText(detail, "|cFFFFD100Inspector|r\n\nSelect an NPC to view details and map locations.")
			MTH_BOOK_UpdateOpenMapButton()
			return
		end

		local functionSummary = MTH_BOOK_GetNPCFunctionSummary(npc)
		local zoneName, subzoneName = MTH_BOOK_GetNPCZoneSummary(npc)
		local npcName = (MTH and MTH.GetLocalizedNPCNameById and MTH:GetLocalizedNPCNameById(npcId, npc.name)) or npc.name
		local lines = {}
		table.insert(lines, "|cFFFFFF00" .. tostring(npcName or "Unknown") .. "|r")
		MTH_BOOK_AddDetailSection(lines, "Identity")
		MTH_BOOK_AddDetailKV(lines, "ID", npcId)
		MTH_BOOK_AddDetailKV(lines, "React", MTH_BOOK_GetNPCReactBucket(npc.fac))
		MTH_BOOK_AddDetailKV(lines, "Function", functionSummary)
		MTH_BOOK_AddDetailKV(lines, "Level", npc.lvl or "?")

		MTH_BOOK_AddDetailSection(lines, "Location")
		MTH_BOOK_AddDetailKV(lines, "Zone", zoneName)
		MTH_BOOK_AddDetailKV(lines, "Subzone", subzoneName)
		if npc.coords and table.getn(npc.coords) > 0 then
			for i = 1, table.getn(npc.coords) do
				local c = npc.coords[i]
				if c then
					local x = tonumber(c[1] or 0) or 0
					local y = tonumber(c[2] or 0) or 0
					table.insert(lines, string.format("  - %s (%.1f, %.1f)", MTH_BOOK_GetZoneName(c[3]), x, y))
				end
				if i >= 8 then break end
			end
		else
			table.insert(lines, "  - No coordinates")
		end

		MTH_BOOK_SetDetailText(detail, table.concat(lines, "\n"))
		MTH_BOOK_UpdateOpenMapButton()
		return
	end

	if MTH_BOOK_STATE.mode == "pets" then
		local selected = MTH_BOOK_STATE.selectedEntry
		if not selected or not selected.beastId then
			MTH_BOOK_SetDetailText(detail, "|cFFFFD100Inspector|r\n\nSelect an entry from the list to view identity, stats, sources and locations.")
			MTH_BOOK_UpdateOpenMapButton()
			return
		end
		local beastId = selected.beastId
		local beast = MTH_DS_Beasts and MTH_DS_Beasts[beastId]
		if not beast then
			MTH_BOOK_SetDetailText(detail, "|cFFFFD100Inspector|r\n\nSelect an entry from the list to view identity, stats, sources and locations.")
			MTH_BOOK_UpdateOpenMapButton()
			return
		end
		local lines = {}
		local beastDisplayName = (MTH and MTH.GetLocalizedBeastName and MTH:GetLocalizedBeastName(beastId, beast.name)) or beast.name
		table.insert(lines, "|cFFFFFF00" .. (beastDisplayName or "Unknown") .. "|r")
		MTH_BOOK_AddDetailSection(lines, "Identity")
		MTH_BOOK_AddDetailKV(lines, "ID", beastId)
		MTH_BOOK_AddDetailKV(lines, "Family", beast.family or "?")

		MTH_BOOK_AddDetailSection(lines, "Stats")
		MTH_BOOK_AddDetailKV(lines, "Level", beast.lvl or "?")
		MTH_BOOK_AddDetailKV(lines, "Attack Speed", beast.attackSpeed or "?")
		local respawnWindow = MTH_BOOK_FormatRespawnWindow(beast)
		if respawnWindow then
			MTH_BOOK_AddDetailKV(lines, "Respawn", respawnWindow)
		end
		MTH_BOOK_AddDetailKV(lines, "Rare", beast.rare and "Yes" or "No")
		MTH_BOOK_AddDetailKV(lines, "Abilities", beast.abilities or "None")

		local fam = MTH_DS_Families and beast.family and MTH_DS_Families[beast.family]
		if fam and fam.abilities and table.getn(fam.abilities) > 0 then
			MTH_BOOK_AddDetailSection(lines, "Family Pool")
			table.insert(lines, "  " .. table.concat(fam.abilities, ", "))
		end

		if beast.coords and table.getn(beast.coords) > 0 then
			MTH_BOOK_AddDetailSection(lines, "Locations")
			for i = 1, table.getn(beast.coords) do
				local c = beast.coords[i]
				if c then
					local x = tonumber(c[1] or 0) or 0
					local y = tonumber(c[2] or 0) or 0
					local zoneId = c[3]
					table.insert(lines, string.format("  - %s (%.1f, %.1f)", MTH_BOOK_GetZoneName(zoneId), x, y))
				end
				if i >= 8 then break end
			end
		end

		MTH_BOOK_SetDetailText(detail, table.concat(lines, "\n"))
		MTH_BOOK_UpdateOpenMapButton()
		return
	end

	if MTH_BOOK_STATE.mode == "abilities" then
		local entry = MTH_BOOK_STATE.selectedEntry
		if not entry or not entry.beastId then
			MTH_BOOK_SetDetailText(detail, "|cFFFFD100Inspector|r\n\nSelect an entry from the list to view identity, stats, sources and locations.")
			MTH_BOOK_UpdateOpenMapButton()
			return
		end
		local beast = MTH_DS_Beasts and MTH_DS_Beasts[entry.beastId]
		if not beast then
			MTH_BOOK_SetDetailText(detail, "|cFFFFD100Inspector|r\n\nSelect an entry from the list to view identity, stats, sources and locations.")
			MTH_BOOK_UpdateOpenMapButton()
			return
		end
		local lines = {}
		table.insert(lines, "|cFFFFFF00" .. tostring(entry.abilityToken) .. "|r")
		local beastDisplayName = (MTH and MTH.GetLocalizedBeastName and MTH:GetLocalizedBeastName(entry.beastId, beast.name)) or beast.name

		MTH_BOOK_AddDetailSection(lines, "Identity")
		MTH_BOOK_AddDetailKV(lines, "Beast", tostring(beastDisplayName or "Unknown") .. " (ID " .. tostring(entry.beastId) .. ")")
		MTH_BOOK_AddDetailKV(lines, "Family", beast.family or "?")

		MTH_BOOK_AddDetailSection(lines, "Stats")
		MTH_BOOK_AddDetailKV(lines, "Level", beast.lvl or "?")
		MTH_BOOK_AddDetailKV(lines, "Attack Speed", beast.attackSpeed or "?")
		local respawnWindow = MTH_BOOK_FormatRespawnWindow(beast)
		if respawnWindow then
			MTH_BOOK_AddDetailKV(lines, "Respawn", respawnWindow)
		end
		MTH_BOOK_AddDetailKV(lines, "Rare", beast.rare and "Yes" or "No")

		if beast.coords and table.getn(beast.coords) > 0 then
			MTH_BOOK_AddDetailSection(lines, "Locations")
			for i = 1, table.getn(beast.coords) do
				local c = beast.coords[i]
				if c then
					local x = tonumber(c[1] or 0) or 0
					local y = tonumber(c[2] or 0) or 0
					local zoneId = c[3]
					table.insert(lines, string.format("  - %s (%.1f, %.1f)", MTH_BOOK_GetZoneName(zoneId), x, y))
				end
				if i >= 8 then break end
			end
		end

		MTH_BOOK_SetDetailText(detail, table.concat(lines, "\n"))
		MTH_BOOK_UpdateOpenMapButton()
		return
	end

	if MTH_BOOK_STATE.mode == "petabilities" then
		local entry = MTH_BOOK_STATE.selectedEntry
		if not entry then
			if petTop and petBottom then
				MTH_BOOK_SetDetailText(petTop, "Select a spell baseline from the left list.")
				MTH_BOOK_SetDetailText(petBottom, "Select a rank from the right list.")
				if MTH_BOOK_STATE.petUI and MTH_BOOK_STATE.petUI.detailTopIcon then
					MTH_BOOK_STATE.petUI.detailTopIcon:Hide()
				end
			else
				MTH_BOOK_SetDetailText(detail, "|cFFFFD100Pet Abilities|r\n\nSelect a spell baseline to inspect rank coverage and families.")
			end
			MTH_BOOK_UpdateOpenMapButton()
			return
		end

		local topLines = {}
		table.insert(topLines, tostring(entry.ability or "Unknown"))
		table.insert(topLines, "")
		table.insert(topLines, "Baseline")
		MTH_BOOK_AddDetailKV(topLines, "Ranks", entry.rankText ~= "" and entry.rankText or "")
		MTH_BOOK_AddDetailKV(topLines, "Families", entry.familyCount or 0)
		MTH_BOOK_AddDetailKV(topLines, "Spell Rows", entry.spellRows or 0)
		if entry.minRank and entry.maxRank then
			if entry.minRank == entry.maxRank then
				MTH_BOOK_AddDetailKV(topLines, "Rank Span", tostring(entry.minRank))
			else
				MTH_BOOK_AddDetailKV(topLines, "Rank Span", tostring(entry.minRank) .. "-" .. tostring(entry.maxRank))
			end
		end
		table.insert(topLines, "")
		table.insert(topLines, "Families")
		if entry.families and table.getn(entry.families) > 0 then
			for i = 1, table.getn(entry.families) do
				table.insert(topLines, "  - " .. tostring(entry.families[i]))
			end
		else
			table.insert(topLines, "  - None")
		end

		local rankEntry = MTH_BOOK_STATE.selectedPetRankEntry
		local bottomLines = {}
		if rankEntry then
			table.insert(bottomLines, MTH_BOOK_GetRankLabel(rankEntry.rankNumber, true))
			table.insert(bottomLines, "")
			table.insert(bottomLines, "Rank Detail")
			MTH_BOOK_AddDetailKV(bottomLines, "Train Level", rankEntry.trainLevel or "-")
			MTH_BOOK_AddDetailKV(bottomLines, "Spell ID", rankEntry.id or "-")
			if rankEntry.cost and rankEntry.cost ~= "" then MTH_BOOK_AddDetailKV(bottomLines, "Cost", rankEntry.cost) end
			if rankEntry.castTime and rankEntry.castTime ~= "" then MTH_BOOK_AddDetailKV(bottomLines, "Cast", rankEntry.castTime) end
			if rankEntry.range and rankEntry.range ~= "" then MTH_BOOK_AddDetailKV(bottomLines, "Range", rankEntry.range) end
			if rankEntry.school and rankEntry.school ~= "" then MTH_BOOK_AddDetailKV(bottomLines, "School", rankEntry.school) end
			table.insert(bottomLines, "")
			table.insert(bottomLines, "Description")
			table.insert(bottomLines, "  " .. tostring(rankEntry.description or "-"))
		else
			table.insert(bottomLines, "Select a rank from the right list.")
		end

		if petTop and petBottom then
			MTH_BOOK_SetDetailText(petTop, table.concat(topLines, "\n"))
			MTH_BOOK_SetDetailText(petBottom, table.concat(bottomLines, "\n"))
			if MTH_BOOK_STATE.petUI and MTH_BOOK_STATE.petUI.detailTopIcon then
				if entry.icon and entry.icon ~= "" then
					if string.find(entry.icon, "\\", 1, true) then
						MTH_BOOK_STATE.petUI.detailTopIcon:SetTexture(entry.icon)
					else
						MTH_BOOK_STATE.petUI.detailTopIcon:SetTexture("Interface\\Icons\\" .. tostring(entry.icon))
					end
					MTH_BOOK_STATE.petUI.detailTopIcon:Show()
				else
					MTH_BOOK_STATE.petUI.detailTopIcon:Hide()
				end
			end
		else
			local fallback = table.concat(topLines, "\n") .. "\n\n" .. table.concat(bottomLines, "\n")
			MTH_BOOK_SetDetailText(detail, fallback)
		end
		MTH_BOOK_UpdateOpenMapButton()
		return
	end

	if MTH_BOOK_STATE.mode == "stable" then
		local petId = MTH_BOOK_STATE.selectedEntry
		local row = petId and MTH_BOOK_GetPetStoreRow(petId)
		if not row then
			MTH_BOOK_SetDetailText(detail, "|cFFFFD100Stable|r\n\nSelect a stable entry to inspect stored pet identity and latest stable scan fields.")
			MTH_BOOK_UpdateOpenMapButton()
			return
		end

		local lines = {}
		table.insert(lines, "|cFFFFFF00" .. tostring(row.name or "Unknown") .. "|r")
		MTH_BOOK_AddDetailSection(lines, "Identity")
		MTH_BOOK_AddDetailKV(lines, "Pet ID", tostring(petId or "-"))
		MTH_BOOK_AddDetailKV(lines, "Family", row.family or "-")
		MTH_BOOK_AddDetailKV(lines, "Level", row.level or "-")
		MTH_BOOK_AddDetailKV(lines, "Beast ID", row.beastId or "-")

		MTH_BOOK_AddDetailSection(lines, "Stable")
		MTH_BOOK_AddDetailKV(lines, "Slot", MTH_BOOK_GetStableDisplaySlot(petId, row) or "-")
		MTH_BOOK_AddDetailKV(lines, "Loyalty", MTH_BOOK_GetLoyaltyNameByLevel(tonumber(row.loyaltyLevel) or (row.stableInfo and tonumber(row.stableInfo.loyaltyLevel)) or nil))
		MTH_BOOK_AddDetailKV(lines, "Happiness", (row.stableInfo and row.stableInfo.happiness) or row.happiness or "-")
		MTH_BOOK_AddDetailKV(lines, "State", row.state or "active")
		MTH_BOOK_AddDetailKV(lines, "Last Seen", row.lastSeen or row.lastUpdated or "-")

		if type(row.tameContext) == "table" then
			MTH_BOOK_AddDetailSection(lines, "Tamed")
			MTH_BOOK_AddDetailKV(lines, "At", row.tameContext.timestamp or "-")
			MTH_BOOK_AddDetailKV(lines, "Zone", row.tameContext.zone or "-")
			MTH_BOOK_AddDetailKV(lines, "Subzone", row.tameContext.subZone or "-")
			MTH_BOOK_AddDetailKV(lines, "Coord", row.tameContext.coordinate or "-")
			MTH_BOOK_AddDetailKV(lines, "Hunter Lvl", row.tameContext.hunterLevel or "-")
		end

		MTH_BOOK_SetDetailText(detail, table.concat(lines, "\n"))
		MTH_BOOK_UpdateOpenMapButton()
		return
	end

	if MTH_BOOK_STATE.mode == "pethistory" then
		local selected = MTH_BOOK_STATE.selectedEntry
		local petId = selected
		if type(selected) == "table" then
			petId = selected.petId or selected.id
		end
		local row = petId and MTH_BOOK_GetPetStoreRow(petId)
		if not row then
			MTH_BOOK_SetDetailText(detail, "|cFFFFD100Pet History|r\n\nSelect a history entry to inspect abandon context and archived pet data.")
			MTH_BOOK_UpdateOpenMapButton()
			return
		end

		local stableInfo = (type(row.stableInfo) == "table") and row.stableInfo or nil
		local stabledAt = tonumber(row.stabledAt) or tonumber(row.stableFirstSeenAt) or (stableInfo and tonumber(stableInfo.stabledAt) or nil)
		local stabledSince = "-"
		local stableElapsedFormatter = _G and _G["MTH_BOOK_FormatElapsedStableInfo"] or nil
		if type(stableElapsedFormatter) == "function" then
			stabledSince = stableElapsedFormatter(stabledAt)
		end
		local stableZone = stableInfo and tostring(stableInfo.stableZone or "") or ""
		local stableSubZone = stableInfo and tostring(stableInfo.stableSubZone or "") or ""
		local stableMasterName = stableInfo and tostring(stableInfo.stableMasterName or "") or ""
		local stableLocation = "-"
		if stableSubZone ~= "" and stableZone ~= "" then
			stableLocation = stableSubZone .. " (" .. stableZone .. ")"
		elseif stableSubZone ~= "" then
			stableLocation = stableSubZone
		elseif stableZone ~= "" then
			stableLocation = stableZone
		end
		if stableMasterName == "" then
			stableMasterName = "-"
		end

		local legacyTameContext = type(row.tameContext) == "table" and row.tameContext or nil
		local hasRecordedTame = row.tameRecorded == true
		if not hasRecordedTame and legacyTameContext then
			if legacyTameContext.name or legacyTameContext.zone or legacyTameContext.timestamp then
				hasRecordedTame = true
			end
		end
		local tamedAt = hasRecordedTame and (tonumber(row.tamedAt) or (legacyTameContext and tonumber(legacyTameContext.timestamp) or nil)) or nil
		local tameZone = hasRecordedTame and tostring(row.tameZone or (legacyTameContext and legacyTameContext.zone) or "-") or "-"
		local tameX = hasRecordedTame and (tonumber(row.tameX) or (legacyTameContext and tonumber(legacyTameContext.x) or nil)) or nil
		local tameY = hasRecordedTame and (tonumber(row.tameY) or (legacyTameContext and tonumber(legacyTameContext.y) or nil)) or nil
		local tameCoords = "-"
		if tameX and tameY then
			tameCoords = string.format("%.1f, %.1f", tameX, tameY)
		end
		local tameBeastId = hasRecordedTame and (tonumber(row.tameBeastId) or (legacyTameContext and tonumber(legacyTameContext.beastId) or nil)) or nil
		local tameBeast = tameBeastId and MTH_DS_Beasts and MTH_DS_Beasts[tameBeastId] or nil
		local tameBeastName = tostring(((MTH and MTH.GetLocalizedBeastName and tameBeastId and tameBeast and MTH:GetLocalizedBeastName(tameBeastId, tameBeast.name)) or (tameBeast and tameBeast.name)) or (legacyTameContext and legacyTameContext.name) or "-")

		local lines = {}
		table.insert(lines, "|cFFFFFF00" .. tostring(row.name or "Unknown") .. "|r")

		MTH_BOOK_AddDetailSection(lines, "Identity")
		MTH_BOOK_AddStableStyleKV(lines, "Pet ID", tostring(petId or "-"))
		MTH_BOOK_AddStableStyleKV(lines, "Name", row.name or "-")
		MTH_BOOK_AddStableStyleKV(lines, "Family", row.family or "-")
		MTH_BOOK_AddStableStyleKV(lines, "Level", row.level or "-")
		MTH_BOOK_AddStableStyleKV(lines, "Loyalty", MTH_BOOK_GetLoyaltyNameByLevel(tonumber(row.loyaltyLevel) or (stableInfo and tonumber(stableInfo.loyaltyLevel)) or nil))

		MTH_BOOK_AddDetailSection(lines, "Stable info")
		MTH_BOOK_AddStableStyleKV(lines, "Stabled on", MTH_BOOK_FormatDateTimeValue(stabledAt))
		MTH_BOOK_AddStableStyleKV(lines, "Stabled since", stabledSince)
		MTH_BOOK_AddStableStyleKV(lines, "Stable Master", stableMasterName)
		MTH_BOOK_AddStableStyleKV(lines, "Location", stableLocation)

		MTH_BOOK_AddDetailSection(lines, "Taming info")
		if hasRecordedTame then
			MTH_BOOK_AddStableStyleKV(lines, "Tamed on", MTH_BOOK_FormatDateTimeValue(tamedAt))
			MTH_BOOK_AddStableStyleKV(lines, "Tamed Beast", tameBeastName)
			MTH_BOOK_AddStableStyleKV(lines, "Taming Loc", tameZone)
			MTH_BOOK_AddStableStyleKV(lines, "Coords", tameCoords)
		else
			table.insert(lines, "|cffb0b0b0No info|r")
		end

		MTH_BOOK_AddDetailSection(lines, "Row info")
		MTH_BOOK_AddStableStyleKV(lines, "ID", tostring(petId or "-"))
		MTH_BOOK_AddStableStyleKV(lines, "Created", MTH_BOOK_FormatDateTimeValue(row.createdAt))
		MTH_BOOK_AddStableStyleKV(lines, "Origin", row.origin or row.lastSource or "-")
		MTH_BOOK_AddStableStyleKV(lines, "Updated", MTH_BOOK_FormatDateTimeValue(row.lastUpdated or row.updatedAt or row.lastSeen))
		MTH_BOOK_AddStableStyleKV(lines, "Lost Date/Time", MTH_BOOK_FormatDateTimeValue(row.abandonedAt))
		MTH_BOOK_AddStableStyleKV(lines, "Lost Cause", MTH_BOOK_GetPetHistoryLostCause(row))

		MTH_BOOK_SetDetailText(detail, table.concat(lines, "\n"))
		MTH_BOOK_UpdateOpenMapButton()
		return
	end

	local selected = MTH_BOOK_STATE.selectedEntry
	if not selected or not selected.itemId then
		MTH_BOOK_SetDetailText(detail, "|cFFFFD100Inspector|r\n\nSelect an entry from the list to view identity, stats, sources and locations.")
		MTH_BOOK_UpdateOpenMapButton()
		return
	end
	local itemId = selected.itemId
	local items = MTH_BOOK_GetItemsTable()
	local item = items and items[itemId]
	if not item then
		MTH_BOOK_SetDetailText(detail, "|cFFFFD100Inspector|r\n\nSelect an entry from the list to view identity, stats, sources and locations.")
		MTH_BOOK_UpdateOpenMapButton()
		return
	end

	local sourceInfo = MTH_BOOK_GetItemSourceInfo(item)
	local lines = {}
	local localizedItemName = (MTH and MTH.GetLocalizedItemName)
		and MTH:GetLocalizedItemName(itemId, item.name)
		or item.name
	table.insert(lines, "|cFFFFFF00" .. (localizedItemName or "Unknown") .. "|r")

	MTH_BOOK_AddDetailSection(lines, "Identity")
	MTH_BOOK_AddDetailKV(lines, "ID", itemId)
	MTH_BOOK_AddDetailKV(lines, "Subtype", item.subtype or "?")

	MTH_BOOK_AddDetailSection(lines, "Stats")
	MTH_BOOK_AddDetailKV(lines, "Level", item.level or "?")
	MTH_BOOK_AddDetailKV(lines, "Req Level", item.reqlevel or "-")
	if item.slots then MTH_BOOK_AddDetailKV(lines, "Slots", item.slots) end
	if item.quality then MTH_BOOK_AddDetailKV(lines, "Quality", item.quality) end
	if item.dps then MTH_BOOK_AddDetailKV(lines, "DPS", item.dps) end
	if item.speed then MTH_BOOK_AddDetailKV(lines, "Speed", item.speed) end
	if item.sourceUrl and item.sourceUrl ~= "" then MTH_BOOK_AddDetailKV(lines, "DB URL", item.sourceUrl) end

	MTH_BOOK_AddDetailSection(lines, "Sources")
	if table.getn(sourceInfo.sourceTypes) == 0 then
		MTH_BOOK_AddDetailKV(lines, "Source", "-")
	elseif table.getn(sourceInfo.sourceTypes) == 1 then
		MTH_BOOK_AddDetailKV(lines, "Source", sourceInfo.sourceTypes[1])
	else
		for i = 1, table.getn(sourceInfo.sourceTypes) do
			MTH_BOOK_AddDetailKV(lines, "Source " .. tostring(i), sourceInfo.sourceTypes[i])
		end
	end
	MTH_BOOK_SetDetailText(detail, table.concat(lines, "\n"))
	MTH_BOOK_UpdateOpenMapButton()
end

local function MTH_BOOK_UpdateHeader()
	local stats = getglobal("MTH_BOOK_StatsText")
	if not stats then return end
	local mode = MTH_BOOK_STATE.mode or "pets"
	local tabDef = MTH_BOOK_GetTabDefinition(mode)
	local modeLabel = (tabDef and tabDef.headerLabel) or "Beasts"
	if not tabDef then
		if mode == "families" then modeLabel = "Families" end
		if mode == "petabilities" then modeLabel = "Pet Abilities" end
		if mode == "items" then modeLabel = "Ranged Weapons" end
		if mode == "projectiles" then modeLabel = "Projectiles" end
		if mode == "ammobags" then modeLabel = "Ammo Bags" end
		if mode == "npcs" then modeLabel = "NPC Finder" end
		if mode == "stable" then modeLabel = "Stable" end
		if mode == "pethistory" then modeLabel = "Pet History" end
	end
	local total = MTH_BOOK_GetTotalCount()
	local filtered = table.getn(MTH_BOOK_STATE.results)
	local pages = math.max(1, math.ceil(filtered / MTH_BOOK_STATE.pageSize))
	if mode == "families" then
		local namedTotal = 0
		local coordsTotal = 0
		for i = 1, table.getn(MTH_BOOK_STATE.results or {}) do
			local row = MTH_BOOK_STATE.results[i]
			if type(row) == "table" then
				namedTotal = namedTotal + (tonumber(row.named) or 0)
				coordsTotal = coordsTotal + (tonumber(row.coords) or 0)
			end
		end
		stats:SetText("Named: " .. tostring(namedTotal) .. " | Coords: " .. tostring(coordsTotal))
		return
	end
	stats:SetText(modeLabel .. ": " .. total .. " | Filtered: " .. filtered .. " | Page " .. MTH_BOOK_STATE.page .. "/" .. pages)
end

local function MTH_BOOK_GetColumnLabels()
	local tabDef = MTH_BOOK_GetTabDefinition(MTH_BOOK_STATE.mode)
	if tabDef and type(tabDef.columnLabels) == "table" then
		return tabDef.columnLabels
	end
	if MTH_BOOK_STATE.mode == "pets" then
		return { "ID", "Lvl", "Family", "Name", "Abilities", "Zone", "R", "E", "U" }
	elseif MTH_BOOK_STATE.mode == "petabilities" then
		return { "Ability Name", "Ranks", "Families" }
	elseif MTH_BOOK_STATE.mode == "stable" then
		return { "Pet ID", "Slot", "Name", "Family", "Lvl", "Loyalty", "Seen" }
	elseif MTH_BOOK_STATE.mode == "pethistory" then
		return { "Pet ID", "Name", "Family", "Lvl", "Lost Date/Time", "Lost Cause" }
	elseif MTH_BOOK_STATE.mode == "abilities" then
		return { "Ability", "Lvl", "Family", "Beast", "Rare" }
	elseif MTH_BOOK_STATE.mode == "npcs" then
		return { "ID", "Name", "React", "Function", "Zone" }
	elseif MTH_BOOK_STATE.mode == "projectiles" then
		return { "ID", "Req", "Lvl", "Type", "Name", "DPS", "Source" }
	end
	return { "ID", "Req", "Lvl", "Type", "Name", "DPS", "Speed", "Source" }
end

local function MTH_BOOK_GetColumnLayout()
	local tabDef = MTH_BOOK_GetTabDefinition(MTH_BOOK_STATE.mode)
	if tabDef and type(tabDef.columnLayout) == "table" then
		return tabDef.columnLayout
	end
	if MTH_BOOK_STATE.mode == "pets" then
		return {
			{ x = 8, width = 28, align = "LEFT" },
			{ x = 38, width = 30, align = "LEFT" },
			{ x = 68, width = 74, align = "LEFT" },
			{ x = 142, width = 130, align = "LEFT" },
			{ x = 272, width = 180, align = "LEFT" },
			{ x = 452, width = 68, align = "LEFT" },
			{ x = 520, width = 10, align = "CENTER" },
			{ x = 532, width = 10, align = "CENTER" },
			{ x = 544, width = 10, align = "CENTER" },
		}
	elseif MTH_BOOK_STATE.mode == "petabilities" then
		return {
			{ x = 8, width = 160, align = "LEFT" },
			{ x = 170, width = 52, align = "LEFT" },
			{ x = 224, width = 328, align = "LEFT" },
		}
	elseif MTH_BOOK_STATE.mode == "stable" then
		return {
			{ x = 8, width = 78, align = "LEFT" },
			{ x = 88, width = 34, align = "LEFT" },
			{ x = 124, width = 118, align = "LEFT" },
			{ x = 244, width = 92, align = "LEFT" },
			{ x = 338, width = 34, align = "LEFT" },
			{ x = 374, width = 114, align = "LEFT" },
			{ x = 490, width = 52, align = "LEFT" },
		}
	elseif MTH_BOOK_STATE.mode == "pethistory" then
		return {
			{ x = 8, width = 66, align = "LEFT" },
			{ x = 76, width = 104, align = "LEFT" },
			{ x = 182, width = 84, align = "LEFT" },
			{ x = 268, width = 30, align = "LEFT" },
			{ x = 300, width = 128, align = "LEFT" },
			{ x = 430, width = 78, align = "LEFT" },
		}
	elseif MTH_BOOK_STATE.mode == "abilities" then
		return {
			{ x = 8, width = 112, align = "LEFT" },
			{ x = 120, width = 40, align = "LEFT" },
			{ x = 160, width = 78, align = "LEFT" },
			{ x = 238, width = 142, align = "LEFT" },
			{ x = 380, width = 38, align = "LEFT" },
		}
	elseif MTH_BOOK_STATE.mode == "npcs" then
		return {
			{ x = 8, width = 52, align = "LEFT" },
			{ x = 60, width = 140, align = "LEFT" },
			{ x = 200, width = 40, align = "LEFT" },
			{ x = 242, width = 160, align = "LEFT" },
			{ x = 404, width = 148, align = "LEFT" },
		}
	elseif MTH_BOOK_STATE.mode == "projectiles" then
		return {
			{ x = 8, width = 36, align = "LEFT" },
			{ x = 44, width = 30, align = "LEFT" },
			{ x = 74, width = 30, align = "LEFT" },
			{ x = 104, width = 62, align = "LEFT" },
			{ x = 166, width = 228, align = "LEFT" },
			{ x = 396, width = 44, align = "LEFT" },
			{ x = 442, width = 110, align = "LEFT" },
		}
	end

	return {
		{ x = 8, width = 36, align = "LEFT" },
		{ x = 44, width = 30, align = "LEFT" },
		{ x = 74, width = 30, align = "LEFT" },
		{ x = 104, width = 62, align = "LEFT" },
		{ x = 166, width = 188, align = "LEFT" },
		{ x = 356, width = 44, align = "LEFT" },
		{ x = 402, width = 40, align = "LEFT" },
		{ x = 444, width = 108, align = "LEFT" },
	}
end

local function MTH_BOOK_ApplyColumnLayout(parent)
	if not parent then return end
	local layout = MTH_BOOK_GetColumnLayout()

	for i = 1, MTH_BOOK_MAX_COLS do
		local header = MTH_BOOK_STATE.headerCols[i]
		local hit = MTH_BOOK_STATE.headerButtons[i]
		local info = layout[i]
		if header then
			if info then
				header:Show()
				header:ClearAllPoints()
				header:SetPoint("TOPLEFT", parent, "TOPLEFT", info.x, -8)
				header:SetWidth(info.width)
				header:SetJustifyH(info.align or "LEFT")
				if hit then
					hit:Show()
					hit:ClearAllPoints()
					hit:SetPoint("TOPLEFT", parent, "TOPLEFT", info.x, -8)
					hit:SetWidth(info.width)
					hit:SetHeight(14)
				end
			else
				header:Hide()
				header:SetText("")
				if hit then hit:Hide() end
			end
		end
	end

	for row = 1, MTH_BOOK_STATE.pageSize do
		local btn = MTH_BOOK_STATE.buttons[row]
		if btn and btn.cols then
			local itemNameColumn = (MTH_BOOK_STATE.mode == "ammobags") and 6 or 5
			local itemNameLayout = layout[itemNameColumn]
			local parentWidth = tonumber(parent:GetWidth()) or 0
			local rowWidth = parentWidth - 8
			if rowWidth < 220 then rowWidth = 220 end
			btn:SetWidth(rowWidth)

			for i = 1, MTH_BOOK_MAX_COLS do
				local col = btn.cols[i]
				local info = layout[i]
				if col then
					if info then
						col:Show()
						col:ClearAllPoints()
						col:SetPoint("LEFT", btn, "LEFT", info.x - 4, 0)
						col:SetWidth(info.width)
						col:SetJustifyH(info.align or "LEFT")
					else
						col:Hide()
						col:SetText("")
					end
				end
			end

			if btn.bookLinkButton then
				local info = layout[1]
				if (MTH_BOOK_STATE.mode == "pets" or MTH_BOOK_STATE.mode == "npcs" or MTH_BOOK_IsItemMode()) and info then
					btn.bookLinkButton:ClearAllPoints()
					btn.bookLinkButton:SetPoint("LEFT", btn, "LEFT", info.x - 4, 0)
					btn.bookLinkButton:SetWidth(info.width)
					btn.bookLinkButton:SetHeight(btn:GetHeight())
					btn.bookLinkButton:Show()
				else
					btn.bookLinkButton:Hide()
				end
			end

			if btn.itemLinkButton then btn.itemLinkButton:Hide() end

			if btn.nameHoverButton then
				if MTH_BOOK_IsItemMode() and itemNameLayout then
					btn.nameHoverButton:ClearAllPoints()
					btn.nameHoverButton:SetPoint("LEFT", btn, "LEFT", itemNameLayout.x + 12, 0)
					btn.nameHoverButton:SetWidth(itemNameLayout.width - 16)
					btn.nameHoverButton:SetHeight(btn:GetHeight())
					btn.nameHoverButton:Show()
				else
					btn.nameHoverButton:Hide()
				end
			end

			if btn.itemIcon then
				if MTH_BOOK_IsItemMode() and itemNameLayout then
					btn.itemIcon:ClearAllPoints()
					btn.itemIcon:SetPoint("LEFT", btn, "LEFT", itemNameLayout.x - 4, 0)
					btn.itemIcon:Show()
					if btn.cols and btn.cols[itemNameColumn] then
						btn.cols[itemNameColumn]:ClearAllPoints()
						btn.cols[itemNameColumn]:SetPoint("LEFT", btn, "LEFT", itemNameLayout.x + 12, 0)
						btn.cols[itemNameColumn]:SetWidth(itemNameLayout.width - 16)
					end
				else
					btn.itemIcon:Hide()
				end
			end
		end
	end
end

local function MTH_BOOK_GetRowValues(entry)
	if MTH_BOOK_STATE.mode == "pets" then
		local beast = MTH_DS_Beasts and MTH_DS_Beasts[entry]
		if not beast then return { "", "", "", "", "", "", "", "", "" } end
		local beastDisplayName = (MTH and MTH.GetLocalizedBeastName and MTH:GetLocalizedBeastName(entry, beast.name)) or beast.name
		local traits = MTH_BOOK_ParseBeastTraits(beast)
		local abilities = MTH_BOOK_GetBeastAbilitiesSummary(beast)
		local zone = MTH_BOOK_GetBeastZoneSummary(beast)
		return {
			"|cFF33CCFF" .. tostring(entry) .. "|r",
			tostring(beast.lvl or "?"),
			tostring(beast.family or "?"),
			tostring(beastDisplayName or "Unknown"),
			abilities,
			zone,
			(traits.rare and "R" or ""),
			(traits.elite and "E" or ""),
			(traits.unique and "U" or ""),
		}
	end

	if MTH_BOOK_STATE.mode == "abilities" then
		return {
			tostring(entry.abilityToken or "?"),
			tostring(entry.level or 0),
			tostring(entry.family or "?"),
			tostring(entry.name or "Unknown"),
			(entry.rare and "R" or ""),
		}
	end

	if MTH_BOOK_STATE.mode == "petabilities" then
		local families = entry.familyList or ""
		if families == "" then families = "-" end
		return {
			tostring(entry.ability or "Unknown"),
			tostring(entry.rankText or ""),
			families,
		}
	end

	if MTH_BOOK_STATE.mode == "families" then
		local names = {}
		if type(entry.abilities) == "table" then
			for i = 1, table.getn(entry.abilities) do
				local ability = entry.abilities[i]
				if type(ability) == "table" and ability.name and ability.name ~= "" then
					table.insert(names, tostring(ability.name))
				end
			end
		end
		local abilitiesText = table.concat(names, ", ")
		if abilitiesText == "" then abilitiesText = "-" end
		local dietText = tostring(entry.dietText or "")
		if dietText == "" then dietText = "-" end
		return {
			tostring(entry.family or "-"),
			tostring(entry.named or 0),
			tostring(entry.coords or 0),
			abilitiesText,
			dietText,
		}
	end

	if MTH_BOOK_STATE.mode == "stable" then
		local row = MTH_BOOK_GetPetStoreRow(entry)
		if not row then return { "", "", "", "", "", "", "" } end
		local slotDisplay = MTH_BOOK_GetStableDisplaySlot(entry, row) or "-"
		local loyalty = MTH_BOOK_GetLoyaltyNameByLevel(tonumber(row.loyaltyLevel) or (row.stableInfo and tonumber(row.stableInfo.loyaltyLevel)) or nil)
		return {
			tostring(entry or ""),
			tostring(slotDisplay),
			tostring(row.name or "-"),
			tostring(row.family or "-"),
			tostring(row.level or "-"),
			tostring(loyalty),
			tostring(row.lastSeen or row.lastUpdated or 0),
		}
	end

	if MTH_BOOK_STATE.mode == "pethistory" then
		local row = MTH_BOOK_GetPetStoreRow(entry)
		if not row then return { "", "", "", "", "", "" } end
		local lostCause = MTH_BOOK_GetPetHistoryLostCause(row)
		return {
			tostring(entry or ""),
			tostring(row.name or "-"),
			tostring(row.family or "-"),
			tostring(row.level or "-"),
			MTH_BOOK_FormatDateTimeValue(row.abandonedAt),
			tostring(lostCause),
		}
	end

	if MTH_BOOK_STATE.mode == "npcs" then
		local vendor = MTH_DS_Vendors and MTH_DS_Vendors[entry]
		if not vendor then return { "", "", "", "", "" } end
		local react = MTH_BOOK_GetNPCReactBucket(vendor.fac)
		local functionSummary = MTH_BOOK_GetNPCFunctionSummary(vendor)
		local zoneName = MTH_BOOK_GetNPCZoneSummary(vendor)
		local vendorName = (MTH and MTH.GetLocalizedNPCNameById and MTH:GetLocalizedNPCNameById(entry, vendor.name)) or vendor.name
		return {
			"|cFF33CCFF" .. tostring(entry) .. "|r",
			tostring(vendorName or "Unknown"),
			react,
			functionSummary,
			zoneName,
		}
	end

	local items = MTH_BOOK_GetItemsTable()
	local item = items and items[entry]
	if not item then
		if MTH_BOOK_STATE.mode == "projectiles" or MTH_BOOK_STATE.mode == "ammobags" then
			return { "", "", "", "", "", "", "" }
		end
		return { "", "", "", "", "", "", "", "" }
	end
	local itemName = tostring(((MTH and MTH.GetLocalizedItemName)
		and MTH:GetLocalizedItemName(entry, item.name)
		or item.name) or "Unknown")
	local resolvedQuality = item.quality
	if not resolvedQuality and MTH_BOOK_STATE.mode == "projectiles" and MTH_DS_ItemOrigins and MTH_DS_ItemOrigins[entry] then
		resolvedQuality = MTH_DS_ItemOrigins[entry].quality
	end
	if not resolvedQuality and type(GetItemInfo) == "function" then
		local _, _, runtimeQuality = GetItemInfo(entry)
		if runtimeQuality ~= nil then
			resolvedQuality = runtimeQuality
			item.quality = runtimeQuality
		end
	end
	local colorCode = MTH_BOOK_GetItemQualityColorCode(resolvedQuality)
	if MTH_BOOK_STATE.mode == "items" then
		colorCode = MTH_BOOK_GetWeaponLegacyQualityColorCode(resolvedQuality)
	end
	local sourceInfo = MTH_BOOK_GetItemSourceInfo(item)
	local sourceText = sourceInfo.primary
	if MTH_BOOK_STATE.mode == "ammobags" then
		return {
			"|cFF33CCFF" .. tostring(entry) .. "|r",
			tostring(item.reqlevel or 0),
			tostring(item.level or 0),
			tostring(item.slots or "-"),
			tostring(item.subtype or "?"),
			"|c" .. colorCode .. itemName .. "|r",
			sourceText,
		}
	end
	if MTH_BOOK_STATE.mode == "projectiles" then
		local projectileDps = MTH_BOOK_GetProjectileDPSValue(item)
		return {
			"|cFF33CCFF" .. tostring(entry) .. "|r",
			tostring(item.reqlevel or 0),
			tostring(item.level or 0),
			tostring(item.subtype or "?"),
			"|c" .. colorCode .. itemName .. "|r",
			(projectileDps and tostring(projectileDps) or "-"),
			sourceText,
		}
	end
	return {
		"|cFF33CCFF" .. tostring(entry) .. "|r",
		tostring(item.reqlevel or 0),
		tostring(item.level or 0),
		tostring(item.subtype or "?"),
		"|c" .. colorCode .. itemName .. "|r",
		(item.dps and tostring(item.dps) or "-"),
		(item.speed and tostring(item.speed) or "-"),
		sourceText,
	}
end

local function MTH_BOOK_EnsurePetAbilitiesUI(listParent, detailParent)
	if type(MTH_BOOKTAB_EnsurePetAbilitiesUI) == "function" then
		return MTH_BOOKTAB_EnsurePetAbilitiesUI(listParent, detailParent)
	end
end

local function MTH_BOOK_SetPetAbilitiesUIVisible(visible)
	if type(MTH_BOOKTAB_SetPetAbilitiesUIVisible) == "function" then
		return MTH_BOOKTAB_SetPetAbilitiesUIVisible(visible)
	end
end

local function MTH_BOOK_SetFamiliesUIVisible(visible)
	if type(MTH_BOOKTAB_SetFamiliesUIVisible) == "function" then
		return MTH_BOOKTAB_SetFamiliesUIVisible(visible)
	end
	MTH_BOOK_FamiliesTrace("SetFamiliesUIVisible missing MTH_BOOKTAB_SetFamiliesUIVisible")
end

function MTH_BOOK_EnsureStableUI()
	if type(MTH_BOOKTAB_EnsureStableUI) == "function" then
		return MTH_BOOKTAB_EnsureStableUI()
	end
end

function MTH_BOOK_SetStableUIVisible(visible)
	if type(MTH_BOOKTAB_SetStableUIVisible) == "function" then
		return MTH_BOOKTAB_SetStableUIVisible(visible)
	end
end

function MTH_BOOK_RenderStableCards()
	if type(MTH_BOOKTAB_RenderStableCards) == "function" then
		return MTH_BOOKTAB_RenderStableCards()
	end
end

MTH_BOOK_UpdatePetAbilitiesLists = function()
	if type(MTH_BOOKTAB_UpdatePetAbilitiesLists) == "function" then
		return MTH_BOOKTAB_UpdatePetAbilitiesLists()
	end
end
_G.MTH_BOOK_UpdatePetAbilitiesLists = MTH_BOOK_UpdatePetAbilitiesLists

local function MTH_BOOK_UpdateListHeaders()
	if MTH_BOOK_STATE.mode == "petabilities" or MTH_BOOK_STATE.mode == "stable" then
		for i = 1, MTH_BOOK_MAX_COLS do
			local header = MTH_BOOK_STATE.headerCols[i]
			local hit = MTH_BOOK_STATE.headerButtons[i]
			if header then header:SetText(""); header:Hide() end
			if hit then hit:Hide() end
		end
		return
	end

	local labels = MTH_BOOK_GetColumnLabels()
	local state = MTH_BOOK_GetSortState()
	for i = 1, MTH_BOOK_MAX_COLS do
		local header = MTH_BOOK_STATE.headerCols[i]
		local hit = MTH_BOOK_STATE.headerButtons[i]
		if header then
			local label = labels[i] or ""
			if label ~= "" and state and state.col == i then
				label = label .. (state.asc and " ^" or " v")
			end
			header:SetText(label)
			if hit then
				hit:EnableMouse(labels[i] and labels[i] ~= "")
			end
		end
	end
	local listParent = getglobal("MTH_BOOK_ListBackdrop")
	if listParent then
		MTH_BOOK_ApplyColumnLayout(listParent)
	end
end

local function MTH_BOOK_OnHeaderClick(col)
	local labels = MTH_BOOK_GetColumnLabels()
	if not labels[col] or labels[col] == "" then return end
	local state = MTH_BOOK_GetSortState()
	if state.col == col then
		state.asc = not state.asc
	else
		state.col = col
		state.asc = true
	end
	MTH_BOOK_STATE.page = 1
	MTH_BOOK_STATE.selectedEntry = nil
	MTH_BOOK_STATE.selectedPetRankEntry = nil
	MTH_BOOK_STATE.petRankRows = {}
	MTH_BOOK_STATE.forcedBeastId = nil
	MTH_BOOK_RefreshFilter()
end

local function MTH_BOOK_AssignEntry(btn, entry)
	btn.entry = nil
	if MTH_BOOK_STATE.mode == "pets" then
		btn.entry = { beastId = entry }
	elseif MTH_BOOK_STATE.mode == "families" then
		btn.entry = entry
	elseif MTH_BOOK_STATE.mode == "npcs" then
		btn.entry = { npcId = entry }
	elseif MTH_BOOK_STATE.mode == "abilities" then
		btn.entry = entry
	elseif MTH_BOOK_STATE.mode == "petabilities" then
		btn.entry = entry
	elseif MTH_BOOK_STATE.mode == "pethistory" then
		btn.entry = { petId = entry }
	else
		btn.entry = { itemId = entry }
	end
end

MTH_BOOK_UpdateResults = function()
	MTH_BOOK_SetFamiliesListVisualScale(MTH_BOOK_STATE.mode == "families")

	local resultCount = table.getn(MTH_BOOK_STATE.results)
	local totalPages = math.max(1, math.ceil(resultCount / MTH_BOOK_STATE.pageSize))
	local buttonCount = table.getn(MTH_BOOK_STATE.buttons)
	if MTH_BOOK_STATE.page < 1 then MTH_BOOK_STATE.page = 1 end
	if MTH_BOOK_STATE.page > totalPages then MTH_BOOK_STATE.page = totalPages end

	local slider = getglobal("MTH_BOOK_ListSlider")
	local sliderBackdrop = getglobal("MTH_BOOK_ListSliderBackdrop")

	if MTH_BOOK_STATE.mode == "stable" then
		MTH_BOOK_DebugTrace("UpdateResults stable: resultCount=" .. tostring(resultCount))
		if slider then slider:Hide() end
		MTH_BOOK_SetPetAbilitiesUIVisible(false)
		MTH_BOOK_SetFamiliesUIVisible(false)
		MTH_BOOK_EnsureStableUI()
		if not MTH_BOOK_STATE.stableUI then
			MTH_BOOK_DebugTrace("UpdateResults stable: custom UI unavailable, fallback to list")
			MTH_BOOK_SetStableUIVisible(false)
		else
			MTH_BOOK_DebugTrace("UpdateResults stable: custom UI active")
			MTH_BOOK_SetStableUIVisible(true)
		end

		for i = 1, buttonCount do
			local btn = MTH_BOOK_STATE.buttons[i]
			if btn then
				if MTH_BOOK_STATE.stableUI then
					btn:Hide()
				else
					btn:Show()
				end
			end
		end

		if MTH_BOOK_STATE.stableUI then
			MTH_BOOK_RenderStableCards()
			local stableFrame = MTH_BOOK_STATE.stableUI.frame
			if stableFrame and stableFrame.SetScript then
				stableFrame:SetScript("OnUpdate", function()
					stableFrame:SetScript("OnUpdate", nil)
					if MTH_BOOK_STATE.mode == "stable" and MTH_BOOK_STATE.stableUI then
						MTH_BOOK_RenderStableCards()
					end
				end)
			end
		end
		MTH_BOOK_UpdateHeader()
		if not MTH_BOOK_STATE.stableUI then
			MTH_BOOK_SetStableUIVisible(false)
			MTH_BOOK_SetPetAbilitiesUIVisible(false)
			-- continue with generic list rendering
		else
			return
		end
	end

	if MTH_BOOK_STATE.mode == "petabilities" then
		if slider then slider:Hide() end
		local listParent = getglobal("MTH_BOOK_ListBackdrop")
		local detailParent = getglobal("MTH_BOOK_DetailBackdrop")
		MTH_BOOK_SetStableUIVisible(false)
		MTH_BOOK_EnsurePetAbilitiesUI(listParent, detailParent)
		MTH_BOOK_SetPetAbilitiesUIVisible(true)
		MTH_BOOK_SetFamiliesUIVisible(false)

		for i = 1, buttonCount do
			local btn = MTH_BOOK_STATE.buttons[i]
			if btn then btn:Hide() end
		end

		MTH_BOOK_UpdatePetAbilitiesLists()
		MTH_BOOK_UpdateHeader()
		MTH_BOOK_UpdateDetail()
		return
	end

	if MTH_BOOK_STATE.mode == "families" then
		MTH_BOOK_FamiliesTrace("UpdateResults families using safe generic renderer")
		MTH_BOOK_STATE.page = 1
		if sliderBackdrop then sliderBackdrop:Hide() end
	end

	if slider then
		if MTH_BOOK_STATE.mode == "families" then
			slider:Hide()
		else
			if sliderBackdrop then sliderBackdrop:Show() end
			slider:Show()
			slider:SetMinMaxValues(1, totalPages)
			slider:SetValueStep(1)
			slider:SetValue(MTH_BOOK_STATE.page)
			MTH_BOOK_HideSliderTemplateTexts()
			MTH_BOOK_UpdateSliderMarker(slider)
		end
	end

	MTH_BOOK_SetPetAbilitiesUIVisible(false)
	MTH_BOOK_SetStableUIVisible(false)
	MTH_BOOK_SetFamiliesUIVisible(false)

	local startIndex = ((MTH_BOOK_STATE.page - 1) * MTH_BOOK_STATE.pageSize) + 1
	for i = 1, buttonCount do
		local btn = MTH_BOOK_STATE.buttons[i]
		if btn then
			local entry = nil
			if i <= MTH_BOOK_STATE.pageSize then
				local rowIndex = startIndex + i - 1
				entry = MTH_BOOK_STATE.results[rowIndex]
			end
			if entry then
				MTH_BOOK_AssignEntry(btn, entry)
				local values = MTH_BOOK_GetRowValues(entry)
				for c = 1, MTH_BOOK_MAX_COLS do
					if btn.cols and btn.cols[c] then
						btn.cols[c]:SetText(values[c] or "")
					end
				end
				if btn.itemIcon then
					if MTH_BOOK_IsItemMode() then
						local items = MTH_BOOK_GetItemsTable()
						local item = items and items[entry]
						if item and item.icon and item.icon ~= "" then
							if string.find(tostring(item.icon), "\\", 1, true) then
								btn.itemIcon:SetTexture(tostring(item.icon))
							else
								btn.itemIcon:SetTexture("Interface\\Icons\\" .. tostring(item.icon))
							end
							btn.itemIcon:Show()
						else
							btn.itemIcon:SetTexture(nil)
							btn.itemIcon:Hide()
						end
					else
						btn.itemIcon:SetTexture(nil)
						btn.itemIcon:Hide()
					end
				end
				if btn.familyAbilityButtons then
					local abilityEntries = nil
					local abilityColIndex = nil
					local tooltipFunc = nil
					if MTH_BOOK_STATE.mode == "families" and type(entry) == "table" and type(entry.abilities) == "table" then
						abilityEntries = entry.abilities
						abilityColIndex = 4
						tooltipFunc = MTH_BOOKTAB_ShowFamilyAbilityTooltip
					elseif MTH_BOOK_STATE.mode == "pets" then
						local beast = MTH_DS_Beasts and MTH_DS_Beasts[entry]
						if beast and type(MTH_BOOKTAB_BuildBeastAbilityEntries) == "function" then
							abilityEntries = MTH_BOOKTAB_BuildBeastAbilityEntries(beast)
							abilityColIndex = 5
							tooltipFunc = MTH_BOOKTAB_ShowBeastAbilityTooltip
						end
					end

					if type(abilityEntries) == "table" and table.getn(abilityEntries) > 0 then
						if btn.cols and btn.cols[abilityColIndex] then btn.cols[abilityColIndex]:SetText("") end
						local layout = MTH_BOOK_GetColumnLayout()
						local col = layout and layout[abilityColIndex]
						local startX = ((col and col.x) or 232) - 4
						local maxWidth = (col and col.width) or 292
						local usedWidth = 0
						local abilitiesCount = table.getn(abilityEntries)
						for chipIndex = 1, table.getn(btn.familyAbilityButtons) do
							local chip = btn.familyAbilityButtons[chipIndex]
							local ability = abilityEntries[chipIndex]
							if chip and ability and type(ability) == "table" and ability.name and ability.name ~= "" then
								local label = tostring(ability.name)
								if chipIndex < abilitiesCount then
									label = label .. ","
								end
								chip.text:SetText(label)
								local textWidth = chip.text:GetStringWidth() or 24
								if textWidth < 16 then textWidth = 16 end
								local chipWidth = ((MTH_BOOK_STATE.mode == "families") and 15 or 14) + textWidth
								if usedWidth + chipWidth > maxWidth then
									chip:Hide()
								else
									chip:ClearAllPoints()
									chip:SetPoint("LEFT", btn, "LEFT", startX + usedWidth, 0)
									chip:SetWidth(chipWidth)
									chip.abilityEntry = ability
									chip.abilityTooltipFunc = tooltipFunc
									local iconPath = MTH_BOOK_ResolveIconPath(ability.icon)
									if iconPath then
										chip.icon:SetTexture(iconPath)
									else
										chip.icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
									end
									chip:Show()
									usedWidth = usedWidth + chipWidth + 4
								end
							else
								if chip then
									chip.abilityEntry = nil
									chip.abilityTooltipFunc = nil
									chip:Hide()
								end
							end
						end
					else
						for chipIndex = 1, table.getn(btn.familyAbilityButtons) do
							local chip = btn.familyAbilityButtons[chipIndex]
							if chip then
								chip.abilityEntry = nil
								chip.abilityTooltipFunc = nil
								chip:Hide()
							end
						end
					end
				end
				btn:Show()
			else
				btn.entry = nil
				for c = 1, MTH_BOOK_MAX_COLS do
					if btn.cols and btn.cols[c] then
						btn.cols[c]:SetText("")
					end
				end
				if btn.itemIcon then
					btn.itemIcon:SetTexture(nil)
					btn.itemIcon:Hide()
				end
				if btn.familyAbilityButtons then
					for chipIndex = 1, table.getn(btn.familyAbilityButtons) do
						local chip = btn.familyAbilityButtons[chipIndex]
						if chip then
							chip.abilityEntry = nil
							chip.abilityTooltipFunc = nil
							chip:Hide()
						end
					end
				end
				btn:Hide()
			end
		end
	end

	MTH_BOOK_UpdateHeader()
	MTH_BOOK_UpdateDetail()
end

MTH_BOOK_RefreshFilter = function()
	MTH_BOOK_UpdateQuickFilterControls()
	MTH_BOOK_UpdateListHeaders()
	if MTH_BOOK_STATE.mode == "stable" and type(MTH_PETS_RefreshCurrentPet) == "function" then
		MTH_PETS_RefreshCurrentPet()
	end
	MTH_BOOK_STATE.results = MTH_BOOK_BuildResults()
	MTH_BOOK_UpdateResults()
end

local function MTH_BOOK_UpdateModeLabels()
	local header = getglobal("MTH_BOOK_HeaderText")
	if header then header:SetText("The Great Book of Huntards") end

	local filterNames = {}
	local check1 = ""
	local check2 = ""
	local check3 = ""
	local searchLabel = getglobal("MTH_BOOK_SearchLabel")
	local minLabel = getglobal("MTH_BOOK_MinLabel")
	local maxLabel = getglobal("MTH_BOOK_MaxLabel")

	if MTH_BOOK_STATE.mode == "pets" then
		filterNames = { "All", "Cats", "Wolves", "Boars", "Spiders", "" }
		check1 = "Rare"
		check2 = "Elite"
		check3 = "Unique"
	elseif MTH_BOOK_STATE.mode == "families" then
		filterNames = { "", "", "", "", "", "" }
		check1 = ""
		check2 = ""
		check3 = ""
	elseif MTH_BOOK_STATE.mode == "petabilities" then
		filterNames = { "", "", "", "", "", "" }
		check1 = ""
		check2 = ""
		check3 = ""
	elseif MTH_BOOK_STATE.mode == "npcs" then
		filterNames = { "", "", "", "", "", "" }
		check1 = "Alliance"
		check2 = "Horde"
		check3 = "Neutral"
	elseif MTH_BOOK_STATE.mode == "abilities" then
		filterNames = { "All", "Bite", "Claw", "Dash", "Screech", "Charge" }
		check1 = "Ranked only"
		check2 = "Rare beasts"
		check3 = "Has coords"
	else
		filterNames = { "", "", "", "", "", "" }
		check1 = ""
		check2 = ""
		check3 = ""
	end

	for i = 1, 6 do
		local btn = getglobal("MTH_BOOK_Filter" .. i)
		if btn then btn:SetText(filterNames[i] or "") end
	end

	if getglobal("MTH_BOOK_RequireVendorText") then getglobal("MTH_BOOK_RequireVendorText"):SetText(check1) end
	if getglobal("MTH_BOOK_RequireDropText") then getglobal("MTH_BOOK_RequireDropText"):SetText(check2) end
	if getglobal("MTH_BOOK_RequireObjectText") then getglobal("MTH_BOOK_RequireObjectText"):SetText(check3) end

	if searchLabel then
		if MTH_BOOK_STATE.mode == "npcs" then
			searchLabel:SetText("Name")
		else
			searchLabel:SetText("Search")
		end
	end
	if minLabel then
		if MTH_BOOK_STATE.mode == "npcs" or MTH_BOOK_IsItemMode() or MTH_BOOK_STATE.mode == "stable" or MTH_BOOK_STATE.mode == "families" or MTH_BOOK_STATE.mode == "pethistory" then
			minLabel:Hide()
		else
			minLabel:Show()
			minLabel:SetText("Min Lvl")
		end
	end
	if maxLabel then
		if MTH_BOOK_STATE.mode == "npcs" or MTH_BOOK_IsItemMode() or MTH_BOOK_STATE.mode == "stable" or MTH_BOOK_STATE.mode == "families" or MTH_BOOK_STATE.mode == "pethistory" then
			maxLabel:Hide()
		else
			maxLabel:Show()
			maxLabel:SetText("Max Lvl")
		end
	end

	if getglobal("MTH_BOOK_HideNoAbilitiesText") then getglobal("MTH_BOOK_HideNoAbilitiesText"):SetText("Hide No Abilities") end
	if getglobal("MTH_BOOK_PetOnlyMyLevelText") then
		if MTH_BOOK_IsItemMode() then
			getglobal("MTH_BOOK_PetOnlyMyLevelText"):SetText("Show only my level")
		else
			getglobal("MTH_BOOK_PetOnlyMyLevelText"):SetText("Only my level")
		end
		local onlyMyLevel = getglobal("MTH_BOOK_PetOnlyMyLevel")
		if onlyMyLevel then
			getglobal("MTH_BOOK_PetOnlyMyLevelText"):ClearAllPoints()
			getglobal("MTH_BOOK_PetOnlyMyLevelText"):SetPoint("LEFT", onlyMyLevel, "RIGHT", 1, 1)
		end
	end
	if getglobal("MTH_BOOK_PetInZoneOnlyText") then
		getglobal("MTH_BOOK_PetInZoneOnlyText"):SetText("In this zone only")
		local zoneOnly = getglobal("MTH_BOOK_PetInZoneOnly")
		if zoneOnly then
			getglobal("MTH_BOOK_PetInZoneOnlyText"):ClearAllPoints()
			getglobal("MTH_BOOK_PetInZoneOnlyText"):SetPoint("LEFT", zoneOnly, "RIGHT", 1, 1)
		end
	end
	if getglobal("MTH_BOOK_NPCInZoneOnlyText") then
		getglobal("MTH_BOOK_NPCInZoneOnlyText"):SetText("In this zone only")
		local zoneOnlyNpc = getglobal("MTH_BOOK_NPCInZoneOnly")
		if zoneOnlyNpc then
			getglobal("MTH_BOOK_NPCInZoneOnlyText"):ClearAllPoints()
			getglobal("MTH_BOOK_NPCInZoneOnlyText"):SetPoint("LEFT", zoneOnlyNpc, "RIGHT", 1, 1)
		end
	end
	if getglobal("MTH_BOOK_HideUnknownText") then
		if MTH_BOOK_STATE.mode == "npcs" then
			getglobal("MTH_BOOK_HideUnknownText"):SetText("Hide no zone")
		else
			getglobal("MTH_BOOK_HideUnknownText"):SetText("Hide Unknown")
		end
	end
	MTH_BOOK_UpdateQuickFilterControls()
end

local function MTH_BOOK_ApplyInputs()
	local search = getglobal("MTH_BOOK_Search")
	MTH_BOOK_STATE.search = MTH_BOOK_SafeLower(search and search:GetText() or "")
	if MTH_BOOK_STATE.mode == "npcs" or MTH_BOOK_IsItemMode() or MTH_BOOK_STATE.mode == "stable" or MTH_BOOK_STATE.mode == "families" or MTH_BOOK_STATE.mode == "pethistory" then
		MTH_BOOK_STATE.minLevel = nil
		MTH_BOOK_STATE.maxLevel = nil
	else
		MTH_BOOK_STATE.minLevel = MTH_BOOK_ParseBoxNumber("MTH_BOOK_MinLevel")
		MTH_BOOK_STATE.maxLevel = MTH_BOOK_ParseBoxNumber("MTH_BOOK_MaxLevel")
	end

	local requireVendor = getglobal("MTH_BOOK_RequireVendor")
	local requireDrop = getglobal("MTH_BOOK_RequireDrop")
	local requireObject = getglobal("MTH_BOOK_RequireObject")
	local hideNoAbilities = getglobal("MTH_BOOK_HideNoAbilities")
	local hideUnknown = getglobal("MTH_BOOK_HideUnknown")
	local petOnlyMyLevel = getglobal("MTH_BOOK_PetOnlyMyLevel")
	local petInZoneOnly = getglobal("MTH_BOOK_PetInZoneOnly")
	local npcInZoneOnly = getglobal("MTH_BOOK_NPCInZoneOnly")
	local showAllOnMapButton = getglobal("MTH_BOOK_ShowAllOnMapButton")
	MTH_BOOK_STATE.flag1 = requireVendor and requireVendor:GetChecked() == 1 or false
	MTH_BOOK_STATE.flag2 = requireDrop and requireDrop:GetChecked() == 1 or false
	MTH_BOOK_STATE.flag3 = requireObject and requireObject:GetChecked() == 1 or false
	if MTH_BOOK_STATE.mode == "pets" then
		MTH_BOOK_STATE.petHideNoAbilities = hideNoAbilities and hideNoAbilities:GetChecked() == 1 or false
		MTH_BOOK_STATE.petHideUnknown = hideUnknown and hideUnknown:GetChecked() == 1 or false
		MTH_BOOK_STATE.petInZoneOnly = petInZoneOnly and petInZoneOnly:GetChecked() == 1 or false
	elseif MTH_BOOK_STATE.mode == "petabilities" then
		MTH_BOOK_STATE.petOnlyMyLevel = petOnlyMyLevel and petOnlyMyLevel:GetChecked() == 1 or false
	elseif MTH_BOOK_IsItemMode() then
		MTH_BOOK_STATE.itemOnlyMyLevel = petOnlyMyLevel and petOnlyMyLevel:GetChecked() == 1 or false
	elseif MTH_BOOK_STATE.mode == "npcs" then
		MTH_BOOK_STATE.npcHideNoZone = hideUnknown and hideUnknown:GetChecked() == 1 or false
		MTH_BOOK_STATE.npcInZoneOnly = npcInZoneOnly and npcInZoneOnly:GetChecked() == 1 or false
	end

	MTH_BOOK_STATE.page = 1
	MTH_BOOK_STATE.selectedEntry = nil
	MTH_BOOK_STATE.selectedPetRankEntry = nil
	MTH_BOOK_STATE.petRankRows = {}
	MTH_BOOK_RefreshFilter()
end

local function MTH_BOOK_SetQuickFilter(index)
	if MTH_BOOK_STATE.mode == "pets" then
		local map = { [1] = "all", [2] = "cats", [3] = "wolves", [4] = "boars", [5] = "spiders", [6] = "all" }
		MTH_BOOK_STATE.quick = map[index] or "all"
	elseif MTH_BOOK_STATE.mode == "families" then
		MTH_BOOK_STATE.quick = "all"
	elseif MTH_BOOK_STATE.mode == "petabilities" then
		MTH_BOOK_STATE.quick = "all"
	elseif MTH_BOOK_STATE.mode == "npcs" then
		MTH_BOOK_STATE.quick = "all"
	elseif MTH_BOOK_STATE.mode == "abilities" then
		local map = { [1] = "all", [2] = "bite", [3] = "claw", [4] = "dash", [5] = "screech", [6] = "charge" }
		MTH_BOOK_STATE.quick = map[index] or "all"
	else
		local map = { [1] = "all", [2] = "arrow", [3] = "bullet", [4] = "bow", [5] = "gun", [6] = "crossbow" }
		MTH_BOOK_STATE.quick = map[index] or "all"
	end
	MTH_BOOK_STATE.page = 1
	MTH_BOOK_STATE.selectedEntry = nil
	MTH_BOOK_STATE.forcedBeastId = nil
	MTH_BOOK_RefreshFilter()
end

local function MTH_BOOK_StyleSectionTab(button)
	if not button then return end
	button:SetHeight(24)
	button:SetScript("OnShow", nil)
end

local function MTH_BOOK_UpdateSectionTabs()
	local sectionPets = getglobal("MTH_BOOK_SectionPets")
	local sectionFamilies = getglobal("MTH_BOOK_SectionFamilies")
	local sectionPetAbilities = getglobal("MTH_BOOK_SectionPetAbilities")
	local sectionItems = getglobal("MTH_BOOK_SectionItems")
	local sectionProjectiles = getglobal("MTH_BOOK_SectionProjectiles")
	local sectionAmmoBags = getglobal("MTH_BOOK_SectionAmmoBags")
	local sectionNPCs = getglobal("MTH_BOOK_SectionNPCs")
	local sectionStable = getglobal("MTH_BOOK_SectionStable")
	local sectionPetHistory = getglobal("MTH_BOOK_SectionPetHistory")

	local function setState(button, selected)
		if not button then return end
		if selected then
			PanelTemplates_SelectTab(button)
		else
			PanelTemplates_DeselectTab(button)
		end
	end

	setState(sectionPets, MTH_BOOK_STATE.mode == "pets")
	setState(sectionFamilies, MTH_BOOK_STATE.mode == "families")
	setState(sectionPetAbilities, MTH_BOOK_STATE.mode == "petabilities")
	setState(sectionItems, MTH_BOOK_STATE.mode == "items")
	setState(sectionProjectiles, MTH_BOOK_STATE.mode == "projectiles")
	setState(sectionAmmoBags, MTH_BOOK_STATE.mode == "ammobags")
	setState(sectionNPCs, MTH_BOOK_STATE.mode == "npcs")
	setState(sectionStable, MTH_BOOK_STATE.mode == "stable")
	setState(sectionPetHistory, MTH_BOOK_STATE.mode == "pethistory")
end

local function MTH_BOOK_LayoutSectionTabs()
	local tabBar = getglobal("MTH_BOOK_TabBar")
	local sectionPets = getglobal("MTH_BOOK_SectionPets")
	local sectionFamilies = getglobal("MTH_BOOK_SectionFamilies")
	local sectionPetAbilities = getglobal("MTH_BOOK_SectionPetAbilities")
	local sectionItems = getglobal("MTH_BOOK_SectionItems")
	local sectionProjectiles = getglobal("MTH_BOOK_SectionProjectiles")
	local sectionAmmoBags = getglobal("MTH_BOOK_SectionAmmoBags")
	local sectionNPCs = getglobal("MTH_BOOK_SectionNPCs")
	local sectionStable = getglobal("MTH_BOOK_SectionStable")
	local sectionPetHistory = getglobal("MTH_BOOK_SectionPetHistory")
	if not (tabBar and sectionPets and sectionFamilies and sectionPetAbilities and sectionItems and sectionNPCs and sectionProjectiles and sectionAmmoBags) then return end

	if sectionStable then
		sectionStable:ClearAllPoints()
		sectionStable:SetPoint("TOPLEFT", tabBar, "TOPLEFT", 0, 0)
	end

	sectionPetAbilities:ClearAllPoints()
	if sectionStable then
		sectionPetAbilities:SetPoint("LEFT", sectionStable, "RIGHT", 2, 0)
	else
		sectionPetAbilities:SetPoint("TOPLEFT", tabBar, "TOPLEFT", 0, 0)
	end

	sectionPets:ClearAllPoints()
	sectionPets:SetPoint("LEFT", sectionPetAbilities, "RIGHT", 2, 0)

	sectionFamilies:ClearAllPoints()
	sectionFamilies:SetPoint("LEFT", sectionPets, "RIGHT", 2, 0)

	sectionNPCs:ClearAllPoints()
	sectionNPCs:SetPoint("LEFT", sectionFamilies, "RIGHT", 2, 0)

	sectionItems:ClearAllPoints()
	sectionItems:SetPoint("LEFT", sectionNPCs, "RIGHT", 2, 0)

	sectionProjectiles:ClearAllPoints()
	sectionProjectiles:SetPoint("LEFT", sectionItems, "RIGHT", 2, 0)

	sectionAmmoBags:ClearAllPoints()
	sectionAmmoBags:SetPoint("LEFT", sectionProjectiles, "RIGHT", 2, 0)

	if sectionPetHistory then
		sectionPetHistory:ClearAllPoints()
		sectionPetHistory:SetPoint("LEFT", sectionAmmoBags, "RIGHT", 2, 0)
	end
end

local function MTH_BOOK_GetFilterWidgets()
	return {
		search = getglobal("MTH_BOOK_Search"),
		min = getglobal("MTH_BOOK_MinLevel"),
		max = getglobal("MTH_BOOK_MaxLevel"),
		requireVendor = getglobal("MTH_BOOK_RequireVendor"),
		requireDrop = getglobal("MTH_BOOK_RequireDrop"),
		requireObject = getglobal("MTH_BOOK_RequireObject"),
		hideNoAbilities = getglobal("MTH_BOOK_HideNoAbilities"),
		hideUnknown = getglobal("MTH_BOOK_HideUnknown"),
		abilityDropdown = getglobal("MTH_BOOK_AbilityDropdown"),
		rankDropdown = getglobal("MTH_BOOK_RankDropdown"),
		npcFunctionDropdown = getglobal("MTH_BOOK_NPCFunctionDropdown"),
		npcZoneDropdown = getglobal("MTH_BOOK_NPCZoneDropdown"),
		petLearnSourceDropdown = getglobal("MTH_BOOK_PetLearnSourceDropdown"),
		itemSubtypeDropdown = getglobal("MTH_BOOK_ItemSubtypeDropdown"),
		petOnlyMyLevel = getglobal("MTH_BOOK_PetOnlyMyLevel"),
		petInZoneOnly = getglobal("MTH_BOOK_PetInZoneOnly"),
		npcInZoneOnly = getglobal("MTH_BOOK_NPCInZoneOnly"),
	}
end

local function MTH_BOOK_ResetStateForMode(mode)
	MTH_BOOK_STATE.search = ""
	MTH_BOOK_STATE.quick = "all"
	MTH_BOOK_STATE.minLevel = nil
	MTH_BOOK_STATE.maxLevel = nil
	MTH_BOOK_STATE.flag1 = false
	MTH_BOOK_STATE.flag2 = false
	MTH_BOOK_STATE.flag3 = false
	MTH_BOOK_STATE.petAbility = "all"
	MTH_BOOK_STATE.petRank = "all"
	MTH_BOOK_STATE.petLearnSource = "all"
	MTH_BOOK_STATE.petOnlyMyLevel = false
	MTH_BOOK_STATE.itemOnlyMyLevel = false
	MTH_BOOK_STATE.petInZoneOnly = false
	MTH_BOOK_STATE.itemSubtype = "all"
	MTH_BOOK_STATE.npcFunction = "all"
	MTH_BOOK_STATE.npcZone = "all"
	MTH_BOOK_STATE.npcInZoneOnly = false
	MTH_BOOK_STATE.npcHideNoZone = true
	MTH_BOOK_STATE.petHideNoAbilities = false
	MTH_BOOK_STATE.petHideUnknown = false
	MTH_BOOK_STATE.forcedBeastId = nil
	MTH_BOOK_STATE.petLeftOffset = 0

	if mode == "pets" then
		MTH_BOOK_STATE.petHideNoAbilities = true
		MTH_BOOK_STATE.petHideUnknown = true
	elseif mode == "families" then
		MTH_BOOK_STATE.quick = "all"
	elseif mode == "petabilities" then
		MTH_BOOK_STATE.petLearnSource = "beast"
		MTH_BOOK_STATE.petOnlyMyLevel = true
	elseif MTH_BOOK_IsItemMode(mode) then
		MTH_BOOK_STATE.itemSubtype = "all"
		MTH_BOOK_STATE.itemOnlyMyLevel = false
	elseif mode == "npcs" then
		MTH_BOOK_STATE.flag1, MTH_BOOK_STATE.flag2, MTH_BOOK_STATE.flag3 = MTH_BOOK_GetPlayerReactDefaults()
		MTH_BOOK_STATE.npcHideNoZone = true
	end

	MTH_BOOK_STATE.page = 1
	MTH_BOOK_STATE.selectedEntry = nil
	MTH_BOOK_STATE.selectedPetRankEntry = nil
	MTH_BOOK_STATE.petRankRows = {}
end

local function MTH_BOOK_ApplyStateToWidgets(widgets)
	if widgets.search then widgets.search:SetText("") end
	if widgets.min then widgets.min:SetText("") end
	if widgets.max then widgets.max:SetText("") end
	if widgets.requireVendor then widgets.requireVendor:SetChecked(MTH_BOOK_STATE.flag1 and 1 or nil) end
	if widgets.requireDrop then widgets.requireDrop:SetChecked(MTH_BOOK_STATE.flag2 and 1 or nil) end
	if widgets.requireObject then widgets.requireObject:SetChecked(MTH_BOOK_STATE.flag3 and 1 or nil) end
	if widgets.hideNoAbilities then
		widgets.hideNoAbilities:SetChecked(MTH_BOOK_STATE.mode == "pets" and MTH_BOOK_STATE.petHideNoAbilities and 1 or nil)
	end
	if widgets.hideUnknown then
		if MTH_BOOK_STATE.mode == "pets" then
			widgets.hideUnknown:SetChecked(MTH_BOOK_STATE.petHideUnknown and 1 or nil)
		elseif MTH_BOOK_STATE.mode == "npcs" then
			widgets.hideUnknown:SetChecked(MTH_BOOK_STATE.npcHideNoZone and 1 or nil)
		else
			widgets.hideUnknown:SetChecked(nil)
		end
	end
	if widgets.petOnlyMyLevel then
		if MTH_BOOK_STATE.mode == "petabilities" then
			widgets.petOnlyMyLevel:SetChecked(MTH_BOOK_STATE.petOnlyMyLevel and 1 or nil)
		elseif MTH_BOOK_IsItemMode() then
			widgets.petOnlyMyLevel:SetChecked(MTH_BOOK_STATE.itemOnlyMyLevel and 1 or nil)
		else
			widgets.petOnlyMyLevel:SetChecked(nil)
		end
	end
	if widgets.petInZoneOnly then
		widgets.petInZoneOnly:SetChecked(MTH_BOOK_STATE.mode == "pets" and MTH_BOOK_STATE.petInZoneOnly and 1 or nil)
	end
	if widgets.npcInZoneOnly then
		widgets.npcInZoneOnly:SetChecked(MTH_BOOK_STATE.mode == "npcs" and MTH_BOOK_STATE.npcInZoneOnly and 1 or nil)
	end
end

local function MTH_BOOK_SetMode(mode)
	if mode == "abilities" then mode = "pets" end
	if MTH_BOOK_STATE.mode == mode then return end
	if mode == "families" then
		MTH_BOOK_FamiliesTrace("SetMode -> families")
	end
	MTH_BOOK_STATE.mode = mode

	local widgets = MTH_BOOK_GetFilterWidgets()
	MTH_BOOK_ResetStateForMode(mode)
	MTH_BOOK_ApplyStateToWidgets(widgets)
	MTH_BOOK_BuildPetAbilityOptions()
	MTH_BOOK_BuildPetRankOptions()
	MTH_BOOK_UpdatePetLearnSourceDropdownText()

	MTH_BOOK_UpdateModeLabels()
	MTH_BOOK_UpdateSectionTabs()
	MTH_BOOK_RefreshFilter()
end

function MTH_BOOK_JumpToBeastById(beastId)
	local id = tonumber(beastId)
	if not id then
		return false
	end
	local beast = MTH_DS_Beasts and MTH_DS_Beasts[id]
	if type(beast) ~= "table" then
		return false
	end

	MTH_BOOK_STATE.mode = "pets"
	local widgets = MTH_BOOK_GetFilterWidgets()
	MTH_BOOK_ResetStateForMode("pets")
	MTH_BOOK_STATE.search = tostring(id)
	MTH_BOOK_STATE.forcedBeastId = id
	MTH_BOOK_ApplyStateToWidgets(widgets)
	if widgets.search then widgets.search:SetText(MTH_BOOK_STATE.search) end
	MTH_BOOK_BuildPetAbilityOptions()
	MTH_BOOK_BuildPetRankOptions()
	MTH_BOOK_UpdatePetLearnSourceDropdownText()
	MTH_BOOK_UpdateModeLabels()
	MTH_BOOK_UpdateSectionTabs()
	MTH_BOOK_RefreshFilter()

	MTH_BOOK_STATE.selectedEntry = {
		beastId = id,
		name = beast.name,
	}
	MTH_BOOK_UpdateResults()
	MTH_BOOK_UpdateDetail()
	return true
end

local function MTH_BOOK_CreateResultButtons(parent)
	for i = 1, MTH_BOOK_MAX_COLS do
		local colIndex = i
		local headerButton = CreateFrame("Button", nil, parent)
		headerButton:RegisterForClicks("LeftButtonUp")
		headerButton:SetFrameLevel(parent:GetFrameLevel() + 10)
		headerButton:SetScript("OnClick", function()
			MTH_BOOK_OnHeaderClick(colIndex)
		end)
		headerButton:EnableMouse(true)
		MTH_BOOK_STATE.headerButtons[i] = headerButton

		local header = parent:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
		header:SetHeight(14)
		header:SetTextColor(1.00, 0.82, 0.00)
		MTH_BOOK_STATE.headerCols[i] = header
	end

	MTH_BOOK_UpdateListHeaders()

	local y = -24
	for i = 1, MTH_BOOK_MAX_ROWS do
		local btn = CreateFrame("Button", "MTH_BOOK_ResultButton" .. i, parent)
		btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
		btn:SetPoint("TOPLEFT", parent, "TOPLEFT", 4, y)
		btn:SetWidth(556)
		btn:SetHeight(19)
		btn.entry = nil
		btn.cols = {}

		local highlight = btn:CreateTexture(nil, "HIGHLIGHT")
		highlight:SetAllPoints(btn)
		highlight:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
		highlight:SetBlendMode("ADD")
		highlight:SetAlpha(0.35)

		local line = btn:CreateTexture(nil, "BORDER")
		line:SetTexture("Interface\\Buttons\\WHITE8X8")
		line:SetVertexColor(0.30, 0.30, 0.30, 0.55)
		line:SetPoint("BOTTOMLEFT", btn, "BOTTOMLEFT", 2, 0)
		line:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", -2, 0)
		line:SetHeight(1)

		for c = 1, MTH_BOOK_MAX_COLS do
			local col = btn:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
			col:SetHeight(14)
			col:SetTextColor(0.86, 0.86, 0.86)
			col:SetJustifyH("LEFT")
			btn.cols[c] = col
		end

		btn.bookLinkButton = CreateFrame("Button", nil, btn)
		btn.bookLinkButton:Hide()
		btn.bookLinkButton:SetScript("OnClick", function()
			if this:GetParent() and this:GetParent().entry then
				if this:GetParent().entry.beastId then
					MTH_BOOK_OpenNPCLink(this:GetParent().entry.beastId)
				elseif this:GetParent().entry.npcId then
					MTH_BOOK_OpenNPCLink(this:GetParent().entry.npcId)
				elseif this:GetParent().entry.itemId then
					MTH_BOOK_OpenItemDatabaseLink(this:GetParent().entry.itemId)
				end
			end
		end)
		btn.bookLinkButton:SetScript("OnEnter", function()
			return
		end)
		btn.bookLinkButton:SetScript("OnLeave", function()
			return
		end)

		btn.itemLinkButton = CreateFrame("Button", nil, btn)
		btn.itemLinkButton:Hide()
		btn.itemLinkButton:SetScript("OnClick", nil)
		btn.itemLinkButton:SetScript("OnEnter", nil)
		btn.itemLinkButton:SetScript("OnLeave", nil)

		btn.itemIcon = btn:CreateTexture(nil, "ARTWORK")
		btn.itemIcon:SetWidth(14)
		btn.itemIcon:SetHeight(14)
		btn.itemIcon:Hide()

		btn.nameHoverButton = CreateFrame("Button", nil, btn)
		btn.nameHoverButton:Hide()
		btn.nameHoverButton:SetScript("OnEnter", function()
			if this:GetParent() and this:GetParent().entry and this:GetParent().entry.itemId then
				MTH_BOOK_ShowItemTooltip(this, this:GetParent().entry.itemId)
			end
		end)
		btn.nameHoverButton:SetScript("OnLeave", function()
			MTH_BOOK_HideItemTooltip()
		end)
		btn.nameHoverButton:SetScript("OnClick", function()
			if not this:GetParent() or not this:GetParent().entry then return end
			if MTH_BOOK_IsItemMode() and this:GetParent().entry.itemId and type(IsShiftKeyDown) == "function" and IsShiftKeyDown() then
				if MTH_BOOK_InsertItemLinkToChat(this:GetParent().entry.itemId) then
					return
				end
			end
			MTH_BOOK_STATE.selectedEntry = this:GetParent().entry
			MTH_BOOK_UpdateDetail()
			if arg1 == "RightButton" then
				MTH_BOOK_OpenSelectedBeastOnMap()
				MTH_BOOK_TryTargetSelectedEntry()
			end
		end)

		btn.familyAbilityButtons = {}
		for chipIndex = 1, 12 do
			local chip = CreateFrame("Button", nil, btn)
			chip:SetHeight(14)
			chip.abilityEntry = nil
			chip.abilityTooltipFunc = nil
			chip.icon = chip:CreateTexture(nil, "ARTWORK")
			chip.icon:SetPoint("LEFT", chip, "LEFT", 0, 0)
			chip.icon:SetWidth(12)
			chip.icon:SetHeight(12)
			chip.text = chip:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
			chip.text:SetPoint("LEFT", chip.icon, "RIGHT", 2, 0)
			chip.text:SetJustifyH("LEFT")
			chip:SetScript("OnEnter", function()
				if not this or not this.abilityEntry then return end
				if type(this.abilityTooltipFunc) == "function" then
					this.abilityTooltipFunc(this, this.abilityEntry)
				elseif type(MTH_BOOKTAB_ShowFamilyAbilityTooltip) == "function" then
					MTH_BOOKTAB_ShowFamilyAbilityTooltip(this, this.abilityEntry)
				end
			end)
			chip:SetScript("OnLeave", function()
				if type(MTH_BOOK_HideSpellTooltip) == "function" then
					MTH_BOOK_HideSpellTooltip()
				end
			end)
			chip:Hide()
			btn.familyAbilityButtons[chipIndex] = chip
		end

		btn:SetScript("OnClick", function()
			if this.entry then
				if MTH_BOOK_IsItemMode() and this.entry.itemId and type(IsShiftKeyDown) == "function" and IsShiftKeyDown() then
					if MTH_BOOK_InsertItemLinkToChat(this.entry.itemId) then
						return
					end
				end

				MTH_BOOK_STATE.selectedEntry = this.entry
				MTH_BOOK_UpdateDetail()
				if arg1 == "RightButton" then
					MTH_BOOK_OpenSelectedBeastOnMap()
					MTH_BOOK_TryTargetSelectedEntry()
				end
			end
		end)
		btn:SetScript("OnEnter", function()
			return
		end)
		btn:SetScript("OnLeave", function()
			return
		end)
		MTH_BOOK_STATE.buttons[i] = btn
		y = y - 20
	end

	MTH_BOOK_ApplyColumnLayout(parent)
end

local function MTH_BOOK_ScrollPage(delta)
	if MTH_BOOK_STATE.mode == "petabilities" or MTH_BOOK_STATE.mode == "stable" or MTH_BOOK_STATE.mode == "families" then return end
	if not delta or delta == 0 then return end
	if delta > 0 then
		MTH_BOOK_STATE.page = MTH_BOOK_STATE.page - 1
	else
		MTH_BOOK_STATE.page = MTH_BOOK_STATE.page + 1
	end
	MTH_BOOK_UpdateResults()
end

local function MTH_BOOK_ResetAllFiltersAndRefresh()
	local widgets = MTH_BOOK_GetFilterWidgets()
	MTH_BOOK_ResetStateForMode(MTH_BOOK_STATE.mode)
	MTH_BOOK_ApplyStateToWidgets(widgets)

	MTH_BOOK_BuildPetAbilityOptions()
	MTH_BOOK_BuildPetRankOptions()
	MTH_BOOK_BuildNPCFunctionOptions()
	MTH_BOOK_BuildNPCZoneOptions()
	if widgets.abilityDropdown then MTH_BOOK_UpdateAbilityDropdownText() end
	if widgets.rankDropdown then MTH_BOOK_UpdateRankDropdownText() end
	if widgets.petLearnSourceDropdown then MTH_BOOK_UpdatePetLearnSourceDropdownText() end
	if widgets.itemSubtypeDropdown then MTH_BOOK_UpdateItemSubtypeDropdownText() end
	if widgets.npcFunctionDropdown or widgets.npcZoneDropdown then MTH_BOOK_UpdateNPCDropdownTexts() end

	MTH_BOOK_UpdateModeLabels()
	MTH_BOOK_RefreshFilter()
end

local function MTH_BOOK_WireUI(frame)
	if frame and frame.SetBackdropColor then
		frame:SetBackdropColor(0.05, 0.05, 0.05, 1.00)
		frame:SetBackdropBorderColor(0.35, 0.35, 0.35, 1.00)
	end

	local closeButton = getglobal("MTH_BOOK_CloseButton")
	local applyButton = getglobal("MTH_BOOK_ApplyButton")
	local resetButton = getglobal("MTH_BOOK_ResetButton")
	local sectionPets = getglobal("MTH_BOOK_SectionPets")
	local sectionFamilies = getglobal("MTH_BOOK_SectionFamilies")
	local sectionPetAbilities = getglobal("MTH_BOOK_SectionPetAbilities")
	local sectionItems = getglobal("MTH_BOOK_SectionItems")
	local sectionProjectiles = getglobal("MTH_BOOK_SectionProjectiles")
	local sectionAmmoBags = getglobal("MTH_BOOK_SectionAmmoBags")
	local sectionNPCs = getglobal("MTH_BOOK_SectionNPCs")
	local sectionStable = getglobal("MTH_BOOK_SectionStable")
	local sectionPetHistory = getglobal("MTH_BOOK_SectionPetHistory")
	local requireVendor = getglobal("MTH_BOOK_RequireVendor")
	local requireDrop = getglobal("MTH_BOOK_RequireDrop")
	local requireObject = getglobal("MTH_BOOK_RequireObject")
	local abilityDropdown = getglobal("MTH_BOOK_AbilityDropdown")
	local rankDropdown = getglobal("MTH_BOOK_RankDropdown")
	local petLearnSourceDropdown = getglobal("MTH_BOOK_PetLearnSourceDropdown")
	local itemSubtypeDropdown = getglobal("MTH_BOOK_ItemSubtypeDropdown")
	local npcFunctionDropdown = getglobal("MTH_BOOK_NPCFunctionDropdown")
	local npcZoneDropdown = getglobal("MTH_BOOK_NPCZoneDropdown")
	local petBookScanButton = getglobal("MTH_BOOK_PetBookScanButton")
	local hideNoAbilities = getglobal("MTH_BOOK_HideNoAbilities")
	local hideUnknown = getglobal("MTH_BOOK_HideUnknown")
	local petOnlyMyLevel = getglobal("MTH_BOOK_PetOnlyMyLevel")
	local petInZoneOnly = getglobal("MTH_BOOK_PetInZoneOnly")
	local npcInZoneOnly = getglobal("MTH_BOOK_NPCInZoneOnly")
	local showAllOnMapButton = getglobal("MTH_BOOK_ShowAllOnMapButton")
	local prevButton = getglobal("MTH_BOOK_PrevButton")
	local nextButton = getglobal("MTH_BOOK_NextButton")
	local openMapButton = getglobal("MTH_BOOK_OpenMapButton")
	local listSlider = getglobal("MTH_BOOK_ListSlider")
	local search = getglobal("MTH_BOOK_Search")
	local min = getglobal("MTH_BOOK_MinLevel")
	local max = getglobal("MTH_BOOK_MaxLevel")

	if closeButton then
		closeButton:ClearAllPoints()
		closeButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -8, -8)
		closeButton:SetWidth(22)
		closeButton:SetHeight(22)
		closeButton:SetText("X")
		closeButton:SetScript("OnClick", function() this:GetParent():Hide() end)
	end
	if applyButton then applyButton:SetScript("OnClick", MTH_BOOK_ApplyInputs) end

	if resetButton then
		resetButton:SetScript("OnClick", MTH_BOOK_ResetAllFiltersAndRefresh)
	end

	if sectionPets then sectionPets:SetScript("OnClick", function() MTH_BOOK_SetMode("pets") end) end
	if sectionFamilies then sectionFamilies:SetScript("OnClick", function() MTH_BOOK_SetMode("families") end) end
	if sectionPetAbilities then sectionPetAbilities:SetScript("OnClick", function() MTH_BOOK_SetMode("petabilities") end) end
	if sectionItems then sectionItems:SetScript("OnClick", function() MTH_BOOK_SetMode("items") end) end
	if sectionProjectiles then sectionProjectiles:SetScript("OnClick", function() MTH_BOOK_SetMode("projectiles") end) end
	if sectionAmmoBags then sectionAmmoBags:SetScript("OnClick", function() MTH_BOOK_SetMode("ammobags") end) end
	if sectionNPCs then sectionNPCs:SetScript("OnClick", function() MTH_BOOK_SetMode("npcs") end) end
	if sectionStable then sectionStable:SetScript("OnClick", function() MTH_BOOK_SetMode("stable") end) end
	if sectionPetHistory then sectionPetHistory:SetScript("OnClick", function() MTH_BOOK_SetMode("pethistory") end) end

	MTH_BOOK_StyleSectionTab(sectionPets)
	MTH_BOOK_StyleSectionTab(sectionFamilies)
	MTH_BOOK_StyleSectionTab(sectionPetAbilities)
	MTH_BOOK_StyleSectionTab(sectionItems)
	MTH_BOOK_StyleSectionTab(sectionProjectiles)
	MTH_BOOK_StyleSectionTab(sectionAmmoBags)
	MTH_BOOK_StyleSectionTab(sectionNPCs)
	MTH_BOOK_StyleSectionTab(sectionStable)
	MTH_BOOK_StyleSectionTab(sectionPetHistory)
	MTH_BOOK_LayoutSectionTabs()

	for i = 1, 6 do
		local filterBtn = getglobal("MTH_BOOK_Filter" .. i)
		if filterBtn then
			filterBtn:SetScript("OnClick", function() MTH_BOOK_SetQuickFilter(i) end)
		end
	end

	MTH_BOOK_InitFamilyDropdown()
	MTH_BOOK_InitAbilityDropdown()
	MTH_BOOK_InitRankDropdown()
	MTH_BOOK_InitPetLearnSourceDropdown()
	MTH_BOOK_InitItemSubtypeDropdown()
	MTH_BOOK_InitNPCFunctionDropdown()

	if petBookScanButton then
		petBookScanButton:SetScript("OnClick", function()
			local function getRowCount()
				local getNumCrafts = (type(getglobal) == "function" and getglobal("GetNumCrafts")) or (_G and _G["GetNumCrafts"])
				if type(getNumCrafts) == "function" then
					return tonumber(getNumCrafts()) or 0
				end
				return 0
			end

			local function isTrainingVisible()
				local beastTraining = (type(getglobal) == "function" and getglobal("BeastTrainingFrame")) or (_G and _G["BeastTrainingFrame"])
				local petTraining = (type(getglobal) == "function" and getglobal("PetTrainingFrame")) or (_G and _G["PetTrainingFrame"])
				if beastTraining and ((beastTraining.IsVisible and beastTraining:IsVisible()) or (beastTraining.IsShown and beastTraining:IsShown())) then
					return true
				end
				if petTraining and ((petTraining.IsVisible and petTraining:IsVisible()) or (petTraining.IsShown and petTraining:IsShown())) then
					return true
				end
				return false
			end

			local function runScanNow()
				if MTH and MTH.Print then
					MTH:Print("Beast Training opened. Running scan...")
				end
				if SlashCmdList and SlashCmdList.MTH then
					SlashCmdList.MTH("trainscan")
				end
			end

			if not isTrainingVisible() then
				local castSpellByName = (type(getglobal) == "function" and getglobal("CastSpellByName")) or (_G and _G["CastSpellByName"])
				if type(castSpellByName) == "function" then
					castSpellByName("Beast Training")
				end
			end

			if isTrainingVisible() then
				runScanNow()
				return
			end

			if getRowCount() > 0 then
				runScanNow()
				return
			end

			local waitFrame = CreateFrame("Frame")
			local elapsed = 0
			local done = false

			waitFrame:RegisterEvent("PET_TRAINING_SHOW")
			waitFrame:SetScript("OnEvent", function()
				if done then return end
				done = true
				this:UnregisterEvent("PET_TRAINING_SHOW")
				this:SetScript("OnEvent", nil)
				this:SetScript("OnUpdate", nil)
				runScanNow()
			end)

			waitFrame:SetScript("OnUpdate", function()
				if done then
					this:SetScript("OnUpdate", nil)
					return
				end

				elapsed = elapsed + (arg1 or 0)
				local rows = getRowCount()
				if rows > 0 then
					done = true
					this:UnregisterEvent("PET_TRAINING_SHOW")
					this:SetScript("OnEvent", nil)
					this:SetScript("OnUpdate", nil)
					runScanNow()
					return
				end

				if isTrainingVisible() then
					done = true
					this:UnregisterEvent("PET_TRAINING_SHOW")
					this:SetScript("OnEvent", nil)
					this:SetScript("OnUpdate", nil)
					runScanNow()
					return
				end

				if elapsed >= 6 then
					done = true
					this:UnregisterEvent("PET_TRAINING_SHOW")
					this:SetScript("OnEvent", nil)
					this:SetScript("OnUpdate", nil)
					if MTH and MTH.Print then
						MTH:Print("Could not open Beast Training automatically. Open Beast Training manually.")
					end
				end
			end)
		end)
	end

	if requireVendor then requireVendor:SetScript("OnClick", MTH_BOOK_ApplyInputs) end
	if requireDrop then requireDrop:SetScript("OnClick", MTH_BOOK_ApplyInputs) end
	if requireObject then requireObject:SetScript("OnClick", MTH_BOOK_ApplyInputs) end
	if hideNoAbilities then hideNoAbilities:SetScript("OnClick", MTH_BOOK_ApplyInputs) end
	if hideUnknown then hideUnknown:SetScript("OnClick", MTH_BOOK_ApplyInputs) end
	if petOnlyMyLevel then petOnlyMyLevel:SetScript("OnClick", MTH_BOOK_ApplyInputs) end
	if petInZoneOnly then petInZoneOnly:SetScript("OnClick", MTH_BOOK_ApplyInputs) end
	if npcInZoneOnly then npcInZoneOnly:SetScript("OnClick", MTH_BOOK_ApplyInputs) end
	if showAllOnMapButton then showAllOnMapButton:SetScript("OnClick", MTH_BOOK_ShowAllFilteredBeastsOnMap) end

	if prevButton then
		prevButton:SetScript("OnClick", function()
			MTH_BOOK_STATE.page = MTH_BOOK_STATE.page - 1
			MTH_BOOK_UpdateResults()
		end)
	end
	if nextButton then
		nextButton:SetScript("OnClick", function()
			MTH_BOOK_STATE.page = MTH_BOOK_STATE.page + 1
			MTH_BOOK_UpdateResults()
		end)
	end
	if openMapButton then
		openMapButton:SetScript("OnClick", MTH_BOOK_OpenSelectedBeastOnMap)
	end

	if listSlider then
		listSlider:SetMinMaxValues(1, 1)
		listSlider:SetValueStep(1)
		listSlider:SetValue(1)
		listSlider:Show()
		local sliderThumb = getglobal("MTH_BOOK_ListSliderThumbTexture")
		if sliderThumb then
			sliderThumb:SetTexture("Interface\\Buttons\\UI-SliderBar-Button-Vertical")
			sliderThumb:SetWidth(20)
			sliderThumb:SetHeight(24)
		end
		MTH_BOOK_HideSliderTemplateTexts()
		listSlider:SetScript("OnShow", function()
			MTH_BOOK_HideSliderTemplateTexts()
		end)
		listSlider:SetScript("OnMouseDown", function()
			MTH_BOOK_STATE.sliderDragging = true
			MTH_BOOK_SetSliderFromCursor(this)
		end)
		listSlider:SetScript("OnMouseUp", function()
			MTH_BOOK_SetSliderFromCursor(this)
			MTH_BOOK_STATE.sliderDragging = false
		end)
		listSlider:SetScript("OnUpdate", function()
			if MTH_BOOK_STATE.sliderDragging then
				if IsMouseButtonDown and not IsMouseButtonDown("LeftButton") then
					MTH_BOOK_STATE.sliderDragging = false
				else
					MTH_BOOK_SetSliderFromCursor(this)
				end
			end
		end)
		listSlider:SetScript("OnValueChanged", function()
			local value = this:GetValue()
			if not value then return end
			value = math.floor(value + 0.5)
			MTH_BOOK_HideSliderTemplateTexts()
			MTH_BOOK_UpdateSliderMarker(this)
			if value ~= MTH_BOOK_STATE.page then
				MTH_BOOK_STATE.page = value
				MTH_BOOK_UpdateResults()
			end
		end)
		MTH_BOOK_UpdateSliderMarker(listSlider)
	end

	if search then
		search:SetAutoFocus(false)
		search:SetScript("OnEnterPressed", function() this:ClearFocus(); MTH_BOOK_ApplyInputs() end)
		search:SetScript("OnEscapePressed", function() this:ClearFocus() end)
	end
	if min then
		min:SetNumeric(true)
		min:SetAutoFocus(false)
		min:SetScript("OnEnterPressed", function() this:ClearFocus(); MTH_BOOK_ApplyInputs() end)
		min:SetScript("OnEscapePressed", function() this:ClearFocus() end)
	end
	if max then
		max:SetNumeric(true)
		max:SetAutoFocus(false)
		max:SetScript("OnEnterPressed", function() this:ClearFocus(); MTH_BOOK_ApplyInputs() end)
		max:SetScript("OnEscapePressed", function() this:ClearFocus() end)
	end

	local listParent = getglobal("MTH_BOOK_ListBackdrop")
	local topAreaBackdrop = getglobal("MTH_BOOK_TopAreaBackdrop")
	local sliderBackdrop = getglobal("MTH_BOOK_ListSliderBackdrop")
	local detailParent = getglobal("MTH_BOOK_DetailBackdrop")

	if topAreaBackdrop then
		topAreaBackdrop:SetBackdropColor(0.10, 0.10, 0.10, 1.00)
		topAreaBackdrop:SetBackdropBorderColor(0.28, 0.28, 0.28, 1.00)
		topAreaBackdrop:EnableMouse(false)
		topAreaBackdrop:SetFrameLevel(1)
	end

	local topWidgets = {
		getglobal("MTH_BOOK_StatsText"),
		getglobal("MTH_BOOK_SearchLabel"),
		getglobal("MTH_BOOK_MinLabel"),
		getglobal("MTH_BOOK_MaxLabel"),
		getglobal("MTH_BOOK_Search"),
		getglobal("MTH_BOOK_MinLevel"),
		getglobal("MTH_BOOK_MaxLevel"),
		getglobal("MTH_BOOK_ApplyButton"),
		getglobal("MTH_BOOK_ResetButton"),
		getglobal("MTH_BOOK_RequireVendor"),
		getglobal("MTH_BOOK_RequireDrop"),
		getglobal("MTH_BOOK_RequireObject"),
		getglobal("MTH_BOOK_AbilityDropdown"),
		getglobal("MTH_BOOK_RankDropdown"),
		getglobal("MTH_BOOK_PetLearnSourceDropdown"),
		getglobal("MTH_BOOK_ItemSubtypeDropdown"),
		getglobal("MTH_BOOK_PetBookScanButton"),
		getglobal("MTH_BOOK_NPCFunctionDropdown"),
		getglobal("MTH_BOOK_NPCZoneDropdown"),
		getglobal("MTH_BOOK_HideNoAbilities"),
		getglobal("MTH_BOOK_HideUnknown"),
		getglobal("MTH_BOOK_PetOnlyMyLevel"),
	}
	for i = 1, table.getn(topWidgets) do
		local widget = topWidgets[i]
		if widget and widget.Show then widget:Show() end
	end

	if listParent then
		listParent:SetBackdropColor(0.09, 0.09, 0.09, 1.00)
		listParent:SetBackdropBorderColor(0.24, 0.24, 0.24, 1.00)
		listParent:SetFrameLevel(2)
		if listParent.SetClipsChildren then listParent:SetClipsChildren(true) end
		if listSlider then
			listSlider:SetFrameStrata("HIGH")
			listSlider:SetFrameLevel(listParent:GetFrameLevel() + 8)
		end
		if sliderBackdrop then
			sliderBackdrop:SetFrameStrata("DIALOG")
			sliderBackdrop:SetFrameLevel(listParent:GetFrameLevel() + 6)
		end
		listParent:EnableMouseWheel(true)
		listParent:SetScript("OnMouseWheel", function()
			MTH_BOOK_ScrollPage(arg1)
		end)
		MTH_BOOK_CreateResultButtons(listParent)
	end

	if sliderBackdrop then
		sliderBackdrop:SetBackdropColor(0.01, 0.01, 0.01, 1.00)
		sliderBackdrop:SetBackdropBorderColor(0.30, 0.30, 0.30, 1.00)
		sliderBackdrop:EnableMouse(true)
		if listSlider then
			sliderBackdrop:SetScript("OnMouseDown", function()
				MTH_BOOK_STATE.sliderDragging = true
				MTH_BOOK_SetSliderFromCursor(listSlider)
			end)
			sliderBackdrop:SetScript("OnMouseUp", function()
				MTH_BOOK_SetSliderFromCursor(listSlider)
				MTH_BOOK_STATE.sliderDragging = false
			end)
			sliderBackdrop:SetScript("OnUpdate", function()
				if MTH_BOOK_STATE.sliderDragging then
					if IsMouseButtonDown and not IsMouseButtonDown("LeftButton") then
						MTH_BOOK_STATE.sliderDragging = false
					else
						MTH_BOOK_SetSliderFromCursor(listSlider)
					end
				end
			end)
		end
	end

	local detail = getglobal("MTH_BOOK_DetailBackdropDetailText")
	if detail then MTH_BOOK_ConfigureReadOnlyEditBox(detail) end

	if detailParent then
		detailParent:SetBackdropColor(0.09, 0.09, 0.09, 1.00)
		detailParent:SetBackdropBorderColor(0.24, 0.24, 0.24, 1.00)
		detailParent:SetFrameLevel(2)
		if detailParent.SetClipsChildren then detailParent:SetClipsChildren(true) end
	end

	if listParent and detailParent then
		MTH_BOOK_EnsurePetAbilitiesUI(listParent, detailParent)
		MTH_BOOK_SetPetAbilitiesUIVisible(false)
	end

	MTH_BOOK_UpdateModeLabels()
	MTH_BOOK_UpdateListHeaders()
	MTH_BOOK_SyncTopAreaColorWithSelectedTab()
	MTH_BOOK_UpdateSectionTabs()
	MTH_BOOK_UpdateOpenMapButton()
	if requireVendor then requireVendor:SetChecked(MTH_BOOK_STATE.flag1 and 1 or nil) end
	if requireDrop then requireDrop:SetChecked(MTH_BOOK_STATE.flag2 and 1 or nil) end
	if requireObject then requireObject:SetChecked(MTH_BOOK_STATE.flag3 and 1 or nil) end
	if hideNoAbilities then hideNoAbilities:SetChecked(MTH_BOOK_STATE.mode == "pets" and MTH_BOOK_STATE.petHideNoAbilities and 1 or nil) end
	if hideUnknown then hideUnknown:SetChecked(MTH_BOOK_STATE.mode == "pets" and MTH_BOOK_STATE.petHideUnknown and 1 or nil) end
	if petOnlyMyLevel then
		if MTH_BOOK_STATE.mode == "petabilities" then
			petOnlyMyLevel:SetChecked(MTH_BOOK_STATE.petOnlyMyLevel and 1 or nil)
		elseif MTH_BOOK_IsItemMode() then
			petOnlyMyLevel:SetChecked(MTH_BOOK_STATE.itemOnlyMyLevel and 1 or nil)
		else
			petOnlyMyLevel:SetChecked(nil)
		end
	end
	if petInZoneOnly then petInZoneOnly:SetChecked(MTH_BOOK_STATE.mode == "pets" and MTH_BOOK_STATE.petInZoneOnly and 1 or nil) end
	if npcInZoneOnly then npcInZoneOnly:SetChecked(MTH_BOOK_STATE.mode == "npcs" and MTH_BOOK_STATE.npcInZoneOnly and 1 or nil) end
end

local function MTH_BOOK_EnsureWindow()
	if MTH_BOOK_Browser then return MTH_BOOK_Browser end
	local frame = CreateFrame("Frame", "MTH_BOOK_", UIParent, "MTH_BOOK_Template")
	if not frame then
		MTH_HB_ReportGuard("Failed to create MTH_BOOK_ frame")
		return nil
	end
	if UISpecialFrames then
		local already = false
		for i = 1, table.getn(UISpecialFrames) do
			if UISpecialFrames[i] == "MTH_BOOK_" then
				already = true
				break
			end
		end
		if not already then
			table.insert(UISpecialFrames, "MTH_BOOK_")
		end
	end
	MTH_BOOK_Browser = frame
	MTH_BOOK_WireUI(frame)
	return frame
end

_G.MTH_BOOK_GetZoneName = MTH_BOOK_GetZoneName
_G.MTH_BOOK_GetPlayerLevelValue = MTH_BOOK_GetPlayerLevelValue
_G.MTH_BOOK_IsSpellInLevelScope = MTH_BOOK_IsSpellInLevelScope
_G.MTH_BOOK_GetScopedRankSummary = MTH_BOOK_GetScopedRankSummary
_G.MTH_BOOK_UpdateResults = MTH_BOOK_UpdateResults
_G.MTH_BOOK_RefreshFilter = MTH_BOOK_RefreshFilter

function MTH_OpenHunterBook()
	if not MTH_HB_RequireOpenDeps() then return end
	local frame = MTH_BOOK_EnsureWindow()
	if not frame then return end
	frame:Show()
	MTH_BOOK_RefreshFilter()
end

function MTH_ToggleHunterBook()
	if not MTH_HB_RequireOpenDeps() then return end
	local frame = MTH_BOOK_EnsureWindow()
	if not frame then return end
	if frame:IsShown() then
		frame:Hide()
	else
		frame:Show()
		MTH_BOOK_RefreshFilter()
	end
end

