-- MetaHunt Pet Spells Trainer Overlay
-- Adds trainer-learned pet abilities and normalizes learn method metadata.

if not MTH_DS_PetSpells then
  return
end

local function MTH_DSPS_EnsureArray(tbl)
  if type(tbl) ~= "table" then
    return {}
  end
  return tbl
end

MTH_DS_PetSpells.abilitiesDiscovered = MTH_DSPS_EnsureArray(MTH_DS_PetSpells.abilitiesDiscovered)
MTH_DS_PetSpells.allSpells = MTH_DSPS_EnsureArray(MTH_DS_PetSpells.allSpells)
MTH_DS_PetSpells.byAbility = MTH_DSPS_EnsureArray(MTH_DS_PetSpells.byAbility)

for _, row in ipairs(MTH_DS_PetSpells.allSpells) do
  if type(row) == "table" and not row.learnMethod then
    row.learnMethod = "beast"
  end
end

for _, bundle in pairs(MTH_DS_PetSpells.byAbility) do
  if type(bundle) == "table" and type(bundle.spells) == "table" then
    for _, row in ipairs(bundle.spells) do
      if type(row) == "table" and not row.learnMethod then
        row.learnMethod = "beast"
      end
    end
  end
end

local growlTrainerRows = {
  {
    ["ability"] = "Growl",
    ["castTime"] = "Instant",
    ["categoryCooldown"] = "5 seconds",
    ["cooldown"] = "n/a",
    ["cost"] = "10 mana",
    ["description"] = "Taunt the target, increasing the likelihood the creature will focus attacks on you.",
    ["effects"] = {
      "(63) Threat Value: 50",
    },
    ["icon"] = "Ability_Physical_Taunt",
    ["id"] = 2649,
    ["learnMethod"] = "trainer",
    ["name"] = "Growl",
    ["range"] = "5 yards (Combat Range)",
    ["rank"] = "Rank 1",
    ["rankNumber"] = 1,
    ["school"] = "Physical",
    ["sourceUrl"] = "https://database.turtlecraft.gg/?spell=2649",
    ["trainLevel"] = 1,
  },
  {
    ["ability"] = "Growl",
    ["castTime"] = "Instant",
    ["categoryCooldown"] = "5 seconds",
    ["cooldown"] = "n/a",
    ["cost"] = "10 mana",
    ["description"] = "Taunt the target, increasing the likelihood the creature will focus attacks on you.",
    ["effects"] = {
      "(63) Threat Value: 65",
    },
    ["icon"] = "Ability_Physical_Taunt",
    ["id"] = 14916,
    ["learnMethod"] = "trainer",
    ["name"] = "Growl",
    ["range"] = "5 yards (Combat Range)",
    ["rank"] = "Rank 2",
    ["rankNumber"] = 2,
    ["school"] = "Physical",
    ["sourceUrl"] = "https://database.turtlecraft.gg/?spell=14916",
    ["trainLevel"] = 10,
  },
  {
    ["ability"] = "Growl",
    ["castTime"] = "Instant",
    ["categoryCooldown"] = "5 seconds",
    ["cooldown"] = "n/a",
    ["cost"] = "10 mana",
    ["description"] = "Taunt the target, increasing the likelihood the creature will focus attacks on you.",
    ["effects"] = {
      "(63) Threat Value: 110",
    },
    ["icon"] = "Ability_Physical_Taunt",
    ["id"] = 14917,
    ["learnMethod"] = "trainer",
    ["name"] = "Growl",
    ["range"] = "5 yards (Combat Range)",
    ["rank"] = "Rank 3",
    ["rankNumber"] = 3,
    ["school"] = "Physical",
    ["sourceUrl"] = "https://database.turtlecraft.gg/?spell=14917",
    ["trainLevel"] = 20,
  },
  {
    ["ability"] = "Growl",
    ["castTime"] = "Instant",
    ["categoryCooldown"] = "5 seconds",
    ["cooldown"] = "n/a",
    ["cost"] = "10 mana",
    ["description"] = "Taunt the target, increasing the likelihood the creature will focus attacks on you.",
    ["effects"] = {
      "(63) Threat Value: 170",
    },
    ["icon"] = "Ability_Physical_Taunt",
    ["id"] = 14918,
    ["learnMethod"] = "trainer",
    ["name"] = "Growl",
    ["range"] = "5 yards (Combat Range)",
    ["rank"] = "Rank 4",
    ["rankNumber"] = 4,
    ["school"] = "Physical",
    ["sourceUrl"] = "https://database.turtlecraft.gg/?spell=14918",
    ["trainLevel"] = 30,
  },
  {
    ["ability"] = "Growl",
    ["castTime"] = "Instant",
    ["categoryCooldown"] = "5 seconds",
    ["cooldown"] = "n/a",
    ["cost"] = "10 mana",
    ["description"] = "Taunt the target, increasing the likelihood the creature will focus attacks on you.",
    ["effects"] = {
      "(63) Threat Value: 240",
    },
    ["icon"] = "Ability_Physical_Taunt",
    ["id"] = 14919,
    ["learnMethod"] = "trainer",
    ["name"] = "Growl",
    ["range"] = "5 yards (Combat Range)",
    ["rank"] = "Rank 5",
    ["rankNumber"] = 5,
    ["school"] = "Physical",
    ["sourceUrl"] = "https://database.turtlecraft.gg/?spell=14919",
    ["trainLevel"] = 40,
  },
  {
    ["ability"] = "Growl",
    ["castTime"] = "Instant",
    ["categoryCooldown"] = "5 seconds",
    ["cooldown"] = "n/a",
    ["cost"] = "10 mana",
    ["description"] = "Taunt the target, increasing the likelihood the creature will focus attacks on you.",
    ["effects"] = {
      "(63) Threat Value: 320",
    },
    ["icon"] = "Ability_Physical_Taunt",
    ["id"] = 14920,
    ["learnMethod"] = "trainer",
    ["name"] = "Growl",
    ["range"] = "5 yards (Combat Range)",
    ["rank"] = "Rank 6",
    ["rankNumber"] = 6,
    ["school"] = "Physical",
    ["sourceUrl"] = "https://database.turtlecraft.gg/?spell=14920",
    ["trainLevel"] = 50,
  },
  {
    ["ability"] = "Growl",
    ["castTime"] = "Instant",
    ["categoryCooldown"] = "5 seconds",
    ["cooldown"] = "n/a",
    ["cost"] = "10 mana",
    ["description"] = "Taunt the target, increasing the likelihood the creature will focus attacks on you.",
    ["effects"] = {
      "(63) Threat Value: 415",
    },
    ["icon"] = "Ability_Physical_Taunt",
    ["id"] = 14921,
    ["learnMethod"] = "trainer",
    ["name"] = "Growl",
    ["range"] = "5 yards (Combat Range)",
    ["rank"] = "Rank 7",
    ["rankNumber"] = 7,
    ["school"] = "Physical",
    ["sourceUrl"] = "https://database.turtlecraft.gg/?spell=14921",
    ["trainLevel"] = 60,
  },
}

