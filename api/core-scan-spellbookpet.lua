if not MTH then
	error("MetaHunt core framework missing: api/core-framework.lua must load before api/core-scan-spellbookpet.lua")
end

local MTH_PS_Frame = nil
local MTH_PS_LastScanAt = 0
local MTH_PS_VERBOSE_LOGS = false
local MTH_PS_ForceScanUntil = 0
local MTH_PS_ForceScanBudget = 0

local function MTH_PS_ClearForceWindow()
	MTH_PS_ForceScanUntil = 0
	MTH_PS_ForceScanBudget = 0
end

local function MTH_PS_ArmForceWindow(durationSeconds, maxScans)
	local now = tonumber(time()) or 0
	local duration = tonumber(durationSeconds) or 4
	local budget = tonumber(maxScans) or 6
	if duration < 1 then duration = 1 end
	if budget < 1 then budget = 1 end
	MTH_PS_ForceScanUntil = now + duration
	MTH_PS_ForceScanBudget = budget
end

local function MTH_PS_IsFollowupEventTrigger(trigger)
	local t = tostring(trigger or "")
	return t == "event:UNIT_PET"
		or t == "event:PET_BAR_UPDATE"
		or t == "event:SPELLS_CHANGED"
		or t == "event:LEARNED_SPELL_IN_TAB"
end

local function MTH_PS_IsPriorityTrigger(trigger)
	local t = tostring(trigger or "")
	return t == "unit-pet-current-change" or t == "refresh-current-change"
end

local function MTH_PS_DebugPrint(message, force)
	return
end

local function MTH_PS_TraceTrigger(trigger, accepted, reason)
	return
end

local function MTH_PS_SafeLower(text)
	if text == nil then return "" end
	return string.lower(tostring(text))
end

local function MTH_PS_GetGlobal(name)
	if type(getglobal) == "function" then
		return getglobal(name)
	end
	if _G then
		return _G[name]
	end
	return nil
end

local function MTH_PS_GetStore()
	if not MTH_CharSavedVariables then MTH_CharSavedVariables = {} end
	if type(MTH_CharSavedVariables.petSpellScan) ~= "table" then
		MTH_CharSavedVariables.petSpellScan = {
			lastScan = 0,
			lastTrigger = "",
			lastCount = 0,
			lastHash = "",
			lastChangeAt = 0,
		}
	end
	return MTH_CharSavedVariables.petSpellScan
end

local function MTH_PS_ParseRank(name, subText)
	local rankNumber = nil
	local sub = tostring(subText or "")
	if sub ~= "" then
		local _, _, subRank = string.find(sub, "(%d+)")
		rankNumber = tonumber(subRank)
	end
	if not rankNumber then
		local _, _, nameRank = string.find(tostring(name or ""), "(%d+)")
		rankNumber = tonumber(nameRank)
	end
	if rankNumber and rankNumber > 0 then
		return rankNumber
	end
	return nil
end

local function MTH_PS_MakeToken(name, rankNumber)
	local base = MTH_PS_SafeLower(tostring(name or ""))
	if base == "" then return "" end
	local rank = tonumber(rankNumber)
	if rank and rank > 0 then
		return base .. "#" .. tostring(rank)
	end
	return base
end

