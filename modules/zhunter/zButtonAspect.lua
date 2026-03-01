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
local zButtonAspect_LastAuraUpdateAt = 0
local zButtonAspect_MinAuraInterval = 0.15
local zButtonAspect_MinAuraIntervalCombat = 0.60
local zButtonAspect_LastAuraTexture = nil
local zButtonAspect_LastParentId = nil
local zButtonAspect_AuraProbeTextLeft1 = nil

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

local function zButtonAspect_IsKnownAspectSpellId(spellId)
	if not spellId then
		return false
	end
	local spellName = GetSpellName(spellId, "spell")
	if not spellName or spellName == "" then
		return false
	end
	for i = 1, table.getn(ZHunterMod_Aspect_Spells) do
		if ZHunterMod_Aspect_Spells[i] == spellName then
			return true
		end
	end
	return false
end

local function zButtonAspect_EnsureValidParentId()
	if not (zButtonAspect and zButtonAspect.count) then
		return
	end

	if zButtonAspect_IsKnownAspectSpellId(zButtonAspect.id) then
		return
	end

	for i = 1, zButtonAspect.count do
		local child = getglobal(zButtonAspect.name .. i)
		if child and child.id and zButtonAspect_IsKnownAspectSpellId(child.id) then
			zButtonAspect.id = child.id
			zButtonAspect.isspell = 1
			ZSpellButton_UpdateButton(zButtonAspect)
			ZSpellButton_UpdateCooldown(zButtonAspect)
			return
		end
	end
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
		zButtonAspectAdjustment:RegisterEvent("SPELLS_CHANGED")
		zButtonAspectAdjustment:RegisterEvent("CHARACTER_POINTS_CHANGED")
		zButtonAspectAdjustment:RegisterEvent("LEARNED_SPELL_IN_TAB")
		zButtonAspectAdjustment:SetScript("OnEvent", zButtonAspectAdjustment_OnEvent)
		zButtonAspect_Tooltip = CreateFrame("GameTooltip", "zButtonAspect_AuraProbeScan", nil, "GameTooltipTemplate")
		if zButtonAspect_Tooltip and zButtonAspect_Tooltip.GetName then
			local tooltipName = zButtonAspect_Tooltip:GetName()
			if tooltipName then
				zButtonAspect_AuraProbeTextLeft1 = getglobal(tooltipName .. "TextLeft1")
			end
		end
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
	zButtonAspect_EnsureValidParentId()
end

function zButtonAspect_SetupSizeAndPosition()
	zButtonAspect_EnsureConfig()
	local saved = zButtonAspect_GetSaved()
	if saved["enabled"] == false or saved["enabled"] == 0 then
		if zButtonAspectAdjustment and zButtonAspectAdjustment.SetScript then
			zButtonAspectAdjustment:SetScript("OnEvent", nil)
		end
		if zButtonAspect and zButtonAspect.Hide then
			zButtonAspect:Hide()
		end
		return
	end
	if zButtonAspectAdjustment and zButtonAspectAdjustment.SetScript then
		zButtonAspectAdjustment:SetScript("OnEvent", zButtonAspectAdjustment_OnEvent)
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
	if event == "PLAYER_AURAS_CHANGED" then
		local now = GetTime and GetTime() or 0
		local minInterval = zButtonAspect_MinAuraInterval
		if UnitAffectingCombat and UnitAffectingCombat("player") then
			minInterval = zButtonAspect_MinAuraIntervalCombat
		end
		if now > 0 and zButtonAspect_LastAuraUpdateAt > 0 and (now - zButtonAspect_LastAuraUpdateAt) < minInterval then
			return
		end
		zButtonAspect_LastAuraUpdateAt = now
	end
	if event == "SPELLS_CHANGED" or event == "CHARACTER_POINTS_CHANGED" or event == "LEARNED_SPELL_IN_TAB" then
		zButtonAspect_CreateButtons()
		zButtonAspect_SetupSizeAndPosition()
		zButtonAspect_EnsureValidParentId()
	end
	if event == "PLAYER_AURAS_CHANGED" or event == "PLAYER_ENTERING_WORLD"
		or event == "SPELLS_CHANGED" or event == "CHARACTER_POINTS_CHANGED" or event == "LEARNED_SPELL_IN_TAB" then
		zButtonAspect_EnsureValidParentId()
		if not zButtonAspect1.id then
			return
		end
		local button
		local isParentTooltipOwned = GameTooltip and GameTooltip.IsOwned and GameTooltip:IsOwned(zButtonAspect)
		local childrenShown = zButtonAspect.children and zButtonAspect.children.IsShown and zButtonAspect.children:IsShown()
		local needChildIconScan = (event ~= "PLAYER_AURAS_CHANGED") or childrenShown or isParentTooltipOwned
		local buttontextures = nil
		local hasDuplicateChildTexture = nil
		if needChildIconScan then
			buttontextures = {}
			local textureSeen = {}
			for i=1, zButtonAspect.count do
				button = getglobal(zButtonAspect.name..i)
				button.icon = nil
				if button.id then
					local btnTexture = GetSpellTexture(button.id, "spell")
					if btnTexture then
						if textureSeen[btnTexture] then
							hasDuplicateChildTexture = true
						elseif hasDuplicateChildTexture == nil then
							hasDuplicateChildTexture = false
						end
						textureSeen[btnTexture] = 1
						buttontextures[btnTexture] = button
					end
				end
			end
		end
		local i = 1
		local texture = GetSpellTexture(zButtonAspect1.id, "spell")
		local buff = UnitBuff("player", i)
		local spellname, buffname
		local newParentId = zButtonAspect1.id
		while buff do
			if texture == buff and zButtonAspect2.id then
				newParentId = zButtonAspect2.id
			end
			if needChildIconScan and buttontextures[buff] then
				if hasDuplicateChildTexture then
					zButtonAspect_Tooltip:SetOwner(this, "ANCHOR_NONE")
					zButtonAspect_Tooltip:SetUnitBuff("player", i)
					if zButtonAspect_AuraProbeTextLeft1 and zButtonAspect_AuraProbeTextLeft1.GetText then
						buffname = zButtonAspect_AuraProbeTextLeft1:GetText()
					else
						buffname = nil
					end
					spellname = GetSpellName(buttontextures[buff].id, "spell")
					if buffname == spellname then
						buttontextures[buff].icon = "Interface\\Icons\\Spell_Nature_WispSplode"
					end
				else
					buttontextures[buff].icon = "Interface\\Icons\\Spell_Nature_WispSplode"
				end
			end
			i = i + 1
			buff = UnitBuff("player", i)
		end
		if event == "PLAYER_AURAS_CHANGED" and zButtonAspect_LastAuraTexture == texture and zButtonAspect.id == newParentId and zButtonAspect_LastParentId == newParentId and not isParentTooltipOwned then
			return
		end
		zButtonAspect_LastAuraTexture = texture
		zButtonAspect_LastParentId = newParentId
		zButtonAspect.id = newParentId
		ZSpellButton_UpdateButton(zButtonAspect)
		ZSpellButton_UpdateCooldown(zButtonAspect)
		if needChildIconScan then
			for i=1, zButtonAspect.count do
				button = getglobal(zButtonAspect.name..i)
				if button.id then
					ZSpellButton_UpdateButton(button)
				end
			end
		end
		if isParentTooltipOwned then
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