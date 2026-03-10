------------------------------------------------------
-- MetaHunt: Quest Automation Module
-- SHIFT-rightclick automation for specific quest flows
------------------------------------------------------

local MTH_AutoQuest = {
	name = "autoquest",
	enabled = false,
	version = "1.2.0",
	events = {
		"GOSSIP_SHOW",
		"QUEST_GREETING",
		"QUEST_DETAIL",
		"QUEST_PROGRESS",
		"QUEST_COMPLETE",
	},
	initialized = false,
}

local QA_SCORPOK_QUEST_ID = 2586
local QA_SCORPOK_QUEST_TITLE = "Salt of the Scorpok"
local QA_SCORPOK_NPC_ID = 7505
local QA_SCORPOK_NPC_NAME = "Bloodmage Drazial"
local QA_SISSIES_QUEST_ID = 7342
local QA_SISSIES_QUEST_TITLE = "Arrows Are For Sissies"
local QA_SISSIES_NPC_ID = 14183
local QA_SISSIES_NPC_NAME = "Artilleryman Sheldonore"
local QA_ITEM_SCORPOK_PINCER_ID = 8393
local QA_ITEM_BLASTED_BOAR_LUNG_ID = 8392
local QA_ITEM_VULTURE_GIZZARD_ID = 8396
local QA_ITEM_GROUND_SCORPOK_ASSAY_ID = 8412
local QA_ITEM_SCORPOK_PINCER_NAME = "Scorpok Pincer"
local QA_ITEM_BLASTED_BOAR_LUNG_NAME = "Blasted Boar Lung"
local QA_ITEM_VULTURE_GIZZARD_NAME = "Vulture Gizzard"
local QA_ITEM_GROUND_SCORPOK_ASSAY_NAME = "Ground Scorpok Assay"

local QA_TooltipHooked = false
local QA_TooltipPollFrame = nil
local QA_TooltipRefreshFrame = nil

local function QA_Debug(message)
	return
end

local function QA_CopyValue(value)
	if type(value) ~= "table" then
		return value
	end
	local copy = {}
	for key, entry in pairs(value) do
		copy[key] = QA_CopyValue(entry)
	end
	return copy
end

local function QA_GetOptionsStore()
	if type(MTH_CharSavedVariables) ~= "table" then
		MTH_CharSavedVariables = {}
	end
	if type(MTH_CharSavedVariables.autoquest) ~= "table" then
		MTH_CharSavedVariables.autoquest = {}
	end
	local store = MTH_CharSavedVariables.autoquest

	if store._migrated ~= true then
		if type(MTH_CharSavedVariables.questautomation) == "table" then
			local legacyStore = MTH_CharSavedVariables.questautomation
			if legacyStore.scorpokDrazial ~= nil and store.scorpokDrazial == nil then
				store.scorpokDrazial = legacyStore.scorpokDrazial and true or false
			end
			if legacyStore.scorpokTooltip ~= nil and store.scorpokTooltip == nil then
				store.scorpokTooltip = legacyStore.scorpokTooltip and true or false
			end
		end
		local legacyChar = nil
		local legacyAccount = nil
		if MTH and MTH.GetModuleCharSavedVariables then
			legacyChar = MTH:GetModuleCharSavedVariables("autoquest")
			if type(legacyChar) ~= "table" then
				legacyChar = MTH:GetModuleCharSavedVariables("questautomation")
			end
		end
		if MTH and MTH.GetModuleSavedVariables then
			legacyAccount = MTH:GetModuleSavedVariables("autoquest")
			if type(legacyAccount) ~= "table" then
				legacyAccount = MTH:GetModuleSavedVariables("questautomation")
			end
		end
		if type(legacyChar) == "table" and legacyChar.scorpokDrazial ~= nil and store.scorpokDrazial == nil then
			store.scorpokDrazial = legacyChar.scorpokDrazial and true or false
		elseif type(legacyAccount) == "table" and legacyAccount.scorpokDrazial ~= nil and store.scorpokDrazial == nil then
			store.scorpokDrazial = legacyAccount.scorpokDrazial and true or false
		elseif store.scorpokDrazial == nil and MTH and MTH.GetModuleCharSavedVariables then
			local autobuyStore = MTH:GetModuleCharSavedVariables("autobuy")
			if type(autobuyStore) == "table"
				and type(autobuyStore.questAutomation) == "table"
				and autobuyStore.questAutomation.scorpokDrazial ~= nil then
				store.scorpokDrazial = autobuyStore.questAutomation.scorpokDrazial and true or false
			end
		end
		store._migrated = true
	end

	if store.scorpokDrazial == nil then
		store.scorpokDrazial = false
	end
	if store.arrowsForSissies == nil then
		store.arrowsForSissies = false
	end
	if store.scorpokTooltip == nil then
		store.scorpokTooltip = false
	end

	if MTH and MTH.GetModuleCharSavedVariables then
		local moduleStore = MTH:GetModuleCharSavedVariables("autoquest")
		if type(moduleStore) == "table" then
			moduleStore.scorpokDrazial = store.scorpokDrazial and true or false
			moduleStore.arrowsForSissies = store.arrowsForSissies and true or false
			moduleStore.scorpokTooltip = store.scorpokTooltip and true or false
		end
	end

	return store
