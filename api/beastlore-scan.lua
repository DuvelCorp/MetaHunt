------------------------------------------------------
-- MetaHunt: Beast Lore Scanner
-- TWoW 1.18.1 — "Nightmares of Ursol"
------------------------------------------------------
-- Fires when the player channels Beast Lore on a target.
-- Captures all available data and stores it in
-- MTH_SavedVariables.beastLoreScan.entries (account-wide).
--
-- Dedup rule: skips recording if the same creature name
-- already exists in this zone within 30 yards of current
-- player position (uses ds-minimap-sizes for yard scale).
-- A chat message is always printed either way.
------------------------------------------------------

local SPELL_BEAST_LORE  = "Beast Lore"
local DEDUP_YARDS       = 30
local FALLBACK_DEDUP_PCT = 0.015   -- ~1.5% of map width if zone size unknown

-- ── Tooltip probe ────────────────────────────────────────────

local MTH_BLS_Probe = nil
local function MTH_BLS_EnsureProbe()
	if not MTH_BLS_Probe then
		MTH_BLS_Probe = CreateFrame("GameTooltip", "MTH_BLSProbe", UIParent, "GameTooltipTemplate")
		MTH_BLS_Probe:SetOwner(UIParent, "ANCHOR_NONE")
	end
	return MTH_BLS_Probe
end

-- Read left/right text lines from the probe (Lua 5.0 compatible: getglobal)
local function MTH_BLS_GetProbeLines()
	local lines = {}
	for i = 1, 24 do
		local L = getglobal("MTH_BLSProbeTextLeft"  .. i)
		local R = getglobal("MTH_BLSProbeTextRight" .. i)
		local lText = L and L:GetText() or nil
		local rText = R and R:GetText() or nil
		if (not lText or lText == "") and (not rText or rText == "") then
			break
		end
		table.insert(lines, { left = lText or "", right = rText or "" })
	end
	return lines
end

-- Parse Beast Lore tooltip lines into structured fields.
-- Uses string.find with captures (Lua 5.0, no string.match).
local function MTH_BLS_ParseTooltip(lines)
	local data = {
		tameable  = nil,   -- true / false / nil (unknown)
		diet      = nil,
		abilities = nil,
		armor     = nil,
		health    = nil,
		minDmg    = nil,
		maxDmg    = nil,
	}

	for _, line in ipairs(lines) do
		local L = line.left  or ""
		local R = line.right or ""

		-- Tameability ──────────────────────────────────────────
		if string.find(L, "Cannot Be Tamed", 1, true) or string.find(R, "Cannot Be Tamed", 1, true) then
			data.tameable = false
		elseif string.find(L, "Can Be Tamed", 1, true) or string.find(R, "Can Be Tamed", 1, true)
			or string.find(L, "Tameable", 1, true) or string.find(R, "Tameable", 1, true) then
			data.tameable = true
		end

		-- Diet ─────────────────────────────────────────────────
		if not data.diet then
			local _, _, v = string.find(L, "^Diet:%s*(.*)")
			if not v then _, _, v = string.find(R, "^Diet:%s*(.*)") end
			if v and v ~= "" then data.diet = v end
		end

		-- Tamed Abilities ──────────────────────────────────────
		if not data.abilities then
			local _, _, v = string.find(L, "^Tamed Abilities:%s+(.*)")
			if not v then _, _, v = string.find(R, "^Tamed Abilities:%s+(.*)") end
			if v and v ~= "" then data.abilities = v end
		end

		-- Damage range ("107 - 133 Damage") ────────────────────
		if not data.minDmg then
			local _, _, lo, hi = string.find(L, "(%d+) %- (%d+) Damage")
			if not lo then _, _, lo, hi = string.find(R, "(%d+) %- (%d+) Damage") end
			if lo and hi then
				data.minDmg = tonumber(lo)
				data.maxDmg = tonumber(hi)
			end
		end

		-- Armor ────────────────────────────────────────────────
		if not data.armor then
			local _, _, v = string.find(L, "Armor:%s*(%d+)")
			if not v then _, _, v = string.find(R, "Armor:%s*(%d+)") end
			if v then data.armor = tonumber(v) end
		end

		-- Health ───────────────────────────────────────────────
		if not data.health then
			local _, _, v = string.find(L, "Health:%s*(%d+)")
			if not v then _, _, v = string.find(R, "Health:%s*(%d+)") end
			if v then data.health = tonumber(v) end
		end
	end

	return data
