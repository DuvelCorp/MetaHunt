local function zButtonPet_GetRoot()
	return MTH_ZH_GetSavedRoot()
end

local root = zButtonPet_GetRoot()

-- Initialize with defaults only if not already configured
if not root["zButtonPet"] then
	root["zButtonPet"] = {}
	root["zButtonPet"]["pet"] = {}
	root["zButtonPet"]["pet"]["happiness"] = nil
	root["zButtonPet"]["pet"]["status"] = nil
	root["zButtonPet"]["pet"]["dead"] = nil
	root["zButtonPet"]["spells"] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}
	root["zButtonPet"]["rows"] = 1
	root["zButtonPet"]["horizontal"] = nil
	root["zButtonPet"]["vertical"] = nil
	root["zButtonPet"]["firstbutton"] = "RIGHT"
	root["zButtonPet"]["enabled"] = 1
	root["zButtonPet"]["tooltip"] = 1
	root["zButtonPet"]["parent"] = {}
	root["zButtonPet"]["parent"]["size"] = 36
	root["zButtonPet"]["parent"]["hide"] = nil
	root["zButtonPet"]["parent"]["circle"] = 1
	root["zButtonPet"]["children"] = {}
	root["zButtonPet"]["children"]["size"] = 36
	root["zButtonPet"]["children"]["hideonclick"] = 1
end
root["zButtonPet"]["food"] = {}

ZHunterMod_Pet_Spells = {
	ZHUNTER_PET_EYES,
	ZHUNTER_PET_DISMISS,
	ZHUNTER_PET_MEND,
	ZHUNTER_PET_FEED,
	ZHUNTER_PET_CALL,
	ZHUNTER_PET_REVIVE,
	ZHUNTER_PET_LORE,
	ZHUNTER_PET_TRAINING,
	ZHUNTER_PET_TAMING,
	ZHUNTER_PET_POSITION
}

local ZHUNTER_PET_MAX = table.getn(ZHunterMod_Pet_Spells)
local zButtonPet_SetButtons

local function zButtonPet_GetSaved()
	local currentRoot = zButtonPet_GetRoot()
	if not currentRoot["zButtonPet"] then
		currentRoot["zButtonPet"] = {}
	end
	return currentRoot["zButtonPet"]
end

local function zButtonPet_EnsureConfig()
	local saved = zButtonPet_GetSaved()
	saved["count"] = nil
	if not saved["pet"] then
		saved["pet"] = {}
	end
	if saved["pet"]["happiness"] == nil then
		saved["pet"]["happiness"] = nil
	end
	if saved["pet"]["status"] == nil then
		saved["pet"]["status"] = nil
	end
	if saved["pet"]["dead"] == nil then
		saved["pet"]["dead"] = nil
	end
	if not saved["parent"] then
		saved["parent"] = {}
	end
	if saved["parent"]["size"] == nil then
		saved["parent"]["size"] = 36
	end
	if saved["parent"]["hide"] == nil then
		saved["parent"]["hide"] = nil
	end
	if saved["parent"]["circle"] == nil then
		saved["parent"]["circle"] = 1
	end
	if saved["enabled"] == nil then
		saved["enabled"] = 1
	end
	if saved["tooltip"] == nil then
		saved["tooltip"] = 1
	end
	if saved["rows"] == nil then
		saved["rows"] = 1
	end
	if saved["horizontal"] == nil then
		saved["horizontal"] = nil
	end
	if saved["vertical"] == nil then
		saved["vertical"] = nil
	end
	if saved["firstbutton"] == nil then
		saved["firstbutton"] = "RIGHT"
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
	if saved["food"] == nil then
		saved["food"] = {}
	end
	if not saved["spells"] then
		saved["spells"] = {}
	end
	if not saved["visible"] then
		saved["visible"] = {}
	end
	for i = 1, ZHUNTER_PET_MAX do
		if not tonumber(saved["spells"][i]) then
			saved["spells"][i] = i
		end
		if saved["visible"][i] == nil then
			saved["visible"][i] = 1
		end
	end
end

local function zButtonPet_ApplyRuntimeSettings()
	if not zButtonPet then
		return
	end
	local saved = zButtonPet_GetSaved()
	zButtonPet.tooltip = saved["tooltip"] and true or false
	zButtonPet.hideonclick = saved["children"] and saved["children"]["hideonclick"] and true or false
end

function zButtonPet_OnLoad()
	this:RegisterEvent("VARIABLES_LOADED")
end

