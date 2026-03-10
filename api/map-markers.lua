MTH_Map = {
	enabled = true,
	showWorld = true,
	showMinimap = true,
	activeSource = "focus",
	providers = {},
	nodesByZone = {},
	worldPins = {},
	minimapPins = {},
	zoneNameToId = {},
	zoneNameNormToId = {},
	mapZoneCache = {},
	focusNodes = {},
	pendingZoneOpenId = nil,
	pendingZoneOpenSourceId = nil,
	pendingZoneOpenAttempts = 0,
	pendingZoneOpenNextAttemptAt = 0,
	controller = nil,
	minimapTick = 0,
	lastMapContext = "n/a",
	lastWorldReason = "n/a",
	lastMiniReason = "n/a",
	nodeRevision = 0,
	minimapForceRefreshInterval = 1.0,
	verboseMiniReasons = false,
	minimapTickActive = 0.20,
	minimapTickIdle = 0.75,
}

local MTH_MAP_MINIMAP_ZOOM = {
	[0] = { [0] = 300, [1] = 240, [2] = 180, [3] = 120, [4] = 80, [5] = 50 },
	[1] = { [0] = 466 + 2/3, [1] = 400, [2] = 333 + 1/3, [3] = 266 + 2/6, [4] = 200, [5] = 133 + 1/3 },
}

local MTH_MAP_FAMILY_PALETTE = {
	{ 0.95, 0.35, 0.35 },
	{ 0.95, 0.55, 0.20 },
	{ 0.95, 0.78, 0.20 },
	{ 0.82, 0.92, 0.20 },
	{ 0.45, 0.90, 0.35 },
	{ 0.20, 0.88, 0.62 },
	{ 0.20, 0.82, 0.95 },
	{ 0.35, 0.65, 0.95 },
	{ 0.62, 0.55, 0.95 },
	{ 0.88, 0.45, 0.88 },
	{ 0.95, 0.45, 0.68 },
	{ 0.78, 0.78, 0.82 },
}

local MTH_MAP_FAMILY_COLOR_CACHE = {}

local function MTH_Map_Mod(a, b)
	if b == 0 then return 0 end
	if math.mod then
		return math.mod(a, b)
	end
	if math.fmod then
		return math.fmod(a, b)
	end
	return 0
end

local function MTH_Map_Log(msg)
	if MTH and MTH.debug and MTH.Print then
		MTH:Print("[MAP] " .. tostring(msg), "debug")
	end
end

local function MTH_Map_NormalizeName(name)
	if not name then return "" end
	local lowered = string.lower(tostring(name))
	return string.gsub(lowered, "[^%w]", "")
end

local function MTH_Map_GetFamilyColor(family)
	local key = MTH_Map_NormalizeName(family)
	if key == "" then
		return 0.95, 0.82, 0.10
	end

	if MTH_MAP_FAMILY_COLOR_CACHE[key] then
		local c = MTH_MAP_FAMILY_COLOR_CACHE[key]
		return c[1], c[2], c[3]
	end

	local names = {}
	local seen = {}
	if MTH_DS_Beasts then
		for _, beast in pairs(MTH_DS_Beasts) do
			if beast and beast.family then
				local n = MTH_Map_NormalizeName(beast.family)
				if n ~= "" and not seen[n] then
					seen[n] = beast.family
					table.insert(names, beast.family)
				end
			end
		end
	end

	table.sort(names, function(a, b)
		return MTH_Map_NormalizeName(a) < MTH_Map_NormalizeName(b)
	end)

	for i = 1, table.getn(names) do
		local normalized = MTH_Map_NormalizeName(names[i])
		if not MTH_MAP_FAMILY_COLOR_CACHE[normalized] then
			local paletteIndex = MTH_Map_Mod((i - 1), table.getn(MTH_MAP_FAMILY_PALETTE)) + 1
			MTH_MAP_FAMILY_COLOR_CACHE[normalized] = MTH_MAP_FAMILY_PALETTE[paletteIndex]
		end
	end

	local resolved = MTH_MAP_FAMILY_COLOR_CACHE[key]
	if resolved then
		return resolved[1], resolved[2], resolved[3]
	end

	return 0.95, 0.82, 0.10
end

local function MTH_Map_StripThePrefix(name)
	if not name then return nil end
	local lowered = string.lower(name)
	if string.sub(lowered, 1, 4) == "the " and string.len(name) > 4 then
		return string.sub(name, 5)
	end
	return nil
end

local function MTH_Map_GetZoneNameById(zoneId)
	local normalizedId = tonumber(zoneId) or zoneId
	if not normalizedId then return nil end

	if MTH_DS_ZoneNamesFallback and MTH_DS_ZoneNamesFallback[normalizedId] then
		return MTH_DS_ZoneNamesFallback[normalizedId]
	end

	if not MTH_DS_Zones then return nil end
	local row = MTH_DS_Zones[normalizedId] or MTH_DS_Zones[tostring(normalizedId)]
	if not row or not row.names then return nil end
	return row.names.enUS or row.names[GetLocale()] or row.names.deDE or row.names.frFR
end

local function MTH_Map_MinimapIndoorState()
	local tempzoom = 0
	local state = 1

	if GetCVar("minimapZoom") == GetCVar("minimapInsideZoom") then
		if (GetCVar("minimapInsideZoom") + 0) >= 3 then
			Minimap:SetZoom(Minimap:GetZoom() - 1)
			tempzoom = 1
		else
			Minimap:SetZoom(Minimap:GetZoom() + 1)
			tempzoom = -1
		end
	end

	if (GetCVar("minimapInsideZoom") + 0) == Minimap:GetZoom() then
		state = 0
	end

	Minimap:SetZoom(Minimap:GetZoom() + tempzoom)
	return state
end

