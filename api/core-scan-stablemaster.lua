if not MTH then
	error("MetaHunt core framework missing: api/core-framework.lua must load before api/core-scan-stablemaster.lua")
end

local MTH_PETS_SCHEMA_VERSION = 2
local MTH_PETS_CORE_HOOK_BOUNDARY_KEY = "core-pet-rename-hook"
MTH_PETS_TRACE_CONSISTENCY = false

local MTH_PetLifecycleEventFrame = nil
local MTH_PetLifecycleBootstrapFrame = nil
local MTH_ST_LastAutoScanAt = 0
local MTH_ST_LastUnitPetHadPet = false
local MTH_ST_DeferredStableScanFrame = nil
local MTH_ST_Profile = {
	enabled = false,
	windowStart = 0,
	windowSeconds = 5,
	eventCount = 0,
	totalMs = 0,
	maxMs = 0,
	byEvent = {},
	runawayChecks = 0,
	runawayMs = 0,
	runawayMaxMs = 0,
}
local MTH_ST_Trace = {
	enabled = false,
	verbose = false,
	windowStart = 0,
	windowSeconds = 5,
	eventCount = 0,
	byEvent = {},
	byRoute = {},
	byNote = {},
}
local MTH_ST_Diag = {
	lines = {},
	maxLines = 200,
	chatEcho = false,
}
local MTH_ST_DiagCopyFrame = nil
local MTH_ST_PrintStableDiag
local MTH_PETS_LastTameAttempt = nil
local MTH_PETS_LiveState = nil
local MTH_PETS_LiveStateSeq = 0
local MTH_PETS_LiveStateSubscribers = {}
local MTH_PETS_LiveStateEventName = "MTH_PET_LIVE_STATE_CHANGED"
local MTH_PETS_EventThrottle = {}

MTH_PETS_CoreOriginal_PetRename = MTH_PETS_CoreOriginal_PetRename or nil

local function MTH_ST_Log(line)
	return
end

local function MTH_ST_TraceNow()
	return (type(GetTime) == "function" and GetTime()) or (type(time) == "function" and time()) or nil
end

local function MTH_ST_TraceResetCounters()
	MTH_ST_Trace.eventCount = 0
	MTH_ST_Trace.byEvent = {}
	MTH_ST_Trace.byRoute = {}
	MTH_ST_Trace.byNote = {}
	MTH_ST_Trace.windowStart = MTH_ST_TraceNow() or 0
end

local function MTH_ST_TraceCount(bucket, key)
	if type(bucket) ~= "table" then
		return
	end
	local k = tostring(key or "?")
	bucket[k] = (tonumber(bucket[k]) or 0) + 1
end

local function MTH_ST_TraceBuildTopList(bucket, maxRows)
	local rows = {}
	for key, value in pairs(bucket or {}) do
		table.insert(rows, { key = tostring(key), count = tonumber(value) or 0 })
	end
	table.sort(rows, function(a, b)
		if a.count == b.count then
			return a.key < b.key
		end
		return a.count > b.count
	end)
	local limit = math.min(tonumber(maxRows) or 4, table.getn(rows))
	if limit <= 0 then
		return "none"
	end
	local parts = {}
	for i = 1, limit do
		table.insert(parts, tostring(rows[i].key) .. ":" .. tostring(rows[i].count))
	end
	return table.concat(parts, ",")
end

local function MTH_ST_TraceRecord(evt, route, note)
	if not (MTH_ST_Trace and MTH_ST_Trace.enabled) then
		return
	end
	MTH_ST_Trace.eventCount = (tonumber(MTH_ST_Trace.eventCount) or 0) + 1
	MTH_ST_TraceCount(MTH_ST_Trace.byEvent, evt)
	MTH_ST_TraceCount(MTH_ST_Trace.byRoute, route)
	if note and note ~= "" then
		MTH_ST_TraceCount(MTH_ST_Trace.byNote, note)
	end

	local evtText = tostring(evt or "")
	local routeText = tostring(route or "")
	local noteText = tostring(note or "")
	if string.find(evtText, "PET_STABLE_", 1, true)
		or routeText == "scan"
		or string.find(noteText, "stable", 1, true)
		or string.find(noteText, "deferred", 1, true)
		or string.find(noteText, "throttled", 1, true) then
		MTH_ST_PrintStableDiag("trace evt=" .. evtText .. " route=" .. routeText .. " note=" .. noteText)
	end

	if MTH_ST_Trace.verbose and MTH and MTH.Print then
		local hasPet = (type(UnitExists) == "function" and UnitExists("pet")) and true or false
		local dead = (type(UnitIsDeadOrGhost) == "function" and UnitIsDeadOrGhost("player")) or false
		MTH:Print("[STTRACE] evt=" .. tostring(evt)
			.. " route=" .. tostring(route)
			.. " note=" .. tostring(note or "-")
			.. " pet=" .. tostring(hasPet)
			.. " dead=" .. tostring(dead and true or false), "debug")
	end
end

local function MTH_ST_TraceFlushIfDue(force)
	if not (MTH_ST_Trace and MTH_ST_Trace.enabled) then
		return
	end
	local now = MTH_ST_TraceNow()
	if not now then
		return
	end
	local started = tonumber(MTH_ST_Trace.windowStart) or 0
	if started <= 0 then
		MTH_ST_Trace.windowStart = now
		return
	end
	local elapsed = now - started
	local windowSeconds = tonumber(MTH_ST_Trace.windowSeconds) or 5
	if not force and elapsed < windowSeconds then
		return
	end
	if MTH and MTH.Print then
		MTH:Print("[STTRACE] " .. tostring(string.format("%.1fs", elapsed))
			.. " events=" .. tostring(tonumber(MTH_ST_Trace.eventCount) or 0)
			.. " byEvent=" .. tostring(MTH_ST_TraceBuildTopList(MTH_ST_Trace.byEvent, 6))
			.. " byRoute=" .. tostring(MTH_ST_TraceBuildTopList(MTH_ST_Trace.byRoute, 6))
			.. " notes=" .. tostring(MTH_ST_TraceBuildTopList(MTH_ST_Trace.byNote, 6)),
		"debug")
	end
	MTH_ST_TraceResetCounters()
end

local function MTH_ST_IsStableUiEvent(evt)
	return evt == "PET_STABLE_SHOW"
		or evt == "PET_STABLE_UPDATE"
		or evt == "PET_STABLE_CLOSED"
end

MTH_ST_PrintStableDiag = function(line)
	return
end

local function MTH_ST_BuildDiagDumpText()
	local lines = MTH_ST_Diag.lines or {}
	if table.getn(lines) <= 0 then
		return "(no stable diagnostics captured yet)"
	end
	return table.concat(lines, "\n")
end

local function MTH_ST_EnsureDiagCopyFrame()
	if MTH_ST_DiagCopyFrame then
		return MTH_ST_DiagCopyFrame
	end
	local frame = CreateFrame("Frame", "MTHStableDiagCopyFrame", UIParent)
	if not frame then
		return nil
	end
	frame:SetWidth(820)
	frame:SetHeight(440)
	frame:SetPoint("CENTER", UIParent, "CENTER")
	frame:SetFrameStrata("DIALOG")
	frame:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
		tile = true,
		tileSize = 32,
		edgeSize = 32,
		insets = { left = 11, right = 12, top = 12, bottom = 11 },
	})
	frame:SetBackdropColor(0, 0, 0, 0.9)
	frame:SetMovable(true)
	frame:EnableMouse(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetScript("OnDragStart", function() frame:StartMoving() end)
	frame:SetScript("OnDragStop", function() frame:StopMovingOrSizing() end)

	local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	title:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -15)
	title:SetText("MetaHunt Stable Diagnostics")

	local closeButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
	closeButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -12, -12)
	closeButton:SetWidth(24)
	closeButton:SetHeight(24)
	closeButton:SetText("X")
	closeButton:SetScript("OnClick", function() frame:Hide() end)

	local copyButton = CreateFrame("Button", nil, frame, "GameMenuButtonTemplate")
	copyButton:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 12, 12)
	copyButton:SetWidth(110)
	copyButton:SetHeight(24)
	copyButton:SetText("Select All")

	local scrollFrame = CreateFrame("ScrollFrame", "MTHStableDiagCopyScroll", frame, "UIPanelScrollFrameTemplate")
	scrollFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, -48)
	scrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -36, 44)

	local editBox = CreateFrame("EditBox", "MTHStableDiagCopyText", scrollFrame)
	editBox:SetMultiLine(true)
	editBox:SetMaxLetters(999999)
	editBox:SetFont("Fonts\\FRIZQT__.TTF", 11, "")
	editBox:SetTextColor(0.85, 0.85, 0.85, 1)
	editBox:SetWidth(760)
	editBox:SetHeight(1)
	editBox:SetAutoFocus(false)
	editBox:EnableMouse(true)
	editBox:EnableMouseWheel(true)
	editBox:SetScript("OnEscapePressed", function() editBox:ClearFocus() end)
	editBox:SetScript("OnMouseWheel", function()
		local curr = scrollFrame:GetVerticalScroll()
		if arg1 and arg1 > 0 then
			scrollFrame:SetVerticalScroll(curr - 24)
		else
			scrollFrame:SetVerticalScroll(curr + 24)
		end
	end)
	scrollFrame:SetScrollChild(editBox)

	copyButton:SetScript("OnClick", function()
		editBox:HighlightText(0, -1)
		editBox:SetFocus()
	end)

	frame._scroll = scrollFrame
	frame._edit = editBox
	MTH_ST_DiagCopyFrame = frame
	if UISpecialFrames then
		local exists = false
		for i = 1, table.getn(UISpecialFrames) do
			if UISpecialFrames[i] == "MTHStableDiagCopyFrame" then
				exists = true
				break
			end
		end
		if not exists then
			table.insert(UISpecialFrames, "MTHStableDiagCopyFrame")
		end
	end
	return frame
end

function MTH_CommandStableDiag(mode)
	MTH_ST_Diag.lines = {}
	MTH_ST_Diag.chatEcho = false
	if MTH and MTH.Print then
		MTH:Print("Stable diagnostics are disabled.")
	end
	return false
end

function MTH_CommandStableTrace(mode)
	MTH_ST_Trace.enabled = false
	MTH_ST_Trace.verbose = false
	if MTH and MTH.Print then
		MTH:Print("Stable trace is disabled.")
	end
	return false
end

local function MTH_ST_ProfileNow()
	return (type(GetTime) == "function" and GetTime()) or (type(time) == "function" and time()) or nil
end

local function MTH_ST_ProfileResetCounters()
	MTH_ST_Profile.eventCount = 0
	MTH_ST_Profile.totalMs = 0
	MTH_ST_Profile.maxMs = 0
	MTH_ST_Profile.byEvent = {}
	MTH_ST_Profile.runawayChecks = 0
	MTH_ST_Profile.runawayMs = 0
	MTH_ST_Profile.runawayMaxMs = 0
	MTH_ST_Profile.windowStart = MTH_ST_ProfileNow() or 0
end

local function MTH_ST_ProfileRecordEvent(evt, elapsedMs)
	if not (MTH_ST_Profile and MTH_ST_Profile.enabled) then
		return
	end
	local eventName = tostring(evt or "?")
	local elapsed = tonumber(elapsedMs) or 0
	MTH_ST_Profile.eventCount = (tonumber(MTH_ST_Profile.eventCount) or 0) + 1
	MTH_ST_Profile.totalMs = (tonumber(MTH_ST_Profile.totalMs) or 0) + elapsed
	if elapsed > (tonumber(MTH_ST_Profile.maxMs) or 0) then
		MTH_ST_Profile.maxMs = elapsed
	end
	if type(MTH_ST_Profile.byEvent[eventName]) ~= "table" then
		MTH_ST_Profile.byEvent[eventName] = { count = 0, totalMs = 0, maxMs = 0 }
	end
	local row = MTH_ST_Profile.byEvent[eventName]
	row.count = (tonumber(row.count) or 0) + 1
	row.totalMs = (tonumber(row.totalMs) or 0) + elapsed
	if elapsed > (tonumber(row.maxMs) or 0) then
		row.maxMs = elapsed
	end
end

local function MTH_ST_ProfileRecordRunaway(elapsedMs)
	if not (MTH_ST_Profile and MTH_ST_Profile.enabled) then
		return
	end
	local elapsed = tonumber(elapsedMs) or 0
	MTH_ST_Profile.runawayChecks = (tonumber(MTH_ST_Profile.runawayChecks) or 0) + 1
	MTH_ST_Profile.runawayMs = (tonumber(MTH_ST_Profile.runawayMs) or 0) + elapsed
	if elapsed > (tonumber(MTH_ST_Profile.runawayMaxMs) or 0) then
		MTH_ST_Profile.runawayMaxMs = elapsed
	end
end

local function MTH_ST_ProfileBuildTopList(metricKey, maxRows)
	local rows = {}
	for eventName, row in pairs(MTH_ST_Profile.byEvent or {}) do
		if type(row) == "table" then
			table.insert(rows, {
				event = tostring(eventName),
				count = tonumber(row.count) or 0,
				totalMs = tonumber(row.totalMs) or 0,
				maxMs = tonumber(row.maxMs) or 0,
			})
		end
	end
	table.sort(rows, function(a, b)
		local av = tonumber(a[metricKey]) or 0
		local bv = tonumber(b[metricKey]) or 0
		if av == bv then
			return tostring(a.event or "") < tostring(b.event or "")
		end
		return av > bv
	end)

	local limit = math.min(tonumber(maxRows) or 3, table.getn(rows))
	if limit <= 0 then
		return "none"
	end

	local parts = {}
	for i = 1, limit do
		local row = rows[i]
		if metricKey == "count" then
			table.insert(parts, tostring(row.event) .. ":" .. tostring(row.count))
		else
			table.insert(parts, tostring(row.event) .. ":" .. string.format("%.2f", tonumber(row.totalMs) or 0) .. "ms")
		end
	end
	return table.concat(parts, ",")
end

local function MTH_ST_ProfileFlushIfDue(force)
	if not (MTH_ST_Profile and MTH_ST_Profile.enabled) then
		return
	end
	local now = MTH_ST_ProfileNow()
	if not now then
		return
	end
	local windowStart = tonumber(MTH_ST_Profile.windowStart) or 0
	if windowStart <= 0 then
		MTH_ST_Profile.windowStart = now
		return
	end
	local elapsed = now - windowStart
	local windowSeconds = tonumber(MTH_ST_Profile.windowSeconds) or 5
	if not force and elapsed < windowSeconds then
		return
	end
	if MTH and MTH.Print then
		local eventCount = tonumber(MTH_ST_Profile.eventCount) or 0
		local totalMs = tonumber(MTH_ST_Profile.totalMs) or 0
		local avgMs = (eventCount > 0) and (totalMs / eventCount) or 0
		local maxMs = tonumber(MTH_ST_Profile.maxMs) or 0
		local runawayChecks = tonumber(MTH_ST_Profile.runawayChecks) or 0
		local runawayMs = tonumber(MTH_ST_Profile.runawayMs) or 0
		local runawayAvg = (runawayChecks > 0) and (runawayMs / runawayChecks) or 0
		local runawayMax = tonumber(MTH_ST_Profile.runawayMaxMs) or 0
		local topCount = MTH_ST_ProfileBuildTopList("count", 4)
		local topMs = MTH_ST_ProfileBuildTopList("totalMs", 4)
		MTH:Print("[STPROF] " .. tostring(string.format("%.1fs", elapsed))
			.. " events=" .. tostring(eventCount)
			.. " total=" .. tostring(string.format("%.2f", totalMs)) .. "ms"
			.. " avg=" .. tostring(string.format("%.3f", avgMs)) .. "ms"
			.. " max=" .. tostring(string.format("%.3f", maxMs)) .. "ms"
			.. " topCount=" .. tostring(topCount)
			.. " topMs=" .. tostring(topMs)
			.. " runaway=" .. tostring(runawayChecks)
			.. "/" .. tostring(string.format("%.2f", runawayMs)) .. "ms"
			.. " avg=" .. tostring(string.format("%.3f", runawayAvg)) .. "ms"
			.. " max=" .. tostring(string.format("%.3f", runawayMax)) .. "ms",
		"debug")
	end
	MTH_ST_ProfileResetCounters()
end

function MTH_CommandStableProfile(mode)
	MTH_ST_Profile.enabled = false
	if MTH and MTH.Print then
		MTH:Print("Stable profiler is disabled.")
	end
	return false
end

local function MTH_PETS_LogConsistency(line)
	return
end

local function MTH_PETS_LogTame(line)
	return
end

local function MTH_PETS_FormatRowConsistency(row)
	if type(row) ~= "table" then
		return "<nil-row>"
	end
	return "id=" .. tostring(row.id)
		.. " name='" .. tostring(row.name or "") .. "'"
		.. " family='" .. tostring(row.family or "") .. "'"
		.. " level='" .. tostring(row.level or "") .. "'"
		.. " signature='" .. tostring(row.signature or "") .. "'"
		.. " guid='" .. tostring(row.guid or "") .. "'"
end

local function MTH_PETS_FormatCurrentConsistency(cp)
	if type(cp) ~= "table" then
		return "<nil-current>"
	end
	return "id=" .. tostring(cp.id)
		.. " exists=" .. tostring(cp.exists)
		.. " name='" .. tostring(cp.name or "") .. "'"
		.. " family='" .. tostring(cp.family or "") .. "'"
		.. " level='" .. tostring(cp.level or "") .. "'"
		.. " signature='" .. tostring(cp.signature or "") .. "'"
		.. " guid='" .. tostring(cp.guid or "") .. "'"
end

local function MTH_PETS_RequestPetSpellScan(reason)
	local stableFrame = (type(getglobal) == "function" and getglobal("PetStableFrame")) or (_G and _G["PetStableFrame"])
	if stableFrame and type(stableFrame.IsShown) == "function" and stableFrame:IsShown() then
		MTH_ST_PrintStableDiag("swap spellscan-skip reason=stable-open src=" .. tostring(reason or "stablemaster-current-change"))
		return
	end
	MTH_ST_PrintStableDiag("swap spellscan-request reason=" .. tostring(reason or "stablemaster-current-change"))
	if type(MTH_PSP_RequestScan) == "function" then
		MTH_PSP_RequestScan(tostring(reason or "stablemaster-current-change"), 1)
	end
end

local function MTH_ST_IsStableFrameOpen()
	local stableFrame = (type(getglobal) == "function" and getglobal("PetStableFrame")) or (_G and _G["PetStableFrame"])
	return stableFrame and type(stableFrame.IsShown) == "function" and stableFrame:IsShown() and true or false
end

local function MTH_PETS_ShouldHandleThrottledEvent(key, minIntervalSeconds)
	local now = (type(GetTime) == "function" and GetTime()) or (type(time) == "function" and time()) or 0
	local threshold = tonumber(minIntervalSeconds) or 0
	local last = tonumber(MTH_PETS_EventThrottle[key] or 0) or 0
	if threshold > 0 and (now - last) < threshold then
		return false
	end
	MTH_PETS_EventThrottle[key] = now
	return true
end

local function MTH_PETS_CopyLiveState(state)
	if type(state) ~= "table" then
		return nil
	end
	local copy = {}
	for key, value in pairs(state) do
		copy[key] = value
	end
	return copy
end

local function MTH_PETS_BuildLiveState(source, skipRefresh)
	local info = (type(MTH_GetCurrentPetInfo) == "function") and MTH_GetCurrentPetInfo(skipRefresh and true or false) or nil
	if type(info) ~= "table" then
		info = {}
	end

	return {
		exists = info.exists and true or false,
		liveExists = info.liveExists and true or false,
		dead = info.dead and true or false,
		suppressed = info.suppressed and true or false,
		suppressedReason = tostring(info.suppressedReason or ""),
		id = info.id,
		name = info.name,
		family = info.family,
		level = tonumber(info.level) or nil,
		happiness = tonumber(info.happiness) or nil,
		loyalty = tonumber(info.loyalty) or nil,
		loyaltyLevel = tonumber(info.loyaltyLevel) or nil,
		health = tonumber(info.health) or nil,
		healthMax = tonumber(info.healthMax) or nil,
		xp = tonumber(info.xp) or nil,
		xpMax = tonumber(info.xpMax) or nil,
		xpPercent = tonumber(info.xpPercent) or nil,
		lastSource = info.lastSource,
		lastUpdated = tonumber(info.lastUpdated) or nil,
		acquiredAt = tonumber(info.acquiredAt) or nil,
		withMeSinceAt = tonumber(info.withMeSinceAt) or nil,
		source = tostring(source or "stablemaster"),
	}
