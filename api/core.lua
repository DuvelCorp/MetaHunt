if not MTH then
	error("MetaHunt core framework missing: api/core-framework.lua must load before api/core.lua")
end

local function MTH_PT_GetGlobal(name)
	if type(getglobal) == "function" then
		return getglobal(name)
	end
	if _G then
		return _G[name]
	end
	return nil
end

local MTH_ItemLinkCache = nil

local function MTH_GetQualityHexColor(quality)
	local q = tonumber(quality)
	if type(GetItemQualityColor) == "function" and q then
		local _, _, _, colorCode = GetItemQualityColor(q)
		if colorCode and colorCode ~= "" then
			local hex = string.gsub(tostring(colorCode), "|c", "")
			hex = string.gsub(hex, "|r", "")
			hex = string.gsub(hex, "^#", "")
			if string.len(hex) == 8 then return hex end
			if string.len(hex) == 6 then return "ff" .. hex end
		end
	end
	return "ffffffff"
end

function MTH_PrimeItemCache(itemId)
	local id = tonumber(itemId)
	if not id or id <= 0 then return false end
	if type(GetItemInfo) == "function" and GetItemInfo(id) then return true end

	if not MTH_ItemLinkCache then
		MTH_ItemLinkCache = CreateFrame("GameTooltip", "MTH_ItemLinkCache", UIParent, "GameTooltipTemplate")
		if not MTH_ItemLinkCache then return false end
		MTH_ItemLinkCache:SetOwner(UIParent, "ANCHOR_NONE")
	end

	MTH_ItemLinkCache:ClearLines()
	MTH_ItemLinkCache:SetHyperlink("item:" .. tostring(id) .. ":0:0:0")
	return type(GetItemInfo) == "function" and (GetItemInfo(id) ~= nil) or false
end

function MTH_GetClickableItemLink(itemId, fallbackName, tryPrimeCache)
	local id = tonumber(itemId)
	if not id then return nil end

	local itemName = nil
	local itemLink = nil
	local itemQuality = nil
	if type(GetItemInfo) == "function" then
		itemName, itemLink, itemQuality = GetItemInfo(id)
		if (not itemName or itemName == "") and tryPrimeCache then
			MTH_PrimeItemCache(id)
			itemName, itemLink, itemQuality = GetItemInfo(id)
		end
	end

	local displayName = tostring(itemName or fallbackName or ("Item " .. tostring(id)))
	local coreLink = nil
	if itemLink and itemLink ~= "" then
		local _, _, parsedCore = string.find(tostring(itemLink), "|H(item:[^|]+)|h")
		if parsedCore and parsedCore ~= "" then
			coreLink = parsedCore
		elseif string.find(tostring(itemLink), "^item:", 1, true) then
			coreLink = tostring(itemLink)
		end
	end
	if not coreLink then
		coreLink = "item:" .. tostring(id) .. ":0:0:0"
	end

	local colorHex = MTH_GetQualityHexColor(itemQuality)
	return "|c" .. tostring(colorHex) .. "|H" .. tostring(coreLink) .. "|h[" .. tostring(displayName) .. "]|h|r"
end

function MTH_InsertLinkToChat(link)
	if type(link) ~= "string" or link == "" then return false end

	local wimEditBox = MTH_PT_GetGlobal("WIM_EditBoxInFocus")
	if wimEditBox and type(wimEditBox.Insert) == "function" then
		wimEditBox:Insert(link)
		return true
	end

	local chatEditBox = MTH_PT_GetGlobal("ChatFrameEditBox")
	if not chatEditBox then return false end

	if type(chatEditBox.IsVisible) == "function" and chatEditBox:IsVisible() and type(chatEditBox.Insert) == "function" then
		chatEditBox:Insert(link)
		return true
	end

	if type(chatEditBox.Show) == "function" then chatEditBox:Show() end
	if type(chatEditBox.Insert) == "function" then
		chatEditBox:Insert(link)
	elseif type(chatEditBox.SetText) == "function" then
		chatEditBox:SetText(link)
		if type(chatEditBox.HighlightText) == "function" then
			chatEditBox:HighlightText()
		end
	end

	return true
