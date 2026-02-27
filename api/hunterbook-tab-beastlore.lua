if type(MTH_HUNTERBOOK_TABS) ~= "table" then MTH_HUNTERBOOK_TABS = {} end

MTH_HUNTERBOOK_TABS.pets = {
	headerLabel = "Beasts",
	columnLabels = { "ID", "Lvl", "Family", "Name", "Abilities", "Zone", "R", "E", "U" },
	columnLayout = {
		{ x = 8, width = 28, align = "LEFT" },
		{ x = 38, width = 30, align = "LEFT" },
		{ x = 68, width = 74, align = "LEFT" },
		{ x = 142, width = 130, align = "LEFT" },
		{ x = 272, width = 180, align = "LEFT" },
		{ x = 452, width = 68, align = "LEFT" },
		{ x = 520, width = 10, align = "CENTER" },
		{ x = 532, width = 10, align = "CENTER" },
		{ x = 544, width = 10, align = "CENTER" },
	},
}

function MTH_BOOK_GetBeastAbilitiesSummary(beast)
	if not beast or not beast.abilities or beast.abilities == "" or beast.abilities == "None" then
		return "-"
	end
	return tostring(beast.abilities)
end

function MTH_BOOK_GetBeastZoneSummary(beast)
	if not beast or not beast.coords or table.getn(beast.coords) == 0 then
		return "-"
	end

	local seen = {}
	local zoneNames = {}
	for i = 1, table.getn(beast.coords) do
		local c = beast.coords[i]
		if c and c[3] and not seen[c[3]] then
			seen[c[3]] = true
			table.insert(zoneNames, MTH_BOOK_GetZoneName(c[3]))
		end
	end

	if table.getn(zoneNames) == 0 then return "-" end
	if table.getn(zoneNames) == 1 then return zoneNames[1] end
	return zoneNames[1] .. " +" .. tostring(table.getn(zoneNames) - 1)
end

function MTH_BOOK_SplitAbilities(text)
	local out = {}
	if not text or text == "" or text == "None" then return out end
	local startPos = 1
	local textLen = string.len(text)
	while startPos <= textLen do
		local commaPos = string.find(text, ",", startPos, true)
		local token
		if commaPos then
			token = string.sub(text, startPos, commaPos - 1)
			startPos = commaPos + 1
		else
			token = string.sub(text, startPos)
			startPos = textLen + 1
		end
		token = string.gsub(token, "^%s+", "")
		token = string.gsub(token, "%s+$", "")
		if token ~= "" then
			table.insert(out, token)
		end
	end
	return out
end

function MTH_BOOK_HasUsableAbilities(beast)
	if not beast then return false end
	local abilities = MTH_BOOK_SplitAbilities(beast.abilities)
	if table.getn(abilities) == 0 then return false end
	for i = 1, table.getn(abilities) do
		local token = MTH_BOOK_SafeLower(abilities[i])
		if token ~= "" and token ~= "none" and token ~= "unknown" then
			return true
		end
	end
	return false
end

function MTH_BOOK_HasKnownLevel(beast)
	if not beast then return false end
	if MTH_BOOK_IsUnknownText(beast.lvl) then return false end
	return MTH_BOOK_ParseLevel(beast.lvl) ~= nil
end

function MTH_BOOK_HasKnownZone(beast)
	if not beast or not beast.coords or table.getn(beast.coords) == 0 then
		return false
	end

	for i = 1, table.getn(beast.coords) do
		local c = beast.coords[i]
		if c and c[3] then
			local zoneName = MTH_BOOK_SafeLower(MTH_BOOK_GetZoneName(c[3]))
			if zoneName ~= "" and zoneName ~= "unknown" and string.sub(zoneName, 1, 5) ~= "zone " then
				return true
			end
		end
	end

	return false
end

function MTH_BOOK_ParseAbilityToken(token)
	local text = tostring(token or "")
	text = string.gsub(text, "^%s+", "")
	text = string.gsub(text, "%s+$", "")
	if text == "" then return "", "", nil end

	local _, _, ability, rank = string.find(text, "^(.-)%s*(%d+)$")
	if ability and ability ~= "" then
		ability = string.gsub(ability, "^%s+", "")
		ability = string.gsub(ability, "%s+$", "")
		if ability ~= "" then
			return MTH_BOOK_SafeLower(ability), ability, tonumber(rank)
		end
	end

	return MTH_BOOK_SafeLower(text), text, nil
end

function MTH_BOOK_BeastHasAbilityRank(beast, abilityValue, rankValue)
	if not beast then return false end
	local wantedAbility = MTH_BOOK_SafeLower(abilityValue)
	if wantedAbility == "" or wantedAbility == "all" then return true end

	local wantedRank = tonumber(rankValue)
	local abilities = MTH_BOOK_SplitAbilities(beast.abilities)
	for i = 1, table.getn(abilities) do
		local abilityLower, _, rank = MTH_BOOK_ParseAbilityToken(abilities[i])
		if abilityLower == wantedAbility then
			if not wantedRank then
				return true
			end
			if rank and rank == wantedRank then
				return true
			end
		end
	end

	return false