end

local function MTH_PETS_IsSameLiveStateField(a, b)
	if a == b then
		return true
	end
	if a == nil or b == nil then
		return false
	end
	return tostring(a) == tostring(b)
end

local function MTH_PETS_AreLiveStatesEqual(left, right)
	if type(left) ~= "table" or type(right) ~= "table" then
		return false
	end

	local keys = {
		"exists", "liveExists", "dead", "suppressed", "suppressedReason",
		"id", "name", "family", "level", "happiness", "loyalty", "loyaltyLevel",
		"health", "healthMax", "xp", "xpMax", "xpPercent", "lastSource", "lastUpdated", "acquiredAt", "withMeSinceAt",
	}

	for _, key in ipairs(keys) do
		if not MTH_PETS_IsSameLiveStateField(left[key], right[key]) then
			return false
		end
	end

	return true
end

local function MTH_PETS_NotifyLiveSubscribers(state, source)
	for key, callback in pairs(MTH_PETS_LiveStateSubscribers) do
		if type(callback) == "function" then
			local ok, err = pcall(callback, MTH_PETS_CopyLiveState(state), source)
			if not ok and MTH and MTH.Print then
				MTH:Print("[PETS] live-state subscriber error ('" .. tostring(key) .. "'): " .. tostring(err), "error")
			end
		end
	end
end

function MTH_PETS_EmitLiveState(source, force, options)
	local emittedSource = source or "stablemaster"
	if type(emittedSource) ~= "string" then
		emittedSource = tostring(emittedSource)
	end
	local skipRefresh = false
	if type(options) == "table" and options.skipRefresh == true then
		skipRefresh = true
	end
	local nextState = MTH_PETS_BuildLiveState(emittedSource, skipRefresh)
	local changed = force and true or (not MTH_PETS_AreLiveStatesEqual(MTH_PETS_LiveState, nextState))
	if not changed then
		return false
	end

	MTH_PETS_LiveStateSeq = MTH_PETS_LiveStateSeq + 1
	nextState.seq = MTH_PETS_LiveStateSeq
	nextState.changedAt = time()
	MTH_PETS_LiveState = nextState

	if MTH and MTH.FireEvent then
		MTH:FireEvent(MTH_PETS_LiveStateEventName, MTH_PETS_CopyLiveState(nextState), emittedSource)
	end
	MTH_PETS_NotifyLiveSubscribers(nextState, emittedSource)
	return true
end

function MTH_PETS_GetLiveState()
	if type(MTH_PETS_LiveState) ~= "table" then
		MTH_PETS_EmitLiveState("api:init", true)
	end
	return MTH_PETS_CopyLiveState(MTH_PETS_LiveState)
end

function MTH_PETS_SubscribeLiveState(key, callback, emitCurrent)
	if type(key) ~= "string" or key == "" then
		return false, "invalid key"
	end
	if type(callback) ~= "function" then
		return false, "callback must be function"
	end

	MTH_PETS_LiveStateSubscribers[key] = callback
	if emitCurrent then
		local current = MTH_PETS_GetLiveState()
		if type(current) == "table" then
			pcall(callback, current, "subscribe:init")
		end
	end
	return true
end

function MTH_PETS_UnsubscribeLiveState(key)
	if type(key) ~= "string" or key == "" then
		return false
	end
	MTH_PETS_LiveStateSubscribers[key] = nil
	return true
end

local function MTH_PETS_SafeLower(text)
	if text == nil then return "" end
	return string.lower(tostring(text))
end

local function MTH_PETS_NormalizeText(text)
	local normalized = tostring(text or "")
	normalized = string.gsub(normalized, "^%s+", "")
	normalized = string.gsub(normalized, "%s+$", "")
	return normalized
end

local function MTH_PETS_GetLoyaltyLevelNames()
	local defaults = {
		[1] = "Rebellious",
		[2] = "Unruly",
		[3] = "Submissive",
		[4] = "Dependable",
		[5] = "Faithful",
		[6] = "Best Friend",
	}

	local names = {}
	for level = 1, 6 do
		local key = "PET_LOYALTY" .. tostring(level)
		local value = (_G and _G[key]) or (type(getglobal) == "function" and getglobal(key))
		value = MTH_PETS_NormalizeText(value)
		if value ~= "" then
			names[level] = value
		else
			names[level] = defaults[level]
		end
	end

	return names
end

local function MTH_PETS_GetLoyaltyNameByLevel(level)
	local resolvedLevel = tonumber(level)
	if not resolvedLevel or resolvedLevel < 1 or resolvedLevel > 6 then
		return nil
	end
	local names = MTH_PETS_GetLoyaltyLevelNames()
	return names[resolvedLevel]
end

local function MTH_PETS_ParseLoyaltyLevelFromText(text)
	text = MTH_PETS_NormalizeText(text)
	if text == "" then
		return nil
	end

	local _, _, levelText = string.find(text, "[Ll]oyalty%s*[Ll]evel%s*(%d+)")
	local level = tonumber(levelText)
	if level and level >= 1 and level <= 6 then
		return level
	end

	local lowerText = string.lower(text)
	local names = MTH_PETS_GetLoyaltyLevelNames()
	for index = 1, 6 do
		local loyaltyName = MTH_PETS_NormalizeText(names[index])
		if loyaltyName ~= "" and string.find(lowerText, string.lower(loyaltyName), 1, true) then
			return index
		end
	end

	return nil
end

local function MTH_PETS_FormatLoyaltyDisplay(level, text)
	local resolvedLevel = tonumber(level)
	if (not resolvedLevel or resolvedLevel < 1 or resolvedLevel > 6) then
		resolvedLevel = MTH_PETS_ParseLoyaltyLevelFromText(text)
	end
	local resolvedName = MTH_PETS_GetLoyaltyNameByLevel(resolvedLevel)
	if resolvedLevel and resolvedName ~= "" then
		return "Level " .. tostring(resolvedLevel) .. " " .. tostring(resolvedName)
	end
	if resolvedLevel then
		return "Level " .. tostring(resolvedLevel)
	end
	return nil
end

local function MTH_PETS_IsPlaceholderPetName(name)
	local normalized = MTH_PETS_SafeLower(MTH_PETS_NormalizeText(name))
	if normalized == "" then
		return true
	end
	if normalized == "unknown" then
		return true
	end
	local unknownObject = _G and _G["UNKNOWNOBJECT"]
	if type(unknownObject) == "string" and unknownObject ~= "" then
		local unknownNormalized = MTH_PETS_SafeLower(MTH_PETS_NormalizeText(unknownObject))
		if unknownNormalized ~= "" and normalized == unknownNormalized then
			return true
		end
	end
	return false
end

local function MTH_PETS_GetPlayerCoords()
	if type(GetPlayerMapPosition) ~= "function" then
		return nil, nil
	end
	local x, y = GetPlayerMapPosition("player")
	x = tonumber(x)
	y = tonumber(y)
	if not x or not y then
		return nil, nil
	end
	if x <= 0 and y <= 0 then
		return nil, nil
	end
	return x, y
end

local function MTH_PETS_CaptureContext()
	local x, y = MTH_PETS_GetPlayerCoords()
	local zoneName = (type(GetRealZoneText) == "function") and GetRealZoneText() or nil
	if (not zoneName or zoneName == "") and type(GetZoneText) == "function" then
		zoneName = GetZoneText()
	end
	local subZoneName = (type(GetSubZoneText) == "function") and GetSubZoneText() or nil
	if subZoneName == "" then
		subZoneName = nil
	end
	if zoneName == "" then
		zoneName = nil
	end
	local hunterLevel = (type(UnitLevel) == "function") and UnitLevel("player") or nil
	return {
		timestamp = time(),
		zone = zoneName,
		subZone = subZoneName,
		x = x,
		y = y,
		hunterLevel = hunterLevel,
	}
end

local function MTH_PETS_GetStableMasterName()
	if type(UnitName) ~= "function" then
		return nil
	end
	local name = nil
	if type(UnitExists) == "function" and UnitExists("npc") then
		name = UnitName("npc")
	end
	if (not name or name == "") and type(UnitExists) == "function" and UnitExists("target") then
		if type(UnitIsPlayer) ~= "function" or not UnitIsPlayer("target") then
			name = UnitName("target")
		end
	end
	name = MTH_PETS_NormalizeText(name)
	if name == "" then
		return nil
	end
	return name
end

local function MTH_PETS_NormalizeSystemMessage(rawMessage)
	local message = tostring(rawMessage or "")
	if message == "" then
		return ""
	end
	message = string.gsub(message, "|c%x%x%x%x%x%x%x%x", "")
	message = string.gsub(message, "|r", "")
	message = string.gsub(message, "^%s+", "")
	message = string.gsub(message, "%s+$", "")
	return message
end

local function MTH_PETS_NormalizeSystemMessageKey(rawMessage)
	local message = MTH_PETS_NormalizeSystemMessage(rawMessage)
	message = string.lower(tostring(message or ""))
	message = string.gsub(message, "%%s", " ")
	message = string.gsub(message, "[^%w%s]", " ")
	message = string.gsub(message, "%s+", " ")
	message = string.gsub(message, "^%s+", "")
	message = string.gsub(message, "%s+$", "")
	return message
end

local function MTH_PETS_IsRunawaySystemMessage(rawMessage)
	local message = MTH_PETS_NormalizeSystemMessage(rawMessage)
	if message == "" then
		return false
	end

	local lostPetMessage = _G and _G["PETTAME_LOSTPET"]
	if type(lostPetMessage) == "string" and lostPetMessage ~= "" then
		if message == lostPetMessage then
			return true
		end
		local messageKey = MTH_PETS_NormalizeSystemMessageKey(message)
		local lostKey = MTH_PETS_NormalizeSystemMessageKey(lostPetMessage)
		if messageKey ~= "" and lostKey ~= "" then
			if messageKey == lostKey then
				return true
			end
			if string.find(messageKey, lostKey, 1, true) then
				return true
			end
		end
	end

	local lower = string.lower(message)
	if string.find(lower, "pet has run away", 1, true) then return true end
	if string.find(lower, "pet ran away", 1, true) then return true end
	if string.find(lower, "pet has fled", 1, true) then return true end
	if string.find(lower, "pet fled", 1, true) then return true end
	if string.find(lower, "pet has left", 1, true) then return true end
	if string.find(lower, "pet left", 1, true) then return true end

	return false
end

local function MTH_PETS_ParseCreatureIdFromGuid(guid)
	local guidText = tostring(guid or "")
	if guidText == "" then
		return nil
	end

	local _, _, creatureIdText = string.find(guidText, "^Creature%-%d+%-%d+%-%d+%-%d+%-(%d+)%-%d+$")
	if creatureIdText then
		return tonumber(creatureIdText)
	end

	return nil
end

local function MTH_PETS_ParseBeastLevelBounds(levelField)
	local levelText = tostring(levelField or "")
	if levelText == "" then
		return nil, nil
	end
	local exact = tonumber(levelText)
	if exact then
		return exact, exact
	end
	local _, _, minLevel, maxLevel = string.find(levelText, "(%d+)%s*%-%s*(%d+)")
	if minLevel and maxLevel then
		return tonumber(minLevel), tonumber(maxLevel)
	end
	local _, _, single = string.find(levelText, "(%d+)")
	if single then
		local parsed = tonumber(single)
		return parsed, parsed
	end
	return nil, nil
end

local function MTH_PETS_LevelMatchesBeast(levelField, targetLevel)
	local numericTargetLevel = tonumber(targetLevel)
	if not numericTargetLevel then
		return false
	end
	local minLevel, maxLevel = MTH_PETS_ParseBeastLevelBounds(levelField)
	if not minLevel and not maxLevel then
		return false
	end
	if minLevel and maxLevel then
		return numericTargetLevel >= minLevel and numericTargetLevel <= maxLevel
	end
	if minLevel then
		return numericTargetLevel == minLevel
	end
	return false
end

local function MTH_PETS_FindBeastIdByDataset(name, family, level)
	if type(MTH_DS_Beasts) ~= "table" then
		return nil
	end
	local normalizedName = MTH_PETS_SafeLower(MTH_PETS_NormalizeText(name))
	if normalizedName == "" then
		return nil
	end
	local normalizedFamily = MTH_PETS_SafeLower(MTH_PETS_NormalizeText(family))
	local candidates = {}
	for beastId, beast in pairs(MTH_DS_Beasts) do
		if type(beast) == "table" then
			local beastName = MTH_PETS_SafeLower(MTH_PETS_NormalizeText(beast.name))
			if beastName == normalizedName then
				table.insert(candidates, { id = tonumber(beastId), beast = beast })
			end
		end
	end
	if table.getn(candidates) == 1 then
		return candidates[1].id
	end
	if table.getn(candidates) <= 0 then
		return nil
	end

	local familyMatches = {}
	if normalizedFamily ~= "" then
		for i = 1, table.getn(candidates) do
			local candidate = candidates[i]
			local beastFamily = MTH_PETS_SafeLower(MTH_PETS_NormalizeText(candidate.beast and candidate.beast.family))
			if beastFamily ~= "" and beastFamily == normalizedFamily then
				table.insert(familyMatches, candidate)
			end
		end
	end
	if table.getn(familyMatches) == 1 then
		return familyMatches[1].id
	end

	local levelMatches = {}
	local scanPool = candidates
	if table.getn(familyMatches) > 0 then
		scanPool = familyMatches
	end
	for i = 1, table.getn(scanPool) do
		local candidate = scanPool[i]
		if MTH_PETS_LevelMatchesBeast(candidate.beast and candidate.beast.lvl, level) then
			table.insert(levelMatches, candidate)
		end
	end
	if table.getn(levelMatches) == 1 then
		return levelMatches[1].id
	end

	if table.getn(scanPool) > 0 then
		return scanPool[1].id
	end
	return candidates[1].id
end

local function MTH_PETS_CaptureTargetSnapshot()
	if type(UnitExists) ~= "function" or not UnitExists("target") then
		return nil
	end
	local targetName = (type(UnitName) == "function") and UnitName("target") or nil
	if MTH_PETS_IsPlaceholderPetName(targetName) then
		return nil
	end
	local targetGuid = (type(UnitGUID) == "function") and UnitGUID("target") or nil
	local beastId = MTH_PETS_ParseCreatureIdFromGuid(targetGuid)
	local targetFamily = (type(UnitCreatureFamily) == "function") and UnitCreatureFamily("target") or nil
	local targetLevel = (type(UnitLevel) == "function") and UnitLevel("target") or nil
	if beastId == nil then
		beastId = MTH_PETS_FindBeastIdByDataset(targetName, targetFamily, targetLevel)
	end
	return {
		capturedAt = time(),
		name = targetName,
		family = targetFamily,
		level = targetLevel,
		guid = targetGuid,
		beastId = beastId,
	}
end

local function MTH_PETS_IsTameBeastSpellName(spellName)
	local normalized = MTH_PETS_SafeLower(MTH_PETS_NormalizeText(spellName))
	if normalized == "" then
		return false
	end
	if normalized == "tame beast" then
		return true
	end
	local globalTameName = _G and _G["TAMEBEAST"] or nil
	if type(globalTameName) == "string" then
		local tameNormalized = MTH_PETS_SafeLower(MTH_PETS_NormalizeText(globalTameName))
		if tameNormalized ~= "" then
			if normalized == tameNormalized then
				return true
			end
			if string.find(normalized, tameNormalized, 1, true) then
				return true
			end
		end
	end
	if string.find(normalized, "tame beast", 1, true) then
		return true
	end
	return false
end

local function MTH_PETS_GetCurrentPlayerCastOrChannelName()
	if type(UnitChannelInfo) == "function" then
		local channelName = UnitChannelInfo("player")
		if channelName and tostring(channelName) ~= "" then
			return tostring(channelName), "UnitChannelInfo"
		end
	end
	if type(UnitCastingInfo) == "function" then
		local castName = UnitCastingInfo("player")
		if castName and tostring(castName) ~= "" then
			return tostring(castName), "UnitCastingInfo"
		end
	end
	local castingBarText = _G and _G["CastingBarText"]
	if castingBarText and type(castingBarText.GetText) == "function" then
		local barText = castingBarText:GetText()
		if barText and tostring(barText) ~= "" then
			return tostring(barText), "CastingBarText"
		end
	end
	return nil, nil
end

local function MTH_PETS_IsTargetBeastCandidate()
	if type(UnitExists) ~= "function" or not UnitExists("target") then
		return false
	end
	if type(UnitIsPlayer) == "function" and UnitIsPlayer("target") then
		return false
	end
	if type(UnitCreatureType) == "function" then
		local creatureType = MTH_PETS_SafeLower(MTH_PETS_NormalizeText(UnitCreatureType("target")))
		if creatureType ~= "" and creatureType ~= "beast" then
			return false
		end
	end
	return true
end

local function MTH_PETS_RecordTameAttempt(source, spellName)
	MTH_PETS_LogTame("Channel start source=" .. tostring(source) .. " spell='" .. tostring(spellName or "") .. "'")
	local resolvedSpellName = spellName
	if not MTH_PETS_IsTameBeastSpellName(resolvedSpellName) then
		local numericArg = tonumber(resolvedSpellName)
		if numericArg and type(GetSpellInfo) == "function" then
			local byIdName = GetSpellInfo(numericArg)
			if byIdName and MTH_PETS_IsTameBeastSpellName(byIdName) then
				resolvedSpellName = byIdName
				MTH_PETS_LogTame("Resolved channel spell via GetSpellInfo(" .. tostring(numericArg) .. ") => '" .. tostring(byIdName) .. "'")
			end
		end
	end
	if not MTH_PETS_IsTameBeastSpellName(resolvedSpellName) then
		local fallbackName, fallbackSource = MTH_PETS_GetCurrentPlayerCastOrChannelName()
		if fallbackName and MTH_PETS_IsTameBeastSpellName(fallbackName) then
			resolvedSpellName = fallbackName
			MTH_PETS_LogTame("Resolved channel spell via " .. tostring(fallbackSource) .. " => '" .. tostring(fallbackName) .. "'")
		end
	end
	if not MTH_PETS_IsTameBeastSpellName(resolvedSpellName) then
		local numericArg = tonumber(spellName)
		local hasNoPet = (type(UnitExists) ~= "function") or (not UnitExists("pet"))
		if numericArg and numericArg >= 18000 and numericArg <= 22000 and hasNoPet and MTH_PETS_IsTargetBeastCandidate() then
			local tameLabel = (_G and _G["TAMEBEAST"]) or "Tame Beast"
			resolvedSpellName = tameLabel
			MTH_PETS_LogTame("Resolved channel as Tame Beast via duration heuristic arg=" .. tostring(numericArg))
		end
	end
	if not MTH_PETS_IsTameBeastSpellName(resolvedSpellName) then
		MTH_PETS_LogTame("Ignored channel start: not Tame Beast")
		local fallbackName, fallbackSource = MTH_PETS_GetCurrentPlayerCastOrChannelName()
		if fallbackName then
			MTH_PETS_LogTame("Fallback spell from " .. tostring(fallbackSource) .. " was '" .. tostring(fallbackName) .. "'")
		end
		return false
	end
	local targetSnapshot = MTH_PETS_CaptureTargetSnapshot()
	if type(targetSnapshot) ~= "table" then
		MTH_PETS_LogTame("Failed capture: no valid target snapshot")
		return false
	end
	MTH_PETS_LastTameAttempt = {
		source = tostring(source or "unknown"),
		spellName = tostring(resolvedSpellName or ""),
		capturedAt = targetSnapshot.capturedAt,
		target = targetSnapshot,
	}
	MTH_PETS_LogTame("Captured target name='" .. tostring(targetSnapshot.name or "")
		.. "' family='" .. tostring(targetSnapshot.family or "")
		.. "' level='" .. tostring(targetSnapshot.level or "")
		.. "' guid='" .. tostring(targetSnapshot.guid or "")
		.. "' beastId='" .. tostring(targetSnapshot.beastId or "") .. "'")
	MTH_PETS_LogConsistency("TameAttempt captured source=" .. tostring(source)
		.. " target='" .. tostring(targetSnapshot.name or "") .. "'"
		.. " family='" .. tostring(targetSnapshot.family or "") .. "'"
		.. " level='" .. tostring(targetSnapshot.level or "") .. "'"
		.. " beastId='" .. tostring(targetSnapshot.beastId or "") .. "'")
	return true
