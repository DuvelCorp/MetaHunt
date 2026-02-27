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

local function zButtonTrack_GetSaved()
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
		zButtonTrackAdjustment = CreateFrame("Frame", "zButtonTrackAdjustment")
		zButtonTrackAdjustment:RegisterEvent("PLAYER_AURAS_CHANGED")
		zButtonTrackAdjustment:RegisterEvent("PLAYER_ENTERING_WORLD")
		zButtonTrackAdjustment:RegisterEvent("SPELLS_CHANGED")
		zButtonTrackAdjustment:RegisterEvent("CHARACTER_POINTS_CHANGED")
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
		if zButtonTrack and zButtonTrack.Hide then
			zButtonTrack:Hide()
		end
		return
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
	if event == "SPELLS_CHANGED" or event == "CHARACTER_POINTS_CHANGED" then
		zButtonTrack_CreateButtons()
		zButtonTrack_SetupSizeAndPosition()
	end
	if event == "PLAYER_AURAS_CHANGED" or event == "PLAYER_ENTERING_WORLD"
		or event == "SPELLS_CHANGED" or event == "CHARACTER_POINTS_CHANGED" then
		local i = 1
		local texture = zButtonTrack1IconTexture:GetTexture()
		local buff = GetTrackingTexture()
		if texture == buff and zButtonTrack2.id then
			zButtonTrack.id = zButtonTrack2.id
		else
			zButtonTrack.id = zButtonTrack1.id			
		end
		ZSpellButton_UpdateButton(zButtonTrack)
		ZSpellButton_UpdateCooldown(zButtonTrack)
		if GameTooltip:IsOwned(zButtonTrack) then
			ZSpellButtonParent_OnEnter(zButtonTrack)
		end
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