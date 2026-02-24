------------------------------------------------------
-- MetaHunt Configuration System
------------------------------------------------------

-- Global config management for modules
MTH.config = {}

local function MTH_ConfigEnsureStore(module_name)
	if type(module_name) ~= "string" or module_name == "" then
		module_name = "core"
	end

	local root = _G and _G.MTH_SavedVariables or MTH_SavedVariables
	if type(root) ~= "table" then
		if MTH and MTH.InitSavedVariables then
			MTH:InitSavedVariables()
		end
		root = _G and _G.MTH_SavedVariables or MTH_SavedVariables
	end

	if type(root) ~= "table" then
		root = { modules = {} }
		if _G then
			_G.MTH_SavedVariables = root
		end
		MTH_SavedVariables = root
	end

	if type(root.modules) ~= "table" then
		root.modules = {}
	end

	if type(root.modules[module_name]) ~= "table" then
		local legacy = root[module_name]
		if type(legacy) ~= "table" then
			legacy = {}
		end
		root.modules[module_name] = legacy
	end

	root[module_name] = root.modules[module_name]
	MTH_SavedVariables = root
	return root.modules[module_name]
end

function MTH:GetConfig(module_name, key, default)
	local store = MTH_ConfigEnsureStore(module_name)
	local value = store[key]
	if value == nil then
		return default
	end
	return value
end

function MTH:SetConfig(module_name, key, value)
	local store = MTH_ConfigEnsureStore(module_name)
	store[key] = value
end
