if not MTH_ST_RunawayService then
	MTH_ST_RunawayService = {}
end

function MTH_ST_RunawayService:HandleEvent(evt, eventArg1, _eventArg2)
	if type(MTH_ST_HandleRunawayEvent) ~= "function" then
		return false
	end
	return MTH_ST_HandleRunawayEvent(evt, eventArg1) and true or false
end
