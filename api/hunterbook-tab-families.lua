if type(MTH_HUNTERBOOK_TABS) ~= "table" then MTH_HUNTERBOOK_TABS = {} end

MTH_HUNTERBOOK_TABS.families = {
	headerLabel = "Families",
	columnLabels = { "Family", "Named", "Coords", "Abilities", "Diet", "HP", "dmg", "Arm" },
	columnLayout = {
		{ x = 10, width = 100, align = "LEFT" },
		{ x = 114, width = 38, align = "LEFT" },
		{ x = 154, width = 38, align = "LEFT" },
		{ x = 196, width = 364, align = "LEFT" },
		{ x = 496, width = 102, align = "LEFT" },
		{ x = 602, width = 30, align = "CENTER" },
		{ x = 636, width = 36, align = "CENTER" },
		{ x = 674, width = 38, align = "CENTER" },
	},
}

local function MTH_BOOKTAB_FamiliesTrace(message)
end

local function MTH_BOOKTAB_FamiliesSafeLower(value)
	return string.lower(tostring(value or ""))
end

local function MTH_BOOKTAB_FamiliesTrim(value)
	local text = tostring(value or "")
	text = string.gsub(text, "^%s+", "")
	text = string.gsub(text, "%s+$", "")
	return text
end

local function MTH_BOOKTAB_FormatFamilyStat(value)
	local numeric = tonumber(value)
	if not numeric then
		return "-"
	end
	local colorPrefix = "|cFF4DA6FF"
	if numeric < 1 then
		colorPrefix = "|cFFFF4040"
	elseif numeric > 1 then
		colorPrefix = "|cFF40FF40"
	end
	local text = nil
	if MTH_BOOK_STATE and MTH_BOOK_STATE.familyStatsPercent == true then
		text = tostring(math.floor((numeric * 100) + 0.5)) .. "%"
		return colorPrefix .. text .. "|r"
	end
	text = string.format("%.3f", numeric)
	text = string.gsub(text, "(%..-)0+$", "%1")
	text = string.gsub(text, "%.$", "")
	return colorPrefix .. text .. "|r"
end

local function MTH_BOOKTAB_ShouldDisplayAllDiet(familyName)
	local token = MTH_BOOKTAB_FamiliesSafeLower(MTH_BOOKTAB_FamiliesTrim(familyName))
	return token == "bears" or token == "boars"
end

local function MTH_BOOKTAB_FindAbilityBundle(abilityName)
	if not (MTH_DS_PetSpells and type(MTH_DS_PetSpells.byAbility) == "table") then
		return nil
	end
	local direct = MTH_DS_PetSpells.byAbility[abilityName]
	if type(direct) == "table" then
		return direct
	end
	local wanted = MTH_BOOKTAB_FamiliesSafeLower(abilityName)
	for key, bundle in pairs(MTH_DS_PetSpells.byAbility) do
		if MTH_BOOKTAB_FamiliesSafeLower(key) == wanted then
			return bundle
		end
	end
	return nil
end