end

function MTH_BOOK_ParseBeastTraits(beast)
	local traits = {
		rare = beast and beast.rare and true or false,
		elite = beast and (beast.elite == true or beast.isElite == true) or false,
		unique = beast and (beast.unique == true or beast.isUnique == true) or false,
	}

	if not beast then return traits end

	local rank = MTH_BOOK_SafeLower(beast.rank)
	if rank ~= "" then
		if string.find(rank, "rare", 1, true) then traits.rare = true end
		if string.find(rank, "elite", 1, true) then traits.elite = true end
		if string.find(rank, "unique", 1, true) then traits.unique = true end
	end

	local cls = MTH_BOOK_SafeLower(beast.classification)
	if cls ~= "" then
		if string.find(cls, "rare", 1, true) then traits.rare = true end
		if string.find(cls, "elite", 1, true) then traits.elite = true end
		if string.find(cls, "unique", 1, true) then traits.unique = true end
	end

	local name = MTH_BOOK_SafeLower(beast.name)
	if name ~= "" then
		local scanPos = 1
		while true do
			local startPos, endPos = string.find(name, "%b()", scanPos)
			if not startPos then break end
			local token = string.sub(name, startPos, endPos)
			scanPos = endPos + 1

			local inner = string.sub(token, 2, -2)
			inner = string.gsub(inner, "^%s+", "")
			inner = string.gsub(inner, "%s+$", "")
			local normalized = string.gsub(inner, "[%s%-_/]", "")

			if inner == "rare" or normalized == "r" then traits.rare = true end
			if inner == "elite" or normalized == "e" then traits.elite = true end
			if inner == "unique" or normalized == "u" then traits.unique = true end

			if string.find(inner, "rare", 1, true) then traits.rare = true end
			if string.find(inner, "elite", 1, true) then traits.elite = true end
			if string.find(inner, "unique", 1, true) then traits.unique = true end

			if normalized ~= "" and string.find(normalized, "[^reu]", 1) == nil then
				if string.find(normalized, "r", 1, true) then traits.rare = true end
				if string.find(normalized, "e", 1, true) then traits.elite = true end
				if string.find(normalized, "u", 1, true) then traits.unique = true end
			end
		end
	end

	return traits
end

function MTH_BOOK_BeastMatches(beastId, beast)
	if not beast then return false end
	local forcedBeastId = MTH_BOOK_STATE and tonumber(MTH_BOOK_STATE.forcedBeastId) or nil
	if forcedBeastId and tonumber(beastId) ~= forcedBeastId then
		return false
	end
	local beastLevel = MTH_BOOK_ParseLevel(beast.lvl)
	local traits = MTH_BOOK_ParseBeastTraits(beast)
	local familyLower = MTH_BOOK_SafeLower(beast.family or "")

	if MTH_BOOK_STATE.minLevel and (not beastLevel or beastLevel < MTH_BOOK_STATE.minLevel) then return false end
	if MTH_BOOK_STATE.maxLevel and (not beastLevel or beastLevel > MTH_BOOK_STATE.maxLevel) then return false end

	if MTH_BOOK_STATE.flag1 and not traits.rare then return false end
	if MTH_BOOK_STATE.flag2 and not traits.elite then return false end
	if MTH_BOOK_STATE.flag3 and not traits.unique then return false end
	if not MTH_BOOK_BeastHasAbilityRank(beast, MTH_BOOK_STATE.petAbility, MTH_BOOK_STATE.petRank) then return false end
	if MTH_BOOK_STATE.petHideNoAbilities and not MTH_BOOK_HasUsableAbilities(beast) then return false end
	if MTH_BOOK_STATE.petHideUnknown then
		if familyLower == "unknown" then return false end
		if not MTH_BOOK_HasKnownLevel(beast) then return false end
		if not MTH_BOOK_HasKnownZone(beast) then return false end
	end

	if MTH_BOOK_STATE.quick ~= "all" then
		if familyLower ~= MTH_BOOK_STATE.quick then
			return false
		end
	end

	if MTH_BOOK_STATE.petInZoneOnly then
		local currentZoneId = MTH_BOOK_GetCurrentZoneId()
		if currentZoneId and not MTH_BOOK_BeastHasZoneId(beast, currentZoneId) then
			return false
		end
	end

	if MTH_BOOK_STATE.search ~= "" then
		local localizedName = (MTH and MTH.GetLocalizedBeastName and MTH:GetLocalizedBeastName(beastId, beast.name)) or beast.name
		local name = MTH_BOOK_SafeLower(localizedName)
		local family = MTH_BOOK_SafeLower(beast.family)
		local idText = tostring(beastId)
		if string.find(name, MTH_BOOK_STATE.search, 1, true) == nil
			and string.find(family, MTH_BOOK_STATE.search, 1, true) == nil
			and string.find(idText, MTH_BOOK_STATE.search, 1, true) == nil
		then
			return false
		end
	end

	return true
end

