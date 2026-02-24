
if not MTH_DS then
	MTH_DS = {}
end

MTH_DS.version = "1.0"
MTH_DS.loaded = false

local function MTH_DS_MarkNotInGameRangedWeapons()
	if not MTH_DS_AmmoItems then return end
	for _, item in pairs(MTH_DS_AmmoItems) do
		if type(item) == "table" then
			local name = string.lower(tostring(item.name or ""))
			if string.find(name, "monster - ", 1, true) == 1 or string.find(name, "90 green", 1, true) == 1 then
				local subtype = string.lower(tostring(item.subtype or ""))
				if subtype == "bow" or subtype == "bows"
					or subtype == "gun" or subtype == "rifle" or subtype == "rifles"
					or subtype == "crossbow" or subtype == "crossbows" or subtype == "cross bow" or subtype == "cross-bow"
				then
					item.notingame = true
				end
			end
		end
	end
end

MTH_DS_MarkNotInGameRangedWeapons()

local function MTH_DS_EnsurePetSpellsTrainerGrowl()
	if not MTH_DS_PetSpells then return end
	if type(MTH_DS_PetSpells.allSpells) ~= "table" then MTH_DS_PetSpells.allSpells = {} end
	if type(MTH_DS_PetSpells.byAbility) ~= "table" then MTH_DS_PetSpells.byAbility = {} end
	if type(MTH_DS_PetSpells.abilitiesDiscovered) ~= "table" then MTH_DS_PetSpells.abilitiesDiscovered = {} end

	for _, row in ipairs(MTH_DS_PetSpells.allSpells) do
		if type(row) == "table" and not row.learnMethod then
			row.learnMethod = "beast"
		end
	end

	local hasGrowlAbility = false
	local hasGreatStaminaAbility = false
	local hasNaturalArmorAbility = false
	local hasFireResistanceAbility = false
	local hasFrostResistanceAbility = false
	local hasArcaneResistanceAbility = false
	local hasNatureResistanceAbility = false
	local hasShadowResistanceAbility = false
	for i = 1, table.getn(MTH_DS_PetSpells.abilitiesDiscovered) do
		if MTH_DS_PetSpells.abilitiesDiscovered[i] == "Growl" then
			hasGrowlAbility = true
		elseif MTH_DS_PetSpells.abilitiesDiscovered[i] == "Great Stamina" then
			hasGreatStaminaAbility = true
		elseif MTH_DS_PetSpells.abilitiesDiscovered[i] == "Natural Armor" then
			hasNaturalArmorAbility = true
		elseif MTH_DS_PetSpells.abilitiesDiscovered[i] == "Fire Resistance" then
			hasFireResistanceAbility = true
		elseif MTH_DS_PetSpells.abilitiesDiscovered[i] == "Frost Resistance" then
			hasFrostResistanceAbility = true
		elseif MTH_DS_PetSpells.abilitiesDiscovered[i] == "Arcane Resistance" then
			hasArcaneResistanceAbility = true
		elseif MTH_DS_PetSpells.abilitiesDiscovered[i] == "Nature Resistance" then
			hasNatureResistanceAbility = true
		elseif MTH_DS_PetSpells.abilitiesDiscovered[i] == "Shadow Resistance" then
			hasShadowResistanceAbility = true
		end
		if hasGrowlAbility and hasGreatStaminaAbility and hasNaturalArmorAbility and hasFireResistanceAbility and hasFrostResistanceAbility and hasArcaneResistanceAbility and hasNatureResistanceAbility and hasShadowResistanceAbility then break end
	end
	if not hasGrowlAbility then
		table.insert(MTH_DS_PetSpells.abilitiesDiscovered, "Growl")
	end
	if not hasGreatStaminaAbility then
		table.insert(MTH_DS_PetSpells.abilitiesDiscovered, "Great Stamina")
	end
	if not hasNaturalArmorAbility then
		table.insert(MTH_DS_PetSpells.abilitiesDiscovered, "Natural Armor")
	end
	if not hasFireResistanceAbility then
		table.insert(MTH_DS_PetSpells.abilitiesDiscovered, "Fire Resistance")
	end
	if not hasFrostResistanceAbility then
		table.insert(MTH_DS_PetSpells.abilitiesDiscovered, "Frost Resistance")
	end
	if not hasArcaneResistanceAbility then
		table.insert(MTH_DS_PetSpells.abilitiesDiscovered, "Arcane Resistance")
	end
	if not hasNatureResistanceAbility then
		table.insert(MTH_DS_PetSpells.abilitiesDiscovered, "Nature Resistance")
	end
	if not hasShadowResistanceAbility then
		table.insert(MTH_DS_PetSpells.abilitiesDiscovered, "Shadow Resistance")
	end
	table.sort(MTH_DS_PetSpells.abilitiesDiscovered)

	local growlRows = {
		{ id = 2649, rank = "Rank 1", rankNumber = 1, trainLevel = 1, effect = "(63) Threat Value: 50" },
		{ id = 14916, rank = "Rank 2", rankNumber = 2, trainLevel = 10, effect = "(63) Threat Value: 65" },
		{ id = 14917, rank = "Rank 3", rankNumber = 3, trainLevel = 20, effect = "(63) Threat Value: 110" },
		{ id = 14918, rank = "Rank 4", rankNumber = 4, trainLevel = 30, effect = "(63) Threat Value: 170" },
		{ id = 14919, rank = "Rank 5", rankNumber = 5, trainLevel = 40, effect = "(63) Threat Value: 240" },
		{ id = 14920, rank = "Rank 6", rankNumber = 6, trainLevel = 50, effect = "(63) Threat Value: 320" },
		{ id = 14921, rank = "Rank 7", rankNumber = 7, trainLevel = 60, effect = "(63) Threat Value: 415" },
	}

	local allById = {}
	for i, row in ipairs(MTH_DS_PetSpells.allSpells) do
		if type(row) == "table" and row.id then
			allById[row.id] = i
		end
	end

	local growlSpells = {}
	for i = 1, table.getn(growlRows) do
		local src = growlRows[i]
		local row = {
			ability = "Growl",
			castTime = "Instant",
			categoryCooldown = "5 seconds",
			cooldown = "n/a",
			cost = "10 mana",
			description = "Taunt the target, increasing the likelihood the creature will focus attacks on you.",
			effects = { src.effect },
			icon = "Ability_Physical_Taunt",
			id = src.id,
			learnMethod = "trainer",
			name = "Growl",
			range = "5 yards (Combat Range)",
			rank = src.rank,
			rankNumber = src.rankNumber,
			school = "Physical",
			sourceUrl = "https://database.turtlecraft.gg/?spell=" .. tostring(src.id),
			trainLevel = src.trainLevel,
		}
		table.insert(growlSpells, row)
		local idx = allById[src.id]
		if idx then
			MTH_DS_PetSpells.allSpells[idx] = row
		else
			table.insert(MTH_DS_PetSpells.allSpells, row)
		end
	end

	local staminaRows = {
		{ id = 4187, rank = "Rank 1", rankNumber = 1, trainLevel = 10, description = "Stamina increased by 3.", effect = "(6) Apply Aura #29: Mod Stat (2) Value: 3" },
		{ id = 4188, rank = "Rank 2", rankNumber = 2, trainLevel = 12, description = "Stamina increased by 5.", effect = "(6) Apply Aura #29: Mod Stat (2) Value: 5" },
		{ id = 4189, rank = "Rank 3", rankNumber = 3, trainLevel = 18, description = "Stamina increased by 7.", effect = "(6) Apply Aura #29: Mod Stat (2) Value: 7" },
		{ id = 4190, rank = "Rank 4", rankNumber = 4, trainLevel = 24, description = "Stamina increased by 10.", effect = "(6) Apply Aura #29: Mod Stat (2) Value: 10" },
		{ id = 4191, rank = "Rank 5", rankNumber = 5, trainLevel = 30, description = "Stamina increased by 13.", effect = "(6) Apply Aura #29: Mod Stat (2) Value: 13" },
		{ id = 4192, rank = "Rank 6", rankNumber = 6, trainLevel = 36, description = "Stamina increased by 17.", effect = "(6) Apply Aura #29: Mod Stat (2) Value: 17" },
		{ id = 4193, rank = "Rank 7", rankNumber = 7, trainLevel = 42, description = "Stamina increased by 21.", effect = "(6) Apply Aura #29: Mod Stat (2) Value: 21" },
		{ id = 4194, rank = "Rank 8", rankNumber = 8, trainLevel = 48, description = "Stamina increased by 26.", effect = "(6) Apply Aura #29: Mod Stat (2) Value: 26" },
		{ id = 5048, rank = "Rank 9", rankNumber = 9, trainLevel = 54, description = "Stamina increased by 32.", effect = "(36) Learn Spell Great Stamina" },
		{ id = 5049, rank = "Rank 10", rankNumber = 10, trainLevel = 60, description = "Stamina increased by 40.", effect = "(36) Learn Spell Great Stamina" },
	}

	for i, row in ipairs(MTH_DS_PetSpells.allSpells) do
		if type(row) == "table" and row.id then
			allById[row.id] = i
		end
	end

	local staminaSpells = {}
	for i = 1, table.getn(staminaRows) do
		local src = staminaRows[i]
		local row = {
			ability = "Great Stamina",
			castTime = "Passive",
			categoryCooldown = "n/a",
			cooldown = "n/a",
			cost = "None",
			description = src.description,
			effects = { src.effect },
			icon = "Spell_Nature_UnyeildingStamina",
			id = src.id,
			learnMethod = "trainer",
			name = "Great Stamina",
			range = "0 yards (Self Only)",
			rank = src.rank,
			rankNumber = src.rankNumber,
			school = "Physical",
			sourceUrl = "https://database.turtlecraft.gg/?spell=" .. tostring(src.id),
			trainLevel = src.trainLevel,
		}
		table.insert(staminaSpells, row)
		local idx = allById[src.id]
		if idx then
			MTH_DS_PetSpells.allSpells[idx] = row
		else
			table.insert(MTH_DS_PetSpells.allSpells, row)
		end
	end

	for i, row in ipairs(MTH_DS_PetSpells.allSpells) do
		if type(row) == "table" and row.id then
			allById[row.id] = i
		end
	end

	local armorRows = {
		{ id = 24545, rank = "Rank 1", rankNumber = 1, trainLevel = 10, description = "Armor increased by 50.", effect = "(6) Apply Aura #22: Mod Resistance (1) Value: 50" },
		{ id = 24549, rank = "Rank 2", rankNumber = 2, trainLevel = 12, description = "Armor increased by 100.", effect = "(6) Apply Aura #22: Mod Resistance (1) Value: 100" },
		{ id = 24550, rank = "Rank 3", rankNumber = 3, trainLevel = 18, description = "Armor increased by 160.", effect = "(6) Apply Aura #22: Mod Resistance (1) Value: 160" },
		{ id = 24551, rank = "Rank 4", rankNumber = 4, trainLevel = 24, description = "Armor increased by 240.", effect = "(6) Apply Aura #22: Mod Resistance (1) Value: 240" },
		{ id = 24552, rank = "Rank 5", rankNumber = 5, trainLevel = 30, description = "Armor increased by 330.", effect = "(6) Apply Aura #22: Mod Resistance (1) Value: 330" },
		{ id = 24553, rank = "Rank 6", rankNumber = 6, trainLevel = 36, description = "Armor increased by 430.", effect = "(6) Apply Aura #22: Mod Resistance (1) Value: 430" },
		{ id = 24554, rank = "Rank 7", rankNumber = 7, trainLevel = 42, description = "Armor increased by 550.", effect = "(6) Apply Aura #22: Mod Resistance (1) Value: 550" },
		{ id = 24555, rank = "Rank 8", rankNumber = 8, trainLevel = 48, description = "Armor increased by 675.", effect = "(6) Apply Aura #22: Mod Resistance (1) Value: 675" },
		{ id = 24629, rank = "Rank 9", rankNumber = 9, trainLevel = 54, description = "Armor increased by 810.", effect = "(6) Apply Aura #22: Mod Resistance (1) Value: 810" },
		{ id = 24630, rank = "Rank 10", rankNumber = 10, trainLevel = 60, description = "Armor increased by 1000.", effect = "(6) Apply Aura #22: Mod Resistance (1) Value: 1000" },
	}

	local armorSpells = {}
	for i = 1, table.getn(armorRows) do
		local src = armorRows[i]
		local row = {
			ability = "Natural Armor",
			castTime = "Passive",
			categoryCooldown = "n/a",
			cooldown = "n/a",
			cost = "None",
			description = src.description,
			effects = { src.effect },
			icon = "Spell_Nature_SpiritArmor",
			id = src.id,
			learnMethod = "trainer",
			name = "Natural Armor",
			range = "0 yards (Self Only)",
			rank = src.rank,
			rankNumber = src.rankNumber,
			school = "Physical",
			sourceUrl = "https://database.turtlecraft.gg/?spell=" .. tostring(src.id),
			trainLevel = src.trainLevel,
		}
		table.insert(armorSpells, row)
		local idx = allById[src.id]
		if idx then
			MTH_DS_PetSpells.allSpells[idx] = row
		else
			table.insert(MTH_DS_PetSpells.allSpells, row)
		end
	end

	for i, row in ipairs(MTH_DS_PetSpells.allSpells) do
		if type(row) == "table" and row.id then
			allById[row.id] = i
		end
	end

	local fireResRows = {
		{ id = 23992, rank = "Rank 1", rankNumber = 1, trainLevel = 20, description = "Increases Fire resistance by 30.", effect = "(6) Apply Aura #22: Mod Resistance (4) Value: 30" },
		{ id = 24439, rank = "Rank 2", rankNumber = 2, trainLevel = 30, description = "Increases Fire resistance by 60.", effect = "(6) Apply Aura #22: Mod Resistance (4) Value: 60" },
		{ id = 24444, rank = "Rank 3", rankNumber = 3, trainLevel = 40, description = "Increases Fire resistance by 90.", effect = "(6) Apply Aura #22: Mod Resistance (4) Value: 90" },
		{ id = 24445, rank = "Rank 4", rankNumber = 4, trainLevel = 50, description = "Increases Fire resistance by 120.", effect = "(6) Apply Aura #22: Mod Resistance (4) Value: 120" },
	}

	local fireResSpells = {}
	for i = 1, table.getn(fireResRows) do
		local src = fireResRows[i]
		local row = {
			ability = "Fire Resistance",
			castTime = "Passive",
			categoryCooldown = "n/a",
			cooldown = "n/a",
			cost = "None",
			description = src.description,
			effects = { src.effect },
			icon = "Spell_Fire_FireArmor",
			id = src.id,
			learnMethod = "trainer",
			name = "Fire Resistance",
			range = "0 yards (Self Only)",
			rank = src.rank,
			rankNumber = src.rankNumber,
			school = "Physical",
			sourceUrl = "https://database.turtlecraft.gg/?spell=" .. tostring(src.id),
			trainLevel = src.trainLevel,
		}
		table.insert(fireResSpells, row)
		local idx = allById[src.id]
		if idx then
			MTH_DS_PetSpells.allSpells[idx] = row
		else
			table.insert(MTH_DS_PetSpells.allSpells, row)
		end
	end

	for i, row in ipairs(MTH_DS_PetSpells.allSpells) do
		if type(row) == "table" and row.id then
			allById[row.id] = i
		end
	end

	local frostResRows = {
		{ id = 24446, rank = "Rank 1", rankNumber = 1, trainLevel = 20, description = "Increases Frost resistance by 30.", effect = "(6) Apply Aura #22: Mod Resistance (16) Value: 30" },
		{ id = 24447, rank = "Rank 2", rankNumber = 2, trainLevel = 30, description = "Increases Frost resistance by 60.", effect = "(6) Apply Aura #22: Mod Resistance (16) Value: 60" },
		{ id = 24448, rank = "Rank 3", rankNumber = 3, trainLevel = 40, description = "Increases Frost resistance by 90.", effect = "(6) Apply Aura #22: Mod Resistance (16) Value: 90" },
		{ id = 24449, rank = "Rank 4", rankNumber = 4, trainLevel = 50, description = "Increases Frost resistance by 120.", effect = "(6) Apply Aura #22: Mod Resistance (16) Value: 120" },
	}

	local frostResSpells = {}
	for i = 1, table.getn(frostResRows) do
		local src = frostResRows[i]
		local row = {
			ability = "Frost Resistance",
			castTime = "Passive",
			categoryCooldown = "n/a",
			cooldown = "n/a",
			cost = "None",
			description = src.description,
			effects = { src.effect },
			icon = "Spell_Frost_FrostWard",
			id = src.id,
			learnMethod = "trainer",
			name = "Frost Resistance",
			range = "0 yards (Self Only)",
			rank = src.rank,
			rankNumber = src.rankNumber,
			school = "Physical",
			sourceUrl = "https://database.turtlecraft.gg/?spell=" .. tostring(src.id),
			trainLevel = src.trainLevel,
		}
		table.insert(frostResSpells, row)
		local idx = allById[src.id]
		if idx then
			MTH_DS_PetSpells.allSpells[idx] = row
		else
			table.insert(MTH_DS_PetSpells.allSpells, row)
		end
	end

	for i, row in ipairs(MTH_DS_PetSpells.allSpells) do
		if type(row) == "table" and row.id then
			allById[row.id] = i
		end
	end

	local arcaneResRows = {
		{ id = 24493, rank = "Rank 1", rankNumber = 1, trainLevel = 20, description = "Increases Arcane resistance by 30.", effect = "(6) Apply Aura #22: Mod Resistance (64) Value: 30" },
		{ id = 24497, rank = "Rank 2", rankNumber = 2, trainLevel = 30, description = "Increases Arcane resistance by 60.", effect = "(6) Apply Aura #22: Mod Resistance (64) Value: 60" },
		{ id = 24500, rank = "Rank 3", rankNumber = 3, trainLevel = 40, description = "Increases Arcane resistance by 90.", effect = "(6) Apply Aura #22: Mod Resistance (64) Value: 90" },
		{ id = 24501, rank = "Rank 4", rankNumber = 4, trainLevel = 50, description = "Increases Arcane resistance by 120.", effect = "(6) Apply Aura #22: Mod Resistance (64) Value: 120" },
	}

	local arcaneResSpells = {}
	for i = 1, table.getn(arcaneResRows) do
		local src = arcaneResRows[i]
		local row = {
			ability = "Arcane Resistance",
			castTime = "Passive",
			categoryCooldown = "n/a",
			cooldown = "n/a",
			cost = "None",
			description = src.description,
			effects = { src.effect },
			icon = "Spell_Nature_StarFall",
			id = src.id,
			learnMethod = "trainer",
			name = "Arcane Resistance",
			range = "0 yards (Self Only)",
			rank = src.rank,
			rankNumber = src.rankNumber,
			school = "Physical",
			sourceUrl = "https://database.turtlecraft.gg/?spell=" .. tostring(src.id),
			trainLevel = src.trainLevel,
		}
		table.insert(arcaneResSpells, row)
		local idx = allById[src.id]
		if idx then
			MTH_DS_PetSpells.allSpells[idx] = row
		else
			table.insert(MTH_DS_PetSpells.allSpells, row)
		end
	end

	for i, row in ipairs(MTH_DS_PetSpells.allSpells) do
		if type(row) == "table" and row.id then
			allById[row.id] = i
		end
	end

	local natureResRows = {
		{ id = 24492, rank = "Rank 1", rankNumber = 1, trainLevel = 20, description = "Increases Nature resistance by 30.", effect = "(6) Apply Aura #22: Mod Resistance (8) Value: 30" },
		{ id = 24502, rank = "Rank 2", rankNumber = 2, trainLevel = 30, description = "Increases Nature resistance by 60.", effect = "(6) Apply Aura #22: Mod Resistance (8) Value: 60" },
		{ id = 24503, rank = "Rank 3", rankNumber = 3, trainLevel = 40, description = "Increases Nature resistance by 90.", effect = "(6) Apply Aura #22: Mod Resistance (8) Value: 90" },
		{ id = 24504, rank = "Rank 4", rankNumber = 4, trainLevel = 50, description = "Increases Nature resistance by 120.", effect = "(6) Apply Aura #22: Mod Resistance (8) Value: 120" },
	}

	local natureResSpells = {}
	for i = 1, table.getn(natureResRows) do
		local src = natureResRows[i]
		local row = {
			ability = "Nature Resistance",
			castTime = "Passive",
			categoryCooldown = "n/a",
			cooldown = "n/a",
			cost = "None",
			description = src.description,
			effects = { src.effect },
			icon = "Spell_Nature_ResistNature",
			id = src.id,
			learnMethod = "trainer",
			name = "Nature Resistance",
			range = "0 yards (Self Only)",
			rank = src.rank,
			rankNumber = src.rankNumber,
			school = "Physical",
			sourceUrl = "https://database.turtlecraft.gg/?spell=" .. tostring(src.id),
			trainLevel = src.trainLevel,
		}
		table.insert(natureResSpells, row)
		local idx = allById[src.id]
		if idx then
			MTH_DS_PetSpells.allSpells[idx] = row
		else
			table.insert(MTH_DS_PetSpells.allSpells, row)
		end
	end

	for i, row in ipairs(MTH_DS_PetSpells.allSpells) do
		if type(row) == "table" and row.id then
			allById[row.id] = i
		end
	end

	local shadowResRows = {
		{ id = 24488, rank = "Rank 1", rankNumber = 1, trainLevel = 20, description = "Increases Shadow resistance by 30.", effect = "(6) Apply Aura #22: Mod Resistance (32) Value: 30" },
		{ id = 24505, rank = "Rank 2", rankNumber = 2, trainLevel = 30, description = "Increases Shadow resistance by 60.", effect = "(6) Apply Aura #22: Mod Resistance (32) Value: 60" },
		{ id = 24506, rank = "Rank 3", rankNumber = 3, trainLevel = 40, description = "Increases Shadow resistance by 90.", effect = "(6) Apply Aura #22: Mod Resistance (32) Value: 90" },
		{ id = 24507, rank = "Rank 4", rankNumber = 4, trainLevel = 50, description = "Increases Shadow resistance by 120.", effect = "(6) Apply Aura #22: Mod Resistance (32) Value: 120" },
	}

	local shadowResSpells = {}
	for i = 1, table.getn(shadowResRows) do
		local src = shadowResRows[i]
		local row = {
			ability = "Shadow Resistance",
			castTime = "Passive",
			categoryCooldown = "n/a",
			cooldown = "n/a",
			cost = "None",
			description = src.description,
			effects = { src.effect },
			icon = "Spell_Shadow_AntiShadow",
			id = src.id,
			learnMethod = "trainer",
			name = "Shadow Resistance",
			range = "0 yards (Self Only)",
			rank = src.rank,
			rankNumber = src.rankNumber,
			school = "Physical",
			sourceUrl = "https://database.turtlecraft.gg/?spell=" .. tostring(src.id),
			trainLevel = src.trainLevel,
		}
		table.insert(shadowResSpells, row)
		local idx = allById[src.id]
		if idx then
			MTH_DS_PetSpells.allSpells[idx] = row
		else
			table.insert(MTH_DS_PetSpells.allSpells, row)
		end
	end

	table.sort(MTH_DS_PetSpells.allSpells, function(a, b)
		local aa = (a and a.ability) or ""
		local bb = (b and b.ability) or ""
		if aa ~= bb then return aa < bb end
		local ar = (a and a.rankNumber) or 0
		local br = (b and b.rankNumber) or 0
		if ar ~= br then return ar < br end
		return ((a and a.id) or 0) < ((b and b.id) or 0)
	end)

	MTH_DS_PetSpells.byAbility["Growl"] = {
		ability = "Growl",
		searchUrl = "https://database.turtlecraft.gg/?search=Growl",
		spellCount = table.getn(growlSpells),
		spells = growlSpells,
	}

	MTH_DS_PetSpells.byAbility["Great Stamina"] = {
		ability = "Great Stamina",
		searchUrl = "https://database.turtlecraft.gg/?search=Great+Stamina",
		spellCount = table.getn(staminaSpells),
		spells = staminaSpells,
	}

	MTH_DS_PetSpells.byAbility["Natural Armor"] = {
		ability = "Natural Armor",
		searchUrl = "https://database.turtlecraft.gg/?search=Natural+Armor",
		spellCount = table.getn(armorSpells),
		spells = armorSpells,
	}

	MTH_DS_PetSpells.byAbility["Fire Resistance"] = {
		ability = "Fire Resistance",
		searchUrl = "https://database.turtlecraft.gg/?search=Fire+Resistance",
		spellCount = table.getn(fireResSpells),
		spells = fireResSpells,
	}

	MTH_DS_PetSpells.byAbility["Frost Resistance"] = {
		ability = "Frost Resistance",
		searchUrl = "https://database.turtlecraft.gg/?search=Frost+Resistance",
		spellCount = table.getn(frostResSpells),
		spells = frostResSpells,
	}

	MTH_DS_PetSpells.byAbility["Arcane Resistance"] = {
		ability = "Arcane Resistance",
		searchUrl = "https://database.turtlecraft.gg/?search=Arcane+Resistance",
		spellCount = table.getn(arcaneResSpells),
		spells = arcaneResSpells,
	}

	MTH_DS_PetSpells.byAbility["Nature Resistance"] = {
		ability = "Nature Resistance",
		searchUrl = "https://database.turtlecraft.gg/?search=Nature+Resistance",
		spellCount = table.getn(natureResSpells),
		spells = natureResSpells,
	}

	MTH_DS_PetSpells.byAbility["Shadow Resistance"] = {
		ability = "Shadow Resistance",
		searchUrl = "https://database.turtlecraft.gg/?search=Shadow+Resistance",
		spellCount = table.getn(shadowResSpells),
		spells = shadowResSpells,
	}

	MTH_DS_PetSpells.totalSpellRows = table.getn(MTH_DS_PetSpells.allSpells)
