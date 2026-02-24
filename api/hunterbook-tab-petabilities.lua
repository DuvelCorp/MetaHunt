if type(MTH_HUNTERBOOK_TABS) ~= "table" then MTH_HUNTERBOOK_TABS = {} end

MTH_HUNTERBOOK_TABS.petabilities = {
	headerLabel = "Pet Abilities",
	columnLabels = { "Ability Name", "Ranks", "Families" },
	columnLayout = {
		{ x = 8, width = 160, align = "LEFT" },
		{ x = 170, width = 52, align = "LEFT" },
		{ x = 224, width = 328, align = "LEFT" },
	},
}

MTH_HUNTERBOOK_TABS.abilities = {
	headerLabel = "Pet Abilities",
	columnLabels = { "Ability", "Lvl", "Family", "Beast", "Rare" },
	columnLayout = {
		{ x = 8, width = 112, align = "LEFT" },
		{ x = 120, width = 40, align = "LEFT" },
		{ x = 160, width = 78, align = "LEFT" },
		{ x = 238, width = 142, align = "LEFT" },
		{ x = 380, width = 38, align = "LEFT" },
	},
}

function MTH_BOOK_AbilitySort(a, b)
	if a.ability ~= b.ability then return a.ability < b.ability end
	if a.level ~= b.level then return a.level < b.level end
	if a.name ~= b.name then return a.name < b.name end
	return a.beastId < b.beastId
end

function MTH_BOOK_PetAbilitySort(a, b)
	local aa = MTH_BOOK_SafeLower(a and a.ability)
	local ab = MTH_BOOK_SafeLower(b and b.ability)
	if aa ~= ab then return aa < ab end
	local ra = tonumber(a and a.rankCount) or 0
	local rb = tonumber(b and b.rankCount) or 0
	if ra ~= rb then return ra > rb end
	local fa = tonumber(a and a.familyCount) or 0
	local fb = tonumber(b and b.familyCount) or 0
	if fa ~= fb then return fa > fb end
	return tostring(a and a.familyList or "") < tostring(b and b.familyList or "")
end

function MTH_BOOK_GetSpellRowsForAbility(abilityName)
	if not abilityName or abilityName == "" then return 0 end
	if not (MTH_DS_PetSpells and MTH_DS_PetSpells.byAbility) then return 0 end
	local row = MTH_DS_PetSpells.byAbility[abilityName]
	if not row or not row.spells then return 0 end
	return table.getn(row.spells)
end

function MTH_BOOK_GetSpellCoverageForAbility(abilityName)
	local coverage = {
		ability = abilityName,
		icon = nil,
		spellRows = 0,
		hasBeastLearned = false,
		hasTrainerLearned = false,
		rankCount = 0,
		minRank = nil,
		maxRank = nil,
		minTrainLevel = nil,
		maxTrainLevel = nil,
	}

	if not abilityName or abilityName == "" then return coverage end
	if not (MTH_DS_PetSpells and MTH_DS_PetSpells.byAbility) then return coverage end

	local row = MTH_DS_PetSpells.byAbility[abilityName]
	if not row or not row.spells then return coverage end

	local rankMap = {}
	local hasPositiveRank = false
	for i = 1, table.getn(row.spells) do
		local spell = row.spells[i]
		if spell then
			local rankNumber = tonumber(spell.rankNumber)
			if rankNumber and rankNumber > 0 then
				hasPositiveRank = true
				break
			end
		end
	end

	coverage.spellRows = 0
	for i = 1, table.getn(row.spells) do
		local spell = row.spells[i]
		if spell then
			local rankNumber = tonumber(spell.rankNumber)
			if hasPositiveRank and ((not rankNumber) or rankNumber <= 0) then
				-- Ignore legacy/unranked rows when proper ranked variants exist.
			else
				coverage.spellRows = coverage.spellRows + 1
				local learnMethod = MTH_BOOK_SafeLower(spell.learnMethod)
				if learnMethod == "trainer" then
					coverage.hasTrainerLearned = true
				else
					coverage.hasBeastLearned = true
				end
				if not coverage.icon and spell.icon and spell.icon ~= "" then
					coverage.icon = spell.icon
				end
				if rankNumber and rankNumber > 0 then
					rankMap[rankNumber] = true
					if not coverage.minRank or rankNumber < coverage.minRank then coverage.minRank = rankNumber end
					if not coverage.maxRank or rankNumber > coverage.maxRank then coverage.maxRank = rankNumber end
				end

				local trainLevel = tonumber(spell.trainLevel)
				if trainLevel then
					if not coverage.minTrainLevel or trainLevel < coverage.minTrainLevel then coverage.minTrainLevel = trainLevel end
					if not coverage.maxTrainLevel or trainLevel > coverage.maxTrainLevel then coverage.maxTrainLevel = trainLevel end
				end
			end
		end
	end

	for _ in pairs(rankMap) do
		coverage.rankCount = coverage.rankCount + 1
	end
	if coverage.rankCount == 0 and coverage.spellRows > 0 then
		coverage.rankCount = 1
	end

	return coverage
