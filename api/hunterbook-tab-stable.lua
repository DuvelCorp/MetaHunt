if type(MTH_HUNTERBOOK_TABS) ~= "table" then MTH_HUNTERBOOK_TABS = {} end

MTH_HUNTERBOOK_TABS.stable = {
	headerLabel = "Stable",
	columnLabels = { "Pet ID", "Slot", "Name", "Family", "Lvl", "Loyalty", "Seen" },
	columnLayout = {
		{ x = 8, width = 78, align = "LEFT" },
		{ x = 88, width = 34, align = "LEFT" },
		{ x = 124, width = 118, align = "LEFT" },
		{ x = 244, width = 92, align = "LEFT" },
		{ x = 338, width = 34, align = "LEFT" },
		{ x = 374, width = 114, align = "LEFT" },
		{ x = 490, width = 52, align = "LEFT" },
	},
}

function MTH_BOOK_GetLoyaltyHeaderText(loyaltyValue)
	local text = tostring(loyaltyValue or "")
	text = string.gsub(text, "^%s+", "")
	text = string.gsub(text, "%s+$", "")
	if text == "" then
		return "-"
	end

	local closePos = string.find(text, "%)")
	if closePos and closePos < string.len(text) then
		local tail = string.sub(text, closePos + 1)
		tail = string.gsub(tail, "^%s+", "")
		tail = string.gsub(tail, "%s+$", "")
		if tail ~= "" then
			return tail
		end
	end

	return text
end

local function MTH_BOOK_GetLoyaltyNameByLevel(level)
	level = tonumber(level)
	if not level then
		return nil
	end
	local names = {
		[1] = "Rebellious",
		[2] = "Unruly",
		[3] = "Submissive",
		[4] = "Dependable",
		[5] = "Faithful",
		[6] = "Best Friend",
	}
	local globalName = _G and _G["PET_LOYALTY" .. tostring(level)] or nil
	if type(globalName) == "string" and globalName ~= "" then
		return globalName
	end
	return names[level]
end

function MTH_BOOK_CountPetAbilitiesMap(map)
	if type(map) ~= "table" then return 0 end
	local total = 0
	for _ in pairs(map) do
		total = total + 1
	end
	return total
end

function MTH_BOOK_GetStableAbilitySummary(map)
	if type(map) ~= "table" then return "-" end
	local entries = {}
	for _, ability in pairs(map) do
		if type(ability) == "table" then
			local nameText = tostring(ability.name or "")
			local rankValue = tonumber(ability.rank)
			if nameText ~= "" then
				if rankValue and rankValue > 0 then
					table.insert(entries, nameText .. " R" .. tostring(rankValue))
				else
					table.insert(entries, nameText)
				end
			end
		end
	end
	table.sort(entries)
	if table.getn(entries) == 0 then return "-" end
	return table.concat(entries, ", ")
end

function MTH_BOOK_GetStablePetSpellbookSummary(spellbook)
	if type(spellbook) ~= "table" or type(spellbook.spells) ~= "table" then
		return "Abilities (-)"
	end

	local entries = {}
	for i = 1, table.getn(spellbook.spells) do
		local spell = spellbook.spells[i]
		if type(spell) == "table" and tostring(spell.name or "") ~= "" then
			local line = tostring(spell.name)
			local rankValue = tonumber(spell.rank)
			if rankValue and rankValue > 0 then
				line = line .. " R" .. tostring(rankValue)
			end
			if spell.isPassive then
				line = line .. " (P)"
			end
			table.insert(entries, line)
		end
	end

	if table.getn(entries) == 0 then
		return "Abilities (0)"
	end

	return "Abilities (" .. tostring(table.getn(entries)) .. ")\n" .. table.concat(entries, "\n")
end

function MTH_BOOK_NormalizeAbilityDisplayName(nameText)
	local name = tostring(nameText or "")
	name = string.gsub(name, "^%s+", "")
	name = string.gsub(name, "%s+$", "")
	name = string.gsub(name, "%s+[Rr]ank%s+%d+", "")
	name = string.gsub(name, "%s*%([^%)]*[Rr]ank%s*%d+[^%)]*%)", "")
	name = string.gsub(name, "%s+$", "")
	return name
end

function MTH_BOOK_IsResistanceAbilityName(nameText)
	local name = string.lower(tostring(nameText or ""))
	if name == "" then return false end
	if string.find(name, "resistance", 1, true) then
		return true
	end
	if name == "arcane resistance" or name == "nature resistance" or name == "fire resistance" or name == "frost resistance" or name == "shadow resistance" then
		return true
	end
	return false
end

function MTH_BOOK_GetResistanceShortName(nameText)
	local lowerName = string.lower(tostring(nameText or ""))
	if string.find(lowerName, "arcane", 1, true) then return "AR" end
	if string.find(lowerName, "nature", 1, true) then return "NR" end
	if string.find(lowerName, "fire", 1, true) then return "FR" end
	if string.find(lowerName, "frost", 1, true) then return "FR" end
	if string.find(lowerName, "shadow", 1, true) then return "SR" end
	return tostring(nameText or "-")
end

function MTH_BOOK_FindPetAbilityDSRow(abilityName, rankNumber)
	if not (MTH_DS_PetSpells and type(MTH_DS_PetSpells.byAbility) == "table") then
		return nil
	end
	local normalized = MTH_BOOK_NormalizeAbilityDisplayName(abilityName)
	if normalized == "" then
		return nil
	end

	local bundle = MTH_DS_PetSpells.byAbility[normalized]
	if type(bundle) ~= "table" then
		for candidateName, candidateBundle in pairs(MTH_DS_PetSpells.byAbility) do
			if string.lower(tostring(candidateName or "")) == string.lower(normalized) then
				bundle = candidateBundle
				break
			end
		end
	end
	if type(bundle) ~= "table" or type(bundle.spells) ~= "table" then
		return nil
	end

	local wantedRank = tonumber(rankNumber)
	if wantedRank and wantedRank > 0 then
		for i = 1, table.getn(bundle.spells) do
			local row = bundle.spells[i]
			if type(row) == "table" and tonumber(row.rankNumber) == wantedRank then
				return row
			end
		end
	end

	return bundle.spells[1]
end

function MTH_BOOK_BuildStablePetAbilityEntries(row)
	if type(row) ~= "table" then
		return {}, {}
	end

	local source = {}
	if type(row.petSpellbook) == "table" and type(row.petSpellbook.spells) == "table" and table.getn(row.petSpellbook.spells) > 0 then
		source = row.petSpellbook.spells
	elseif type(row.abilities) == "table" then
		local i = 0
		for _, ability in pairs(row.abilities) do
			if type(ability) == "table" and tostring(ability.name or "") ~= "" then
				i = i + 1
				source[i] = {
					name = tostring(ability.name or ""),
					rank = tonumber(ability.rank),
					icon = ability.icon,
				}
			end
		end
	end

	local sourceCount = table.getn(source)
	if sourceCount == 0 then
		return {}, {}
	end

	local hideAvoidance = sourceCount > 8
	local leftEntries = {}
	local rightEntries = {}

	for i = 1, sourceCount do
		local spell = source[i]
		if type(spell) == "table" and tostring(spell.name or "") ~= "" then
			local fullName = MTH_BOOK_NormalizeAbilityDisplayName(spell.name)
			if fullName ~= "" then
				local isAvoidance = string.lower(fullName) == "avoidance"
				if not (hideAvoidance and isAvoidance) then
					local rankNumber = tonumber(spell.rank)
					local dsRow = MTH_BOOK_FindPetAbilityDSRow(fullName, rankNumber)
					local icon = (dsRow and dsRow.icon) or spell.icon
					local description = (dsRow and dsRow.description) or ""
					local displayName = fullName
					if MTH_BOOK_IsResistanceAbilityName(fullName) then
						displayName = MTH_BOOK_GetResistanceShortName(fullName)
					end
					if rankNumber and rankNumber > 0 then
						displayName = displayName .. " R" .. tostring(rankNumber)
					end

					local entry = {
						name = fullName,
						display = displayName,
						rank = rankNumber,
						description = tostring(description or ""),
						icon = icon,
					}

					if MTH_BOOK_IsResistanceAbilityName(fullName) then
						table.insert(rightEntries, entry)
					else
						table.insert(leftEntries, entry)
					end
				end
			end
		end
	end

	return leftEntries, rightEntries
end

MTH_BOOK_ShowStableAbilityTooltip = function(anchor, entry)
	if not anchor or type(entry) ~= "table" then return end
	local tooltip = MTH_BOOK_GetSpellTooltip()
	if not tooltip then return end

	tooltip:SetOwner(anchor, "ANCHOR_RIGHT")
	tooltip:ClearLines()
	MTH_BOOK_SetSpellTooltipIcon(tooltip, entry.icon)
	tooltip:AddLine(tostring(entry.name or "Unknown"), 1.00, 0.82, 0.00)
	if tonumber(entry.rank) and tonumber(entry.rank) > 0 then
		tooltip:AddLine("Rank " .. tostring(entry.rank), 0.85, 0.85, 0.85)
	end
	if entry.description and entry.description ~= "" then
		tooltip:AddLine(" ")
		tooltip:AddLine(tostring(entry.description), 0.90, 0.90, 0.90, true)
	end
	tooltip:Show()
end

function MTH_BOOK_GetContextSummary(context)
	if type(context) ~= "table" then
		return "-"
	end
	local parts = {}
	if context.zone and context.zone ~= "" then table.insert(parts, tostring(context.zone)) end
	if context.subZone and context.subZone ~= "" then table.insert(parts, tostring(context.subZone)) end
	if context.x and context.y then
		table.insert(parts, string.format("%.2f,%.2f", tonumber(context.x) or 0, tonumber(context.y) or 0))
	elseif context.coordinate and context.coordinate ~= "" then
		table.insert(parts, tostring(context.coordinate))
	end
	if context.hunterLevel then table.insert(parts, "L" .. tostring(context.hunterLevel)) end
	if context.timestamp then table.insert(parts, "t=" .. tostring(context.timestamp)) end
	if table.getn(parts) == 0 then return "-" end
	return table.concat(parts, " | ")
