local function AutoStrip_Print(msg)
	if MTH and MTH.Print then
		MTH:Print(msg)
	elseif DEFAULT_CHAT_FRAME and DEFAULT_CHAT_FRAME.AddMessage then
		DEFAULT_CHAT_FRAME:AddMessage(tostring(msg))
	end
end

local AutoStrip_TraceEnabled = false

local function AutoStrip_Trace(msg)
	if not AutoStrip_TraceEnabled then
		return
	end
	AutoStrip_Print("[ASTRACE] " .. tostring(msg))
end

function AutoStrip_CommandTrace(mode)
	local action = string.lower(tostring(mode or "status"))
	if action == "on" or action == "1" or action == "true" then
		AutoStrip_TraceEnabled = true
		AutoStrip_Trace("trace enabled")
		return
	elseif action == "off" or action == "0" or action == "false" then
		AutoStrip_Trace("trace disabled")
		AutoStrip_TraceEnabled = false
		return
	end
	AutoStrip_Print("[ASTRACE] status=" .. tostring(AutoStrip_TraceEnabled and true or false))
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
local AutoStrip_RestoreFrame = nil

local function AutoStrip_DescribePoint(frame)
	if not (frame and frame.GetPoint) then
		return "<no-frame>"
	end
	local point, relTo, relPoint, x, y = frame:GetPoint()
	local relName = "nil"
	if type(relTo) == "table" and relTo.GetName then
		relName = tostring(relTo:GetName() or "<anon>")
	elseif relTo then
		relName = tostring(relTo)
	end
	return tostring(point or "nil")
		.. "->" .. relName
		.. ":" .. tostring(relPoint or "nil")
		.. " @(" .. tostring(x) .. "," .. tostring(y) .. ")"
end

function AutoStrip_SaveDisplayPosition(reason)
	if not (AutoStripDisplay and AutoStripDisplay.GetPoint) then
		return
	end
	local saved = AutoStrip_GetSaved()
	local point, _, relPoint, x, y = AutoStripDisplay:GetPoint()
	x = tonumber(x)
	y = tonumber(y)
	if not (point and relPoint and x and y) then
		return
	end
	saved["point"] = tostring(point)
	saved["relativePoint"] = tostring(relPoint)
	saved["x"] = math.floor(x + 0.5)
	saved["y"] = math.floor(y + 0.5)
	AutoStrip_Trace("persist-display-position reason=" .. tostring(reason or "")
		.. " point=" .. tostring(saved["point"])
		.. " rel=" .. tostring(saved["relativePoint"])
		.. " x=" .. tostring(saved["x"])
		.. " y=" .. tostring(saved["y"]))
end

local function AutoStrip_RestoreDisplayPosition(reason)
	if not (AutoStripDisplay and AutoStripDisplay.ClearAllPoints and AutoStripDisplay.SetPoint) then
		return false
	end
	local saved = AutoStrip_GetSaved()
	local point = tostring(saved["point"] or "")
	local relPoint = tostring(saved["relativePoint"] or "")
	local x = tonumber(saved["x"])
	local y = tonumber(saved["y"])
	if point == "" or not x or not y then
		AutoStrip_Trace("restore-display-position skipped reason=" .. tostring(reason or "")
			.. " savedPoint=" .. tostring(saved["point"])
			.. " savedX=" .. tostring(saved["x"])
			.. " savedY=" .. tostring(saved["y"]))
		return false
	end
	if relPoint == "" then
		relPoint = point
	end
	AutoStripDisplay:ClearAllPoints()
	AutoStripDisplay:SetPoint(point, UIParent, relPoint, x, y)
	AutoStrip_Trace("restore-display-position reason=" .. tostring(reason or "")
		.. " frame=" .. AutoStrip_DescribePoint(AutoStripDisplay))
	return true
end

local function AutoStrip_QueueDeferredRestore(reason)
	if not AutoStrip_RestoreFrame then
		AutoStrip_RestoreFrame = CreateFrame("Frame", "AutoStripRestoreFrame")
		if not AutoStrip_RestoreFrame then
			return
		end
	end
	AutoStrip_RestoreFrame._elapsed = 0
	AutoStrip_RestoreFrame:SetScript("OnUpdate", function()
		this._elapsed = (this._elapsed or 0) + (arg1 or 0)
		if this._elapsed < 0.2 then
			return
		end
		this:SetScript("OnUpdate", nil)
		AutoStrip_RestoreDisplayPosition("deferred:" .. tostring(reason or ""))
	end)
end

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
	AutoStrip_Trace("SetAutoStripToggle enabled=" .. tostring(enabled and true or false)
		.. " silent=" .. tostring(silent and true or false)
		.. " savedBefore=" .. tostring(saved["autostrip"] and 1 or 0)
		.. " runtimeBefore=" .. tostring(AutoStrip_On and 1 or 0)
		.. " castShownBefore=" .. tostring((AutoStripDisplayAutoCast and AutoStripDisplayAutoCast:IsVisible()) and 1 or 0))
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
	AutoStrip_Trace("SetAutoStripToggle savedAfter=" .. tostring(saved["autostrip"] and 1 or 0)
		.. " runtimeAfter=" .. tostring(AutoStrip_On and 1 or 0)
		.. " castShownAfter=" .. tostring((AutoStripDisplayAutoCast and AutoStripDisplayAutoCast:IsVisible()) and 1 or 0))
