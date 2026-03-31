local function zButtonTrack_GetRoot()
	return MTH_ZH_GetSavedRoot()
end

local root = zButtonTrack_GetRoot()
if not root["zButtonTrack"] then
	root["zButtonTrack"] = {}
	root["zButtonTrack"]["spells"] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12}
	root["zButtonTrack"]["rows"] = 1
	root["zButtonTrack"]["horizontal"] = nil
	root["zButtonTrack"]["vertical"] = nil
	root["zButtonTrack"]["firstbutton"] = "RIGHT"
	root["zButtonTrack"]["enabled"] = 1
	root["zButtonTrack"]["tooltip"] = 1
	root["zButtonTrack"]["parent"] = {}
	root["zButtonTrack"]["parent"]["size"] = 36
	root["zButtonTrack"]["parent"]["hide"] = nil
	root["zButtonTrack"]["parent"]["circle"] = 1
	root["zButtonTrack"]["children"] = {}
	root["zButtonTrack"]["children"]["size"] = 36
	root["zButtonTrack"]["children"]["hideonclick"] = 1
end

ZHunterMod_Track_Spells = {
	ZHUNTER_TRACK_HIDDEN,
	ZHUNTER_TRACK_HUMANOIDS,
	ZHUNTER_TRACK_UNDEAD,
	ZHUNTER_TRACK_BEASTS,
	ZHUNTER_TRACK_DEMONS,
	ZHUNTER_TRACK_ELEMENTALS,
	ZHUNTER_TRACK_DRAGONKIN,
	ZHUNTER_TRACK_GIANTS,
	ZHUNTER_TRACK_MINERALS,
	ZHUNTER_TRACK_HERBS,
	ZHUNTER_TRACK_TREASURE,
	ZHUNTER_TRACK_TREES
}

local ZHUNTER_TRACK_MAX = table.getn(ZHunterMod_Track_Spells)
local zButtonTrack_LastTrackingTexture = nil
local zButtonTrack_SyncActiveChild
local zButtonTrack_GetSaved

local function zButtonTrack_NormalizeTexture(texture)
	if not texture then
		return ""
	end
	local value = string.lower(tostring(texture))
	value = string.gsub(value, "\\", "/")
	local _, _, basename = string.find(value, "([^/]+)$")
	return basename or value
end

local function zButtonTrack_FindSpellIdByTrackingTexture(trackingTexture)
	if not trackingTexture or not zButtonTrack or not zButtonTrack.count then
		return nil
	end
	local wanted = zButtonTrack_NormalizeTexture(trackingTexture)
	for i = 1, zButtonTrack.count do
		local child = getglobal("zButtonTrack" .. i)
		if child and child.id then
			local spellTexture = GetSpellTexture and GetSpellTexture(child.id, "spell") or nil
			if zButtonTrack_NormalizeTexture(spellTexture) == wanted then
				return child.id
			end
			if child.icon and zButtonTrack_NormalizeTexture(child.icon) == wanted then
				return child.id
			end
			if child.icontexture and child.icontexture.GetTexture then
				local childTexture = child.icontexture:GetTexture()
				if zButtonTrack_NormalizeTexture(childTexture) == wanted then
					return child.id
				end
			end
		end
	end
	return nil
end

local function zButtonTrack_FindSpellIdByTrackingName(trackingName)
	if not trackingName or trackingName == "" or not zButtonTrack or not zButtonTrack.count then
		return nil
	end
	for i = 1, zButtonTrack.count do
		local child = getglobal("zButtonTrack" .. i)
		if child and child.id then
			local spellName = GetSpellName and GetSpellName(child.id, "spell") or nil
			if spellName == trackingName then
				return child.id
			end
		end
	end
	return nil
end

local function zButtonTrack_ScanBuffsForTrackingSpell()
	if not zButtonTrack or not zButtonTrack.count then
		return nil, nil
	end
	local childTextures = {}
	for i = 1, zButtonTrack.count do
		local child = getglobal("zButtonTrack" .. i)
		if child and child.id then
			local tex = GetSpellTexture and GetSpellTexture(child.id, "spell") or nil
			if tex then
				childTextures[tex] = child.id
			end
		end
	end
	local buffIndex = 1
	local buff = UnitBuff("player", buffIndex)
	while buff do
		if childTextures[buff] then
			return childTextures[buff], buff
		end
		buffIndex = buffIndex + 1
		buff = UnitBuff("player", buffIndex)
	end
	return nil, nil
