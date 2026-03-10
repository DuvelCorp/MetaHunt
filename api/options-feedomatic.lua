local MTH_FOM_READY = MTH_OptionsRequire and MTH_OptionsRequire("options-feedomatic", {
	"MTH_GetFrame",
	"MTH_ClearContainer",
	"MTH_CreateCheckbox",
})

local MTH_FOM_STATE = {
	enableCheck = nil,
	keepOpenEdit = nil,
	bindStatus = nil,
	bindButton = nil,
	bindClearButton = nil,
	bindingCapture = false,
	ctrl = {},
}

local function MTH_FOM_L(key, default)
	if MTH and MTH.GetLocalization then
		return MTH:GetLocalization(key, default)
	end
	return default or key
end

local function MTH_EnsureFOMConfig()
	if FOM_Config then
		return
	end

	if FOM_Config_Default then
		FOM_Config = {}
		for key, value in pairs(FOM_Config_Default) do
			FOM_Config[key] = value
		end
		return
	end

	FOM_Config = {
		Enabled = false,
		Alert = "emote",
		Level = "content",
		KeepOpenSlots = 8,
		AvoidUsefulFood = true,
		AvoidQuestFood = true,
		AvoidBonusFood = true,
		Fallback = false,
		SaveForCookingLevel = 1,
		PreferHigherQuality = true,
		AudioWarning = true,
		TextWarning = true,
		IconWarning = true,
	}
end

local function MTH_FOM_SetAlert(mode)
	MTH_EnsureFOMConfig()
	if mode == "none" then
		FOM_Config.Alert = nil
	else
		FOM_Config.Alert = mode
	end
end

local function MTH_FOM_SetLevel(level)
	MTH_EnsureFOMConfig()
	if level == "off" then
		FOM_Config.Level = nil
	else
		FOM_Config.Level = level
	end
end

local function MTH_FOM_SetCookingLevel(level)
	MTH_EnsureFOMConfig()
	FOM_Config.SaveForCookingLevel = level
end

local function MTH_FOM_GetBindingDisplayText()
	if not GetBindingKey then
		return MTH_FOM_L("FOM_BIND_UNAVAILABLE", "Unavailable")
	end
	local key1, key2 = GetBindingKey("FEEDOMATIC")
	if not key1 and not key2 then
		return MTH_FOM_L("FOM_BIND_UNBOUND", "Unbound")
	end
	if key1 and key2 then
		return key1 .. " / " .. key2
	end
	return key1 or key2 or MTH_FOM_L("FOM_BIND_UNBOUND", "Unbound")
end

local function MTH_FOM_UpdateBindingStatus()
	local bindStatus = MTH_FOM_STATE.bindStatus
	if not bindStatus or not bindStatus.SetText then
		return
	end
	if MTH_FOM_STATE.bindingCapture then
		bindStatus:SetText(MTH_FOM_L("FOM_BIND_STATUS_PROMPT", "Feed key: press a key... (ESC to clear)"))
	else
		bindStatus:SetText(string.format(MTH_FOM_L("FOM_BIND_STATUS_VALUE", "Feed key: %s"), MTH_FOM_GetBindingDisplayText()))
	end
end

local function MTH_FOM_StopBindingCapture()
	MTH_FOM_STATE.bindingCapture = false
	if MTH_FOM_STATE.bindButton then
		if MTH_FOM_STATE.bindButton.SetPropagateKeyboardInput then
			MTH_FOM_STATE.bindButton:SetPropagateKeyboardInput(true)
		end
		MTH_FOM_STATE.bindButton:EnableKeyboard(false)
		MTH_FOM_STATE.bindButton:SetText(MTH_FOM_L("FOM_BIND_SET_KEY", "Set Key"))
	end
	MTH_FOM_UpdateBindingStatus()
end