local function MTH_Map_AddNode(list, zoneId, x, y, title, detail, r, g, b, meta)
	local nx = tonumber(x)
	local ny = tonumber(y)
	local zid = tonumber(zoneId)
	if not nx or not ny or not zid then return end
	if nx <= 0 or ny <= 0 or nx > 100 or ny > 100 then return end

	local node = {
		zoneId = zid,
		x = nx,
		y = ny,
		title = title or "Unknown",
		detail = detail,
		color = { r or 1, g or 1, b or 1 },
	}
	if type(meta) == "table" then
		for key, value in pairs(meta) do
			node[key] = value
		end
	end
	table.insert(list, node)
end

local function MTH_Map_TT_Trim(value)
	if value == nil then return "" end
	local text = tostring(value)
	text = string.gsub(text, "^%s+", "")
	text = string.gsub(text, "%s+$", "")
	return text
end

local function MTH_Map_TT_Lower(value)
	if value == nil then return "" end
	return string.lower(tostring(value))
end

local function MTH_Map_TT_GetKnownSpellMap()
	if not MTH_CharSavedVariables or not MTH_CharSavedVariables.petTraining then
		return nil
	end
	return MTH_CharSavedVariables.petTraining.spellMap
end

local function MTH_Map_TT_ParseAbilityToken(token)
	local text = MTH_Map_TT_Trim(token)
	if text == "" then
		return "", nil
	end
	local _, _, abilityName, rankText = string.find(text, "^(.-)%s+(%d+)$")
	if abilityName and abilityName ~= "" then
		return MTH_Map_TT_Trim(abilityName), tonumber(rankText)
	end
	return text, nil
end

local function MTH_Map_TT_HunterKnowsAbility(abilityName, rankNumber)
	local abilityLower = MTH_Map_TT_Lower(abilityName)
	if abilityLower == "" then return false end

	local spellMap = MTH_Map_TT_GetKnownSpellMap()
	if type(spellMap) ~= "table" then
		return false
	end

	for _, row in pairs(spellMap) do
		if row and row.name and row.isKnown ~= false then
			if MTH_Map_TT_Lower(row.name) == abilityLower then
				if rankNumber then
					if tonumber(row.rankNumber) == tonumber(rankNumber) then
						return true
					end
				else
					return true
				end
			end
		end
	end

	return false
end

local function MTH_Map_TT_ParseAbilities(abilitiesText)
	local text = MTH_Map_TT_Trim(abilitiesText)
	local parsed = {}
	if text == "" or text == "None" then
		return parsed
	end

	local startPos = 1
	local len = string.len(text)
	while startPos <= len do
		local commaPos = string.find(text, ",", startPos, true)
		local token
		if commaPos then
			token = string.sub(text, startPos, commaPos - 1)
			startPos = commaPos + 1
		else
			token = string.sub(text, startPos)
			startPos = len + 1
		end

		token = MTH_Map_TT_Trim(token)
		if token ~= "" then
			local abilityName, rankNumber = MTH_Map_TT_ParseAbilityToken(token)
			table.insert(parsed, {
				text = token,
				known = MTH_Map_TT_HunterKnowsAbility(abilityName, rankNumber),
			})
		end
	end

	return parsed
end

local function MTH_Map_GetCoordsForUnit(unitId, fallbackCoords)
	if not unitId then return fallbackCoords end

	if MTH_DS_UnitCoords and MTH_DS_UnitCoords[unitId] and table.getn(MTH_DS_UnitCoords[unitId]) > 0 then
		return MTH_DS_UnitCoords[unitId]
	end

	if MTH_DS_CreatureCoords and MTH_DS_CreatureCoords[unitId] and table.getn(MTH_DS_CreatureCoords[unitId]) > 0 then
		return MTH_DS_CreatureCoords[unitId]
	end

	return fallbackCoords
end

function MTH_Map:BuildZoneLookup()
	self.zoneNameToId = {}
	self.zoneNameNormToId = {}

	if MTH_DS_Zones then
		for zoneId, row in pairs(MTH_DS_Zones) do
			local zid = tonumber(zoneId)
			if zid and row and row.names then
				for _, value in pairs(row.names) do
					if value and value ~= "" then
						self.zoneNameToId[value] = zid
						self.zoneNameNormToId[MTH_Map_NormalizeName(value)] = zid
					end
				end
			end
		end
	end

	if MTH_DS_ZoneNamesFallback then
		for zoneId, value in pairs(MTH_DS_ZoneNamesFallback) do
			local zid = tonumber(zoneId)
			if zid and value and value ~= "" then
				if not self.zoneNameToId[value] then
					self.zoneNameToId[value] = zid
				end
				local norm = MTH_Map_NormalizeName(value)
				if not self.zoneNameNormToId[norm] then
					self.zoneNameNormToId[norm] = zid
				end
			end
		end
	end

	local count = 0
	for _ in pairs(self.zoneNameNormToId) do
		count = count + 1
	end
	MTH_Map_Log("Zone lookup rebuilt: " .. tostring(count) .. " entries")
end

function MTH_Map:GetMapIDByName(name)
	if not name or name == "" then return nil end

	if not next(self.zoneNameNormToId or {}) then
		self:BuildZoneLookup()
	end

	local id = self.zoneNameToId[name]
	if id then return id end

	local normalized = MTH_Map_NormalizeName(name)
	id = self.zoneNameNormToId[normalized]
	if id then return id end

	local stripped = MTH_Map_StripThePrefix(name)
	if stripped then
		id = self.zoneNameToId[stripped]
		if id then return id end
		id = self.zoneNameNormToId[MTH_Map_NormalizeName(stripped)]
		if id then return id end
	else
		local withThe = "The " .. name
		id = self.zoneNameToId[withThe]
		if id then return id end
		id = self.zoneNameNormToId[MTH_Map_NormalizeName(withThe)]
		if id then return id end
	end

	return nil
end