end

local function zButtonTrack_GetActiveTrackingSpellId()
	local activeName = nil
	local activeTexture = nil
	if GetNumTrackingTypes and GetTrackingInfo then
		local numTracking = GetNumTrackingTypes() or 0
		for i = 1, numTracking do
			local name, texture, active = GetTrackingInfo(i)
			if active then
				activeName = name
				activeTexture = texture
				break
			end
		end
	end
	local byName = zButtonTrack_FindSpellIdByTrackingName(activeName)
	if byName then
		return byName, activeTexture
	end
	if activeTexture then
		local byTex = zButtonTrack_FindSpellIdByTrackingTexture(activeTexture)
		if byTex then
			return byTex, activeTexture
		end
	end
	-- Fallback: scan player buffs for tracking spell icon textures
	local buffId, buffTex = zButtonTrack_ScanBuffsForTrackingSpell()
	if buffId then
		return buffId, buffTex
	end
	return nil, nil
end

local function zButtonTrack_SmartParentId(activeChildId)
	local child1 = getglobal("zButtonTrack1")
	local child2 = getglobal("zButtonTrack2")
	if not child1 or not child1.id then return nil end
	if not child2 or not child2.id then return child1.id end
	if activeChildId == child1.id then return child2.id end
	return child1.id
end

local function zButtonTrack_AfterClick(button)
	if not zButtonTrack then
		return
	end
	if button and button.id then
		local saved = zButtonTrack_GetSaved()
		local newId
		if saved["parent"]["smart"] ~= false then
			newId = zButtonTrack_SmartParentId(button.id)
		else
			local firstChild = getglobal("zButtonTrack1")
			newId = firstChild and firstChild.id
		end
		if newId and newId ~= zButtonTrack.id then
			zButtonTrack.id = newId
			ZSpellButton_UpdateButton(zButtonTrack)
			ZSpellButton_UpdateCooldown(zButtonTrack)
		end
		zButtonTrack_SyncActiveChild(button.id)
		if GetSpellTexture then
			zButtonTrack_LastTrackingTexture = GetSpellTexture(button.id, "spell") or zButtonTrack_LastTrackingTexture
		end
		local isOwned = GameTooltip and GameTooltip.IsOwned and GameTooltip:IsOwned(zButtonTrack)
		if isOwned then
			ZSpellButtonParent_OnEnter(zButtonTrack)
		end
	end
end

zButtonTrack_SyncActiveChild = function(activeId)
	if not zButtonTrack or not zButtonTrack.count then
		return
	end
	for i = 1, zButtonTrack.count do
		local child = getglobal("zButtonTrack" .. i)
		if child and child.SetChecked then
			child:SetChecked((activeId and child.id == activeId) and 1 or 0)
		end
	end
	if zButtonTrack.SetChecked then
		zButtonTrack:SetChecked(0)
	end
end

local function zButtonTrack_RefreshTrackingState()
	if not zButtonTrack or not zButtonTrack.count then
		return
	end
	local saved = zButtonTrack_GetSaved()
	local firstChild = getglobal("zButtonTrack1")

	-- Smart OFF: always show first child
	if saved["parent"]["smart"] == false then
		if firstChild and firstChild.id and zButtonTrack.id ~= firstChild.id then
			zButtonTrack.id = firstChild.id
			ZSpellButton_UpdateButton(zButtonTrack)
			ZSpellButton_UpdateCooldown(zButtonTrack)
		end
		return
	end

	-- Smart ON: detect which tracking is active, show the OTHER one
	local activeId = zButtonTrack_GetActiveTrackingSpellId()
	local newId = zButtonTrack_SmartParentId(activeId)
	if not newId then
		newId = firstChild and firstChild.id
	end
	if not newId then return end

	-- Sync checked state on children
	zButtonTrack_SyncActiveChild(activeId)

	if zButtonTrack.id == newId then return end

	local isOwned = GameTooltip and GameTooltip.IsOwned and GameTooltip:IsOwned(zButtonTrack)
	zButtonTrack.id = newId
	ZSpellButton_UpdateButton(zButtonTrack)
	ZSpellButton_UpdateCooldown(zButtonTrack)
	if isOwned then
		ZSpellButtonParent_OnEnter(zButtonTrack)
	end
end

zButtonTrack_GetSaved = function()
	local currentRoot = zButtonTrack_GetRoot()
	if not currentRoot["zButtonTrack"] then
		currentRoot["zButtonTrack"] = {}
	end
	return currentRoot["zButtonTrack"]
