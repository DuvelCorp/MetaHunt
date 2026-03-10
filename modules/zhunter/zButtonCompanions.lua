local function zButtonCompanions_GetRoot()
	return MTH_ZH_GetSavedRoot()
end

local root = zButtonCompanions_GetRoot()
if not root["zButtonCompanions"] then
	root["zButtonCompanions"] = {}
	root["zButtonCompanions"]["spells"] = {}
	root["zButtonCompanions"]["rows"] = 1
	root["zButtonCompanions"]["horizontal"] = nil
	root["zButtonCompanions"]["vertical"] = nil
	root["zButtonCompanions"]["firstbutton"] = "RIGHT"
	root["zButtonCompanions"]["enabled"] = 0
	root["zButtonCompanions"]["tooltip"] = 1
	root["zButtonCompanions"]["parent"] = {}
	root["zButtonCompanions"]["parent"]["size"] = 36
	root["zButtonCompanions"]["parent"]["hide"] = nil
	root["zButtonCompanions"]["parent"]["circle"] = 1
	root["zButtonCompanions"]["children"] = {}
	root["zButtonCompanions"]["children"]["size"] = 36
	root["zButtonCompanions"]["children"]["hideonclick"] = 1
end

local ZHUNTER_COMPANIONS_BUTTON_MAX = 80
local zButtonCompanions_LastSpellSignature = nil
local zButtonCompanions_LastRefreshAt = 0
local zButtonCompanions_MinRefreshInterval = 0.50

local function zButtonCompanions_GetSpellSignature(spellIds)
	if type(spellIds) ~= "table" or table.getn(spellIds) == 0 then
		return ""
	end
	local parts = {}
	for i = 1, table.getn(spellIds) do
		parts[i] = tostring(spellIds[i] or "")
	end
	return table.concat(parts, ",")
end

local function zButtonCompanions_GetSaved()
	local currentRoot = zButtonCompanions_GetRoot()
	if not currentRoot["zButtonCompanions"] then
		currentRoot["zButtonCompanions"] = {}
	end
	return currentRoot["zButtonCompanions"]
end

local function zButtonCompanions_EnsureConfig()
	local saved = zButtonCompanions_GetSaved()
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

local function zButtonCompanions_ApplyRuntimeSettings()
	if not zButtonCompanions then
		return
	end
	local saved = zButtonCompanions_GetSaved()
	zButtonCompanions.tooltip = saved["tooltip"] and true or false
	zButtonCompanions.hideonclick = saved["children"] and saved["children"]["hideonclick"] and true or false
	zButtonCompanions.expandonhover = saved["children"] and saved["children"]["expandonhover"] and true or false
	zButtonCompanions.fadetimer = saved["children"] and tonumber(saved["children"]["fadetimer"]) or 0
end

local function zButtonCompanions_NormalizeTabName(value)
	local text = string.lower(tostring(value or ""))
	text = string.gsub(text, "%s+", "")
	text = string.gsub(text, "[^%a]", "")
	while string.sub(text, 1, 1) == "z" and string.len(text) > 1 do
		text = string.sub(text, 2)
	end
	return text
end

local function zButtonCompanions_FindTabBounds()
	if type(GetNumSpellTabs) ~= "function" or type(GetSpellTabInfo) ~= "function" then
		return nil, nil
	end
	local tabCount = GetNumSpellTabs() or 0
	for tabIndex = 1, tabCount do
		local tabName, _, tabOffset, tabEntries = GetSpellTabInfo(tabIndex)
		local normalized = zButtonCompanions_NormalizeTabName(tabName)
		if string.find(normalized, "companion", 1, true) or string.find(normalized, "minipet", 1, true) then
			return tonumber(tabOffset) or 0, tonumber(tabEntries) or 0
		end
	end
	return nil, nil
end

local function zButtonCompanions_CollectTabSpellIds()
	local tabOffset, tabEntries = zButtonCompanions_FindTabBounds()
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

local function zButtonCompanions_ApplySpellIds(spellIds)
	if not zButtonCompanions then
		return 0
	end

	local parent = zButtonCompanions
	local childCount = parent.count or ZHUNTER_COMPANIONS_BUTTON_MAX

	for i = 1, childCount do
		local child = getglobal("zButtonCompanions" .. i)
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
			local child = getglobal("zButtonCompanions" .. found)
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

local function zButtonCompanions_RefreshSpells()
	if not zButtonCompanions then
		return 0
	end
	local saved = zButtonCompanions_GetSaved()
	local spellIds = zButtonCompanions_CollectTabSpellIds()
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
	zButtonCompanions.spells = spellNames
	zButtonCompanions.found = zButtonCompanions_ApplySpellIds(spellIds)
	zButtonCompanions_ApplyRuntimeSettings()
	return zButtonCompanions.found or 0
end

function zButtonCompanions_OnLoad()
	this:RegisterEvent("VARIABLES_LOADED")
end