end

-- Slash command handler (original, from backup)
MTH:RegisterSlashAliases("MTH")

local function MTH_CommandBook()
	if type(MTH_OpenHunterBook) == "function" then
		MTH_OpenHunterBook()
	elseif type(MTH_ToggleHunterBook) == "function" then
		MTH_ToggleHunterBook()
	else
		MTH:Print("Hunter Book is not available yet")
	end
end

local function MTH_CommandOptions()
	if MTH_OpenOptions then
		MTH_OpenOptions("General")
	else
		MTH:Print("Options window is not available yet")
	end
end

local function MTH_FormatAgeSeconds(seconds)
	local value = tonumber(seconds) or 0
	if value < 0 then value = 0 end
	if value < 60 then
		return tostring(math.floor(value)) .. "s"
	end
	if value < 3600 then
		return tostring(math.floor(value / 60)) .. "m"
	end
	if value < 86400 then
		return tostring(math.floor(value / 3600)) .. "h"
	end
	return tostring(math.floor(value / 86400)) .. "d"
end

local function MTH_CommandPeers()
	if not (MTH and MTH.VersionCheck and type(MTH.VersionCheck.GetTrackedPeers) == "function") then
		MTH:Print("Peer tracker is not available yet")
		return
	end

	local peers = MTH.VersionCheck:GetTrackedPeers()
	local count = table.getn(peers)
	if count <= 0 then
		MTH:Print("No MetaHunt broadcasters seen yet on LFT")
		return
	end

	MTH:Print("MetaHunt broadcasters seen on LFT: " .. tostring(count))
	local now = (type(time) == "function" and time()) or (type(GetTime) == "function" and math.floor(GetTime())) or 0
	local maxRows = math.min(count, 20)
	for i = 1, maxRows do
		local peer = peers[i]
		if type(peer) == "table" then
			local age = MTH_FormatAgeSeconds((now or 0) - (tonumber(peer.lastSeenAt) or 0))
			MTH:Print("- " .. tostring(peer.name or "?") .. " v" .. tostring(peer.versionText or "?") .. " (seen " .. tostring(age) .. " ago)")
		end
	end
	if count > maxRows then
		MTH:Print("... and " .. tostring(count - maxRows) .. " more")
	end
end

local function MTH_CommandPetSpellScanFallback()
	local getSpellName = (type(getglobal) == "function" and getglobal("GetSpellName")) or (_G and _G["GetSpellName"])
	local getSpellTexture = (type(getglobal) == "function" and getglobal("GetSpellTexture")) or (_G and _G["GetSpellTexture"])
	local isPassiveSpell = (type(getglobal) == "function" and getglobal("IsPassiveSpell")) or (_G and _G["IsPassiveSpell"])
	local bookTypePet = (type(getglobal) == "function" and getglobal("BOOKTYPE_PET")) or (_G and _G["BOOKTYPE_PET"])

	local petName = UnitName and UnitName("pet") or nil
	local pets = (type(MTH_PETS_GetRootStore) == "function") and MTH_PETS_GetRootStore() or nil
	local currentPetId = (type(pets) == "table" and type(pets.currentPet) == "table") and pets.currentPet.id or nil

	if type(getSpellName) ~= "function" or not bookTypePet then
		return false, 0
	end

	local rows = {}
	for slot = 1, 200 do
		local name, subText = getSpellName(slot, bookTypePet)
		if not name or name == "" then
			break
		end
		local rankNumber = nil
		if tostring(subText or "") ~= "" then
			local _, _, r = string.find(tostring(subText), "(%d+)")
			rankNumber = tonumber(r)
		end
		if not rankNumber then
			local _, _, r2 = string.find(tostring(name), "(%d+)")
			rankNumber = tonumber(r2)
		end
		local token = string.lower(tostring(name or ""))
		if rankNumber and rankNumber > 0 then
			token = token .. "#" .. tostring(rankNumber)
		end
		table.insert(rows, {
			slot = slot,
			name = tostring(name or ""),
			rank = rankNumber,
			icon = (type(getSpellTexture) == "function") and getSpellTexture(slot, bookTypePet) or nil,
			isPassive = (type(isPassiveSpell) == "function") and (isPassiveSpell(slot, bookTypePet) and true or false) or false,
			token = token,
		})
	end

	local count = table.getn(rows)
	if count > 0 then
		local preview = {}
		local maxPreview = math.min(6, count)
		for i = 1, maxPreview do
			local row = rows[i]
			if type(row) == "table" then
				local line = tostring(row.name or "?")
				local rank = tonumber(row.rank)
				if rank and rank > 0 then
					line = line .. " R" .. tostring(rank)
				end
				table.insert(preview, line)
			end
		end
	end

	if type(MTH_PETS_RecordCurrentPetSpellbookSnapshot) == "function" then
		local persisted, updated = MTH_PETS_RecordCurrentPetSpellbookSnapshot(rows, "petspellscan:core-fallback")
		return true, tonumber(persisted) or count
	else
		return false, count
	end
