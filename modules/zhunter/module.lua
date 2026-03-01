------------------------------------------------------
-- MetaHunt: zhunter Module Wrapper
-- Modern module abstraction for the zhunter addon
------------------------------------------------------

MTH_ZH_MANAGED_HOOKS = true

local MTH_ZHunter = {
	name = "zhunter",
	enabled = true,
	version = "1.0.5",
	events = {
		"VARIABLES_LOADED",
		"PLAYER_ENTERING_WORLD",
		"MTH_PET_LIVE_STATE_CHANGED",
	},
	features = {
		aspect = true,
		tracking = true,
		traps = true,
		ranged = true,
		ammo = true,
		pet = true,
	}
}

local function MTH_ZH_Log(msg)
	if not (MTH and MTH.debug) then
		return
	end
	MTH:Print("[ZH MODULE] " .. tostring(msg), "debug")
end

local MTH_ZH_PostLoginRestoreFrame = nil
local MTH_ZH_BootstrapFrame = nil
local MTH_ZH_SyncSavedVariables
local MTH_ZH_SetButtonsVisible
local MTH_ZH_SetAuxFramesVisible
local MTH_ZH_RestoreRuntimeFeatureFlags
local MTH_ZH_ApplyEnabledRuntimeState
local MTH_ZH_QueuePostLoginRestore

local function MTH_ZH_ApplyDefaultWidgetSpawnLayoutOnce()
	local savedRoot = nil
	if type(MTH_ZH_GetSavedRoot) == "function" then
		savedRoot = MTH_ZH_GetSavedRoot()
	elseif type(ZHunterMod_Saved) == "table" then
		savedRoot = ZHunterMod_Saved
	end

	if type(savedRoot) ~= "table" then
		return false
	end

	if savedRoot["_mth_widget_spawn_layout_v1"] then
		return false
	end

	local orderedButtons = {
		"zButtonAspect",
		"zButtonAmmo",
		"zButtonTrack",
		"zButtonTrap",
		"zButtonRanged",
		"zButtonPet",
		"zButtonMounts",
		"zButtonCompanions",
		"zButtonToys",
	}

	local startY = -140
	local stepY = -54

	local orderedCount = table.getn(orderedButtons)
	for i = 1, orderedCount do
		if not getglobal(orderedButtons[i]) then
			MTH_ZH_Log("skipped one-time default widget spawn layout (missing frame: " .. tostring(orderedButtons[i]) .. ")")
			return false
		end
	end

	for i = 1, orderedCount do
		local buttonName = orderedButtons[i]
		local button = getglobal(buttonName)
		if button then
			button:ClearAllPoints()
			button:SetPoint("TOP", UIParent, "TOP", 0, startY + ((i - 1) * stepY))
		end
	end

	savedRoot["_mth_widget_spawn_layout_v1"] = 1
	MTH_ZH_Log("applied one-time default widget spawn layout")
	return true
end

function MTH_ZH_OnDeferredInitComplete()
	if not (MTH and MTH.IsModuleEnabled and MTH:IsModuleEnabled("zhunter", true)) then
		if MTH_ZH_SetButtonsVisible then
			MTH_ZH_SetButtonsVisible(false)
		end
		if MTH_ZH_SetAuxFramesVisible then
			MTH_ZH_SetAuxFramesVisible(false)
		end
		MTH_ZH_Log("deferred init applied disabled-state hide")
		return
	end
	MTH_ZH_SyncSavedVariables()
	MTH_ZH_ApplyDefaultWidgetSpawnLayoutOnce()
	MTH_ZH_RestoreRuntimeFeatureFlags()
	MTH_ZH_QueuePostLoginRestore("deferred-init")
end

MTH_ZH_QueuePostLoginRestore = function(tag)
	if not MTH_ZH_PostLoginRestoreFrame then
		MTH_ZH_PostLoginRestoreFrame = CreateFrame("Frame", "MTH_ZH_PostLoginRestoreFrame")
		if not MTH_ZH_PostLoginRestoreFrame then
			return
		end
	end

	MTH_ZH_PostLoginRestoreFrame._mthElapsed = 0
	MTH_ZH_PostLoginRestoreFrame:SetScript("OnUpdate", function()
		this._mthElapsed = (this._mthElapsed or 0) + (arg1 or 0)
		if this._mthElapsed < 0.2 then
			return
		end

		this:SetScript("OnUpdate", nil)
		if not (MTH and MTH.IsModuleEnabled and MTH:IsModuleEnabled("zhunter", true)) then
			return
		end

		MTH_ZH_SyncSavedVariables()
		MTH_ZH_RestoreRuntimeFeatureFlags()
		MTH_ZH_Log("post-login restore applied: " .. tostring(tag))
	end)