end

function MTH_AutoQuest:GetStore()
	return QA_GetOptionsStore()
end

function MTH_AutoQuest:SetScorpokDrazialEnabled(enabled)
	local store = QA_GetOptionsStore()
	store.scorpokDrazial = enabled and true or false
	if MTH and MTH.GetModuleCharSavedVariables then
		local moduleStore = MTH:GetModuleCharSavedVariables("autoquest")
		if type(moduleStore) == "table" then
			moduleStore.scorpokDrazial = store.scorpokDrazial and true or false
		end
	end
	QA_Debug("option write: scorpokDrazial=" .. tostring(store.scorpokDrazial and true or false))
end

function MTH_AutoQuest:SetArrowsForSissiesEnabled(enabled)
	local store = QA_GetOptionsStore()
	store.arrowsForSissies = enabled and true or false
	if MTH and MTH.GetModuleCharSavedVariables then
		local moduleStore = MTH:GetModuleCharSavedVariables("autoquest")
		if type(moduleStore) == "table" then
			moduleStore.arrowsForSissies = store.arrowsForSissies and true or false
		end
	end
	QA_Debug("option write: arrowsForSissies=" .. tostring(store.arrowsForSissies and true or false))
end

function MTH_AutoQuest:SetScorpokTooltipEnabled(enabled)
	local store = QA_GetOptionsStore()
	store.scorpokTooltip = enabled and true or false
	if MTH and MTH.GetModuleCharSavedVariables then
		local moduleStore = MTH:GetModuleCharSavedVariables("autoquest")
		if type(moduleStore) == "table" then
			moduleStore.scorpokTooltip = store.scorpokTooltip and true or false
		end
	end
	QA_Debug("option write: scorpokTooltip=" .. tostring(store.scorpokTooltip and true or false))
end

local function QA_IsScorpokAutomationEnabled()
	local store = QA_GetOptionsStore()
	return store and store.scorpokDrazial and true or false
end

local function QA_IsArrowsForSissiesAutomationEnabled()
	local store = QA_GetOptionsStore()
	return store and store.arrowsForSissies and true or false
end

local function QA_IsScorpokTooltipEnabled()
	local store = QA_GetOptionsStore()
	return store and store.scorpokTooltip and true or false
end

local function QA_NormalizeText(value)
	local text = string.lower(tostring(value or ""))
	text = string.gsub(text, "[^%a%d]", "")
	return text
end

local function QA_IsTitleMatch(title, expectedTitle)
	if type(title) ~= "string" or title == "" then
		return false
	end
	return QA_NormalizeText(title) == QA_NormalizeText(expectedTitle)
end

local function QA_IsScorpokTitle(title)
	return QA_IsTitleMatch(title, QA_SCORPOK_QUEST_TITLE)
end

local function QA_IsArrowsForSissiesTitle(title)
	return QA_IsTitleMatch(title, QA_SISSIES_QUEST_TITLE)
end

local function QA_IsQuestContext(title, expectedQuestId, titleMatcher)
	if type(GetQuestID) == "function" then
		local questId = tonumber(GetQuestID())
		if questId and questId == expectedQuestId then
			return true
		end
	end
	if type(titleMatcher) == "function" then
		return titleMatcher(title)
	end
	return false
end

local function QA_IsScorpokQuestContext(title)
	return QA_IsQuestContext(title, QA_SCORPOK_QUEST_ID, QA_IsScorpokTitle)
end

local function QA_IsArrowsForSissiesQuestContext(title)
	return QA_IsQuestContext(title, QA_SISSIES_QUEST_ID, QA_IsArrowsForSissiesTitle)
end

local function QA_GetNpcIdFromGuid(guid)
	if type(guid) ~= "string" or guid == "" then
		return nil
	end

	local _, _, _, _, _, npcId = string.find(guid, "^Creature%-%d+%-%d+%-%d+%-%d+%-(%d+)%-%x+$")
	if npcId then
		return tonumber(npcId)
	end

	if string.sub(guid, 1, 2) == "0x" and string.len(guid) >= 12 then
		local hex = string.sub(guid, 9, 12)
		local parsed = tonumber(hex, 16)
		if parsed and parsed > 0 then
			return parsed
		end
	end

	return nil
end

