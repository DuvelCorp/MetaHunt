if not MTH_ST_StableScanService then
	MTH_ST_StableScanService = {}
end

function MTH_ST_StableScanService:HandleEvent(evt, _eventArg1, _eventArg2)
	if type(MTH_ST_HandleStableUiEvent) ~= "function" then
		return false
	end
	return MTH_ST_HandleStableUiEvent(evt) and true or false
end