end

local function MTH_PETS_GetPendingTameBeastId(snapshot)
	local pending = MTH_PETS_LastTameAttempt
	if type(pending) ~= "table" or type(pending.target) ~= "table" then
		MTH_PETS_LogTame("Resolve beastId: no pending tame attempt")
		return nil
	end
	local pendingAt = tonumber(pending.capturedAt) or 0
	if pendingAt <= 0 or (time() - pendingAt) > 45 then
		MTH_PETS_LogTame("Resolve beastId: pending tame expired age=" .. tostring((time() - pendingAt)))
		return nil
	end
	local pendingTarget = pending.target
	if type(snapshot) == "table" then
		local targetFamily = MTH_PETS_SafeLower(MTH_PETS_NormalizeText(pendingTarget.family))
		local petFamily = MTH_PETS_SafeLower(MTH_PETS_NormalizeText(snapshot.family))
		if targetFamily ~= "" and petFamily ~= "" and targetFamily ~= petFamily then
			MTH_PETS_LogTame("Resolve beastId: family mismatch target='" .. tostring(targetFamily) .. "' pet='" .. tostring(petFamily) .. "'")
			return nil
		end
		local targetLevel = tonumber(pendingTarget.level)
		local petLevel = tonumber(snapshot.level)
		if targetLevel and petLevel and targetLevel ~= petLevel then
			MTH_PETS_LogTame("Resolve beastId: level mismatch target='" .. tostring(targetLevel) .. "' pet='" .. tostring(petLevel) .. "'")
			return nil
		end
	end
	if tonumber(pendingTarget.beastId) and tonumber(pendingTarget.beastId) > 0 then
		MTH_PETS_LogTame("Resolve beastId: using captured beastId=" .. tostring(pendingTarget.beastId))
		return tonumber(pendingTarget.beastId)
	end
	local fromTarget = MTH_PETS_FindBeastIdByDataset(pendingTarget.name, pendingTarget.family, pendingTarget.level)
	if fromTarget then
		MTH_PETS_LogTame("Resolve beastId: DS lookup matched beastId=" .. tostring(fromTarget))
		return fromTarget
	end
	MTH_PETS_LogTame("Resolve beastId: DS lookup failed for target='" .. tostring(pendingTarget.name or "") .. "'")
	return nil
end

local function MTH_PETS_ResolveTameBeastIdForRow(row, snapshot)
	if type(row) ~= "table" then
		return nil
	end

	local pendingResolved = MTH_PETS_GetPendingTameBeastId(snapshot)
	if pendingResolved and pendingResolved > 0 then
		return pendingResolved
	end

	local fromSnapshot = snapshot and tonumber(snapshot.beastId) or nil
	if fromSnapshot and fromSnapshot > 0 then
		return fromSnapshot
	end

	local fromRow = tonumber(row.beastId)
	if fromRow and fromRow > 0 then
		return fromRow
	end

	local lookup = MTH_PETS_FindBeastIdByDataset(
		tostring((snapshot and snapshot.name) or row.name or ""),
		tostring((snapshot and snapshot.family) or row.family or ""),
		tonumber((snapshot and snapshot.level) or row.level)
	)
	if lookup and lookup > 0 then
		return lookup
	end

	return nil
end

local function MTH_PETS_MakeSignature(name, family, level)
	local cleanName = MTH_PETS_SafeLower(MTH_PETS_NormalizeText(name))
	local cleanFamily = MTH_PETS_SafeLower(MTH_PETS_NormalizeText(family))
	local numericLevel = tonumber(level) or 0
	return cleanName .. "|" .. cleanFamily .. "|" .. tostring(numericLevel)
end

local function MTH_PETS_RowHasTameRecord(row)
	if type(row) ~= "table" then
		return false
	end
	if row.tameRecorded == true then
		return true
	end
	if tonumber(row.tamedAt) and tonumber(row.tamedAt) > 0 then
		return true
	end
	if tonumber(row.tameBeastId) and tonumber(row.tameBeastId) > 0 then
		return true
	end
	if type(row.tameZone) == "string" and row.tameZone ~= "" then
		return true
	end
	return false
end

local function MTH_PETS_BackfillTameMetadataFromEvents(row)
	if type(row) ~= "table" then
		return false
	end
	if MTH_PETS_RowHasTameRecord(row) then
		return false
	end
	if type(row.events) ~= "table" then
		return false
	end

	local bestEvent = nil
	local stableFirstSeenAt = tonumber(row.stableFirstSeenAt) or tonumber(row.stabledAt) or 0
	for i = 1, table.getn(row.events) do
		local ev = row.events[i]
		if type(ev) == "table" and tostring(ev.type or "") == "pet-acquired" then
			local evAt = tonumber(ev.at) or 0
			local timelineOk = true
			if stableFirstSeenAt > 0 and evAt > 0 and evAt > stableFirstSeenAt then
				-- If we only saw this pet as stabled before the acquire event, it was likely a call-out, not a tame.
				timelineOk = false
			end
			if timelineOk then
				if not bestEvent then
					bestEvent = ev
				else
					local bestAt = tonumber(bestEvent.at) or 0
					if bestAt <= 0 or (evAt > 0 and evAt < bestAt) then
						bestEvent = ev
					end
				end
			end
		end
	end

	if type(bestEvent) ~= "table" then
		return false
	end

	local context = type(bestEvent.context) == "table" and bestEvent.context or nil
	local changed = false

	if row.tamedAt == nil or tonumber(row.tamedAt) == nil or tonumber(row.tamedAt) <= 0 then
		local candidateAt = tonumber(bestEvent.at) or (context and tonumber(context.timestamp) or nil) or tonumber(row.createdAt)
		if candidateAt and candidateAt > 0 then
			row.tamedAt = candidateAt
			changed = true
		end
	end

	if context then
		if row.tameHunterLevel == nil and context.hunterLevel ~= nil then
			row.tameHunterLevel = context.hunterLevel
			changed = true
		end
		if (row.tameZone == nil or row.tameZone == "") and context.zone ~= nil and tostring(context.zone) ~= "" then
			row.tameZone = context.zone
			changed = true
		end
		if (row.tameSubZone == nil or row.tameSubZone == "") and context.subZone ~= nil and tostring(context.subZone) ~= "" then
			row.tameSubZone = context.subZone
			changed = true
		end
		if row.tameX == nil and context.x ~= nil then
			row.tameX = context.x
			changed = true
		end
		if row.tameY == nil and context.y ~= nil then
			row.tameY = context.y
			changed = true
		end
	end

	if (row.tameBeastId == nil or tonumber(row.tameBeastId) == nil) and row.beastId ~= nil then
		local beastId = tonumber(row.beastId)
		if beastId and beastId > 0 then
			row.tameBeastId = beastId
			changed = true
		end
	end

	if changed then
		row.tameRecorded = true
		row.lastUpdated = time()
	end

	return changed
end

local function MTH_PETS_EnsurePetStoreSchema(pets)
	if type(pets.petStore) ~= "table" then
		pets.petStore = {}
	end
	local petStore = pets.petStore
	if type(petStore.activeById) ~= "table" then
		petStore.activeById = {}
	end
	if type(petStore.historyById) ~= "table" then
		petStore.historyById = {}
	end
	if type(petStore.signatureIndex) ~= "table" then
		petStore.signatureIndex = {}
	end
	if type(petStore.guidIndex) ~= "table" then
		petStore.guidIndex = {}
	end
	if type(petStore.stableSlotIndex) ~= "table" then
		petStore.stableSlotIndex = {}
	end
	if tonumber(petStore.nextId) == nil or tonumber(petStore.nextId) < 1 then
		petStore.nextId = 1
	end
	if petStore.activeCurrentId == nil then
		petStore.activeCurrentId = nil
	end

	for _, row in pairs(petStore.activeById) do
		if type(row) == "table" then
			if row.loyaltyLevel == nil and type(row.loyalty) == "string" then
				row.loyaltyLevel = MTH_PETS_ParseLoyaltyLevelFromText(row.loyalty)
			end
			if type(row.loyalty) == "string" then
				row.loyalty = nil
			end
			row.loyaltyText = nil
			row.loyaltyDisplay = nil
			if type(row.stableInfo) == "table" then
				if row.stableInfo.loyaltyLevel == nil then
					row.stableInfo.loyaltyLevel = MTH_PETS_ParseLoyaltyLevelFromText(row.stableInfo.loyalty)
				end
				row.stableInfo.loyalty = nil
			end
			MTH_PETS_BackfillTameMetadataFromEvents(row)
		end
	end
end

local function MTH_PETS_EnsureCurrentPetSchema(pets)
	if type(pets.currentPet) ~= "table" then
		pets.currentPet = {}
	end
	local currentPet = pets.currentPet
	if currentPet.id == nil then currentPet.id = nil end
	if currentPet.guid == nil then currentPet.guid = nil end
	if currentPet.signature == nil then currentPet.signature = nil end
	if currentPet.beastId == nil then currentPet.beastId = nil end
	if currentPet.name == nil then currentPet.name = nil end
	if currentPet.family == nil then currentPet.family = nil end
	if currentPet.level == nil then currentPet.level = nil end
	if currentPet.happiness == nil then currentPet.happiness = nil end
	if currentPet.loyalty == nil then currentPet.loyalty = nil end
	if currentPet.loyaltyLevel == nil then currentPet.loyaltyLevel = nil end
	if currentPet.loyaltyLevel == nil and type(currentPet.loyalty) == "string" then
		currentPet.loyaltyLevel = MTH_PETS_ParseLoyaltyLevelFromText(currentPet.loyalty)
	end
	if type(currentPet.loyalty) == "string" then
		currentPet.loyalty = nil
	end
	currentPet.loyaltyText = nil
	currentPet.loyaltyDisplay = nil
	if currentPet.xp == nil then currentPet.xp = nil end
	if currentPet.xpMax == nil then currentPet.xpMax = nil end
	if currentPet.xpPercent == nil then currentPet.xpPercent = nil end
	if currentPet.exists == nil then currentPet.exists = false end
	if currentPet.lastSeen == nil then currentPet.lastSeen = 0 end
	if currentPet.lastUpdated == nil then currentPet.lastUpdated = 0 end
	if currentPet.acquiredAt == nil then currentPet.acquiredAt = 0 end
	if currentPet.lastSource == nil then currentPet.lastSource = "" end
end

local function MTH_PETS_NormalizePetId(petId)
	if petId == nil then
		return nil
	end
	local value = tostring(petId)
	if value == "" then
		return nil
	end
	return value
end

local function MTH_PETS_SetCurrentPetId(pets, petId)
	if type(pets) ~= "table" then
		return nil
	end
	local normalized = MTH_PETS_NormalizePetId(petId)
	pets.currentPetId = normalized
	if type(pets.petStore) == "table" then
		pets.petStore.activeCurrentId = normalized
	end
	return normalized
end

local function MTH_PETS_SetCurrentPetSuppressed(pets, suppressed, reason)
	if type(pets) ~= "table" then
		return
	end
	pets.currentPetSuppressed = suppressed and true or false
	pets.currentPetSuppressedAwaitNoLive = suppressed and true or false
	pets.currentPetSuppressedReason = suppressed and tostring(reason or "") or ""
	pets.currentPetSuppressedAt = time()
end

local function MTH_PETS_ResolveNoLiveCurrentRow(pets, previousCurrentId)
	if type(pets) ~= "table" then
		return nil, nil
	end
	if pets.currentPetSuppressed == true then
		return nil, nil
	end
	local petStore = (type(pets.petStore) == "table") and pets.petStore or nil
	if type(petStore) ~= "table" or type(petStore.activeById) ~= "table" then
		return nil, nil
	end

	local cp = pets.currentPet
	local candidates = {
		previousCurrentId,
		cp and cp.id or nil,
		pets.currentPetId,
		petStore.activeCurrentId,
	}

	local seen = {}
	for i = 1, table.getn(candidates) do
		local candidateId = candidates[i]
		if candidateId ~= nil then
			local key = tostring(candidateId)
			if not seen[key] then
				seen[key] = true
				local row = petStore.activeById[candidateId]
				if type(row) == "table" then
					local stableSlot = tonumber(row.stableSlot)
					if stableSlot and stableSlot > 0 then
						return nil, nil
					end
					return tostring(candidateId), row
				end
			end
		end
	end

	return nil, nil
end

local function MTH_PETS_ApplyCurrentPetFromActiveRow(cp, petId, row)
	if type(cp) ~= "table" or petId == nil or type(row) ~= "table" then
		return
	end
	cp.id = tostring(petId)
	cp.guid = row.guid
	cp.signature = row.signature
	cp.beastId = row.beastId
	cp.name = row.name
	cp.family = row.family
	cp.level = row.level
	cp.happiness = row.happiness
	cp.loyalty = row.loyalty
	cp.loyaltyLevel = row.loyaltyLevel
	cp.xp = row.xp
	cp.xpMax = row.xpMax
	cp.xpPercent = row.xpPercent
	if cp.acquiredAt == nil or tonumber(cp.acquiredAt) == nil or tonumber(cp.acquiredAt) <= 0 then
		cp.acquiredAt = tonumber(row.createdAt) or tonumber(row.lastSeen) or tonumber(row.lastUpdated) or time()
	end
	if tonumber(cp.lastSeen) == nil or tonumber(cp.lastSeen) <= 0 then
		cp.lastSeen = tonumber(row.lastSeen) or tonumber(row.lastUpdated) or time()
	end
end

local function MTH_PETS_EnsureSchema(pets)
	local now = time()
	if pets.schemaVersion ~= MTH_PETS_SCHEMA_VERSION then
		pets.schemaVersion = MTH_PETS_SCHEMA_VERSION
		pets.schemaMigratedAt = now
		if type(pets.schemaMigration) ~= "table" then
			pets.schemaMigration = {}
		end
		pets.schemaMigration.version = MTH_PETS_SCHEMA_VERSION
		pets.schemaMigration.at = now
		pets.schemaMigration.note = "beta canonical store"
	end
	if pets.updatedAt == nil then
		pets.updatedAt = 0
	end
	if pets.createdAt == nil or tonumber(pets.createdAt) == nil or tonumber(pets.createdAt) <= 0 then
		pets.createdAt = now
	end
	if pets.currentPetId == nil then
		local cpId = (type(pets.currentPet) == "table") and pets.currentPet.id or nil
		pets.currentPetId = MTH_PETS_NormalizePetId(cpId)
	end
	if pets.currentPetSuppressed == nil then
		pets.currentPetSuppressed = false
	end
	if pets.currentPetSuppressedAwaitNoLive == nil then
		pets.currentPetSuppressedAwaitNoLive = false
	end
	if pets.currentPetSuppressedReason == nil then
		pets.currentPetSuppressedReason = ""
	end
	if pets.hasVisitedStableOnce == nil then
		pets.hasVisitedStableOnce = false
	end
	if pets.stableVisitPromptLastAt == nil then
		pets.stableVisitPromptLastAt = 0
	end
	MTH_PETS_EnsureCurrentPetSchema(pets)
	MTH_PETS_EnsurePetStoreSchema(pets)
end

local function MTH_PETS_MarkStableVisited(pets, source)
	if type(pets) ~= "table" then
		return
	end
	if pets.hasVisitedStableOnce == true then
		return
	end
	pets.hasVisitedStableOnce = true
	pets.stableVisitedAt = time()
	pets.stableVisitedSource = source or "stable-scan"
	pets.updatedAt = time()
end

local function MTH_PETS_MaybePromptStableVisit(pets)
	if type(pets) ~= "table" then
		return
	end
	if pets.hasVisitedStableOnce == true then
		return
	end
	local playerLevel = (type(UnitLevel) == "function") and tonumber(UnitLevel("player")) or nil
	if not playerLevel or playerLevel <= 12 then
		return
	end
	local now = time()
	local lastPrompt = tonumber(pets.stableVisitPromptLastAt) or 0
	if lastPrompt > 0 and (now - lastPrompt) <= 60 then
		return
	end
	pets.stableVisitPromptLastAt = now
	if MTH and MTH.Print then
		MTH:Print("No Stable scan found for this character. Visit a Stable Master once to record stable pets and slots.")
	end
end

local function MTH_PETS_EnsurePetTrainingCompatibility(pets)
	if type(pets.trainScan) ~= "table" and type(pets.petTraining) == "table" then
		pets.trainScan = pets.petTraining
	end
	if type(pets.trainScan) ~= "table" then
		pets.trainScan = {}
	end
	if type(pets.petTraining) ~= "table" then
		pets.petTraining = pets.trainScan
	end
	if pets.petTraining ~= pets.trainScan then
		pets.petTraining = pets.trainScan
	end
	local pt = pets.trainScan
	if type(pt.spellMap) ~= "table" then
		pt.spellMap = {}
	end
	if type(pt.hunterKnownMap) ~= "table" then
		pt.hunterKnownMap = {}
	end
	if pt.lastScan == nil then
		pt.lastScan = 0
	end
	if pt.lastPrompt == nil then
		pt.lastPrompt = 0
	end

	if pt.hasCompletedPetScan == nil then
		if (tonumber(pt.lastScan) or 0) > 0 then
			pt.hasCompletedPetScan = 1
		else
			for _ in pairs(pt.spellMap) do
				pt.hasCompletedPetScan = 1
				break
			end
		end
	end
end

local function MTH_PETS_GetStoreTables(pets)
	if type(pets) ~= "table" then
		return nil
	end
	MTH_PETS_EnsurePetStoreSchema(pets)
	return pets.petStore
end

local function MTH_PETS_AddSignatureIndex(store, signature, petId)
	if signature == nil or signature == "" or petId == nil then
		return
	end
	if type(store.signatureIndex[signature]) ~= "table" then
		store.signatureIndex[signature] = {}
	end
	local list = store.signatureIndex[signature]
	for _, existingId in pairs(list) do
		if existingId == petId then
			return
		end
	end
	table.insert(list, petId)
end

local function MTH_PETS_RemoveSignatureIndex(store, signature, petId)
	if signature == nil or signature == "" or petId == nil then
		return
	end
	local list = store.signatureIndex[signature]
	if type(list) ~= "table" then
		return
	end
	for i = table.getn(list), 1, -1 do
		if list[i] == petId then
			table.remove(list, i)
		end
	end
	if table.getn(list) <= 0 then
		store.signatureIndex[signature] = nil
	end
end

local function MTH_PETS_GetPetById(pets, petId)
	if petId == nil or type(pets) ~= "table" then
		return nil
	end
	local store = MTH_PETS_GetStoreTables(pets)
	if not store then
		return nil
	end
	return store.activeById[petId]
end

local function MTH_PETS_CreatePetId(store)
	local nextId = tonumber(store.nextId) or 1
	store.nextId = nextId + 1
	return "pet-" .. tostring(nextId)
end