function MTH_BOOKTAB_BuildFamiliesRows()
	local results = {}
	local families = MTH_DS_Families
	local beasts = MTH_DS_Beasts
	if type(families) ~= "table" then
		return results
	end

	local abilityCounts = {}
	local canonicalMap = {}
	local familyCounts = {}

	if type(beasts) == "table" then
		for _, beastRow in pairs(beasts) do
			if type(beastRow) == "table" then
				local familyName = MTH_BOOKTAB_FamiliesTrim(beastRow.family)
				if familyName ~= "" then
					local counts = familyCounts[familyName]
					if not counts then
						counts = { named = 0, coords = 0 }
						familyCounts[familyName] = counts
					end
					counts.named = counts.named + 1

					if type(beastRow.coords) == "table" then
						for coordIndex = 1, table.getn(beastRow.coords) do
							local coord = beastRow.coords[coordIndex]
							if type(coord) == "table" then
								if coord[1] ~= nil and coord[2] ~= nil then
									counts.coords = counts.coords + 1
								end
							end
						end
					end
				end
			end
		end
	end

	for _, familyRow in pairs(families) do
		if type(familyRow) == "table" and type(familyRow.abilities) == "table" then
			local seenInFamily = {}
			for i = 1, table.getn(familyRow.abilities) do
				local rawName = MTH_BOOKTAB_FamiliesTrim(familyRow.abilities[i])
				if rawName ~= "" then
					local bundle = MTH_BOOKTAB_FindAbilityBundle(rawName)
					local canonical = rawName
					if type(bundle) == "table" and type(bundle.ability) == "string" and bundle.ability ~= "" then
						canonical = bundle.ability
					end
					local token = MTH_BOOKTAB_FamiliesSafeLower(canonical)
					if token ~= "" and not seenInFamily[token] then
						seenInFamily[token] = true
						abilityCounts[token] = (abilityCounts[token] or 0) + 1
						canonicalMap[token] = canonical
					end
				end
			end
		end
	end

	for familyName, familyRow in pairs(families) do
		if type(familyRow) == "table" then
			local beastCounts = familyCounts[familyName] or nil
			MTH_BOOKTAB_FamiliesTrace("BUILD " .. tostring(familyName) .. " icon=" .. tostring(familyRow.icon))
			local abilities = {}
			local seen = {}

			if type(familyRow.abilities) == "table" then
				for i = 1, table.getn(familyRow.abilities) do
					local rawName = MTH_BOOKTAB_FamiliesTrim(familyRow.abilities[i])
					if rawName ~= "" then
						local bundle = MTH_BOOKTAB_FindAbilityBundle(rawName)
						local canonical = rawName
						if type(bundle) == "table" and type(bundle.ability) == "string" and bundle.ability ~= "" then
							canonical = bundle.ability
						end

						local token = MTH_BOOKTAB_FamiliesSafeLower(canonical)
						if token ~= "" and not seen[token] then
							seen[token] = true
							local spellRows = (type(bundle) == "table" and type(bundle.spells) == "table") and bundle.spells or {}
							local firstAnySpell = nil
							local firstBeastSpell = nil
							local beastRankMin = nil
							local beastRankMax = nil
							local beastRankMap = {}
							local anyRankMin = nil
							local anyRankMax = nil
							local anyRankMap = {}
							for s = 1, table.getn(spellRows) do
								local spell = spellRows[s]
								if type(spell) == "table" then
									if not firstAnySpell then
										firstAnySpell = spell
									end
									local rank = tonumber(spell.rankNumber)
									if rank and rank > 0 then
										anyRankMap[rank] = true
										if not anyRankMin or rank < anyRankMin then anyRankMin = rank end
										if not anyRankMax or rank > anyRankMax then anyRankMax = rank end
									end
									if MTH_BOOKTAB_FamiliesSafeLower(spell.learnMethod or "beast") ~= "trainer" then
										if not firstBeastSpell then
											firstBeastSpell = spell
										end
										if rank and rank > 0 then
											beastRankMap[rank] = true
											if not beastRankMin or rank < beastRankMin then beastRankMin = rank end
											if not beastRankMax or rank > beastRankMax then beastRankMax = rank end
										end
									end
								end
							end

							local displaySpell = firstBeastSpell or firstAnySpell
							local rankMap = beastRankMap
							local rankMin = beastRankMin
							local rankMax = beastRankMax
							if not firstBeastSpell then
								rankMap = anyRankMap
								rankMin = anyRankMin
								rankMax = anyRankMax
							end

							local rankCount = 0
							for _ in pairs(rankMap) do
								rankCount = rankCount + 1
							end

							table.insert(abilities, {
								name = canonicalMap[token] or canonical,
								token = token,
								isUnique = (abilityCounts[token] or 0) == 1,
								icon = displaySpell and displaySpell.icon or nil,
								description = displaySpell and displaySpell.description or "",
								rankMin = rankMin,
								rankMax = rankMax,
								rankCount = rankCount,
							})
						end
					end
				end
			end

			table.sort(abilities, function(a, b)
				if a.isUnique ~= b.isUnique then
					return a.isUnique and true or false
				end
				return MTH_BOOKTAB_FamiliesSafeLower(a.name) < MTH_BOOKTAB_FamiliesSafeLower(b.name)
			end)

			local dietText = ""
			local stats = type(familyRow.stats) == "table" and familyRow.stats or nil
			local healthStat = stats and tonumber(stats.health) or nil
			local damageStat = stats and tonumber(stats.damage) or nil
			local armorStat = stats and tonumber(stats.armor) or nil
			if MTH_BOOKTAB_ShouldDisplayAllDiet(familyName) then
				dietText = "ALL"
			else
				local dietItems = {}
				if type(familyRow.food) == "table" then
					for i = 1, table.getn(familyRow.food) do
						local food = MTH_BOOKTAB_FamiliesTrim(familyRow.food[i])
						local token = MTH_BOOKTAB_FamiliesSafeLower(food)
						if food ~= "" and token ~= "raw fish" and token ~= "raw meat" then
							table.insert(dietItems, string.upper(string.sub(food, 1, 1)) .. string.sub(food, 2))
						end
					end
					table.sort(dietItems, function(a, b)
						return MTH_BOOKTAB_FamiliesSafeLower(a) < MTH_BOOKTAB_FamiliesSafeLower(b)
					end)
				end
				dietText = table.concat(dietItems, "|")
			end

			table.insert(results, {
				family = tostring(familyName),
				icon = familyRow.icon or nil,
				named = beastCounts and (tonumber(beastCounts.named) or 0) or 0,
				coords = beastCounts and (tonumber(beastCounts.coords) or 0) or 0,
				abilities = abilities,
				dietText = dietText,
				healthStat = healthStat,
				healthText = MTH_BOOKTAB_FormatFamilyStat(healthStat),
				damageStat = damageStat,
				damageText = MTH_BOOKTAB_FormatFamilyStat(damageStat),
				armorStat = armorStat,
				armorText = MTH_BOOKTAB_FormatFamilyStat(armorStat),
			})
		end
	end

	table.sort(results, function(a, b)
		return MTH_BOOKTAB_FamiliesSafeLower(a.family) < MTH_BOOKTAB_FamiliesSafeLower(b.family)
	end)

	return results