local function QA_ColorByThreshold(count, threshold)
	local value = math.floor(tonumber(count) or 0)
	if value <= 0 then
		return "|cffff0000" .. tostring(value) .. "|r"
	end
	local modFn = nil
	if type(rawget) == "function" and type(math) == "table" then
		modFn = rawget(math, "mod") or rawget(math, "fmod")
	elseif type(math) == "table" then
		modFn = math.fmod
	end
	if threshold > 0 and type(modFn) == "function" and modFn(value, threshold) == 0 then
		return "|cff00ff00" .. tostring(value) .. "|r"
	end
	return "|cffffa500" .. tostring(value) .. "|r"
end

local function QA_ColorAssay(count)
	local value = math.floor(tonumber(count) or 0)
	if value > 0 then
		return "|cff66ccff" .. tostring(value) .. "|r"
	end
	return tostring(value)
end

local function QA_MatchesItem(itemId, itemName, expectedId, expectedName)
	if expectedId and tonumber(itemId) == tonumber(expectedId) then
		return true
	end
	if type(itemName) == "string" and type(expectedName) == "string" and QA_NormalizeText(itemName) == QA_NormalizeText(expectedName) then
		return true
	end
	return false
end

local function QA_CountItemInBags(expectedId, expectedName)
	local getContainerNumSlots = _G and _G["GetContainerNumSlots"] or nil
	local getContainerItemLink = _G and _G["GetContainerItemLink"] or nil
	local getContainerItemInfo = _G and _G["GetContainerItemInfo"] or nil
	local getItemInfo = _G and _G["GetItemInfo"] or nil
	if type(getContainerNumSlots) ~= "function" or type(getContainerItemLink) ~= "function" then
		return 0
	end

	local total = 0
	for bag = 0, 4 do
		local slots = math.floor(tonumber(getContainerNumSlots(bag)) or 0)
		for slot = 1, slots do
			local link = getContainerItemLink(bag, slot)
			if type(link) == "string" and link ~= "" then
				local _, _, itemIdStr = string.find(link, "item:(%d+)")
				local itemId = tonumber(itemIdStr)
				local itemName = nil
				if type(getItemInfo) == "function" then
					itemName = getItemInfo(link)
				end
				if QA_MatchesItem(itemId, itemName, expectedId, expectedName) then
					local texture, stackCount = nil, nil
					if type(getContainerItemInfo) == "function" then
						texture, stackCount = getContainerItemInfo(bag, slot)
					end
					total = total + math.floor(tonumber(stackCount) or 1)
				end
			end
		end
	end

	return total
end

local function QA_TooltipTrace(message, force)
	return
end

local function QA_GetTooltipNpc(tooltip)
	if not tooltip or type(tooltip.GetUnit) ~= "function" then
		return nil, nil, nil, nil
	end
	local ok, unitA, unitB = pcall(function()
		return tooltip:GetUnit()
	end)
	local unit = nil
	if ok then
		if type(unitB) == "string" and unitB ~= "" then
			unit = unitB
		elseif type(unitA) == "string" and unitA ~= "" then
			unit = unitA
		end
	end
	if (type(unit) ~= "string" or unit == "") and type(UnitExists) == "function" and UnitExists("mouseover") then
		unit = "mouseover"
	end
	if type(unit) ~= "string" or unit == "" then
		local left1 = (type(getglobal) == "function" and getglobal("GameTooltipTextLeft1")) or (_G and _G["GameTooltipTextLeft1"])
		local title = left1 and left1.GetText and left1:GetText() or nil
		if type(title) == "string" and title ~= "" then
			return nil, title, nil, title
		end
		return nil, nil, nil, nil
	end
	local guid = UnitGUID and UnitGUID(unit) or nil
	local npcId = QA_GetNpcIdFromGuid(guid)
	local name = UnitName and UnitName(unit) or nil
	local title = nil
	if (type(name) ~= "string" or name == "") then
		local left1 = (type(getglobal) == "function" and getglobal("GameTooltipTextLeft1")) or (_G and _G["GameTooltipTextLeft1"])
		title = left1 and left1.GetText and left1:GetText() or nil
		if type(title) == "string" and title ~= "" then
			name = title
		end
	end
	return npcId, name, unit, title
end

local function QA_TooltipAlreadyExtended(tooltip)
	if not tooltip or type(tooltip.NumLines) ~= "function" then
		return false
	end
	local lines = math.floor(tonumber(tooltip:NumLines()) or 0)
	for i = 1, lines do
		local line = (type(getglobal) == "function" and getglobal("GameTooltipTextLeft" .. tostring(i))) or (_G and _G["GameTooltipTextLeft" .. tostring(i)])
		local text = line and line.GetText and line:GetText() or nil
		if type(text) == "string" and QA_NormalizeText(text) == QA_NormalizeText("Quest Automation") then
			return true
		end
	end
	return false
end

