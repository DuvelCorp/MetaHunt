local MTH_ChronometerModule = {
	name = "chronometer",
	enabled = true,
	version = "1.0.5",
	events = {},
	initialized = false,
}

local function MTH_CHRON_ApplyRuntimeEnabledState(enabled)
	if not MTH_ChronometerHunter then
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
	if MTH_ChronometerHunter and MTH_ChronometerHunter.MTH_Initialize then
		MTH_ChronometerHunter:MTH_Initialize()
	end
	MTH_CHRON_ApplyRuntimeEnabledState(self.enabled and true or false)
	self.initialized = true
end

function MTH_ChronometerModule:setEnabled(enabled)
	if not self.initialized then
		self:init()
	end
	MTH_CHRON_ApplyRuntimeEnabledState(enabled and true or false)
end

function MTH_ChronometerModule:cleanup()
	if MTH_ChronometerHunter and MTH_ChronometerHunter.MTH_Disable then
		MTH_ChronometerHunter:MTH_Disable()
	end
end

MTH:RegisterModule("chronometer", MTH_ChronometerModule)