local function MTH_PETS_MakeSnapshotFromLivePet()
	local exists = (type(UnitExists) == "function") and UnitExists("pet")
	if not exists then
		return nil
	end
	local petName = (type(UnitName) == "function") and UnitName("pet") or nil
	if MTH_PETS_IsPlaceholderPetName(petName) then
		MTH_PETS_LogConsistency("MakeSnapshotFromLivePet ignored placeholder name='" .. tostring(petName or "") .. "'")
		return nil
	end
	local petFamily = (type(UnitCreatureFamily) == "function") and UnitCreatureFamily("pet") or nil
	local petLevel = (type(UnitLevel) == "function") and UnitLevel("pet") or nil
	local happiness = nil
	local loyalty = nil
	local loyaltyLevel = nil
	local xp = nil
	local xpMax = nil
	local xpPercent = nil
	if type(GetPetHappiness) == "function" then
		local h, _, l = GetPetHappiness()
		happiness = h
		loyalty = l
	end
	local getPetLoyalty = (type(getglobal) == "function" and getglobal("GetPetLoyalty")) or (_G and _G["GetPetLoyalty"])
	if type(getPetLoyalty) == "function" then
		local lLevel, lText = getPetLoyalty()
		if lLevel ~= nil then
			loyaltyLevel = tonumber(lLevel) or nil
		end
		if lText ~= nil and tostring(lText) ~= "" then
			local lTextValue = tostring(lText)
			local parsedFromText = MTH_PETS_ParseLoyaltyLevelFromText(lTextValue)
			if loyaltyLevel == nil and parsedFromText ~= nil then
				loyaltyLevel = parsedFromText
			end
		end
	end
	local petFrameHappiness = (_G and _G["PetFrameHappiness"]) or (type(getglobal) == "function" and getglobal("PetFrameHappiness"))
	if type(petFrameHappiness) == "table" and type(petFrameHappiness.tooltipLoyalty) == "string" and petFrameHappiness.tooltipLoyalty ~= "" then
		local tooltipText = tostring(petFrameHappiness.tooltipLoyalty)
		local parsedFromTooltip = MTH_PETS_ParseLoyaltyLevelFromText(tooltipText)
		if loyaltyLevel == nil and parsedFromTooltip ~= nil then
			loyaltyLevel = parsedFromTooltip
		end
	end
	local petLoyaltyText = (_G and _G["PetLoyaltyText"]) or (type(getglobal) == "function" and getglobal("PetLoyaltyText"))
	if type(petLoyaltyText) == "table" and type(petLoyaltyText.GetText) == "function" then
		local uiLoyaltyText = MTH_PETS_NormalizeText(petLoyaltyText:GetText())
		if uiLoyaltyText ~= "" then
			local parsedFromUi = MTH_PETS_ParseLoyaltyLevelFromText(uiLoyaltyText)
			if loyaltyLevel == nil and parsedFromUi ~= nil then
				loyaltyLevel = parsedFromUi
			end
		end
	end
	local getPetExperience = (type(getglobal) == "function" and getglobal("GetPetExperience")) or (_G and _G["GetPetExperience"])
	if type(getPetExperience) == "function" then
		local pxp, pxpMax = getPetExperience()
		xp = tonumber(pxp)
		xpMax = tonumber(pxpMax)
		if xp and xpMax and xpMax > 0 then
			xpPercent = math.floor((xp / xpMax) * 1000 + 0.5) / 10
		end
	end
	local petGuid = (type(UnitGUID) == "function") and UnitGUID("pet") or nil
	local beastId = MTH_PETS_ParseCreatureIdFromGuid(petGuid)
	if beastId == nil and type(UnitGUID) == "function" then
		beastId = MTH_PETS_ParseCreatureIdFromGuid(UnitGUID("target"))
	end
	local signature = MTH_PETS_MakeSignature(petName, petFamily, petLevel)
	return {
		name = petName,
		family = petFamily,
		level = petLevel,
		happiness = happiness,
		loyalty = loyalty,
		loyaltyLevel = loyaltyLevel,
		xp = xp,
		xpMax = xpMax,
		xpPercent = xpPercent,
		guid = petGuid,
		beastId = beastId,
		signature = signature,
	}
end

local function MTH_PETS_SelectPetIdBySnapshot(store, snapshot, previousPetId)
	if type(store) ~= "table" or type(snapshot) ~= "table" then
		return nil
	end

	if previousPetId and store.activeById[previousPetId] then
		local previousRow = store.activeById[previousPetId]
		if previousRow.guid and snapshot.guid and previousRow.guid == snapshot.guid then
			return previousPetId
		end
		if previousRow.signature and snapshot.signature and previousRow.signature == snapshot.signature then
			return previousPetId
		end
	end

	if snapshot.guid and store.guidIndex[snapshot.guid] and store.activeById[store.guidIndex[snapshot.guid]] then
		return store.guidIndex[snapshot.guid]
	end

	if snapshot.signature and snapshot.signature ~= "" then
		local list = store.signatureIndex[snapshot.signature]
		if type(list) == "table" then
			local count = 0
			local candidateId = nil
			for _, listedId in pairs(list) do
				if listedId and store.activeById[listedId] then
					count = count + 1
					candidateId = listedId
				end
			end
			if count == 1 then
				return candidateId
			end
		end
	end

	return nil
end

local function MTH_PETS_ApplySnapshotToRow(row, snapshot, source, context)
	if type(row) ~= "table" or type(snapshot) ~= "table" then
		return
	end
	local isStableScan = (source == "stable-scan")
	MTH_PETS_LogConsistency("ApplySnapshotToRow(before) source=" .. tostring(source)
		.. " row=" .. MTH_PETS_FormatRowConsistency(row)
		.. " snapshotName='" .. tostring(snapshot.name or "") .. "'")
	local now = time()
	row.name = snapshot.name
	row.family = snapshot.family
	row.level = snapshot.level
	if snapshot.happiness ~= nil then
		row.happiness = snapshot.happiness
	elseif not isStableScan and row.happiness == nil then
		row.happiness = nil
	end
	if not isStableScan then
		if snapshot.loyalty ~= nil then
			row.loyalty = snapshot.loyalty
		end
		if snapshot.loyaltyLevel ~= nil then
			row.loyaltyLevel = snapshot.loyaltyLevel
		end
		if snapshot.xp ~= nil then
			row.xp = snapshot.xp
		end
		if snapshot.xpMax ~= nil then
			row.xpMax = snapshot.xpMax
		end
		if snapshot.xpPercent ~= nil then
			row.xpPercent = snapshot.xpPercent
		end
	else
		if (row.loyalty == nil or tostring(row.loyalty) == "") and snapshot.loyalty ~= nil and tostring(snapshot.loyalty) ~= "" then
			row.loyalty = snapshot.loyalty
		end
		if row.loyaltyLevel == nil and snapshot.loyaltyLevel ~= nil then
			row.loyaltyLevel = snapshot.loyaltyLevel
		end
	end
	row.guid = snapshot.guid or row.guid
	row.beastId = snapshot.beastId or row.beastId
	local hasPendingTame = type(MTH_PETS_LastTameAttempt) == "table"
	if hasPendingTame and (row.tameBeastId == nil or tonumber(row.tameBeastId) == nil) then
		local resolvedTameBeastId = MTH_PETS_ResolveTameBeastIdForRow(row, snapshot)
		if resolvedTameBeastId and resolvedTameBeastId > 0 then
			row.tameBeastId = resolvedTameBeastId
		end
	end
	if hasPendingTame and (source == "unit-pet-acquire" or source == "refresh-current-pet") and type(context) == "table" then
		row.tameRecorded = true
		row.tamedAt = row.tamedAt or context.timestamp
		row.tameHunterLevel = row.tameHunterLevel or context.hunterLevel
		row.tameZone = row.tameZone or context.zone
		row.tameSubZone = row.tameSubZone or context.subZone
		row.tameX = row.tameX or context.x
		row.tameY = row.tameY or context.y
	end
	row.signature = snapshot.signature
	row.lastUpdated = now
	if not isStableScan then
		row.lastSeen = now
	end
	row.status = "active"
	row.lastSource = source or row.lastSource
	if source ~= "stable-scan" then
		if row.stabledAt then
			row.lastUnstabledAt = now
		end
		row.stabledAt = nil
	end
	if type(context) == "table" then
		row.lastContext = context
		if not isStableScan then
			row.zone = context.zone or row.zone
			row.subZone = context.subZone or row.subZone
			row.x = context.x or row.x
			row.y = context.y or row.y
			row.hunterLevel = context.hunterLevel or row.hunterLevel
		end
	end
	if not isStableScan and type(context) == "table" then
		local hasTameRecord = (row.tameRecorded == true)
			or tonumber(row.tamedAt) ~= nil
			or tonumber(row.tameBeastId) ~= nil
			or (type(row.tameZone) == "string" and row.tameZone ~= "")
		if not hasTameRecord and hasPendingTame then
			local sourceText = tostring(source or "")
			if sourceText == "unit-pet-acquire" or sourceText == "refresh-current-pet" then
				row.tameRecorded = true
				row.tamedAt = row.tamedAt or context.timestamp
				row.tameHunterLevel = row.tameHunterLevel or context.hunterLevel
				row.tameZone = row.tameZone or context.zone
				row.tameSubZone = row.tameSubZone or context.subZone
				row.tameX = row.tameX or context.x
				row.tameY = row.tameY or context.y
				if tonumber(row.tameBeastId) == nil then
					local resolvedTameBeastId = MTH_PETS_ResolveTameBeastIdForRow(row, snapshot)
					if resolvedTameBeastId and resolvedTameBeastId > 0 then
						row.tameBeastId = resolvedTameBeastId
					end
				end
			end
		end
	end
	if type(row.abilities) ~= "table" then
		row.abilities = {}
	end
	MTH_PETS_LogConsistency("ApplySnapshotToRow(after) source=" .. tostring(source) .. " row=" .. MTH_PETS_FormatRowConsistency(row))
end

local function MTH_PETS_UpsertActivePetFromSnapshot(pets, snapshot, source, options)
	if type(pets) ~= "table" or type(snapshot) ~= "table" then
		return nil, false
	end
	local petStore = MTH_PETS_GetStoreTables(pets)
	if not petStore then
		return nil, false
	end
	local currentPet = pets.currentPet
	local previousPetId = currentPet and currentPet.id or nil
	local petId = MTH_PETS_SelectPetIdBySnapshot(petStore, snapshot, previousPetId)
	local created = false
	if not petId then
		petId = MTH_PETS_CreatePetId(petStore)
		created = true
	end
	MTH_PETS_LogConsistency("UpsertActivePet select source=" .. tostring(source)
		.. " previousCurrentId=" .. tostring(previousPetId)
		.. " selectedId=" .. tostring(petId)
		.. " created=" .. tostring(created)
		.. " snapshotName='" .. tostring(snapshot.name or "") .. "'")

	local row = petStore.activeById[petId]
	local wasKnownRow = type(row) == "table"
	if type(row) ~= "table" then
		row = {
			id = petId,
			createdAt = time(),
			firstSeen = time(),
			abilities = {},
			events = {},
			status = "active",
		}
		petStore.activeById[petId] = row
		created = true
	end

	if row.signature and row.signature ~= snapshot.signature then
		MTH_PETS_RemoveSignatureIndex(petStore, row.signature, petId)
	end
	if row.stableSlot and petStore.stableSlotIndex[row.stableSlot] == petId then
		petStore.stableSlotIndex[row.stableSlot] = nil
	end
	row.stableSlot = nil
	if row.guid and row.guid ~= snapshot.guid and petStore.guidIndex[row.guid] == petId then
		petStore.guidIndex[row.guid] = nil
	end

	local context = MTH_PETS_CaptureContext()
	MTH_PETS_ApplySnapshotToRow(row, snapshot, source, context)
	row.firstSeen = row.firstSeen or time()

	if snapshot.guid and snapshot.guid ~= "" then
		petStore.guidIndex[snapshot.guid] = petId
	end
	if snapshot.signature and snapshot.signature ~= "" then
		MTH_PETS_AddSignatureIndex(petStore, snapshot.signature, petId)
	end

	if created then
		row.origin = source or "unknown"
		row.originContext = context
		local hasPendingTame = type(MTH_PETS_LastTameAttempt) == "table"
		local shouldRecordTame = hasPendingTame and (source == "unit-pet-acquire" or source == "refresh-current-pet")
		if shouldRecordTame then
			row.tamedAt = context.timestamp
			row.tameHunterLevel = context.hunterLevel
			row.tameZone = context.zone
			row.tameSubZone = context.subZone
			row.tameX = context.x
			row.tameY = context.y
			row.tameBeastId = snapshot.beastId
			row.tameRecorded = true
		end
		if type(options) == "table" and options.stableSlot then
			row.origin = "stable-slot"
		end
	end

	MTH_PETS_SetCurrentPetId(pets, petId)
	pets.updatedAt = time()
	MTH_PETS_LogConsistency("UpsertActivePet finalized activeCurrentId=" .. tostring(petStore.activeCurrentId)
		.. " row=" .. MTH_PETS_FormatRowConsistency(row))

	return petId, created
end

local function MTH_PETS_RecordStableSlot(pets, slot, raw1, raw2, raw3, raw4, raw5, raw6, raw7, raw8, scanContext, scanStableMasterName)
	if type(pets) ~= "table" then
		return
	end
	local slotNumber = tonumber(slot)
	if not slotNumber or slotNumber <= 0 then
		return
	end
	local petStore = MTH_PETS_GetStoreTables(pets)
	if not petStore then
		return
	end

	if raw2 == nil or raw2 == "" then
		petStore.stableSlotIndex[slotNumber] = nil
		MTH_PETS_LogConsistency("RecordStableSlot cleared slot=" .. tostring(slotNumber) .. " because name is empty")
		return
	end
	MTH_PETS_LogConsistency("RecordStableSlot slot=" .. tostring(slotNumber)
		.. " name='" .. tostring(raw2 or "") .. "'"
		.. " family='" .. tostring(raw4 or "") .. "'"
		.. " level='" .. tostring(raw3 or "") .. "'")

	local snapshot = {
		name = raw2,
		family = raw4,
		level = tonumber(raw3) or 0,
		happiness = nil,
		loyalty = nil,
		loyaltyLevel = MTH_PETS_ParseLoyaltyLevelFromText(raw5),
		xp = nil,
		xpMax = nil,
		xpPercent = nil,
		guid = nil,
		beastId = nil,
		signature = MTH_PETS_MakeSignature(raw2, raw4, raw3),
	}

	local existingId = petStore.stableSlotIndex[slotNumber]
	local petId = nil
	if existingId and petStore.activeById[existingId] then
		local existingRow = petStore.activeById[existingId]
		local existingSignature = existingRow and existingRow.signature or nil
		local snapshotSignature = snapshot and snapshot.signature or nil
		local existingGuid = existingRow and existingRow.guid or nil
		local snapshotGuid = snapshot and snapshot.guid or nil
		local signatureMatches = (existingSignature and snapshotSignature and existingSignature == snapshotSignature) and true or false
		local guidMatches = (existingGuid and snapshotGuid and existingGuid ~= "" and existingGuid == snapshotGuid) and true or false

		if signatureMatches or guidMatches then
			petId = existingId
		else
			MTH_PETS_LogConsistency("RecordStableSlot remapping stale slot=" .. tostring(slotNumber)
				.. " existingId=" .. tostring(existingId)
				.. " existingSignature='" .. tostring(existingSignature or "") .. "'"
				.. " snapshotSignature='" .. tostring(snapshotSignature or "") .. "'")
			petStore.stableSlotIndex[slotNumber] = nil
		end
	end

	if not petId then
		petId = MTH_PETS_SelectPetIdBySnapshot(petStore, snapshot, nil)
	end

	if not petId then
		petId = MTH_PETS_CreatePetId(petStore)
	end

	local row = petStore.activeById[petId]
	local wasKnownRow = type(row) == "table"
	if type(row) ~= "table" then
		row = {
			id = petId,
			createdAt = time(),
			firstSeen = time(),
			abilities = {},
			events = {},
			status = "active",
		}
		petStore.activeById[petId] = row
	end

	if row.signature and row.signature ~= snapshot.signature then
		MTH_PETS_RemoveSignatureIndex(petStore, row.signature, petId)
	end

	local previousStableSlot = tonumber(row.stableSlot)
	local wasPreviouslyStabled = previousStableSlot ~= nil and previousStableSlot > 0
	local lastSourceLower = MTH_PETS_SafeLower(row.lastSource)
	local didEnterStableFromActive = wasKnownRow and not wasPreviouslyStabled and lastSourceLower ~= "stable-scan"

	local stableContext = type(scanContext) == "table" and scanContext or MTH_PETS_CaptureContext()
	local previousStableInfo = (type(row.stableInfo) == "table") and row.stableInfo or nil
	local stableMasterName = previousStableInfo and tostring(previousStableInfo.stableMasterName or "") or ""
	local stableZone = previousStableInfo and previousStableInfo.stableZone or nil
	local stableSubZone = previousStableInfo and previousStableInfo.stableSubZone or nil
	if didEnterStableFromActive then
		stableMasterName = MTH_PETS_NormalizeText(scanStableMasterName)
		if stableMasterName == "" then
			stableMasterName = MTH_PETS_GetStableMasterName()
		end
		if stableMasterName == "" then
			stableMasterName = ""
		end
		stableZone = stableContext and stableContext.zone or nil
		stableSubZone = stableContext and stableContext.subZone or nil
	end
	if stableSubZone == "" then stableSubZone = nil end
	if stableZone == "" then stableZone = nil end
	MTH_PETS_ApplySnapshotToRow(row, snapshot, "stable-scan", stableContext)
	if tonumber(row.stableSlot) ~= slotNumber then
		if didEnterStableFromActive then
			row.stabledAt = time()
		else
			row.stableFirstSeenAt = row.stableFirstSeenAt or time()
		end
	end
	row.icon = raw1
	row.stableSlot = slotNumber
	row.stableRaw = { raw1, raw2, raw3, raw4, raw5, raw6, raw7, raw8 }
	row.stableInfo = {
		icon = raw1,
		name = raw2,
		level = raw3,
		family = raw4,
		loyaltyLevel = MTH_PETS_ParseLoyaltyLevelFromText(raw5),
		stabledAt = row.stabledAt,
		stableFirstSeenAt = row.stableFirstSeenAt,
		stableZone = stableZone,
		stableSubZone = stableSubZone,
		stableMasterName = stableMasterName,
		r6 = raw6,
		r7 = raw7,
		r8 = raw8,
		updatedAt = (didEnterStableFromActive and time()) or (previousStableInfo and previousStableInfo.updatedAt) or time(),
	}

	if snapshot.signature and snapshot.signature ~= "" then
		MTH_PETS_AddSignatureIndex(petStore, snapshot.signature, petId)
	end
	petStore.stableSlotIndex[slotNumber] = petId
	pets.updatedAt = time()
end

function MTH_PETS_RecordCurrentPetLearnedAbility(abilityName, rankNumber, source)
	local pets = MTH_PETS_GetRootStore()
	if type(pets) ~= "table" then
		return false
	end
	local cp = pets.currentPet
	if type(cp) ~= "table" or cp.exists ~= true or not cp.id then
		return false
	end
	local row = MTH_PETS_GetPetById(pets, cp.id)
	if type(row) ~= "table" then
		return false
	end
	if type(row.abilities) ~= "table" then
		row.abilities = {}
	end
	local nameText = MTH_PETS_NormalizeText(abilityName)
	if nameText == "" then
		return false
	end
	local token = MTH_PETS_SafeLower(nameText)
	local numericRank = tonumber(rankNumber)
	if numericRank and numericRank > 0 then
		token = token .. "#" .. tostring(numericRank)
	end
	row.abilities[token] = {
		name = nameText,
		rank = numericRank,
		source = source or "unknown",
		recordedAt = time(),
	}
	row.lastUpdated = time()
	pets.updatedAt = time()
	return true
end

function MTH_PETS_RecordCurrentPetSpellbookSnapshot(spells, source)
	local pets = MTH_PETS_GetRootStore()
	if type(pets) ~= "table" then
		return 0, false
	end
	local cp = pets.currentPet
	if type(cp) ~= "table" or cp.exists ~= true or not cp.id then
		return 0, false
	end
	local row = MTH_PETS_GetPetById(pets, cp.id)
	if type(row) ~= "table" then
		return 0, false
	end
	if type(spells) ~= "table" then
		spells = {}
	end

	local stored = {}
	local count = 0
	for i = 1, table.getn(spells) do
		local spell = spells[i]
		if type(spell) == "table" and tostring(spell.name or "") ~= "" then
			count = count + 1
			stored[count] = {
				name = tostring(spell.name or ""),
				rank = spell.rank,
				icon = spell.icon,
				isPassive = spell.isPassive and true or false,
				slot = tonumber(spell.slot) or count,
				token = spell.token,
			}
		end
	end

	local existingSpellbook = row.petSpellbook
	local existingCount = 0
	if type(existingSpellbook) == "table" then
		existingCount = tonumber(existingSpellbook.count) or 0
	end
	if count <= 0 and existingCount > 0 then
		row.lastPetSpellbookSkipAt = time()
		row.lastPetSpellbookSkipSource = source or "unknown"
		row.lastPetSpellbookSkipReason = "empty-scan-preserved-existing"
		row.lastUpdated = time()
		pets.updatedAt = time()
		return existingCount, false
	end

	row.petSpellbook = {
		updatedAt = time(),
		source = source or "unknown",
		count = count,
		spells = stored,
	}
	row.lastUpdated = time()
	pets.updatedAt = time()
	return count, true