end

function MTH_BOOKTAB_ShowFamilyAbilityTooltip(anchor, abilityEntry)
	if not anchor or type(abilityEntry) ~= "table" then return end
	local tooltip = MTH_BOOK_GetSpellTooltip and MTH_BOOK_GetSpellTooltip() or GameTooltip
	if not tooltip then return end

	tooltip:SetOwner(anchor, "ANCHOR_RIGHT")
	tooltip:ClearLines()
	if MTH_BOOK_SetSpellTooltipIcon then
		MTH_BOOK_SetSpellTooltipIcon(tooltip, abilityEntry.icon)
	end
	tooltip:AddLine(tostring(abilityEntry.name or "Unknown"), 1.00, 0.82, 0.00)
	tooltip:AddLine(" ")
	tooltip:AddLine("Baseline", 1.00, 0.82, 0.00)
	if abilityEntry.rankCount and abilityEntry.rankCount > 0 then
		if abilityEntry.rankMin and abilityEntry.rankMax then
			if abilityEntry.rankMin == abilityEntry.rankMax then
				tooltip:AddDoubleLine("Ranks", tostring(abilityEntry.rankMin), 0.85, 0.85, 0.85, 1, 1, 1)
			else
				tooltip:AddDoubleLine("Ranks", tostring(abilityEntry.rankMin) .. "-" .. tostring(abilityEntry.rankMax), 0.85, 0.85, 0.85, 1, 1, 1)
			end
		end
	else
		tooltip:AddDoubleLine("Ranks", "Unranked", 0.85, 0.85, 0.85, 1, 1, 1)
	end
	tooltip:AddDoubleLine("Family-Unique", abilityEntry.isUnique and "Yes" or "No", 0.85, 0.85, 0.85, 1, 1, 1)
	if abilityEntry.description and abilityEntry.description ~= "" then
		tooltip:AddLine(" ")
		tooltip:AddLine(tostring(abilityEntry.description), 0.90, 0.90, 0.90, true)
	end
	tooltip:Show()
end

