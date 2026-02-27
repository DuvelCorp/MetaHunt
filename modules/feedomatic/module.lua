------------------------------------------------------
-- MetaHunt: FeedOMatic Module Wrapper
-- Modern module abstraction for the FeedOMatic addon
------------------------------------------------------

local MTH_FeedOMatic = {
	name = "feedomatic",
	enabled = false,
	version = "1.0.4",
	events = {
		"VARIABLES_LOADED",
			"MERCHANT_SHOW",
			"MERCHANT_UPDATE",
		"MTH_PET_LIVE_STATE_CHANGED",
		"PET_ATTACK_START",
		"PET_ATTACK_STOP",
		"PET_STABLE_SHOW",
		"PET_STABLE_UPDATE",
		"TRADE_SKILL_SHOW",
		"TRADE_SKILL_UPDATE",
		"CHAT_MSG_SPELL_TRADESKILLS",
		"CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS",
		"UI_ERROR_MESSAGE",
		"PET_BAR_SHOWGRID",
		"PET_BAR_UPDATE",
		"PET_UI_UPDATE",
		"UNIT_HAPPINESS",
		"PLAYER_REGEN_ENABLED",
	},
	initialized = false,
	variablesLoadedProcessed = false,
}

local MTH_PETL_HOOK_BOUNDARY_KEY = "pet-lifecycle-hooks"
local MTH_FeedOMatic_MerchantProbeFrame = nil

function MTH_FeedOMatic_OnUpdate(elapsed)
	if not elapsed then
		return
	end
	if not (MTH and MTH.IsModuleEnabled and MTH:IsModuleEnabled("feedomatic", true)) then
		return
	end
	if type(FOM_OnUpdate) == "function" then
		FOM_OnUpdate(elapsed)
	end
end

local function MTH_FeedOMatic_GetRuntimeFrame()
	return getglobal("Frame_GFW_FeedOMatic")
end

local function MTH_FeedOMatic_CaptureHookBoundary()
	if not (MTH and MTH.CaptureHookBoundary) then
		return
	end
	MTH:CaptureHookBoundary(MTH_PETL_HOOK_BOUNDARY_KEY, {
		{ globalName = "PetAbandon", originalName = "MTH_PETL_Original_PetAbandon" },
	})
end

local function MTH_FeedOMatic_RestoreHookBoundary()
	if not (MTH and MTH.RestoreHookBoundary) then
		return
	end
	MTH:RestoreHookBoundary(MTH_PETL_HOOK_BOUNDARY_KEY)
end

local function MTH_FeedOMatic_ApplyLegacyHooks()
	local canTouchPetAbandon = true
	if MTH and MTH.GetGlobalHookOwner then
		local abandonOwner = MTH:GetGlobalHookOwner("PetAbandon")
		if abandonOwner and abandonOwner ~= MTH_PETL_HOOK_BOUNDARY_KEY then
			canTouchPetAbandon = false
		end
	end

	local abandonHook = MTH_PetAbandonHook or FOM_PetAbandon
	local abandonOriginal = MTH_PETL_Original_PetAbandon or FOM_Original_PetAbandon
	if type(abandonHook) == "function" and type(abandonOriginal) == "function" then
		if canTouchPetAbandon and (PetAbandon == abandonOriginal or PetAbandon == abandonHook) then
			PetAbandon = abandonHook
		end
	end
end

local function MTH_FeedOMatic_CallLegacyOnEvent(evt, a1, a2, a3, a4, a5, a6, a7, a8, a9)
	if type(FOM_OnEvent) ~= "function" then
		return
	end

	local frame = MTH_FeedOMatic_GetRuntimeFrame()
	if not frame then
		return
	end

	local oldThis = this
	local oldEvent = event
	local oldArg1, oldArg2, oldArg3, oldArg4, oldArg5 = arg1, arg2, arg3, arg4, arg5
	local oldArg6, oldArg7, oldArg8, oldArg9 = arg6, arg7, arg8, arg9

	this = frame
	event = evt
	arg1, arg2, arg3, arg4, arg5 = a1, a2, a3, a4, a5
	arg6, arg7, arg8, arg9 = a6, a7, a8, a9

	local ok = pcall(function()
		FOM_OnEvent(evt, a1)
	end)

	this = oldThis
	event = oldEvent
	arg1, arg2, arg3, arg4, arg5 = oldArg1, oldArg2, oldArg3, oldArg4, oldArg5
	arg6, arg7, arg8, arg9 = oldArg6, oldArg7, oldArg8, oldArg9

	if not ok and MTH and MTH.DebugPrint then
		MTH:DebugPrint("FeedOMatic legacy OnEvent call failed for event: " .. tostring(evt))
	end
end