function zButtonCompanions_OnEvent()
	if event == "VARIABLES_LOADED" then
		if not zButtonCompanions then
			return
		end
		if UnitClass("player") ~= ZHUNTER_HUNTER then
			zButtonCompanions:UnregisterAllEvents()
			zButtonCompanions:Hide()
			return
		end
		zButtonCompanions_CreateButtons()
		MTH_ZH_CompanionsAdjust = CreateFrame("Frame", "MTH_ZH_CompanionsAdjust")
		MTH_ZH_CompanionsAdjust:RegisterEvent("SPELLS_CHANGED")
		MTH_ZH_CompanionsAdjust:RegisterEvent("PLAYER_ENTERING_WORLD")
		MTH_ZH_CompanionsAdjust:SetScript("OnEvent", MTH_ZH_CompanionsAdjust_OnEvent)
		zButtonCompanions_SetupSizeAndPosition()
	end
end

function zButtonCompanions_CreateButtons()
	zButtonCompanions_EnsureConfig()

	if not zButtonCompanions._mthChildrenCreated then
		ZSpellButton_CreateChildren(zButtonCompanions, "zButtonCompanions", ZHUNTER_COMPANIONS_BUTTON_MAX)
		zButtonCompanions._mthChildrenCreated = 1
	end

	zButtonCompanions_RefreshSpells()
end

function zButtonCompanions_SetupSizeAndPosition()
	local saved = zButtonCompanions_GetSaved()
	if saved["enabled"] == false or saved["enabled"] == 0 then
		if MTH_ZH_CompanionsAdjust and MTH_ZH_CompanionsAdjust.SetScript then
			MTH_ZH_CompanionsAdjust:SetScript("OnEvent", nil)
		end
		if zButtonCompanions and zButtonCompanions.Hide then
			zButtonCompanions:Hide()
		end
		return
	end
	if MTH_ZH_CompanionsAdjust and MTH_ZH_CompanionsAdjust.SetScript then
		MTH_ZH_CompanionsAdjust:SetScript("OnEvent", MTH_ZH_CompanionsAdjust_OnEvent)
	end
	local displayCount = zButtonCompanions.found or 0
	if displayCount < 0 then
		displayCount = 0
	end
	ZSpellButton_SetSize(zButtonCompanions, saved["parent"]["size"])
	ZSpellButton_SetSize(zButtonCompanions, saved["children"]["size"], 1)
	ZSpellButton_SetExpandDirection(zButtonCompanions, saved["firstbutton"])
	ZSpellButton_ArrangeChildren(zButtonCompanions, saved["rows"], 
		displayCount, saved["horizontal"],
		saved["vertical"])
end

function zButtonCompanions_Reset()
	local currentRoot = zButtonCompanions_GetRoot()
	currentRoot["zButtonCompanions"] = {}
	local saved = zButtonCompanions_GetSaved()
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
	zButtonCompanions_EnsureConfig()
end

function MTH_ZH_CompanionsAdjust_OnEvent()
	if not zButtonCompanions then
		return
	end
	if event == "SPELLS_CHANGED" then
		local now = GetTime and GetTime() or 0
		if now > 0 and zButtonCompanions_LastRefreshAt > 0 and (now - zButtonCompanions_LastRefreshAt) < zButtonCompanions_MinRefreshInterval then
			return
		end
		local signature = zButtonCompanions_GetSpellSignature(zButtonCompanions_CollectTabSpellIds())
		if signature == zButtonCompanions_LastSpellSignature and not GameTooltip:IsOwned(zButtonCompanions) then
			return
		end
		zButtonCompanions_LastSpellSignature = signature
		zButtonCompanions_LastRefreshAt = now
	end
	zButtonCompanions_RefreshSpells()
	zButtonCompanions_SetupSizeAndPosition()
	if GameTooltip:IsOwned(zButtonCompanions) then
		ZSpellButtonParent_OnEnter(zButtonCompanions)
	end
end

function zButtonCompanions_KeyBinding(index)
	if MTH_ZH_IsModuleEnabled and not MTH_ZH_IsModuleEnabled() then
		return
	end

	local button
	if index then
		button = getglobal("zButtonCompanions"..index)
	else
		button = zButtonCompanions
	end
	if button and button.id then
		CastSpell(button.id, "spell")
		if zButtonCompanions.hideonclick then
			if type(ZSpellButton_SetChildrenExpanded) == "function" then
				ZSpellButton_SetChildrenExpanded(zButtonCompanions, false)
			elseif zButtonCompanions.children then
				zButtonCompanions.children:Hide()
			end
		end
	end
end

SLASH_zButtonCompanions1 = "/ZCompanions"
SLASH_zButtonCompanions2 = "/ZMinipets"
SlashCmdList["zButtonCompanions"] = function(msg)
	if MTH_ZH_HandleDisabledSlash and MTH_ZH_HandleDisabledSlash("Companions button is disabled while module 'zhunter' is disabled.") then
		return
	end
	if msg == "reset" then
		zButtonCompanions_Reset()
		zButtonCompanions:ClearAllPoints()
		zButtonCompanions:SetPoint("TOP", UIParent, "TOP", 0, -464)
		zButtonCompanions_RefreshSpells()
		zButtonCompanions_SetupSizeAndPosition()
	else
		MTH_ZH_Print("Possible Commands: \"reset\"")
	end
end