end

function MTH_BOOK_FormatTimestamp(timestamp)
	local value = tonumber(timestamp)
	if not value or value <= 0 then return "-" end
	if type(date) ~= "function" then return tostring(value) end
	return date("%Y-%m-%d %H:%M:%S", value)
end

function MTH_BOOK_FormatElapsedFromTimestamp(timestamp)
	local value = tonumber(timestamp)
	if not value or value <= 0 then return "-" end
	local now = tonumber(time()) or 0
	local elapsed = now - value
	if elapsed < 0 then elapsed = 0 end
	local days = math.floor(elapsed / 86400)
	local elapsedAfterDays = elapsed - (days * 86400)
	local hours = math.floor(elapsedAfterDays / 3600)
	local elapsedAfterHours = elapsedAfterDays - (hours * 3600)
	local mins = math.floor(elapsedAfterHours / 60)
	if days > 0 then
		return tostring(days) .. "d " .. tostring(hours) .. "h"
	end
	if hours > 0 then
		return tostring(hours) .. "h " .. tostring(mins) .. "m"
	end
	return tostring(mins) .. "m"
end

local function MTH_BOOK_FormatElapsedStableInfo(timestamp)
	local value = tonumber(timestamp)
	if not value or value <= 0 then return "-" end
	local now = tonumber(time()) or 0
	local elapsed = now - value
	if elapsed < 0 then elapsed = 0 end
	local days = math.floor(elapsed / 86400)
	local remAfterDays = elapsed - (days * 86400)
	local hours = math.floor(remAfterDays / 3600)
	local remAfterHours = remAfterDays - (hours * 3600)
	local mins = math.floor(remAfterHours / 60)
	if days > 0 then
		if hours > 0 then
			return tostring(days) .. " days " .. tostring(hours) .. " hours"
		end
		return tostring(days) .. " days"
	end
	if hours > 0 then
		if mins > 0 then
			return tostring(hours) .. " hours " .. tostring(mins) .. " minutes"
		end
		return tostring(hours) .. " hours"
	end
	return tostring(mins) .. " minutes"
end

local function MTH_BOOK_NormalizeMapCoordValue(value)
	local numeric = tonumber(value)
	if not numeric then
		return nil
	end
	if numeric > 0 and numeric <= 1 then
		return numeric * 100
	end
	return numeric
end

local function MTH_BOOK_StableDetailKV(title, value)
	local key = tostring(title or "")
	if key == "" then
		return tostring(value or "-")
	end
	return "|cff9a9a9a" .. key .. " :|r " .. tostring(value or "-")
end

local function MTH_BOOK_EnsureStableColumnLines(card, fieldName, lineCount)
	if type(card[fieldName]) ~= "table" then
		card[fieldName] = {}
	end
	for i = 1, lineCount do
		if not card[fieldName][i] then
			local fs = card:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
			fs:SetJustifyH("LEFT")
			fs:SetJustifyV("TOP")
			fs:SetTextColor(1.00, 1.00, 1.00)
			if fs.SetWordWrap then fs:SetWordWrap(false) end
			if fs.SetNonSpaceWrap then fs:SetNonSpaceWrap(false) end
			if fs.SetMaxLines then fs:SetMaxLines(1) end
			card[fieldName][i] = fs
		end
	end
	return card[fieldName]
end

local function MTH_BOOK_ResolveStableTameZoneId(zoneName, beast, tameX, tameY)
	local normalizedZone = MTH_BOOK_NormalizeZoneLookupName and MTH_BOOK_NormalizeZoneLookupName(zoneName) or ""
	if zoneName and zoneName ~= "" and MTH_Map and type(MTH_Map.GetMapIDByName) == "function" then
		local mapped = MTH_Map:GetMapIDByName(zoneName)
		if mapped then
			return tonumber(mapped) or mapped
		end
	end

	if normalizedZone ~= "" and type(MTH_DS_Zones) == "table" then
		for zoneId, zoneRow in pairs(MTH_DS_Zones) do
			if type(zoneRow) == "table" and type(zoneRow.names) == "table" then
				for _, zoneValue in pairs(zoneRow.names) do
					if MTH_BOOK_NormalizeZoneLookupName and MTH_BOOK_NormalizeZoneLookupName(zoneValue) == normalizedZone then
						return tonumber(zoneId) or zoneId
					end
				end
			end
		end
	end

	if type(beast) == "table" and type(beast.coords) == "table" and table.getn(beast.coords) > 0 then
		local bestZoneId = nil
		local bestDistance = nil
		for i = 1, table.getn(beast.coords) do
			local c = beast.coords[i]
			if c and c[3] then
				local zid = tonumber(c[3])
				if zid and not bestZoneId then
					bestZoneId = zid
				end
				if zid and tameX and tameY then
					local cx = tonumber(c[1])
					local cy = tonumber(c[2])
					if cx and cy then
						local dx = cx - tameX
						local dy = cy - tameY
						local dist = (dx * dx) + (dy * dy)
						if not bestDistance or dist < bestDistance then
							bestDistance = dist
							bestZoneId = zid
						end
					end
				end
			end
		end
		if bestZoneId then
			return bestZoneId
		end
	end

	return nil
end

local MTH_BOOK_NormalizeStableFoodLink

local function MTH_BOOK_GetStableFeedSummary(petId)
	local totalFed = 0
	local topFoods = {}
	if type(MTH_FEED_GetPetFeedStats) ~= "function" then
		return totalFed, topFoods
	end

	local stats = MTH_FEED_GetPetFeedStats(petId)
	if type(stats) ~= "table" then
		return totalFed, topFoods
	end

	totalFed = tonumber(stats.totals and stats.totals.accepted) or 0
	if totalFed < 0 then totalFed = 0 end

	local recentNameByItemId = {}
	if type(stats.recent) == "table" then
		for i = 1, table.getn(stats.recent) do
			local recent = stats.recent[i]
			if type(recent) == "table" then
				local itemId = tonumber(recent.itemId)
				local itemName = tostring(recent.itemName or "")
				if itemId and itemName ~= "" and recentNameByItemId[itemId] == nil then
					recentNameByItemId[itemId] = itemName
				end
			end
		end
	end

	if type(stats.byItemId) == "table" then
		for key, itemRow in pairs(stats.byItemId) do
			local acceptedCount = tonumber(type(itemRow) == "table" and itemRow.accepted) or 0
			local itemId = tonumber(key)
			if acceptedCount > 0 and itemId then
				local itemName = type(itemRow) == "table" and tostring(itemRow.itemName or "") or ""
				local itemLink = type(itemRow) == "table" and tostring(itemRow.itemLink or "") or ""
				itemLink = MTH_BOOK_NormalizeStableFoodLink(itemId, itemLink, itemName)
				local itemTexture = type(itemRow) == "table" and itemRow.itemIcon or nil
				if type(MTH_PrimeItemCache) == "function" then
					MTH_PrimeItemCache(itemId)
				end
				if type(GetItemInfo) == "function" then
					local infoName, infoLink, _, _, _, _, _, _, _, infoTexture = GetItemInfo(itemId)
					if (not itemName or itemName == "") and infoName and infoName ~= "" then
						itemName = infoName
					end
					if (not itemLink or itemLink == "") and infoLink and infoLink ~= "" then
						itemLink = infoLink
					end
					if (not itemTexture or itemTexture == "") and infoTexture and infoTexture ~= "" then
						itemTexture = infoTexture
					end
					if (not itemTexture or itemTexture == "") and itemLink and itemLink ~= "" then
						local _, _, _, _, _, _, _, _, _, linkTexture = GetItemInfo(itemLink)
						if linkTexture and linkTexture ~= "" then
							itemTexture = linkTexture
						end
					end
				end
				if (not itemName or itemName == "") and recentNameByItemId[itemId] then
					itemName = recentNameByItemId[itemId]
				end
				itemLink = MTH_BOOK_NormalizeStableFoodLink(itemId, itemLink, itemName)
				if not itemName or itemName == "" then
					itemName = "Item " .. tostring(itemId)
				end
				table.insert(topFoods, {
					itemId = itemId,
					name = itemName,
					link = itemLink,
					icon = itemTexture or (type(GetItemIcon) == "function" and GetItemIcon(itemId) or nil),
					count = acceptedCount,
				})
			end
		end
	end

	table.sort(topFoods, function(a, b)
		if a.count ~= b.count then
			return a.count > b.count
		end
		return tostring(a.name or "") < tostring(b.name or "")
	end)

	while table.getn(topFoods) > 3 do
		table.remove(topFoods)
	end

	return totalFed, topFoods
end

MTH_BOOK_NormalizeStableFoodLink = function(itemId, itemLink, itemName)
	local link = tostring(itemLink or "")
	if link ~= "" then
		if string.find(link, "|Hitem:", 1, true) or string.find(link, "^item:%d+") then
			return link
		end
	end

	local numericItemId = tonumber(itemId)
	if numericItemId and type(MTH_GetClickableItemLink) == "function" then
		local clickable = MTH_GetClickableItemLink(numericItemId, itemName, false)
		if clickable and clickable ~= "" then
			return tostring(clickable)
		end
	end
	if numericItemId then
		return "item:" .. tostring(numericItemId) .. ":0:0:0"
	end
	return nil
end

