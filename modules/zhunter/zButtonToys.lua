local function zButtonToys_GetRoot()
	return MTH_ZH_GetSavedRoot()
end

local root = zButtonToys_GetRoot()
if not root["zButtonToys"] then
	root["zButtonToys"] = {}
	root["zButtonToys"]["spells"] = {}
	root["zButtonToys"]["rows"] = 1
	root["zButtonToys"]["horizontal"] = nil
	root["zButtonToys"]["vertical"] = nil
	root["zButtonToys"]["firstbutton"] = "RIGHT"
	root["zButtonToys"]["enabled"] = 0
	root["zButtonToys"]["tooltip"] = 1
	root["zButtonToys"]["parent"] = {}
	root["zButtonToys"]["parent"]["size"] = 36
	root["zButtonToys"]["parent"]["hide"] = nil
	root["zButtonToys"]["parent"]["circle"] = 1
	root["zButtonToys"]["children"] = {}
	root["zButtonToys"]["children"]["size"] = 36
	root["zButtonToys"]["children"]["hideonclick"] = 1
end

local ZHUNTER_TOYS_BUTTON_MAX = 80
local zButtonToys_LastSpellSignature = nil
local zButtonToys_LastRefreshAt = 0
local zButtonToys_MinRefreshInterval = 0.50

local function zButtonToys_GetSpellSignature(spellIds)
	if type(spellIds) ~= "table" or table.getn(spellIds) == 0 then
		return ""
	end
	local parts = {}
	for i = 1, table.getn(spellIds) do
		parts[i] = tostring(spellIds[i] or "")
	end
	return table.concat(parts, ",")
end

local function zButtonToys_GetSaved()
	local currentRoot = zButtonToys_GetRoot()
	if not currentRoot["zButtonToys"] then
		currentRoot["zButtonToys"] = {}
	end
	return currentRoot["zButtonToys"]
end

local function zButtonToys_EnsureConfig()
	local saved = zButtonToys_GetSaved()
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

local function zButtonToys_ApplyRuntimeSettings()
	if not zButtonToys then
		return
	end
	local saved = zButtonToys_GetSaved()
	zButtonToys.tooltip = saved["tooltip"] and true or false
	zButtonToys.hideonclick = saved["children"] and saved["children"]["hideonclick"] and true or false
	zButtonToys.expandonhover = saved["children"] and saved["children"]["expandonhover"] and true or false
	zButtonToys.fadetimer = saved["children"] and tonumber(saved["children"]["fadetimer"]) or 0
end

local function zButtonToys_NormalizeTabName(value)
	local text = string.lower(tostring(value or ""))
	text = string.gsub(text, "%s+", "")
	text = string.gsub(text, "[^%a]", "")
	while string.sub(text, 1, 1) == "z" and string.len(text) > 1 do
		text = string.sub(text, 2)
	end
	return text
end

local function zButtonToys_FindTabBounds()
	if type(GetNumSpellTabs) ~= "function" or type(GetSpellTabInfo) ~= "function" then
		return nil, nil
	end
	local tabCount = GetNumSpellTabs() or 0
	for tabIndex = 1, tabCount do
		local tabName, _, tabOffset, tabEntries = GetSpellTabInfo(tabIndex)
		local normalized = zButtonToys_NormalizeTabName(tabName)
		if string.find(normalized, "toy", 1, true) then
			return tonumber(tabOffset) or 0, tonumber(tabEntries) or 0
		end
	end
	return nil, nil
end

local function zButtonToys_CollectTabSpellIds()
	local tabOffset, tabEntries = zButtonToys_FindTabBounds()
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

local function zButtonToys_ApplySpellIds(spellIds)
	if not zButtonToys then
		return 0
	end

	local parent = zButtonToys
	local childCount = parent.count or ZHUNTER_TOYS_BUTTON_MAX

	for i = 1, childCount do
		local child = getglobal("zButtonToys" .. i)
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
			local child = getglobal("zButtonToys" .. found)
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

local function zButtonToys_RefreshSpells()
	if not zButtonToys then
		return 0
	end
	local saved = zButtonToys_GetSaved()
	local spellIds = zButtonToys_CollectTabSpellIds()
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
	zButtonToys.spells = spellNames
	zButtonToys.found = zButtonToys_ApplySpellIds(spellIds)
	zButtonToys_ApplyRuntimeSettings()
	return zButtonToys.found or 0
end

function zButtonToys_OnLoad()
	this:RegisterEvent("VARIABLES_LOADED")
end

