local function AutoStrip_Print(msg)
	if MTH and MTH.Print then
		MTH:Print(msg)
	elseif DEFAULT_CHAT_FRAME and DEFAULT_CHAT_FRAME.AddMessage then
		DEFAULT_CHAT_FRAME:AddMessage(tostring(msg))
	end
end

function AutoStrip_GetSaved()
	if type(MTH_CharSavedVariables) ~= "table" then
		MTH_CharSavedVariables = {}
	end
	if type(MTH_CharSavedVariables.autoStrip) ~= "table" then
		MTH_CharSavedVariables.autoStrip = {}
	end
	return MTH_CharSavedVariables.autoStrip
end

local AUTO_STRIP_ORDER = {16, 17, 18, 5, 7, 1, 3, 10, 8, 6, 9}
AutoStrip_On = nil
AutoStrip_WasInCombat = nil
AutoStrip_Frame = nil

function AutoStrip_SetDisplayIcon()
	local icon = getglobal("AutoStripDisplayIcon") or getglobal("AutoStripDisplayIconTexture")
	if icon then
		icon:SetTexture("Interface\\Icons\\Ability_Creature_Cursed_02")
		icon:Show()
	end
end

function AutoStrip_GetEnabled()
	return AutoStrip_On and true or false
end

function AutoStrip_SetAutoStripToggle(enabled, silent)
	local saved = AutoStrip_GetSaved()
	if enabled then
		saved["autostrip"] = 1
		AutoStrip_On = 1
		if AutoStripDisplay and AutoStripDisplay:IsVisible() and AutoStripDisplayAutoCast then
			AutoStripDisplayAutoCast:Show()
		end
		if not silent then
			AutoStrip_Print("Auto-Strip enabled.")
		end
	else
		saved["autostrip"] = nil
		AutoStrip_On = nil
		if AutoStripDisplayAutoCast then
			AutoStripDisplayAutoCast:Hide()
		end
		if not silent then
			AutoStrip_Print("Auto-Strip disabled.")
		end
	end
end

function AutoStrip_SetDisplayToggle(enabled, silent)
	local saved = AutoStrip_GetSaved()
	if enabled then
		saved["display"] = 1
		if AutoStripDisplay then
			AutoStripDisplay:Show()
			AutoStrip_SetDisplayIcon()
			if AutoStrip_On and AutoStripDisplayAutoCast then
				AutoStripDisplayAutoCast:Show()
			end
		end
		if not silent then
			AutoStrip_Print("AutoStrip button is now visible.")
		end
	else
		saved["display"] = nil
		if AutoStripDisplay then
			AutoStripDisplay:Hide()
		end
		if not silent then
			AutoStrip_Print("AutoStrip button is now hidden.")
		end
	end
end

function AutoStrip_UnequipAll(weaponsOnly)
	AutoStrip_On = nil
	if AutoStripDisplayAutoCast then
		AutoStripDisplayAutoCast:Hide()
	end

	local hasEmptySlot = nil
	for bag = 0, 4 do
		for slot = 1, GetContainerNumSlots(bag) do
			if not GetContainerItemLink(bag, slot) then
				hasEmptySlot = 1
				break
			end
		end
		if hasEmptySlot then
			break
		end
	end

	if not hasEmptySlot then
		AutoStrip_Print("You need at least one empty bag slot to auto-strip.")
		return
	end

	local startIndex = 1
	local finishIndex = weaponsOnly and 3 or table.getn(AUTO_STRIP_ORDER)
	for bag = 0, 4 do
		for slot = 1, GetContainerNumSlots(bag) do
			if not GetContainerItemLink(bag, slot) then
				for index = startIndex, finishIndex do
					if GetInventoryItemLink("player", AUTO_STRIP_ORDER[index]) then
						PickupInventoryItem(AUTO_STRIP_ORDER[index])
						PickupContainerItem(bag, slot)
						startIndex = index + 1
						break
					end
				end
			end
		end
	end
end

local function AutoStrip_OnEvent()
	if event == "VARIABLES_LOADED" then
		local saved = AutoStrip_GetSaved()
		AutoStrip_WasInCombat = UnitAffectingCombat("player") and 1 or nil
		AutoStrip_SetDisplayToggle(saved["display"] and true or false, 1)
		AutoStrip_SetAutoStripToggle(saved["autostrip"] and true or false, 1)
		return
	end

	if event == "PLAYER_ENTERING_WORLD" then
		AutoStrip_WasInCombat = UnitAffectingCombat("player") and 1 or nil
		return
	end

	if event == "PLAYER_REGEN_DISABLED" then
		AutoStrip_WasInCombat = 1
		return
	end

	if event == "PLAYER_REGEN_ENABLED" then
		if AutoStrip_On and AutoStrip_WasInCombat then
			AutoStrip_UnequipAll()
		end
		AutoStrip_WasInCombat = nil
	end
end

local function AutoStrip_HandleSlash(msg)
	local saved = AutoStrip_GetSaved()
	if msg == "display" then
		AutoStrip_SetDisplayToggle(not (saved["display"] and true or false))
	elseif msg == "toggle" then
		local enableAutoStrip = not AutoStrip_GetEnabled()
		if enableAutoStrip and not saved["display"] then
			AutoStrip_SetDisplayToggle(true, 1)
		end
		AutoStrip_SetAutoStripToggle(enableAutoStrip, 1)
		if enableAutoStrip then
			AutoStrip_Print("You will strip when you leave combat.")
		else
			AutoStrip_Print("You will no longer strip when you leave combat.")
		end
	else
		AutoStrip_Print("Possible Commands: \"display\", \"toggle\"")
	end
end

AutoStrip_Frame = CreateFrame("Frame", "AutoStripFrame")
if AutoStrip_Frame then
	AutoStrip_Frame:RegisterEvent("VARIABLES_LOADED")
	AutoStrip_Frame:RegisterEvent("PLAYER_REGEN_DISABLED")
	AutoStrip_Frame:RegisterEvent("PLAYER_REGEN_ENABLED")
	AutoStrip_Frame:RegisterEvent("PLAYER_ENTERING_WORLD")
	AutoStrip_Frame:SetScript("OnEvent", AutoStrip_OnEvent)
end

if AutoStripDisplay then
	AutoStrip_SetDisplayIcon()
end

SLASH_AUTOSTRIP1 = "/autostrip"
SlashCmdList["AUTOSTRIP"] = AutoStrip_HandleSlash
SLASH_ZSTRIP1 = "/zstrip"
SlashCmdList["ZSTRIP"] = AutoStrip_HandleSlash