function MTH_Map:ResolveZoneHierarchy(zoneId)
	local inputId = tonumber(zoneId)
	local resolved = {
		inputId = inputId,
		zoneId = inputId,
		parentId = nil,
		subzoneId = nil,
		continentId = nil,
		hasMinimapSize = false,
	}

	if not inputId then
		return resolved
	end

	local sizes = MTH_DS_MinimapSizes or (pfDB and pfDB["minimap"]) or {}
	local visited = {}
	local cursor = inputId
	local depth = 0

	while cursor and not visited[cursor] and depth < 8 do
		visited[cursor] = true
		local row = MTH_DS_Zones and (MTH_DS_Zones[cursor] or MTH_DS_Zones[tostring(cursor)])
		if not row then
			break
		end

		local parent = tonumber(row.parent or row.continent)
		if parent and not resolved.continentId then
			resolved.continentId = parent
		end

		if parent and parent > 0 and parent ~= cursor then
			resolved.subzoneId = resolved.subzoneId or cursor
			resolved.parentId = parent
			cursor = parent
			resolved.zoneId = cursor
			depth = depth + 1
		else
			break
		end
	end

	local renderZoneId = resolved.zoneId
	if not sizes[renderZoneId] then
		if sizes[inputId] then
			renderZoneId = inputId
		elseif resolved.parentId and sizes[resolved.parentId] then
			renderZoneId = resolved.parentId
		end
	end

	resolved.zoneId = renderZoneId
	resolved.hasMinimapSize = sizes[renderZoneId] and true or false
	return resolved
end

function MTH_Map:GetCurrentMapID()
	local continent = GetCurrentMapContinent and GetCurrentMapContinent() or nil
	local zone = GetCurrentMapZone and GetCurrentMapZone() or nil
	local zoneName = nil
	local mapId = nil
	local worldMapShown = WorldMapFrame and WorldMapFrame.IsShown and WorldMapFrame:IsShown() or false

	if continent and zone and continent > 0 and zone > 0 and GetMapZones then
		if not self.mapZoneCache[continent] then
			self.mapZoneCache[continent] = { GetMapZones(continent) }
		end
		zoneName = self.mapZoneCache[continent][zone]
		mapId = self:GetMapIDByName(zoneName)
		if mapId then
			local resolved = self:ResolveZoneHierarchy(mapId)
			local normalized = resolved.zoneId or mapId
			self.lastMapContext = string.format("continent=%s zone=%s mapZone='%s' real=nil mapId=%s normalized=%s", tostring(continent), tostring(zone), tostring(zoneName), tostring(mapId), tostring(normalized))
			return normalized
		end
	end

	if worldMapShown then
		self.lastMapContext = string.format("continent=%s zone=%s mapZone='%s' real=skipped mapId=nil (zoomed-out)", tostring(continent), tostring(zone), tostring(zoneName))
		return nil
	end

	local real = GetRealZoneText and GetRealZoneText() or nil
	if real then
		mapId = self:GetMapIDByName(real)
		local resolved = self:ResolveZoneHierarchy(mapId)
		local normalized = resolved.zoneId or mapId
		self.lastMapContext = string.format("continent=%s zone=%s mapZone='%s' real='%s' mapId=%s normalized=%s", tostring(continent), tostring(zone), tostring(zoneName), tostring(real), tostring(mapId), tostring(normalized))
		return normalized
	end

	self.lastMapContext = string.format("continent=%s zone=%s mapZone='%s' real=nil mapId=nil", tostring(continent), tostring(zone), tostring(zoneName))

	return nil
end

function MTH_Map:RegisterProvider(key, provider)
	if not key or type(key) ~= "string" then return false end
	if type(provider) ~= "table" or type(provider.buildNodes) ~= "function" then return false end
	self.providers[key] = provider
	return true
end

local function MTH_Map_ClearPendingZoneOpen()
	MTH_Map.pendingZoneOpenId = nil
	MTH_Map.pendingZoneOpenSourceId = nil
	MTH_Map.pendingZoneOpenAttempts = 0
	MTH_Map.pendingZoneOpenNextAttemptAt = 0
end

function MTH_Map:EnsureInitialized()
	if self.controller then
		return true
	end
	self:Init()
	return self.controller ~= nil
end

function MTH_Map:SetSource(key)
	if not self:EnsureInitialized() then
		return false
	end
	if not self.providers[key] then
		return false
	end
	if key ~= "focus" and self.activeSource == key and self.nodesByZone and next(self.nodesByZone) then
		self:UpdateWorldMap()
		self:UpdateMinimap()
		return true
	end
	self.activeSource = key
	self:RebuildNodes()
	self:UpdateWorldMap()
	self:UpdateMinimap()
	return true
end

local function MTH_Map_ApplyWorldMapZone(targetZoneId, sourceZoneId)
	if not (GetMapContinents and GetMapZones and SetMapZoom) then
		return false
	end

	local targetNames = {}
	local resolvedName = MTH_Map_GetZoneNameById(targetZoneId)
	if resolvedName and resolvedName ~= "" then
		targetNames[MTH_Map_NormalizeName(resolvedName)] = true
	end
	local sourceName = MTH_Map_GetZoneNameById(sourceZoneId)
	if sourceName and sourceName ~= "" then
		targetNames[MTH_Map_NormalizeName(sourceName)] = true
	end

	local continents = { GetMapContinents() }
	for continentId = 1, table.getn(continents) do
		local zones = { GetMapZones(continentId) }
		for mapIndex = 1, table.getn(zones) do
			local zoneName = zones[mapIndex]
			if zoneName and targetNames[MTH_Map_NormalizeName(zoneName)] then
				SetMapZoom(continentId, mapIndex)
				return true
			end
		end
	end

	return false
end