end

local function MTH_ZH_EnsureBootstrapRestoreFrame()
	if MTH_ZH_BootstrapFrame then
		return MTH_ZH_BootstrapFrame
	end

	MTH_ZH_BootstrapFrame = CreateFrame("Frame", "MTH_ZH_BootstrapRestoreFrame")
	if not MTH_ZH_BootstrapFrame then
		return nil
	end

	MTH_ZH_BootstrapFrame:RegisterEvent("VARIABLES_LOADED")
	MTH_ZH_BootstrapFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	MTH_ZH_BootstrapFrame:SetScript("OnEvent", function()
		if not (MTH and MTH.IsModuleEnabled and MTH:IsModuleEnabled("zhunter", true)) then
			return
		end

		if event == "VARIABLES_LOADED" then
			MTH_ZH_SyncSavedVariables()
			return
		end

		if event == "PLAYER_ENTERING_WORLD" then
			MTH_ZH_ApplyEnabledRuntimeState("bootstrap:" .. tostring(event))
			MTH_ZH_QueuePostLoginRestore("bootstrap:" .. tostring(event))
			this:UnregisterAllEvents()
			this:SetScript("OnEvent", nil)
		end
	end)

	return MTH_ZH_BootstrapFrame
end

MTH_ZH_ApplyEnabledRuntimeState = function(source)
	MTH_ZH_SyncSavedVariables()
	MTH_ZH_SetButtonsVisible(true)
	MTH_ZH_SetAuxFramesVisible(true)
	MTH_ZH_RestoreRuntimeFeatureFlags()
end

MTH_ZH_SyncSavedVariables = function()
	if not MTH or not MTH.GetModuleCharSavedVariables then
		return
	end

	local moduleStore = MTH:GetModuleCharSavedVariables("zhunter")

	if type(ZHunterMod_Saved) == "table" then
		if MTH_CharSavedVariables and MTH_CharSavedVariables.modules then
			MTH_CharSavedVariables.modules.zhunter = ZHunterMod_Saved
		end
	elseif type(moduleStore) == "table" then
		ZHunterMod_Saved = moduleStore
	end
end

MTH_ZH_SetButtonsVisible = function(visible)
	local buttonNames = {
		"zButtonAspect",
		"zButtonTrack",
		"zButtonTrap",
		"zButtonRanged",
		"zButtonAmmo",
		"zButtonPet",
		"zButtonMounts",
		"zButtonCompanions",
		"zButtonToys",
	}

	local function MTH_ZH_SetChildButtonsVisible(parentButton, parentName, show)
		if not parentButton then
			return
		end

		if not show then
			if parentButton.children then
				parentButton.children:Hide()
			end

			if not parentButton.count then
				return
			end

			local hideBaseName = parentButton.name or parentName
			if not hideBaseName then
				return
			end

			for index = 1, parentButton.count do
				local child = getglobal(hideBaseName .. index)
				if child then
					child:Hide()
				end
			end
			return
		end

		local showChildren = false
		if type(ZSpellButton_GetChildrenExpanded) == "function" then
			showChildren = ZSpellButton_GetChildrenExpanded(parentButton)
		else
			showChildren = true
		end

		if parentButton.children then
			if showChildren then
				parentButton.children:Show()
			else
				parentButton.children:Hide()
			end
		end

		if not parentButton.count then
			return
		end

		local baseName = parentButton.name or parentName
		if not baseName then
			return
		end

		if showChildren then
			for index = 1, parentButton.count do
				local child = getglobal(baseName .. index)
				if child then
					if child.id then
						child:Show()
					else
						child:Hide()
					end
				end
			end
		end
	end

	for _, buttonName in ipairs(buttonNames) do
		local button = getglobal(buttonName)
		if button then
			MTH_ZH_SetChildButtonsVisible(button, buttonName, visible)
			if visible then
				button:Show()
			else
				button:Hide()
			end
		end
	end
end

MTH_ZH_SetAuxFramesVisible = function(visible)
	return
end