end

local function zButtonTrack_EnsureConfig()
	local saved = zButtonTrack_GetSaved()
	saved["count"] = nil
	if saved["rows"] == nil then
		saved["rows"] = 1
	end
	if saved["firstbutton"] == nil then
		saved["firstbutton"] = "RIGHT"
	end
	if saved["enabled"] == nil then
		saved["enabled"] = 1
	end
	if saved["tooltip"] == nil then
		saved["tooltip"] = 1
	end
	if not saved["parent"] then
		saved["parent"] = {}
	end
	if saved["parent"]["size"] == nil then
		saved["parent"]["size"] = 36
	end
	if saved["parent"]["circle"] == nil then
		saved["parent"]["circle"] = 1
	end
	if saved["parent"]["smart"] == nil then
		saved["parent"]["smart"] = true
	end
	if not saved["children"] then
		saved["children"] = {}
	end
	if saved["children"]["size"] == nil then
		saved["children"]["size"] = 36
	end
	if saved["children"]["hideonclick"] == nil then
		saved["children"]["hideonclick"] = 1
	end
	if not saved["spells"] then
		saved["spells"] = {}
	end
	if not saved["visible"] then
		saved["visible"] = {}
	end
	for i = 1, ZHUNTER_TRACK_MAX do
		if not tonumber(saved["spells"][i]) then
			saved["spells"][i] = i
		end
		if saved["visible"][i] == nil then
			saved["visible"][i] = 1
		end
	end
end

local function zButtonTrack_ApplyRuntimeSettings()
	if not zButtonTrack then
		return
	end
	local saved = zButtonTrack_GetSaved()
	zButtonTrack.tooltip = saved["tooltip"] and true or false
	zButtonTrack.hideonclick = saved["children"] and saved["children"]["hideonclick"] and true or false
	zButtonTrack.expandonhover = saved["children"] and saved["children"]["expandonhover"] and true or false
	zButtonTrack.fadetimer = saved["children"] and tonumber(saved["children"]["fadetimer"]) or 0
end


function zButtonTrack_OnLoad()
	this:RegisterEvent("VARIABLES_LOADED")
end

function zButtonTrack_OnEvent()
	if event == "VARIABLES_LOADED" then
		if not zButtonTrack then
			return
		end
		if UnitClass("player") ~= ZHUNTER_HUNTER then
			zButtonTrack:UnregisterAllEvents()
			zButtonTrack:Hide()
			return
		end
		zButtonTrack_CreateButtons()
		zButtonTrack.afterclick = zButtonTrack_AfterClick
		MTH_ZH_TrackAdjust = CreateFrame("Frame", "MTH_ZH_TrackAdjust")
		MTH_ZH_TrackAdjust:RegisterEvent("MINIMAP_UPDATE_TRACKING")
		MTH_ZH_TrackAdjust:RegisterEvent("PLAYER_ENTERING_WORLD")
		MTH_ZH_TrackAdjust:RegisterEvent("SPELLS_CHANGED")
		MTH_ZH_TrackAdjust:RegisterEvent("CHARACTER_POINTS_CHANGED")
		MTH_ZH_TrackAdjust:RegisterEvent("LEARNED_SPELL_IN_TAB")
		MTH_ZH_TrackAdjust:SetScript("OnEvent", MTH_ZH_TrackAdjust_OnEvent)
		zButtonTrack_SetupSizeAndPosition()
	end
end

function zButtonTrack_CreateButtons()
	zButtonTrack_EnsureConfig()
	local saved = zButtonTrack_GetSaved()
	
	ZSpellButton_CreateChildren(zButtonTrack, "zButtonTrack", ZHUNTER_TRACK_MAX)
	local info = {}
	local infoIndex = 1
	for i=1, table.getn(ZHunterMod_Track_Spells) do
		if not tonumber(saved["spells"][i]) then
			info = ZHunterMod_Track_Spells
			saved["spells"] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11}
			break
		end
		local spellIndex = saved["spells"][i]
		if saved["visible"][spellIndex] ~= false then
			info[infoIndex] = ZHunterMod_Track_Spells[spellIndex]
			infoIndex = infoIndex + 1
		end
	end
	zButtonTrack.found = ZSpellButton_SetButtons(zButtonTrack, info)
	zButtonTrack_ApplyRuntimeSettings()
end