local function MTH_FOM_StartBindingCapture()
	MTH_FOM_STATE.bindingCapture = true
	if MTH_FOM_STATE.bindButton then
		MTH_FOM_STATE.bindButton:SetText(MTH_FOM_L("FOM_BIND_PRESS_KEY", "Press key..."))
		MTH_FOM_STATE.bindButton:EnableKeyboard(true)
		if MTH_FOM_STATE.bindButton.SetPropagateKeyboardInput then
			MTH_FOM_STATE.bindButton:SetPropagateKeyboardInput(false)
		end
	end
	MTH_FOM_UpdateBindingStatus()
end

local function MTH_FOM_BuildBindingChord(key)
	local chord = ""
	if IsControlKeyDown and IsControlKeyDown() and key ~= "LCTRL" and key ~= "RCTRL" then chord = chord .. "CTRL-" end
	if IsAltKeyDown and IsAltKeyDown() and key ~= "LALT" and key ~= "RALT" then chord = chord .. "ALT-" end
	if IsShiftKeyDown and IsShiftKeyDown() and key ~= "LSHIFT" and key ~= "RSHIFT" then chord = chord .. "SHIFT-" end
	return chord .. key
end

local function MTH_FOM_SaveBinding(key)
	if not SetBinding or not SaveBindings or not GetBindingKey then
		if MTH and MTH.Print then
			MTH:Print(MTH_FOM_L("FOM_ERROR_KEYBIND_API_UNAVAILABLE", "Keybinding APIs unavailable."))
		end
		return
	end
	if InCombatLockdown and InCombatLockdown() then
		if MTH and MTH.Print then
			MTH:Print(MTH_FOM_L("FOM_ERROR_KEYBIND_COMBAT_LOCKED", "Cannot change keybindings during combat."))
		end
		MTH_FOM_StopBindingCapture()
		return
	end

	local old1, old2 = GetBindingKey("FEEDOMATIC")
	if old1 then SetBinding(old1) end
	if old2 then SetBinding(old2) end

	if key and key ~= "" and key ~= "ESCAPE" then
		SetBinding(key, "FEEDOMATIC")
	end

	local bindingSet = 1
	if GetCurrentBindingSet then
		bindingSet = GetCurrentBindingSet() or 1
	end
	SaveBindings(bindingSet)
	MTH_FOM_StopBindingCapture()
end