function zButtonPet_OnEvent()
	if event == "VARIABLES_LOADED" then
		if not zButtonPet then
			return
		end
		if UnitClass("player") ~= ZHUNTER_HUNTER then
			zButtonPet:UnregisterAllEvents()
			zButtonPet:Hide()
			return
		end
		zButtonPet.customSetButtons = zButtonPet_SetButtons
		zButtonPet_CreateButtons()
		zButtonPet.beforeclick = zButtonPetAdjustment_BeforeClick
		zButtonPet.afterclick = zButtonPet_AfterClick
		zButtonPetAdjustment = CreateFrame("Frame", "zButtonPetAdjustment")
		zButtonPetAdjustment:RegisterEvent("UNIT_HEALTH")
		zButtonPetAdjustment:RegisterEvent("UNIT_HAPPINESS")
		zButtonPetAdjustment:RegisterEvent("UNIT_PET")
		zButtonPetAdjustment:RegisterEvent("PET_BAR_UPDATE")
		zButtonPetAdjustment:RegisterEvent("PLAYER_ENTERING_WORLD")
		zButtonPetAdjustment:RegisterEvent("SPELLS_CHANGED")
		zButtonPetAdjustment:RegisterEvent("LEARNED_SPELL_IN_TAB")
		zButtonPetAdjustment:SetScript("OnEvent", zButtonPetAdjustment_OnEvent)
		zButtonPet_Tooltip = CreateFrame("GameTooltip", "zButtonPet_Tooltip", nil, "GameTooltipTemplate")
		zButtonPet_SetupSizeAndPosition()
		zButtonPetAdjustment_OnEvent()
	end
end

function zButtonPet_CreateButtons()
	zButtonPet_EnsureConfig()
	local saved = zButtonPet_GetSaved()
	
	ZSpellButton_CreateChildren(zButtonPet, "zButtonPet", ZHUNTER_PET_MAX)
	local info = {}
	local infoIndex = 1
	for i=1, table.getn(ZHunterMod_Pet_Spells) do
		if not tonumber(saved["spells"][i]) then
			info = ZHunterMod_Pet_Spells
			saved["spells"] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}
			break
		end
		local spellIndex = saved["spells"][i]
		if saved["visible"][spellIndex] ~= false then
			info[infoIndex] = ZHunterMod_Pet_Spells[spellIndex]
			infoIndex = infoIndex + 1
		end
	end
	zButtonPet.found = ZSpellButton_SetButtons(zButtonPet, info)
	zButtonPet_ApplyRuntimeSettings()
end

function zButtonPet_SetupSizeAndPosition()
	local saved = zButtonPet_GetSaved()
	if saved["enabled"] == false or saved["enabled"] == 0 then
		if zButtonPet and zButtonPet.Hide then
			zButtonPet:Hide()
		end
		return
	end
	local displayCount = zButtonPet.found or ZHUNTER_PET_MAX
	if displayCount < 0 then
		displayCount = 0
	end
	ZSpellButton_SetSize(zButtonPet, saved["parent"]["size"])
	ZSpellButton_SetSize(zButtonPet, saved["children"]["size"], 1)
	ZSpellButton_SetExpandDirection(zButtonPet, saved["firstbutton"])
	ZSpellButton_ArrangeChildren(zButtonPet, saved["rows"], 
		displayCount, saved["horizontal"],
		saved["vertical"])
end

function zButtonPet_Reset()
	local currentRoot = zButtonPet_GetRoot()
	currentRoot["zButtonPet"] = {}
	local saved = zButtonPet_GetSaved()
	saved["pet"] = {}
	saved["pet"]["happiness"] = nil
	saved["pet"]["status"] = nil
	saved["pet"]["dead"] = nil
	saved["spells"] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}
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
	saved["visible"] = {1, 1, 1, 1, 1, 1, 1, 1, 1, 1}
	zButtonPet_EnsureConfig()
end

function IsPetDead()
	local saved = zButtonPet_GetSaved()
	return saved["pet"] and saved["pet"]["dead"]
end

local function zButtonPet_GetCorePetInfo()
	if type(MTH_GetCurrentPetInfo) == "function" then
		local info = MTH_GetCurrentPetInfo()
		if type(info) == "table" then
			return info
		end
	end
	return nil
end