local function QA_IsTooltipDrazial(tooltip)
	local npcId, npcName = QA_GetTooltipNpc(tooltip)
	if tonumber(npcId) == QA_SCORPOK_NPC_ID then
		return true
	end
	if type(npcName) == "string" and npcName ~= "" and QA_NormalizeText(npcName) == QA_NormalizeText(QA_SCORPOK_NPC_NAME) then
		return true
	end
	return false
end

local function QA_AppendDrazialTooltip(tooltip, sourceTag)
	sourceTag = tostring(sourceTag or "unknown")
	if not (MTH_AutoQuest and MTH_AutoQuest.enabled) then
		QA_TooltipTrace("skip: module disabled source=" .. sourceTag)
		return
	end
	if not QA_IsScorpokAutomationEnabled() or not QA_IsScorpokTooltipEnabled() then
		QA_TooltipTrace("skip: option disabled source=" .. sourceTag)
		return
	end
	local npcId, npcName, unitToken, title = QA_GetTooltipNpc(tooltip)
	local isMatch = tonumber(npcId) == QA_SCORPOK_NPC_ID
	if not isMatch and type(npcName) == "string" and npcName ~= "" and QA_NormalizeText(npcName) == QA_NormalizeText(QA_SCORPOK_NPC_NAME) then
		isMatch = true
	end
	if not isMatch then
		QA_TooltipTrace("skip: npc mismatch source=" .. sourceTag
			.. " unit=" .. tostring(unitToken)
			.. " id=" .. tostring(npcId)
			.. " name='" .. tostring(npcName or "") .. "'"
			.. " title='" .. tostring(title or "") .. "'")
		return
	end
	if QA_TooltipAlreadyExtended(tooltip) then
		QA_TooltipTrace("skip: already-extended source=" .. sourceTag)
		return
	end

	local pincerCount = QA_CountItemInBags(QA_ITEM_SCORPOK_PINCER_ID, QA_ITEM_SCORPOK_PINCER_NAME)
	local gizzardCount = QA_CountItemInBags(QA_ITEM_VULTURE_GIZZARD_ID, QA_ITEM_VULTURE_GIZZARD_NAME)
	local lungCount = QA_CountItemInBags(QA_ITEM_BLASTED_BOAR_LUNG_ID, QA_ITEM_BLASTED_BOAR_LUNG_NAME)
	local assayCount = QA_CountItemInBags(QA_ITEM_GROUND_SCORPOK_ASSAY_ID, QA_ITEM_GROUND_SCORPOK_ASSAY_NAME)

	tooltip:AddLine(" ")
	tooltip:AddLine("|cffffff00Quest Automation|r")
	tooltip:AddLine("Scorpok Pincer: " .. QA_ColorByThreshold(pincerCount, 3), 1, 1, 1)
	tooltip:AddLine("Vulture Gizzard: " .. QA_ColorByThreshold(gizzardCount, 2), 1, 1, 1)
	tooltip:AddLine("Blasted Boar Lung: " .. QA_ColorByThreshold(lungCount, 1), 1, 1, 1)
	tooltip:AddLine("Ground Scorpok Assay: " .. QA_ColorAssay(assayCount), 1, 1, 1)
	tooltip:AddLine("Spam SHIFT-click!", 0.7, 0.9, 1)
	tooltip:AddLine("Recipes: 3x Pincer, 2x Gizzard, 1x Lung", 0.7, 0.7, 0.7)
	tooltip:Show()
	QA_TooltipTrace("added: source=" .. sourceTag
		.. " id=" .. tostring(npcId)
		.. " name='" .. tostring(npcName or "") .. "'", true)
end

local function QA_EnsureTooltipHook()
	if QA_TooltipHooked then
		return
	end
	if not GameTooltip then
		return
	end

	local hasGetScript = type(GameTooltip.GetScript) == "function"
	local hasSetScript = type(GameTooltip.SetScript) == "function"
	local hasHookScript = type(GameTooltip.HookScript) == "function"

	local onTooltipSetUnitExists = false
	local onShowExists = false
	if hasGetScript then
		local okSetUnit, existingSetUnit = pcall(function()
			return GameTooltip:GetScript("OnTooltipSetUnit")
		end)
		onTooltipSetUnitExists = okSetUnit and type(existingSetUnit) == "function"

		local okShow, existingShow = pcall(function()
			return GameTooltip:GetScript("OnShow")
		end)
		onShowExists = okShow and type(existingShow) == "function"
	end

	if hasHookScript and onTooltipSetUnitExists then
		pcall(function()
			GameTooltip:HookScript("OnTooltipSetUnit", function()
				QA_AppendDrazialTooltip(this, "hook:setunit")
			end)
		end)
	elseif hasSetScript and hasGetScript and onTooltipSetUnitExists then
		local okGetPrev, previous = pcall(function()
			return GameTooltip:GetScript("OnTooltipSetUnit")
		end)
		if okGetPrev then
			pcall(function()
				GameTooltip:SetScript("OnTooltipSetUnit", function()
					if type(previous) == "function" then
						previous()
					end
					QA_AppendDrazialTooltip(this, "script:setunit")
				end)
			end)
		end
	end

	if hasHookScript and onShowExists then
		pcall(function()
			GameTooltip:HookScript("OnShow", function()
				QA_AppendDrazialTooltip(this, "hook:show")
			end)
		end)
	elseif hasSetScript and hasGetScript and onShowExists then
		local okGetPrevShow, previousShow = pcall(function()
			return GameTooltip:GetScript("OnShow")
		end)
		if okGetPrevShow then
			pcall(function()
				GameTooltip:SetScript("OnShow", function()
					if type(previousShow) == "function" then
						previousShow()
					end
					QA_AppendDrazialTooltip(this, "script:show")
				end)
			end)
		end
	end

	QA_TooltipHooked = true
