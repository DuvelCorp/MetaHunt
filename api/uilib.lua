MTH_UI = MTH_UI or {}

MTH_UI.version = "0.1.0"
MTH_UI.pages = MTH_UI.pages or {}
MTH_UI.pageOrder = MTH_UI.pageOrder or {}
MTH_UI.callbacks = MTH_UI.callbacks or {}

local function MTH_UI_SafeCall(handler, a1, a2, a3)
	if type(handler) ~= "function" then
		return false, "handler is not a function"
	end
	local ok, resultOrError = pcall(handler, a1, a2, a3)
	if not ok then
		if MTH and MTH.Print then
			MTH:Print("[MTH_UI] " .. tostring(resultOrError), "error")
		end
		return false, resultOrError
	end
	return true, resultOrError
end

local function MTH_UI_CopyTable(value)
	if type(value) ~= "table" then return value end
	local copy = {}
	for key, nestedValue in pairs(value) do
		copy[key] = MTH_UI_CopyTable(nestedValue)
	end
	return copy
end

local function MTH_UI_ApplyDefaults(target, defaults)
	if type(target) ~= "table" or type(defaults) ~= "table" then return target end
	for key, defaultValue in pairs(defaults) do
		if target[key] == nil then
			target[key] = MTH_UI_CopyTable(defaultValue)
		elseif type(target[key]) == "table" and type(defaultValue) == "table" then
			MTH_UI_ApplyDefaults(target[key], defaultValue)
		end
	end
	return target
end

function MTH_UI.CloneTable(value)
	return MTH_UI_CopyTable(value)
end

function MTH_UI.MergeDefaults(target, defaults)
	return MTH_UI_ApplyDefaults(target, defaults)
end

function MTH_UI.ResolveValue(value, context)
	if type(value) == "function" then
		local ok, resolved = MTH_UI_SafeCall(value, context)
		if ok then return resolved end
		return nil
	end
	return value
end

function MTH_UI.RegisterCallback(eventName, callbackKey, handler)
	if type(eventName) ~= "string" or eventName == "" then return false end
	if type(callbackKey) ~= "string" or callbackKey == "" then return false end
	if type(handler) ~= "function" then return false end

	if not MTH_UI.callbacks[eventName] then
		MTH_UI.callbacks[eventName] = {}
	end
	MTH_UI.callbacks[eventName][callbackKey] = handler
	return true
end

function MTH_UI.UnregisterCallback(eventName, callbackKey)
	if not MTH_UI.callbacks[eventName] then return false end
	if not MTH_UI.callbacks[eventName][callbackKey] then return false end
	MTH_UI.callbacks[eventName][callbackKey] = nil
	return true
end

function MTH_UI.FireCallback(eventName, payload)
	local listeners = MTH_UI.callbacks[eventName]
	if not listeners then return end
	for _, handler in pairs(listeners) do
		MTH_UI_SafeCall(handler, payload)
	end
end

function MTH_UI.RegisterPage(pageId, pageDefinition)
	if type(pageId) ~= "string" or pageId == "" then return false, "invalid page id" end
	if type(pageDefinition) ~= "table" then return false, "page definition must be a table" end

	local rootType = pageDefinition.type or "group"
	if rootType ~= "group" then
		return false, "root page type must be group"
	end

	local existing = MTH_UI.pages[pageId]
	MTH_UI.pages[pageId] = MTH_UI_CopyTable(pageDefinition)
	MTH_UI.pages[pageId].id = pageId

	if not existing then
		table.insert(MTH_UI.pageOrder, pageId)
	end

	MTH_UI.FireCallback("PageRegistered", pageId)
	return true
end

function MTH_UI.GetPage(pageId)
	return MTH_UI.pages[pageId]
end

function MTH_UI.ListPages()
	local pageList = {}
	for _, pageId in ipairs(MTH_UI.pageOrder) do
		if MTH_UI.pages[pageId] then
			table.insert(pageList, pageId)
		end
	end
	return pageList
end

function MTH_UI.NotifyPageChanged(pageId)
	MTH_UI.FireCallback("PageChanged", pageId)
end