local function MTH_FeedOMatic_EnsureVariablesLoaded(module)
	if not module or module.variablesLoadedProcessed then
		return
	end

	MTH_FeedOMatic_CallLegacyOnEvent("VARIABLES_LOADED")
	module.variablesLoadedProcessed = true
end

local function MTH_FeedOMatic_SyncSavedVariables()
	if not MTH or not MTH.GetModuleSavedVariables then
		return
	end

	local moduleStore = MTH:GetModuleSavedVariables("feedomatic")
	if not moduleStore.legacy then
		moduleStore.legacy = {}
	end

	if type(FOM_Config) == "table" then
		moduleStore.legacy.FOM_Config = FOM_Config
	elseif type(moduleStore.legacy.FOM_Config) == "table" then
		FOM_Config = moduleStore.legacy.FOM_Config
	end

	if type(FOM_FoodQuality) == "table" then
		moduleStore.legacy.FOM_FoodQuality = FOM_FoodQuality
	elseif type(moduleStore.legacy.FOM_FoodQuality) == "table" then
		FOM_FoodQuality = moduleStore.legacy.FOM_FoodQuality
	end

	if type(FOM_AddedFoods) == "table" then
		moduleStore.legacy.FOM_AddedFoods = FOM_AddedFoods
	elseif type(moduleStore.legacy.FOM_AddedFoods) == "table" then
		FOM_AddedFoods = moduleStore.legacy.FOM_AddedFoods
	end

	if type(FOM_RemovedFoods) == "table" then
		moduleStore.legacy.FOM_RemovedFoods = FOM_RemovedFoods
	elseif type(moduleStore.legacy.FOM_RemovedFoods) == "table" then
		FOM_RemovedFoods = moduleStore.legacy.FOM_RemovedFoods
	end

	if type(FOM_Cooking) == "table" then
		moduleStore.legacy.FOM_Cooking = FOM_Cooking
	elseif type(moduleStore.legacy.FOM_Cooking) == "table" then
		FOM_Cooking = moduleStore.legacy.FOM_Cooking
	end

	if type(FOM_QuestFood) == "table" then
		moduleStore.legacy.FOM_QuestFood = FOM_QuestFood
	elseif type(moduleStore.legacy.FOM_QuestFood) == "table" then
		FOM_QuestFood = moduleStore.legacy.FOM_QuestFood
	end

	if type(FOM_LocaleInfo) == "table" then
		moduleStore.legacy.FOM_LocaleInfo = FOM_LocaleInfo
	elseif type(moduleStore.legacy.FOM_LocaleInfo) == "table" then
		FOM_LocaleInfo = moduleStore.legacy.FOM_LocaleInfo
	end
end

local function MTH_FeedOMatic_Log(message, severity)
	if type(MTH_Log) == "function" then
		local logSeverity = severity or "debug"
		MTH_Log("[FeedOMatic] " .. tostring(message or ""), logSeverity)
	end
end

local function MTH_FeedOMatic_DebugMerchantScan(sourceEvent)
	if type(MTH_GetMerchantFoodsByDiet) ~= "function" then
		MTH_FeedOMatic_Log(tostring(sourceEvent) .. ": MTH_GetMerchantFoodsByDiet is not available yet")
		return
	end

	local merchantFoods = MTH_GetMerchantFoodsByDiet()
	local knownCount = 0
	local unknownCount = 0
	if type(merchantFoods) == "table" then
		if type(merchantFoods.items) == "table" then
			knownCount = table.getn(merchantFoods.items)
		end
		if type(merchantFoods.unknown) == "table" then
			unknownCount = table.getn(merchantFoods.unknown)
		end
	end

	local merchantName = UnitName("npc") or UnitName("target") or "unknown"
	MTH_FeedOMatic_Log(tostring(sourceEvent) .. ": wrapper scan for " .. tostring(merchantName) .. " | known=" .. tostring(knownCount) .. " | unknown=" .. tostring(unknownCount))

	if type(merchantFoods.byDiet) == "table" then
		for dietName, rows in merchantFoods.byDiet do
			local dietCount = 0
			if type(rows) == "table" then
				dietCount = table.getn(rows)
			end
			MTH_FeedOMatic_Log("diet " .. tostring(dietName) .. ": " .. tostring(dietCount) .. " item(s)", "debug")
			if type(rows) == "table" then
				for _, row in rows do
					MTH_FeedOMatic_Log("  - [" .. tostring(row.id) .. "] " .. tostring(row.name) .. " (slot=" .. tostring(row.index) .. ")", "debug")
				end
			end
		end
	end

	if unknownCount > 0 and type(merchantFoods.unknown) == "table" then
		for _, row in merchantFoods.unknown do
			MTH_FeedOMatic_Log("unknown map: [" .. tostring(row.id) .. "] " .. tostring(row.name) .. " (slot=" .. tostring(row.index) .. ")", "debug")
		end
	end
