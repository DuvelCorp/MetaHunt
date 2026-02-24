local function zButtonMounts_GetRoot()
	return MTH_ZH_GetSavedRoot()
end

local root = zButtonMounts_GetRoot()
if not root["zButtonMounts"] then
	root["zButtonMounts"] = {}
	root["zButtonMounts"]["spells"] = {}
	root["zButtonMounts"]["rows"] = 1
	root["zButtonMounts"]["horizontal"] = nil
	root["zButtonMounts"]["vertical"] = nil
	root["zButtonMounts"]["firstbutton"] = "RIGHT"
	root["zButtonMounts"]["enabled"] = 0
	root["zButtonMounts"]["tooltip"] = 1
	root["zButtonMounts"]["parent"] = {}
	root["zButtonMounts"]["parent"]["size"] = 36
	root["zButtonMounts"]["parent"]["hide"] = nil
	root["zButtonMounts"]["parent"]["circle"] = 1
	root["zButtonMounts"]["children"] = {}
	root["zButtonMounts"]["children"]["size"] = 36
	root["zButtonMounts"]["children"]["hideonclick"] = 1
end

local ZHUNTER_MOUNTS_BUTTON_MAX = 80

local function zButtonMounts_GetSaved()
	local currentRoot = zButtonMounts_GetRoot()
	if not currentRoot["zButtonMounts"] then
		currentRoot["zButtonMounts"] = {}
	end
	return currentRoot["zButtonMounts"]
end

local function zButtonMounts_EnsureConfig()
	local saved = zButtonMounts_GetSaved()
	saved["count"] = nil
	if saved["enabled"] == nil then
		saved["enabled"] = 0
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
	if not saved["parent"] then
		saved["parent"] = {}
	end
	if not saved["children"] then
		saved["children"] = {}
	end
	if not saved["parent"]["size"] then
		saved["parent"]["size"] = 36
	end
	if saved["parent"]["circle"] == nil then
		saved["parent"]["circle"] = 1
	end
	if not saved["children"]["size"] then
		saved["children"]["size"] = 36
	end
	if not saved["rows"] or saved["rows"] < 1 then
		saved["rows"] = 1
	end
	if not saved["firstbutton"] then
		saved["firstbutton"] = "RIGHT"
	end
end

local function zButtonMounts_ApplyRuntimeSettings()
	if not zButtonMounts then
		return
	end
	local saved = zButtonMounts_GetSaved()
	zButtonMounts.tooltip = saved["tooltip"] and true or false
	zButtonMounts.hideonclick = saved["children"] and saved["children"]["hideonclick"] and true or false
end

local function zButtonMounts_NormalizeTabName(value)
	local text = string.lower(tostring(value or ""))
	text = string.gsub(text, "%s+", "")
	text = string.gsub(text, "[^%a]", "")
	while string.sub(text, 1, 1) == "z" and string.len(text) > 1 do
		text = string.sub(text, 2)
	end
	return text
end

local function zButtonMounts_FindTabBounds()
	if type(GetNumSpellTabs) ~= "function" or type(GetSpellTabInfo) ~= "function" then
		return nil, nil
	end
	local tabCount = GetNumSpellTabs() or 0
	for tabIndex = 1, tabCount do
		local tabName, _, tabOffset, tabEntries = GetSpellTabInfo(tabIndex)
		local normalized = zButtonMounts_NormalizeTabName(tabName)
		if string.find(normalized, "mount", 1, true) then
			return tonumber(tabOffset) or 0, tonumber(tabEntries) or 0
		end
	end
	return nil, nil
end

local function zButtonMounts_CollectTabSpellIds()
	local tabOffset, tabEntries = zButtonMounts_FindTabBounds()
	if not tabOffset or not tabEntries or tabEntries <= 0 then
		return {}
	end

	local spellIds = {}
	local bookType = BOOKTYPE_SPELL or "spell"
	local maxIndex = tabOffset + tabEntries
	for spellIndex = tabOffset + 1, maxIndex do
		local spellName = GetSpellName(spellIndex, bookType)
		if spellName and spellName ~= "" then
			table.insert(spellIds, spellIndex)
		end
	end
	return spellIds
end

local function zButtonMounts_ApplySpellIds(spellIds)
	if not zButtonMounts then
		return 0
	end

	local parent = zButtonMounts
	local childCount = parent.count or ZHUNTER_MOUNTS_BUTTON_MAX

	for i = 1, childCount do
		local child = getglobal("zButtonMounts" .. i)
		if child then
			child:Hide()
			child.id = nil
			child.icon = nil
			child.isspell = nil
		end
	end

	local found = 0
	for i = 1, table.getn(spellIds) do
		if found >= childCount then
			break
		end
		local spellId = spellIds[i]
		if spellId then
			found = found + 1
			local child = getglobal("zButtonMounts" .. found)
			if child then
				child.id = spellId
				child.isspell = 1
				ZSpellButton_UpdateButton(child)
				child:Show()
			end
		end
	end

	if found > 0 then
		parent.id = spellIds[1]
		parent.isspell = 1
		ZSpellButton_UpdateButton(parent)
		parent:Enable()
		parent:Show()
	else
		parent.id = nil
		parent:Hide()
	end

	return found