local function MTH_BOOK_ResolveStableFoodIcon(itemId, iconHint, itemName, itemLink)
	local linkText = tostring(itemLink or "")
	local linkItemId = nil
	if linkText ~= "" then
		local _, _, parsedId = string.find(linkText, "item:(%d+)")
		if parsedId then
			linkItemId = tonumber(parsedId)
		end
	end

	local numericItemId = tonumber(itemId) or linkItemId

	if linkText ~= "" and type(GetItemInfo) == "function" then
		local _, _, _, _, _, _, _, _, _, linkTexture = GetItemInfo(linkText)
		if linkTexture and linkTexture ~= "" then
			if type(linkTexture) == "number" then
				return linkTexture
			end
			if string.find(tostring(linkTexture), "\\", 1, true) then
				return tostring(linkTexture)
			end
			local asNumber = tonumber(tostring(linkTexture))
			if asNumber then
				return asNumber
			end
			return "Interface\\Icons\\" .. tostring(linkTexture)
		end
	end

	if type(iconHint) == "number" then
		return iconHint
	end

	local iconHintText = tostring(iconHint or "")
	if iconHintText ~= "" then
		local numericHint = tonumber(iconHintText)
		if numericHint then
			return numericHint
		end
	end

	local iconPath = iconHintText
	if iconPath ~= "" then
		if string.find(iconPath, "\\", 1, true) then
			return iconPath
		end
		return "Interface\\Icons\\" .. iconPath
	end

	if numericItemId and type(GetItemInfo) == "function" then
		local _, _, _, _, _, _, _, _, _, infoTexture = GetItemInfo(numericItemId)
		if infoTexture and infoTexture ~= "" then
			if type(infoTexture) == "number" then
				return infoTexture
			end
			if string.find(tostring(infoTexture), "\\", 1, true) then
				return tostring(infoTexture)
			end
			local asNumber = tonumber(tostring(infoTexture))
			if asNumber then
				return asNumber
			end
			return "Interface\\Icons\\" .. tostring(infoTexture)
		end
	end

	if numericItemId and type(GetItemIcon) == "function" then
		local directIcon = GetItemIcon(numericItemId)
		if directIcon and directIcon ~= "" then
			if type(directIcon) == "number" then
				return directIcon
			end
			if string.find(tostring(directIcon), "\\", 1, true) then
				return tostring(directIcon)
			end
			local asNumber = tonumber(tostring(directIcon))
			if asNumber then
				return asNumber
			end
			return "Interface\\Icons\\" .. tostring(directIcon)
		end
	end

	if itemName and itemName ~= "" and type(GetItemIcon) == "function" then
		local namedIcon = GetItemIcon(itemName)
		if namedIcon and namedIcon ~= "" then
			if type(namedIcon) == "number" then
				return namedIcon
			end
			if string.find(tostring(namedIcon), "\\", 1, true) then
				return tostring(namedIcon)
			end
			local asNumber = tonumber(tostring(namedIcon))
			if asNumber then
				return asNumber
			end
			return "Interface\\Icons\\" .. tostring(namedIcon)
		end
	end

	if numericItemId and type(MTH_DS_Items) == "table" and type(MTH_DS_Items[numericItemId]) == "table" then
		local dsIcon = tostring(MTH_DS_Items[numericItemId].icon or "")
		if dsIcon ~= "" then
			if string.find(dsIcon, "\\", 1, true) then
				return dsIcon
			end
			return "Interface\\Icons\\" .. dsIcon
		end
	end

	return nil
end

local function MTH_BOOK_UpdateStableFoodRowIcon(foodRow)
	if not foodRow or not foodRow.icon then
		return
	end
	local texturePath = MTH_BOOK_ResolveStableFoodIcon(foodRow.itemId, foodRow.iconHint, foodRow.itemName, foodRow.itemLink)
	if texturePath and texturePath ~= "" then
		foodRow.icon:SetTexture(texturePath)
	else
		foodRow.icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
	end
end

function MTH_BOOK_GetLoyaltyLevel(loyaltyValue)
	local text = tostring(loyaltyValue or "")
	local _, _, levelText = string.find(text, "[Ll]oyalty%s*[Ll]evel%s*(%d+)")
	local level = tonumber(levelText)
	if level then
		return level
	end

	if tonumber(loyaltyValue) then
		local numeric = tonumber(loyaltyValue)
		if numeric and numeric >= 1 and numeric <= 6 then
			return numeric
		end
	end

	return nil
end

function MTH_BOOK_GetLoyaltyHeaderColor(loyaltyValue)
	local level = MTH_BOOK_GetLoyaltyLevel(loyaltyValue)
	if not level then
		return 0.84, 0.84, 0.84
	end
	if level < 1 then level = 1 end
	if level > 6 then level = 6 end
	local t = (level - 1) / 5
	local red = 1 - t
	local green = t
	return red, green, 0
end

function MTH_BOOK_GetVisibleStableSlotCount()
	local maxStableSlots = 4
	local detected = nil

	if type(MTH_PETS_GetRootStore) == "function" then
		local pets = MTH_PETS_GetRootStore()
		if type(pets) == "table" and type(pets.stableScan) == "table" then
			detected = tonumber(pets.stableScan.slotCount)
		end
	end

	local getNumStableSlots = nil
	if type(getglobal) == "function" then
		getNumStableSlots = getglobal("GetNumStableSlots")
	end
	if (not detected or detected < 0) and type(getNumStableSlots) == "function" then
		detected = tonumber(getNumStableSlots())
	end

	if detected and detected >= 0 then
		if detected > 4 then detected = 4 end
		maxStableSlots = detected
	end

	if maxStableSlots < 0 then maxStableSlots = 0 end
	return maxStableSlots
end

function MTH_BOOK_GetStableRenderCardCount(maxCards)
	local cards = 1 + MTH_BOOK_GetVisibleStableSlotCount()
	if cards < 1 then cards = 1 end
	if maxCards and cards > maxCards then cards = maxCards end
	return cards
end

function MTH_BOOK_GetStableRenderCardHeight(frameHeight, cardCount, topPad, bottomPad, bigGap, smallGap)
	local usable = frameHeight - topPad - bottomPad
	local gapCount = cardCount - 1
	if gapCount > 0 then
		usable = usable - bigGap - (smallGap * (gapCount - 1))
	end
	local cardHeight = math.floor(usable / cardCount)
	if cardHeight < 70 then cardHeight = 70 end
	return cardHeight
end

function MTH_BOOKTAB_StableSort(a, b)
	local store = MTH_BOOK_GetPetDatastore()
	local ra = MTH_BOOK_GetPetStoreRow(a)
	local rb = MTH_BOOK_GetPetStoreRow(b)
	if not ra and not rb then return tostring(a) < tostring(b) end
	if not ra then return false end
	if not rb then return true end
	local slotA = MTH_BOOK_GetStableDisplaySlot(a, ra, store) or 9999
	local slotB = MTH_BOOK_GetStableDisplaySlot(b, rb, store) or 9999
	if slotA ~= slotB then return slotA < slotB end
	local nameA = MTH_BOOK_SafeLower(ra.name)
	local nameB = MTH_BOOK_SafeLower(rb.name)
	if nameA ~= nameB then return nameA < nameB end
	return tostring(a) < tostring(b)
end