local function MTH_PS_CollectPetSpellbookRows()
	local getSpellName = MTH_PS_GetGlobal("GetSpellName")
	local getSpellTexture = MTH_PS_GetGlobal("GetSpellTexture")
	local isPassiveSpell = MTH_PS_GetGlobal("IsPassiveSpell")
	local bookTypePet = MTH_PS_GetGlobal("BOOKTYPE_PET")
	if type(getSpellName) ~= "function" or not bookTypePet then
		MTH_PS_DebugPrint("Collect rows aborted: GetSpellName=" .. tostring(type(getSpellName)) .. " BOOKTYPE_PET=" .. tostring(bookTypePet), true)
		return {}
	end

	local rows = {}
	for slot = 1, 200 do
		local name, subText = getSpellName(slot, bookTypePet)
		if not name or name == "" then
			if slot == 1 then
				MTH_PS_DebugPrint("Slot 1 returned empty name (pet spellbook not ready/visible in this client context)", true)
			end
			break
		end
		local rankNumber = MTH_PS_ParseRank(name, subText)
		local token = MTH_PS_MakeToken(name, rankNumber)
		table.insert(rows, {
			slot = slot,
			name = tostring(name or ""),
			rank = rankNumber,
			icon = (type(getSpellTexture) == "function") and getSpellTexture(slot, bookTypePet) or nil,
			isPassive = (type(isPassiveSpell) == "function") and (isPassiveSpell(slot, bookTypePet) and true or false) or false,
			token = token,
		})
	end
	MTH_PS_DebugPrint("Collected rows: " .. tostring(table.getn(rows)), true)
	return rows
end

local function MTH_PS_HashRows(rows)
	if type(rows) ~= "table" or table.getn(rows) == 0 then
		return ""
	end
	local parts = {}
	for i = 1, table.getn(rows) do
		local row = rows[i]
		parts[i] = tostring(row.token or "") .. ":" .. tostring(row.slot or "")
	end
	return table.concat(parts, "|")
end

function MTH_PS_ScanNow(trigger)
	if UnitClass then
		local _, classToken = UnitClass("player")
		if classToken ~= "HUNTER" then
			return false, 0, false
		end
	end

	local rows = MTH_PS_CollectPetSpellbookRows()
	local count = table.getn(rows)
	local hash = MTH_PS_HashRows(rows)
	local store = MTH_PS_GetStore()
	local changed = (hash ~= tostring(store.lastHash or ""))
	MTH_PS_DebugPrint("Scan trigger=" .. tostring(trigger or "auto") .. " count=" .. tostring(count) .. " changed=" .. tostring(changed and true or false), true)

	store.lastScan = time()
	store.lastTrigger = tostring(trigger or "auto")
	store.lastCount = count
	if changed then
		store.lastHash = hash
		store.lastChangeAt = store.lastScan
	end

	if type(MTH_PETS_RecordCurrentPetSpellbookSnapshot) == "function" then
		local persistedCount, updated = MTH_PETS_RecordCurrentPetSpellbookSnapshot(rows, "petspellscan:" .. tostring(trigger or "auto"))
		if updated == false then
			MTH_PS_DebugPrint("Snapshot skipped; preserved existing count=" .. tostring(persistedCount or 0), true)
		else
			MTH_PS_DebugPrint("Snapshot persisted to current pet row", true)
		end
	else
		MTH_PS_DebugPrint("Snapshot function missing: MTH_PETS_RecordCurrentPetSpellbookSnapshot", true)
	end

	MTH_PS_LastScanAt = store.lastScan
	return true, count, changed
end

function MTH_PSP_RequestScan(trigger, minIntervalSeconds)
	local triggerText = tostring(trigger or "request")
	local now = tonumber(time()) or 0
	local minInterval = tonumber(minIntervalSeconds) or 1
	local bypassThrottle = false
	local bypassReason = ""

	if MTH_PS_IsPriorityTrigger(triggerText) then
		bypassThrottle = true
		bypassReason = "priority"
		MTH_PS_ArmForceWindow(4, 6)
	elseif MTH_PS_IsFollowupEventTrigger(triggerText)
		and MTH_PS_ForceScanBudget > 0
		and now <= (tonumber(MTH_PS_ForceScanUntil) or 0)
	then
		bypassThrottle = true
		bypassReason = "followup"
		MTH_PS_ForceScanBudget = MTH_PS_ForceScanBudget - 1
	end

	if (not bypassThrottle) and minInterval > 0 and (now - (MTH_PS_LastScanAt or 0)) < minInterval then
		MTH_PS_TraceTrigger(triggerText, false, "throttled")
		return false
	end

	if bypassThrottle then
		MTH_PS_TraceTrigger(triggerText, true, bypassReason)
	else
		MTH_PS_TraceTrigger(triggerText, true, "queued")
	end

	local ok, count = MTH_PS_ScanNow(triggerText)
	if ok and tonumber(count) and tonumber(count) > 0 then
		MTH_PS_ClearForceWindow()
	elseif MTH_PS_IsPriorityTrigger(triggerText) and type(UnitExists) == "function" and UnitExists("pet") then
		MTH_PS_ArmForceWindow(4, 6)
	end
	if not ok then
		MTH_PS_TraceTrigger(triggerText, false, "scan-failed")
	end
	return ok and true or false