end

function AutoStrip_SetDisplayToggle(enabled, silent)
	local saved = AutoStrip_GetSaved()
	AutoStrip_Trace("SetDisplayToggle enabled=" .. tostring(enabled and true or false)
		.. " silent=" .. tostring(silent and true or false)
		.. " savedDisplayBefore=" .. tostring(saved["display"] and 1 or 0)
		.. " frameShownBefore=" .. tostring((AutoStripDisplay and AutoStripDisplay:IsVisible()) and 1 or 0))
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
	AutoStrip_Trace("SetDisplayToggle savedDisplayAfter=" .. tostring(saved["display"] and 1 or 0)
		.. " frameShownAfter=" .. tostring((AutoStripDisplay and AutoStripDisplay:IsVisible()) and 1 or 0)
		.. " castShownAfter=" .. tostring((AutoStripDisplayAutoCast and AutoStripDisplayAutoCast:IsVisible()) and 1 or 0))
end

function AutoStrip_UnequipAll(weaponsOnly)
	AutoStrip_Trace("UnequipAll called weaponsOnly=" .. tostring(weaponsOnly and 1 or 0)
		.. " runtimeBefore=" .. tostring(AutoStrip_On and 1 or 0)
		.. " wasInCombat=" .. tostring(AutoStrip_WasInCombat and 1 or 0))
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
		AutoStrip_Trace("UnequipAll aborted no-empty-slot")
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
	AutoStrip_Trace("UnequipAll completed runtimeAfter=" .. tostring(AutoStrip_On and 1 or 0)
		.. " castShownAfter=" .. tostring((AutoStripDisplayAutoCast and AutoStripDisplayAutoCast:IsVisible()) and 1 or 0))
end

local function AutoStrip_OnEvent()
	AutoStrip_Trace("OnEvent evt=" .. tostring(event or "")
		.. " runtime=" .. tostring(AutoStrip_On and 1 or 0)
		.. " wasInCombat=" .. tostring(AutoStrip_WasInCombat and 1 or 0)
		.. " playerInCombat=" .. tostring((type(UnitAffectingCombat) == "function" and UnitAffectingCombat("player")) and 1 or 0))
	if event == "VARIABLES_LOADED" then
		local saved = AutoStrip_GetSaved()
		AutoStrip_Trace("VARIABLES_LOADED saved.autostrip=" .. tostring(saved["autostrip"] and 1 or 0)
			.. " saved.display=" .. tostring(saved["display"] and 1 or 0))
		AutoStrip_WasInCombat = UnitAffectingCombat("player") and 1 or nil
		AutoStrip_RestoreDisplayPosition("VARIABLES_LOADED")
		AutoStrip_SetDisplayToggle(saved["display"] and true or false, 1)
		AutoStrip_SetAutoStripToggle(saved["autostrip"] and true or false, 1)
		AutoStrip_QueueDeferredRestore("VARIABLES_LOADED")
		return
	end

	if event == "PLAYER_ENTERING_WORLD" then
		AutoStrip_WasInCombat = UnitAffectingCombat("player") and 1 or nil
		AutoStrip_RestoreDisplayPosition("PLAYER_ENTERING_WORLD")
		AutoStrip_QueueDeferredRestore("PLAYER_ENTERING_WORLD")
		return
	end

	if event == "PLAYER_LOGOUT" then
		AutoStrip_SaveDisplayPosition("PLAYER_LOGOUT")
		return
	end

	if event == "PLAYER_REGEN_DISABLED" then
		AutoStrip_WasInCombat = 1
		return
	end

	if event == "PLAYER_REGEN_ENABLED" then
		if AutoStrip_On and AutoStrip_WasInCombat then
			AutoStrip_Trace("PLAYER_REGEN_ENABLED triggering auto strip")
			AutoStrip_UnequipAll()
		end
		AutoStrip_WasInCombat = nil
	end
end

local function AutoStrip_HandleSlash(msg)
	local saved = AutoStrip_GetSaved()
	AutoStrip_Trace("Slash msg='" .. tostring(msg or "") .. "' saved.autostrip=" .. tostring(saved["autostrip"] and 1 or 0)
		.. " runtime=" .. tostring(AutoStrip_On and 1 or 0))
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
	AutoStrip_Frame:RegisterEvent("PLAYER_LOGOUT")
	AutoStrip_Frame:SetScript("OnEvent", AutoStrip_OnEvent)
end

if AutoStripDisplay then
	AutoStrip_SetDisplayIcon()
end

SLASH_AUTOSTRIP1 = "/autostrip"
SlashCmdList["AUTOSTRIP"] = AutoStrip_HandleSlash
SLASH_ZSTRIP1 = "/zstrip"
SlashCmdList["ZSTRIP"] = AutoStrip_HandleSlash
SLASH_AUTOSTRIPTRACE1 = "/autostriptrace"
SLASH_AUTOSTRIPTRACE2 = "/astrace"
SlashCmdList["AUTOSTRIPTRACE"] = function(msg)
	AutoStrip_CommandTrace(msg)
end