end

local function QA_EnsureTooltipPoller()
	if QA_TooltipPollFrame then
		return
	end
	local frame = CreateFrame("Frame", "MTH_AQTooltipPoll")
	if not frame then
		return
	end
	frame._mthElapsed = 0
	frame:SetScript("OnUpdate", function()
		this._mthElapsed = (this._mthElapsed or 0) + (arg1 or 0)
		if this._mthElapsed < 0.20 then
			return
		end
		this._mthElapsed = 0
		if not (MTH_AutoQuest and MTH_AutoQuest.enabled) then
			return
		end
		if GameTooltip and type(GameTooltip.IsVisible) == "function" and GameTooltip:IsVisible() then
			QA_AppendDrazialTooltip(GameTooltip, "poll")
		end
	end)
	QA_TooltipPollFrame = frame
end

local function QA_GetInteractedNpcId()
	local getGuid = _G and _G["UnitGUID"] or nil
	if type(getGuid) ~= "function" then
		return nil
	end
	local npcGuid = getGuid("npc")
	local npcId = QA_GetNpcIdFromGuid(npcGuid)
	if npcId then
		return npcId
	end
	return QA_GetNpcIdFromGuid(getGuid("target"))
end

local function QA_GetInteractedNpcName()
	local getName = _G and _G["UnitName"] or nil
	if type(getName) ~= "function" then
		return nil
	end
	local name = getName("npc")
	if type(name) == "string" and name ~= "" then
		return name
	end
	name = getName("target")
	if type(name) == "string" and name ~= "" then
		return name
	end
	return nil
end

local function QA_IsInteractedNpc(expectedNpcId, expectedNpcName)
	local npcId = QA_GetInteractedNpcId()
	if tonumber(npcId) == tonumber(expectedNpcId) then
		return true
	end
	local npcName = QA_GetInteractedNpcName()
	if type(npcName) == "string" and npcName ~= "" and QA_NormalizeText(npcName) == QA_NormalizeText(expectedNpcName) then
		return true
	end
	return false
end

local function QA_IsScorpokNpc()
	return QA_IsInteractedNpc(QA_SCORPOK_NPC_ID, QA_SCORPOK_NPC_NAME)
end

local function QA_IsArrowsForSissiesNpc()
	return QA_IsInteractedNpc(QA_SISSIES_NPC_ID, QA_SISSIES_NPC_NAME)
end

local function QA_RefreshMouseoverTooltip()
	local tooltip = _G and _G["GameTooltip"] or GameTooltip
	if not tooltip then
		return
	end
	if type(UnitExists) == "function" and UnitExists("mouseover") and type(tooltip.SetUnit) == "function" then
		tooltip:SetUnit("mouseover")
		if type(tooltip.Show) == "function" then
			tooltip:Show()
		end
	end
end

local function QA_RequestTooltipRefresh(delaySeconds)
	delaySeconds = tonumber(delaySeconds) or 0.10
	if not QA_TooltipRefreshFrame then
		QA_TooltipRefreshFrame = CreateFrame("Frame", "MTH_AQTooltipRefresh")
		if not QA_TooltipRefreshFrame then
			return
		end
		QA_TooltipRefreshFrame:SetScript("OnUpdate", function()
			local frameRef = this or QA_TooltipRefreshFrame
			if not frameRef then
				return
			end
			frameRef._elapsed = (frameRef._elapsed or 0) + (arg1 or 0)
			if frameRef._elapsed < (frameRef._delay or 0.10) then
				return
			end
			frameRef._elapsed = 0
			frameRef._delay = 0
			frameRef:SetScript("OnUpdate", nil)
			QA_RefreshMouseoverTooltip()
		end)
	end
	QA_TooltipRefreshFrame._delay = delaySeconds
	QA_TooltipRefreshFrame._elapsed = 0
	QA_TooltipRefreshFrame:SetScript("OnUpdate", QA_TooltipRefreshFrame:GetScript("OnUpdate"))
end

