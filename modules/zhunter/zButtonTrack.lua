local function zButtonTrack_GetRoot()
	return MTH_ZH_GetSavedRoot()
end

local root = zButtonTrack_GetRoot()
if not root["zButtonTrack"] then
	root["zButtonTrack"] = {}
	root["zButtonTrack"]["spells"] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11}
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
	ZHUNTER_TRACK_TREASURE
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
		return zButtonTrack_FindSpellIdByTrackingTexture(activeTexture), activeTexture
	end
	local buff = GetTrackingTexture and GetTrackingTexture() or nil
	return zButtonTrack_FindSpellIdByTrackingTexture(buff), buff
end

local function zButtonTrack_AfterClick(button)
	if not zButtonTrack then
		return
	end
	if button and button.id then
		zButtonTrack.id = button.id
		ZSpellButton_UpdateButton(zButtonTrack)
		ZSpellButton_UpdateCooldown(zButtonTrack)
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
	local newId, trackingTexture = zButtonTrack_GetActiveTrackingSpellId()
	local buff = trackingTexture or (GetTrackingTexture and GetTrackingTexture() or nil)
	if not newId and not buff then
		if zButtonTrack.id then
			zButtonTrack_SyncActiveChild(zButtonTrack.id)
		else
			zButtonTrack_LastTrackingTexture = nil
			zButtonTrack_SyncActiveChild(nil)
		end
		return
	end
	if not newId then
		newId = zButtonTrack.id or nil
	end
	if not newId then
		return
	end
	if zButtonTrack_NormalizeTexture(zButtonTrack_LastTrackingTexture) == zButtonTrack_NormalizeTexture(buff) and zButtonTrack.id == newId then
		zButtonTrack_SyncActiveChild(newId)
		return
	end

	local isOwned = GameTooltip and GameTooltip.IsOwned and GameTooltip:IsOwned(zButtonTrack)
	zButtonTrack_LastTrackingTexture = buff
	zButtonTrack.id = newId
	ZSpellButton_UpdateButton(zButtonTrack)
	ZSpellButton_UpdateCooldown(zButtonTrack)
	zButtonTrack_SyncActiveChild(newId)
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
		zButtonTrackAdjustment = CreateFrame("Frame", "zButtonTrackAdjustment")
		zButtonTrackAdjustment:RegisterEvent("MINIMAP_UPDATE_TRACKING")
		zButtonTrackAdjustment:RegisterEvent("PLAYER_ENTERING_WORLD")
		zButtonTrackAdjustment:RegisterEvent("SPELLS_CHANGED")
		zButtonTrackAdjustment:RegisterEvent("CHARACTER_POINTS_CHANGED")
		zButtonTrackAdjustment:RegisterEvent("LEARNED_SPELL_IN_TAB")
		zButtonTrackAdjustment:SetScript("OnEvent", zButtonTrackAdjustment_OnEvent)
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
		if zButtonTrackAdjustment and zButtonTrackAdjustment.SetScript then
			zButtonTrackAdjustment:SetScript("OnEvent", nil)
		end
		if zButtonTrack and zButtonTrack.Hide then
			zButtonTrack:Hide()
		end
		return
	end
	if zButtonTrackAdjustment and zButtonTrackAdjustment.SetScript then
		zButtonTrackAdjustment:SetScript("OnEvent", zButtonTrackAdjustment_OnEvent)
	end
	local displayCount = zButtonTrack.found or ZHUNTER_TRACK_MAX
	if displayCount < 0 then
		displayCount = 0
	end
	ZSpellButton_SetSize(zButtonTrack, saved["parent"]["size"])
	ZSpellButton_SetSize(zButtonTrack, saved["children"]["size"], 1)
	ZSpellButton_SetExpandDirection(zButtonTrack, saved["firstbutton"])
	ZSpellButton_ArrangeChildren(zButtonTrack, saved["rows"], 
		displayCount, saved["horizontal"],
		saved["vertical"])
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

function zButtonTrackAdjustment_OnEvent()
	if not zButtonTrack or not zButtonTrack.count then
		return
	end
	if event == "SPELLS_CHANGED" or event == "CHARACTER_POINTS_CHANGED" or event == "LEARNED_SPELL_IN_TAB" then
		zButtonTrack_CreateButtons()
		zButtonTrack_SetupSizeAndPosition()
	end
	if event == "MINIMAP_UPDATE_TRACKING" or event == "PLAYER_ENTERING_WORLD"
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