function MTH_Map:OpenWorldMapForZone(zoneId)
	local zid = tonumber(zoneId)
	if not zid then return false end
	local resolved = self:ResolveZoneHierarchy(zid)
	local targetZoneId = tonumber(resolved.zoneId or zid) or zid

	if ToggleWorldMap then
		if not WorldMapFrame or not WorldMapFrame:IsShown() then
			ToggleWorldMap()
		end
	elseif WorldMapFrame and not WorldMapFrame:IsShown() then
		WorldMapFrame:Show()
	end

	if pfMap and pfMap.SetMapByID then
		pfMap:SetMapByID(targetZoneId)
		local currentAfterPF = self:GetCurrentMapID()
		if tonumber(currentAfterPF) == tonumber(targetZoneId) then
			MTH_Map_ClearPendingZoneOpen()
			return true
		end
	end

	local zoomApplied = MTH_Map_ApplyWorldMapZone(targetZoneId, zid)
	if zoomApplied then
		local currentAfterZoom = self:GetCurrentMapID()
		if tonumber(currentAfterZoom) == tonumber(targetZoneId) then
			MTH_Map_ClearPendingZoneOpen()
			return true
		end
	end

	local nowMapId = self:GetCurrentMapID()
	if tonumber(nowMapId) == tonumber(targetZoneId) then
		MTH_Map_ClearPendingZoneOpen()
		return true
	end

	self.pendingZoneOpenId = targetZoneId
	self.pendingZoneOpenSourceId = zid
	self.pendingZoneOpenAttempts = 8
	self.pendingZoneOpenNextAttemptAt = (GetTime and GetTime() or 0) + 0.25
	return true
end

function MTH_Map:FocusBeast(beastId, beast)
	local id = tonumber(beastId)
	if not id then return false end

	local row = beast or (MTH_DS_Beasts and MTH_DS_Beasts[id])
	if not row then return false end

	local coords = MTH_Map_GetCoordsForUnit(id, row.coords)
	if not coords or table.getn(coords) == 0 then return false end

	local cr, cg, cb = MTH_Map_GetFamilyColor(row.family)
	local nodes = {}
	local firstZoneId = nil
	local displayName = (MTH and MTH.GetLocalizedBeastName and MTH:GetLocalizedBeastName(id, row.name)) or row.name or "Unknown"

	for i = 1, table.getn(coords) do
		local c = coords[i]
		if c and c[1] and c[2] and c[3] then
			local zoneId = tonumber(c[3])
			if zoneId and not firstZoneId then
				firstZoneId = zoneId
			end
			local details = string.format("Family: %s\nLevel: %s\nAbilities: %s", row.family or "?", row.lvl or "?", row.abilities or "None")
			MTH_Map_AddNode(nodes, c[3], c[1], c[2], string.format("%s (%d)", displayName, id), details, cr, cg, cb, { kind = "beast", beastId = id })
		end
	end

	if table.getn(nodes) == 0 then return false end

	self.focusNodes = nodes
	if not self:SetSource("focus") then
		return false
	end

	if firstZoneId then
		self:OpenWorldMapForZone(firstZoneId)
	end

	self:UpdateWorldMap()
	self:UpdateMinimap()
	return true
end

function MTH_Map:FocusVendor(vendorId, vendor)
	local id = tonumber(vendorId)
	if not id then return false end

	local row = vendor or (MTH_DS_Vendors and MTH_DS_Vendors[id])
	if not row then return false end

	local coords = MTH_Map_GetCoordsForUnit(id, row.coords)
	if not coords or table.getn(coords) == 0 then return false end

	local react = tostring(row.fac or "AH")
	local cr, cg, cb = 0.20, 0.75, 0.95
	if react == "A" then
		cr, cg, cb = 0.30, 0.55, 1.00
	elseif react == "H" then
		cr, cg, cb = 0.95, 0.35, 0.35
	elseif react == "AH" then
		cr, cg, cb = 0.95, 0.90, 0.35
	end

	local metaTags = "-"
	if row.meta then
		local labels = {}
		for key, value in pairs(row.meta) do
			if type(key) == "string" and value and tostring(value) ~= "" then
				table.insert(labels, key)
			end
		end
		if table.getn(labels) > 0 then
			table.sort(labels)
			metaTags = table.concat(labels, ", ")
		end
	end

	local nodes = {}
	local firstZoneId = nil
	local displayName = (MTH and MTH.GetLocalizedVendorName and MTH:GetLocalizedVendorName(id, row.name)) or row.name or "Unknown"
	for i = 1, table.getn(coords) do
		local c = coords[i]
		if c and c[1] and c[2] and c[3] then
			local zoneId = tonumber(c[3])
			if zoneId and not firstZoneId then
				firstZoneId = zoneId
			end
			local details = string.format("React: %s\nLevel: %s\nFunctions: %s", react ~= "" and react or "?", row.lvl or "?", metaTags)
			MTH_Map_AddNode(nodes, c[3], c[1], c[2], string.format("%s (%d)", displayName, id), details, cr, cg, cb, { kind = "vendor", vendorId = id })
		end
	end

	if table.getn(nodes) == 0 then return false end

	self.focusNodes = nodes
	if not self:SetSource("focus") then
		return false
	end

	if firstZoneId then
		self:OpenWorldMapForZone(firstZoneId)
	end

	self:UpdateWorldMap()
	self:UpdateMinimap()
	return true
end

function MTH_Map:SetEnabled(enabled)
	self.enabled = enabled and true or false
	if not self.enabled then
		self:HideAllPins()
	else
		if not self:EnsureInitialized() then
			return
		end
		self:UpdateWorldMap()
		self:UpdateMinimap()
	end
end

function MTH_Map:SetWorldEnabled(enabled)
	self.showWorld = enabled and true or false
	if not self.showWorld then
		self:HideWorldPins()
	else
		if not self:EnsureInitialized() then
			return
		end
		self:UpdateWorldMap()
	end
end

function MTH_Map:SetMinimapEnabled(enabled)
	self.showMinimap = enabled and true or false
	if not self.showMinimap then
		self:HideMinimapPins()
	else
		if not self:EnsureInitialized() then
			return
		end
		self:UpdateMinimap()
	end
end

function MTH_Map:GetStatusText()
	return string.format("source=%s, enabled=%s, world=%s, minimap=%s", self.activeSource, self.enabled and "on" or "off", self.showWorld and "on" or "off", self.showMinimap and "on" or "off")
end

local function MTH_Map_CountList(list)
	local count = 0
	if not list then return 0 end
	for _ in pairs(list) do
		count = count + 1
	end
	return count
end

