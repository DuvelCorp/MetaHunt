local function AntiDaze_Print(msg)
	if MTH and MTH.Print then
		MTH:Print(msg)
	elseif DEFAULT_CHAT_FRAME and DEFAULT_CHAT_FRAME.AddMessage then
		DEFAULT_CHAT_FRAME:AddMessage(tostring(msg))
	end
end

local function AntiDaze_GetSaved()
	if type(MTH_CharSavedVariables) ~= "table" then
		MTH_CharSavedVariables = {}
	end
	if type(MTH_CharSavedVariables.antiDaze) ~= "table" then
		MTH_CharSavedVariables.antiDaze = {}
	end
	return MTH_CharSavedVariables.antiDaze
end

local function AntiDaze_IsEnabled()
	local saved = AntiDaze_GetSaved()
	return saved["enabled"] and true or false
end

local function AntiDaze_RegisterCombatEvents()
	if not AntiDazeFrame then
		return
	end
	if MTH and MTH.nampower then
		AntiDazeFrame:RegisterEvent("DEBUFF_ADDED_SELF")
	else
		AntiDazeFrame:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE")
		AntiDazeFrame:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE")
		AntiDazeFrame:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE")
		AntiDazeFrame:RegisterEvent("CHAT_MSG_SPELL_PARTY_DAMAGE")
	end
end

local function AntiDaze_UnregisterCombatEvents()
	if not AntiDazeFrame then
		return
	end
	AntiDazeFrame:UnregisterEvent("DEBUFF_ADDED_SELF")
	AntiDazeFrame:UnregisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE")
	AntiDazeFrame:UnregisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE")
	AntiDazeFrame:UnregisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE")
	AntiDazeFrame:UnregisterEvent("CHAT_MSG_SPELL_PARTY_DAMAGE")
end

function AntiDaze_SetEnabled(enabled, silent)
	local saved = AntiDaze_GetSaved()
	if enabled then
		saved["enabled"] = 1
		AntiDaze_RegisterCombatEvents()
		if not silent then
			AntiDaze_Print("AntiDaze enabled.")
		end
	else
		saved["enabled"] = nil
		AntiDaze_UnregisterCombatEvents()
		if not silent then
			AntiDaze_Print("AntiDaze disabled.")
		end
	end
end

function AntiDaze_GetEnabled()
	return AntiDaze_IsEnabled()
end

local function AntiDaze_ResolvePlayerFromMessage(msg)
	local afflictedPattern = _G["ZHUNTER_AFFLICTED_DAZED"] or "(.+) (.+) afflicted by Dazed"
	local _, _, player = string.find(msg or "", afflictedPattern)
	if player then
		return player
	end

	local lowerMsg = string.lower(msg or "")
	if string.find(lowerMsg, "dazed", 1, true) or string.find(lowerMsg, "daze", 1, true) then
		local playerName = UnitName("player")
		if string.find(msg or "", "You", 1, true) or (playerName and string.find(msg or "", playerName, 1, true)) then
			return _G["ZHUNTER_YOU"] or "You"
		end

		for i = 1, GetNumPartyMembers() do
			local partyName = UnitName("party" .. i)
			if partyName and string.find(msg or "", partyName, 1, true) then
				return partyName
			end
		end
	end

	return nil
end

local AntiDaze_DazeSpellIdCache = {}  -- [spellId] = true/false

local function AntiDaze_IsDazeSpellId(spellId)
	local cached = AntiDaze_DazeSpellIdCache[spellId]
	if cached ~= nil then return cached end
	if type(GetSpellRecField) ~= "function" then return false end
	local name = GetSpellRecField(spellId, "name")
	if name and (name == "Daze" or name == "Dazed") then
		AntiDaze_DazeSpellIdCache[spellId] = true
		return true
	end
	AntiDaze_DazeSpellIdCache[spellId] = false
	return false
end

local function AntiDaze_CancelRelevantAspect(isSelfDazed)
	local packName = _G["ZHUNTER_ASPECT_PACK"] or "Aspect of the Pack"
	local cheetahName = _G["ZHUNTER_ASPECT_CHEETAH"] or "Aspect of the Cheetah"

	-- Always use GetPlayerBuff + tooltip scan for cancellation.
	-- The aura-array slot index from GetUnitField does NOT map 1:1
	-- to the sequential buff index that CancelPlayerBuff expects
	-- (empty slots create gaps), so we cannot use the NamPower
	-- array for the cancel call. NamPower is still used for daze
	-- DETECTION via DEBUFF_ADDED_SELF in the event handler.
	for i = 0, 32 do
		if GetPlayerBuff(i, "HELPFUL") < 0 then
			break
		end

		AntiDazeTooltip:SetOwner(UIParent, "ANCHOR_NONE")
		AntiDazeTooltip:SetPlayerBuff(i, "HELPFUL")
		local text = MTH_AntiDazeProbeTextLeft1 and MTH_AntiDazeProbeTextLeft1:GetText()
		if text == packName or (isSelfDazed and text == cheetahName) then
			CancelPlayerBuff(i)
			return 1
		end
	end

	return nil
end

local function AntiDaze_HandleSlash()
	AntiDaze_SetEnabled(not AntiDaze_IsEnabled())
end

AntiDazeTooltip = CreateFrame("GameTooltip", "MTH_AntiDazeProbe", nil, "GameTooltipTemplate")
AntiDazeFrame = CreateFrame("Frame", "MTH_AntiDazeEvent")
if AntiDazeFrame then
	AntiDazeFrame:RegisterEvent("VARIABLES_LOADED")
	AntiDazeFrame:SetScript("OnEvent", function()
		if event == "VARIABLES_LOADED" then
			-- Class gate: only hunters use AntiDaze.
			if MTH and MTH.IsClassGateBlocked and MTH:IsClassGateBlocked() then
				AntiDazeFrame:UnregisterAllEvents()
				AntiDazeFrame:SetScript("OnEvent", nil)
				return
			end
			if AntiDaze_IsEnabled() then
				AntiDaze_RegisterCombatEvents()
			else
				AntiDaze_UnregisterCombatEvents()
			end
			return
		end

		-- NamPower path: DEBUFF_ADDED_SELF fires with spellId in arg3
		if event == "DEBUFF_ADDED_SELF" then
			local spellId = tonumber(arg3)
			if spellId and AntiDaze_IsDazeSpellId(spellId) then
				AntiDaze_CancelRelevantAspect(true)
			end
			return
		end

		-- Legacy path: parse chat messages
		local player = AntiDaze_ResolvePlayerFromMessage(arg1)
		if player then
			local you = _G["ZHUNTER_YOU"] or "You"
			local group = {}
			group[you] = 1
			for i = 1, GetNumPartyMembers() do
				group[UnitName("party" .. i)] = 1
			end
			if group[player] then
				AntiDaze_CancelRelevantAspect(player == you)
			end
		end
	end)
end

SLASH_ANTIDAZE1 = "/antidaze"
SlashCmdList["ANTIDAZE"] = AntiDaze_HandleSlash
SLASH_ZANTIDAZE1 = "/zantidaze"
SlashCmdList["ZANTIDAZE"] = AntiDaze_HandleSlash