function MTH_BOOKTAB_EnsureFamiliesUI()
	if MTH_BOOK_STATE.familiesUI then return end
	local listParent = getglobal("MTH_BOOK_ListBackdrop")
	if not listParent then
		MTH_BOOKTAB_FamiliesTrace("EnsureFamiliesUI failed: missing MTH_BOOK_ListBackdrop")
		return
	end

	local ui = {}
	ui.frame = CreateFrame("Frame", nil, listParent)
	ui.frame:SetPoint("TOPLEFT", listParent, "TOPLEFT", 6, -6)
	ui.frame:SetPoint("BOTTOMRIGHT", listParent, "BOTTOMRIGHT", -6, 6)
	ui.frame:Hide()

	local statsText = getglobal("MTH_BOOK_StatsText")
	local statsParent = statsText and statsText:GetParent() or nil
	if statsParent then
		ui.percentCheckbox = CreateFrame("CheckButton", "MTH_BOOK_FamiliesPercentCheckbox", statsParent, "UICheckButtonTemplate")
		ui.percentCheckbox:SetFrameStrata(statsParent:GetFrameStrata())
		ui.percentCheckbox:SetFrameLevel((statsParent:GetFrameLevel() or 0) + 20)
		ui.percentCheckbox:ClearAllPoints()
		if statsText then
			ui.percentCheckbox:SetPoint("LEFT", statsText, "RIGHT", 260, 0)
		else
			ui.percentCheckbox:SetPoint("TOPLEFT", statsParent, "TOPLEFT", 538, -526)
		end
		ui.percentCheckbox.label = ui.percentCheckbox:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
		ui.percentCheckbox.label:SetPoint("LEFT", ui.percentCheckbox, "RIGHT", 4, 0)
		ui.percentCheckbox.label:SetTextColor(1.00, 0.82, 0.00)
		ui.percentCheckbox.label:SetText("Show modifiers in %")
		ui.percentCheckbox:SetScript("OnClick", function()
			if not this then return end
			MTH_BOOK_STATE.familyStatsPercent = this:GetChecked() == 1
			MTH_BOOKTAB_RenderFamiliesList()
		end)
		ui.percentCheckbox:Hide()
	end

	ui.headerFamily = ui.frame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	ui.headerFamily:SetPoint("TOPLEFT", ui.frame, "TOPLEFT", 4, -2)
	ui.headerFamily:SetTextColor(1.00, 0.82, 0.00)
	ui.headerFamily:SetText("Family")

	ui.headerNamed = ui.frame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	ui.headerNamed:SetPoint("TOPLEFT", ui.frame, "TOPLEFT", 114, -2)
	ui.headerNamed:SetTextColor(1.00, 0.82, 0.00)
	ui.headerNamed:SetText("Named")

	ui.headerCoords = ui.frame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	ui.headerCoords:SetPoint("TOPLEFT", ui.frame, "TOPLEFT", 154, -2)
	ui.headerCoords:SetTextColor(1.00, 0.82, 0.00)
	ui.headerCoords:SetText("Coords")

	ui.headerAbilities = ui.frame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	ui.headerAbilities:SetPoint("TOPLEFT", ui.frame, "TOPLEFT", 196, -2)
	ui.headerAbilities:SetTextColor(1.00, 0.82, 0.00)
	ui.headerAbilities:SetText("Abilities")

	ui.headerDiet = ui.frame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	ui.headerDiet:SetPoint("TOPLEFT", ui.frame, "TOPLEFT", 496, -2)
	ui.headerDiet:SetTextColor(1.00, 0.82, 0.00)
	ui.headerDiet:SetText("Diet")

	ui.headerHP = ui.frame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	ui.headerHP:SetPoint("TOPLEFT", ui.frame, "TOPLEFT", 602, -2)
	ui.headerHP:SetWidth(30)
	ui.headerHP:SetJustifyH("CENTER")
	ui.headerHP:SetTextColor(1.00, 0.82, 0.00)
	ui.headerHP:SetText("HP")

	ui.headerDmg = ui.frame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	ui.headerDmg:SetPoint("TOPLEFT", ui.frame, "TOPLEFT", 636, -2)
	ui.headerDmg:SetWidth(36)
	ui.headerDmg:SetJustifyH("CENTER")
	ui.headerDmg:SetTextColor(1.00, 0.82, 0.00)
	ui.headerDmg:SetText("dmg")

	ui.headerArm = ui.frame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	ui.headerArm:SetPoint("TOPLEFT", ui.frame, "TOPLEFT", 674, -2)
	ui.headerArm:SetWidth(38)
	ui.headerArm:SetJustifyH("CENTER")
	ui.headerArm:SetTextColor(1.00, 0.82, 0.00)
	ui.headerArm:SetText("Arm")

	ui.rows = {}
	for i = 1, 28 do
		local row = CreateFrame("Frame", nil, ui.frame)
		row:SetHeight(18)
		if i == 1 then
			row:SetPoint("TOPLEFT", ui.frame, "TOPLEFT", 0, -18)
			row:SetPoint("TOPRIGHT", ui.frame, "TOPRIGHT", 0, -18)
		else
			row:SetPoint("TOPLEFT", ui.rows[i - 1], "BOTTOMLEFT", 0, -1)
			row:SetPoint("TOPRIGHT", ui.rows[i - 1], "BOTTOMRIGHT", 0, -1)
		end

		row.familyIcon = row:CreateTexture(nil, "ARTWORK")
		row.familyIcon:SetPoint("LEFT", row, "LEFT", 4, 0)
		row.familyIcon:SetWidth(16)
		row.familyIcon:SetHeight(16)
		row.familyIcon:Hide()

		row.family = row:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
		row.family:SetPoint("LEFT", row, "LEFT", 24, 0)
		row.family:SetWidth(82)
		row.family:SetJustifyH("LEFT")

		row.named = row:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
		row.named:SetPoint("LEFT", row, "LEFT", 114, 0)
		row.named:SetWidth(38)
		row.named:SetJustifyH("LEFT")

		row.coords = row:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
		row.coords:SetPoint("LEFT", row, "LEFT", 154, 0)
		row.coords:SetWidth(38)
		row.coords:SetJustifyH("LEFT")

		row.diet = row:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
		row.diet:SetPoint("LEFT", row, "LEFT", 496, 0)
		row.diet:SetWidth(102)
		row.diet:SetJustifyH("LEFT")

		row.hp = row:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
		row.hp:SetPoint("LEFT", row, "LEFT", 602, 0)
		row.hp:SetWidth(30)
		row.hp:SetJustifyH("CENTER")

		row.dmg = row:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
		row.dmg:SetPoint("LEFT", row, "LEFT", 636, 0)
		row.dmg:SetWidth(36)
		row.dmg:SetJustifyH("CENTER")

		row.arm = row:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
		row.arm:SetPoint("LEFT", row, "LEFT", 674, 0)
		row.arm:SetWidth(38)
		row.arm:SetJustifyH("CENTER")

		row.abilityButtons = {}
		for b = 1, 16 do
			local button = CreateFrame("Button", nil, row)
			button:SetHeight(14)
			button.icon = button:CreateTexture(nil, "ARTWORK")
			button.icon:SetPoint("LEFT", button, "LEFT", 0, 0)
			button.icon:SetWidth(12)
			button.icon:SetHeight(12)
			button.text = button:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
			button.text:SetPoint("LEFT", button.icon, "RIGHT", 2, 0)
			button.text:SetJustifyH("LEFT")
			button.text:SetTextColor(0.90, 0.90, 0.90)
			button.entry = nil
			button:SetScript("OnEnter", function()
				if this and this.entry then
					MTH_BOOKTAB_ShowFamilyAbilityTooltip(this, this.entry)
				end
			end)
			button:SetScript("OnLeave", function()
				if type(MTH_BOOK_HideSpellTooltip) == "function" then
					MTH_BOOK_HideSpellTooltip()
				end
			end)
			button:Hide()
			row.abilityButtons[b] = button
		end

		row.divider = row:CreateTexture(nil, "BORDER")
		row.divider:SetTexture("Interface\\Buttons\\WHITE8X8")
		row.divider:SetVertexColor(0.28, 0.28, 0.28, 0.45)
		row.divider:SetPoint("BOTTOMLEFT", row, "BOTTOMLEFT", 0, 0)
		row.divider:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", 0, 0)
		row.divider:SetHeight(1)

		ui.rows[i] = row
	end

	MTH_BOOK_STATE.familiesUI = ui
	MTH_BOOKTAB_FamiliesTrace("EnsureFamiliesUI created rows=" .. tostring(table.getn(ui.rows or {})))