function MTH_Map:GetStatsText()
	local zones = MTH_Map_CountList(self.nodesByZone)
	local activeNodes = 0
	for _, rows in pairs(self.nodesByZone) do
		activeNodes = activeNodes + MTH_Map_CountList(rows)
	end

	local worldTotal = MTH_Map_CountList(self.worldPins)
	local worldVisible = 0
	for _, pin in pairs(self.worldPins) do
		if pin and pin.IsShown and pin:IsShown() then worldVisible = worldVisible + 1 end
	end

	local miniTotal = MTH_Map_CountList(self.minimapPins)
	local miniVisible = 0
	for _, pin in pairs(self.minimapPins) do
		if pin and pin.IsShown and pin:IsShown() then miniVisible = miniVisible + 1 end
	end

	return string.format("nodes=%d zones=%d world=%d/%d mini=%d/%d worldReason=%s miniReason=%s map=%s", activeNodes, zones, worldVisible, worldTotal, miniVisible, miniTotal, tostring(self.lastWorldReason), tostring(self.lastMiniReason), tostring(self.lastMapContext))
end

function MTH_Map:GetContextText()
	local continent = GetCurrentMapContinent and GetCurrentMapContinent() or nil
	local zone = GetCurrentMapZone and GetCurrentMapZone() or nil
	local zoneName = nil
	if continent and zone and continent > 0 and zone > 0 and GetMapZones then
		if not self.mapZoneCache[continent] then
			self.mapZoneCache[continent] = { GetMapZones(continent) }
		end
		zoneName = self.mapZoneCache[continent][zone]
	end

	local mapIdFromZone = zoneName and self:GetMapIDByName(zoneName) or nil
	local realZoneName = GetRealZoneText and GetRealZoneText() or nil
	local mapIdFromReal = realZoneName and self:GetMapIDByName(realZoneName) or nil
	local baseMapId = mapIdFromZone or mapIdFromReal
	local resolved = self:ResolveZoneHierarchy(baseMapId)

	return string.format(
		"continent=%s zoneIndex=%s mapZone='%s' realZone='%s' mapId(zone)=%s mapId(real)=%s sourceZone=%s subzone=%s parent=%s renderZone=%s minimap=%s",
		tostring(continent),
		tostring(zone),
		tostring(zoneName),
		tostring(realZoneName),
		tostring(mapIdFromZone),
		tostring(mapIdFromReal),
		tostring(resolved.inputId),
		tostring(resolved.subzoneId),
		tostring(resolved.parentId),
		tostring(resolved.zoneId),
		resolved.hasMinimapSize and "yes" or "no"
	)
end

function MTH_Map:BuildPin(parent, name, isMinimap)
	local pin = CreateFrame("Button", name, parent)
	pin:SetWidth(isMinimap and 14 or 17)
	pin:SetHeight(isMinimap and 14 or 17)
	pin:SetFrameStrata(isMinimap and "MEDIUM" or "FULLSCREEN")
	pin:SetFrameLevel(isMinimap and 8 or 120)

	pin.tex = pin:CreateTexture(nil, "ARTWORK")
	pin.tex:SetAllPoints(pin)
	pin.tex:SetTexture("Interface\\AddOns\\MetaHunt\\img\\node")
	pin.tex:SetVertexColor(1, 1, 1, 1)

	pin:SetScript("OnEnter", function()
		if not this.meta then return end
		GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
		GameTooltip:ClearLines()
		GameTooltip:AddLine(this.meta.title or "Unknown", 1, 0.85, 0.2)
		if this.meta.detail and this.meta.detail ~= "" then
			GameTooltip:AddLine(this.meta.detail, 0.9, 0.9, 0.9, true)
		end
		local beastId = this.meta.beastId and tonumber(this.meta.beastId) or nil
		local beast = beastId and MTH_DS_Beasts and MTH_DS_Beasts[beastId] or nil
		if beast and beast.abilities then
			local abilities = MTH_Map_TT_ParseAbilities(beast.abilities)
			if table.getn(abilities) > 0 then
				GameTooltip:AddLine("Pet Abilities:", 1.0, 0.95, 0.45)
				for i = 1, table.getn(abilities) do
					local entry = abilities[i]
					if entry and entry.known then
						GameTooltip:AddLine("  " .. tostring(entry.text or ""), 0.2, 1.0, 0.2)
					else
						GameTooltip:AddLine("  " .. tostring(entry and entry.text or ""), 1.0, 0.25, 0.25)
					end
				end
			end
		end
		if this.meta.subzoneId and this.meta.zoneId and tonumber(this.meta.subzoneId) ~= tonumber(this.meta.zoneId) then
			local subzoneName = MTH_Map_GetZoneNameById(this.meta.subzoneId)
			if subzoneName then
				GameTooltip:AddLine("Subzone: " .. subzoneName, 0.7, 0.9, 1)
			end
		end
		local zoneName = MTH_Map_GetZoneNameById(this.meta.zoneId)
		if zoneName then
			GameTooltip:AddLine(zoneName .. string.format(" (%.1f, %.1f)", this.meta.x or 0, this.meta.y or 0), 0.6, 0.8, 1)
		end
		GameTooltip:Show()
	end)

	pin:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)

	pin:Hide()
	return pin
end

function MTH_Map:HideWorldPins()
	for i = 1, table.getn(self.worldPins) do
		if self.worldPins[i] then self.worldPins[i]:Hide() end
	end
end

function MTH_Map:HideMinimapPins()
	for i = 1, table.getn(self.minimapPins) do
		if self.minimapPins[i] then self.minimapPins[i]:Hide() end
	end
end

function MTH_Map:HideAllPins()
	self:HideWorldPins()
	self:HideMinimapPins()
end