end

local function zButtonMounts_RefreshSpells()
	if not zButtonMounts then
		return 0
	end
	local saved = zButtonMounts_GetSaved()
	local spellIds = zButtonMounts_CollectTabSpellIds()
	local spellNames = {}
	local bookType = BOOKTYPE_SPELL or "spell"
	for i = 1, table.getn(spellIds) do
		local n = GetSpellName(spellIds[i], bookType)
		if n and n ~= "" then
			table.insert(spellNames, n)
		end
	end
	saved["spellIds"] = spellIds
	saved["spells"] = spellNames
	zButtonMounts.spells = spellNames
	zButtonMounts.found = zButtonMounts_ApplySpellIds(spellIds)
	zButtonMounts_ApplyRuntimeSettings()
	return zButtonMounts.found or 0
end

function zButtonMounts_OnLoad()
	this:RegisterEvent("VARIABLES_LOADED")
end

function zButtonMounts_OnEvent()
	if event == "VARIABLES_LOADED" then
		if not zButtonMounts then
			return
		end
		if UnitClass("player") ~= ZHUNTER_HUNTER then
			zButtonMounts:UnregisterAllEvents()
			zButtonMounts:Hide()
			return
		end
		zButtonMounts_CreateButtons()
		zButtonMountsAdjustment = CreateFrame("Frame", "zButtonMountsAdjustment")
		zButtonMountsAdjustment:RegisterEvent("SPELLS_CHANGED")
		zButtonMountsAdjustment:RegisterEvent("PLAYER_ENTERING_WORLD")
		zButtonMountsAdjustment:SetScript("OnEvent", zButtonMountsAdjustment_OnEvent)
		zButtonMounts_SetupSizeAndPosition()
	end
end

function zButtonMounts_CreateButtons()
	zButtonMounts_EnsureConfig()

	if not zButtonMounts._mthChildrenCreated then
		ZSpellButton_CreateChildren(zButtonMounts, "zButtonMounts", ZHUNTER_MOUNTS_BUTTON_MAX)
		zButtonMounts._mthChildrenCreated = 1
	end

	zButtonMounts_RefreshSpells()
end

function zButtonMounts_SetupSizeAndPosition()
	local saved = zButtonMounts_GetSaved()
	if saved["enabled"] == false or saved["enabled"] == 0 then
		if zButtonMounts and zButtonMounts.Hide then
			zButtonMounts:Hide()
		end
		return
	end
	local displayCount = zButtonMounts.found or 0
	if displayCount < 0 then
		displayCount = 0
	end
	ZSpellButton_SetSize(zButtonMounts, saved["parent"]["size"])
	ZSpellButton_SetSize(zButtonMounts, saved["children"]["size"], 1)
	ZSpellButton_SetExpandDirection(zButtonMounts, saved["firstbutton"])
	ZSpellButton_ArrangeChildren(zButtonMounts, saved["rows"], 
		displayCount, saved["horizontal"],
		saved["vertical"])
end

function zButtonMounts_Reset()
	local currentRoot = zButtonMounts_GetRoot()
	currentRoot["zButtonMounts"] = {}
	local saved = zButtonMounts_GetSaved()
	saved["spells"] = {}
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
	zButtonMounts_EnsureConfig()
end

function zButtonMountsAdjustment_OnEvent()
	if not zButtonMounts then
		return
	end
	zButtonMounts_RefreshSpells()
	zButtonMounts_SetupSizeAndPosition()
	if GameTooltip:IsOwned(zButtonMounts) then
		ZSpellButtonParent_OnEnter(zButtonMounts)
	end
end

function zButtonMounts_KeyBinding(index)
	if MTH_ZH_IsModuleEnabled and not MTH_ZH_IsModuleEnabled() then
		return
	end

	local button
	if index then
		button = getglobal("zButtonMounts"..index)
	else
		button = zButtonMounts
	end
	if button and button.id then
		CastSpell(button.id, "spell")
		if zButtonMounts.hideonclick then
			if type(ZSpellButton_SetChildrenExpanded) == "function" then
				ZSpellButton_SetChildrenExpanded(zButtonMounts, false)
			elseif zButtonMounts.children then
				zButtonMounts.children:Hide()
			end
		end
	end
end

SLASH_zButtonMounts1 = "/ZMounts"
SlashCmdList["zButtonMounts"] = function(msg)
	if MTH_ZH_HandleDisabledSlash and MTH_ZH_HandleDisabledSlash("Mounts button is disabled while module 'zhunter' is disabled.") then
		return
	end
	if msg == "reset" then
		zButtonMounts_Reset()
		zButtonMounts:ClearAllPoints()
		zButtonMounts:SetPoint("TOP", UIParent, "TOP", 0, -410)
		zButtonMounts_RefreshSpells()
		zButtonMounts_SetupSizeAndPosition()
	else
		MTH_ZH_Print("Possible Commands: \"reset\"")
	end
end