local function zButtonPet_RefreshSavedPetState(saved, corePetInfo)
	local hasLivePet = false
	if type(UnitExists) == "function" then
		hasLivePet = UnitExists("pet") and true or false
	elseif type(corePetInfo) == "table" and corePetInfo.liveExists ~= nil then
		hasLivePet = corePetInfo.liveExists and true or false
	end

	if not hasLivePet then
		saved["pet"]["status"] = nil
		saved["pet"]["dead"] = nil
		saved["pet"]["happiness"] = nil
		return false
	end

	local currentHealth = (corePetInfo and tonumber(corePetInfo.health)) or (type(UnitHealth) == "function" and UnitHealth("pet")) or nil
	local currentHealthMax = (corePetInfo and tonumber(corePetInfo.healthMax)) or (type(UnitHealthMax) == "function" and UnitHealthMax("pet")) or nil
	local isDead = (corePetInfo and corePetInfo.dead) and true or false
	if not isDead and type(UnitIsDead) == "function" then
		isDead = UnitIsDead("pet") and true or false
	end
	if isDead then
		saved["pet"]["dead"] = 1
	else
		saved["pet"]["dead"] = nil
	end

	local happiness = corePetInfo and corePetInfo.happiness or nil
	if happiness == nil and type(GetPetHappiness) == "function" then
		happiness = GetPetHappiness()
	end
	saved["pet"]["happiness"] = happiness

	if isDead then
		saved["pet"]["status"] = 1
	elseif currentHealth and currentHealthMax and currentHealthMax > 0 then
		if (currentHealth / currentHealthMax) > 0.75 then
			saved["pet"]["status"] = 2
		else
			saved["pet"]["status"] = 1
		end
	else
		saved["pet"]["status"] = 2
	end

	return true
end

local function zButtonPet_FindSpellIdByName(spellName)
	if not spellName or spellName == "" then
		return nil
	end
	local lookup = {}
	local foundAny = nil

	if type(GetNumSpellTabs) == "function" and type(GetSpellTabInfo) == "function" then
		local numTabs = GetNumSpellTabs() or 0
		for tabIndex = 1, numTabs do
			local _, _, offset, numSpells = GetSpellTabInfo(tabIndex)
			offset = tonumber(offset) or 0
			numSpells = tonumber(numSpells) or 0
			if numSpells > 0 then
				for spellIndex = (offset + 1), (offset + numSpells) do
					local spellNameAtIndex = GetSpellName(spellIndex, "spell")
					if spellNameAtIndex then
						lookup[spellNameAtIndex] = spellIndex
						foundAny = 1
					end
				end
			end
		end
	end

	if not foundAny then
		local maxSpells = tonumber((_G and _G["MAX_SPELLS"]) or nil) or 1024
		local nilStreak = 0
		for spellIndex = 1, maxSpells do
			local spellNameAtIndex = GetSpellName(spellIndex, "spell")
			if spellNameAtIndex then
				lookup[spellNameAtIndex] = spellIndex
				nilStreak = 0
			else
				nilStreak = nilStreak + 1
				if nilStreak >= 30 then
					break
				end
			end
		end
	end

	if spellName == ZHUNTER_PET_POSITION then
		if lookup[spellName] then
			return lookup[spellName]
		end
		for currentName, currentId in lookup do
			if string.find(currentName, "Take Position", 1, true)
				or string.find(currentName, "Position", 1, true)
				or string.find(currentName, "Stay", 1, true) then
				return currentId
			end
		end
		return nil
	end

	return lookup[spellName]
end

zButtonPet_SetButtons = function(parent, spells)
	if not (parent and parent.count and parent.name and spells) then
		return 0
	end

	local info = {}
	for i = 1, table.getn(spells) do
		local spellName = spells[i]
		local spellId = zButtonPet_FindSpellIdByName(spellName)
		if spellId then
			table.insert(info, spellId)
		end
	end

	for i = 1, parent.count do
		local child = getglobal(parent.name..i)
		if child then
			child:Hide()
			child.id = nil
			child.icon = nil
			child.isspell = nil
		end
	end

	parent.id = nil
	parent.isspell = nil

	local foundCount = 0
	for i = 1, table.getn(info) do
		if i > parent.count then
			break
		end
		local button = getglobal(parent.name..i)
		if button then
			button.id = info[i]
			button.isspell = 1
			ZSpellButton_UpdateButton(button)
			button:Show()
			if i == 1 then
				parent.id = info[i]
				parent.isspell = 1
				ZSpellButton_UpdateButton(parent)
				parent:Enable()
			end
			foundCount = foundCount + 1
		end
	end

	return foundCount
end

function zButtonPetAdjustment_BeforeClick()
	if CursorHasItem() then
		DropItemOnUnit("pet")
		return 1
	end
end