end

local function MTH_CommandFoodData(limitText)
	if type(FOM_PrintCollectedFoodData) ~= "function" then
		MTH:Print("Food data command is not available yet")
		return
	end
	local trimmed = string.gsub(tostring(limitText or ""), "^%s+", "")
	trimmed = string.gsub(trimmed, "%s+$", "")
	if string.lower(trimmed) == "purge" then
		if type(FOM_PruneCollectedFoodData) ~= "function" then
			MTH:Print("Food data purge is not available yet")
			return
		end
		local removed = tonumber(FOM_PruneCollectedFoodData()) or 0
		MTH:Print("Food data purge removed rows: " .. tostring(removed))
		return
	end
	if trimmed == "" then
		FOM_PrintCollectedFoodData(nil)
		return
	end
	local limit = tonumber(trimmed)
	if not limit then
		MTH:Print("Usage: /mth food [limit|purge]")
		return
	end
	FOM_PrintCollectedFoodData(limit)
end

if type(MTH_PS_ScanNow) ~= "function" then
	function MTH_PS_ScanNow(trigger)
		local ok, count = MTH_CommandPetSpellScanFallback()
		return ok and true or false, tonumber(count) or 0, false
	end
end

if type(MTH_PSP_RequestScan) ~= "function" then
	local mthPsFallbackLastScan = 0
	function MTH_PSP_RequestScan(trigger, minIntervalSeconds)
		local now = tonumber(time()) or 0
		local minInterval = tonumber(minIntervalSeconds) or 1
		local triggerText = tostring(trigger or "request")
		if minInterval > 0 and (now - mthPsFallbackLastScan) < minInterval then
			return false
		end
		local ok = MTH_PS_ScanNow(triggerText)
		if ok then
			mthPsFallbackLastScan = now
		end
		return ok and true or false
	end
end

if type(MTH_CommandPetSpellScan) ~= "function" then
	function MTH_CommandPetSpellScan()
		local ok, count = MTH_PS_ScanNow("manual-core-fallback")
		if not (MTH and MTH.IsMessageEnabled) or MTH:IsMessageEnabled("spellbookScan", false) then
			MTH:Print("Pet spellbook scan: " .. tostring(count or 0) .. " spell(s). ok=" .. tostring(ok and true or false))
		end
	end
end

