if not MTH_ST_VitalsService then
	MTH_ST_VitalsService = {}
end

function MTH_ST_VitalsService:HandleEvent(evt, eventArg1, _eventArg2)
	if type(MTH_ST_HandleVitalsEvent) ~= "function" then
		return false
	end
	return MTH_ST_HandleVitalsEvent(evt, eventArg1) and true or false
end