end

local function MTH_PETS_MoveToHistory(pets, petId, source, context, reason)
	if type(pets) ~= "table" or not petId then
		return false
	end
	local petStore = MTH_PETS_GetStoreTables(pets)
	if type(petStore) ~= "table" then
		return false
	end
	local resolvedPetId = petId
	local row = petStore and petStore.activeById and petStore.activeById[resolvedPetId]
	if type(row) ~= "table" then
		local normalizedPetId = MTH_PETS_NormalizePetId(petId)
		if normalizedPetId ~= nil then
			resolvedPetId = normalizedPetId
			row = petStore and petStore.activeById and petStore.activeById[resolvedPetId]
		end
	end
	if type(row) ~= "table" then
		return false
	end

	if row.signature then
		MTH_PETS_RemoveSignatureIndex(petStore, row.signature, resolvedPetId)
	end
	if row.guid and petStore.guidIndex[row.guid] == resolvedPetId then
		petStore.guidIndex[row.guid] = nil
	end
	if row.stableSlot and petStore.stableSlotIndex[row.stableSlot] == resolvedPetId then
		petStore.stableSlotIndex[row.stableSlot] = nil
	end

	row.status = "abandoned"
	row.abandonedAt = (context and context.timestamp) or time()
	row.abandonContext = context or MTH_PETS_CaptureContext()
	row.abandonSource = source or "unknown"
	row.abandonReason = reason or "abandon"
	row.lastUpdated = time()

	petStore.historyById[resolvedPetId] = row
	petStore.activeById[resolvedPetId] = nil
	if tostring(petStore.activeCurrentId or "") == tostring(resolvedPetId)
		or tostring(pets.currentPetId or "") == tostring(resolvedPetId) then
		MTH_PETS_SetCurrentPetId(pets, nil)
	end
	pets.updatedAt = time()
	return true
end

function MTH_PETS_RecordPetAbandon(source, explicitName)
	local pets = MTH_PETS_GetRootStore()
	if type(pets) ~= "table" then
		return false
	end
	local cp = pets.currentPet
	local petId = cp and cp.id or nil
	if not petId then
		local petStore = MTH_PETS_GetStoreTables(pets)
		if type(petStore) ~= "table" then
			return false
		end
		local petName = MTH_PETS_NormalizeText(explicitName or (cp and cp.name) or "")
		local petFamily = cp and cp.family or nil
		local petLevel = cp and cp.level or nil
		local signature = MTH_PETS_MakeSignature(petName, petFamily, petLevel)
		local list = petStore.signatureIndex[signature]
		if type(list) == "table" and table.getn(list) == 1 then
			petId = list[1]
		end
	end

	local context = MTH_PETS_CaptureContext()
	local ok = MTH_PETS_MoveToHistory(pets, petId, source or "abandon", context, "pet-abandon")

	if type(cp) == "table" then
		cp.exists = false
		cp.id = nil
		cp.guid = nil
		cp.signature = nil
		cp.beastId = nil
		cp.name = nil
		cp.family = nil
		cp.level = nil
		cp.happiness = nil
		cp.loyalty = nil
		cp.loyaltyLevel = nil
		cp.xp = nil
		cp.xpMax = nil
		cp.xpPercent = nil
		cp.lastUpdated = time()
		cp.lastSource = source or "abandon"
	end
	MTH_PETS_SetCurrentPetId(pets, nil)
	MTH_PETS_SetCurrentPetSuppressed(pets, true, "abandon")
	MTH_PETS_LastTameAttempt = nil

	return ok
end

function MTH_PETS_RecordPetRunaway(source, rawMessage)
	local pets = MTH_PETS_GetRootStore()
	if type(pets) ~= "table" then
		return false
	end

	local cp = pets.currentPet
	local petId = cp and cp.id or nil
	local petName = cp and cp.name or nil
	local context = MTH_PETS_CaptureContext()
	context.systemMessage = MTH_PETS_NormalizeSystemMessage(rawMessage)

	local ok = MTH_PETS_MoveToHistory(pets, petId, source or "runaway", context, "pet-runaway")
	if not ok then
		return false
	end

	if type(cp) == "table" then
		cp.exists = false
		cp.id = nil
		cp.guid = nil
		cp.signature = nil
		cp.beastId = nil
		cp.name = nil
		cp.family = nil
		cp.level = nil
		cp.happiness = nil
		cp.loyalty = nil
		cp.loyaltyLevel = nil
		cp.xp = nil
		cp.xpMax = nil
		cp.xpPercent = nil
		cp.lastUpdated = time()
		cp.lastSource = source or "runaway"
	end
	MTH_PETS_SetCurrentPetId(pets, nil)
	MTH_PETS_SetCurrentPetSuppressed(pets, true, "runaway")
	MTH_PETS_LastTameAttempt = nil

	MTH_ST_LastUnitPetHadPet = false
	pets.updatedAt = time()

	if MTH and MTH.Print then
		local displayName = MTH_PETS_NormalizeText(petName)
		if displayName == "" then displayName = "Unknown" end
		if MTH:IsMessageEnabled("petRanAway", true) then
			MTH:Print("YOUR PET " .. tostring(displayName) .. " HAS RUNAWAY FOREVER :-( Try to feed it better next time.")
		end
	end

	return true
end

function MTH_PETS_RecordPetRename(oldName, newName, source)
	local pets = MTH_PETS_GetRootStore()
	if type(pets) ~= "table" then
		return false
	end
	local cp = pets.currentPet
	local petId = cp and cp.id or nil
	local petStore = MTH_PETS_GetStoreTables(pets)
	local petRow = MTH_PETS_GetPetById(pets, petId)
	if type(petRow) ~= "table" then
		return false
	end

	local normalizedNewName = MTH_PETS_NormalizeText(newName)
	if normalizedNewName == "" then
		return false
	end
	local oldSignature = petRow.signature
	petRow.previousName = MTH_PETS_NormalizeText(oldName)
	petRow.name = normalizedNewName
	petRow.signature = MTH_PETS_MakeSignature(petRow.name, petRow.family, petRow.level)
	MTH_PETS_RemoveSignatureIndex(petStore, oldSignature, petId)
	MTH_PETS_AddSignatureIndex(petStore, petRow.signature, petId)
	petRow.lastUpdated = time()
	petRow.lastSource = source or "rename"

	if type(petRow.events) ~= "table" then
		petRow.events = {}
	end
	table.insert(petRow.events, {
		type = "pet-rename",
		from = MTH_PETS_NormalizeText(oldName),
		to = normalizedNewName,
		source = source or "rename",
		at = time(),
		context = MTH_PETS_CaptureContext(),
	})

	cp.name = normalizedNewName
	cp.signature = petRow.signature
	cp.lastUpdated = time()
	cp.lastSource = source or "rename"
	pets.updatedAt = time()
	return true
end

function MTH_PETS_CorePetRenameHook(newName)
	local oldName = nil
	if type(UnitName) == "function" then
		oldName = UnitName("pet")
	end
	if (not oldName or oldName == "") and MTH_CharSavedVariables and type(MTH_CharSavedVariables.MTH_Pets) == "table" then
		local cp = MTH_CharSavedVariables.MTH_Pets.currentPet
		oldName = cp and cp.name or oldName
	end

	local newNameNormalized = MTH_PETS_NormalizeText(newName)
	if newNameNormalized ~= "" then
		if type(MTH_PETS_RecordPetRename) == "function" then
			MTH_PETS_RecordPetRename(oldName, newNameNormalized, "core:PetRename")
		end

		if type(FOM_FoodQuality) == "table" and type(FOM_RealmPlayer) == "string" and FOM_RealmPlayer ~= "" then
			if type(FOM_FoodQuality[FOM_RealmPlayer]) == "table" then
				local realmMap = FOM_FoodQuality[FOM_RealmPlayer]
				local oldKey = MTH_PETS_NormalizeText(oldName)
				if oldKey ~= "" and oldKey ~= newNameNormalized and realmMap[oldKey] ~= nil then
					realmMap[newNameNormalized] = realmMap[oldKey]
					realmMap[oldKey] = nil
				end
			end
		end
	end

	if type(MTH_PETS_CoreOriginal_PetRename) == "function" and MTH_PETS_CoreOriginal_PetRename ~= MTH_PETS_CorePetRenameHook then
		return MTH_PETS_CoreOriginal_PetRename(newName)
	end
	return nil
end

local function MTH_PETS_InstallCoreRenameHook()
	if type(PetRename) ~= "function" then
		return false
	end
	if PetRename == MTH_PETS_CorePetRenameHook then
		if MTH and MTH.CaptureHookBoundary then
			MTH:CaptureHookBoundary(MTH_PETS_CORE_HOOK_BOUNDARY_KEY, {
				{ globalName = "PetRename", originalName = "MTH_PETS_CoreOriginal_PetRename" },
			})
		end
		return true
	end

	if type(MTH_PETS_CoreOriginal_PetRename) ~= "function" or MTH_PETS_CoreOriginal_PetRename == MTH_PETS_CorePetRenameHook then
		MTH_PETS_CoreOriginal_PetRename = PetRename
	end

	if MTH_PETS_CoreOriginal_PetRename == MTH_PETS_CorePetRenameHook then
		return false
	end

	PetRename = MTH_PETS_CorePetRenameHook
	if MTH and MTH.CaptureHookBoundary then
		MTH:CaptureHookBoundary(MTH_PETS_CORE_HOOK_BOUNDARY_KEY, {
			{ globalName = "PetRename", originalName = "MTH_PETS_CoreOriginal_PetRename" },
		})
	end
	return true
end

function MTH_PETS_GetRootStore()
	if not MTH_CharSavedVariables then
		MTH_CharSavedVariables = {}
	end

	if type(MTH_CharSavedVariables.MTH_Pets) ~= "table" then
		MTH_CharSavedVariables.MTH_Pets = {
			petTraining = {},
			trainScan = {},
			stableScan = {},
			petStore = {},
		}
	end

	local pets = MTH_CharSavedVariables.MTH_Pets
	if pets._betaFreshStoreApplied ~= 1 then
		pets.petTraining = {}
		pets.trainScan = {}
		pets.stableScan = {}
		pets.currentPet = {}
		pets.petStore = {}
		pets._betaFreshStoreApplied = 1
		pets.updatedAt = time()
	end
	if type(pets.petTraining) ~= "table" then
		pets.petTraining = {}
	end
	if type(pets.trainScan) ~= "table" then
		pets.trainScan = pets.petTraining
	end
	if type(pets.stableScan) ~= "table" then
		pets.stableScan = {}
	end
	if type(pets.petStore) ~= "table" then
		pets.petStore = {}
	end

	MTH_PETS_EnsureSchema(pets)
	MTH_PETS_EnsurePetTrainingCompatibility(pets)

	MTH_CharSavedVariables.petTraining = pets.petTraining
	MTH_CharSavedVariables.trainScan = pets.trainScan
	MTH_CharSavedVariables.stableScan = pets.stableScan
	MTH_CharSavedVariables.petStore = pets.petStore

	return pets
end

function MTH_PETS_RefreshCurrentPet()
	local pets = type(MTH_PETS_GetRootStore) == "function" and MTH_PETS_GetRootStore() or nil
	if type(pets) ~= "table" then
		return
	end
	MTH_PETS_EnsureCurrentPetSchema(pets)

	local cp = pets.currentPet
	local previousCurrentId = cp and cp.id or nil
	local hadPetBeforeRefresh = MTH_ST_LastUnitPetHadPet and true or false
	local now = time()
	local snapshot = MTH_PETS_MakeSnapshotFromLivePet()
	if pets.currentPetSuppressed == true and pets.currentPetSuppressedAwaitNoLive == true then
		if type(snapshot) == "table" then
			snapshot = nil
		else
			pets.currentPetSuppressedAwaitNoLive = false
		end
	end
	local hadPendingTame = type(MTH_PETS_LastTameAttempt) == "table"
	if hadPendingTame then
		MTH_PETS_LogTame("RefreshCurrentPet with pending tame attempt previousCurrentId=" .. tostring(previousCurrentId)
			.. " liveSnapshot=" .. tostring(type(snapshot) == "table"))
	end
	MTH_PETS_LogConsistency("RefreshCurrentPet start current=" .. MTH_PETS_FormatCurrentConsistency(cp)
		.. " previousCurrentId=" .. tostring(previousCurrentId)
		.. " hasLiveSnapshot=" .. tostring(type(snapshot) == "table"))
	if not snapshot then
		cp.exists = false
		local keepCurrentId, keepCurrentRow = MTH_PETS_ResolveNoLiveCurrentRow(pets, previousCurrentId)
		if keepCurrentId ~= nil and type(keepCurrentRow) == "table" then
			MTH_PETS_ApplyCurrentPetFromActiveRow(cp, keepCurrentId, keepCurrentRow)
		else
			cp.id = nil
			cp.guid = nil
			cp.signature = nil
			cp.beastId = nil
			cp.name = nil
			cp.family = nil
			cp.level = nil
			cp.happiness = nil
			cp.loyalty = nil
			cp.loyaltyLevel = nil
			cp.xp = nil
			cp.xpMax = nil
			cp.xpPercent = nil
		end
		cp.lastUpdated = now
		cp.lastSource = "no-pet"
		local petStore = MTH_PETS_GetStoreTables(pets)
		MTH_PETS_SetCurrentPetId(pets, keepCurrentId)
		MTH_PETS_LogConsistency("RefreshCurrentPet no-live result current=" .. MTH_PETS_FormatCurrentConsistency(cp)
			.. " activeCurrentId=" .. tostring(petStore and petStore.activeCurrentId or nil))
		MTH_ST_LastUnitPetHadPet = false
		pets.updatedAt = now
		return
	end

	if snapshot.beastId == nil and hadPendingTame then
		snapshot.beastId = MTH_PETS_GetPendingTameBeastId(snapshot)
		MTH_PETS_LogTame("RefreshCurrentPet resolved beastId from pending tame => " .. tostring(snapshot.beastId or "nil"))
	end

	local petId, created = MTH_PETS_UpsertActivePetFromSnapshot(pets, snapshot, "refresh-current-pet", nil)
	MTH_PETS_SetCurrentPetSuppressed(pets, false)
	cp.exists = true
	cp.id = petId
	cp.guid = snapshot.guid
	cp.signature = snapshot.signature
	cp.beastId = snapshot.beastId
	cp.name = snapshot.name
	cp.family = snapshot.family
	cp.level = snapshot.level
	cp.happiness = snapshot.happiness
	cp.loyalty = snapshot.loyalty
	cp.loyaltyLevel = snapshot.loyaltyLevel
	cp.xp = snapshot.xp
	cp.xpMax = snapshot.xpMax
	cp.xpPercent = snapshot.xpPercent
	cp.lastUpdated = now
	cp.lastSeen = now
	if created then
		cp.acquiredAt = now
		cp.lastSource = "acquired"
	else
		cp.lastSource = "refresh"
	end
	if cp.id and cp.id ~= previousCurrentId then
		MTH_PETS_RequestPetSpellScan("refresh-current-change")
	end

	local row = MTH_PETS_GetPetById(pets, petId)
	if type(row) == "table" then
		if type(row.events) ~= "table" then
			row.events = {}
		end

		local eventType = "pet-updated"
		if created and (not hadPetBeforeRefresh) then
			eventType = "pet-acquired"
		end

		local shouldRecordLifecycleEvent = (eventType == "pet-acquired")
			or (cp.id ~= nil and previousCurrentId ~= nil and cp.id ~= previousCurrentId)
		local eventContext = nil
		if shouldRecordLifecycleEvent then
			eventContext = MTH_PETS_CaptureContext()
			table.insert(row.events, {
				type = eventType,
				source = "refresh-current-pet",
				at = now,
				context = eventContext,
			})
		end

		if eventType == "pet-acquired" then
			local hasTameRecord = (row.tameRecorded == true)
				or (tonumber(row.tamedAt) and tonumber(row.tamedAt) > 0)
				or (type(row.tameZone) == "string" and row.tameZone ~= "")
			if not hasTameRecord and type(eventContext) == "table" then
				row.tameRecorded = true
				row.tamedAt = row.tamedAt or eventContext.timestamp or now
				row.tameHunterLevel = row.tameHunterLevel or eventContext.hunterLevel
				row.tameZone = row.tameZone or eventContext.zone
				row.tameSubZone = row.tameSubZone or eventContext.subZone
				row.tameX = row.tameX or eventContext.x
				row.tameY = row.tameY or eventContext.y
				if tonumber(row.tameBeastId) == nil then
					local resolvedTameBeastId = MTH_PETS_ResolveTameBeastIdForRow(row, snapshot)
					if resolvedTameBeastId and resolvedTameBeastId > 0 then
						row.tameBeastId = resolvedTameBeastId
					end
				end
			end
		end
	end

	if hadPendingTame and cp.id and cp.id ~= previousCurrentId then
		MTH_PETS_LogTame("RefreshCurrentPet acquire/change completed; clearing pending tame attempt")
		MTH_PETS_LastTameAttempt = nil
	end
	MTH_PETS_LogConsistency("RefreshCurrentPet live result current=" .. MTH_PETS_FormatCurrentConsistency(cp))
	MTH_ST_LastUnitPetHadPet = true
	pets.updatedAt = now
end

function MTH_GetPetsStore()
	return MTH_PETS_GetRootStore()
end

function MTH_GetCurrentPetSnapshot()
	local pets = MTH_PETS_GetRootStore()
	MTH_PETS_RefreshCurrentPet()
	return pets and pets.currentPet or nil
end

local function MTH_PETS_ApplyLivePetVitalsFast(source)
	local pets = type(MTH_PETS_GetRootStore) == "function" and MTH_PETS_GetRootStore() or nil
	if type(pets) ~= "table" then
		return false
	end
	MTH_PETS_EnsureCurrentPetSchema(pets)

	local cp = pets.currentPet
	if type(cp) ~= "table" or cp.id == nil then
		return false
	end
	if type(UnitExists) ~= "function" or not UnitExists("pet") then
		return false
	end

	local changed = false
	local function assignIfChanged(target, key, value)
		if type(target) ~= "table" then
			return
		end
		if not MTH_PETS_IsSameLiveStateField(target[key], value) then
			target[key] = value
			changed = true
		end
	end

	local happiness = nil
	local loyalty = nil
	if type(GetPetHappiness) == "function" then
		local h, _, l = GetPetHappiness()
		happiness = h
		loyalty = l
	end

	local loyaltyLevel = nil
	local getPetLoyalty = (type(getglobal) == "function" and getglobal("GetPetLoyalty")) or (_G and _G["GetPetLoyalty"])
	if type(getPetLoyalty) == "function" then
		local level = getPetLoyalty()
		loyaltyLevel = tonumber(level) or nil
	end

	local xp = nil
	local xpMax = nil
	local xpPercent = nil
	local getPetExperience = (type(getglobal) == "function" and getglobal("GetPetExperience")) or (_G and _G["GetPetExperience"])
	if type(getPetExperience) == "function" then
		local x, xMax = getPetExperience()
		xp = tonumber(x)
		xpMax = tonumber(xMax)
		if xp and xpMax and xpMax > 0 then
			xpPercent = math.floor((xp / xpMax) * 1000 + 0.5) / 10
		end
	end

	assignIfChanged(cp, "happiness", happiness)
	assignIfChanged(cp, "loyalty", loyalty)
	if loyaltyLevel ~= nil then
		assignIfChanged(cp, "loyaltyLevel", loyaltyLevel)
	end
	assignIfChanged(cp, "xp", xp)
	assignIfChanged(cp, "xpMax", xpMax)
	assignIfChanged(cp, "xpPercent", xpPercent)

	local activeRow = nil
	if type(pets.petStore) == "table" and type(pets.petStore.activeById) == "table" then
		activeRow = pets.petStore.activeById[cp.id] or pets.petStore.activeById[tostring(cp.id)]
	end
	if type(activeRow) == "table" then
		assignIfChanged(activeRow, "happiness", happiness)
		assignIfChanged(activeRow, "loyalty", loyalty)
		if loyaltyLevel ~= nil then
			assignIfChanged(activeRow, "loyaltyLevel", loyaltyLevel)
		end
		assignIfChanged(activeRow, "xp", xp)
		assignIfChanged(activeRow, "xpMax", xpMax)
		assignIfChanged(activeRow, "xpPercent", xpPercent)
		if changed then
			activeRow.lastUpdated = time()
		end
	end

	if changed then
		cp.lastUpdated = time()
		cp.lastSource = source or "live-vitals"
		pets.updatedAt = cp.lastUpdated
	end

	return changed
