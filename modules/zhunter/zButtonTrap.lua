local function zButtonTrap_GetRoot()
	return MTH_ZH_GetSavedRoot()
end

local root = zButtonTrap_GetRoot()
if not root["zButtonTrap"] then
	root["zButtonTrap"] = {}
	root["zButtonTrap"]["spells"] = {1, 2, 3, 4}
	root["zButtonTrap"]["rows"] = 1
	root["zButtonTrap"]["horizontal"] = nil
	root["zButtonTrap"]["vertical"] = nil
	root["zButtonTrap"]["firstbutton"] = "RIGHT"
	root["zButtonTrap"]["enabled"] = 1
	root["zButtonTrap"]["tooltip"] = 1
	root["zButtonTrap"]["parent"] = {}
	root["zButtonTrap"]["parent"]["size"] = 36
	root["zButtonTrap"]["parent"]["hide"] = nil
	root["zButtonTrap"]["parent"]["circle"] = 1
	root["zButtonTrap"]["children"] = {}
	root["zButtonTrap"]["children"]["size"] = 36
	root["zButtonTrap"]["children"]["hideonclick"] = 1
end

ZHunterMod_Trap_Spells = {
	ZHUNTER_TRAP_FREEZING,
	ZHUNTER_TRAP_FROST,
	ZHUNTER_TRAP_IMMOLATION,
	ZHUNTER_TRAP_EXPLOSIVE
}

local ZHUNTER_TRAP_MAX = table.getn(ZHunterMod_Trap_Spells)

local function zButtonTrap_GetSaved()
	local currentRoot = zButtonTrap_GetRoot()
	if not currentRoot["zButtonTrap"] then
		currentRoot["zButtonTrap"] = {}
	end
	return currentRoot["zButtonTrap"]
end

local function zButtonTrap_EnsureConfig()
	local saved = zButtonTrap_GetSaved()
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
	for i = 1, ZHUNTER_TRAP_MAX do
		if not tonumber(saved["spells"][i]) then
			saved["spells"][i] = i
		end
		if saved["visible"][i] == nil then
			saved["visible"][i] = 1
		end
	end
end

local function zButtonTrap_ApplyRuntimeSettings()
	if not zButtonTrap then
		return
	end
	local saved = zButtonTrap_GetSaved()
	zButtonTrap.tooltip = saved["tooltip"] and true or false
	zButtonTrap.hideonclick = saved["children"] and saved["children"]["hideonclick"] and true or false
end

function zButtonTrap_OnLoad()
	this:RegisterEvent("VARIABLES_LOADED")
end

function zButtonTrap_OnEvent()
	if event == "VARIABLES_LOADED" then
		if not zButtonTrap then
			return
		end
		if UnitClass("player") ~= ZHUNTER_HUNTER then
			zButtonTrap:UnregisterAllEvents()
			zButtonTrap:Hide()
			return
		end
		zButtonTrap_CreateButtons()
		zButtonTrapAdjustment = CreateFrame("Frame", "zButtonTrapAdjustment")
		zButtonTrapAdjustment:RegisterEvent("PLAYER_REGEN_ENABLED")
		zButtonTrapAdjustment:RegisterEvent("PLAYER_REGEN_DISABLED")
		zButtonTrapAdjustment:RegisterEvent("PLAYER_ENTERING_WORLD")
		zButtonTrapAdjustment:RegisterEvent("SPELLS_CHANGED")
		zButtonTrapAdjustment:RegisterEvent("CHARACTER_POINTS_CHANGED")
		zButtonTrapAdjustment:SetScript("OnEvent", zButtonTrapAdjustment_OnEvent)
		zButtonTrap_SetupSizeAndPosition()
	end
end

function zButtonTrap_CreateButtons()
	zButtonTrap_EnsureConfig()
	local saved = zButtonTrap_GetSaved()
	
	ZSpellButton_CreateChildren(zButtonTrap, "zButtonTrap", ZHUNTER_TRAP_MAX)
	local info = {}
	local infoIndex = 1
	for i=1, table.getn(ZHunterMod_Trap_Spells) do
		if not tonumber(saved["spells"][i]) then
			info = ZHunterMod_Trap_Spells
			saved["spells"] = {1, 2, 3, 4}
			break
		end
		local spellIndex = saved["spells"][i]
		if saved["visible"][spellIndex] ~= false then
			info[infoIndex] = ZHunterMod_Trap_Spells[spellIndex]
			infoIndex = infoIndex + 1
		end
	end
	zButtonTrap.found = ZSpellButton_SetButtons(zButtonTrap, info)
	zButtonTrap_ApplyRuntimeSettings()