local function zButtonPet_RefreshParentSpell()
	if not zButtonPet or not zButtonPet.count then
		return
	end
	zButtonPet_EnsureConfig()
	local saved = zButtonPet_GetSaved()
	local corePetInfo = zButtonPet_GetCorePetInfo()
	local hasCurrentPet = nil
	local hasLivePet = nil
	if type(corePetInfo) == "table" and corePetInfo.exists ~= nil then
		hasCurrentPet = corePetInfo.exists and true or false
	end
	if type(corePetInfo) == "table" and corePetInfo.liveExists ~= nil then
		hasLivePet = corePetInfo.liveExists and true or false
	end
	zButtonPet_RefreshSavedPetState(saved, corePetInfo)

	local status, happiness, dead
	local spells = {}
	local name
	local choice
	for i=1, zButtonPet.count do
		local button
		button = getglobal(zButtonPet.name..i)
		if button and button.id then
			name = GetSpellName(button.id, "spell")
			spells[name] = button
			if not choice and (name == ZHUNTER_PET_DISMISS or name == ZHUNTER_PET_EYES or name == ZHUNTER_PET_POSITION) then
				choice = button
			end
		end
	end
	status = saved["pet"]["status"]
	happiness = saved["pet"]["happiness"]
	dead = saved["pet"]["dead"]
	local id = zButtonPet.id
	name = nil

	if hasCurrentPet == false and hasLivePet == false then
		name = ZHUNTER_PET_TAMING
	elseif not status then
		name = ZHUNTER_PET_CALL
	elseif dead then
		name = ZHUNTER_PET_REVIVE
	elseif status == 1 then
		name = ZHUNTER_PET_MEND
	elseif happiness ~= 3 then
		name = ZHUNTER_PET_FEED
	elseif choice then
		id = choice.id
	end

	if name and spells[name] then
		id = spells[name].id
	elseif name then
		local fallbackId = zButtonPet_FindSpellIdByName(name)
		if fallbackId then
			id = fallbackId
		end
	end
	zButtonPet.id = id
	ZSpellButton_UpdateButton(zButtonPet)
	ZSpellButton_UpdateCooldown(zButtonPet)
	if GameTooltip:IsOwned(zButtonPet) then
		ZSpellButtonParent_OnEnter(zButtonPet)
	end
end

function zButtonPet_AfterClick()
	zButtonPet_RefreshParentSpell()
end

function zButtonPet_RefreshLiveState(_liveState, _source)
	zButtonPet_RefreshParentSpell()
end

function zButtonPetAdjustment_OnEvent()
	if not zButtonPet or not zButtonPet.count then
		return
	end

	if (event == "UNIT_HEALTH" or event == "UNIT_HAPPINESS") and arg1 and arg1 ~= "pet" then
		return
	end
	if event == "UNIT_PET" and arg1 and arg1 ~= "player" then
		return
	end
	zButtonPet_RefreshParentSpell()
end

function zButtonPet_KeyBinding(index)
	if MTH_ZH_IsModuleEnabled and not MTH_ZH_IsModuleEnabled() then
		return
	end

	local button
	if index then
		button = getglobal("zButtonPet"..index)
	else
		button = zButtonPet
	end
	if button.id then
		CastSpell(button.id, "spell")
		if zButtonPet.hideonclick then
			if type(ZSpellButton_SetChildrenExpanded) == "function" then
				ZSpellButton_SetChildrenExpanded(zButtonPet, false)
			elseif zButtonPet.children then
				zButtonPet.children:Hide()
			end
		end
	end
end

function zButtonPet_FeedPet()

end

local function zButtonPet_DebugVerify()
	if not zButtonPet then
		MTH_ZH_Print("zPet: button frame is not ready yet.")
		return
	end

	zButtonPet_CreateButtons()
	zButtonPet_RefreshParentSpell()

	MTH_ZH_Print("zPet verify: expected spell availability")
	for i = 1, table.getn(ZHunterMod_Pet_Spells) do
		local spellName = ZHunterMod_Pet_Spells[i]
		local spellId = zButtonPet_FindSpellIdByName(spellName)
		if spellId then
			MTH_ZH_Print("  + "..spellName.." (id "..spellId..")")
		else
			MTH_ZH_Print("  - "..spellName.." (missing)")
		end
	end

	if zButtonPet.id then
		local parentName = GetSpellName(zButtonPet.id, "spell") or "<unknown>"
		MTH_ZH_Print("zPet parent: "..parentName.." (id "..zButtonPet.id..")")
	else
		MTH_ZH_Print("zPet parent: <none>")
	end

	for i = 1, (zButtonPet.count or 0) do
		local button = getglobal("zButtonPet"..i)
		if button and button.id then
			local name = GetSpellName(button.id, "spell") or "<unknown>"
			MTH_ZH_Print("  slot "..i..": "..name.." (id "..button.id..")")
		end
	end
end

SLASH_zButtonPet1 = "/ZPet"
SlashCmdList["zButtonPet"] = function(msg)
	if MTH_ZH_HandleDisabledSlash and MTH_ZH_HandleDisabledSlash("Pet button is disabled while module 'zhunter' is disabled.") then
		return
	end
	msg = (msg and string.lower(msg)) or ""
	if msg == "reset" then
		zButtonPet_Reset()
		zButtonPet:ClearAllPoints()
		zButtonPet:SetPoint("CENTER", UIParent, "CENTER", 0, 60)
	elseif msg == "options" then
		MTH_OpenOptions("Pet")
	elseif msg == "verify" then
		zButtonPet_DebugVerify()
	else
		MTH_ZH_Print("Possible Commands: \"options\", \"reset\", \"verify\"")
	end
end