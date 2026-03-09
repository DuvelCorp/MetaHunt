if not MTH_ST_LifecycleService then
	MTH_ST_LifecycleService = {}
end

function MTH_ST_LifecycleService:HandleEvent(evt, eventArg1, eventArg2)
	if type(MTH_ST_HandlePlayerEnteringWorld) == "function" and MTH_ST_HandlePlayerEnteringWorld(evt) then
		return true, "lifecycle-enter-world"
	end
	if type(MTH_ST_HandleUnitPetEvent) == "function" and MTH_ST_HandleUnitPetEvent(evt, eventArg1) then
		if evt == "UNIT_PET" then
			if eventArg1 == "player" then
				return true, "lifecycle-unit-pet-player"
			end
			return true, "lifecycle-unit-pet-other"
		end
		return true, "lifecycle-unit-pet"
	end
	return false
end