function MTH_Map:RebuildNodes()
	self:BuildZoneLookup()
	self.nodesByZone = {}
	self.nodeRevision = (tonumber(self.nodeRevision) or 0) + 1
	self._lastWorldRenderKey = nil
	self._lastMiniState = nil
	local provider = self.providers[self.activeSource]
	if not provider then return end

	local allNodes = provider.buildNodes()
	if type(allNodes) ~= "table" then return end

	for i = 1, table.getn(allNodes) do
		local node = allNodes[i]
		if node and node.zoneId then
			local sourceZoneId = tonumber(node.zoneId)
			local resolved = self:ResolveZoneHierarchy(sourceZoneId)
			local zoneId = tonumber(resolved.zoneId or sourceZoneId)
			if zoneId then
				node.sourceZoneId = sourceZoneId
				node.zoneId = zoneId
				node.parentZoneId = resolved.parentId
				node.subzoneId = resolved.subzoneId
				if not self.nodesByZone[zoneId] then self.nodesByZone[zoneId] = {} end
				table.insert(self.nodesByZone[zoneId], node)
			end
		end
	end

	MTH_Map_Log("Rebuilt nodes for source '" .. tostring(self.activeSource) .. "'")
end

function MTH_Map:UpdateWorldMap()
	if not self.enabled or not self.showWorld then
		self.lastWorldReason = "disabled"
		self._lastWorldRenderKey = nil
		self:HideWorldPins()
		return
	end

	local worldButton = WorldMapButton
	if not WorldMapFrame or not WorldMapFrame:IsShown() or not worldButton then
		self.lastWorldReason = "worldmap-hidden-or-missing"
		self._lastWorldRenderKey = nil
		self:HideWorldPins()
		return
	end

	local mapId = self:GetCurrentMapID()
	if not mapId or not self.nodesByZone[mapId] then
		self.lastWorldReason = "no-mapid-or-nodes"
		self._lastWorldRenderKey = nil
		self:HideWorldPins()
		return
	end

	local nodes = self.nodesByZone[mapId]
	local worldWidth = worldButton:GetWidth() or 0
	local worldHeight = worldButton:GetHeight() or 0
	local worldKey = tostring(mapId)
		.. "|" .. tostring(worldWidth)
		.. "x" .. tostring(worldHeight)
		.. "|" .. tostring(table.getn(nodes))
		.. "|" .. tostring(self.nodeRevision or 0)
		.. "|" .. tostring(self.activeSource or "")
	if self._lastWorldRenderKey == worldKey then
		self.lastWorldReason = "cached(map=" .. tostring(mapId) .. ")"
		return
	end
	local shown = 0

	for i = 1, table.getn(nodes) do
		local node = nodes[i]
		if node then
			shown = shown + 1
			if not self.worldPins[shown] then
				self.worldPins[shown] = self:BuildPin(worldButton, "MTHMapWorldPin" .. shown, nil)
			end

			local pin = self.worldPins[shown]
			pin.meta = node
			pin.tex:SetVertexColor(node.color[1], node.color[2], node.color[3], 0.95)

			local x = node.x / 100 * worldButton:GetWidth()
			local y = node.y / 100 * worldButton:GetHeight()
			pin:ClearAllPoints()
			pin:SetPoint("CENTER", worldButton, "TOPLEFT", x, -y)
			pin:Show()
		end
	end

	for i = shown + 1, table.getn(self.worldPins) do
		if self.worldPins[i] then self.worldPins[i]:Hide() end
	end

	self._lastWorldRenderKey = worldKey
	self.lastWorldReason = "ok(map=" .. tostring(mapId) .. ",shown=" .. tostring(shown) .. ")"
end

function MTH_Map:UpdateMinimap()
	if not self.enabled or not self.showMinimap then
		self.lastMiniReason = "disabled"
		self._lastMiniState = nil
		self:HideMinimapPins()
		return
	end

	if not Minimap or not GetPlayerMapPosition then
		self.lastMiniReason = "minimap-or-position-api-missing"
		self._lastMiniState = nil
		self:HideMinimapPins()
		return
	end

	local mapId = self:GetCurrentMapID()
	local nodes = mapId and self.nodesByZone[mapId] or nil
	if not mapId or not nodes then
		self.lastMiniReason = "no-mapid-or-nodes"
		self._lastMiniState = nil
		self:HideMinimapPins()
		return
	end
	if table.getn(nodes) <= 0 then
		self.lastMiniReason = "no-nodes-in-zone"
		self._lastMiniState = nil
		self:HideMinimapPins()
		return
	end

	local now = GetTime() or 0
	local xPlayer, yPlayer = GetPlayerMapPosition("player")
	if not xPlayer or not yPlayer or (xPlayer == 0 and yPlayer == 0) then
		self.lastMiniReason = "player-position-unavailable"
		self._lastMiniState = nil
		self:HideMinimapPins()
		return
	end

	xPlayer = xPlayer * 100
	yPlayer = yPlayer * 100

	local zoom = Minimap:GetZoom()
	local miniState = self._lastMiniState
	if miniState
		and miniState.mapId == mapId
		and miniState.zoom == zoom
		and miniState.nodeRevision == (self.nodeRevision or 0)
	then
		local dx = math.abs((xPlayer or 0) - (miniState.xPlayer or 0))
		local dy = math.abs((yPlayer or 0) - (miniState.yPlayer or 0))
		if dx < 0.05 and dy < 0.05 and now < (miniState.nextForceAt or 0) then
			self.lastMiniReason = self.verboseMiniReasons and "throttled-small-move" or "throttle"
			return
		end
	end

	local minimapSizes = MTH_DS_MinimapSizes or (pfDB and pfDB["minimap"])
	local mapSize = minimapSizes and minimapSizes[mapId]
	if not mapSize then
		self.lastMiniReason = self.verboseMiniReasons and "missing-minimap-size" or "missing-size"
		self._lastMiniState = nil
		self:HideMinimapPins()
		return
	end

	local indoor = MTH_Map_MinimapIndoorState()
	local zoomSet = MTH_MAP_MINIMAP_ZOOM[indoor]
	if not zoomSet then
		self.lastMiniReason = self.verboseMiniReasons and "missing-zoomset" or "missing-zoomset"
		self._lastMiniState = nil
		self:HideMinimapPins()
		return
	end

	local mapZoom = zoomSet[zoom]
	if not mapZoom then
		self.lastMiniReason = self.verboseMiniReasons and "missing-mapzoom" or "missing-zoom"
		self._lastMiniState = nil
		self:HideMinimapPins()
		return
	end

	local mapWidth = mapSize[1]
	local mapHeight = mapSize[2]
	if not mapWidth or not mapHeight or mapWidth == 0 or mapHeight == 0 then
		self.lastMiniReason = self.verboseMiniReasons and "invalid-map-size" or "invalid-size"
		self._lastMiniState = nil
		self:HideMinimapPins()
		return
	end

	local xScale = mapZoom / mapWidth
	local yScale = mapZoom / mapHeight
	local xDraw = Minimap:GetWidth() / xScale / 100
	local yDraw = Minimap:GetHeight() / yScale / 100
	local shown = 0

	for i = 1, table.getn(nodes) do
		local node = nodes[i]
		if node then
			local xPos = (node.x - xPlayer) * xDraw
			local yPos = (node.y - yPlayer) * yDraw
			local distance = math.sqrt(xPos * xPos + yPos * yPos)
			local shouldShow = (distance + 6) < (Minimap:GetWidth() / 2)

			if shouldShow then
				shown = shown + 1
				if not self.minimapPins[shown] then
					self.minimapPins[shown] = self:BuildPin(Minimap, "MTHMapMiniPin" .. shown, true)
				end

				local pin = self.minimapPins[shown]
				pin.meta = node
				pin.tex:SetVertexColor(node.color[1], node.color[2], node.color[3], 0.95)
				pin:ClearAllPoints()
				pin:SetPoint("CENTER", Minimap, "CENTER", xPos, -yPos)
				pin:Show()
			end
		end
	end

	for i = shown + 1, table.getn(self.minimapPins) do
		if self.minimapPins[i] then self.minimapPins[i]:Hide() end
	end

	local lastState = self._lastMiniState or {}
	lastState.mapId = mapId
	lastState.zoom = zoom
	lastState.indoor = indoor
	lastState.xPlayer = xPlayer
	lastState.yPlayer = yPlayer
	lastState.nodeRevision = self.nodeRevision or 0
	lastState.nextForceAt = now + (tonumber(self.minimapForceRefreshInterval) or 1.0)
	self._lastMiniState = lastState

	if self.verboseMiniReasons then
		self.lastMiniReason = "ok(map=" .. tostring(mapId) .. ",shown=" .. tostring(shown) .. ")"
	else
		self.lastMiniReason = "ok"
	end
