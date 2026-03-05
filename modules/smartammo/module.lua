------------------------------------------------------
-- MetaHunt: SmartAmmo Module
------------------------------------------------------

MTH_SA_MANAGED_HOOKS = true

local MTH_SmartAmmo = {
	name = "smartammo",
	enabled = true,
	version = "1.0.6",
	events = {
		"VARIABLES_LOADED",
		"PLAYER_ENTERING_WORLD",
	},
}

local MTH_SA_BOUNDARY_KEY = "smartammo.core"

function MTH_SA_GetSavedTable(tableName)
	if not MTH or not MTH.GetModuleCharSavedVariables then
		if type(_G[tableName]) ~= "table" then
			_G[tableName] = {}
		end
		return _G[tableName]
	end

	local moduleStore = MTH:GetModuleCharSavedVariables("smartammo")
	if type(moduleStore) ~= "table" then
		moduleStore = {}
	end

	if not moduleStore.legacy then
		moduleStore.legacy = {}
	end
	if type(moduleStore.legacy[tableName]) ~= "table" then
		moduleStore.legacy[tableName] = {}
	end

	if type(_G[tableName]) == "table" then
		local legacyTable = moduleStore.legacy[tableName]
		if not next(legacyTable) then
			for key, value in pairs(_G[tableName]) do
				legacyTable[key] = value
			end
		end
	end
	_G[tableName] = moduleStore.legacy[tableName]

	return moduleStore.legacy[tableName]
end

function MTH_SA_IsModuleEnabled()
	if MTH and MTH.IsModuleEnabled then
		return MTH:IsModuleEnabled("smartammo", true) and true or false
	end
	return true
end

function MTH_SA_Print(msg, severity)
	if MTH and MTH.Print then
		MTH:Print(tostring(msg), severity)
		return
	end
	if DEFAULT_CHAT_FRAME and DEFAULT_CHAT_FRAME.AddMessage then
		DEFAULT_CHAT_FRAME:AddMessage(tostring(msg))
	end
end

local function MTH_SA_ApplySavedState()
	if type(MTHSmartAmmo_SetSmartEnabled) ~= "function" then
		return
	end

	local saved = MTH_SA_GetSavedTable("MTHSmartAmmo")
	local moduleStore = MTH and MTH.GetModuleCharSavedVariables and MTH:GetModuleCharSavedVariables("smartammo") or nil
	if type(moduleStore) == "table" then
		if moduleStore.smartEnabled ~= nil then
			saved["enabled"] = moduleStore.smartEnabled and 1 or false
		end
		if moduleStore.reloadEnabled ~= nil then
			saved["reload"] = moduleStore.reloadEnabled and 1 or false
		end
		if moduleStore.weaponSwapEnabled ~= nil then
			saved["weaponSwap"] = moduleStore.weaponSwapEnabled and 1 or false
		end
	end
	if saved["enabled"] == nil then
		saved["enabled"] = 1
		if type(moduleStore) == "table" then
			moduleStore.smartEnabled = true
		end
	end
	if saved["reload"] == nil and type(moduleStore) == "table" then
		moduleStore.reloadEnabled = saved["reload"] ~= false
	end
	if saved["weaponSwap"] == nil then
		saved["weaponSwap"] = 1
		if type(moduleStore) == "table" then
			moduleStore.weaponSwapEnabled = true
		end
	elseif type(moduleStore) == "table" and moduleStore.weaponSwapEnabled == nil then
		moduleStore.weaponSwapEnabled = saved["weaponSwap"] ~= false
	end

	MTHSmartAmmo_SetSmartEnabled(saved["enabled"] and 1 or nil, 1)
	if type(MTHSmartAmmo_SetReloadEnabled) == "function" then
		MTHSmartAmmo_SetReloadEnabled(saved["reload"] ~= false and 1 or nil, 1)
	end
	if type(MTHSmartAmmo_SetWeaponSwapEnabled) == "function" then
		MTHSmartAmmo_SetWeaponSwapEnabled(saved["weaponSwap"] ~= false and 1 or nil, 1)
	end
	if type(MTHSmartAmmo_EnsureHooks) == "function" then
		MTHSmartAmmo_EnsureHooks("module-apply")
	end

	if not (MTH and MTH.CaptureHookBoundary) then
		return
	end

	local castHook = getglobal("MTHSmartAmmo_CastSpell_Hook")
	local useActionHook = getglobal("MTHSmartAmmo_UseAction_Hook")
	local castByNameHook = getglobal("MTHSmartAmmo_CastSpellByName_Hook")
	if type(castHook) ~= "function" or type(useActionHook) ~= "function" or type(castByNameHook) ~= "function" then
		return
	end
	if CastSpell ~= castHook or UseAction ~= useActionHook or CastSpellByName ~= castByNameHook then
		return
	end

	MTH:CaptureHookBoundary(MTH_SA_BOUNDARY_KEY, {
		{ globalName = "CastSpell", originalName = "MTH_SA_CastSpell" },
		{ globalName = "UseAction", originalName = "MTH_SA_UseAction" },
		{ globalName = "CastSpellByName", originalName = "MTH_SA_CastSpellByName" },
	})
end

local function MTH_SA_RestoreHooks()
	if MTH and MTH.RestoreHookBoundary and MTH:RestoreHookBoundary(MTH_SA_BOUNDARY_KEY) then
		return
	end

	local castHook = getglobal("MTHSmartAmmo_CastSpell_Hook")
	local useActionHook = getglobal("MTHSmartAmmo_UseAction_Hook")
	local castByNameHook = getglobal("MTHSmartAmmo_CastSpellByName_Hook")

	if CastSpell == castHook and type(MTH_SA_CastSpell) == "function" then
		CastSpell = MTH_SA_CastSpell
	end
	if UseAction == useActionHook and type(MTH_SA_UseAction) == "function" then
		UseAction = MTH_SA_UseAction
	end
	if CastSpellByName == castByNameHook and type(MTH_SA_CastSpellByName) == "function" then
		CastSpellByName = MTH_SA_CastSpellByName
	end
end

function MTH_SmartAmmo:init()
	MTH_SA_GetSavedTable("MTHSmartAmmo")
	if self.enabled then
		MTH_SA_ApplySavedState()
	end
end

function MTH_SmartAmmo:setEnabled(enabled)
	if enabled then
		MTH_SA_ApplySavedState()
	else
		MTH_SA_RestoreHooks()
	end
end

function MTH_SmartAmmo:onEvent(evt)
	if not self.enabled then
		return
	end
	if evt == "VARIABLES_LOADED" or evt == "PLAYER_ENTERING_WORLD" then
		MTH_SA_ApplySavedState()
	end
end

function MTH_SmartAmmo:cleanup()
	self:setEnabled(false)
end

MTH:RegisterModule("smartammo", MTH_SmartAmmo)