end

function MTH_GetCurrentPetInfo(skipRefresh)
	local pets = MTH_PETS_GetRootStore()
	if not skipRefresh then
		MTH_PETS_RefreshCurrentPet()
	end
	local cp = pets and pets.currentPet or nil

	local info = {
		exists = false,
		liveExists = false,
		dead = false,
		suppressed = false,
		suppressedReason = "",
		id = nil,
		name = nil,
		family = nil,
		level = nil,
		happiness = nil,
		loyalty = nil,
		loyaltyLevel = nil,
		loyaltyText = nil,
		loyaltyDisplay = nil,
		xp = nil,
		xpMax = nil,
		xpPercent = nil,
		lastSource = nil,
		lastUpdated = nil,
		acquiredAt = nil,
		tamedAt = nil,
		stabledAt = nil,
		stableFirstSeenAt = nil,
		lastUnstabledAt = nil,
		withMeSinceAt = nil,
	}

	if type(cp) == "table" then
		info.id = cp.id or pets.currentPetId
		info.name = cp.name
		info.family = cp.family
		info.level = cp.level
		info.happiness = cp.happiness
		info.loyalty = cp.loyalty
		info.loyaltyLevel = tonumber(cp.loyaltyLevel) or nil
		info.lastSource = cp.lastSource
		info.lastUpdated = cp.lastUpdated
		info.acquiredAt = tonumber(cp.acquiredAt) or nil
		info.exists = info.id ~= nil and tostring(info.id) ~= ""
	end

	local activeRow = nil
	if type(pets) == "table" and type(pets.petStore) == "table" and type(pets.petStore.activeById) == "table" and info.id ~= nil then
		activeRow = pets.petStore.activeById[info.id] or pets.petStore.activeById[tostring(info.id)]
	end
	if type(activeRow) == "table" then
		info.tamedAt = tonumber(activeRow.tamedAt) or nil
		info.stabledAt = tonumber(activeRow.stabledAt) or nil
		info.stableFirstSeenAt = tonumber(activeRow.stableFirstSeenAt) or nil
		info.lastUnstabledAt = tonumber(activeRow.lastUnstabledAt) or nil
		if info.acquiredAt == nil then
			info.acquiredAt = tonumber(activeRow.createdAt) or tonumber(activeRow.lastSeen) or tonumber(activeRow.lastUpdated) or nil
		end
		if info.loyaltyLevel == nil then
			info.loyaltyLevel = tonumber(activeRow.loyaltyLevel) or nil
		end
	end

	info.withMeSinceAt = info.lastUnstabledAt or info.stabledAt or info.stableFirstSeenAt or info.tamedAt or nil

	info.suppressed = (pets and pets.currentPetSuppressed) and true or false
	info.suppressedReason = tostring((pets and pets.currentPetSuppressedReason) or "")

	local hasLivePet = (type(UnitExists) == "function") and UnitExists("pet") and true or false
	info.liveExists = hasLivePet

	if hasLivePet then
		if type(UnitName) == "function" then
			local liveName = UnitName("pet")
			if liveName and tostring(liveName) ~= "" then
				info.name = liveName
			end
		end
		if type(UnitLevel) == "function" then
			local liveLevel = tonumber(UnitLevel("pet"))
			if liveLevel and liveLevel > 0 then
				info.level = liveLevel
			end
		end
		if type(UnitIsDead) == "function" then
			info.dead = UnitIsDead("pet") and true or false
		end
		if type(GetPetHappiness) == "function" then
			local h, _, l = GetPetHappiness()
			if h ~= nil then
				info.happiness = h
			end
			if l ~= nil then
				info.loyalty = l
			end
		end
		local getPetLoyalty = (type(getglobal) == "function" and getglobal("GetPetLoyalty")) or (_G and _G["GetPetLoyalty"])
		if type(getPetLoyalty) == "function" then
			local loyaltyLevel, loyaltyText = getPetLoyalty()
			if loyaltyLevel ~= nil then
				info.loyaltyLevel = tonumber(loyaltyLevel) or info.loyaltyLevel
			end
			if loyaltyText ~= nil and tostring(loyaltyText) ~= "" then
				local loyaltyTextValue = tostring(loyaltyText)
				local parsedFromText = MTH_PETS_ParseLoyaltyLevelFromText(loyaltyTextValue)
				if info.loyaltyLevel == nil and parsedFromText ~= nil then
					info.loyaltyLevel = parsedFromText
				end
			end
		end
		local petFrameHappiness = (_G and _G["PetFrameHappiness"]) or (type(getglobal) == "function" and getglobal("PetFrameHappiness"))
		if type(petFrameHappiness) == "table" and type(petFrameHappiness.tooltipLoyalty) == "string" and petFrameHappiness.tooltipLoyalty ~= "" then
			local tooltipText = tostring(petFrameHappiness.tooltipLoyalty)
			local parsedFromTooltip = MTH_PETS_ParseLoyaltyLevelFromText(tooltipText)
			if info.loyaltyLevel == nil and parsedFromTooltip ~= nil then
				info.loyaltyLevel = parsedFromTooltip
			end
		end
		local petLoyaltyText = (_G and _G["PetLoyaltyText"]) or (type(getglobal) == "function" and getglobal("PetLoyaltyText"))
		if type(petLoyaltyText) == "table" and type(petLoyaltyText.GetText) == "function" then
			local uiLoyaltyText = MTH_PETS_NormalizeText(petLoyaltyText:GetText())
			if uiLoyaltyText ~= "" then
				local parsedFromUi = MTH_PETS_ParseLoyaltyLevelFromText(uiLoyaltyText)
				if info.loyaltyLevel == nil and parsedFromUi ~= nil then
					info.loyaltyLevel = parsedFromUi
				end
			end
		end
		local getPetExperience = (type(getglobal) == "function" and getglobal("GetPetExperience")) or (_G and _G["GetPetExperience"])
		if type(getPetExperience) == "function" then
			local xp, xpMax = getPetExperience()
			xp = tonumber(xp)
			xpMax = tonumber(xpMax)
			if xp then
				info.xp = xp
			end
			if xpMax and xpMax > 0 then
				info.xpMax = xpMax
				if xp then
					info.xpPercent = math.floor((xp / xpMax) * 1000 + 0.5) / 10
				end
			end
		end
		if type(UnitHealth) == "function" then
			info.health = tonumber(UnitHealth("pet")) or nil
		end
		if type(UnitHealthMax) == "function" then
			info.healthMax = tonumber(UnitHealthMax("pet")) or nil
		end
	end

	if info.loyaltyLevel ~= nil then
		info.loyaltyText = MTH_PETS_GetLoyaltyNameByLevel(info.loyaltyLevel)
		info.loyaltyDisplay = MTH_PETS_FormatLoyaltyDisplay(info.loyaltyLevel)
	else
		info.loyaltyText = nil
		info.loyaltyDisplay = nil
	end

	if info.liveExists and info.id and type(cp) == "table" then
		local changed = false
		local function assignIfChanged(target, key, value)
			if type(target) ~= "table" then
				return
			end
			if not MTH_PETS_IsSameLiveStateField(target[key], value) then
				target[key] = value
				changed = true
			end
		end

		assignIfChanged(cp, "happiness", info.happiness)
		assignIfChanged(cp, "loyalty", info.loyalty)
		if info.loyaltyLevel ~= nil then
			assignIfChanged(cp, "loyaltyLevel", info.loyaltyLevel)
		end
		assignIfChanged(cp, "xp", info.xp)
		assignIfChanged(cp, "xpMax", info.xpMax)
		assignIfChanged(cp, "xpPercent", info.xpPercent)

		if type(activeRow) == "table" then
			assignIfChanged(activeRow, "happiness", info.happiness)
			assignIfChanged(activeRow, "loyalty", info.loyalty)
			if info.loyaltyLevel ~= nil then
				assignIfChanged(activeRow, "loyaltyLevel", info.loyaltyLevel)
			end
			assignIfChanged(activeRow, "xp", info.xp)
			assignIfChanged(activeRow, "xpMax", info.xpMax)
			assignIfChanged(activeRow, "xpPercent", info.xpPercent)
			if changed then
				activeRow.lastUpdated = time()
			end
		end

		if changed then
			cp.lastUpdated = time()
			pets.updatedAt = cp.lastUpdated
		end
	end

	return info
end

function MTH_GetPetDatastoreSnapshot()
	local pets = MTH_PETS_GetRootStore()
	if type(pets) ~= "table" or type(pets.petStore) ~= "table" then
		return nil
	end
	return pets.petStore
end

function MTH_GetPetHistorySnapshot()
	local store = MTH_GetPetDatastoreSnapshot()
	if type(store) ~= "table" then
		return nil
	end
	return store.historyById
end

local function MTH_ST_GetStore()
	local pets = MTH_PETS_GetRootStore()
	if type(pets.stableScan) ~= "table" then
		pets.stableScan = {
			lastScan = 0,
			lastEvent = "",
			slotCount = 0,
			slots = {},
		}
	end
	if type(pets.stableScan.slots) ~= "table" then
		pets.stableScan.slots = {}
	end
	MTH_CharSavedVariables.stableScan = pets.stableScan
	return pets.stableScan
end

function MTH_ST_Scan(reason)
	local startedAt = MTH_ST_ProfileNow()
	MTH_ST_PrintStableDiag("scan begin reason=" .. tostring(reason or ""))
	local slotDiagParts = {}
	if UnitClass then
		local _, classToken = UnitClass("player")
		if classToken ~= "HUNTER" then
			MTH_ST_TraceRecord("MTH_ST_Scan", "scan", "class-gate:" .. tostring(classToken or "unknown"))
			MTH_ST_PrintStableDiag("scan skip reason=class-gate class=" .. tostring(classToken or "unknown"))
			return false
		end
	end

	if type(GetNumStableSlots) ~= "function" or type(GetStablePetInfo) ~= "function" then
		MTH_ST_Log("scan skipped: stable APIs unavailable")
		MTH_ST_TraceRecord("MTH_ST_Scan", "scan", "api-unavailable")
		MTH_ST_PrintStableDiag("scan skip reason=api-unavailable")
		return false
	end

	local slotCount = tonumber(GetNumStableSlots()) or 0
	MTH_ST_PrintStableDiag("scan api-ok slots=" .. tostring(slotCount))
	MTH_ST_TraceRecord("MTH_ST_Scan", "scan", "begin reason=" .. tostring(reason or "") .. " slots=" .. tostring(slotCount))
	local store = MTH_ST_GetStore()
	local petsRoot = MTH_PETS_GetRootStore()
	MTH_PETS_RefreshCurrentPet()
	local scanContext = MTH_PETS_CaptureContext()
	local scanStableMasterName = MTH_PETS_GetStableMasterName()
	store.lastScan = time()
	store.lastEvent = tostring(reason or "manual")
	store.slotCount = slotCount
	store.zone = scanContext and scanContext.zone or store.zone
	store.subZone = scanContext and scanContext.subZone or store.subZone
	if scanStableMasterName and scanStableMasterName ~= "" then
		store.stableMasterName = scanStableMasterName
	end
	store.slots = {}

	for slot = 1, slotCount do
		local r1, r2, r3, r4, r5, r6, r7, r8 = GetStablePetInfo(slot)
		local slotName = tostring(r2 or "-")
		local slotLevel = tostring(tonumber(r3) or "-")
		local slotFamily = tostring(r4 or "-")
		table.insert(slotDiagParts, "s" .. tostring(slot) .. "=" .. slotName .. "(lvl=" .. slotLevel .. ",fam=" .. slotFamily .. ")")
		MTH_PETS_RecordStableSlot(petsRoot, slot, r1, r2, r3, r4, r5, r6, r7, r8, scanContext, scanStableMasterName or store.stableMasterName)
		local petId = nil
		if type(petsRoot) == "table" and type(petsRoot.petStore) == "table" and type(petsRoot.petStore.stableSlotIndex) == "table" then
			petId = petsRoot.petStore.stableSlotIndex[slot]
		end
		store.slots[slot] = {
			petId = petId,
			icon = r1,
			name = r2,
			level = r3,
			family = r4,
			loyalty = r5,
			raw = { r1, r2, r3, r4, r5, r6, r7, r8 },
			r1, r2, r3, r4, r5, r6, r7, r8,
		}
	end

	local c1, c2, c3, c4, c5, c6, c7, c8 = GetStablePetInfo(0)
	local currentPetId = (type(petsRoot) == "table" and type(petsRoot.currentPet) == "table") and petsRoot.currentPet.id or nil
	if currentPetId and type(petsRoot.petStore) == "table" and type(petsRoot.petStore.activeById) == "table" then
		local currentRow = petsRoot.petStore.activeById[currentPetId]
		if type(currentRow) == "table" then
			local currentIcon = tostring(c1 or "")
			if currentIcon ~= "" then
				currentRow.icon = currentIcon
				currentRow.lastUpdated = time()
			end
		end
	end
	store.current = {
		petId = currentPetId,
		icon = c1,
		name = c2,
		level = c3,
		family = c4,
		loyalty = c5,
		raw = { c1, c2, c3, c4, c5, c6, c7, c8 },
	}
	MTH_ST_PrintStableDiag("scan current name=" .. tostring(c2 or "-")
		.. " lvl=" .. tostring(tonumber(c3) or "-")
		.. " fam=" .. tostring(c4 or "-")
		.. " petId=" .. tostring(currentPetId or "-"))
	if table.getn(slotDiagParts) > 0 then
		MTH_ST_PrintStableDiag("scan slots " .. table.concat(slotDiagParts, " | "))
	end

	MTH_PETS_MarkStableVisited(petsRoot, tostring(reason or "stable-scan"))

	MTH_PETS_RefreshCurrentPet()

	local elapsedMs = nil
	local finishedAt = MTH_ST_ProfileNow()
	if startedAt and finishedAt then
		elapsedMs = (finishedAt - startedAt) * 1000
	end
	if elapsedMs then
		MTH_ST_TraceRecord("MTH_ST_Scan", "scan", "done reason=" .. tostring(reason or "")
			.. " slots=" .. tostring(slotCount)
			.. " elapsedMs=" .. string.format("%.2f", elapsedMs))
		MTH_ST_PrintStableDiag("scan done ok=true slots=" .. tostring(slotCount) .. " elapsedMs=" .. string.format("%.2f", elapsedMs))
	else
		MTH_ST_TraceRecord("MTH_ST_Scan", "scan", "done reason=" .. tostring(reason or "")
			.. " slots=" .. tostring(slotCount))
		MTH_ST_PrintStableDiag("scan done ok=true slots=" .. tostring(slotCount))
	end

	MTH_PETS_EmitLiveState("STABLE_SCAN:" .. tostring(reason or "stable"), false)

	return true
end

function MTH_GetStableScanSnapshot()
	local pets = MTH_PETS_GetRootStore()
	if not pets then
		return nil
	end
	if type(pets.stableScan) ~= "table" then
		return nil
	end
	MTH_CharSavedVariables.stableScan = pets.stableScan
	return pets.stableScan
end

function MTH_RunStableScan(reason)
	if type(MTH_ST_Scan) ~= "function" then
		return false
	end
	return MTH_ST_Scan(reason or "external") and true or false
end

local function MTH_ST_RunScanThrottled(reason, minIntervalSeconds)
	local now = tonumber(time()) or 0
	local minInterval = tonumber(minIntervalSeconds) or 0
	if minInterval > 0 and (now - (MTH_ST_LastAutoScanAt or 0)) < minInterval then
		MTH_ST_PrintStableDiag("scan throttled reason=" .. tostring(reason or "")
			.. " min=" .. tostring(minInterval)
			.. " age=" .. tostring(now - (MTH_ST_LastAutoScanAt or 0)))
		MTH_ST_TraceRecord("MTH_ST_RunScanThrottled", "scan", "throttled reason=" .. tostring(reason or "")
			.. " min=" .. tostring(minInterval)
			.. " age=" .. tostring(now - (MTH_ST_LastAutoScanAt or 0)))
		return false
	end
	MTH_ST_LastAutoScanAt = now
	MTH_ST_PrintStableDiag("scan trigger reason=" .. tostring(reason or "") .. " min=" .. tostring(minInterval))
	MTH_ST_TraceRecord("MTH_ST_RunScanThrottled", "scan", "trigger reason=" .. tostring(reason or "")
		.. " min=" .. tostring(minInterval))
	return MTH_ST_Scan(reason)
end

local function MTH_ST_QueueDeferredStableScan(reason, delaySeconds)
	if not MTH_ST_DeferredStableScanFrame then
		MTH_ST_DeferredStableScanFrame = CreateFrame("Frame", "MTHDeferredStableScanFrame")
		if not MTH_ST_DeferredStableScanFrame then
			MTH_ST_TraceRecord("MTH_ST_QueueDeferredStableScan", "scan", "frame-create-failed")
			return false
		end
	end

	local frame = MTH_ST_DeferredStableScanFrame
	frame._reason = tostring(reason or "deferred")
	frame._elapsed = 0
	frame._delay = tonumber(delaySeconds) or 0.30
	MTH_ST_PrintStableDiag("deferred queue reason=" .. tostring(frame._reason) .. " delay=" .. tostring(frame._delay))
	frame:SetScript("OnUpdate", function()
		this._elapsed = (this._elapsed or 0) + (arg1 or 0)
		if this._elapsed < (this._delay or 0.30) then
			return
		end
		this:SetScript("OnUpdate", nil)
		MTH_ST_PrintStableDiag("deferred execute reason=" .. tostring(this._reason or "deferred"))
		MTH_ST_TraceRecord("MTH_ST_QueueDeferredStableScan", "scan", "execute reason=" .. tostring(this._reason or "deferred"))
		MTH_ST_RunScanThrottled("deferred:" .. tostring(this._reason or "stable"), 1)
	end)
	MTH_ST_TraceRecord("MTH_ST_QueueDeferredStableScan", "scan", "queued reason=" .. tostring(frame._reason)
		.. " delay=" .. tostring(frame._delay))
	return true
end