function MTH_BOOK_BeastSort(a, b)
	local beasts = MTH_DS_Beasts
	local ba = beasts and beasts[a]
	local bb = beasts and beasts[b]
	if not ba or not bb then return a < b end
	local la = MTH_BOOK_ParseLevel(ba.lvl) or 0
	local lb = MTH_BOOK_ParseLevel(bb.lvl) or 0
	if la ~= lb then return la < lb end
	local na = (MTH and MTH.GetLocalizedBeastName) and MTH:GetLocalizedBeastName(a, ba.name) or (ba.name or "")
	local nb = (MTH and MTH.GetLocalizedBeastName) and MTH:GetLocalizedBeastName(b, bb.name) or (bb.name or "")
	if na ~= nb then return na < nb end
	return a < b
end

local function MTH_BOOKTAB_BeastLoreTrim(value)
	local text = tostring(value or "")
	text = string.gsub(text, "^%s+", "")
	text = string.gsub(text, "%s+$", "")
	return text
end

local function MTH_BOOKTAB_BeastLoreFindAbilityBundle(abilityName)
	if not (MTH_DS_PetSpells and type(MTH_DS_PetSpells.byAbility) == "table") then
		return nil
	end
	local direct = MTH_DS_PetSpells.byAbility[abilityName]
	if type(direct) == "table" then
		return direct
	end
	local wanted = MTH_BOOK_SafeLower(abilityName)
	for key, bundle in pairs(MTH_DS_PetSpells.byAbility) do
		if MTH_BOOK_SafeLower(key) == wanted then
			return bundle
		end
	end
	return nil
end

function MTH_BOOKTAB_BuildBeastAbilityEntries(beast)
	local entries = {}
	if type(beast) ~= "table" then
		return entries
	end

	local tokens = MTH_BOOK_SplitAbilities(beast.abilities)
	local seen = {}
	for i = 1, table.getn(tokens) do
		local rawToken = MTH_BOOKTAB_BeastLoreTrim(tokens[i])
		if rawToken ~= "" then
			local tokenKey = MTH_BOOK_SafeLower(rawToken)
			if tokenKey ~= "" and not seen[tokenKey] then
				seen[tokenKey] = true

				local _, abilityLabel, requestedRank = MTH_BOOK_ParseAbilityToken(rawToken)
				local bundle = MTH_BOOKTAB_BeastLoreFindAbilityBundle(abilityLabel)
				local canonical = abilityLabel
				if type(bundle) == "table" and type(bundle.ability) == "string" and bundle.ability ~= "" then
					canonical = bundle.ability
				end

				local spellRows = (type(bundle) == "table" and type(bundle.spells) == "table") and bundle.spells or {}
				local preferredSpell = nil
				local firstBeastSpell = nil
				local rankMin = nil
				local rankMax = nil
				local rankMap = {}
				for s = 1, table.getn(spellRows) do
					local spell = spellRows[s]
					if type(spell) == "table" and MTH_BOOK_SafeLower(spell.learnMethod or "beast") ~= "trainer" then
						if not firstBeastSpell then
							firstBeastSpell = spell
						end
						local rank = tonumber(spell.rankNumber)
						if rank and rank > 0 then
							rankMap[rank] = true
							if not rankMin or rank < rankMin then rankMin = rank end
							if not rankMax or rank > rankMax then rankMax = rank end
							if requestedRank and requestedRank == rank then
								preferredSpell = spell
							end
						end
					end
				end

				local rankCount = 0
				for _ in pairs(rankMap) do
					rankCount = rankCount + 1
				end

				if not preferredSpell then
					preferredSpell = firstBeastSpell
				end

				local displayName = canonical
				if requestedRank then
					displayName = canonical .. " " .. tostring(requestedRank)
				end

				table.insert(entries, {
					name = displayName,
					tooltipName = canonical,
					requestedRank = requestedRank,
					icon = preferredSpell and preferredSpell.icon or nil,
					description = preferredSpell and preferredSpell.description or "",
					rankMin = rankMin,
					rankMax = rankMax,
					rankCount = rankCount,
				})
			end
		end
	end

	return entries
end

function MTH_BOOKTAB_ShowBeastAbilityTooltip(anchor, abilityEntry)
	if not anchor or type(abilityEntry) ~= "table" then return end
	local tooltip = MTH_BOOK_GetSpellTooltip and MTH_BOOK_GetSpellTooltip() or GameTooltip
	if not tooltip then return end

	tooltip:SetOwner(anchor, "ANCHOR_RIGHT")
	tooltip:ClearLines()
	if MTH_BOOK_SetSpellTooltipIcon then
		MTH_BOOK_SetSpellTooltipIcon(tooltip, abilityEntry.icon)
	end
	local title = tostring(abilityEntry.tooltipName or abilityEntry.name or "Unknown")
	if abilityEntry.requestedRank then
		title = title .. " " .. tostring(abilityEntry.requestedRank)
	end
	tooltip:AddLine(title, 1.00, 0.82, 0.00)
	if abilityEntry.description and abilityEntry.description ~= "" then
		tooltip:AddLine(" ")
		tooltip:AddLine(tostring(abilityEntry.description), 0.90, 0.90, 0.90, true)
	end
	tooltip:Show()
end