function zButtonToys_OnEvent()
	if event == "VARIABLES_LOADED" then
		if not zButtonToys then
			return
		end
		if UnitClass("player") ~= ZHUNTER_HUNTER then
			zButtonToys:UnregisterAllEvents()
			zButtonToys:Hide()
			return
		end
		zButtonToys_CreateButtons()
		MTH_ZH_ToysAdjust = CreateFrame("Frame", "MTH_ZH_ToysAdjust")
		MTH_ZH_ToysAdjust:RegisterEvent("SPELLS_CHANGED")
		MTH_ZH_ToysAdjust:RegisterEvent("PLAYER_ENTERING_WORLD")
		MTH_ZH_ToysAdjust:SetScript("OnEvent", MTH_ZH_ToysAdjust_OnEvent)
		zButtonToys_SetupSizeAndPosition()
	end
end

function zButtonToys_CreateButtons()
	zButtonToys_EnsureConfig()

	if not zButtonToys._mthChildrenCreated then
		ZSpellButton_CreateChildren(zButtonToys, "zButtonToys", ZHUNTER_TOYS_BUTTON_MAX)
		zButtonToys._mthChildrenCreated = 1
	end

	zButtonToys_RefreshSpells()
end

function zButtonToys_SetupSizeAndPosition()
	local saved = zButtonToys_GetSaved()
	if saved["enabled"] == false or saved["enabled"] == 0 then
		if MTH_ZH_ToysAdjust and MTH_ZH_ToysAdjust.SetScript then
			MTH_ZH_ToysAdjust:SetScript("OnEvent", nil)
		end
		if zButtonToys and zButtonToys.Hide then
			zButtonToys:Hide()
		end
		return
	end
	if MTH_ZH_ToysAdjust and MTH_ZH_ToysAdjust.SetScript then
		MTH_ZH_ToysAdjust:SetScript("OnEvent", MTH_ZH_ToysAdjust_OnEvent)
	end
	local displayCount = zButtonToys.found or 0
	if displayCount < 0 then
		displayCount = 0
	end
	ZSpellButton_SetSize(zButtonToys, saved["parent"]["size"])
	ZSpellButton_SetSize(zButtonToys, saved["children"]["size"], 1)
	ZSpellButton_SetExpandDirection(zButtonToys, saved["firstbutton"])
	ZSpellButton_ArrangeChildren(zButtonToys, saved["rows"], 
		displayCount, saved["horizontal"],
		saved["vertical"])
end

function zButtonToys_Reset()
	local currentRoot = zButtonToys_GetRoot()
	currentRoot["zButtonToys"] = {}
	local saved = zButtonToys_GetSaved()
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
	zButtonToys_EnsureConfig()
end

function MTH_ZH_ToysAdjust_OnEvent()
	if not zButtonToys then
		return
	end
	if event == "SPELLS_CHANGED" then
		local now = GetTime and GetTime() or 0
		if now > 0 and zButtonToys_LastRefreshAt > 0 and (now - zButtonToys_LastRefreshAt) < zButtonToys_MinRefreshInterval then
			return
		end
		local signature = zButtonToys_GetSpellSignature(zButtonToys_CollectTabSpellIds())
		if signature == zButtonToys_LastSpellSignature and not GameTooltip:IsOwned(zButtonToys) then
			return
		end
		zButtonToys_LastSpellSignature = signature
		zButtonToys_LastRefreshAt = now
	end
	zButtonToys_RefreshSpells()
	zButtonToys_SetupSizeAndPosition()
	if GameTooltip:IsOwned(zButtonToys) then
		ZSpellButtonParent_OnEnter(zButtonToys)
	end
end

function zButtonToys_KeyBinding(index)
	if MTH_ZH_IsModuleEnabled and not MTH_ZH_IsModuleEnabled() then
		return
	end

	local button
	if index then
		button = getglobal("zButtonToys"..index)
	else
		button = zButtonToys
	end
	if button and button.id then
		CastSpell(button.id, "spell")
		if zButtonToys.hideonclick then
			if type(ZSpellButton_SetChildrenExpanded) == "function" then
				ZSpellButton_SetChildrenExpanded(zButtonToys, false)
			elseif zButtonToys.children then
				zButtonToys.children:Hide()
			end
		end
	end
end

SLASH_zButtonToys1 = "/ZToys"
SlashCmdList["zButtonToys"] = function(msg)
	if MTH_ZH_HandleDisabledSlash and MTH_ZH_HandleDisabledSlash("Toys button is disabled while module 'zhunter' is disabled.") then
		return
	end
	if msg == "reset" then
		zButtonToys_Reset()
		zButtonToys:ClearAllPoints()
		zButtonToys:SetPoint("TOP", UIParent, "TOP", 0, -518)
		zButtonToys_RefreshSpells()
		zButtonToys_SetupSizeAndPosition()
	else
		MTH_ZH_Print("Possible Commands: \"reset\"")
	end
end