local function MTH_PETS_HandleUnitPetTransition(source)
	local pets = MTH_PETS_GetRootStore()
	if type(pets) ~= "table" then
		return
	end
	MTH_PETS_EnsureCurrentPetSchema(pets)

	local hadPet = MTH_ST_LastUnitPetHadPet and true or false
	local previousCurrentId = (type(pets.currentPet) == "table") and pets.currentPet.id or nil
	local snapshot = MTH_PETS_MakeSnapshotFromLivePet()
	if pets.currentPetSuppressed == true and pets.currentPetSuppressedAwaitNoLive == true then
		if type(snapshot) == "table" then
			snapshot = nil
		else
			pets.currentPetSuppressedAwaitNoLive = false
		end
	end
	local hasPet = snapshot and true or false
	local pending = MTH_PETS_LastTameAttempt
	local pendingTarget = (type(pending) == "table" and type(pending.target) == "table") and pending.target or nil
	local hasPendingTame = type(pendingTarget) == "table"
	if hasPendingTame then
		MTH_PETS_LogTame("UNIT_PET source=" .. tostring(source)
			.. " hadPet=" .. tostring(hadPet)
			.. " hasLiveSnapshot=" .. tostring(type(snapshot) == "table")
			.. " pendingTarget='" .. tostring((pendingTarget and pendingTarget["name"]) or "")
			.. "' pendingBeastId='" .. tostring((pendingTarget and pendingTarget["beastId"]) or "") .. "'")
	end
	MTH_PETS_LogConsistency("HandleUnitPetTransition source=" .. tostring(source)
		.. " previousCurrentId=" .. tostring(previousCurrentId)
		.. " hadPet=" .. tostring(hadPet)
		.. " hasLiveSnapshot=" .. tostring(type(snapshot) == "table"))

	if type(snapshot) == "table" then
		local transitionSource = "unit-pet-refresh"
		if not hadPet then
			transitionSource = "unit-pet-acquire"
		end
		if not hadPet and snapshot.beastId == nil then
			snapshot.beastId = MTH_PETS_GetPendingTameBeastId(snapshot)
			MTH_PETS_LogTame("UNIT_PET acquire beastId resolved to " .. tostring(snapshot.beastId or "nil"))
		end

		local petId, created = MTH_PETS_UpsertActivePetFromSnapshot(pets, snapshot, transitionSource, nil)
		MTH_PETS_SetCurrentPetSuppressed(pets, false)
		local cp = pets.currentPet
		cp.exists = true
		cp.id = petId
		cp.guid = snapshot.guid
		cp.signature = snapshot.signature
		cp.beastId = snapshot.beastId
		cp.name = snapshot.name
		cp.family = snapshot.family
		cp.level = snapshot.level
		cp.happiness = snapshot.happiness
		cp.loyalty = snapshot.loyalty
		cp.loyaltyLevel = snapshot.loyaltyLevel
		cp.xp = snapshot.xp
		cp.xpMax = snapshot.xpMax
		cp.xpPercent = snapshot.xpPercent
		cp.lastUpdated = time()
		cp.lastSeen = time()
		cp.lastSource = source or transitionSource
		if not hadPet or created then
			cp.acquiredAt = time()
		end
		if cp.id and cp.id ~= previousCurrentId then
			MTH_PETS_RequestPetSpellScan("unit-pet-current-change")
		end

		local row = MTH_PETS_GetPetById(pets, petId)
		if type(row) == "table" then
			if type(row.events) ~= "table" then
				row.events = {}
			end
			local eventType = (not hadPet) and "pet-acquired" or "pet-updated"
			if eventType == "pet-updated" and source == "UNIT_PET" and MTH_ST_IsStableFrameOpen() then
				MTH_ST_PrintStableDiag("swap history-skip reason=stable-open")
			else
				table.insert(row.events, {
					type = eventType,
					source = source or transitionSource,
					at = time(),
					context = MTH_PETS_CaptureContext(),
				})
			end
		end
		if not hadPet and hasPendingTame then
			MTH_PETS_LogTame("Acquire completed; clearing pending tame attempt")
			MTH_PETS_LastTameAttempt = nil
		end
	else
		local cp = pets.currentPet
		cp.exists = false
		local keepCurrentId, keepCurrentRow = MTH_PETS_ResolveNoLiveCurrentRow(pets, previousCurrentId)
		if keepCurrentId ~= nil and type(keepCurrentRow) == "table" then
			MTH_PETS_ApplyCurrentPetFromActiveRow(cp, keepCurrentId, keepCurrentRow)
		else
			cp.id = nil
			cp.guid = nil
			cp.signature = nil
			cp.beastId = nil
			cp.name = nil
			cp.family = nil
			cp.level = nil
			cp.happiness = nil
			cp.loyalty = nil
			cp.loyaltyLevel = nil
			cp.xp = nil
			cp.xpMax = nil
			cp.xpPercent = nil
		end
		cp.lastUpdated = time()
		cp.lastSource = source or "unit-pet-none"
		MTH_PETS_SetCurrentPetId(pets, keepCurrentId)
		MTH_PETS_LogConsistency("HandleUnitPetTransition no-live result current=" .. MTH_PETS_FormatCurrentConsistency(cp)
			.. " activeCurrentId=" .. tostring(type(pets.petStore) == "table" and pets.petStore.activeCurrentId or nil))
		if hasPendingTame then
			MTH_PETS_LogTame("UNIT_PET no-live while tame pending; keeping pending attempt")
		end
	end

	MTH_ST_LastUnitPetHadPet = hasPet
	pets.updatedAt = time()
end

function MTH_GetStablePetNames()
	MTH_PETS_RefreshCurrentPet()
	local names = {}
	local seen = {}
	local snapshot = MTH_GetStableScanSnapshot()

	if snapshot and type(snapshot.slots) == "table" then
		for _, row in pairs(snapshot.slots) do
			local petName = nil
			if type(row) == "table" then
				petName = row.name or row[2]
			end
			if petName and petName ~= "" and not seen[petName] then
				seen[petName] = true
				table.insert(names, petName)
			end
		end
	end

	if type(UnitName) == "function" then
		local activePetName = UnitName("pet")
		if activePetName and activePetName ~= "" and not seen[activePetName] then
			seen[activePetName] = true
			table.insert(names, activePetName)
		end
	end

	return names
end

local function MTH_ST_CountStableSlots(snapshot)
	if type(snapshot) ~= "table" then
		return 0
	end
	local count = tonumber(snapshot.slotCount) or 0
	if count > 0 then
		return count
	end
	if type(snapshot.slots) ~= "table" then
		return 0
	end
	for _ in pairs(snapshot.slots) do
		count = count + 1
	end
	return count
end

local function MTH_ST_DebugDumpLine(line)
	if MTH and MTH.Print then
		MTH:Print(tostring(line or ""), "debug")
	end
end

local MTH_PETS_DebugBaselineSnapshot = nil

local function MTH_ST_DebugCloneValue(value, seen)
	if type(value) ~= "table" then
		return value
	end
	seen = seen or {}
	if seen[value] then
		return seen[value]
	end
	local clone = {}
	seen[value] = clone
	for key, child in pairs(value) do
		clone[MTH_ST_DebugCloneValue(key, seen)] = MTH_ST_DebugCloneValue(child, seen)
	end
	return clone
end

local function MTH_PETS_CaptureDebugSnapshot(targetPetId)
	local pets = MTH_PETS_GetRootStore()
	if type(pets) ~= "table" then
		return nil, "pets datastore unavailable"
	end

	MTH_PETS_RefreshCurrentPet()

	local cp = (type(pets.currentPet) == "table") and pets.currentPet or nil
	local petId = targetPetId or (cp and cp.id) or pets.currentPetId
	if petId == nil or tostring(petId) == "" then
		return nil, "no current pet id"
	end

	local row = MTH_PETS_GetPetById(pets, petId)
	if type(row) ~= "table" then
		return nil, "active row missing for pet id=" .. tostring(petId)
	end

	local snapshot = {
		capturedAt = time(),
		petId = tostring(petId),
		currentPetId = pets.currentPetId,
		currentPet = MTH_ST_DebugCloneValue(cp or {}),
		row = MTH_ST_DebugCloneValue(row),
		stableScan = MTH_ST_DebugCloneValue(pets.stableScan or {}),
	}
	return snapshot, nil
end

local function MTH_ST_DebugSortKeys(tbl)
	local keys = {}
	for k in pairs(tbl or {}) do
		table.insert(keys, k)
	end
	table.sort(keys, function(a, b)
		return tostring(a) < tostring(b)
	end)
	return keys
end

local function MTH_ST_DebugDumpValue(prefix, value, depth, maxDepth, seen)
	depth = tonumber(depth) or 0
	maxDepth = tonumber(maxDepth) or 4
	seen = seen or {}

	if type(value) ~= "table" then
		MTH_ST_DebugDumpLine(prefix .. " = " .. tostring(value))
		return
	end

	if seen[value] then
		MTH_ST_DebugDumpLine(prefix .. " = <cycle>")
		return
	end
	seen[value] = true

	if depth >= maxDepth then
		MTH_ST_DebugDumpLine(prefix .. " = <max-depth>")
		return
	end

	local keys = MTH_ST_DebugSortKeys(value)
	if table.getn(keys) == 0 then
		MTH_ST_DebugDumpLine(prefix .. " = {}")
		return
	end

	for i = 1, table.getn(keys) do
		local key = keys[i]
		local child = value[key]
		local childPrefix = prefix .. "." .. tostring(key)
		if type(child) == "table" then
			MTH_ST_DebugDumpLine(childPrefix .. " = {")
			MTH_ST_DebugDumpValue(childPrefix, child, depth + 1, maxDepth, seen)
			MTH_ST_DebugDumpLine(childPrefix .. " = }")
		else
			MTH_ST_DebugDumpLine(childPrefix .. " = " .. tostring(child))
		end
	end
end

function MTH_CommandPetsState()
	local pets = MTH_PETS_GetRootStore()
	MTH_PETS_RefreshCurrentPet()

	local currentPet = pets and pets.currentPet or nil
	local stableScan = pets and pets.stableScan or nil
	local petTraining = pets and (pets.trainScan or pets.petTraining) or nil
	local petStore = pets and pets.petStore or nil
	local activeCount = 0
	local historyCount = 0
	if type(petStore) == "table" and type(petStore.activeById) == "table" then
		for _ in pairs(petStore.activeById) do activeCount = activeCount + 1 end
	end
	if type(petStore) == "table" and type(petStore.historyById) == "table" then
		for _ in pairs(petStore.historyById) do historyCount = historyCount + 1 end
	end

	local currentPetText = "none"
	if type(currentPet) == "table" and currentPet.exists then
		local petName = tostring(currentPet.name or "")
		local petLevel = tonumber(currentPet.level) or 0
		if petName ~= "" then
			if petLevel > 0 then
				currentPetText = petName .. " (" .. tostring(petLevel) .. ")"
			else
				currentPetText = petName
			end
		end
	end

	local summary = "MTH_Pets: schemaVersion=" .. tostring(pets and pets.schemaVersion or 0)
		.. " currentPet=" .. currentPetText
		.. " activePets=" .. tostring(activeCount)
		.. " petHistory=" .. tostring(historyCount)
		.. " stableSlots=" .. tostring(MTH_ST_CountStableSlots(stableScan))
		.. " stableLastScan=" .. tostring(stableScan and stableScan.lastScan or 0)
		.. " petTrainingLastScan=" .. tostring(petTraining and petTraining.lastScan or 0)
		.. " hasCompletedPetScan=" .. tostring(petTraining and petTraining.hasCompletedPetScan or nil)
	MTH:Print(summary)
	MTH:Print("[PETSSTATE] " .. summary, "debug")
end

function MTH_CommandPetsReset()
	local pets = MTH_PETS_GetRootStore()
	if type(pets) ~= "table" then
		MTH:Print("Pets reset failed: datastore unavailable.")
		return false
	end

	MTH_PETS_EnsureSchema(pets)
	local store = MTH_PETS_GetStoreTables(pets)
	if type(store) ~= "table" then
		MTH:Print("Pets reset failed: petStore unavailable.")
		return false
	end

	local activeCount = 0
	if type(store.activeById) == "table" then
		for _ in pairs(store.activeById) do
			activeCount = activeCount + 1
		end
	end

	local historyCount = 0
	if type(store.historyById) == "table" then
		for _ in pairs(store.historyById) do
			historyCount = historyCount + 1
		end
	else
		store.historyById = {}
	end

	store.activeById = {}
	store.signatureIndex = {}
	store.guidIndex = {}
	store.stableSlotIndex = {}
	store.activeCurrentId = nil
	pets.currentPetId = nil
	pets.currentPetSuppressed = false
	pets.currentPetSuppressedReason = ""
	store.nextId = 1

	MTH_PETS_EnsureCurrentPetSchema(pets)
	local cp = pets.currentPet
	cp.exists = false
	cp.id = nil
	cp.guid = nil
	cp.signature = nil
	cp.beastId = nil
	cp.name = nil
	cp.family = nil
	cp.level = nil
	cp.happiness = nil
	cp.loyalty = nil
	cp.loyaltyLevel = nil
	cp.xp = nil
	cp.xpMax = nil
	cp.xpPercent = nil
	cp.acquiredAt = 0
	cp.lastSeen = time()
	cp.lastUpdated = time()
	cp.lastSource = "pets-reset"

	if type(pets.stableScan) ~= "table" then
		pets.stableScan = {}
	end
	pets.stableScan.lastScan = 0
	pets.stableScan.lastEvent = "reset:/mth pets reset"
	pets.stableScan.slotCount = 0
	pets.stableScan.slots = {}

	MTH_ST_LastUnitPetHadPet = false
	pets.updatedAt = time()

	if type(MTH_CharSavedVariables) == "table" then
		MTH_CharSavedVariables.MTH_Pets = pets
		MTH_CharSavedVariables.petStore = pets.petStore
		MTH_CharSavedVariables.stableScan = pets.stableScan
	end

	local line = "Pets reset complete: clearedActive=" .. tostring(activeCount)
		.. " preservedHistory=" .. tostring(historyCount)
		.. " nextId=" .. tostring(store.nextId)
	MTH:Print(line)
	MTH:Print("[PETSRESET] " .. line, "debug")
	return true
end

function MTH_CommandPetsDump()
	local pets = MTH_PETS_GetRootStore()
	MTH_PETS_RefreshCurrentPet()

	if type(pets) ~= "table" or type(pets.currentPet) ~= "table" or not pets.currentPet.exists or not pets.currentPet.id then
		MTH:Print("Current pet dump: no active pet.")
		return
	end

	local cp = pets.currentPet
	local row = nil
	if type(pets.petStore) == "table" and type(pets.petStore.activeById) == "table" then
		row = pets.petStore.activeById[cp.id]
	end
	if type(row) ~= "table" then
		MTH:Print("Current pet dump: active row missing for id=" .. tostring(cp.id))
		return
	end

	MTH_ST_DebugDumpLine("[PETDUMP] BEGIN currentPet")
	MTH_ST_DebugDumpValue("[PETDUMP].currentPet", cp, 0, 3, {})
	MTH_ST_DebugDumpLine("[PETDUMP] END currentPet")

	MTH_ST_DebugDumpLine("[PETDUMP] BEGIN activeRow[" .. tostring(cp.id) .. "]")
	MTH_ST_DebugDumpValue("[PETDUMP].activeRow", row, 0, 5, {})
	MTH_ST_DebugDumpLine("[PETDUMP] END activeRow")

	local petStore = pets.petStore
	if type(petStore) == "table" and type(petStore.stableSlotIndex) == "table" then
		local slotKeys = MTH_ST_DebugSortKeys(petStore.stableSlotIndex)
		for i = 1, table.getn(slotKeys) do
			local slot = slotKeys[i]
			local petId = petStore.stableSlotIndex[slot]
			MTH_ST_DebugDumpLine("[PETDUMP] stableSlotIndex." .. tostring(slot) .. " = " .. tostring(petId))
			if petId and type(petStore.activeById) == "table" and type(petStore.activeById[petId]) == "table" then
				MTH_ST_DebugDumpLine("[PETDUMP] BEGIN stableRow slot=" .. tostring(slot) .. " id=" .. tostring(petId))
				MTH_ST_DebugDumpValue("[PETDUMP].stableRow[" .. tostring(slot) .. "]", petStore.activeById[petId], 0, 5, {})
				MTH_ST_DebugDumpLine("[PETDUMP] END stableRow slot=" .. tostring(slot))
			end
		end
	end

	if type(pets.stableScan) == "table" then
		MTH_ST_DebugDumpLine("[PETDUMP] BEGIN stableScan")
		MTH_ST_DebugDumpValue("[PETDUMP].stableScan", pets.stableScan, 0, 4, {})
		MTH_ST_DebugDumpLine("[PETDUMP] END stableScan")
	end
end

function MTH_CommandPetsSnap()
	local snapshot, err = MTH_PETS_CaptureDebugSnapshot(nil)
	if not snapshot then
		MTH:Print("Pet snapshot failed: " .. tostring(err or "unknown"))
		return false
	end
	MTH_PETS_DebugBaselineSnapshot = snapshot
	MTH:Print("Pet snapshot saved for id=" .. tostring(snapshot.petId) .. ". Run /mth petsdiff after reproducing the issue.")
	MTH_ST_DebugDumpLine("[PETSNAP] BASELINE BEGIN")
	MTH_ST_DebugDumpValue("[PETSNAP].baseline", snapshot, 0, 5, {})
	MTH_ST_DebugDumpLine("[PETSNAP] BASELINE END")
	return true
end

function MTH_CommandPetsDiff()
	if type(MTH_PETS_DebugBaselineSnapshot) ~= "table" then
		MTH:Print("No pet snapshot baseline found. Run /mth petssnap first.")
		return false
	end

	local baseline = MTH_PETS_DebugBaselineSnapshot
	local current, err = MTH_PETS_CaptureDebugSnapshot(baseline.petId)
	if not current then
		MTH:Print("Pet snapshot compare failed: " .. tostring(err or "unknown"))
		return false
	end

	MTH:Print("Pet snapshot compare for id=" .. tostring(current.petId) .. ".")
	MTH_ST_DebugDumpLine("[PETSNAP] BEFORE BEGIN")
	MTH_ST_DebugDumpValue("[PETSNAP].before", baseline, 0, 5, {})
	MTH_ST_DebugDumpLine("[PETSNAP] BEFORE END")
	MTH_ST_DebugDumpLine("[PETSNAP] AFTER BEGIN")
	MTH_ST_DebugDumpValue("[PETSNAP].after", current, 0, 5, {})
	MTH_ST_DebugDumpLine("[PETSNAP] AFTER END")

	local diffKeys = {
		"name", "family", "level", "beastId", "icon",
		"tameRecorded", "tamedAt", "tameZone", "tameSubZone", "tameX", "tameY", "tameBeastId",
		"stableSlot", "stabledAt", "stableFirstSeenAt", "lastUnstabledAt", "lastSource", "lastUpdated",
	}
	local diffCount = 0
	for i = 1, table.getn(diffKeys) do
		local key = diffKeys[i]
		local beforeValue = baseline.row and baseline.row[key] or nil
		local afterValue = current.row and current.row[key] or nil
		if tostring(beforeValue) ~= tostring(afterValue) then
			diffCount = diffCount + 1
			MTH_ST_DebugDumpLine("[PETSNAP] DIFF row." .. tostring(key) .. ": " .. tostring(beforeValue) .. " -> " .. tostring(afterValue))
		end
	end
	if diffCount <= 0 then
		MTH_ST_DebugDumpLine("[PETSNAP] DIFF none")
	end

	MTH_PETS_DebugBaselineSnapshot = current
	return true
end

function MTH_CommandStableScan()
	if UnitClass then
		local _, classToken = UnitClass("player")
		if classToken ~= "HUNTER" then
			MTH:Print("Stable scan is hunter-only.")
			return
		end
	end

	local ok = MTH_ST_Scan("manual:/mth stablescan")
	if not ok then
		MTH:Print("Stable scan failed or no stable data available.")
		return
	end

	local store = MTH_CharSavedVariables and MTH_CharSavedVariables.stableScan
	local slotCount = store and store.slotCount or 0
	MTH:Print("Stable scan captured " .. tostring(slotCount) .. " slot(s).")
end

function MTH_ST_HandlePlayerEnteringWorld(evt)
	if evt ~= "PLAYER_ENTERING_WORLD" then
		return false
	end
	local pets = MTH_PETS_GetRootStore()
	MTH_PETS_MaybePromptStableVisit(pets)
	MTH_PETS_EmitLiveState("PLAYER_ENTERING_WORLD", true)
	return true
end