local QA_PROFILE_SCORPOK = {
	key = "scorpokDrazial",
	label = "Scorpok",
	optionCheck = QA_IsScorpokAutomationEnabled,
	npcCheck = QA_IsScorpokNpc,
	titleCheck = QA_IsScorpokTitle,
	questContextCheck = QA_IsScorpokQuestContext,
	lastActionField = "_scorpokLastActionAt",
	refreshTooltipOnComplete = true,
}

local QA_PROFILE_SISSIES = {
	key = "arrowsForSissies",
	label = "ArrowsForSissies",
	optionCheck = QA_IsArrowsForSissiesAutomationEnabled,
	npcCheck = QA_IsArrowsForSissiesNpc,
	titleCheck = QA_IsArrowsForSissiesTitle,
	questContextCheck = QA_IsArrowsForSissiesQuestContext,
	lastActionField = "_sissiesLastActionAt",
	refreshTooltipOnComplete = false,
}

local QA_LastActionAt = {}

local function QA_GetLastActionAt(profile)
	local key = type(profile) == "table" and tostring(profile.lastActionField or "") or ""
	if key == "" then
		return 0
	end
	return tonumber(QA_LastActionAt[key]) or 0
end

local function QA_SetLastActionAt(profile, value)
	local key = type(profile) == "table" and tostring(profile.lastActionField or "") or ""
	if key == "" then
		return
	end
	QA_LastActionAt[key] = tonumber(value) or 0
end

local function QA_CanRunProfile(profile)
	if type(profile) ~= "table" then
		return false
	end
	if type(profile.optionCheck) ~= "function" or not profile.optionCheck() then
		QA_Debug("[" .. tostring(profile.label or "AutoQuest") .. "] skip: option disabled")
		return false
	end
	if type(IsShiftKeyDown) ~= "function" or not IsShiftKeyDown() then
		QA_Debug("[" .. tostring(profile.label or "AutoQuest") .. "] skip: SHIFT not held")
		return false
	end
	local npcOk = type(profile.npcCheck) == "function" and profile.npcCheck() or false
	if not npcOk then
		QA_Debug("[" .. tostring(profile.label or "AutoQuest") .. "] skip: NPC mismatch (id=" .. tostring(QA_GetInteractedNpcId()) .. ", name='" .. tostring(QA_GetInteractedNpcName() or "") .. "')")
	end
	return npcOk
end

local function QA_FindGossipQuestIndex(rawEntries, count, profile)
	if type(rawEntries) ~= "table" or tonumber(count) == nil or tonumber(count) <= 0 then
		return nil
	end
	if type(profile) ~= "table" or type(profile.titleCheck) ~= "function" then
		return nil
	end
	local entryCount = math.floor(tonumber(count) or 0)
	local tupleSize = math.floor(table.getn(rawEntries) / entryCount)
	if tupleSize < 1 then
		tupleSize = 1
	end
	for i = 1, entryCount do
		local title = tostring(rawEntries[((i - 1) * tupleSize) + 1] or "")
		if profile.titleCheck(title) then
			return i
		end
	end
	if entryCount == 1 and type(profile.npcCheck) == "function" and profile.npcCheck() then
		QA_Debug("[" .. tostring(profile.label or "AutoQuest") .. "] gossip fallback: single quest entry -> selecting index 1")
		return 1
	end
	return nil
end

local function QA_FindQuestGreetingIndex(isActive, profile)
	local getCount = isActive and _G and _G["GetNumActiveQuests"] or _G and _G["GetNumAvailableQuests"]
	local getTitle = isActive and _G and _G["GetActiveTitle"] or _G and _G["GetAvailableTitle"]
	if type(getCount) ~= "function" or type(getTitle) ~= "function" or type(profile) ~= "table" or type(profile.titleCheck) ~= "function" then
		return nil
	end
	local count = math.floor(tonumber(getCount()) or 0)
	if count <= 0 then
		return nil
	end
	for i = 1, count do
		local title = tostring(getTitle(i) or "")
		if profile.titleCheck(title) then
			return i
		end
	end
	if count == 1 and type(profile.npcCheck) == "function" and profile.npcCheck() then
		QA_Debug("[" .. tostring(profile.label or "AutoQuest") .. "] quest greeting fallback: single quest entry -> selecting index 1")
		return 1
	end
	return nil
end

local function QA_GetFrameText(frame)
	if type(frame) ~= "table" then
		return ""
	end
	if type(frame.GetText) == "function" then
		return tostring(frame:GetText() or "")
	end
	if type(frame.GetName) == "function" then
		local name = frame:GetName()
		if type(name) == "string" and name ~= "" then
			local textRegion = _G and _G[name .. "Text"] or nil
			if textRegion and type(textRegion.GetText) == "function" then
				return tostring(textRegion:GetText() or "")
			end
		end
	end
	return ""
end