end

function MTH_BOOK_GetKnownSpellMap()
	if not MTH_CharSavedVariables then return nil end
	if not MTH_CharSavedVariables.petTraining then return nil end
	local petTraining = MTH_CharSavedVariables.petTraining
	if petTraining.hunterKnownMap and petTraining.spellMap then
		for token, isKnown in pairs(petTraining.hunterKnownMap) do
			if isKnown == true then
				local _, _, baseToken = string.find(tostring(token), "^(.-)#%d+$")
				if baseToken and baseToken ~= "" then
					local baseRow = petTraining.spellMap[baseToken]
					if baseRow and ((tonumber(baseRow.rankNumber) or 0) <= 0) then
						baseRow.isKnown = true
					end
				end
			end
		end
	end
	return MTH_CharSavedVariables.petTraining.spellMap
end

function MTH_BOOK_GetKnownRankCountForAbility(abilityName)
	local spellMap = MTH_BOOK_GetKnownSpellMap()
	if not spellMap or not abilityName or abilityName == "" then return 0 end

	local abilityLower = MTH_BOOK_SafeLower(abilityName)
	if abilityLower == "" then return 0 end

	local knownRanks = {}
	for _, row in pairs(spellMap) do
		if row and row.name and (row.isKnown ~= false) then
			if MTH_BOOK_SafeLower(row.name) == abilityLower then
				local rankNumber = tonumber(row.rankNumber) or 0
				knownRanks[rankNumber] = true
			end
		end
	end

	local count = 0
	for _ in pairs(knownRanks) do
		count = count + 1
	end
	return count
end

function MTH_BOOK_IsKnownRankForAbility(abilityName, rankNumber)
	local spellMap = MTH_BOOK_GetKnownSpellMap()
	if not spellMap then return false end
	if not abilityName or abilityName == "" then return false end
	local rankValue = tonumber(rankNumber)

	local abilityLower = MTH_BOOK_SafeLower(abilityName)
	for _, row in pairs(spellMap) do
		if row and row.name and (row.isKnown ~= false) then
			if MTH_BOOK_SafeLower(row.name) == abilityLower then
				local rowRank = tonumber(row.rankNumber)
				if rankValue and rankValue > 0 then
					if rowRank == rankValue then
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

function MTH_BOOK_BuildPetAbilitiesRows(ignoreSearch)
	local spellRows = {}

	if MTH_DS_PetSpells and MTH_DS_PetSpells.byAbility then
		for abilityName in pairs(MTH_DS_PetSpells.byAbility) do
			local ability = tostring(abilityName or "")
			if ability ~= "" then
				local key = MTH_BOOK_SafeLower(ability)
				if key ~= "" then
					spellRows[key] = {
						ability = ability,
						familiesMap = {},
					}
				end
			end
		end
	end

	local function ensureRow(abilityName)
		local ability = tostring(abilityName or "")
		if ability == "" then return nil end
		local key = MTH_BOOK_SafeLower(ability)
		if key == "" then return nil end
		return spellRows[key], key
	end

	if MTH_DS_Families then
		for familyName, row in pairs(MTH_DS_Families) do
			if familyName and familyName ~= "" and row and row.abilities then
				for i = 1, table.getn(row.abilities) do
					local ability = row.abilities[i]
					local spellRow = ensureRow(ability)
					if spellRow then
						spellRow.familiesMap[familyName] = true
					end
				end
			end
		end
	end

	if MTH_DS_Beasts then
		for _, beast in pairs(MTH_DS_Beasts) do
			if beast and beast.family and beast.family ~= "" then
				local tokens = MTH_BOOK_SplitAbilities(beast.abilities)
				for i = 1, table.getn(tokens) do
					local _, abilityName = MTH_BOOK_ParseAbilityToken(tokens[i])
					local spellRow = ensureRow(abilityName)
					if spellRow then
						spellRow.familiesMap[beast.family] = true
					end
				end
			end
		end
	end

	local results = {}
	for _, row in pairs(spellRows) do
		local coverage = MTH_BOOK_GetSpellCoverageForAbility(row.ability)
		local families = {}
		for familyName in pairs(row.familiesMap or {}) do
			table.insert(families, familyName)
		end
		table.sort(families, function(a, b)
			return MTH_BOOK_SafeLower(a) < MTH_BOOK_SafeLower(b)
		end)

		local rankCount = tonumber(coverage.rankCount) or 0
		local knownRankCount = MTH_BOOK_GetKnownRankCountForAbility(row.ability)
		local minRank = coverage.minRank
		local maxRank = coverage.maxRank
		local minTrainLevel = coverage.minTrainLevel
		local maxTrainLevel = coverage.maxTrainLevel
		if MTH_BOOK_STATE.petOnlyMyLevel then
			knownRankCount, rankCount, minRank, maxRank, minTrainLevel, maxTrainLevel = MTH_BOOK_GetScopedRankSummary(row.ability)
		end
		if knownRankCount > rankCount then knownRankCount = rankCount end
		local rankText = tostring(knownRankCount) .. "/" .. tostring(rankCount)

		local sourceFilter = tostring(MTH_BOOK_STATE.petLearnSource or "all")
		local sourceMatch = true
		if sourceFilter == "beast" then
			sourceMatch = coverage.hasBeastLearned and true or false
		elseif sourceFilter == "trainer" then
			sourceMatch = coverage.hasTrainerLearned and true or false
		end

		local familyList = table.concat(families, ", ")
		local searchable = MTH_BOOK_SafeLower(tostring(row.ability or "") .. " " .. familyList)
		if sourceMatch and rankCount > 0 and (ignoreSearch or MTH_BOOK_STATE.search == "" or string.find(searchable, MTH_BOOK_STATE.search, 1, true) ~= nil) then
			table.insert(results, {
				ability = row.ability,
				icon = coverage.icon,
				knownRankCount = knownRankCount,
				rankCount = rankCount,
				rankText = rankText,
				families = families,
				familyCount = table.getn(families),
				familyList = familyList,
				spellRows = coverage.spellRows or 0,
				minRank = minRank,
				maxRank = maxRank,
				minTrainLevel = minTrainLevel,
				maxTrainLevel = maxTrainLevel,
				hasBeastLearned = coverage.hasBeastLearned,
				hasTrainerLearned = coverage.hasTrainerLearned,
			})
		end
	end

	table.sort(results, MTH_BOOK_PetAbilitySort)
	return results