function SlashCmdList.MTH(msg, editbox)
	if MTH and MTH.ApplyClassGate and MTH:ApplyClassGate("slash") then
		return
	end

	msg = msg or ""
	msg = string.gsub(tostring(msg), "^%s+", "")
	msg = string.gsub(msg, "%s+$", "")
	local lowerMsg = string.lower(msg)
	local _, _, lowerCmd, lowerArg = string.find(lowerMsg, "^(%S+)%s*(.-)%s*$")
	if msg == "" then
		MTH:Print("Available: /mth options, /mth book")
	elseif lowerMsg == "err" or lowerMsg == "errors" or lowerMsg == "debug" then
		if MTH_DebugFrame and MTH_DebugFrame.Toggle then
			MTH_DebugFrame:Toggle()
		else
			MTH:Print("Debug frame is not available.")
		end
	elseif lowerMsg == "options" then
		MTH_CommandOptions()
	elseif lowerMsg == "book" or lowerMsg == "hunterbook" then
		MTH_CommandBook()
	elseif lowerMsg == "peers" or lowerMsg == "who" then
		MTH_CommandPeers()
	elseif lowerMsg == "zoneinfo" then
		-- Dumps all available zone data for the current zone, for adding to ds-zones / ds-minimap-sizes
		pcall(SetMapToCurrentZone)
		local zoneName    = (type(GetRealZoneText) == "function" and GetRealZoneText()) or ""
		local subZone     = (type(GetSubZoneText)  == "function" and GetSubZoneText())  or ""
		local zoneText    = (type(GetZoneText)      == "function" and GetZoneText())     or ""
		local areaId      = nil
		if type(GetCurrentMapAreaID) == "function" then
			local ok, v = pcall(GetCurrentMapAreaID)
			if ok then areaId = v end
		end
		local cx, cy = nil, nil
		if type(GetPlayerMapPosition) == "function" then
			local ok, x, y = pcall(GetPlayerMapPosition, "player")
			if ok then cx, cy = x, y end
		end
		local contId = nil
		if type(GetCurrentMapContinent) == "function" then
			local ok, v = pcall(GetCurrentMapContinent)
			if ok then contId = v end
		end
		MTH:Print("|cffffff00=== Zone Info ===|r")
		MTH:Print("GetRealZoneText: |cffffaa00" .. tostring(zoneName) .. "|r")
		MTH:Print("GetZoneText:     |cffffaa00" .. tostring(zoneText) .. "|r")
		MTH:Print("GetSubZoneText:  |cffffaa00" .. tostring(subZone) .. "|r")
		MTH:Print("AreaID (GetCurrentMapAreaID): |cff88ffff" .. tostring(areaId) .. "|r")
		MTH:Print("ContinentID: |cff88ffff" .. tostring(contId) .. "|r")
		if cx and cy then
			MTH:Print(string.format("Player map pos: |cff88ffff%.4f, %.4f|r  (display: %.1f, %.1f)", cx, cy, cx*100, cy*100))
		end
		-- Also check if zone is in our tables
		local inZones = MTH_DS_Zones and MTH_DS_Zones[tonumber(areaId)] and "YES" or "not in MTH_DS_Zones"
		local inSizes = MTH_DS_MinimapSizes and MTH_DS_MinimapSizes[tonumber(areaId)] and "YES" or "not in ds-minimap-sizes"
		MTH:Print("MTH_DS_Zones entry:        " .. inZones)
		MTH:Print("MTH_DS_MinimapSizes entry: " .. inSizes)
	elseif lowerMsg == "npcid" then
		-- Print the creature entry ID of the current target, or arm a listener for next NPC interaction
		local function MTH_ParseCreatureEntryFromAnyGuid(guid)
			if type(guid) ~= "string" or guid == "" then return nil end
			-- Format 1: TBC-style "Creature-realm-map-inst-?-ENTRY-spawn"
			local _, _, id1 = string.find(guid, "^Creature%-%d+%-%d+%-%d+%-%d+%-(%d+)%-%d+$")
			if id1 then return tonumber(id1) end
			-- Format 2: vanilla hex "0xF130EEEEEECCCCCC" — entry is bits 24-47 = hex chars 7-12
			if string.sub(guid, 1, 2) == "0x" and string.len(guid) >= 14 then
				local entryHex = string.sub(guid, 7, 12)  -- 24 bits = up to 16M
				local parsed = tonumber(entryHex, 16)
				if parsed and parsed > 0 then return parsed end
			end
			return nil
		end

		local function MTH_PrintNpcId(unitToken)
			unitToken = unitToken or "target"
			local name  = (type(UnitName)  == "function") and UnitName(unitToken)  or "?"
			local level = (type(UnitLevel) == "function") and UnitLevel(unitToken) or "?"
			-- Try UnitGUID first, then GetUnitGUID (TurtleWoW nameplate API)
			local guid = nil
			if type(UnitGUID) == "function" then
				local ok, g = pcall(UnitGUID, unitToken)
				if ok and g and g ~= "" then guid = g end
			end
			if (not guid or guid == "") and type(GetUnitGUID) == "function" then
				local ok, g = pcall(GetUnitGUID, unitToken)
				if ok and g and g ~= "" then guid = g end
			end
			local creatureId = MTH_ParseCreatureEntryFromAnyGuid(guid)
			if creatureId then
				MTH:Print(string.format("|cffffff00NPC:|r %s  |cffffff00ID:|r |cff88ffff%s|r  lvl: %s", tostring(name), tostring(creatureId), tostring(level)))
			else
				MTH:Print(string.format("|cffffff00NPC:|r %s  lvl: %s  |cffff8800GUID: %s|r", tostring(name), tostring(level), tostring(guid or "nil")))
				MTH:Print("|cffaaaaaa(Could not parse creature ID from GUID)|r")
			end
		end

		-- Try current target first
		local hasTarget = (type(UnitExists) == "function") and UnitExists("target")
		if hasTarget then
			MTH_PrintNpcId("target")
		end

		-- Arm a one-shot frame for MERCHANT_SHOW / TRAINER_LIST_UPDATE / GOSSIP_SHOW
		if not _G["MTH_NpcIdListenerFrame"] then
			local f = CreateFrame("Frame", "MTH_NpcIdListenerFrame")
			f:RegisterEvent("MERCHANT_SHOW")
			f:RegisterEvent("TRAINER_LIST_UPDATE")
			f:RegisterEvent("GOSSIP_SHOW")
			f:SetScript("OnEvent", function()
				MTH_PrintNpcId("target")
				this:UnregisterEvent("MERCHANT_SHOW")
				this:UnregisterEvent("TRAINER_LIST_UPDATE")
				this:UnregisterEvent("GOSSIP_SHOW")
				_G["MTH_NpcIdListenerFrame"] = nil
			end)
			if not hasTarget then
				MTH:Print("|cffaaffaaArmed.|r Open any vendor, trainer, or stable master to capture their ID.")
			end
		end
	elseif lowerCmd == "bls" then
		if lowerArg == "reset" then
			if type(MTH_SavedVariables) == "table" then
				MTH_SavedVariables.beastLoreScan = { entries = {} }
			end
			MTH:Print("|cffff4444Beast Lore scan data wiped.|r All recorded beasts cleared.")
		else
			MTH:Print("Beast Lore Scan: |cffffff00/mth bls reset|r — wipe all recorded beast data")
		end
	else
		MTH:Print("Unknown command: " .. tostring(msg))
		MTH:Print("Available: /mth options, /mth book, /mth npcid, /mth bls reset")
	end
end

-- Initialize on load
MTH:InitSavedVariables()
if type(MTH_ST_InitBootstrap) == "function" then
	MTH_ST_InitBootstrap()
end
if type(MTH_TR_InitBootstrap) == "function" then
	MTH_TR_InitBootstrap()
elseif type(MTH_PT_InitBootstrap) == "function" then
	MTH_PT_InitBootstrap()
end
if type(MTH_PS_InitService) == "function" then
	MTH_PS_InitService()
end