end

function MTH_DS_OnLoad()
	if MTH_DS.loaded then
		return
	end
	
	-- Database files loaded via TOC
	-- Check if all tables are present
	
	if MTH_DS_Beasts and MTH_DS_Vendors and MTH_DS_AmmoItems and MTH_DS_Zones and MTH_DS_Families then
		MTH_DS_EnsurePetSpellsTrainerGrowl()
		MTH_DS.loaded = true
		
		-- Count entries
		MTH_DS.beastCount = 0
		for _ in pairs(MTH_DS_Beasts) do
			MTH_DS.beastCount = MTH_DS.beastCount + 1
		end
		
		MTH_DS.vendorCount = 0
		for _ in pairs(MTH_DS_Vendors) do
			MTH_DS.vendorCount = MTH_DS.vendorCount + 1
		end
		
		MTH_DS.ammoItemCount = 0
		for _ in pairs(MTH_DS_AmmoItems) do
			MTH_DS.ammoItemCount = MTH_DS.ammoItemCount + 1
		end
		
		MTH_DS.zoneCount = 0
		for _ in pairs(MTH_DS_Zones) do
			MTH_DS.zoneCount = MTH_DS.zoneCount + 1
		end

		MTH_DS.familyCount = 0
		for _ in pairs(MTH_DS_Families) do
			MTH_DS.familyCount = MTH_DS.familyCount + 1
		end

		MTH_DS.petSpellRowCount = 0
		if MTH_DS_PetSpells and MTH_DS_PetSpells.allSpells then
			for _ in pairs(MTH_DS_PetSpells.allSpells) do
				MTH_DS.petSpellRowCount = MTH_DS.petSpellRowCount + 1
			end
		end
		
		-- Delayed message to ensure chat frame is ready
		local frame = CreateFrame("Frame")
		frame:RegisterEvent("PLAYER_ENTERING_WORLD")
		frame:SetScript("OnEvent", function()
			this:UnregisterAllEvents()
		end)
	else
		local missing = {}
		if not MTH_DS_Beasts then table.insert(missing, "MTH_DS_Beasts") end
		if not MTH_DS_Vendors then table.insert(missing, "MTH_DS_Vendors") end
		if not MTH_DS_AmmoItems then table.insert(missing, "MTH_DS_AmmoItems") end
		if not MTH_DS_Zones then table.insert(missing, "MTH_DS_Zones") end
		if not MTH_DS_Families then table.insert(missing, "MTH_DS_Families") end
		local msg = "|cFFFF3333[MTH] ERROR:|r Database failed to load! Missing: " .. table.concat(missing, ", ")
		local frame = CreateFrame("Frame")
		frame:RegisterEvent("PLAYER_ENTERING_WORLD")
		frame:SetScript("OnEvent", function()
			this:UnregisterAllEvents()
			MTH:Print(msg, "error")
		end)
	end
end