end

function MTH_BOOK_BuildPetAbilityRankRows(entry)
	local rows = {}
	if not entry or not entry.ability then return rows end
	if not (MTH_DS_PetSpells and MTH_DS_PetSpells.byAbility) then return rows end

	local spellBucket = MTH_DS_PetSpells.byAbility[entry.ability]
	if not spellBucket or not spellBucket.spells then return rows end

	local hasPositiveRank = false
	for i = 1, table.getn(spellBucket.spells) do
		local spell = spellBucket.spells[i]
		if spell then
			local rankNumber = tonumber(spell.rankNumber)
			if rankNumber and rankNumber > 0 then
				hasPositiveRank = true
				break
			end
		end
	end

	for i = 1, table.getn(spellBucket.spells) do
		local spell = spellBucket.spells[i]
		if spell then
			local rankNumber = tonumber(spell.rankNumber)
			if not rankNumber and spell.rank then
				local _, _, parsed = string.find(tostring(spell.rank), "(%d+)")
				rankNumber = tonumber(parsed)
			end
			if hasPositiveRank and ((not rankNumber) or rankNumber <= 0) then
				-- Ignore legacy/unranked rows when proper ranked variants exist.
			elseif MTH_BOOK_IsSpellInLevelScope(tonumber(spell.trainLevel)) then
				table.insert(rows, {
					id = spell.id,
					ability = entry.ability,
					icon = spell.icon or spell.iconName or spell.texture or spell.iconTexture or entry.icon,
					rankNumber = rankNumber,
					isKnown = MTH_BOOK_IsKnownRankForAbility(entry.ability, rankNumber),
					trainLevel = tonumber(spell.trainLevel),
					description = spell.description,
					cost = spell.cost,
					castTime = spell.castTime,
					range = spell.range,
					school = spell.school,
					effects = spell.effects,
					sourceUrl = spell.sourceUrl,
				})
			end
		end
	end

	table.sort(rows, function(a, b)
		local ra = a.rankNumber or 0
		local rb = b.rankNumber or 0
		if ra ~= rb then return ra < rb end
		local la = a.trainLevel or 0
		local lb = b.trainLevel or 0
		if la ~= lb then return la < lb end
		return (tonumber(a.id) or 0) < (tonumber(b.id) or 0)
	end)

	return rows
end

function MTH_BOOK_GetRankLabel(rankNumber, includePrefix)
	local rankValue = tonumber(rankNumber)
	if rankValue and rankValue > 0 then
		if includePrefix then
			return "Rank " .. tostring(rankValue)
		end
		return tostring(rankValue)
	end
	if includePrefix then
		return "Unranked"
	end
	return "None"