function MTH_RefreshFeedOMaticOptions()
	if not MTH_FOM_READY then return end
	MTH_EnsureFOMConfig()

	if MTH_FOM_STATE.enableCheck then
		local module = MTH and MTH:GetModule("feedomatic")
		MTH_FOM_STATE.enableCheck:SetChecked(module and module.enabled and true or false)
	end

	if MTH_FOM_STATE.keepOpenEdit then
		MTH_FOM_STATE.keepOpenEdit:SetText(tostring(FOM_Config.KeepOpenSlots or 0))
	end

	MTH_FOM_UpdateBindingStatus()

	if MTH_FOM_STATE.ctrl.AvoidQuestFood then MTH_FOM_STATE.ctrl.AvoidQuestFood:SetChecked(FOM_Config.AvoidQuestFood and 1 or nil) end
	if MTH_FOM_STATE.ctrl.AvoidBonusFood then MTH_FOM_STATE.ctrl.AvoidBonusFood:SetChecked(FOM_Config.AvoidBonusFood and 1 or nil) end
	if MTH_FOM_STATE.ctrl.PreferHigherQuality then MTH_FOM_STATE.ctrl.PreferHigherQuality:SetChecked(FOM_Config.PreferHigherQuality and 1 or nil) end
	if MTH_FOM_STATE.ctrl.Fallback then MTH_FOM_STATE.ctrl.Fallback:SetChecked(FOM_Config.Fallback and 1 or nil) end
	if MTH_FOM_STATE.ctrl.AudioWarning then MTH_FOM_STATE.ctrl.AudioWarning:SetChecked(FOM_Config.AudioWarning and true or false) end
	if MTH_FOM_STATE.ctrl.AudioWarningBell then MTH_FOM_STATE.ctrl.AudioWarningBell:SetChecked(FOM_Config.AudioWarning == "bell" and 1 or nil) end
	if MTH_FOM_STATE.ctrl.TextWarning then MTH_FOM_STATE.ctrl.TextWarning:SetChecked(FOM_Config.TextWarning and 1 or nil) end
	if MTH_FOM_STATE.ctrl.IconWarning then MTH_FOM_STATE.ctrl.IconWarning:SetChecked(FOM_Config.IconWarning and 1 or nil) end

	if MTH_FOM_STATE.ctrl.AlertEmote then MTH_FOM_STATE.ctrl.AlertEmote:SetChecked(FOM_Config.Alert == "emote" and 1 or nil) end
	if MTH_FOM_STATE.ctrl.AlertChat then MTH_FOM_STATE.ctrl.AlertChat:SetChecked(FOM_Config.Alert == "chat" and 1 or nil) end
	if MTH_FOM_STATE.ctrl.AlertNone then MTH_FOM_STATE.ctrl.AlertNone:SetChecked((not FOM_Config.Alert) and 1 or nil) end

	if MTH_FOM_STATE.ctrl.LevelContent then MTH_FOM_STATE.ctrl.LevelContent:SetChecked(FOM_Config.Level == "content" and 1 or nil) end
	if MTH_FOM_STATE.ctrl.LevelUnhappy then MTH_FOM_STATE.ctrl.LevelUnhappy:SetChecked(FOM_Config.Level == "unhappy" and 1 or nil) end
	if MTH_FOM_STATE.ctrl.LevelOff then MTH_FOM_STATE.ctrl.LevelOff:SetChecked((not FOM_Config.Level) and 1 or nil) end

	if MTH_FOM_STATE.ctrl.SaveCookOrange then MTH_FOM_STATE.ctrl.SaveCookOrange:SetChecked(FOM_Config.SaveForCookingLevel == 3 and 1 or nil) end
	if MTH_FOM_STATE.ctrl.SaveCookYellow then MTH_FOM_STATE.ctrl.SaveCookYellow:SetChecked(FOM_Config.SaveForCookingLevel == 2 and 1 or nil) end
	if MTH_FOM_STATE.ctrl.SaveCookGreen then MTH_FOM_STATE.ctrl.SaveCookGreen:SetChecked(FOM_Config.SaveForCookingLevel == 1 and 1 or nil) end
	if MTH_FOM_STATE.ctrl.SaveCookAll then MTH_FOM_STATE.ctrl.SaveCookAll:SetChecked(FOM_Config.SaveForCookingLevel == 0 and 1 or nil) end
	if MTH_FOM_STATE.ctrl.SaveCookNone then MTH_FOM_STATE.ctrl.SaveCookNone:SetChecked(FOM_Config.SaveForCookingLevel and FOM_Config.SaveForCookingLevel >= 4 and 1 or nil) end
end