local function MTH_DSPS_Contains(array, value)
  for _, item in ipairs(array) do
    if item == value then
      return true
    end
  end
  return false
end

if not MTH_DSPS_Contains(MTH_DS_PetSpells.abilitiesDiscovered, "Growl") then
  table.insert(MTH_DS_PetSpells.abilitiesDiscovered, "Growl")
  table.sort(MTH_DS_PetSpells.abilitiesDiscovered)
end

local allById = {}
for i, row in ipairs(MTH_DS_PetSpells.allSpells) do
  if type(row) == "table" and row.id then
    allById[row.id] = i
  end
end

for _, row in ipairs(growlTrainerRows) do
  local idx = allById[row.id]
  if idx then
    MTH_DS_PetSpells.allSpells[idx] = row
  else
    table.insert(MTH_DS_PetSpells.allSpells, row)
  end
end

table.sort(MTH_DS_PetSpells.allSpells, function(a, b)
  local aa = (a and a.ability) or ""
  local bb = (b and b.ability) or ""
  if aa ~= bb then
    return aa < bb
  end
  local ar = (a and a.rankNumber) or 0
  local br = (b and b.rankNumber) or 0
  if ar ~= br then
    return ar < br
  end
  return ((a and a.id) or 0) < ((b and b.id) or 0)
end)

MTH_DS_PetSpells.byAbility["Growl"] = {
  ["ability"] = "Growl",
  ["searchUrl"] = "https://database.turtlecraft.gg/?search=Growl",
  ["spellCount"] = table.getn(growlTrainerRows),
  ["spells"] = growlTrainerRows,
}

MTH_DS_PetSpells.totalSpellRows = table.getn(MTH_DS_PetSpells.allSpells)