end

function MTH_BOOKTAB_SetFamiliesUIVisible(visible)
	local ui = MTH_BOOK_STATE.familiesUI
	if visible then
		if not ui then
			MTH_BOOKTAB_EnsureFamiliesUI()
			ui = MTH_BOOK_STATE.familiesUI
		end
		if not ui then return end
	else
		if not ui then return end
	end

	local listParent = getglobal("MTH_BOOK_ListBackdrop")
	local detailParent = getglobal("MTH_BOOK_DetailBackdrop")
	local detailText = getglobal("MTH_BOOK_DetailBackdropDetailText")
	local openMapButton = getglobal("MTH_BOOK_OpenMapButton")

	if visible then
		if listParent then listParent:Show() end
		if detailParent then detailParent:Hide() end
		if detailText then detailText:Hide() end
		if openMapButton then openMapButton:Hide() end
		if ui.percentCheckbox then
			ui.percentCheckbox:SetChecked(MTH_BOOK_STATE and MTH_BOOK_STATE.familyStatsPercent == true and 1 or nil)
			ui.percentCheckbox:Show()
		end
		ui.frame:Show()
	else
		ui.frame:Hide()
		if ui.percentCheckbox then ui.percentCheckbox:Hide() end
		if listParent then listParent:Show() end
		if detailParent then detailParent:Show() end
		if detailText then detailText:Show() end
	end