end

-- ── Location helpers ─────────────────────────────────────────

-- pfQuest AreaTable ID → WMA ID bridge (GetCurrentMapAreaID returns pfQ IDs)
local MTH_PFQ_TO_WMA = {
  [1]=27,[3]=17,[4]=19,[8]=38,[10]=34,[11]=40,[12]=30,[14]=4,[15]=141,[16]=181,
  [17]=11,[25]=519,[28]=22,[33]=37,[36]=15,[38]=35,[40]=39,[41]=32,[44]=36,
  [45]=16,[46]=29,[47]=26,[51]=28,[85]=20,[130]=21,[139]=23,[141]=41,[148]=42,
  [209]=650,[215]=9,[267]=24,[331]=43,[357]=121,[361]=182,[400]=61,[405]=101,
  [406]=81,[408]=505,[409]=504,[440]=161,[490]=201,[491]=641,[493]=241,
  [616]=501,[618]=281,[717]=611,[718]=516,[719]=609,[721]=518,[722]=639,
  [796]=520,[876]=500,[1176]=605,[1337]=521,[1377]=261,[1477]=607,[1497]=382,
  [1519]=301,[1537]=341,[1581]=514,[1583]=629,[1584]=623,[1637]=321,[1638]=362,
  [1657]=381,[1769]=700,[1941]=523,[1977]=619,[2017]=652,[2040]=509,[2057]=648,
  [2100]=517,[2159]=627,[2257]=659,[2366]=663,[2437]=603,[2557]=689,[2597]=401,
  [2677]=635,[2717]=617,[3277]=443,[3358]=461,[3428]=654,[3429]=625,[3456]=667,
  [3457]=682,[3478]=522,[4012]=502,[5023]=503,[5024]=511,[5053]=680,[5077]=670,
  [5086]=674,[5087]=676,[5097]=678,[5103]=672,[5121]=507,[5130]=601,[5135]=644,
  [5136]=643,[5138]=637,[5147]=655,[5148]=668,[5153]=645,[5163]=646,[5179]=510,
  [5204]=662,[5208]=665,[5225]=513,[5536]=512,[5557]=683,[5561]=685,[5581]=686,
  [5601]=691,[5602]=684,[5628]=693,[5640]=701,[5641]=698,[5642]=699,[5722]=702,
  [5723]=657,[5731]=705,[5734]=704,
}

local function MTH_BLS_GetZoneId()
	if type(SetMapToCurrentZone) == "function" then
		pcall(SetMapToCurrentZone)
	end
	if type(GetCurrentMapAreaID) == "function" then
		local ok, id = pcall(GetCurrentMapAreaID)
		if ok and tonumber(id) and tonumber(id) > 0 then
			local pfq = tonumber(id)
			return MTH_PFQ_TO_WMA[pfq] or pfq
		end
	end
	return 0
end

local function MTH_BLS_GetPlayerCoords()
	if type(SetMapToCurrentZone) == "function" then
		pcall(SetMapToCurrentZone)
	end
	if type(GetPlayerMapPosition) ~= "function" then return nil, nil end
	local ok, x, y = pcall(GetPlayerMapPosition, "player")
	if ok and x and y and (x ~= 0 or y ~= 0) then return x, y end
	return nil, nil
end

-- Returns true if a beast with this name is already in the static MTH_DS_Beasts database.
-- We skip SavedVariables recording for beasts already catalogued in the DB.
local function MTH_BLS_IsInStaticDB(name)
	if type(MTH_DS_Beasts) ~= "table" or not name or name == "" then return false end
	for _, row in pairs(MTH_DS_Beasts) do
		if type(row) == "table" and row.name == name then
			return true
		end
	end
	return false