function MTH_BOOKTAB_EnsureStableUI()
	if MTH_BOOK_STATE.stableUI then return end
	local listParent = getglobal("MTH_BOOK_ListBackdrop")
	local parent = listParent
	local parentSource = "ListBackdrop"
	if not parent then
		parent = getglobal("MTH_BOOK_TopAreaBackdrop")
		parentSource = "TopAreaBackdrop"
	end
	if not parent and listParent and listParent.GetParent then
		parent = listParent:GetParent()
		parentSource = "ListBackdropParent"
	end
	if not parent then
		parent = MTH_BOOK_Browser
		parentSource = "Browser"
	end
	if not parent then
		MTH_BOOK_DebugTrace("EnsureStableUI failed: no parent")
		return
	end
	MTH_BOOK_DebugTrace("EnsureStableUI parent=" .. tostring(parentSource) .. " name=" .. tostring(parent.GetName and parent:GetName() or "<anon>"))

	local ui = {}
	ui.frame = CreateFrame("Frame", nil, parent)
	ui.frame:SetPoint("TOPLEFT", parent, "TOPLEFT", 4, -4)
	ui.frame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -4, 4)
	ui.frame:SetFrameStrata("DIALOG")
	if parent.GetFrameLevel and ui.frame.SetFrameLevel then
		ui.frame:SetFrameLevel(parent:GetFrameLevel() + 5)
	end
	ui.frame:SetAlpha(1)
	ui.frame:Hide()

	ui.cards = {}
	for i = 1, 5 do
		local card = CreateFrame("Button", nil, ui.frame)
		card:SetFrameStrata("DIALOG")
		card:SetFrameLevel((ui.frame.GetFrameLevel and ui.frame:GetFrameLevel() or 1) + 1)
		card:SetAlpha(1)

		card.bg = card:CreateTexture(nil, "BACKGROUND")
		card.bg:SetAllPoints(card)
		card.bg:SetTexture("Interface\\Buttons\\WHITE8X8")
		card.bg:SetVertexColor(0.08, 0.08, 0.08, 0.72)

		card.borderTop = card:CreateTexture(nil, "BORDER")
		card.borderTop:SetTexture("Interface\\Buttons\\WHITE8X8")
		card.borderTop:SetVertexColor(0.35, 0.35, 0.35, 0.75)
		card.borderTop:SetPoint("TOPLEFT", card, "TOPLEFT", 0, 0)
		card.borderTop:SetPoint("TOPRIGHT", card, "TOPRIGHT", 0, 0)
		card.borderTop:SetHeight(1)

		card.borderBottom = card:CreateTexture(nil, "BORDER")
		card.borderBottom:SetTexture("Interface\\Buttons\\WHITE8X8")
		card.borderBottom:SetVertexColor(0.35, 0.35, 0.35, 0.75)
		card.borderBottom:SetPoint("BOTTOMLEFT", card, "BOTTOMLEFT", 0, 0)
		card.borderBottom:SetPoint("BOTTOMRIGHT", card, "BOTTOMRIGHT", 0, 0)
		card.borderBottom:SetHeight(1)

		card.icon = card:CreateTexture(nil, "ARTWORK")
		card.icon:SetPoint("TOPLEFT", card, "TOPLEFT", 12, -10)
		card.icon:SetWidth(44)
		card.icon:SetHeight(44)
		card.icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")

		card.name = card:CreateFontString(nil, "ARTWORK", "GameFontHighlightLarge")
		card.name:SetPoint("TOPLEFT", card.icon, "TOPRIGHT", 10, 2)
		card.name:SetPoint("TOPRIGHT", card, "TOPRIGHT", -10, -8)
		card.name:SetJustifyH("LEFT")
		card.name:SetTextColor(1.00, 0.82, 0.00)

		card.meta = card:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
		card.meta:SetPoint("TOPLEFT", card.icon, "TOPRIGHT", 10, -18)
		card.meta:SetPoint("TOPRIGHT", card, "TOPRIGHT", -10, -24)
		card.meta:SetJustifyH("LEFT")
		card.meta:SetJustifyV("TOP")

		card.metaLoyalty = card:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
		card.metaLoyalty:SetJustifyH("LEFT")
		card.metaLoyalty:SetJustifyV("TOP")
		card.metaLoyalty:SetTextColor(0.84, 0.84, 0.84)
		do
			local fontName, fontHeight, fontFlags = card.meta:GetFont()
			if fontName then
				local loyaltySize = fontHeight
				if loyaltySize and loyaltySize > 6 then
					loyaltySize = loyaltySize - 1
				end
				card.metaLoyalty:SetFont(fontName, loyaltySize, fontFlags)
			end
		end

		card.headerXpBar = CreateFrame("StatusBar", nil, card)
		card.headerXpBar:SetFrameLevel((card.GetFrameLevel and card:GetFrameLevel() or 1) + 2)
		card.headerXpBar:SetStatusBarTexture("Interface\\Buttons\\WHITE8X8")
		card.headerXpBar:SetStatusBarColor(0.22, 0.62, 0.96, 0.95)
		card.headerXpBar:SetMinMaxValues(0, 1)
		card.headerXpBar:SetValue(0)
		card.headerXpBar:Hide()
		card.headerXpBarBg = card.headerXpBar:CreateTexture(nil, "BACKGROUND")
		card.headerXpBarBg:SetAllPoints(card.headerXpBar)
		card.headerXpBarBg:SetTexture("Interface\\Buttons\\WHITE8X8")
		card.headerXpBarBg:SetVertexColor(0.22, 0.22, 0.22, 0.95)
		card.headerXpBarBorderTop = card.headerXpBar:CreateTexture(nil, "BORDER")
		card.headerXpBarBorderTop:SetTexture("Interface\\Buttons\\WHITE8X8")
		card.headerXpBarBorderTop:SetVertexColor(0.45, 0.45, 0.45, 0.85)
		card.headerXpBarBorderTop:SetPoint("TOPLEFT", card.headerXpBar, "TOPLEFT", 0, 0)
		card.headerXpBarBorderTop:SetPoint("TOPRIGHT", card.headerXpBar, "TOPRIGHT", 0, 0)
		card.headerXpBarBorderTop:SetHeight(1)
		card.headerXpBarBorderBottom = card.headerXpBar:CreateTexture(nil, "BORDER")
		card.headerXpBarBorderBottom:SetTexture("Interface\\Buttons\\WHITE8X8")
		card.headerXpBarBorderBottom:SetVertexColor(0.45, 0.45, 0.45, 0.85)
		card.headerXpBarBorderBottom:SetPoint("BOTTOMLEFT", card.headerXpBar, "BOTTOMLEFT", 0, 0)
		card.headerXpBarBorderBottom:SetPoint("BOTTOMRIGHT", card.headerXpBar, "BOTTOMRIGHT", 0, 0)
		card.headerXpBarBorderBottom:SetHeight(1)
		card.headerXpBarBorderLeft = card.headerXpBar:CreateTexture(nil, "BORDER")
		card.headerXpBarBorderLeft:SetTexture("Interface\\Buttons\\WHITE8X8")
		card.headerXpBarBorderLeft:SetVertexColor(0.45, 0.45, 0.45, 0.85)
		card.headerXpBarBorderLeft:SetPoint("TOPLEFT", card.headerXpBar, "TOPLEFT", 0, 0)
		card.headerXpBarBorderLeft:SetPoint("BOTTOMLEFT", card.headerXpBar, "BOTTOMLEFT", 0, 0)
		card.headerXpBarBorderLeft:SetWidth(1)
		card.headerXpBarBorderRight = card.headerXpBar:CreateTexture(nil, "BORDER")
		card.headerXpBarBorderRight:SetTexture("Interface\\Buttons\\WHITE8X8")
		card.headerXpBarBorderRight:SetVertexColor(0.45, 0.45, 0.45, 0.85)
		card.headerXpBarBorderRight:SetPoint("TOPRIGHT", card.headerXpBar, "TOPRIGHT", 0, 0)
		card.headerXpBarBorderRight:SetPoint("BOTTOMRIGHT", card.headerXpBar, "BOTTOMRIGHT", 0, 0)
		card.headerXpBarBorderRight:SetWidth(1)
		card.headerXpText = card:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
		card.headerXpText:SetJustifyH("CENTER")
		card.headerXpText:SetJustifyV("MIDDLE")
		card.headerXpText:SetTextColor(0.92, 0.92, 0.92)
		card.headerXpText:SetText("")
		card.headerXpText:Hide()

		card.sepAB = card:CreateTexture(nil, "BORDER")
		card.sepAB:SetTexture("Interface\\Buttons\\WHITE8X8")
		card.sepAB:SetVertexColor(0.36, 0.36, 0.36, 0.70)
		card.sepAB:SetWidth(1)

		card.sepHA = card:CreateTexture(nil, "BORDER")
		card.sepHA:SetTexture("Interface\\Buttons\\WHITE8X8")
		card.sepHA:SetVertexColor(0.36, 0.36, 0.36, 0.70)
		card.sepHA:SetWidth(1)

		card.sepBC = card:CreateTexture(nil, "BORDER")
		card.sepBC:SetTexture("Interface\\Buttons\\WHITE8X8")
		card.sepBC:SetVertexColor(0.36, 0.36, 0.36, 0.70)
		card.sepBC:SetWidth(1)

		card.sepCD = card:CreateTexture(nil, "BORDER")
		card.sepCD:SetTexture("Interface\\Buttons\\WHITE8X8")
		card.sepCD:SetVertexColor(0.36, 0.36, 0.36, 0.70)
		card.sepCD:SetWidth(1)

		card.sectionLabelHeader = card:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
		card.sectionLabelHeader:SetPoint("TOPLEFT", card, "TOPLEFT", 10, -8)
		card.sectionLabelHeader:SetJustifyH("LEFT")
		card.sectionLabelHeader:SetTextColor(1.00, 0.82, 0.00)
		card.sectionLabelHeader:SetText("")

		card.sectionLabelA = card:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
		card.sectionLabelA:SetJustifyH("LEFT")
		card.sectionLabelA:SetTextColor(1.00, 0.82, 0.00)
		card.sectionLabelA:SetText("")

		card.sectionLabelB = card:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
		card.sectionLabelB:SetJustifyH("LEFT")
		card.sectionLabelB:SetTextColor(1.00, 0.82, 0.00)
		card.sectionLabelB:SetText("B")

		card.sectionLabelC = card:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
		card.sectionLabelC:SetJustifyH("LEFT")
		card.sectionLabelC:SetTextColor(1.00, 0.82, 0.00)
		card.sectionLabelC:SetText("C")

		card.sectionLabelD = card:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
		card.sectionLabelD:SetJustifyH("LEFT")
		card.sectionLabelD:SetTextColor(1.00, 0.82, 0.00)
		card.sectionLabelD:SetText("D")

		card.detailA = card:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
		card.detailA:SetJustifyH("LEFT")
		card.detailA:SetJustifyV("TOP")

		card.detailB = card:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
		card.detailB:SetJustifyH("LEFT")
		card.detailB:SetJustifyV("TOP")
		card.detailB:SetTextColor(1.00, 1.00, 1.00)
		if card.detailB.SetWordWrap then card.detailB:SetWordWrap(false) end
		if card.detailB.SetNonSpaceWrap then card.detailB:SetNonSpaceWrap(false) end

		card.detailC = card:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
		card.detailC:SetJustifyH("LEFT")
		card.detailC:SetJustifyV("TOP")
		card.detailC:SetTextColor(1.00, 1.00, 1.00)
		if card.detailC.SetWordWrap then card.detailC:SetWordWrap(false) end
		if card.detailC.SetNonSpaceWrap then card.detailC:SetNonSpaceWrap(false) end

		card.detailD = card:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
		card.detailD:SetJustifyH("LEFT")
		card.detailD:SetJustifyV("TOP")
		card.detailD:SetTextColor(1.00, 1.00, 1.00)
		if card.detailD.SetWordWrap then card.detailD:SetWordWrap(false) end
		if card.detailD.SetNonSpaceWrap then card.detailD:SetNonSpaceWrap(false) end

		card.tameBeastLinkButton = CreateFrame("Button", nil, card)
		card.tameBeastLinkButton:SetHeight(12)
		card.tameBeastLinkButton:SetWidth(96)
		card.tameBeastLinkButton.text = card.tameBeastLinkButton:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
		card.tameBeastLinkButton.text:SetAllPoints(card.tameBeastLinkButton)
		card.tameBeastLinkButton.text:SetJustifyH("LEFT")
		card.tameBeastLinkButton.text:SetTextColor(0.35, 0.75, 1.00)
		if card.tameBeastLinkButton.text.SetWordWrap then card.tameBeastLinkButton.text:SetWordWrap(false) end
		if card.tameBeastLinkButton.text.SetNonSpaceWrap then card.tameBeastLinkButton.text:SetNonSpaceWrap(false) end
		card.tameBeastLinkButton:SetScript("OnClick", function()
			if not this then return end
			if this.beastId and type(MTH_BOOK_JumpToBeastById) == "function" then
				MTH_BOOK_JumpToBeastById(this.beastId)
			end
		end)
		card.tameBeastLinkButton:SetScript("OnEnter", function()
			if this and this.text then
				this.text:SetTextColor(0.50, 0.85, 1.00)
			end
		end)
		card.tameBeastLinkButton:SetScript("OnLeave", function()
			if this and this.text then
				this.text:SetTextColor(0.35, 0.75, 1.00)
			end
		end)
		card.tameBeastLinkButton:Hide()

		card.tameMapButton = CreateFrame("Button", nil, card, "UIPanelButtonTemplate")
		card.tameMapButton:SetHeight(16)
		card.tameMapButton:SetWidth(106)
		card.tameMapButton:SetText("Show Taming Loc")
		card.tameMapButton:SetScript("OnClick", function()
			if not this then return end
			if type(MTH_BOOK_OpenTamePointOnMap) ~= "function" then return end
			local zoneId = tonumber(this.zoneId)
			local x = tonumber(this.coordX)
			local y = tonumber(this.coordY)
			if zoneId and x and y then
				MTH_BOOK_OpenTamePointOnMap(zoneId, x, y, this.pointTitle, this.pointDetail)
			end
		end)
		card.tameMapButton:Hide()

		card.abilitySlots = {}
		for slotIndex = 1, 8 do
			local slotButton = CreateFrame("Button", nil, card)
			slotButton:SetFrameStrata("DIALOG")
			slotButton:SetFrameLevel((card.GetFrameLevel and card:GetFrameLevel() or 1) + 2)
			slotButton:SetHeight(12)

			slotButton.icon = slotButton:CreateTexture(nil, "ARTWORK")
			slotButton.icon:SetPoint("LEFT", slotButton, "LEFT", 0, 0)
			slotButton.icon:SetWidth(12)
			slotButton.icon:SetHeight(12)

			slotButton.text = slotButton:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
			slotButton.text:SetPoint("LEFT", slotButton.icon, "RIGHT", 4, 0)
			slotButton.text:SetPoint("RIGHT", slotButton, "RIGHT", 0, 0)
			slotButton.text:SetJustifyH("LEFT")
			slotButton.text:SetTextColor(1.00, 1.00, 1.00)

			slotButton.entry = nil
			slotButton:SetScript("OnEnter", function()
				if this and this.entry then
					MTH_BOOK_ShowStableAbilityTooltip(this, this.entry)
				end
			end)
			slotButton:SetScript("OnLeave", function()
				MTH_BOOK_HideSpellTooltip()
			end)
			slotButton:Hide()
			card.abilitySlots[slotIndex] = slotButton
		end

		card.feedFoodRows = {}
		for foodRowIndex = 1, 3 do
			local foodRow = CreateFrame("Button", nil, card)
			foodRow:SetFrameStrata("DIALOG")
			foodRow:SetFrameLevel((card.GetFrameLevel and card:GetFrameLevel() or 1) + 2)
			foodRow:SetHeight(12)
			foodRow:SetWidth(10)
			foodRow.itemId = nil
			foodRow.itemLink = nil
			foodRow.itemName = nil

			foodRow.countText = foodRow:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
			foodRow.countText:SetPoint("LEFT", foodRow, "LEFT", 0, 0)
			foodRow.countText:SetWidth(14)
			foodRow.countText:SetJustifyH("LEFT")
			foodRow.countText:SetTextColor(1.00, 0.82, 0.00)

			foodRow.icon = foodRow:CreateTexture(nil, "ARTWORK")
			foodRow.icon:SetPoint("LEFT", foodRow.countText, "RIGHT", 0, 0)
			foodRow.icon:SetWidth(12)
			foodRow.icon:SetHeight(12)

			foodRow.nameButton = CreateFrame("Button", nil, foodRow)
			foodRow.nameButton:SetHeight(12)
			foodRow.nameButton:SetPoint("LEFT", foodRow.icon, "RIGHT", 2, 0)
			foodRow.nameButton:SetPoint("RIGHT", foodRow, "RIGHT", 0, 0)
			foodRow.nameButton.itemId = nil
			foodRow.nameButton.itemLink = nil
			foodRow.nameButton.itemName = nil

			foodRow.nameText = foodRow.nameButton:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
			foodRow.nameText:SetAllPoints(foodRow.nameButton)
			foodRow.nameText:SetJustifyH("LEFT")
			foodRow.nameText:SetTextColor(1.00, 1.00, 1.00)

			foodRow.nameButton:SetScript("OnEnter", function()
				if not this then return end
				if not GameTooltip then return end
				if this.itemId then
					this.itemLink = MTH_BOOK_NormalizeStableFoodLink(this.itemId, this.itemLink, this.itemName)
				end
				if type(MTH_PrimeItemCache) == "function" and this.itemId then
					MTH_PrimeItemCache(this.itemId)
				end
				if this.itemLink and this.itemLink ~= "" then
					GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
					local ok, err = pcall(GameTooltip.SetHyperlink, GameTooltip, this.itemLink)
					if not ok then
						if this.itemId then
							local fallbackLink = "item:" .. tostring(this.itemId) .. ":0:0:0"
							local fallbackOk, fallbackErr = pcall(GameTooltip.SetHyperlink, GameTooltip, fallbackLink)
							if not fallbackOk then
								GameTooltip:ClearLines()
								GameTooltip:AddLine(tostring(this.itemName or ("Item #" .. tostring(this.itemId))), 1.00, 1.00, 1.00)
							end
						else
							GameTooltip:ClearLines()
							GameTooltip:AddLine(tostring(this.itemName or "Unknown Food"), 1.00, 1.00, 1.00)
						end
					end
					GameTooltip:Show()
					local rowFrame = this:GetParent()
					if rowFrame then
						if type(GetItemInfo) == "function" and this.itemId then
							local _, _, _, _, _, _, _, _, _, itemTexture = GetItemInfo(this.itemId)
							if itemTexture and itemTexture ~= "" then
								rowFrame.iconHint = itemTexture
							end
						end
						MTH_BOOK_UpdateStableFoodRowIcon(rowFrame)
					end
					return
				end
				if this.itemId then
					GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
					local itemLink = "item:" .. tostring(this.itemId) .. ":0:0:0"
					local ok, err = pcall(GameTooltip.SetHyperlink, GameTooltip, itemLink)
					if not ok then
						GameTooltip:ClearLines()
						GameTooltip:AddLine(tostring(this.itemName or ("Item #" .. tostring(this.itemId))), 1.00, 1.00, 1.00)
					end
					GameTooltip:Show()
					local rowFrame = this:GetParent()
					if rowFrame then
						if type(GetItemInfo) == "function" then
							local _, _, _, _, _, _, _, _, _, itemTexture = GetItemInfo(this.itemId)
							if itemTexture and itemTexture ~= "" then
								rowFrame.iconHint = itemTexture
							end
						end
						MTH_BOOK_UpdateStableFoodRowIcon(rowFrame)
					end
					return
				end
				if this.itemName and this.itemName ~= "" then
					GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
					GameTooltip:ClearLines()
					GameTooltip:AddLine(tostring(this.itemName), 1.00, 1.00, 1.00)
					GameTooltip:Show()
				end
			end)
			foodRow.nameButton:SetScript("OnLeave", function()
				if GameTooltip then GameTooltip:Hide() end
			end)

			foodRow:Hide()
			card.feedFoodRows[foodRowIndex] = foodRow
		end

		ui.cards[i] = card
	end

	MTH_BOOK_STATE.stableUI = ui
	MTH_BOOK_DebugTrace("EnsureStableUI created cards=" .. tostring(table.getn(ui.cards)))
