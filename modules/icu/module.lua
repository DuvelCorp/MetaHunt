------------------------------------------------------
-- MetaHunt: ICU Module Wrapper
-- Safe wrapper for ICU minimap targeting utilities
------------------------------------------------------

local MTH_ICU = {
	name = "icu",
	enabled = false,
	version = "1.1.0",
	events = {
		"VARIABLES_LOADED",
	},
	initialized = false,
}

local function ICU_Log(message, severity)
	if type(MTH_Log) == "function" then
		MTH_Log("[ICU] " .. tostring(message or ""), severity)
	end
end

function MTH_ICU:init()
	self.initialized = true
	if type(ICU_SetEnabled) == "function" then
		ICU_SetEnabled(self.enabled and true or false)
	end
end

function MTH_ICU:setEnabled(enabled)
	if not self.initialized then
		self:init()
	end
	if type(ICU_SetEnabled) == "function" then
		ICU_SetEnabled(enabled and true or false)
	else
		ICU_Log("runtime not loaded; cannot change enabled state", "error")
	end
end

function MTH_ICU:onEvent(eventName)
	if eventName == "VARIABLES_LOADED" and type(ICU_SetEnabled) == "function" then
		ICU_SetEnabled(self.enabled and true or false)
	end
end

function MTH_ICU:cleanup()
	if type(ICU_SetEnabled) == "function" then
		ICU_SetEnabled(false)
	end
end

MTH:RegisterModule("icu", MTH_ICU)