end

-- ── Storage ──────────────────────────────────────────────────

local function MTH_BLS_EnsureStore()
	if type(MTH_SavedVariables) ~= "table" then
		MTH_SavedVariables = {}
	end
	if type(MTH_SavedVariables.beastLoreScan) ~= "table" then
		MTH_SavedVariables.beastLoreScan = {}
	end
	if type(MTH_SavedVariables.beastLoreScan.entries) ~= "table" then
		MTH_SavedVariables.beastLoreScan.entries = {}
	end
	return MTH_SavedVariables.beastLoreScan
end

-- ── Dedup ────────────────────────────────────────────────────

-- Returns the existing entry for a same-named beast in the same zone,
-- plus whether any of its recorded coords is within DEDUP_YARDS of (x, y).
local function MTH_BLS_FindEntry(name, zoneId, x, y)
	local store = MTH_BLS_EnsureStore()

	-- Normalize: treat 0 as unknown (entries are stored with nil for unknown zones)
	if not zoneId or zoneId == 0 then zoneId = nil end

	local mapW, mapH = nil, nil
	if type(MTH_DS_MinimapSizes) == "table" and zoneId then
		local sz = MTH_DS_MinimapSizes[zoneId]
		if type(sz) == "table" then
			mapW = tonumber(sz[1])
			mapH = tonumber(sz[2])
		end
	end

	local function IsNearby(ex, ey)
		if not ex or not ey or not x or not y then return false end
		local dx = ex - x
		local dy = ey - y
		if mapW and mapH then
			return math.sqrt((dx * mapW)^2 + (dy * mapH)^2) < DEDUP_YARDS
		else
			-- No map size data: use a generous fallback (~5% of map width)
			return math.sqrt(dx * dx + dy * dy) < 0.05
		end
	end

	local entries = store.entries
	for i = 1, table.getn(entries) do
		local e = entries[i]
		-- Match by name and zone. When either side has no zone, match on name alone
		-- (coords will still be checked below; cross-zone false positives are
		-- unlikely given players don't share coordinate spaces across zones).
		local zoneMatch = (e.zoneId == zoneId) or (not e.zoneId) or (not zoneId)
		if type(e) == "table"
			and e.name == name
			and zoneMatch
		then
			-- Check all recorded coords for this beast.
			if type(e.coords) == "table" then
				for j = 1, table.getn(e.coords) do
					local c = e.coords[j]
					if type(c) == "table" and IsNearby(c.x, c.y) then
						return e, true   -- entry found, nearby coord found
					end
				end
			elseif IsNearby(e.x, e.y) then
				-- Legacy single-coord entry
				return e, true
			end
			return e, false  -- entry found, but no coord nearby
		end
	end

	return nil, false  -- no entry for this beast in this zone
end

-- ── Main scan ────────────────────────────────────────────────
-- Per-session cooldown: prevents re-recording the same beast in the
-- same zone within SCAN_COOLDOWN seconds, as a safety net on top of
-- the coordinate-based dedup.
local MTH_BLS_ScanCooldowns = {}
local SCAN_COOLDOWN = 120  -- 2 minutes

local function MTH_BLS_Scan()
	-- Basic target guards
	if type(UnitExists) == "function" and not UnitExists("target") then return end
	if type(UnitIsPlayer) == "function" and UnitIsPlayer("target") then return end

	local name = (type(UnitName) == "function") and UnitName("target") or nil
	if not name or name == "" then return end

	-- ── Unit data ───────────────────────────────────────────
	local level     = (type(UnitLevel)         == "function") and UnitLevel("target")         or nil
	local family    = (type(UnitCreatureFamily) == "function") and UnitCreatureFamily("target") or nil
	local healthMax = (type(UnitHealthMax)      == "function") and UnitHealthMax("target")      or nil

	local minDmg, maxDmg, mainSpeed = nil, nil, nil
	if type(UnitDamage) == "function" then
		local ok, a, b, _, _, spd = pcall(UnitDamage, "target")
		if ok then minDmg, maxDmg, mainSpeed = a, b, spd end
	end
	if not mainSpeed and type(UnitAttackSpeed) == "function" then
		local ok, spd = pcall(UnitAttackSpeed, "target")
		if ok then mainSpeed = spd end
	end

	local guid = nil
	if type(UnitGUID) == "function" then
		local ok, g = pcall(UnitGUID, "target")
		if ok and g then guid = g end
	end

	-- ── Location ────────────────────────────────────────────
	local zoneId  = MTH_BLS_GetZoneId()
	local x, y   = MTH_BLS_GetPlayerCoords()
	local zone    = (type(GetZoneText)    == "function") and GetZoneText()    or ""
	local subzone = (type(GetSubZoneText) == "function") and GetSubZoneText() or ""

	-- Session cooldown: hard block on re-scanning the same beast in same zone
	local cooldownKey = tostring(name) .. "|" .. tostring(zone)
	local lastScan = MTH_BLS_ScanCooldowns[cooldownKey]
	if lastScan and (GetTime() - lastScan) < SCAN_COOLDOWN then
		MTH:Log("|cff888888Beast Lore: " .. tostring(name) .. " scanned recently — skipped|r")
		return
	end

	-- ── Tooltip probe ───────────────────────────────────────
	local probe = MTH_BLS_EnsureProbe()
	probe:ClearLines()
	local probeOk = pcall(function() probe:SetUnit("target") end)
	local parsed = { tameable = nil, diet = nil, abilities = nil, armor = nil, health = nil }
	if probeOk then
		local lines = MTH_BLS_GetProbeLines()
		parsed = MTH_BLS_ParseTooltip(lines)
	end

	-- Tooltip values override unit API (Beast Lore reveals more accurate data)
	if parsed.minDmg then minDmg  = parsed.minDmg  end
	if parsed.maxDmg then maxDmg  = parsed.maxDmg  end
	if parsed.health then healthMax = parsed.health end

	-- Fallback tameability: family present = tameable
	if parsed.tameable == nil then
		parsed.tameable = (family and family ~= "") and true or false
	end

	-- ── Dedup / upsert ──────────────────────────────────────
	local function R3(v)
		if type(v) ~= "number" then return nil end
		return math.floor(v * 1000 + 0.5) / 1000
	end
	local function R2(v)
		if type(v) ~= "number" then return nil end
		return math.floor(v * 100 + 0.5) / 100
	end

	local rx, ry = R3(x), R3(y)
	-- Mark scanned now (before storing) so any rapid re-trigger is blocked
	MTH_BLS_ScanCooldowns[cooldownKey] = GetTime()
	local existing, nearbyFound = MTH_BLS_FindEntry(name, zoneId, x, y)

	if nearbyFound then
		-- Already recorded at this location — do nothing.
		MTH:Log("|cff888888Beast Lore: " .. tostring(name)
			.. " already recorded nearby — skipped|r")
		return
	end

	local store = MTH_BLS_EnsureStore()

	if existing then
		-- Known beast, new location — add coord to its list.
		if type(existing.coords) ~= "table" then
			-- Migrate legacy single coord into coords list.
			existing.coords = {}
			if existing.x or existing.y then
				table.insert(existing.coords, { x = existing.x, y = existing.y, timestamp = existing.timestamp })
			end
			existing.x = nil
			existing.y = nil
		end
		table.insert(existing.coords, { x = rx, y = ry, timestamp = (type(time) == "function") and time() or nil })
		existing.lastUpdated = (type(time) == "function") and time() or nil
		-- Update abilities/data if newly revealed by this cast.
		if parsed.abilities and parsed.abilities ~= "" then existing.abilities = parsed.abilities end

		local coordStr = (rx and ry)
			and string.format(" (%.1f, %.1f)", rx * 100, ry * 100)
			or  ""
		local abilitiesStr = (existing.abilities and existing.abilities ~= "")
			and (" |cff88ddff[" .. existing.abilities .. "]|r")
			or  ""
		MTH:Log("Beast Lore: |cffffaa00" .. tostring(name) .. "|r lv" .. (existing.level and tostring(existing.level) or "?")
			.. " — new coord added" .. coordStr
			.. abilitiesStr
			.. " |cff888888[#" .. tostring(table.getn(store.entries)) .. " +" .. tostring(table.getn(existing.coords)) .. " loc]|r")
		return
	end

	-- Skip recording if this beast is already in the static database.
	if MTH_BLS_IsInStaticDB(name) then
		MTH:Log("|cff888888Beast Lore: " .. tostring(name) .. " is already in the MetaHunt database — skipped|r")
		return
	end

	-- New beast entirely.
	local entry = {
		name        = name,
		guid        = guid,
		level       = level,
		family      = family,
		tameable    = parsed.tameable,
		minDmg      = minDmg    and math.floor(minDmg + 0.5)  or nil,
		maxDmg      = maxDmg    and math.floor(maxDmg + 0.5)  or nil,
		attackSpeed = mainSpeed and R2(mainSpeed)              or nil,
		armor       = parsed.armor                            or nil,
		health      = healthMax                               or nil,
		diet        = parsed.diet                             or nil,
		abilities   = parsed.abilities                        or nil,
		coords      = { { x = rx, y = ry, timestamp = (type(time) == "function") and time() or nil } },
		zoneId      = (zoneId and zoneId > 0) and zoneId      or nil,
		zone        = (zone    and zone    ~= "") and zone     or nil,
		subzone     = (subzone and subzone ~= "") and subzone  or nil,
		timestamp   = (type(time) == "function") and time()   or nil,
	}
	table.insert(store.entries, entry)

	-- ── Chat confirmation ────────────────────────────────────
	local tameStr  = parsed.tameable
		and "|cff33ff55Tameable|r"
		or  "|cffff4444Cannot be Tamed|r"
	local famStr   = (family and family ~= "")
		and ("|cffffcc00" .. family .. "|r")
		or  "|cff888888unknown family|r"
	local lvlStr   = level and tostring(level) or "?"
	local coordStr = (x and y)
		and string.format(" (%.1f, %.1f)", x * 100, y * 100)
		or  ""
	local zoneStr  = (zone and zone ~= "") and (", " .. zone .. coordStr) or coordStr
	local idx      = table.getn(store.entries)

	local abilitiesStr = ""
	if parsed.abilities and parsed.abilities ~= "" then
		abilitiesStr = " |cff88ddff[" .. parsed.abilities .. "]|r"
	end

	MTH:Log("|cff00ff88YOU FOUND AND RECORDED A NEW BEAST!|r |cffffaa00" .. tostring(name) .. "|r lv" .. lvlStr
		.. " — " .. tameStr .. " • " .. famStr
		.. zoneStr
		.. abilitiesStr
		.. " |cff888888[#" .. tostring(idx) .. "]|r")
end

-- ── Detection: event-gated tooltip poll ─────────────────────
-- SPELLCAST_CHANNEL_* events do not reliably fire in TurtleWoW 1.18.1.
-- Strategy: spellcast events open a short window (MTH_BLS_WindowEnd).
-- OnUpdate only runs during that window, checking the target tooltip
-- for Beast Lore-specific lines ("Diet:", "Tamed Abilities:").
-- If no event fires at all, the window stays closed and nothing runs.

local MTH_BLS_Frame      = CreateFrame("Frame", "MTH_BeastLoreScanFrame")
local MTH_BLS_PollAccum  = 0
local MTH_BLS_WindowEnd  = 0   -- GetTime() deadline; 0 = window closed
local MTH_BLS_PollLast   = nil -- target name already scanned this window

local WINDOW_DURATION = 6      -- seconds to probe after Beast Lore cast

local function MTH_BLS_OpenWindow()
	MTH_BLS_WindowEnd = GetTime() + WINDOW_DURATION
	MTH_BLS_PollLast  = nil
end

-- [DISABLED] Beast Lore scan activation — not needed while full beast DB is shipped.
-- Re-enable by removing the `if false then` / `end` wrapper below.
if false then

-- Register all known spellcast event variants.
MTH_BLS_Frame:RegisterEvent("SPELLCAST_CHANNEL_START")
MTH_BLS_Frame:RegisterEvent("SPELLCAST_CHANNEL_STOP")
MTH_BLS_Frame:RegisterEvent("SPELLCAST_START")
MTH_BLS_Frame:RegisterEvent("SPELLCAST_STOP")
MTH_BLS_Frame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
MTH_BLS_Frame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
MTH_BLS_Frame:RegisterEvent("UNIT_SPELLCAST_START")
MTH_BLS_Frame:RegisterEvent("UNIT_SPELLCAST_STOP")
MTH_BLS_Frame:RegisterEvent("PLAYER_TARGET_CHANGED")
MTH_BLS_Frame:SetScript("OnEvent", function()
	local evt = event or ""

	if evt == "PLAYER_TARGET_CHANGED" then
		-- New target: reset so re-targeting after a cast works.
		MTH_BLS_PollLast = nil
		return
	end

	-- Determine spell name from event args.
	local isUnitEvt = string.sub(evt, 1, 15) == "UNIT_SPELLCAST_"
	local spellName
	if isUnitEvt then
		if (arg1 or "") ~= "player" then return end
		spellName = arg2 or ""
	else
		spellName = arg1 or ""
	end

	if string.find(spellName, SPELL_BEAST_LORE, 1, true) then
		MTH_BLS_OpenWindow()
	end
end)

MTH_BLS_Frame:SetScript("OnUpdate", function()
	MTH_BLS_PollAccum = MTH_BLS_PollAccum + (arg1 or 0)
	if MTH_BLS_PollAccum < 2.0 then return end
	MTH_BLS_PollAccum = 0

	if not (type(UnitExists) == "function" and UnitExists("target")) then return end
	if type(UnitIsPlayer) == "function" and UnitIsPlayer("target") then return end

	local name = (type(UnitName) == "function") and UnitName("target") or nil
	if not name or name == "" then return end
	if name == MTH_BLS_PollLast then return end

	-- Probe the target tooltip for Beast Lore-specific lines.
	local probe = MTH_BLS_EnsureProbe()
	probe:ClearLines()
	local probeOk = pcall(function() probe:SetUnit("target") end)
	if not probeOk then return end

	local hasData = false
	for i = 1, 20 do
		local L = getglobal("MTH_BLSProbeTextLeft" .. i)
		if not L then break end
		local txt = (L.GetText and L:GetText()) or ""
		if string.find(txt, "Diet:", 1, true)
			or string.find(txt, "Tamed Abilities:", 1, true)
			or string.find(txt, "Cannot Be Tamed", 1, true)
		then
			hasData = true
			break
		end
	end

	if not hasData then return end

	-- Beast Lore data confirmed — record and close window.
	MTH_BLS_PollLast = name
	MTH_BLS_WindowEnd = 0
	local ok, err = pcall(MTH_BLS_Scan)
	if not ok and MTH and MTH.Print then
		MTH:Print("[BeastLore Scan] error: " .. tostring(err), "error")
	end
end)

end -- [DISABLED] if false

-- ── Public accessors ─────────────────────────────────────────

-- Returns the first saved entry whose name matches (case-insensitive),
-- or nil if none found.
function MTH_BLS_FindSavedBeastByName(name)
	local store = MTH_BLS_EnsureStore()
	if not store or type(store.entries) ~= "table" then return nil end
	local wantLower = string.lower(name or "")
	if wantLower == "" then return nil end
	for i = 1, table.getn(store.entries) do
		local e = store.entries[i]
		if type(e) == "table" and string.lower(e.name or "") == wantLower then
			return e
		end
	end
	return nil
end