local function QA_ClickGossipTitleButtonFallback(profile)
	if type(profile) ~= "table" or type(profile.titleCheck) ~= "function" then
		return false
	end
	for i = 1, 40 do
		local button = _G and _G["GossipTitleButton" .. tostring(i)] or nil
		if button then
			local visible = true
			if type(button.IsVisible) == "function" then
				visible = button:IsVisible() and true or false
			end
			if visible then
				local title = QA_GetFrameText(button)
				if profile.titleCheck(title) then
					QA_Debug("action: GossipTitleButton" .. tostring(i) .. " click title='" .. tostring(title) .. "'")
					if type(button.Click) == "function" then
						button:Click()
						return true
					end
					local onClick = type(button.GetScript) == "function" and button:GetScript("OnClick") or nil
					if type(onClick) == "function" then
						onClick(button)
						return true
					end
				end
			end
		end
	end
	return false
end

local function QA_RunProfileAutomation(eventName, profile)
	if type(profile) ~= "table" then
		return
	end
	QA_Debug("[" .. tostring(profile.label or "AutoQuest") .. "] event=" .. tostring(eventName))
	if not QA_CanRunProfile(profile) then
		return
	end

	local getTimeFn = _G and _G["GetTime"] or nil
	if eventName == "GOSSIP_SHOW" and type(getTimeFn) == "function" then
		local now = tonumber(getTimeFn()) or 0
		local last = QA_GetLastActionAt(profile)
		if (now - last) < 0.05 then
			QA_Debug("skip: throttled dt=" .. tostring(now - last))
			return
		end
	end

	if eventName == "QUEST_GREETING" then
		local selectAvailableQuest = _G and _G["SelectAvailableQuest"] or nil
		local selectActiveQuest = _G and _G["SelectActiveQuest"] or nil
		local availableIndex = QA_FindQuestGreetingIndex(false, profile)
		if availableIndex and type(selectAvailableQuest) == "function" then
			QA_Debug("action: SelectAvailableQuest (compat) index=" .. tostring(availableIndex))
			selectAvailableQuest()
			QA_SetLastActionAt(profile, type(getTimeFn) == "function" and getTimeFn() or 0)
			return
		end
		local activeIndex = QA_FindQuestGreetingIndex(true, profile)
		if activeIndex and type(selectActiveQuest) == "function" then
			QA_Debug("action: SelectActiveQuest (compat) index=" .. tostring(activeIndex))
			selectActiveQuest()
			QA_SetLastActionAt(profile, type(getTimeFn) == "function" and getTimeFn() or 0)
			return
		end
		for i = 1, 40 do
			local button = _G and _G["QuestTitleButton" .. tostring(i)] or nil
			if button and (type(button.IsVisible) ~= "function" or button:IsVisible()) then
				local title = QA_GetFrameText(button)
				if profile.titleCheck(title) then
					QA_Debug("action: QuestTitleButton" .. tostring(i) .. " click title='" .. tostring(title) .. "'")
					if type(button.Click) == "function" then
						button:Click()
						QA_SetLastActionAt(profile, type(getTimeFn) == "function" and getTimeFn() or 0)
						return
					end
				end
			end
		end
		QA_Debug("quest greeting: no action taken")
		return
	end

	if eventName == "GOSSIP_SHOW" then
		local getNumGossipAvailableQuests = _G and _G["GetNumGossipAvailableQuests"] or nil
		local getGossipAvailableQuests = _G and _G["GetGossipAvailableQuests"] or nil
		local selectGossipAvailableQuest = _G and _G["SelectGossipAvailableQuest"] or nil
		QA_Debug("api available: numAvail=" .. tostring(type(getNumGossipAvailableQuests) == "function")
			.. " getAvail=" .. tostring(type(getGossipAvailableQuests) == "function")
			.. " selAvail=" .. tostring(type(selectGossipAvailableQuest) == "function"))
		if type(getNumGossipAvailableQuests) == "function" and type(getGossipAvailableQuests) == "function" and type(selectGossipAvailableQuest) == "function" then
			local availableCount = math.floor(tonumber(getNumGossipAvailableQuests()) or 0)
			QA_Debug("gossip available count=" .. tostring(availableCount))
			if availableCount > 0 then
				local availableIndex = QA_FindGossipQuestIndex({ getGossipAvailableQuests() }, availableCount, profile)
				if availableIndex then
					QA_Debug("action: SelectGossipAvailableQuest index=" .. tostring(availableIndex))
					selectGossipAvailableQuest(availableIndex)
					QA_SetLastActionAt(profile, type(getTimeFn) == "function" and getTimeFn() or 0)
					return
				end
				QA_Debug("gossip available: no Scorpok match")
			end
		end
		local getNumGossipActiveQuests = _G and _G["GetNumGossipActiveQuests"] or nil
		local getGossipActiveQuests = _G and _G["GetGossipActiveQuests"] or nil
		local selectGossipActiveQuest = _G and _G["SelectGossipActiveQuest"] or nil
		QA_Debug("api active: numActive=" .. tostring(type(getNumGossipActiveQuests) == "function")
			.. " getActive=" .. tostring(type(getGossipActiveQuests) == "function")
			.. " selActive=" .. tostring(type(selectGossipActiveQuest) == "function"))
		if type(getNumGossipActiveQuests) == "function" and type(getGossipActiveQuests) == "function" and type(selectGossipActiveQuest) == "function" then
			local activeCount = math.floor(tonumber(getNumGossipActiveQuests()) or 0)
			QA_Debug("gossip active count=" .. tostring(activeCount))
			if activeCount > 0 then
				local activeIndex = QA_FindGossipQuestIndex({ getGossipActiveQuests() }, activeCount, profile)
				if activeIndex then
					QA_Debug("action: SelectGossipActiveQuest index=" .. tostring(activeIndex))
					selectGossipActiveQuest(activeIndex)
					QA_SetLastActionAt(profile, type(getTimeFn) == "function" and getTimeFn() or 0)
					return
				end
				QA_Debug("gossip active: no Scorpok match")
			end
		end
		if QA_ClickGossipTitleButtonFallback(profile) then
			QA_SetLastActionAt(profile, type(getTimeFn) == "function" and getTimeFn() or 0)
			return
		end
		QA_Debug("gossip: no action taken")
		return
	end

	local title = type(GetTitleText) == "function" and tostring(GetTitleText() or "") or ""
	QA_Debug("quest frame title='" .. tostring(title) .. "'")
	if type(profile.questContextCheck) ~= "function" or not profile.questContextCheck(title) then
		QA_Debug("skip: quest context mismatch")
		return
	end

	if eventName == "QUEST_DETAIL" then
		if type(AcceptQuest) == "function" then
			QA_Debug("action: AcceptQuest")
			AcceptQuest()
			QA_SetLastActionAt(profile, type(getTimeFn) == "function" and getTimeFn() or 0)
		end
	elseif eventName == "QUEST_PROGRESS" then
		if type(CompleteQuest) == "function" then
			if type(IsQuestCompletable) ~= "function" or IsQuestCompletable() then
				QA_Debug("action: CompleteQuest")
				CompleteQuest()
				QA_SetLastActionAt(profile, type(getTimeFn) == "function" and getTimeFn() or 0)
			else
				QA_Debug("skip: quest not completable yet")
			end
		end
	elseif eventName == "QUEST_COMPLETE" then
		if type(GetQuestReward) == "function" then
			local choices = type(GetNumQuestChoices) == "function" and math.floor(tonumber(GetNumQuestChoices()) or 0) or 0
			if choices <= 1 then
				QA_Debug("action: GetQuestReward(1)")
				GetQuestReward(1)
				QA_SetLastActionAt(profile, type(getTimeFn) == "function" and getTimeFn() or 0)
				if profile.refreshTooltipOnComplete then
					QA_RequestTooltipRefresh(0.10)
				end
			else
				QA_Debug("skip: multiple reward choices=" .. tostring(choices))
			end
		end
	end