end

local function MTH_PS_OnEvent(_, evt, eventArg1)
	evt = evt or event
	eventArg1 = eventArg1 or arg1
	if not evt then return end

	if evt == "UNIT_PET" and eventArg1 ~= "player" then
		return
	end

	if evt == "PLAYER_ENTERING_WORLD" or evt == "UNIT_PET" or evt == "PET_BAR_UPDATE" or evt == "SPELLS_CHANGED" or evt == "LEARNED_SPELL_IN_TAB" then
		MTH_PSP_RequestScan("event:" .. tostring(evt), 1)
	end
end

function MTH_PS_InitService()
	if MTH and MTH.ApplyClassGate and MTH:ApplyClassGate("petspellscan-init") then
		return
	end
	if MTH_PS_Frame then
		return
	end

	MTH_PS_Frame = CreateFrame("Frame", "MTHPetSpellScanFrame")
	MTH_PS_Frame:RegisterEvent("PLAYER_ENTERING_WORLD")
	MTH_PS_Frame:RegisterEvent("UNIT_PET")
	MTH_PS_Frame:RegisterEvent("PET_BAR_UPDATE")
	MTH_PS_Frame:RegisterEvent("SPELLS_CHANGED")
	MTH_PS_Frame:RegisterEvent("LEARNED_SPELL_IN_TAB")
	MTH_PS_Frame:SetScript("OnEvent", MTH_PS_OnEvent)
end

function MTH_PS_ShutdownService(_reason)
	if not MTH_PS_Frame then
		return
	end
	MTH_PS_Frame:UnregisterAllEvents()
	MTH_PS_Frame:SetScript("OnEvent", nil)
	MTH_PS_Frame = nil
	MTH_PS_LastScanAt = 0
	MTH_PS_ClearForceWindow()
end

function MTH_CommandPetSpellScan()
	MTH_PS_VERBOSE_LOGS = true
	local petName = UnitName and UnitName("pet") or nil
	local hasPet = petName and petName ~= ""
	local _, playerClass = UnitClass and UnitClass("player") or nil, nil
	if UnitClass then
		_, playerClass = UnitClass("player")
	end
	MTH_PS_DebugPrint("Manual command start: class=" .. tostring(playerClass) .. " pet=" .. tostring(petName or "<none>") .. " hasPet=" .. tostring(hasPet and true or false), true)
	local bookTypePet = MTH_PS_GetGlobal("BOOKTYPE_PET")
	local getSpellName = MTH_PS_GetGlobal("GetSpellName")
	MTH_PS_DebugPrint("API check: BOOKTYPE_PET=" .. tostring(bookTypePet) .. " GetSpellNameType=" .. tostring(type(getSpellName)), true)

	local ok, count, changed = MTH_PS_ScanNow("manual")
	if not ok then
		MTH:Print("Pet spellbook scan failed.")
		MTH_PS_VERBOSE_LOGS = false
		return
	end
	MTH:Print("Pet spellbook scan: " .. tostring(count or 0) .. " spell(s). changed=" .. tostring(changed and true or false))
	local store = MTH_PS_GetStore()
	MTH_PS_DebugPrint("Store status: lastScan=" .. tostring(store.lastScan or 0) .. " lastCount=" .. tostring(store.lastCount or 0) .. " lastTrigger=" .. tostring(store.lastTrigger or "") .. " lastChangeAt=" .. tostring(store.lastChangeAt or 0), true)
	MTH_PS_VERBOSE_LOGS = false
end