end

local function MTH_FeedOMatic_SetMerchantProbeEnabled(enabled)
	if not MTH_FeedOMatic_MerchantProbeFrame then
		MTH_FeedOMatic_MerchantProbeFrame = CreateFrame("Frame", "MTH_FeedOMatic_MerchantProbeFrame")
		MTH_FeedOMatic_MerchantProbeFrame:SetScript("OnEvent", function()
			local evt = event
			if evt == "MERCHANT_SHOW" or evt == "MERCHANT_UPDATE" then
				MTH_FeedOMatic_Log("probe event received: " .. tostring(evt), "debug")
				MTH_FeedOMatic_DebugMerchantScan(evt)
			end
		end)
	end

	if enabled then
		MTH_FeedOMatic_MerchantProbeFrame:RegisterEvent("MERCHANT_SHOW")
		MTH_FeedOMatic_MerchantProbeFrame:RegisterEvent("MERCHANT_UPDATE")
		MTH_FeedOMatic_Log("merchant probe enabled", "debug")
	else
		MTH_FeedOMatic_MerchantProbeFrame:UnregisterEvent("MERCHANT_SHOW")
		MTH_FeedOMatic_MerchantProbeFrame:UnregisterEvent("MERCHANT_UPDATE")
	end
end

function MTH_FeedOMatic:init()
	-- FeedOMatic initializes via its VARIABLES_LOADED event
	-- This is called after the core MTH framework is loaded
	MTH_FEED_WRAPPER_MODE = true
	MTH_FOM_WRAPPER_MODE = MTH_FEED_WRAPPER_MODE
	MTH_FeedOMatic_SyncSavedVariables()

	if not self.initialized and not getglobal("FOM_METAHUNT_ONLOAD_DONE") and FOM_OnLoad then
		local frame = MTH_FeedOMatic_GetRuntimeFrame()
		if frame then
			local oldThis = this
			this = frame
			pcall(function()
				FOM_OnLoad()
			end)
			this = oldThis
			FOM_METAHUNT_ONLOAD_DONE = true
		end
	end

	MTH_FeedOMatic_CaptureHookBoundary()

	self.initialized = true
	if self.enabled then
		MTH_FeedOMatic_EnsureVariablesLoaded(self)
	end
end

function MTH_FeedOMatic:setEnabled(enabled)
	if enabled then
		if not self.initialized then
			self:init()
		end
		MTH_FeedOMatic_ApplyLegacyHooks()
		MTH_FeedOMatic_CaptureHookBoundary()
		MTH_FeedOMatic_SyncSavedVariables()
		MTH_FeedOMatic_EnsureVariablesLoaded(self)
		MTH_FeedOMatic_SetMerchantProbeEnabled(false)
		if FOM_FeedButton then
			FOM_FeedButton:Show()
		end
	else
		-- Disable FeedOMatic functionality
		MTH_FeedOMatic_RestoreHookBoundary()
		if type(FOM_State) == "table" then
			FOM_State.ShouldFeed = false
		end
		MTH_FeedOMatic_SetMerchantProbeEnabled(false)
		if FOM_FeedButton then
			FOM_FeedButton:Hide()
		end
	end
end

function MTH_FeedOMatic:onEvent(event, arg1, arg2, arg3, arg4, arg5)
	if event == "VARIABLES_LOADED" then
		MTH_FeedOMatic_EnsureVariablesLoaded(self)
		return
	end

	if event == "MTH_PET_LIVE_STATE_CHANGED" then
		MTH_FeedOMatic_CallLegacyOnEvent("PET_BAR_UPDATE")
		MTH_FeedOMatic_CallLegacyOnEvent("PET_UI_UPDATE")
		MTH_FeedOMatic_CallLegacyOnEvent("UNIT_HAPPINESS", "pet")
		return
	end

	MTH_FeedOMatic_CallLegacyOnEvent(event, arg1, arg2, arg3, arg4, arg5)
end

function MTH_FeedOMatic:cleanup()
	-- Cleanup code when module is unloaded
	MTH_FeedOMatic_RestoreHookBoundary()
	if type(FOM_State) == "table" then
		FOM_State.ShouldFeed = false
	end
	MTH_FeedOMatic_SetMerchantProbeEnabled(false)
	if FOM_FeedButton then
		FOM_FeedButton:Hide();
	end
end

-- Register with MTH
MTH:RegisterModule("feedomatic", MTH_FeedOMatic)

MTH_FOM_OnUpdate = MTH_FeedOMatic_OnUpdate