end

function MTH_BOOKTAB_SetStableUIVisible(visible)
	MTH_BOOKTAB_EnsureStableUI()
	local ui = MTH_BOOK_STATE.stableUI
	if not ui then return end

	local listParent = getglobal("MTH_BOOK_ListBackdrop")
	local detailParent = getglobal("MTH_BOOK_DetailBackdrop")
	local detailText = getglobal("MTH_BOOK_DetailBackdropDetailText")
	local openMapButton = getglobal("MTH_BOOK_OpenMapButton")
	if visible then
		if listParent then listParent:Show() end
		if detailParent then detailParent:Hide() end
		if detailText then detailText:Hide() end
		if openMapButton then openMapButton:Hide() end
		ui.frame:SetAlpha(1)
		ui.frame:Show()
	else
		ui.frame:Hide()
		if listParent then listParent:Show() end
		if detailParent then detailParent:Show() end
		if detailText then detailText:Show() end
	end
end

function MTH_BOOKTAB_RenderStableCards()
	MTH_BOOKTAB_EnsureStableUI()
	local ui = MTH_BOOK_STATE.stableUI
	if not ui then
		MTH_BOOK_DebugTrace("RenderStableCards aborted: stableUI nil")
		return
	end

	local results = MTH_BOOK_STATE.results or {}
	local count = table.getn(ui.cards)
	local visibleCardCount = MTH_BOOK_GetStableRenderCardCount(count)
	MTH_BOOK_DebugTrace("RenderStableCards results=" .. tostring(table.getn(results)) .. " cards=" .. tostring(count))
	local topPad = 8
	local bottomPad = 2
	local smallGap = 7
	local bigGap = 13
	local cardHeight = MTH_BOOK_GetStableRenderCardHeight((ui.frame:GetHeight() or 380), visibleCardCount, topPad, bottomPad, bigGap, smallGap)
	cardHeight = cardHeight + 6

	local slotEntries = {}
	for r = 1, table.getn(results) do
		local resultPetId = results[r]
		local resultRow = resultPetId and MTH_BOOK_GetPetStoreRow(resultPetId) or nil
		local slotNumber = MTH_BOOK_GetStableDisplaySlot(resultPetId, resultRow)
		if resultRow and slotNumber and slotNumber >= 0 and slotNumber <= 4 then
			slotEntries[slotNumber] = { petId = resultPetId, row = resultRow }
		end
	end

	local y = -topPad
	for i = 1, count do
		local card = ui.cards[i]
		if i > visibleCardCount then
			card:Hide()
		else
			local slotIndex = i - 1
			local slotEntry = slotEntries[slotIndex]
			local petId = slotEntry and slotEntry.petId or nil
			local row = slotEntry and slotEntry.row or nil
			MTH_BOOK_DebugTrace("Render card#" .. tostring(i) .. " petId=" .. tostring(petId) .. " hasRow=" .. tostring(type(row) == "table"))

			card:ClearAllPoints()
			card:SetPoint("TOPLEFT", ui.frame, "TOPLEFT", 8, y)
			card:SetPoint("TOPRIGHT", ui.frame, "TOPRIGHT", -8, y)
			card:SetHeight(cardHeight)
			local cardWidth = 0
			if card.GetRight and card.GetLeft then
				local right = tonumber(card:GetRight())
				local left = tonumber(card:GetLeft())
				if right and left and right > left then
					cardWidth = math.floor(right - left)
				end
			end
			if cardWidth <= 0 then
				local frameWidth = math.floor(tonumber(ui.frame:GetWidth()) or 0)
				if frameWidth <= 0 and ui.frame.GetRight and ui.frame.GetLeft then
					local right = tonumber(ui.frame:GetRight())
					local left = tonumber(ui.frame:GetLeft())
					if right and left and right > left then
						frameWidth = math.floor(right - left)
					end
				end
				if frameWidth <= 0 then frameWidth = 900 end
				cardWidth = frameWidth - 16
			end
			if cardWidth < 260 then cardWidth = 260 end
			local topY = -6
			local bottomY = 4
			local headerWidth = 139
			local bodyRight = cardWidth - 10
			local bodyWidth = bodyRight - headerWidth
			if bodyWidth < 4 then bodyWidth = 4 end
			local columnWidth = math.floor(bodyWidth / 4)
			local remainder = bodyWidth - (columnWidth * 4)
			local widthA = columnWidth
			local widthB = columnWidth
			local widthC = columnWidth
			local widthD = columnWidth
			if remainder > 0 then widthA = widthA + 1 remainder = remainder - 1 end
			if remainder > 0 then widthB = widthB + 1 remainder = remainder - 1 end
			if remainder > 0 then widthC = widthC + 1 remainder = remainder - 1 end
			if remainder > 0 then widthD = widthD + 1 end
			local xHA = headerWidth
			local xAB = xHA + widthA
			local xBC = xAB + widthB
			local xCD = xBC + widthC
			local xDD = xCD + widthD

			card.sepHA:ClearAllPoints()
			card.sepHA:SetPoint("TOPLEFT", card, "TOPLEFT", xHA, topY)
			card.sepHA:SetPoint("BOTTOMLEFT", card, "BOTTOMLEFT", xHA, bottomY)
			card.sepAB:ClearAllPoints()
			card.sepAB:SetPoint("TOPLEFT", card, "TOPLEFT", xAB, topY)
			card.sepAB:SetPoint("BOTTOMLEFT", card, "BOTTOMLEFT", xAB, bottomY)
			card.sepBC:ClearAllPoints()
			card.sepBC:SetPoint("TOPLEFT", card, "TOPLEFT", xBC, topY)
			card.sepBC:SetPoint("BOTTOMLEFT", card, "BOTTOMLEFT", xBC, bottomY)
			card.sepCD:ClearAllPoints()
			card.sepCD:SetPoint("TOPLEFT", card, "TOPLEFT", xCD, topY)
			card.sepCD:SetPoint("BOTTOMLEFT", card, "BOTTOMLEFT", xCD, bottomY)

			card.sectionLabelHeader:ClearAllPoints()
			card.sectionLabelHeader:SetPoint("TOPLEFT", card, "TOPLEFT", 10, topY)
			card.sectionLabelHeader:SetTextColor(0.75, 0.75, 0.75)
			card.sectionLabelA:ClearAllPoints()
			card.sectionLabelA:SetPoint("TOPLEFT", card, "TOPLEFT", xHA + 8, topY)
			card.sectionLabelA:SetTextColor(1.00, 0.82, 0.00)
			card.sectionLabelA:SetText("Training")
			card.sectionLabelB:ClearAllPoints()
			card.sectionLabelB:SetPoint("TOPLEFT", card, "TOPLEFT", xAB + 8, topY)
			card.sectionLabelB:SetTextColor(1.00, 0.82, 0.00)
			card.sectionLabelB:SetText("Stable info")
			card.sectionLabelC:ClearAllPoints()
			card.sectionLabelC:SetPoint("TOPLEFT", card, "TOPLEFT", xBC + 8, topY)
			card.sectionLabelC:SetTextColor(1.00, 0.82, 0.00)
			card.sectionLabelC:SetText("Taming info")
			card.sectionLabelD:ClearAllPoints()
			card.sectionLabelD:SetPoint("TOPLEFT", card, "TOPLEFT", xCD + 8, topY)
			card.sectionLabelD:SetTextColor(1.00, 0.82, 0.00)
			card.sectionLabelD:SetText("Feeding")

			card.icon:ClearAllPoints()
			card.icon:SetPoint("TOPLEFT", card, "TOPLEFT", 10, topY - 14)
			card.icon:SetWidth(36)
			card.icon:SetHeight(36)
			card.name:ClearAllPoints()
			card.name:SetPoint("TOPLEFT", card.icon, "TOPRIGHT", 8, 2)
			card.name:SetPoint("TOPRIGHT", card, "TOPLEFT", xHA - 8, topY - 14)
			card.meta:ClearAllPoints()
			card.meta:SetPoint("TOPLEFT", card.icon, "TOPRIGHT", 8, -15)
			card.meta:SetPoint("TOPRIGHT", card, "BOTTOMLEFT", xHA - 8, topY - 24)
			card.metaLoyalty:ClearAllPoints()
			card.metaLoyalty:SetPoint("TOPLEFT", card.meta, "BOTTOMLEFT", 0, 0)
			card.metaLoyalty:SetPoint("TOPRIGHT", card, "BOTTOMLEFT", xHA - 8, topY - 36)
			if card.headerXpBar then
				card.headerXpBar:ClearAllPoints()
				card.headerXpBar:SetPoint("BOTTOMLEFT", card, "BOTTOMLEFT", 10, 8)
				card.headerXpBar:SetPoint("BOTTOMRIGHT", card, "BOTTOMLEFT", xHA - 8, 8)
				card.headerXpBar:SetHeight(10)
			end
			if card.headerXpText then
				card.headerXpText:ClearAllPoints()
				card.headerXpText:SetPoint("CENTER", card.headerXpBar or card, "CENTER", 0, 0)
			end

			card.detailA:ClearAllPoints()
			card.detailA:SetPoint("TOPLEFT", card, "TOPLEFT", xHA + 8, topY - 14)
			card.detailA:SetPoint("BOTTOMRIGHT", card, "BOTTOMLEFT", xAB - 8, bottomY)
			card.detailA:SetText("")

			card.detailB:ClearAllPoints()
			card.detailB:SetPoint("TOPLEFT", card, "TOPLEFT", xAB + 8, topY - 14)
			card.detailB:SetPoint("BOTTOMRIGHT", card, "BOTTOMLEFT", xBC - 8, bottomY)

			card.detailC:ClearAllPoints()
			card.detailC:SetPoint("TOPLEFT", card, "TOPLEFT", xBC + 8, topY - 14)
			card.detailC:SetPoint("BOTTOMRIGHT", card, "BOTTOMLEFT", xCD - 8, bottomY)

			card.detailD:ClearAllPoints()
			card.detailD:SetPoint("TOPLEFT", card, "TOPLEFT", xCD + 8, topY - 14)
			card.detailD:SetPoint("BOTTOMRIGHT", card, "BOTTOMLEFT", xDD - 8, bottomY)
			card.detailB:SetText("")
			card.detailC:SetText("")
			card.detailD:SetText("")

			local bLines = MTH_BOOK_EnsureStableColumnLines(card, "detailBLines", 5)
			local cLines = MTH_BOOK_EnsureStableColumnLines(card, "detailCLines", 5)
			local dLines = MTH_BOOK_EnsureStableColumnLines(card, "detailDLines", 5)
			local lineTop = topY - 14
			local lineStep = 12
			for iLine = 1, 5 do
				local line = bLines[iLine]
				line:ClearAllPoints()
				line:SetPoint("TOPLEFT", card, "TOPLEFT", xAB + 8, lineTop - ((iLine - 1) * lineStep))
				line:SetPoint("RIGHT", card, "BOTTOMLEFT", xBC - 8, lineTop - ((iLine - 1) * lineStep))
				line:SetText("")
			end
			for iLine = 1, 5 do
				local line = cLines[iLine]
				line:ClearAllPoints()
				line:SetPoint("TOPLEFT", card, "TOPLEFT", xBC + 8, lineTop - ((iLine - 1) * lineStep))
				line:SetPoint("RIGHT", card, "BOTTOMLEFT", xCD - 8, lineTop - ((iLine - 1) * lineStep))
				line:SetTextColor(1.00, 1.00, 1.00)
				line:SetText("")
			end
			for iLine = 1, 5 do
				local line = dLines[iLine]
				line:ClearAllPoints()
				line:SetPoint("TOPLEFT", card, "TOPLEFT", xCD + 8, lineTop - ((iLine - 1) * lineStep))
				line:SetPoint("RIGHT", card, "BOTTOMLEFT", xDD - 8, lineTop - ((iLine - 1) * lineStep))
				line:SetText("")
			end

			for foodRowIndex = 1, table.getn(card.feedFoodRows or {}) do
				local foodRow = card.feedFoodRows[foodRowIndex]
				if foodRow then
					foodRow:ClearAllPoints()
					foodRow:SetPoint("TOPLEFT", card, "TOPLEFT", xCD + 8, lineTop - (foodRowIndex * lineStep))
					foodRow:SetWidth((xDD - xCD) - 16)
					foodRow.itemId = nil
					foodRow.itemLink = nil
					foodRow.itemName = nil
					foodRow.iconHint = nil
					if foodRow.countText then foodRow.countText:SetText("") end
					if foodRow.icon then foodRow.icon:SetTexture(nil) end
					if foodRow.nameText then foodRow.nameText:SetText("") end
					if foodRow.nameButton then
						foodRow.nameButton.itemId = nil
						foodRow.nameButton.itemLink = nil
						foodRow.nameButton.itemName = nil
						foodRow.nameButton:SetWidth(10)
					end
					foodRow:Hide()
				end
			end

			local aLeft = xHA + 8
			local aRight = xAB - 8
			local aTop = lineTop
			local aWidth = aRight - aLeft
			if aWidth < 20 then aWidth = 20 end
			local colGap = 4
			local innerWidth = aWidth - colGap
			if innerWidth < 16 then innerWidth = 16 end
			local leftColWidth = math.floor(innerWidth * 0.62)
			local rightColWidth = innerWidth - leftColWidth
			if leftColWidth < 8 then leftColWidth = 8 end
			if rightColWidth < 8 then rightColWidth = 8 end
			local rowHeight = 12
			local rowStep = 13

			for slotButtonIndex = 1, table.getn(card.abilitySlots or {}) do
				local slotButton = card.abilitySlots[slotButtonIndex]
				if slotButton then
					local rowIndex = math.floor((slotButtonIndex - 1) / 2) + 1
					local remainder = (slotButtonIndex - 1) - (math.floor((slotButtonIndex - 1) / 2) * 2)
					local colIndex = remainder + 1
					local xOffset = aLeft
					local slotWidth = leftColWidth
					if colIndex == 2 then
						xOffset = aLeft + leftColWidth + colGap + 4
						slotWidth = rightColWidth
					end
					local yOffset = aTop - ((rowIndex - 1) * rowStep)
					slotButton:ClearAllPoints()
					slotButton:SetPoint("TOPLEFT", card, "TOPLEFT", xOffset, yOffset)
					slotButton:SetWidth(slotWidth)
					slotButton:SetHeight(rowHeight)
					slotButton.entry = nil
					slotButton:Hide()
				end
			end

			if card.tameBeastLinkButton then
				card.tameBeastLinkButton:ClearAllPoints()
				card.tameBeastLinkButton:SetPoint("TOPLEFT", card, "TOPLEFT", xBC + 64, lineTop - lineStep + 1)
				local tameLinkWidth = (xCD - xBC) - 82
				if tameLinkWidth < 24 then tameLinkWidth = 24 end
				card.tameBeastLinkButton:SetWidth(tameLinkWidth)
				card.tameBeastLinkButton.beastId = nil
				card.tameBeastLinkButton.text:SetText("")
				card.tameBeastLinkButton:Hide()
			end
			if card.tameMapButton then
				card.tameMapButton:ClearAllPoints()
				card.tameMapButton:SetPoint("TOP", card, "TOPLEFT", math.floor((xBC + xCD) / 2), topY - 50)
				card.tameMapButton.zoneId = nil
				card.tameMapButton.coordX = nil
				card.tameMapButton.coordY = nil
				card.tameMapButton.pointTitle = nil
				card.tameMapButton.pointDetail = nil
				card.tameMapButton:Hide()
			end

			if row then
				local slot = slotIndex
				if slot == 0 then
					card.sectionLabelB:SetText("Last stable info")
				else
					card.sectionLabelB:SetText("Stable info")
				end
				local nameText = tostring(row.name or "Unknown")
				local loyaltyLevelValue = tonumber(row.loyaltyLevel)
				if not loyaltyLevelValue and row.stableInfo then
					loyaltyLevelValue = tonumber(row.stableInfo.loyaltyLevel)
				end
				local loyaltyTextValue = nil
				if loyaltyLevelValue then
					loyaltyTextValue = MTH_BOOK_GetLoyaltyNameByLevel(loyaltyLevelValue)
				end
				if not loyaltyTextValue or loyaltyTextValue == "" then
					loyaltyTextValue = "-"
				end
				local loyaltyColorValue = loyaltyTextValue
				if loyaltyLevelValue then
					loyaltyColorValue = "Loyalty Level " .. tostring(loyaltyLevelValue)
				end
				card.name:SetText(nameText)

				card.sectionLabelHeader:SetText("")
				card.meta:SetText(tostring(row.family or "-") .. " " .. tostring(row.level or "-"))
				card.metaLoyalty:SetTextColor(MTH_BOOK_GetLoyaltyHeaderColor(loyaltyColorValue))
				card.metaLoyalty:SetText(tostring(loyaltyTextValue or "-"))

				if card.headerXpBar then
					local petLevel = tonumber(row.level)
					local xpCur = tonumber(row.xp)
					local xpMax = tonumber(row.xpMax)
					local xpPercent = tonumber(row.xpPercent)
					if (not xpCur or not xpMax or xpMax <= 0) and type(row.stableInfo) == "table" then
						xpCur = xpCur or tonumber(row.stableInfo.r6)
						xpMax = xpMax or tonumber(row.stableInfo.r7)
						xpPercent = xpPercent or tonumber(row.stableInfo.r8)
					end
					if (not xpCur or not xpMax or xpMax <= 0) and type(row.stableRaw) == "table" then
						xpCur = xpCur or tonumber(row.stableRaw[6])
						xpMax = xpMax or tonumber(row.stableRaw[7])
						xpPercent = xpPercent or tonumber(row.stableRaw[8])
					end

					if petLevel and petLevel < 60 then
						local barMin = 0
						local barMax = 1
						local barValue = 0

						if xpCur and xpMax and xpMax > 0 then
							if xpCur < 0 then xpCur = 0 end
							if xpCur > xpMax then xpCur = xpMax end
							barMax = xpMax
							barValue = xpCur
						elseif xpPercent and xpPercent >= 0 then
							if xpPercent > 100 then xpPercent = 100 end
							barMax = 100
							barValue = xpPercent
						end

						card.headerXpBar:SetMinMaxValues(barMin, barMax)
						card.headerXpBar:SetValue(barValue)
						card.headerXpBar:Show()
						if card.headerXpText then
							card.headerXpText:SetText("")
							card.headerXpText:Hide()
						end
					else
						card.headerXpBar:Hide()
						if card.headerXpText then
							card.headerXpText:SetText("")
							card.headerXpText:Hide()
						end
					end
				end

				local iconPath = tostring(row.icon or "")
				if slot == 0 then
					local lowerIconPath = string.lower(iconPath)
					if iconPath == "" or lowerIconPath == "ability_hunter_beasttaming" then
						local fallbackIcon = (type(row.stableInfo) == "table") and tostring(row.stableInfo.icon or "") or ""
						if fallbackIcon == "" and type(row.stableRaw) == "table" then
							fallbackIcon = tostring(row.stableRaw[1] or "")
						end
						if fallbackIcon ~= "" then
							iconPath = fallbackIcon
						end
					end
				end

				card.icon:Show()
				if iconPath ~= "" then
					if string.find(iconPath, "\\", 1, true) then
						card.icon:SetTexture(iconPath)
					else
						card.icon:SetTexture("Interface\\Icons\\" .. iconPath)
					end
				else
					card.icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
				end

				local leftAbilities, rightAbilities = MTH_BOOK_BuildStablePetAbilityEntries(row)
				local abilitiesCount = MTH_BOOK_CountPetAbilitiesMap(row.abilities)
				local abilitiesText = MTH_BOOK_GetStableAbilitySummary(row.abilities)
				local legacyTameContext = type(row.tameContext) == "table" and row.tameContext or nil
				local hasRecordedTame = row.tameRecorded == true
				if not hasRecordedTame and legacyTameContext then
					if legacyTameContext.name or legacyTameContext.zone or legacyTameContext.timestamp then
						hasRecordedTame = true
					end
				end
				local tameZone = hasRecordedTame and tostring(row.tameZone or (legacyTameContext and legacyTameContext.zone) or "-") or "-"
				local tameX = hasRecordedTame and (MTH_BOOK_NormalizeMapCoordValue(row.tameX) or (legacyTameContext and MTH_BOOK_NormalizeMapCoordValue(legacyTameContext.x) or nil)) or nil
				local tameY = hasRecordedTame and (MTH_BOOK_NormalizeMapCoordValue(row.tameY) or (legacyTameContext and MTH_BOOK_NormalizeMapCoordValue(legacyTameContext.y) or nil)) or nil
				local tameCoords = "-"
				if tameX and tameY then
					tameCoords = string.format("%.1f, %.1f", tameX, tameY)
				end
				local tamedAt = hasRecordedTame and (tonumber(row.tamedAt) or (legacyTameContext and tonumber(legacyTameContext.timestamp) or nil)) or nil
				local stableInfo = (type(row.stableInfo) == "table") and row.stableInfo or nil
				local stabledAt = tonumber(row.stabledAt) or tonumber(row.stableFirstSeenAt) or (stableInfo and tonumber(stableInfo.stabledAt) or nil)
				local stabledSince = MTH_BOOK_FormatElapsedStableInfo(stabledAt)
				local pulledAt = tonumber(row.lastUnstabledAt) or stabledAt
				local withMeSince = MTH_BOOK_FormatElapsedStableInfo(pulledAt)
				local stableZone = stableInfo and tostring(stableInfo.stableZone or "") or ""
				local stableSubZone = stableInfo and tostring(stableInfo.stableSubZone or "") or ""
				local stableMasterName = stableInfo and tostring(stableInfo.stableMasterName or "") or ""
				local stableLocation = "-"
				if stableSubZone ~= "" and stableZone ~= "" then
					stableLocation = stableSubZone .. " (" .. stableZone .. ")"
				elseif stableSubZone ~= "" then
					stableLocation = stableSubZone
				elseif stableZone ~= "" then
					stableLocation = stableZone
				end
				if stableMasterName == "" then
					stableMasterName = "-"
				end
				local rowOrigin = tostring(row.origin or row.lastSource or "-")
				local rowLastUpdateAt = tonumber(row.lastUpdated) or tonumber(row.updatedAt) or tonumber(row.lastSeen) or nil
				local tameBeastId = hasRecordedTame and (tonumber(row.tameBeastId) or (legacyTameContext and tonumber(legacyTameContext.beastId) or nil)) or nil
				local tameBeast = tameBeastId and MTH_DS_Beasts and MTH_DS_Beasts[tameBeastId] or nil
				local tameBeastName = tostring((tameBeast and tameBeast.name) or (legacyTameContext and legacyTameContext.name) or "-")
				local tameZoneId = MTH_BOOK_ResolveStableTameZoneId(tameZone ~= "-" and tameZone or nil, tameBeast, tameX, tameY)
				for rowIndex = 1, 4 do
					local leftSlot = ((rowIndex - 1) * 2) + 1
					local rightSlot = leftSlot + 1
					local leftEntry = leftAbilities[rowIndex]
					local rightEntry = rightAbilities[rowIndex]

					local leftButton = card.abilitySlots and card.abilitySlots[leftSlot] or nil
					if leftButton then
						if leftEntry then
							leftButton.entry = leftEntry
							leftButton.text:SetText(tostring(leftEntry.display or "-"))
							local leftIconPath = MTH_BOOK_ResolveIconPath(leftEntry.icon)
							if leftIconPath then
								leftButton.icon:SetTexture(leftIconPath)
							else
								leftButton.icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
							end
							leftButton:Show()
						else
							leftButton.entry = nil
							leftButton:Hide()
						end
					end

					local rightButton = card.abilitySlots and card.abilitySlots[rightSlot] or nil
					if rightButton then
						if rightEntry then
							rightButton.entry = rightEntry
							rightButton.text:SetText(tostring(rightEntry.display or "-"))
							local rightIconPath = MTH_BOOK_ResolveIconPath(rightEntry.icon)
							if rightIconPath then
								rightButton.icon:SetTexture(rightIconPath)
							else
								rightButton.icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
							end
							rightButton:Show()
						else
							rightButton.entry = nil
							rightButton:Hide()
						end
					end
				end
				if slot == 0 then
					bLines[1]:SetText(MTH_BOOK_StableDetailKV("Pulled", MTH_BOOK_FormatTimestamp(pulledAt)))
					bLines[2]:SetText(MTH_BOOK_StableDetailKV("For", tostring(withMeSince)))
					bLines[3]:SetText(MTH_BOOK_StableDetailKV("Master", tostring(stableMasterName)))
					bLines[4]:SetText(tostring(stableLocation))
					bLines[5]:SetText("")
				else
					bLines[1]:SetText(MTH_BOOK_StableDetailKV("Stabled", MTH_BOOK_FormatTimestamp(stabledAt)))
					bLines[2]:SetText(MTH_BOOK_StableDetailKV("For", tostring(stabledSince)))
					bLines[3]:SetText(MTH_BOOK_StableDetailKV("Master", tostring(stableMasterName)))
					bLines[4]:SetText(tostring(stableLocation))
					bLines[5]:SetText("")
				end
				if hasRecordedTame then
					cLines[1]:SetText(MTH_BOOK_StableDetailKV("Tamed on", MTH_BOOK_FormatTimestamp(tamedAt)))
					cLines[2]:SetText("")
					cLines[3]:SetText(MTH_BOOK_StableDetailKV("Taming Loc", tostring(tameZone)))
					cLines[4]:SetText("")
					cLines[5]:SetText("")
					if card.tameBeastLinkButton and tameBeastId and tameBeastName ~= "-" then
						cLines[2]:SetText(MTH_BOOK_StableDetailKV("Tamed Beast", ""))
						card.tameBeastLinkButton.beastId = tameBeastId
						card.tameBeastLinkButton.text:SetText("|cff59bfff" .. tostring(tameBeastName) .. "|r")
						card.tameBeastLinkButton:Show()
					else
						cLines[2]:SetText(MTH_BOOK_StableDetailKV("Tamed Beast", tostring(tameBeastName)))
					end
				else
					cLines[1]:SetText("")
					cLines[2]:SetText("")
					cLines[3]:SetTextColor(0.72, 0.72, 0.72)
					cLines[3]:SetText("No info")
					cLines[4]:SetText("")
					cLines[5]:SetText("")
				end
				if card.tameMapButton and tameZoneId and tameX and tameY then
					card.tameMapButton.zoneId = tameZoneId
					card.tameMapButton.coordX = tameX
					card.tameMapButton.coordY = tameY
					card.tameMapButton.pointTitle = "Tame: " .. tostring(tameBeastName)
					card.tameMapButton.pointDetail = "Zone: " .. tostring(tameZone) .. "\nCoords: " .. tostring(tameCoords)
					card.tameMapButton:Show()
				end
				local totalFed, topFoods = MTH_BOOK_GetStableFeedSummary(petId)
				local totalFedText = tostring(totalFed)
				if tonumber(totalFed) == 1 then
					dLines[1]:SetText("You fed it " .. totalFedText .. " time")
				else
					dLines[1]:SetText("You fed it " .. totalFedText .. " times")
				end
				dLines[2]:SetText("")
				dLines[3]:SetText("")
				dLines[4]:SetText("")
				dLines[5]:SetText("")
				for foodRowIndex = 1, table.getn(card.feedFoodRows or {}) do
					local foodRow = card.feedFoodRows[foodRowIndex]
					local foodEntry = topFoods[foodRowIndex]
					if foodRow and foodEntry then
						if type(MTH_PrimeItemCache) == "function" and foodEntry.itemId then
							MTH_PrimeItemCache(foodEntry.itemId)
						end
						foodRow.itemId = foodEntry.itemId
						foodRow.itemLink = foodEntry.link
						foodRow.itemName = foodEntry.name
						foodRow.iconHint = foodEntry.icon
						if foodRow.countText then
							foodRow.countText:SetText(tostring(foodEntry.count or 0))
						end
						if foodRow.icon then
							MTH_BOOK_UpdateStableFoodRowIcon(foodRow)
						end
						if foodRow.nameText then
							foodRow.nameText:SetText(tostring(foodEntry.name or "-"))
						end
						if foodRow.nameButton then
							foodRow.nameButton.itemId = foodEntry.itemId
							foodRow.nameButton.itemLink = foodEntry.link
							foodRow.nameButton.itemName = foodEntry.name
						end
						foodRow:Show()
					elseif foodRow then
						foodRow:Hide()
					end
				end

				if slot == 0 then
					card.bg:SetVertexColor(0.16, 0.14, 0.08, 0.82)
				else
					card.bg:SetVertexColor(0.08, 0.08, 0.08, 0.72)
				end
				card:Show()
			else
				card.sectionLabelHeader:SetText("")
				if slotIndex == 0 then
					card.icon:Hide()
					card.name:SetText("")
					card.meta:SetText("No current pet")
					card.detailA:SetText("")
					card.detailB:SetText("")
					card.detailC:SetText("")
					card.detailD:SetText("")
				else
					card.icon:Hide()
					card.name:SetText("")
					card.meta:SetText("Free slot")
					card.detailA:SetText("")
					card.detailB:SetText("")
					card.detailC:SetText("")
					card.detailD:SetText("")
				end
				for iLine = 1, 5 do
					if bLines and bLines[iLine] then bLines[iLine]:SetText("") end
					if dLines and dLines[iLine] then dLines[iLine]:SetText("") end
				end
				for iLine = 1, 5 do
					if cLines and cLines[iLine] then cLines[iLine]:SetText("") end
				end
				for foodRowIndex = 1, table.getn(card.feedFoodRows or {}) do
					local foodRow = card.feedFoodRows[foodRowIndex]
					if foodRow then
						foodRow:Hide()
					end
				end
				card.metaLoyalty:SetTextColor(0.84, 0.84, 0.84)
				card.metaLoyalty:SetText("")
				if card.headerXpBar then
					card.headerXpBar:Hide()
				end
				if card.headerXpText then
					card.headerXpText:SetText("")
					card.headerXpText:Hide()
				end
				for slotButtonIndex = 1, table.getn(card.abilitySlots or {}) do
					local slotButton = card.abilitySlots[slotButtonIndex]
					if slotButton then
						slotButton.entry = nil
						slotButton:Hide()
					end
				end
				card.bg:SetVertexColor(0.05, 0.05, 0.05, 0.55)
				card:Show()
			end

			y = y - cardHeight
			if i == 1 and visibleCardCount > 1 then
				y = y - bigGap
			elseif i < visibleCardCount then
				y = y - smallGap
			end
		end
	end
end