end

function MTH_BOOKTAB_EnsurePetAbilitiesUI(listParent, detailParent)
	if MTH_BOOK_STATE.petUI then return end
	if not listParent or not detailParent then return end

	local ui = {}

	ui.leftPane = CreateFrame("Frame", nil, listParent)
	ui.leftPane:SetPoint("TOPLEFT", listParent, "TOPLEFT", 4, -4)
	ui.leftPane:SetWidth(162)
	ui.leftPane:SetHeight(346)

	ui.rightPane = CreateFrame("Frame", nil, listParent)
	ui.rightPane:SetPoint("TOPLEFT", ui.leftPane, "TOPRIGHT", 8, 0)
	ui.rightPane:SetWidth(390)
	ui.rightPane:SetHeight(346)

	ui.vSplit = listParent:CreateTexture(nil, "BORDER")
	ui.vSplit:SetTexture("Interface\\Buttons\\WHITE8X8")
	ui.vSplit:SetVertexColor(0.30, 0.30, 0.30, 0.60)
	ui.vSplit:SetPoint("TOPLEFT", ui.leftPane, "TOPRIGHT", 4, -2)
	ui.vSplit:SetPoint("BOTTOMLEFT", ui.leftPane, "BOTTOMRIGHT", 4, 2)
	ui.vSplit:SetWidth(1)

	ui.leftHeaderAbility = ui.leftPane:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	ui.leftHeaderAbility:SetPoint("TOPLEFT", ui.leftPane, "TOPLEFT", 24, -6)
	ui.leftHeaderAbility:SetWidth(102)
	ui.leftHeaderAbility:SetJustifyH("LEFT")
	ui.leftHeaderAbility:SetTextColor(1.00, 0.82, 0.00)
	ui.leftHeaderAbility:SetText("Ability")

	ui.leftHeaderRank = ui.leftPane:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	ui.leftHeaderRank:SetPoint("TOPLEFT", ui.leftPane, "TOPLEFT", 126, -6)
	ui.leftHeaderRank:SetWidth(28)
	ui.leftHeaderRank:SetJustifyH("LEFT")
	ui.leftHeaderRank:SetTextColor(1.00, 0.82, 0.00)
	ui.leftHeaderRank:SetText("K/T")

	ui.rightHeaderRank = ui.rightPane:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	ui.rightHeaderRank:SetPoint("TOPLEFT", ui.rightPane, "TOPLEFT", 2, -6)
	ui.rightHeaderRank:SetWidth(36)
	ui.rightHeaderRank:SetJustifyH("LEFT")
	ui.rightHeaderRank:SetTextColor(1.00, 0.82, 0.00)
	ui.rightHeaderRank:SetText("Rank")

	ui.rightHeaderLevel = ui.rightPane:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	ui.rightHeaderKnown = ui.rightPane:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	ui.rightHeaderKnown:SetPoint("TOPLEFT", ui.rightPane, "TOPLEFT", 34, -6)
	ui.rightHeaderKnown:SetWidth(22)
	ui.rightHeaderKnown:SetJustifyH("LEFT")
	ui.rightHeaderKnown:SetTextColor(1.00, 0.82, 0.00)
	ui.rightHeaderKnown:SetText("K?")

	ui.rightHeaderLevel:SetPoint("TOPLEFT", ui.rightPane, "TOPLEFT", 58, -6)
	ui.rightHeaderLevel:SetWidth(40)
	ui.rightHeaderLevel:SetJustifyH("LEFT")
	ui.rightHeaderLevel:SetTextColor(1.00, 0.82, 0.00)
	ui.rightHeaderLevel:SetText("Lvl")

	ui.rightHeaderDesc = ui.rightPane:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	ui.rightHeaderDesc:SetPoint("TOPLEFT", ui.rightPane, "TOPLEFT", 98, -6)
	ui.rightHeaderDesc:SetWidth(286)
	ui.rightHeaderDesc:SetJustifyH("LEFT")
	ui.rightHeaderDesc:SetTextColor(1.00, 0.82, 0.00)
	ui.rightHeaderDesc:SetText("Description")

	ui.leftRowsVisible = 20

	ui.leftScroll = CreateFrame("Slider", "MTH_BOOK_PetLeftScroll", ui.leftPane, "UIPanelScrollBarTemplate")
	ui.leftScroll:SetPoint("TOPRIGHT", ui.leftPane, "TOPRIGHT", -2, -22)
	ui.leftScroll:SetPoint("BOTTOMRIGHT", ui.leftPane, "BOTTOMRIGHT", -2, 20)
	ui.leftScroll:SetWidth(16)
	if not getglobal("MTH_BOOK_PetLeftScrollScrollFrame") then
		local leftScrollShim = CreateFrame("ScrollFrame", "MTH_BOOK_PetLeftScrollScrollFrame", ui.leftPane)
		leftScrollShim:SetPoint("TOPLEFT", ui.leftPane, "TOPLEFT", 0, 0)
		leftScrollShim:SetWidth(1)
		leftScrollShim:SetHeight(1)
		leftScrollShim:Hide()
	end
	ui.leftScroll:SetScript("OnValueChanged", function()
		local val = this:GetValue() or 0
		val = math.floor(val + 0.5)
		if val ~= MTH_BOOK_STATE.petLeftOffset then
			MTH_BOOK_STATE.petLeftOffset = val
			MTH_BOOK_UpdatePetAbilitiesLists()
		end
	end)
	ui.leftScroll:SetMinMaxValues(0, 0)
	ui.leftScroll:SetValueStep(1)
	ui.leftScroll:SetValue(0)

	ui.leftPane:EnableMouseWheel(true)
	ui.leftPane:SetScript("OnMouseWheel", function()
		local delta = arg1 or 0
		if delta == 0 then return end
		local current = tonumber(MTH_BOOK_STATE.petLeftOffset or 0) or 0
		if delta < 0 then
			current = current + 1
		else
			current = current - 1
		end
		if current < 0 then current = 0 end
		local maxOffset = 0
		if MTH_BOOK_STATE.results then
			maxOffset = math.max(0, table.getn(MTH_BOOK_STATE.results) - table.getn(ui.leftButtons or {}))
		end
		if current > maxOffset then current = maxOffset end
		MTH_BOOK_STATE.petLeftOffset = current
		if ui.leftScroll then
			ui.leftScroll:SetValue(current)
		end
		MTH_BOOK_UpdatePetAbilitiesLists()
	end)

	ui.leftButtons = {}
	local leftY = -24
	for i = 1, ui.leftRowsVisible do
		local btn = CreateFrame("Button", nil, ui.leftPane)
		btn:SetPoint("TOPLEFT", ui.leftPane, "TOPLEFT", 0, leftY)
		btn:SetWidth(144)
		btn:SetHeight(19)
		btn.entry = nil

		btn.selected = btn:CreateTexture(nil, "BACKGROUND")
		btn.selected:SetAllPoints(btn)
		btn.selected:SetTexture("Interface\\Buttons\\WHITE8X8")
		btn.selected:SetVertexColor(0.18, 0.35, 0.55, 0.35)
		btn.selected:Hide()

		local hl = btn:CreateTexture(nil, "HIGHLIGHT")
		hl:SetAllPoints(btn)
		hl:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
		hl:SetBlendMode("ADD")
		hl:SetAlpha(0.30)

		btn.ability = btn:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
		btn.ability:SetPoint("LEFT", btn, "LEFT", 24, 0)
		btn.ability:SetWidth(100)
		btn.ability:SetJustifyH("LEFT")

		btn.rank = btn:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
		btn.rank:SetPoint("LEFT", btn, "LEFT", 126, 0)
		btn.rank:SetWidth(26)
		btn.rank:SetJustifyH("LEFT")

		btn.icon = btn:CreateTexture(nil, "ARTWORK")
		btn.icon:SetPoint("LEFT", btn, "LEFT", 2, 0)
		btn.icon:SetWidth(16)
		btn.icon:SetHeight(16)

		btn:SetScript("OnClick", function()
			if not this.entry then return end
			MTH_BOOK_STATE.selectedEntry = this.entry
			MTH_BOOK_STATE.selectedPetRankEntry = nil
			MTH_BOOK_STATE.petRankRows = MTH_BOOK_BuildPetAbilityRankRows(this.entry)
			MTH_BOOK_UpdateResults()
		end)
		btn:SetScript("OnEnter", function()
			if this and this.entry then
				MTH_BOOK_ShowBaselineTooltip(this, this.entry)
			end
		end)
		btn:SetScript("OnLeave", function()
			MTH_BOOK_HideSpellTooltip()
		end)

		ui.leftButtons[i] = btn
		leftY = leftY - 20
	end

	local footerParent = listParent:GetParent() or listParent
	ui.recapText = footerParent:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	ui.recapText:SetPoint("TOPLEFT", footerParent, "TOPLEFT", 20, -530)
	ui.recapText:SetWidth(190)
	ui.recapText:SetJustifyH("LEFT")
	ui.recapText:SetTextColor(1.00, 0.82, 0.00)
	ui.recapText:SetText("Abilities 0 | Known 0/0")

	ui.progressBackdrop = CreateFrame("Frame", nil, footerParent)
	ui.progressBackdrop:SetPoint("LEFT", ui.recapText, "RIGHT", 8, 0)
	ui.progressBackdrop:SetWidth(320)
	ui.progressBackdrop:SetHeight(14)
	ui.progressBackdrop:SetFrameLevel(footerParent:GetFrameLevel() + 3)
	ui.progressBackdrop:SetBackdrop({
		bgFile = "Interface\\Buttons\\WHITE8X8",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true,
		tileSize = 8,
		edgeSize = 8,
		insets = { left = 2, right = 2, top = 2, bottom = 2 },
	})
	ui.progressBackdrop:SetBackdropColor(0.08, 0.08, 0.08, 0.95)
	ui.progressBackdrop:SetBackdropBorderColor(0.24, 0.24, 0.24, 0.90)

	ui.progressBar = CreateFrame("StatusBar", nil, ui.progressBackdrop)
	ui.progressBar:SetPoint("TOPLEFT", ui.progressBackdrop, "TOPLEFT", 2, -2)
	ui.progressBar:SetPoint("BOTTOMRIGHT", ui.progressBackdrop, "BOTTOMRIGHT", -2, 2)
	ui.progressBar:SetStatusBarTexture("Interface\\Buttons\\WHITE8X8")
	ui.progressBar:SetStatusBarColor(0.18, 0.75, 0.22, 0.9)
	ui.progressBar:SetMinMaxValues(0, 1)
	ui.progressBar:SetValue(0)

	ui.progressText = ui.progressBackdrop:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	ui.progressText:SetPoint("CENTER", ui.progressBackdrop, "CENTER", 0, 0)
	ui.progressText:SetTextColor(1.00, 1.00, 1.00)
	ui.progressText:SetText("0%")

	ui.rightButtons = {}
	local rightRowsVisible = 10
	local rightRowHeight = 36
	local rightRowStep = 37
	local rightY = -24
	for i = 1, rightRowsVisible do
		local btn = CreateFrame("Button", nil, ui.rightPane)
		btn:SetPoint("TOPLEFT", ui.rightPane, "TOPLEFT", 0, rightY)
		btn:SetWidth(388)
		btn:SetHeight(rightRowHeight)
		btn.entry = nil

		btn.selected = btn:CreateTexture(nil, "BACKGROUND")
		btn.selected:SetAllPoints(btn)
		btn.selected:SetTexture("Interface\\Buttons\\WHITE8X8")
		btn.selected:SetVertexColor(0.18, 0.35, 0.55, 0.35)
		btn.selected:Hide()

		local hl = btn:CreateTexture(nil, "HIGHLIGHT")
		hl:SetAllPoints(btn)
		hl:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
		hl:SetBlendMode("ADD")
		hl:SetAlpha(0.28)

		btn.rank = btn:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
		btn.rank:SetPoint("LEFT", btn, "LEFT", 2, 1)
		btn.rank:SetWidth(30)
		btn.rank:SetJustifyH("LEFT")

		btn.knownIcon = btn:CreateTexture(nil, "ARTWORK")
		btn.knownIcon:SetPoint("LEFT", btn, "LEFT", 38, 1)
		btn.knownIcon:SetWidth(12)
		btn.knownIcon:SetHeight(12)
		btn.knownIcon:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
		btn.knownIcon:SetVertexColor(0.18, 0.90, 0.18, 1.00)
		btn.knownIcon:Hide()

		btn.level = btn:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
		btn.level:SetPoint("LEFT", btn, "LEFT", 58, 1)
		btn.level:SetWidth(40)
		btn.level:SetJustifyH("LEFT")

		btn.desc = btn:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
		btn.desc:SetPoint("LEFT", btn, "LEFT", 98, 1)
		btn.desc:SetWidth(286)
		btn.desc:SetJustifyH("LEFT")

		btn:SetScript("OnClick", function()
			if not this.entry then return end
			MTH_BOOK_STATE.selectedPetRankEntry = this.entry
			MTH_BOOK_UpdateDetail()
			MTH_BOOK_UpdateResults()
		end)
		btn:SetScript("OnEnter", function()
			if this and this.entry then
				MTH_BOOK_ShowRankTooltip(this, this.entry)
			end
		end)
		btn:SetScript("OnLeave", function()
			MTH_BOOK_HideSpellTooltip()
		end)

		ui.rightButtons[i] = btn
		rightY = rightY - rightRowStep
	end

	ui.detailTitleTop = detailParent:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	ui.detailTitleTop:SetPoint("TOPLEFT", detailParent, "TOPLEFT", 8, -8)
	ui.detailTitleTop:SetWidth(120)
	ui.detailTitleTop:SetJustifyH("LEFT")
	ui.detailTitleTop:SetTextColor(1.00, 0.82, 0.00)
	ui.detailTitleTop:SetText("Spell baseline")

	ui.detailTop = CreateFrame("EditBox", nil, detailParent)
	ui.detailTop:SetMultiLine(true)
	ui.detailTop:SetAutoFocus(false)
	ui.detailTop:SetPoint("TOPLEFT", ui.detailTitleTop, "BOTTOMLEFT", 0, -4)
	ui.detailTop:SetWidth(120)
	ui.detailTop:SetHeight(132)

	ui.detailTopIcon = detailParent:CreateTexture(nil, "ARTWORK")
	ui.detailTopIcon:SetPoint("TOPRIGHT", ui.detailTop, "TOPRIGHT", -4, -4)
	ui.detailTopIcon:SetWidth(16)
	ui.detailTopIcon:SetHeight(16)
	ui.detailTopIcon:Hide()

	ui.detailTitleBottom = detailParent:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	ui.detailTitleBottom:SetPoint("TOPLEFT", ui.detailTop, "BOTTOMLEFT", 0, -8)
	ui.detailTitleBottom:SetWidth(120)
	ui.detailTitleBottom:SetJustifyH("LEFT")
	ui.detailTitleBottom:SetTextColor(1.00, 0.82, 0.00)
	ui.detailTitleBottom:SetText("Current Rank")

	ui.detailBottom = CreateFrame("EditBox", nil, detailParent)
	ui.detailBottom:SetMultiLine(true)
	ui.detailBottom:SetAutoFocus(false)
	ui.detailBottom:SetPoint("TOPLEFT", ui.detailTitleBottom, "BOTTOMLEFT", 0, -4)
	ui.detailBottom:SetWidth(120)
	ui.detailBottom:SetHeight(116)

	MTH_BOOK_ConfigureReadOnlyEditBox(ui.detailTop)
	MTH_BOOK_ConfigureReadOnlyEditBox(ui.detailBottom)
	if ui.detailTop.SetTextColor then ui.detailTop:SetTextColor(1.00, 1.00, 1.00) end
	if ui.detailBottom.SetTextColor then ui.detailBottom:SetTextColor(1.00, 1.00, 1.00) end

	MTH_BOOK_STATE.petUI = ui
