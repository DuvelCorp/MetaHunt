local function zButtonAspect_GetRoot()
	return MTH_ZH_GetSavedRoot()
end

local root = zButtonAspect_GetRoot()
if not root["zButtonAspect"] then
	root["zButtonAspect"] = {}
	root["zButtonAspect"]["spells"] = {1, 2, 3, 4, 5, 6, 7}
	root["zButtonAspect"]["rows"] = 1
	root["zButtonAspect"]["horizontal"] = nil
	root["zButtonAspect"]["vertical"] = nil
	root["zButtonAspect"]["firstbutton"] = "RIGHT"
	root["zButtonAspect"]["enabled"] = 1
	root["zButtonAspect"]["tooltip"] = 1
	root["zButtonAspect"]["parent"] = {}
	root["zButtonAspect"]["parent"]["size"] = 36
	root["zButtonAspect"]["parent"]["hide"] = nil
	root["zButtonAspect"]["parent"]["circle"] = 1
	root["zButtonAspect"]["children"] = {}
	root["zButtonAspect"]["children"]["size"] = 36
	root["zButtonAspect"]["children"]["hideonclick"] = 1
end

ZHunterMod_Aspect_Spells = {
	ZHUNTER_ASPECT_HAWK,
	ZHUNTER_ASPECT_MONKEY,
	ZHUNTER_ASPECT_WOLF,
	ZHUNTER_ASPECT_CHEETAH,
	ZHUNTER_ASPECT_PACK,
	ZHUNTER_ASPECT_WILD,
	ZHUNTER_ASPECT_BEAST
}

local ZHUNTER_ASPECT_MAX = table.getn(ZHunterMod_Aspect_Spells)

local function zButtonAspect_GetSaved()
	local currentRoot = zButtonAspect_GetRoot()
	if not currentRoot["zButtonAspect"] then
		currentRoot["zButtonAspect"] = {}
	end
	return currentRoot["zButtonAspect"]
end

local function zButtonAspect_EnsureConfig()
	local saved = zButtonAspect_GetSaved()
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
	for i = 1, ZHUNTER_ASPECT_MAX do
		if not tonumber(saved["spells"][i]) then
			saved["spells"][i] = i
		end
		if saved["visible"][i] == nil then
			saved["visible"][i] = 1
		end
	end
end

local function zButtonAspect_ApplyRuntimeSettings()
	if not zButtonAspect then
		return
	end
	local saved = zButtonAspect_GetSaved()
	zButtonAspect.tooltip = saved["tooltip"] and true or false
	zButtonAspect.hideonclick = saved["children"] and saved["children"]["hideonclick"] and true or false
end

function zButtonAspect_OnLoad()
	this:RegisterEvent("VARIABLES_LOADED")
end

function zButtonAspect_OnEvent()
	if event == "VARIABLES_LOADED" then
		if not zButtonAspect then
			return
		end
		if UnitClass("player") ~= ZHUNTER_HUNTER then
			zButtonAspect:UnregisterAllEvents()
			zButtonAspect:Hide()
			return
		end
		zButtonAspect_CreateButtons()
		zButtonAspectAdjustment = CreateFrame("Frame", "zButtonAspectAdjustment")
		zButtonAspectAdjustment:RegisterEvent("PLAYER_AURAS_CHANGED")
		zButtonAspectAdjustment:RegisterEvent("PLAYER_ENTERING_WORLD")
		zButtonAspectAdjustment:SetScript("OnEvent", zButtonAspectAdjustment_OnEvent)
		zButtonAspect_Tooltip = CreateFrame("GameTooltip", "zButtonAspect_Tooltip", nil, "GameTooltipTemplate")
		zButtonAspect_SetupSizeAndPosition()
	end
end

function zButtonAspect_CreateButtons()
	zButtonAspect_EnsureConfig()
	local saved = zButtonAspect_GetSaved()
	
	ZSpellButton_CreateChildren(zButtonAspect, "zButtonAspect", ZHUNTER_ASPECT_MAX)
	local info = {}
	local infoIndex = 1
	for i=1, table.getn(ZHunterMod_Aspect_Spells) do
		if not tonumber(saved["spells"][i]) then
			info = ZHunterMod_Aspect_Spells
			saved["spells"] = {1, 2, 3, 4, 5, 6, 7}
			break
		end
		local spellIndex = saved["spells"][i]
		if saved["visible"][spellIndex] ~= false then
			info[infoIndex] = ZHunterMod_Aspect_Spells[spellIndex]
			infoIndex = infoIndex + 1
		end
	end
	zButtonAspect.found = ZSpellButton_SetButtons(zButtonAspect, info)
	zButtonAspect_ApplyRuntimeSettings()