end

function MTH_BOOKTAB_RenderFamiliesList()
	local ui = MTH_BOOK_STATE.familiesUI
	if not ui then return end
	local rows = MTH_BOOK_STATE.results or {}
	MTH_BOOKTAB_FamiliesTrace("RenderFamiliesList rows=" .. tostring(table.getn(rows)))

	for i = 1, table.getn(ui.rows) do
		local rowFrame = ui.rows[i]
		local row = rows[i]
		if row then
			rowFrame:Show()
			rowFrame.family:SetText(tostring(row.family or "-"))
			local familyIconPath = row.icon and MTH_BOOK_ResolveIconPath and MTH_BOOK_ResolveIconPath(row.icon) or nil
			MTH_BOOKTAB_FamiliesTrace("RENDER " .. tostring(row.family) .. " icon=" .. tostring(row.icon) .. " path=" .. tostring(familyIconPath))
			if familyIconPath then
				rowFrame.familyIcon:SetTexture(familyIconPath)
				rowFrame.familyIcon:Show()
			else
				rowFrame.familyIcon:Hide()
			end
			rowFrame.named:SetText(tostring(row.named or 0))
			rowFrame.coords:SetText(tostring(row.coords or 0))
			rowFrame.diet:SetText(tostring(row.dietText or "-"))
			rowFrame.hp:SetText(MTH_BOOKTAB_FormatFamilyStat(row.healthStat))
			rowFrame.dmg:SetText(MTH_BOOKTAB_FormatFamilyStat(row.damageStat))
			rowFrame.arm:SetText(MTH_BOOKTAB_FormatFamilyStat(row.armorStat))

			local offsetX = 196
			local abilityMaxRight = 490
			for b = 1, table.getn(rowFrame.abilityButtons) do
				local button = rowFrame.abilityButtons[b]
				local ability = row.abilities and row.abilities[b] or nil
				if ability then
					local nameText = tostring(ability.name or "")
					if b < table.getn(row.abilities) then
						nameText = nameText .. ","
					end
					button.entry = ability
					button.text:SetText(nameText)
					local textW = button.text:GetStringWidth() or 40
					if textW < 24 then textW = 24 end
					local buttonWidth = 14 + textW
					if (offsetX + buttonWidth) > abilityMaxRight then
						button.entry = nil
						button:Hide()
					else
						button:SetWidth(buttonWidth)
						button:ClearAllPoints()
						button:SetPoint("LEFT", rowFrame, "LEFT", offsetX, 0)
						local iconPath = ability.icon and MTH_BOOK_ResolveIconPath and MTH_BOOK_ResolveIconPath(ability.icon) or nil
						if iconPath then
							button.icon:SetTexture(iconPath)
						else
							button.icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
						end
						button:Show()
						offsetX = offsetX + button:GetWidth() + 6
					end
				else
					button.entry = nil
					button:Hide()
				end
			end
		else
			rowFrame:Hide()
		end
	end
end