end

function MTH_Map:RegisterDefaultProviders()
	self:RegisterProvider("focus", {
		name = "Focused Beast",
		buildNodes = function()
			if MTH_Map.focusNodes and table.getn(MTH_Map.focusNodes) > 0 then
				return MTH_Map.focusNodes
			end
			return {}
		end,
	})

	self:RegisterProvider("beasts", {
		name = "Beasts",
		buildNodes = function()
			local nodes = {}
			if not MTH_DS_Beasts then return nodes end

			for beastId, beast in pairs(MTH_DS_Beasts) do
				local coords = beast and MTH_Map_GetCoordsForUnit(beastId, beast.coords)
				if beast and coords and table.getn(coords) > 0 then
					local displayName = (MTH and MTH.GetLocalizedBeastName and MTH:GetLocalizedBeastName(beastId, beast.name)) or beast.name or "Unknown"
					local cr, cg, cb = MTH_Map_GetFamilyColor(beast.family)
					for i = 1, table.getn(coords) do
						local c = coords[i]
						if c and c[1] and c[2] and c[3] then
							local details = string.format("Family: %s\nLevel: %s\nAbilities: %s", beast.family or "?", beast.lvl or "?", beast.abilities or "None")
							MTH_Map_AddNode(nodes, c[3], c[1], c[2], string.format("%s (%d)", displayName, beastId), details, cr, cg, cb, { kind = "beast", beastId = beastId })
						end
					end
				end
			end

			return nodes
		end,
	})

	self:RegisterProvider("vendors", {
		name = "Vendors",
		buildNodes = function()
			local nodes = {}
			if not MTH_DS_Vendors then return nodes end

			for vendorId, vendor in pairs(MTH_DS_Vendors) do
				local coords = vendor and MTH_Map_GetCoordsForUnit(vendorId, vendor.coords)
				if vendor and coords and table.getn(coords) > 0 then
					local displayName = (MTH and MTH.GetLocalizedVendorName and MTH:GetLocalizedVendorName(vendorId, vendor.name)) or vendor.name or "Unknown"
					for i = 1, table.getn(coords) do
						local c = coords[i]
						if c and c[1] and c[2] and c[3] then
							local details = string.format("Faction: %s\nLevel: %s", vendor.fac or "?", vendor.lvl or "?")
							MTH_Map_AddNode(nodes, c[3], c[1], c[2], string.format("%s (%d)", displayName, vendorId), details, 0.20, 0.90, 1.00, { kind = "vendor", vendorId = vendorId })
						end
					end
				end
			end

			return nodes
		end,
	})

	self:RegisterProvider("drops", {
		name = "Drops",
		buildNodes = function()
			local nodes = {}
			local items = MTH_DS_Items or MTH_DS_AmmoItems
			if not items then return nodes end
			local unresolvedCount = 0
			local unresolvedSamples = {}

			for itemId, item in pairs(items) do
				if item and item.drops then
					local itemDefaultName = item.name or "Unknown"
					local itemDisplayName = (MTH and MTH.GetLocalizedItemName)
						and MTH:GetLocalizedItemName(itemId, itemDefaultName)
						or itemDefaultName
					for creatureId, chance in pairs(item.drops) do
						local creature = MTH_DS_Beasts and MTH_DS_Beasts[creatureId]
						local coords = MTH_Map_GetCoordsForUnit(creatureId, creature and creature.coords)
						local creatureName = nil

						if MTH_DS_CreatureCoords and MTH_DS_CreatureCoords[creatureId] and table.getn(MTH_DS_CreatureCoords[creatureId]) > 0 then
								creatureName = (MTH_DS_CreatureNames and MTH_DS_CreatureNames[creatureId]) or ((MTH and MTH.GetLocalizedBeastName and creature and MTH:GetLocalizedBeastName(creatureId, creature.name)) or (creature and creature.name))
						elseif creature and creature.coords and table.getn(creature.coords) > 0 then
								creatureName = (MTH and MTH.GetLocalizedBeastName and MTH:GetLocalizedBeastName(creatureId, creature.name)) or creature.name
						end

						if coords and table.getn(coords) > 0 then
							for i = 1, table.getn(coords) do
								local c = coords[i]
								if c and c[1] and c[2] and c[3] then
									local pct = tonumber(chance)
									local chanceText = pct and string.format("%.2f%%", pct) or tostring(chance or "?")
									local details = string.format(
										"Item: %s (%d)\nDrop Creature: %s (%d)\nDrop Chance: %s",
										itemDisplayName or "Unknown",
										tonumber(itemId) or 0,
										creatureName or "Unknown",
										tonumber(creatureId) or 0,
										chanceText
									)
									MTH_Map_AddNode(
										nodes,
										c[3],
										c[1],
										c[2],
										string.format("%s ← %s", itemDisplayName or "Unknown Item", creatureName or "Unknown Creature"),
										details,
										1.00,
										0.35,
										0.35
									)
								end
							end
						else
							unresolvedCount = unresolvedCount + 1
							if table.getn(unresolvedSamples) < 5 then
								table.insert(unresolvedSamples, tostring(creatureId))
							end
						end
					end
				end
			end

			if unresolvedCount > 0 then
				MTH_Map_Log("drops source: " .. tostring(unresolvedCount) .. " drop-creature links have no loaded coordinates (sample IDs: " .. table.concat(unresolvedSamples, ", ") .. ")")
			end

			return nodes
		end,
	})