local function MTH_ZH_SetAdjustmentHandlersActive(active)
	local frameSpecs = {
		{ frame = "zButtonAspectAdjustment", handler = "zButtonAspectAdjustment_OnEvent", getter = "zButtonAspect_GetSaved" },
		{ frame = "zButtonTrackAdjustment", handler = "zButtonTrackAdjustment_OnEvent", getter = "zButtonTrack_GetSaved" },
		{ frame = "zButtonTrapAdjustment", handler = "zButtonTrapAdjustment_OnEvent", getter = "zButtonTrap_GetSaved" },
		{ frame = "zButtonRangedAdjustment", handler = "zButtonRangedAdjustment_OnEvent", getter = "zButtonRanged_GetSaved" },
		{ frame = "zButtonAmmoAdjustment", handler = "zButtonAmmoAdjustment_OnEvent", getter = "zButtonAmmo_GetSaved" },
		{ frame = "zButtonPetAdjustment", handler = "zButtonPetAdjustment_OnEvent", getter = "zButtonPet_GetSaved" },
		{ frame = "zButtonMountsAdjustment", handler = "zButtonMountsAdjustment_OnEvent", getter = "zButtonMounts_GetSaved" },
		{ frame = "zButtonCompanionsAdjustment", handler = "zButtonCompanionsAdjustment_OnEvent", getter = "zButtonCompanions_GetSaved" },
		{ frame = "zButtonToysAdjustment", handler = "zButtonToysAdjustment_OnEvent", getter = "zButtonToys_GetSaved" },
	}

	local function isFeatureEnabled(getterName)
		local getter = getglobal(getterName)
		if type(getter) ~= "function" then
			return true
		end
		local ok, saved = pcall(getter)
		if not ok or type(saved) ~= "table" then
			return true
		end
		if saved["enabled"] == false or saved["enabled"] == 0 then
			return false
		end
		return true
	end

	for _, spec in ipairs(frameSpecs) do
		local frameName = spec.frame
		local handlerName = spec.handler
		local frame = getglobal(frameName)
		if frame and frame.SetScript then
			if active then
				if isFeatureEnabled(spec.getter) then
					local handler = getglobal(handlerName)
					if type(handler) == "function" then
						frame:SetScript("OnEvent", handler)
					else
						frame:SetScript("OnEvent", nil)
					end
				else
					frame:SetScript("OnEvent", nil)
				end
			else
				frame:SetScript("OnEvent", nil)
			end
		end
	end
end

local function MTH_ZH_ClearRuntimeFeatureFlags()
	return
end

MTH_ZH_RestoreRuntimeFeatureFlags = function()
	return
end

function MTH_ZHunter:init()
	-- ZHunterMod initializes via the game events
	-- Features: Aspect, Tracking, Trap, Ammo, Pet management buttons
	MTH_ZH_SyncSavedVariables()
	MTH_ZH_EnsureBootstrapRestoreFrame()
	if self.enabled then
		MTH_ZH_SyncSavedVariables()
	end
end

function MTH_ZHunter:setEnabled(enabled)
	MTH_ZH_SyncSavedVariables()
	if enabled then
		MTH_ZH_EnsureBootstrapRestoreFrame()
		MTH_ZH_SetAdjustmentHandlersActive(true)
		MTH_ZH_ApplyEnabledRuntimeState("setEnabled")
	else
		MTH_ZH_ClearRuntimeFeatureFlags()
		MTH_ZH_SetAdjustmentHandlersActive(false)
		MTH_ZH_SetButtonsVisible(false)
		MTH_ZH_SetAuxFramesVisible(false)
	end
end

function MTH_ZHunter:onEvent(evt, arg1, arg2)
	if not self.enabled then
		return
	end
	if evt == "MTH_PET_LIVE_STATE_CHANGED" then
		if type(zButtonPet_RefreshLiveState) == "function" then
			zButtonPet_RefreshLiveState(arg1, arg2)
		end
		return
	end
	if evt == "VARIABLES_LOADED" then
		MTH_ZH_SyncSavedVariables()
		MTH_ZH_RestoreRuntimeFeatureFlags()
		return
	end
	if evt == "PLAYER_ENTERING_WORLD" then
		MTH_ZH_ApplyEnabledRuntimeState("event:" .. tostring(evt))
		MTH_ZH_QueuePostLoginRestore(evt)
	end
end

function MTH_ZHunter:cleanup()
	-- Cleanup code when module is unloaded
	self:setEnabled(false)
end

-- Register with MTH
MTH:RegisterModule("zhunter", MTH_ZHunter)