end

function zButtonTrap_SetupSizeAndPosition()
	zButtonTrap_EnsureConfig()
	local saved = zButtonTrap_GetSaved()
	if saved["enabled"] == false or saved["enabled"] == 0 then
		if zButtonTrap and zButtonTrap.Hide then
			zButtonTrap:Hide()
		end
		return
	end
	local displayCount = zButtonTrap.found or ZHUNTER_TRAP_MAX
	if displayCount < 0 then
		displayCount = 0
	end
	ZSpellButton_SetSize(zButtonTrap, saved["parent"]["size"])
	ZSpellButton_SetSize(zButtonTrap, saved["children"]["size"], 1)
	ZSpellButton_SetExpandDirection(zButtonTrap, saved["firstbutton"])
	ZSpellButton_ArrangeChildren(zButtonTrap, saved["rows"], 
		displayCount, saved["horizontal"],
		saved["vertical"])
end

function zButtonTrap_Reset()
	local currentRoot = zButtonTrap_GetRoot()
	currentRoot["zButtonTrap"] = {}
	local saved = zButtonTrap_GetSaved()
	saved["spells"] = {1, 2, 3, 4}
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
	saved["visible"] = {1, 1, 1, 1}
	zButtonTrap_EnsureConfig()
end

function zButtonTrapAdjustment_OnEvent()
	if not zButtonTrap or not zButtonTrap.count then
		return
	end
	if event == "SPELLS_CHANGED" or event == "CHARACTER_POINTS_CHANGED" then
		zButtonTrap_CreateButtons()
		zButtonTrap_SetupSizeAndPosition()
	end
	local nextbutton
	local button
	local combat = event == "PLAYER_REGEN_DISABLED"
	for i=1, zButtonTrap.count do
		button = getglobal(zButtonTrap.name..i)
		button.customcolor = nil
		if button.id then
			if not nextbutton then
				nextbutton = button
			end
			if combat then
				button.icontexture:SetVertexColor(0.4, 0.4, 0.4)
				button.customcolor = 1
			else
				button.icontexture:SetVertexColor(1.0, 1.0, 1.0)
			end
		end
	end
	zButtonTrap.id = nextbutton and nextbutton.id or zButtonTrap1.id
	ZSpellButton_UpdateButton(zButtonTrap)
	ZSpellButton_UpdateCooldown(zButtonTrap)
	if GameTooltip:IsOwned(zButtonTrap) then
		ZSpellButtonParent_OnEnter(zButtonTrap)
	end
end

function zButtonTrap_KeyBinding(index)
	if MTH_ZH_IsModuleEnabled and not MTH_ZH_IsModuleEnabled() then
		return
	end

	local button
	if index then
		button = getglobal("zButtonTrap"..index)
	else
		button = zButtonTrap
	end
	if button.id then
		CastSpell(button.id, "spell")
		if zButtonTrap.hideonclick then
			if type(ZSpellButton_SetChildrenExpanded) == "function" then
				ZSpellButton_SetChildrenExpanded(zButtonTrap, false)
			elseif zButtonTrap.children then
				zButtonTrap.children:Hide()
			end
		end
	end
end

SLASH_zButtonTrap1 = "/ZTrap"
SlashCmdList["zButtonTrap"] = function(msg)
	if MTH_ZH_HandleDisabledSlash and MTH_ZH_HandleDisabledSlash("Trap button is disabled while module 'zhunter' is disabled.") then
		return
	end
	if msg == "reset" then
		zButtonTrap_Reset()
		zButtonTrap:ClearAllPoints()
		zButtonTrap:SetPoint("CENTER", UIParent, "CENTER", 60, 0)
	elseif msg == "options" then
		MTH_OpenOptions("Trap")
	else
		MTH_ZH_Print("Possible Commands: \"options\", \"reset\"")
	end
end