end

-- NOTE: QA_DirectEventFrame removed (Phase 2 fix #22b)
-- The central event router already dispatches GOSSIP_SHOW, QUEST_GREETING,
-- QUEST_DETAIL, QUEST_PROGRESS, QUEST_COMPLETE to MTH_AutoQuest:onEvent().
-- Having a second frame register the same events caused double-dispatch.

function MTH_AutoQuest:init()
	local store = QA_GetOptionsStore()
	self.initialized = true
	QA_Debug("init: module active=" .. tostring(self.enabled and true or false)
		.. ", option scorpokDrazial=" .. tostring(store and store.scorpokDrazial and true or false)
		.. ", option arrowsForSissies=" .. tostring(store and store.arrowsForSissies and true or false)
		.. ", option scorpokTooltip=" .. tostring(store and store.scorpokTooltip and true or false))
end

function MTH_AutoQuest:setEnabled(enabled)
	self.enabled = enabled and true or false
end

function MTH_AutoQuest:onEvent(eventName)
	if eventName == "GOSSIP_SHOW"
		or eventName == "QUEST_GREETING"
		or eventName == "QUEST_DETAIL"
		or eventName == "QUEST_PROGRESS"
		or eventName == "QUEST_COMPLETE" then
		QA_Debug("onEvent=" .. tostring(eventName))
		QA_RunProfileAutomation(eventName, QA_PROFILE_SCORPOK)
		QA_RunProfileAutomation(eventName, QA_PROFILE_SISSIES)
	end
end

function MTH_AutoQuest:cleanup()
	-- no-op: direct event frame removed in Phase 2
end

MTH:RegisterModule("autoquest", MTH_AutoQuest)
