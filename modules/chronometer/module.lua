local MTH_ChronometerModule = {
	name = "chronometer",
	enabled = true,
	version = "1.1.0",
	events = {},
	initialized = false,
}

local MTH_CHRON_MODULE_TRACE_ENABLED = false

local function MTH_CHRON_ModuleTrace(msg)
	if not MTH_CHRON_MODULE_TRACE_ENABLED then
		return
	end
	if MTH and MTH.Print then
		MTH:Print("[CHRONTRACE] " .. tostring(msg), "debug")
	elseif DEFAULT_CHAT_FRAME and DEFAULT_CHAT_FRAME.AddMessage then
		DEFAULT_CHAT_FRAME:AddMessage("[CHRONTRACE] " .. tostring(msg))
	end
end

local function MTH_CHRON_ApplyRuntimeEnabledState(enabled)
	MTH_CHRON_ModuleTrace("module apply runtime enabled=" .. tostring(enabled and true or false))
	if not MTH_ChronometerHunter then
		MTH_CHRON_ModuleTrace("module apply runtime skipped (engine unavailable)")
		return
	end
	if enabled then
		if MTH_ChronometerHunter.MTH_Enable then
			MTH_ChronometerHunter:MTH_Enable()
		end
	else
		if MTH_ChronometerHunter.MTH_Disable then
			MTH_ChronometerHunter:MTH_Disable()
		end
	end
end

function MTH_ChronometerModule:init()
	MTH_CHRON_ModuleTrace("module init begin enabled=" .. tostring(self.enabled and true or false))
	if MTH_ChronometerHunter and MTH_ChronometerHunter.MTH_Initialize then
		MTH_ChronometerHunter:MTH_Initialize()
	end
	MTH_CHRON_ApplyRuntimeEnabledState(self.enabled and true or false)
	self.initialized = true
	MTH_CHRON_ModuleTrace("module init end initialized=true")
end

function MTH_ChronometerModule:setEnabled(enabled)
	MTH_CHRON_ModuleTrace("module setEnabled enabled=" .. tostring(enabled and true or false)
		.. " initialized=" .. tostring(self.initialized and true or false))
	if not self.initialized then
		self:init()
	end
	MTH_CHRON_ApplyRuntimeEnabledState(enabled and true or false)
end

function MTH_ChronometerModule:cleanup()
	MTH_CHRON_ModuleTrace("module cleanup")
	if MTH_ChronometerHunter and MTH_ChronometerHunter.MTH_Disable then
		MTH_ChronometerHunter:MTH_Disable()
	end
end

MTH:RegisterModule("chronometer", MTH_ChronometerModule)