end

function MTH_Map:Init()
	if self.controller then
		return
	end
	self:BuildZoneLookup()
	self:RegisterDefaultProviders()
	self.nodesByZone = self.nodesByZone or {}

	if not self.controller then
		self.controller = CreateFrame("Frame", "MTH_MapController", UIParent)
		self.controller:RegisterEvent("PLAYER_ENTERING_WORLD")
		self.controller:RegisterEvent("ZONE_CHANGED")
		self.controller:RegisterEvent("ZONE_CHANGED_NEW_AREA")
		self.controller:RegisterEvent("MINIMAP_ZONE_CHANGED")
		self.controller:RegisterEvent("WORLD_MAP_UPDATE")

		self.controller:SetScript("OnEvent", function(frame, eventName)
			eventName = eventName or event
			if eventName == "PLAYER_ENTERING_WORLD" or eventName == "ZONE_CHANGED" or eventName == "ZONE_CHANGED_NEW_AREA" or eventName == "MINIMAP_ZONE_CHANGED" then
				if SetMapToCurrentZone and (not WorldMapFrame or not WorldMapFrame:IsShown()) then
					SetMapToCurrentZone()
				end
			end
			MTH_Map:UpdateWorldMap()
			MTH_Map:UpdateMinimap()
		end)

		self.controller:SetScript("OnUpdate", function(frame)
			frame = frame or this
			if not frame then return end
			local now = GetTime() or 0
			if (frame._mthTick or 0) > now then return end

			if MTH_Map.pendingZoneOpenId and MTH_Map.pendingZoneOpenAttempts and MTH_Map.pendingZoneOpenAttempts > 0 then
				if (MTH_Map.pendingZoneOpenNextAttemptAt or 0) <= now then
					MTH_Map.pendingZoneOpenNextAttemptAt = now + 0.25

					if WorldMapFrame and WorldMapFrame:IsShown() then
						if pfMap and pfMap.SetMapByID then
							pfMap:SetMapByID(MTH_Map.pendingZoneOpenId)
						end
						MTH_Map_ApplyWorldMapZone(MTH_Map.pendingZoneOpenId, MTH_Map.pendingZoneOpenSourceId)
						local nowMapId = MTH_Map:GetCurrentMapID()
						if tonumber(nowMapId) == tonumber(MTH_Map.pendingZoneOpenId) then
							MTH_Map_ClearPendingZoneOpen()
							MTH_Map:UpdateWorldMap()
						else
							MTH_Map.pendingZoneOpenAttempts = MTH_Map.pendingZoneOpenAttempts - 1
						end
					else
						MTH_Map.pendingZoneOpenAttempts = MTH_Map.pendingZoneOpenAttempts - 1
					end
				end

				if MTH_Map.pendingZoneOpenAttempts <= 0 then
					MTH_Map_ClearPendingZoneOpen()
				end
			end

			if MTH_Map.enabled and MTH_Map.showMinimap then
				local mapId = MTH_Map:GetCurrentMapID()
				if not mapId and (frame._mthMapRecoverAt or 0) <= now then
					frame._mthMapRecoverAt = now + 2.0
					if SetMapToCurrentZone and (not WorldMapFrame or not WorldMapFrame:IsShown()) then
						SetMapToCurrentZone()
						mapId = MTH_Map:GetCurrentMapID()
					end
				end
				local nodes = mapId and MTH_Map.nodesByZone and MTH_Map.nodesByZone[mapId] or nil
				local hasNodes = nodes and table.getn(nodes) > 0
				frame._mthTick = now + (hasNodes and (tonumber(MTH_Map.minimapTickActive) or 0.20) or (tonumber(MTH_Map.minimapTickIdle) or 0.75))
				if hasNodes then
					MTH_Map:UpdateMinimap()
				elseif (frame._mthNoNodeTick or 0) <= now then
					frame._mthNoNodeTick = now + 1.0
					MTH_Map:UpdateMinimap()
				end
			else
				frame._mthTick = now + (tonumber(MTH_Map.minimapTickIdle) or 0.75)
			end
		end)
	end

	MTH_Map_Log("Map system initialized")
end