end

function zButtonAspect_SetupSizeAndPosition()
	zButtonAspect_EnsureConfig()
	local saved = zButtonAspect_GetSaved()
	if saved["enabled"] == false or saved["enabled"] == 0 then
		if zButtonAspect and zButtonAspect.Hide then
			zButtonAspect:Hide()
		end
		return
	end
	local displayCount = zButtonAspect.found or ZHUNTER_ASPECT_MAX
	if displayCount < 0 then
		displayCount = 0
	end
	ZSpellButton_SetSize(zButtonAspect, saved["parent"]["size"])
	ZSpellButton_SetSize(zButtonAspect, saved["children"]["size"], 1)
	ZSpellButton_SetExpandDirection(zButtonAspect, saved["firstbutton"])
	ZSpellButton_ArrangeChildren(zButtonAspect, saved["rows"], 
		displayCount, saved["horizontal"],
		saved["vertical"])
end

function zButtonAspect_Reset()
	local currentRoot = zButtonAspect_GetRoot()
	currentRoot["zButtonAspect"] = {}
	local saved = zButtonAspect_GetSaved()
	saved["spells"] = {1, 2, 3, 4, 5, 6, 7}
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
	saved["visible"] = {1, 1, 1, 1, 1, 1, 1}
	zButtonAspect_EnsureConfig()
end

function zButtonAspectAdjustment_OnEvent()
	if not zButtonAspect or not zButtonAspect.count then
		return
	end
	if event == "PLAYER_AURAS_CHANGED" or event == "PLAYER_ENTERING_WORLD" then
		if not zButtonAspect1.id then
			return
		end
		local buttontextures = {}
		local button
		for i=1, zButtonAspect.count do
			button = getglobal(zButtonAspect.name..i)
			button.icon = nil
			if button.id then
				buttontextures[GetSpellTexture(button.id, "spell")] = button
			end
		end
		local i = 1
		local texture = GetSpellTexture(zButtonAspect1.id, "spell")
		local buff = UnitBuff("player", i)
		local spellname, buffname
		zButtonAspect.id = zButtonAspect1.id
		while buff do
			if texture == buff and zButtonAspect2.id then
				zButtonAspect.id = zButtonAspect2.id
			end
			if buttontextures[buff] then
				zButtonAspect_Tooltip:SetOwner(this, "ANCHOR_NONE")
				zButtonAspect_Tooltip:SetUnitBuff("player", i)
				buffname = zButtonAspect_TooltipTextLeft1:GetText()
				spellname = GetSpellName(buttontextures[buff].id, "spell")
				if buffname == spellname then
					buttontextures[buff].icon = "Interface\\Icons\\Spell_Nature_WispSplode"
				end
			end
			i = i + 1
			buff = UnitBuff("player", i)
		end
		ZSpellButton_UpdateButton(zButtonAspect)
		ZSpellButton_UpdateCooldown(zButtonAspect)
		for i=1, zButtonAspect.count do
			button = getglobal(zButtonAspect.name..i)
			if button.id then
				ZSpellButton_UpdateButton(button)
			end
		end
		if GameTooltip:IsOwned(zButtonAspect) then
			ZSpellButtonParent_OnEnter(zButtonAspect)
		end
	end
end

function zButtonAspect_KeyBinding(index)
	if MTH_ZH_IsModuleEnabled and not MTH_ZH_IsModuleEnabled() then
		return
	end

	local button
	if index then
		button = getglobal("zButtonAspect"..index)
	else
		button = zButtonAspect
	end
	if button.id then
		CastSpell(button.id, "spell")
		if zButtonAspect.hideonclick then
			if type(ZSpellButton_SetChildrenExpanded) == "function" then
				ZSpellButton_SetChildrenExpanded(zButtonAspect, false)
			elseif zButtonAspect.children then
				zButtonAspect.children:Hide()
			end
		end
	end
end

SLASH_zButtonAspect1 = "/ZAspect"
SlashCmdList["zButtonAspect"] = function(msg)
	if MTH_ZH_HandleDisabledSlash and MTH_ZH_HandleDisabledSlash("Aspect button is disabled while module 'zhunter' is disabled.") then
		return
	end
	if msg == "reset" then
		zButtonAspect_Reset()
		zButtonAspect:ClearAllPoints()
		zButtonAspect:SetPoint("CENTER", UIParent, "CENTER", -60, 0)
	elseif msg == "options" then
		MTH_OpenOptions("Aspect")
	else
		MTH_ZH_Print("Possible Commands: \"options\", \"reset\"")
	end
end