function MTH_ST_HandleSpellcastEvent(evt, eventArg1, eventArg2)
	local isUnitSpellcast = (evt == "UNIT_SPELLCAST_START" or evt == "UNIT_SPELLCAST_STOP"
		or evt == "UNIT_SPELLCAST_FAILED" or evt == "UNIT_SPELLCAST_INTERRUPTED"
		or evt == "UNIT_SPELLCAST_CHANNEL_START" or evt == "UNIT_SPELLCAST_CHANNEL_STOP")
	local castSpellName = eventArg1
	local hasPendingTame = type(MTH_PETS_LastTameAttempt) == "table"
	if isUnitSpellcast then
		if eventArg1 ~= "player" then
			return true
		end
		castSpellName = eventArg2
	end

	if evt == "SPELLCAST_START" or evt == "SPELLCAST_CHANNEL_START"
		or evt == "UNIT_SPELLCAST_START" or evt == "UNIT_SPELLCAST_CHANNEL_START" then
		if not MTH_PETS_IsTameBeastSpellName(castSpellName) then
			return true
		end
		MTH_PETS_RecordTameAttempt(evt, castSpellName)
		return true
	end

	if evt == "SPELLCAST_STOP" or evt == "SPELLCAST_CHANNEL_STOP" or evt == "SPELLCAST_FAILED" or evt == "SPELLCAST_INTERRUPTED"
		or evt == "UNIT_SPELLCAST_STOP" or evt == "UNIT_SPELLCAST_CHANNEL_STOP"
		or evt == "UNIT_SPELLCAST_FAILED" or evt == "UNIT_SPELLCAST_INTERRUPTED" then
		local terminalIsTame = MTH_PETS_IsTameBeastSpellName(castSpellName)
		if not terminalIsTame and hasPendingTame then
			terminalIsTame = true
		end
		if not terminalIsTame then
			return true
		end
		if terminalIsTame then
			if evt == "SPELLCAST_FAILED" or evt == "SPELLCAST_INTERRUPTED" then
				MTH_PETS_LastTameAttempt = nil
			end
		end
		return true
	end

	return false
end

function MTH_ST_HandleUnitPetEvent(evt, eventArg1)
	if evt ~= "UNIT_PET" then
		return false
	end
	if eventArg1 ~= "player" then
		return true
	end

	local startedAt = MTH_ST_ProfileNow()
	local beforeId = nil
	local beforeName = nil
	local beforeFamily = nil
	local beforeLevel = nil
	local beforeExists = nil
	local petsBefore = type(MTH_PETS_GetRootStore) == "function" and MTH_PETS_GetRootStore() or nil
	if type(petsBefore) == "table" and type(petsBefore.currentPet) == "table" then
		beforeId = petsBefore.currentPet.id
		beforeName = petsBefore.currentPet.name
		beforeFamily = petsBefore.currentPet.family
		beforeLevel = petsBefore.currentPet.level
		beforeExists = petsBefore.currentPet.exists and true or false
	end
	MTH_ST_PrintStableDiag("swap UNIT_PET begin beforeId=" .. tostring(beforeId or "-") .. " beforeName=" .. tostring(beforeName or "-"))

	MTH_PETS_HandleUnitPetTransition("UNIT_PET")

	local afterId = nil
	local afterName = nil
	local afterFamily = nil
	local afterLevel = nil
	local afterExists = nil
	local petsAfter = type(MTH_PETS_GetRootStore) == "function" and MTH_PETS_GetRootStore() or nil
	if type(petsAfter) == "table" and type(petsAfter.currentPet) == "table" then
		afterId = petsAfter.currentPet.id
		afterName = petsAfter.currentPet.name
		afterFamily = petsAfter.currentPet.family
		afterLevel = petsAfter.currentPet.level
		afterExists = petsAfter.currentPet.exists and true or false
	end

	local sameCore = (tostring(beforeId or "") == tostring(afterId or ""))
		and (tostring(beforeName or "") == tostring(afterName or ""))
		and (tostring(beforeFamily or "") == tostring(afterFamily or ""))
		and (tonumber(beforeLevel) or -1) == (tonumber(afterLevel) or -1)
		and (beforeExists and true or false) == (afterExists and true or false)

	local emitSkipped = false
	local liveChanged = false
	if MTH_ST_IsStableFrameOpen() then
		emitSkipped = true
		MTH_ST_PrintStableDiag("swap UNIT_PET emit-skip reason=stable-open")
	elseif sameCore then
		emitSkipped = true
		MTH_ST_PrintStableDiag("swap UNIT_PET emit-skip reason=unchanged-core")
	else
		liveChanged = MTH_PETS_EmitLiveState("UNIT_PET", false, { skipRefresh = true }) and true or false
	end

	local elapsedMs = 0
	local finishedAt = MTH_ST_ProfileNow()
	if startedAt and finishedAt then
		elapsedMs = math.floor(math.max(0, (finishedAt - startedAt) * 1000) + 0.5)
	end
	MTH_ST_PrintStableDiag("swap UNIT_PET end afterId=" .. tostring(afterId or "-")
		.. " afterName=" .. tostring(afterName or "-")
		.. " sameCore=" .. tostring(sameCore)
		.. " emitSkipped=" .. tostring(emitSkipped)
		.. " liveChanged=" .. tostring(liveChanged)
		.. " elapsedMs=" .. tostring(elapsedMs))
	return true
end

local function MTH_ST_IsPlayerDeadOrGhost()
	if type(UnitIsDeadOrGhost) == "function" then
		return UnitIsDeadOrGhost("player") and true or false
	end
	if type(UnitIsDead) == "function" then
		return UnitIsDead("player") and true or false
	end
	return false
end

function MTH_ST_HandleVitalsEvent(evt, eventArg1)
	local playerDead = MTH_ST_IsPlayerDeadOrGhost()
	local hasLivePet = (type(UnitExists) == "function" and UnitExists("pet")) and true or false

	if evt == "PET_BAR_UPDATE" then
		if not hasLivePet then
			MTH_ST_TraceRecord(evt, "vitals", "pet_bar:no-pet")
			return true
		end
		local interval = playerDead and 1.75 or 0.5
		if not MTH_PETS_ShouldHandleThrottledEvent("PET_BAR_UPDATE", interval) then
			MTH_ST_TraceRecord(evt, "vitals", "pet_bar:throttled")
			return true
		end
		local changed = MTH_PETS_ApplyLivePetVitalsFast("PET_BAR_UPDATE")
		if changed then
			MTH_ST_TraceRecord(evt, "vitals", "pet_bar:changed")
			MTH_PETS_EmitLiveState("PET_BAR_UPDATE", false, { skipRefresh = true })
		else
			MTH_ST_TraceRecord(evt, "vitals", "pet_bar:no-change")
		end
		return true
	end

	if evt == "UNIT_HAPPINESS" then
		if not hasLivePet then
			MTH_ST_TraceRecord(evt, "vitals", "happiness:no-pet")
			return true
		end
		if eventArg1 and eventArg1 ~= "pet" then
			MTH_ST_TraceRecord(evt, "vitals", "happiness:not-pet-arg")
			return true
		end
		local interval = playerDead and 2.25 or 0.75
		if not MTH_PETS_ShouldHandleThrottledEvent("UNIT_HAPPINESS", interval) then
			MTH_ST_TraceRecord(evt, "vitals", "happiness:throttled")
			return true
		end
		local changed = MTH_PETS_ApplyLivePetVitalsFast("UNIT_HAPPINESS")
		if changed then
			MTH_ST_TraceRecord(evt, "vitals", "happiness:changed")
			MTH_PETS_EmitLiveState("UNIT_HAPPINESS", false, { skipRefresh = true })
		else
			MTH_ST_TraceRecord(evt, "vitals", "happiness:no-change")
		end
		return true
	end

	if evt == "CHAT_MSG_COMBAT_XP_GAIN" or evt == "PLAYER_XP_UPDATE" then
		if not hasLivePet then
			MTH_ST_TraceRecord(evt, "vitals", "xp:no-pet")
			return true
		end
		if playerDead then
			MTH_ST_TraceRecord(evt, "vitals", "xp:dead")
			return true
		end
		if not MTH_PETS_ShouldHandleThrottledEvent("XP_UPDATE", 1.5) then
			MTH_ST_TraceRecord(evt, "vitals", "xp:throttled")
			return true
		end
		local changed = MTH_PETS_ApplyLivePetVitalsFast(evt)
		if changed then
			MTH_ST_TraceRecord(evt, "vitals", "xp:changed")
			MTH_PETS_EmitLiveState(evt, false, { skipRefresh = true })
		else
			MTH_ST_TraceRecord(evt, "vitals", "xp:no-change")
		end
		return true
	end

	return false
end

function MTH_ST_HandleRunawayEvent(evt, eventArg1)
	if evt ~= "CHAT_MSG_SYSTEM" and evt ~= "UI_ERROR_MESSAGE"
		and evt ~= "CHAT_MSG_SPELL_PET_INFO" and evt ~= "CHAT_MSG_SPELL_PET_DAMAGE"
		and evt ~= "CHAT_MSG_COMBAT_PET_HITS" and evt ~= "CHAT_MSG_COMBAT_PET_MISSES" then
		return false
	end

	if type(UnitExists) == "function" and not UnitExists("pet") then
		if not MTH_PETS_ShouldHandleThrottledEvent("RUNAWAY_MSG_NO_PET", 2.0) then
			MTH_ST_TraceRecord(evt, "runaway", "no-pet:throttled")
			return true
		end
		MTH_ST_TraceRecord(evt, "runaway", "no-pet:parse")
	end

	if MTH_ST_IsPlayerDeadOrGhost() then
		if not MTH_PETS_ShouldHandleThrottledEvent("RUNAWAY_MSG_DEAD", 0.30) then
			MTH_ST_TraceRecord(evt, "runaway", "dead:throttled")
			return true
		end
	end

	local runawayStarted = MTH_ST_ProfileNow()
	local matchedRunaway = MTH_PETS_IsRunawaySystemMessage(eventArg1)
	if runawayStarted then
		local runawayNow = MTH_ST_ProfileNow()
		if runawayNow then
			MTH_ST_ProfileRecordRunaway((runawayNow - runawayStarted) * 1000)
		end
	end
	if matchedRunaway then
		MTH_ST_TraceRecord(evt, "runaway", "matched")
		MTH_PETS_RecordPetRunaway(evt, eventArg1)
		MTH_PETS_EmitLiveState(evt)
	else
		MTH_ST_TraceRecord(evt, "runaway", "not-matched")
	end
	return true
end

function MTH_ST_HandleStableUiEvent(evt)
	if evt == "PET_STABLE_SHOW" then
		MTH_ST_TraceRecord(evt, "stable-ui", "show")
		MTH_ST_TraceRecord(evt, "stable-ui", "show:no-scan")
		return true
	end

	if evt == "PET_STABLE_UPDATE" then
		MTH_ST_TraceRecord(evt, "stable-ui", "update")
		MTH_ST_TraceRecord(evt, "stable-ui", "update:no-scan")
		MTH_PETS_EmitLiveState(evt)
		return true
	end

	if evt == "PET_STABLE_CLOSED" then
		MTH_ST_TraceRecord(evt, "stable-ui", "closed")
		MTH_ST_QueueDeferredStableScan("PET_STABLE_CLOSED", 0.20)
		MTH_ST_TraceRecord(evt, "stable-ui", "closed:deferred-scan")
		MTH_PETS_EmitLiveState(evt)
		return true
	end

	return false
end

local function MTH_ST_DispatchEvent(_, evt, eventArg1, eventArg2)
	evt = evt or event
	eventArg1 = eventArg1 or arg1
	eventArg2 = eventArg2 or arg2
	if not evt then
		return
	end

	if type(MTH_ST_LifecycleService) == "table" and type(MTH_ST_LifecycleService.HandleEvent) == "function" then
		local lifecycleHandled, lifecycleNote = MTH_ST_LifecycleService:HandleEvent(evt, eventArg1, eventArg2)
		if lifecycleHandled then
			MTH_ST_TraceRecord(evt, "dispatch", lifecycleNote or "lifecycle-service")
			return
		end
	else
		if MTH_ST_HandlePlayerEnteringWorld(evt) then
			MTH_ST_TraceRecord(evt, "dispatch", "lifecycle-enter-world")
			return
		end
		if MTH_ST_HandleSpellcastEvent(evt, eventArg1, eventArg2) then
			MTH_ST_TraceRecord(evt, "dispatch", "lifecycle-spellcast")
			return
		end
		if MTH_ST_HandleUnitPetEvent(evt, eventArg1) then
			MTH_ST_TraceRecord(evt, "dispatch", "lifecycle-unit-pet")
			return
		end
	end

	if type(MTH_ST_VitalsService) == "table" and type(MTH_ST_VitalsService.HandleEvent) == "function" then
		if MTH_ST_VitalsService:HandleEvent(evt, eventArg1, eventArg2) then
			MTH_ST_TraceRecord(evt, "dispatch", "vitals-service")
			return
		end
	else
		if MTH_ST_HandleVitalsEvent(evt, eventArg1) then
			MTH_ST_TraceRecord(evt, "dispatch", "vitals")
			return
		end
	end

	if type(MTH_ST_RunawayService) == "table" and type(MTH_ST_RunawayService.HandleEvent) == "function" then
		if MTH_ST_RunawayService:HandleEvent(evt, eventArg1, eventArg2) then
			MTH_ST_TraceRecord(evt, "dispatch", "runaway-service")
			return
		end
	else
		if MTH_ST_HandleRunawayEvent(evt, eventArg1) then
			MTH_ST_TraceRecord(evt, "dispatch", "runaway")
			return
		end
	end

	if type(MTH_ST_StableScanService) == "table" and type(MTH_ST_StableScanService.HandleEvent) == "function" then
		if MTH_ST_StableScanService:HandleEvent(evt, eventArg1, eventArg2) then
			MTH_ST_TraceRecord(evt, "dispatch", "stable-service")
			return
		end
	else
		if MTH_ST_HandleStableUiEvent(evt) then
			MTH_ST_TraceRecord(evt, "dispatch", "stable-ui")
			return
		end
	end

	MTH_ST_TraceRecord(evt, "dispatch", "unhandled")
end

local function MTH_ST_OnEvent(frame, evt, eventArg1, eventArg2)
	local started = nil
	if MTH_ST_Profile and MTH_ST_Profile.enabled then
		started = MTH_ST_ProfileNow()
	end

	local stableDiagStart = nil
	local isStableUiEvt = MTH_ST_IsStableUiEvent(evt)
	if isStableUiEvt then
		stableDiagStart = MTH_ST_ProfileNow()
		MTH_ST_PrintStableDiag("evt=" .. tostring(evt) .. " phase=begin")
		if MTH_ST_Trace and not MTH_ST_Trace.enabled then
			MTH_ST_Trace.enabled = true
			MTH_ST_Trace.verbose = false
			MTH_ST_TraceResetCounters()
			MTH_ST_PrintStableDiag("trace=auto-enabled")
		end
	end

	MTH_ST_DispatchEvent(frame, evt, eventArg1, eventArg2)

	if isStableUiEvt then
		local stableDiagEnd = MTH_ST_ProfileNow()
		local elapsedMs = 0
		if stableDiagStart and stableDiagEnd then
			elapsedMs = math.floor(math.max(0, (stableDiagEnd - stableDiagStart) * 1000) + 0.5)
		end
		MTH_ST_PrintStableDiag("evt=" .. tostring(evt) .. " phase=end elapsedMs=" .. tostring(elapsedMs))
		MTH_ST_TraceFlushIfDue(true)
	end

	if started then
		local finished = MTH_ST_ProfileNow()
		if finished then
			MTH_ST_ProfileRecordEvent(evt or event, (finished - started) * 1000)
			MTH_ST_ProfileFlushIfDue(false)
		end
	end
	MTH_ST_TraceFlushIfDue(false)
end

function MTH_ST_InitService()
	if MTH and MTH.ApplyClassGate and MTH:ApplyClassGate("stablescan-init") then
		return
	end

	if MTH_PetLifecycleEventFrame then
		return
	end

	MTH_PetLifecycleEventFrame = CreateFrame("Frame", "MTHPetLifecycleEventFrame")
	MTH_PetLifecycleEventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	MTH_PetLifecycleEventFrame:RegisterEvent("UNIT_PET")
	MTH_PetLifecycleEventFrame:RegisterEvent("PET_BAR_UPDATE")
	MTH_PetLifecycleEventFrame:RegisterEvent("UNIT_HAPPINESS")
	MTH_PetLifecycleEventFrame:RegisterEvent("CHAT_MSG_COMBAT_XP_GAIN")
	MTH_PetLifecycleEventFrame:RegisterEvent("PLAYER_XP_UPDATE")
	MTH_PetLifecycleEventFrame:RegisterEvent("CHAT_MSG_SYSTEM")
	MTH_PetLifecycleEventFrame:RegisterEvent("CHAT_MSG_SPELL_PET_INFO")
	MTH_PetLifecycleEventFrame:RegisterEvent("CHAT_MSG_SPELL_PET_DAMAGE")
	MTH_PetLifecycleEventFrame:RegisterEvent("CHAT_MSG_COMBAT_PET_HITS")
	MTH_PetLifecycleEventFrame:RegisterEvent("CHAT_MSG_COMBAT_PET_MISSES")
	MTH_PetLifecycleEventFrame:RegisterEvent("UI_ERROR_MESSAGE")
	MTH_PetLifecycleEventFrame:RegisterEvent("PET_STABLE_SHOW")
	MTH_PetLifecycleEventFrame:RegisterEvent("PET_STABLE_UPDATE")
	MTH_PetLifecycleEventFrame:RegisterEvent("PET_STABLE_CLOSED")
	MTH_PetLifecycleEventFrame:SetScript("OnEvent", MTH_ST_OnEvent)
	MTH_ST_LastUnitPetHadPet = ((type(UnitExists) == "function") and UnitExists("pet")) and true or false
	MTH_PETS_InstallCoreRenameHook()
	MTH_PETS_EmitLiveState("service:init", true)
	if MTH_PETS_TRACE_CONSISTENCY and MTH and MTH.Print then
		MTH:Print("[PETCONSIST] trace enabled", "debug")
	end
end

function MTH_ST_InitBootstrap()
	if MTH and MTH.ApplyClassGate and MTH:ApplyClassGate("stablescan-bootstrap") then
		return
	end
	if MTH_PetLifecycleEventFrame or MTH_PetLifecycleBootstrapFrame then
		return
	end

	local frame = CreateFrame("Frame", "MTHPetLifecycleBootstrapFrame")
	if not frame then
		return
	end
	frame:RegisterEvent("PLAYER_ENTERING_WORLD")
	frame:RegisterEvent("PET_STABLE_SHOW")
	frame:RegisterEvent("PET_STABLE_UPDATE")
	frame:SetScript("OnEvent", function(self, evt)
		evt = evt or event
		if evt ~= "PLAYER_ENTERING_WORLD" and evt ~= "PET_STABLE_SHOW" and evt ~= "PET_STABLE_UPDATE" then
			return
		end
		if evt == "PET_STABLE_SHOW" or evt == "PET_STABLE_UPDATE" then
			MTH_ST_PrintStableDiag("bootstrap evt=" .. tostring(evt) .. " phase=begin")
		end
		MTH_ST_InitService()
		if evt == "PET_STABLE_SHOW" or evt == "PET_STABLE_UPDATE" then
			MTH_ST_PrintStableDiag("bootstrap evt=" .. tostring(evt) .. " phase=end action=no-scan")
		end
		if self and self.UnregisterAllEvents then
			self:UnregisterAllEvents()
			self:SetScript("OnEvent", nil)
		end
		MTH_PetLifecycleBootstrapFrame = nil
	end)
	MTH_PetLifecycleBootstrapFrame = frame
end

function MTH_ST_ShutdownService(_reason)
	if not MTH_PetLifecycleEventFrame then
		return
	end

	MTH_PetLifecycleEventFrame:UnregisterAllEvents()
	MTH_PetLifecycleEventFrame:SetScript("OnEvent", nil)
	MTH_PetLifecycleEventFrame = nil
	MTH_ST_LastAutoScanAt = 0
	MTH_ST_LastUnitPetHadPet = false
	MTH_PETS_LiveState = nil
	MTH_PETS_LiveStateSeq = 0

	if type(PetRename) == "function" and PetRename == MTH_PETS_CorePetRenameHook and type(MTH_PETS_CoreOriginal_PetRename) == "function" then
		PetRename = MTH_PETS_CoreOriginal_PetRename
	end
	if MTH and MTH.RestoreHookBoundary then
		MTH:RestoreHookBoundary(MTH_PETS_CORE_HOOK_BOUNDARY_KEY)
	end
end

MTH_PETS_GetRootStore()