function zButtonTrack_SetupSizeAndPosition()
	zButtonTrack_EnsureConfig()
	local saved = zButtonTrack_GetSaved()
	if saved["enabled"] == false or saved["enabled"] == 0 then
		if MTH_ZH_TrackAdjust then
			MTH_ZH_TrackAdjust:UnregisterAllEvents()
			MTH_ZH_TrackAdjust:SetScript("OnEvent", nil)
		end
		if zButtonTrack and zButtonTrack.Hide then
			zButtonTrack:Hide()
		end
		return
	end
	if MTH_ZH_TrackAdjust then
		MTH_ZH_TrackAdjust:RegisterEvent("MINIMAP_UPDATE_TRACKING")
		MTH_ZH_TrackAdjust:RegisterEvent("PLAYER_AURAS_CHANGED")
		MTH_ZH_TrackAdjust:RegisterEvent("PLAYER_ENTERING_WORLD")
		MTH_ZH_TrackAdjust:RegisterEvent("SPELLS_CHANGED")
		MTH_ZH_TrackAdjust:RegisterEvent("CHARACTER_POINTS_CHANGED")
		MTH_ZH_TrackAdjust:RegisterEvent("LEARNED_SPELL_IN_TAB")
		MTH_ZH_TrackAdjust:SetScript("OnEvent", MTH_ZH_TrackAdjust_OnEvent)
	end
	local displayCount = zButtonTrack.found or ZHUNTER_TRACK_MAX
	if displayCount < 0 then
		displayCount = 0
	end
	if not (type(MTH_ZBar_ApplyToButton) == "function" and MTH_ZBar_ApplyToButton(zButtonTrack, displayCount)) then
		ZSpellButton_SetSize(zButtonTrack, saved["parent"]["size"])
		ZSpellButton_SetSize(zButtonTrack, saved["children"]["size"], 1)
		ZSpellButton_SetExpandDirection(zButtonTrack, saved["firstbutton"])
		ZSpellButton_ArrangeChildren(zButtonTrack, saved["rows"],
			displayCount, saved["horizontal"],
			saved["vertical"])
	end
	zButtonTrack_RefreshTrackingState()
end

function zButtonTrack_Reset()
	local currentRoot = zButtonTrack_GetRoot()
	currentRoot["zButtonTrack"] = {}
	local saved = zButtonTrack_GetSaved()
	saved["spells"] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11}
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
	saved["visible"] = {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1}
	zButtonTrack_EnsureConfig()
end

function MTH_ZH_TrackAdjust_OnEvent()
	if not zButtonTrack or not zButtonTrack.count then
		return
	end
	if event == "SPELLS_CHANGED" or event == "CHARACTER_POINTS_CHANGED" or event == "LEARNED_SPELL_IN_TAB" then
		zButtonTrack_CreateButtons()
		zButtonTrack_SetupSizeAndPosition()
	end
	if event == "MINIMAP_UPDATE_TRACKING" or event == "PLAYER_AURAS_CHANGED" or event == "PLAYER_ENTERING_WORLD"
		or event == "SPELLS_CHANGED" or event == "CHARACTER_POINTS_CHANGED" or event == "LEARNED_SPELL_IN_TAB" then
		zButtonTrack_RefreshTrackingState()
	end
end

function zButtonTrack_KeyBinding(index)
	if MTH_ZH_IsModuleEnabled and not MTH_ZH_IsModuleEnabled() then
		return
	end

	local button
	if index then
		button = getglobal("zButtonTrack"..index)
		else
		button = zButtonTrack
		end
	if button.id then
		CastSpell(button.id, "spell")
		if zButtonTrack.hideonclick then
			if type(ZSpellButton_SetChildrenExpanded) == "function" then
				ZSpellButton_SetChildrenExpanded(zButtonTrack, false)
			elseif zButtonTrack.children then
				zButtonTrack.children:Hide()
			end
		end
	end
end

SLASH_zButtonTrack1 = "/ZTrack"
SlashCmdList["zButtonTrack"] = function(msg)
	if MTH_ZH_HandleDisabledSlash and MTH_ZH_HandleDisabledSlash("Track button is disabled while module 'zhunter' is disabled.") then
		return
	end
	msg = tostring(msg or "")
	if msg == "reset" then
		zButtonTrack_Reset()
		zButtonTrack:ClearAllPoints()
		zButtonTrack:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
	elseif msg == "options" then
		MTH_OpenOptions("Track")
	else
		MTH_ZH_Print("Possible Commands: \"options\", \"reset\"")
	end
end