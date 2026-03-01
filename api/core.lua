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

local MTH_ItemLinkCacheTooltip = nil

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

	if not MTH_ItemLinkCacheTooltip then
		MTH_ItemLinkCacheTooltip = CreateFrame("GameTooltip", "MTH_ItemLinkCacheTooltip", UIParent, "GameTooltipTemplate")
		if not MTH_ItemLinkCacheTooltip then return false end
		MTH_ItemLinkCacheTooltip:SetOwner(UIParent, "ANCHOR_NONE")
	end

	MTH_ItemLinkCacheTooltip:ClearLines()
	MTH_ItemLinkCacheTooltip:SetHyperlink("item:" .. tostring(id) .. ":0:0:0")
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
	if msg == "" then
		MTH:Print("Available: /mth options, /mth book")
	elseif lowerMsg == "options" then
		MTH_CommandOptions()
	elseif lowerMsg == "book" or lowerMsg == "hunterbook" then
		MTH_CommandBook()
	elseif lowerMsg == "peers" or lowerMsg == "who" then
		MTH_CommandPeers()
	elseif lowerMsg == "err" then
		if MTH_DebugFrame and type(MTH_DebugFrame.Toggle) == "function" then
			MTH_DebugFrame:Toggle()
		else
			MTH:Print("Debug frame is not available yet")
		end
	else
		MTH:Print("Unknown command: " .. tostring(msg))
		MTH:Print("Available: /mth options, /mth book")
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