function MTH_SetupFeedOMaticOptions()
	if not MTH_FOM_READY then return end
	local container = MTH_GetFrame("MetaHuntOptionsFeedOMatic")
	if not container then return end
	local rightColumnX = 300
	local yAdjust = -64

	MTH_ClearContainer(container)
	MTH_FOM_STATE.ctrl = {}

	local title = container:CreateFontString("MetaHuntOptionsFeedOMaticTitle", "ARTWORK", "GameFontHighlight")
	title:SetPoint("TOPLEFT", container, "TOPLEFT", 20, -10)
	title:SetText(MTH_FOM_L("FOM_TITLE", "Feed-O-Matic"))

	local statusNotice = container:CreateFontString("MetaHuntOptionsFeedOMaticStatusNotice", "ARTWORK", "GameFontNormalSmall")
	statusNotice:SetPoint("TOPLEFT", container, "TOPLEFT", 20, -34)
	statusNotice:SetWidth(600)
	statusNotice:SetJustifyH("LEFT")
	statusNotice:SetJustifyV("TOP")
	statusNotice:SetTextColor(0.35, 0.65, 1)
	statusNotice:SetText(MTH_FOM_L("FOM_STATUS_NOTICE", "Feed-O-Matic, created by the great Fizzwidget, is not yet entirely ready for TurtleWoW because I am missing \na reliable list of all foods, mostly impossible to fetch from the DB.\n It still works much better in this version, but all stuff related to Food buff and Cooking isnt fully functional."))

	local moduleCheck = MTH_CreateCheckbox(container, "MetaHuntOptionsFeedOMaticEnabled", MTH_FOM_L("FOM_ENABLE_MODULE", "Enable FeedOMatic module"), -32 + yAdjust)
	if moduleCheck then
		moduleCheck:SetScript("OnClick", function()
			if not this then return end
			local enabled = this:GetChecked() == 1
			if MTH and MTH.SetModuleEnabled then
				local ok, err = MTH:SetModuleEnabled("feedomatic", enabled)
				if not ok and MTH and MTH.Print then
					MTH:Print(string.format(MTH_FOM_L("FOM_ERROR_TOGGLE_FAILED", "Failed to change FeedOMatic state: %s"), tostring(err)))
				end
			end
			MTH_RefreshFeedOMaticOptions()
		end)
		MTH_FOM_STATE.enableCheck = moduleCheck
	end

	local leftHeader = container:CreateFontString("MetaHuntOptionsFeedOMaticGeneralHeader", "ARTWORK", "GameFontHighlight")
	leftHeader:SetPoint("TOPLEFT", container, "TOPLEFT", 20, -62 + yAdjust)
	leftHeader:SetText(MTH_FOM_L("FOM_HEADER_GENERAL", "General"))

	local bindStatus = container:CreateFontString("MetaHuntOptionsFOMBindStatus", "ARTWORK", "GameFontNormalSmall")
	bindStatus:SetPoint("TOPLEFT", container, "TOPLEFT", 20, -80 + yAdjust)
	bindStatus:SetText(string.format(MTH_FOM_L("FOM_BIND_STATUS_VALUE", "Feed key: %s"), MTH_FOM_GetBindingDisplayText()))
	MTH_FOM_STATE.bindStatus = bindStatus

	local bindButton = CreateFrame("Button", "MetaHuntOptionsFOMBindButton", container, "UIPanelButtonTemplate")
	bindButton:SetPoint("TOPLEFT", container, "TOPLEFT", 20, -100 + yAdjust)
	bindButton:SetWidth(90)
	bindButton:SetHeight(22)
	bindButton:SetText(MTH_FOM_L("FOM_BIND_SET_KEY", "Set Key"))
	bindButton:EnableKeyboard(false)
	bindButton:SetScript("OnClick", function()
		if MTH_FOM_STATE.bindingCapture then
			MTH_FOM_StopBindingCapture()
		else
			MTH_FOM_StartBindingCapture()
		end
	end)
	bindButton:SetScript("OnKeyDown", function()
		if not MTH_FOM_STATE.bindingCapture then
			return
		end
		local key = arg1
		if not key or key == "" then
			return
		end
		if key == "ESCAPE" then
			MTH_FOM_SaveBinding(nil)
			return
		end
		if key == "UNKNOWN" or key == "PRINTSCREEN" then
			return
		end
		MTH_FOM_SaveBinding(MTH_FOM_BuildBindingChord(key))
	end)
	MTH_FOM_STATE.bindButton = bindButton

	local bindClearButton = CreateFrame("Button", "MetaHuntOptionsFOMBindClearButton", container, "UIPanelButtonTemplate")
	bindClearButton:SetPoint("LEFT", bindButton, "RIGHT", 8, 0)
	bindClearButton:SetWidth(70)
	bindClearButton:SetHeight(22)
	bindClearButton:SetText(MTH_FOM_L("FOM_BIND_CLEAR", "Clear"))
	bindClearButton:SetScript("OnClick", function()
		MTH_FOM_SaveBinding(nil)
	end)
	MTH_FOM_STATE.bindClearButton = bindClearButton

	local bindHint = container:CreateFontString("MetaHuntOptionsFOMBindHint", "ARTWORK", "GameFontNormalSmall")
	bindHint:SetPoint("TOPLEFT", container, "TOPLEFT", 20, -128 + yAdjust)
	bindHint:SetWidth(360)
	bindHint:SetJustifyH("LEFT")
	bindHint:SetJustifyV("TOP")
	bindHint:SetTextColor(0.35, 0.65, 1)
	bindHint:SetText(MTH_FOM_L("FOM_BIND_HINT", "You should assign a key bind for feed-o-matic,\nin order to feed your pet automatically.\nThe key \"P\" is an excellent candidate !"))

	MTH_FOM_STATE.ctrl.AvoidQuestFood = MTH_CreateCheckbox(container, "MetaHuntOptionsFOMAvoidQuest", FOM_OptionsButtonText and FOM_OptionsButtonText["AvoidQuestFood"] or MTH_FOM_L("FOM_LABEL_AVOID_QUEST_FOODS", "Avoid quest foods"), -170 + yAdjust)
	MTH_FOM_STATE.ctrl.AvoidBonusFood = MTH_CreateCheckbox(container, "MetaHuntOptionsFOMAvoidBonus", FOM_OptionsButtonText and FOM_OptionsButtonText["AvoidBonusFood"] or MTH_FOM_L("FOM_LABEL_AVOID_BONUS_FOODS", "Avoid bonus foods"), -195 + yAdjust)
	MTH_FOM_STATE.ctrl.PreferHigherQuality = MTH_CreateCheckbox(container, "MetaHuntOptionsFOMPreferQuality", FOM_OptionsButtonText and FOM_OptionsButtonText["PreferHigherQuality"] or MTH_FOM_L("FOM_LABEL_PREFER_HIGHER_QUALITY_FOOD", "Prefer higher quality food"), -220 + yAdjust)
	MTH_FOM_STATE.ctrl.Fallback = MTH_CreateCheckbox(container, "MetaHuntOptionsFOMFallback", FOM_OptionsButtonText and FOM_OptionsButtonText["Fallback"] or MTH_FOM_L("FOM_LABEL_FALLBACK_TO_AVOIDED_FOODS", "Fallback to avoided foods"), -245 + yAdjust)

	if MTH_FOM_STATE.ctrl.AvoidQuestFood then MTH_FOM_STATE.ctrl.AvoidQuestFood:SetScript("OnClick", function() if not this then return end FOM_Config.AvoidQuestFood = this:GetChecked() == 1 end) end
	if MTH_FOM_STATE.ctrl.AvoidBonusFood then MTH_FOM_STATE.ctrl.AvoidBonusFood:SetScript("OnClick", function() if not this then return end FOM_Config.AvoidBonusFood = this:GetChecked() == 1 end) end
	if MTH_FOM_STATE.ctrl.PreferHigherQuality then MTH_FOM_STATE.ctrl.PreferHigherQuality:SetScript("OnClick", function() if not this then return end FOM_Config.PreferHigherQuality = this:GetChecked() == 1 end) end
	if MTH_FOM_STATE.ctrl.Fallback then MTH_FOM_STATE.ctrl.Fallback:SetScript("OnClick", function() if not this then return end FOM_Config.Fallback = this:GetChecked() == 1 end) end

	local keepOpenLabel = container:CreateFontString("MetaHuntOptionsFOMKeepOpenLabel", "ARTWORK", "GameFontNormalSmall")
	keepOpenLabel:SetPoint("TOPLEFT", container, "TOPLEFT", 20, -302 + yAdjust)
	keepOpenLabel:SetText(MTH_FOM_L("FOM_KEEP_OPEN_BAG_SLOTS", "Keep open bag slots:"))

	local keepOpen = CreateFrame("EditBox", "MetaHuntOptionsFOMKeepOpen", container, "InputBoxTemplate")
	keepOpen:SetPoint("LEFT", keepOpenLabel, "RIGHT", 8, 0)
	keepOpen:SetWidth(40)
	keepOpen:SetHeight(20)
	keepOpen:SetNumeric(true)
	keepOpen:SetAutoFocus(false)
	keepOpen:SetScript("OnTextChanged", function()
		if not this then return end
		local value = tonumber(this:GetText()) or 0
		FOM_Config.KeepOpenSlots = value
	end)
	keepOpen:SetScript("OnEnterPressed", function() if this then this:ClearFocus() end end)
	keepOpen:SetScript("OnEscapePressed", function() if this then this:ClearFocus() end end)
	MTH_FOM_STATE.keepOpenEdit = keepOpen

	local notifyHeader = container:CreateFontString("MetaHuntOptionsFOMNotifyHeader", "ARTWORK", "GameFontHighlight")
	notifyHeader:SetPoint("TOPLEFT", container, "TOPLEFT", 20, -336 + yAdjust)
	notifyHeader:SetText(MTH_FOM_L("FOM_HEADER_NOTIFY_WHEN_FEEDING", "Notify when feeding"))

	MTH_FOM_STATE.ctrl.AlertEmote = MTH_CreateCheckbox(container, "MetaHuntOptionsFOMAlertEmote", FOM_OptionsButtonText and FOM_OptionsButtonText["AlertEmote"] or MTH_FOM_L("FOM_LABEL_NOTIFY_VIA_EMOTE", "Via emote"), -360 + yAdjust)
	MTH_FOM_STATE.ctrl.AlertChat = MTH_CreateCheckbox(container, "MetaHuntOptionsFOMAlertChat", FOM_OptionsButtonText and FOM_OptionsButtonText["AlertChat"] or MTH_FOM_L("FOM_LABEL_NOTIFY_IN_CHAT", "In chat"), -385 + yAdjust)
	MTH_FOM_STATE.ctrl.AlertNone = MTH_CreateCheckbox(container, "MetaHuntOptionsFOMAlertNone", FOM_OptionsButtonText and FOM_OptionsButtonText["AlertNone"] or MTH_FOM_L("FOM_LABEL_NOTIFY_NONE", "Don't notify"), -410 + yAdjust)
	if MTH_FOM_STATE.ctrl.AlertEmote then MTH_FOM_STATE.ctrl.AlertEmote:SetScript("OnClick", function() MTH_FOM_SetAlert("emote"); MTH_RefreshFeedOMaticOptions() end) end
	if MTH_FOM_STATE.ctrl.AlertChat then MTH_FOM_STATE.ctrl.AlertChat:SetScript("OnClick", function() MTH_FOM_SetAlert("chat"); MTH_RefreshFeedOMaticOptions() end) end
	if MTH_FOM_STATE.ctrl.AlertNone then MTH_FOM_STATE.ctrl.AlertNone:SetScript("OnClick", function() MTH_FOM_SetAlert("none"); MTH_RefreshFeedOMaticOptions() end) end

	local warnHeader = container:CreateFontString("MetaHuntOptionsFOMWarnHeader", "ARTWORK", "GameFontHighlight")
	warnHeader:SetPoint("TOPLEFT", container, "TOPLEFT", rightColumnX, -276 + yAdjust)
	warnHeader:SetText(MTH_FOM_L("FOM_HEADER_WARN_WHEN_PET_NEEDS_FEEDING", "Warn when pet needs feeding"))

	MTH_FOM_STATE.ctrl.LevelContent = MTH_CreateCheckbox(container, "MetaHuntOptionsFOMLevelContent", FOM_OptionsButtonText and FOM_OptionsButtonText["LevelContent"] or MTH_FOM_L("FOM_LABEL_WARN_WHEN_CONTENT", "When content"), -300 + yAdjust, rightColumnX)
	MTH_FOM_STATE.ctrl.LevelUnhappy = MTH_CreateCheckbox(container, "MetaHuntOptionsFOMLevelUnhappy", FOM_OptionsButtonText and FOM_OptionsButtonText["LevelUnhappy"] or MTH_FOM_L("FOM_LABEL_WARN_WHEN_UNHAPPY", "When unhappy"), -325 + yAdjust, rightColumnX)
	MTH_FOM_STATE.ctrl.LevelOff = MTH_CreateCheckbox(container, "MetaHuntOptionsFOMLevelOff", FOM_OptionsButtonText and FOM_OptionsButtonText["LevelOff"] or MTH_FOM_L("FOM_LABEL_DONT_WARN", "Don't warn"), -350 + yAdjust, rightColumnX)
	if MTH_FOM_STATE.ctrl.LevelContent then MTH_FOM_STATE.ctrl.LevelContent:SetScript("OnClick", function() MTH_FOM_SetLevel("content"); MTH_RefreshFeedOMaticOptions() end) end
	if MTH_FOM_STATE.ctrl.LevelUnhappy then MTH_FOM_STATE.ctrl.LevelUnhappy:SetScript("OnClick", function() MTH_FOM_SetLevel("unhappy"); MTH_RefreshFeedOMaticOptions() end) end
	if MTH_FOM_STATE.ctrl.LevelOff then MTH_FOM_STATE.ctrl.LevelOff:SetScript("OnClick", function() MTH_FOM_SetLevel("off"); MTH_RefreshFeedOMaticOptions() end) end

	MTH_FOM_STATE.ctrl.AudioWarning = MTH_CreateCheckbox(container, "MetaHuntOptionsFOMAudioWarning", FOM_OptionsButtonText and FOM_OptionsButtonText["AudioWarning"] or MTH_FOM_L("FOM_LABEL_PLAY_SOUND", "Play sound"), -378 + yAdjust, rightColumnX)
	MTH_FOM_STATE.ctrl.AudioWarningBell = MTH_CreateCheckbox(container, "MetaHuntOptionsFOMAudioWarningBell", FOM_OptionsButtonText and FOM_OptionsButtonText["AudioWarningBell"] or MTH_FOM_L("FOM_LABEL_USE_BELL_SOUND", "Use bell sound"), -403 + yAdjust, rightColumnX)
	MTH_FOM_STATE.ctrl.TextWarning = MTH_CreateCheckbox(container, "MetaHuntOptionsFOMTextWarning", FOM_OptionsButtonText and FOM_OptionsButtonText["TextWarning"] or MTH_FOM_L("FOM_LABEL_SHOW_TEXT", "Show text"), -428 + yAdjust, rightColumnX)
	MTH_FOM_STATE.ctrl.IconWarning = MTH_CreateCheckbox(container, "MetaHuntOptionsFOMIconWarning", FOM_OptionsButtonText and FOM_OptionsButtonText["IconWarning"] or MTH_FOM_L("FOM_LABEL_FLASH_ICON", "Flash icon"), -453 + yAdjust, rightColumnX)
	if MTH_FOM_STATE.ctrl.AudioWarning then MTH_FOM_STATE.ctrl.AudioWarning:SetScript("OnClick", function() if not this then return end if this:GetChecked() == 1 then if FOM_Config.AudioWarning ~= "bell" then FOM_Config.AudioWarning = true end else FOM_Config.AudioWarning = nil end MTH_RefreshFeedOMaticOptions() end) end
	if MTH_FOM_STATE.ctrl.AudioWarningBell then MTH_FOM_STATE.ctrl.AudioWarningBell:SetScript("OnClick", function() if not this then return end if this:GetChecked() == 1 then FOM_Config.AudioWarning = "bell" else FOM_Config.AudioWarning = true end MTH_RefreshFeedOMaticOptions() end) end
	if MTH_FOM_STATE.ctrl.TextWarning then MTH_FOM_STATE.ctrl.TextWarning:SetScript("OnClick", function() if not this then return end FOM_Config.TextWarning = this:GetChecked() == 1 end) end
	if MTH_FOM_STATE.ctrl.IconWarning then MTH_FOM_STATE.ctrl.IconWarning:SetScript("OnClick", function() if not this then return end FOM_Config.IconWarning = this:GetChecked() == 1 end) end

	local cookHeader = container:CreateFontString("MetaHuntOptionsFOMCookingHeader", "ARTWORK", "GameFontHighlight")
	cookHeader:SetPoint("TOPLEFT", container, "TOPLEFT", rightColumnX, -62 + yAdjust)
	cookHeader:SetText(MTH_FOM_L("FOM_HEADER_AVOID_FOODS_USED_IN_COOKING", "Avoid foods used in cooking"))

	MTH_FOM_STATE.ctrl.SaveCookOrange = MTH_CreateCheckbox(container, "MetaHuntOptionsFOMSaveCookOrange", FOM_OptionsButtonText and FOM_OptionsButtonText["SaveForCook_Orange"] or MTH_FOM_L("FOM_LABEL_ONLY_DIFFICULT_RECIPES", "Only difficult recipes"), -86 + yAdjust, rightColumnX)
	MTH_FOM_STATE.ctrl.SaveCookYellow = MTH_CreateCheckbox(container, "MetaHuntOptionsFOMSaveCookYellow", FOM_OptionsButtonText and FOM_OptionsButtonText["SaveForCook_Yellow"] or MTH_FOM_L("FOM_LABEL_MEDIUM_OR_BETTER", "Medium or better"), -111 + yAdjust, rightColumnX)
	MTH_FOM_STATE.ctrl.SaveCookGreen = MTH_CreateCheckbox(container, "MetaHuntOptionsFOMSaveCookGreen", FOM_OptionsButtonText and FOM_OptionsButtonText["SaveForCook_Green"] or MTH_FOM_L("FOM_LABEL_EASY_OR_BETTER", "Easy or better"), -136 + yAdjust, rightColumnX)
	MTH_FOM_STATE.ctrl.SaveCookAll = MTH_CreateCheckbox(container, "MetaHuntOptionsFOMSaveCookAll", FOM_OptionsButtonText and FOM_OptionsButtonText["SaveForCook_All"] or MTH_FOM_L("FOM_LABEL_ALL_FOODS", "All foods"), -161 + yAdjust, rightColumnX)
	MTH_FOM_STATE.ctrl.SaveCookNone = MTH_CreateCheckbox(container, "MetaHuntOptionsFOMSaveCookNone", FOM_OptionsButtonText and FOM_OptionsButtonText["SaveForCook_None"] or MTH_FOM_L("FOM_LABEL_DO_NOT_SAVE_COOKING_FOODS", "Do not save cooking foods"), -186 + yAdjust, rightColumnX)
	if MTH_FOM_STATE.ctrl.SaveCookOrange then MTH_FOM_STATE.ctrl.SaveCookOrange:SetScript("OnClick", function() MTH_FOM_SetCookingLevel(3); MTH_RefreshFeedOMaticOptions() end) end
	if MTH_FOM_STATE.ctrl.SaveCookYellow then MTH_FOM_STATE.ctrl.SaveCookYellow:SetScript("OnClick", function() MTH_FOM_SetCookingLevel(2); MTH_RefreshFeedOMaticOptions() end) end
	if MTH_FOM_STATE.ctrl.SaveCookGreen then MTH_FOM_STATE.ctrl.SaveCookGreen:SetScript("OnClick", function() MTH_FOM_SetCookingLevel(1); MTH_RefreshFeedOMaticOptions() end) end
	if MTH_FOM_STATE.ctrl.SaveCookAll then MTH_FOM_STATE.ctrl.SaveCookAll:SetScript("OnClick", function() MTH_FOM_SetCookingLevel(0); MTH_RefreshFeedOMaticOptions() end) end
	if MTH_FOM_STATE.ctrl.SaveCookNone then MTH_FOM_STATE.ctrl.SaveCookNone:SetScript("OnClick", function() MTH_FOM_SetCookingLevel(4); MTH_RefreshFeedOMaticOptions() end) end

	MTH_RefreshFeedOMaticOptions()
end