end

function MTH_BOOKTAB_SetPetAbilitiesUIVisible(visible)
	local ui = MTH_BOOK_STATE.petUI
	if not ui then return end

	local detail = getglobal("MTH_BOOK_DetailBackdropDetailText")
	if detail then
		if visible then detail:Hide() else detail:Show() end
	end

	local widgets = {
		ui.leftPane,
		ui.leftScroll,
		ui.rightPane,
		ui.vSplit,
		ui.leftHeaderAbility,
		ui.leftHeaderRank,
		ui.rightHeaderRank,
		ui.rightHeaderKnown,
		ui.rightHeaderLevel,
		ui.rightHeaderDesc,
		ui.recapText,
		ui.progressBackdrop,
		ui.detailTop,
		ui.detailBottom,
		ui.detailTitleTop,
		ui.detailTitleBottom,
	}

	for i = 1, table.getn(widgets) do
		local widget = widgets[i]
		if widget and widget.Show and widget.Hide then
			if visible then widget:Show() else widget:Hide() end
		end
	end

	if ui.detailTopIcon and not visible then
		ui.detailTopIcon:Hide()
	end

	if not visible then
		MTH_BOOK_HideSpellTooltip()
	end
end

function MTH_BOOKTAB_UpdatePetAbilitiesLists()
	local ui = MTH_BOOK_STATE.petUI
	if not ui then return end

	local resultCount = table.getn(MTH_BOOK_STATE.results)
	local visibleRows = table.getn(ui.leftButtons)
	local maxOffset = math.max(0, resultCount - visibleRows)
	if MTH_BOOK_STATE.petLeftOffset < 0 then MTH_BOOK_STATE.petLeftOffset = 0 end
	if MTH_BOOK_STATE.petLeftOffset > maxOffset then MTH_BOOK_STATE.petLeftOffset = maxOffset end
	if ui.leftScroll then
		ui.leftScroll:SetMinMaxValues(0, maxOffset)
		ui.leftScroll:SetValueStep(1)
		ui.leftScroll:SetValue(MTH_BOOK_STATE.petLeftOffset)
		local upButton = getglobal("MTH_BOOK_PetLeftScrollScrollUpButton")
		local downButton = getglobal("MTH_BOOK_PetLeftScrollScrollDownButton")
		if upButton then
			if MTH_BOOK_STATE.petLeftOffset > 0 then
				upButton:EnableMouse(true)
				upButton:SetAlpha(1)
			else
				upButton:EnableMouse(false)
				upButton:SetAlpha(0.35)
			end
		end
		if downButton then
			if MTH_BOOK_STATE.petLeftOffset < maxOffset then
				downButton:EnableMouse(true)
				downButton:SetAlpha(1)
			else
				downButton:EnableMouse(false)
				downButton:SetAlpha(0.35)
			end
		end
		if maxOffset > 0 then
			ui.leftScroll:SetAlpha(1)
			ui.leftScroll:Show()
		else
			ui.leftScroll:SetAlpha(1)
			ui.leftScroll:Hide()
		end
	end

	local startIndex = MTH_BOOK_STATE.petLeftOffset + 1
	for i = 1, visibleRows do
		local btn = ui.leftButtons[i]
		if btn then
			local rowIndex = startIndex + i - 1
			local entry = MTH_BOOK_STATE.results[rowIndex]
			btn.entry = entry
			if entry then
				if btn.icon then
					if entry.icon and entry.icon ~= "" then
						if string.find(entry.icon, "\\", 1, true) then
							btn.icon:SetTexture(entry.icon)
						else
							btn.icon:SetTexture("Interface\\Icons\\" .. tostring(entry.icon))
						end
						btn.icon:Show()
					else
						btn.icon:Hide()
					end
				end
				btn.ability:SetText(tostring(entry.ability or "?"))
				btn.rank:SetText(tostring(entry.rankText or ""))
				btn.ability:SetTextColor(0.92, 0.92, 0.92)
				btn.rank:SetTextColor(0.92, 0.92, 0.92)
				if btn.icon then btn.icon:SetVertexColor(1, 1, 1, 1) end
				if MTH_BOOK_STATE.selectedEntry and MTH_BOOK_STATE.selectedEntry.ability == entry.ability then
					btn.selected:Show()
				else
					btn.selected:Hide()
				end
				btn:Show()
			else
				if btn.icon then btn.icon:Hide() end
				btn.ability:SetText("")
				btn.rank:SetText("")
				btn.selected:Hide()
				btn:Hide()
			end
		end
	end

	local totalKnown = 0
	local totalRanks = 0
	for i = 1, resultCount do
		local entry = MTH_BOOK_STATE.results[i]
		if entry then
			totalKnown = totalKnown + (tonumber(entry.knownRankCount) or 0)
			totalRanks = totalRanks + (tonumber(entry.rankCount) or 0)
		end
	end
	if ui.recapText then
		ui.recapText:SetText("Abilities " .. tostring(resultCount) .. " | Known " .. tostring(totalKnown) .. "/" .. tostring(totalRanks))
	end
	if ui.progressBar then
		ui.progressBar:SetMinMaxValues(0, math.max(1, totalRanks))
		ui.progressBar:SetValue(totalKnown)
	end
	if ui.progressText then
		local pct = 0
		if totalRanks > 0 then
			pct = math.floor((totalKnown / totalRanks) * 100 + 0.5)
		end
		ui.progressText:SetText(tostring(pct) .. "%")
	end

	if MTH_BOOK_STATE.selectedEntry then
		local keep = false
		for i = 1, table.getn(MTH_BOOK_STATE.results) do
			local row = MTH_BOOK_STATE.results[i]
			if row and row.ability == MTH_BOOK_STATE.selectedEntry.ability then
				MTH_BOOK_STATE.selectedEntry = row
				keep = true
				break
			end
		end
		if not keep then
			MTH_BOOK_STATE.selectedEntry = nil
			MTH_BOOK_STATE.selectedPetRankEntry = nil
		end
	end

	MTH_BOOK_STATE.petRankRows = MTH_BOOK_BuildPetAbilityRankRows(MTH_BOOK_STATE.selectedEntry)

	for i = 1, table.getn(ui.rightButtons) do
		local btn = ui.rightButtons[i]
		if btn then
			local entry = MTH_BOOK_STATE.petRankRows[i]
			btn.entry = entry
			if entry then
				btn.rank:SetText(MTH_BOOK_GetRankLabel(entry.rankNumber, false))
				if btn.knownIcon then
					if entry.isKnown then
						btn.knownIcon:Show()
					else
						btn.knownIcon:Hide()
					end
				end
				btn.level:SetText(entry.trainLevel and tostring(entry.trainLevel) or "-")
				btn.desc:SetText(tostring(entry.description or "-"))
				if MTH_BOOK_STATE.selectedPetRankEntry and MTH_BOOK_STATE.selectedPetRankEntry.id == entry.id then
					btn.selected:Show()
				else
					btn.selected:Hide()
				end
				btn:Show()
			else
				btn.rank:SetText("")
				if btn.knownIcon then btn.knownIcon:Hide() end
				btn.level:SetText("")
				btn.desc:SetText("")
				btn.selected:Hide()
				btn:Hide()
			end
		end
	end
end
