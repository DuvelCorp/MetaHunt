
-- ds-hunter-spells.lua
-- Hunter spell data for TWoW 1.18.1 "Nightmares of Ursol"
-- Used by: ExpAmmo cycle tracker, HunterBook (future spell reference tab)
--
-- TODO markers:
--   SPELL_ID  : exact spell ID not yet extracted from Spell.dbc (needs MPQ)
--   ICON      : icon texture not yet confirmed from game files
--   VERIFY    : value observed in patch notes but subject to change on PTR/live
--   PENDING   : mechanic not yet verified against live server

if not MTH_DS then MTH_DS = {} end

-- ============================================================
-- BASELINE HUNTER SPELLS (available to all specs from 1.18.1)
-- ============================================================

MTH_DS_HunterSpells = {

  ["baseline"] = {

    {
      ["name"]        = "Steady Shot",
      ["addedIn"]     = "1.18.1",
      ["note"]        = "Moved from Marksmanship talent tree to baseline at level 20.",
      ["castTime"]    = "1.5s",                        -- TODO VERIFY
      ["cooldown"]    = "n/a",
      ["school"]      = "Physical",
      ["icon"]        = "Ability_Hunter_SteadyShot",   -- TODO ICON confirm
    },

    {
      ["name"]        = "Trueshot Aura",
      ["addedIn"]     = "1.18.1",
      ["note"]        = "Moved from Marksmanship capstone to baseline. All hunters now get this.",
      ["castTime"]    = "Instant",
      ["cooldown"]    = "n/a",
      ["school"]      = "Physical",
      ["icon"]        = "Ability_Trueshot",             -- TODO ICON confirm
    },

    {
      ["name"]        = "Aspect of the Viper",
      ["addedIn"]     = "1.18.1",
      ["note"]        = "New baseline aspect learned at level 56. Regenerates mana while dealing reduced damage.",
      ["castTime"]    = "Instant",
      ["cooldown"]    = "n/a",
      ["school"]      = "Nature",
      ["icon"]        = "Spell_Nature_Poison",          -- TODO ICON confirm
    },

    {
      ["name"]        = "Volley",
      ["addedIn"]     = "1.18.1",
      ["note"]        = "Changed from channelled to a 3-second cast AoE. Now a proper cast-bar spell.",
      ["castTime"]    = "3s",                           -- TODO VERIFY
      ["cooldown"]    = "n/a",
      ["school"]      = "Physical",
      ["icon"]        = "Ability_Whirlwind",            -- TODO ICON confirm
    },

  },

  -- ============================================================
  -- MARKSMANSHIP TALENTS (1.18.1 changes)
  -- ============================================================

  ["marksmanship"] = {

    {
      ["name"]        = "Aimed Shot",
      ["addedIn"]     = "1.18.1",
      ["note"]        = "Now has a visible 2s cast bar. Triggers ExpAmmo cycle start (resets to FIRE state).",
      ["castTime"]    = "2s",
      ["cooldown"]    = "26s",                          -- TODO VERIFY vs Spell.dbc
      ["school"]      = "Physical",
      ["icon"]        = "Inv_Spear_07",                 -- TODO ICON confirm
      ["expAmmoTrigger"] = true,                        -- resets ExpAmmo cycle to state 1 (FIRE)
    },

    {
      ["name"]        = "Lock and Load",
      ["addedIn"]     = "1.18.1",
      ["talentRow"]   = 7,                              -- MM capstone row
      ["note"]        = "10s proc buff. Triggered by Aimed Shot crit or trap activation (TODO VERIFY exact condition).",
      ["castTime"]    = "Instant",
      ["cooldown"]    = "n/a",
      ["duration"]    = "10s",                          -- TODO VERIFY
      ["school"]      = "Physical",
      ["type"]        = "buff_proc",
      ["icon"]        = "Ability_Hunter_LockAndLoad",   -- TODO ICON confirm
    },

    {
      ["name"]        = "Rapid Fire",
      ["note"]        = "15% haste, 15s duration, 5min CD. Unchanged in 1.18.1 baseline values.",
      ["castTime"]    = "Instant",
      ["cooldown"]    = "5min",
      ["duration"]    = "15s",
      ["school"]      = "Physical",
      ["type"]        = "buff",
      ["icon"]        = "Ability_Hunter_RapidKilling",
    },

  },

  -- ============================================================
  -- BEAST MASTERY TALENTS (1.18.1 changes)
  -- ============================================================

  ["beastmastery"] = {

    {
      ["name"]        = "Bestial Wrath",
      ["note"]        = "Returned to BM tree. 18s buff, 90s CD (1.5min). Pet immune to fear/CC during.",
      ["castTime"]    = "Instant",
      ["cooldown"]    = "90s",
      ["duration"]    = "18s",                          -- TODO VERIFY
      ["school"]      = "Physical",
      ["type"]        = "buff",
      ["icon"]        = "Ability_Druid_Ferociousbite",  -- TODO ICON confirm
    },

    {
      ["name"]        = "Kill Command",
      ["addedIn"]     = "1.18.1",
      ["talentRow"]   = 7,                              -- BM capstone row
      ["note"]        = "8s CD, triggered on crit. Commands pet to inflict bonus damage on next hit.",
      ["castTime"]    = "Instant",
      ["cooldown"]    = "8s",
      ["school"]      = "Physical",
      ["icon"]        = "Ability_Hunter_KillCommand",   -- TODO ICON confirm
    },

    {
      ["name"]        = "Scent of Blood",
      ["addedIn"]     = "1.18.1",
      ["talentRow"]   = 5,
      ["note"]        = "8s pet rage proc buff. Triggers when Bestial Wrath is active (TODO VERIFY exact condition).",
      ["castTime"]    = "Instant (proc)",
      ["cooldown"]    = "n/a",
      ["duration"]    = "8s",                           -- TODO VERIFY
      ["school"]      = "Physical",
      ["type"]        = "buff_proc",
      ["icon"]        = "Ability_Warrior_BloodFrenzy",  -- TODO ICON confirm
    },

    {
      ["name"]        = "Baited Shot",
      ["removedIn"]   = "1.18.1",
      ["note"]        = "REMOVED. Replaced by Kill Command as the BM capstone. Any saved data for this spell can be cleared.",
      ["deprecated"]  = true,
    },

  },

  -- ============================================================
  -- SURVIVAL TALENTS (1.18.1 changes)
  -- ============================================================

  ["survival"] = {

    {
      ["name"]        = "Alone Against the World",
      ["addedIn"]     = "1.18.1",
      ["talentRow"]   = 2,
      ["note"]        = "New 2-point talent. Bonus to pet/self when no group members nearby (TODO VERIFY exact bonus values).",
      ["type"]        = "passive",
      ["icon"]        = "Ability_Hunter_AloneAgainstTheWorld", -- TODO ICON confirm
    },

    {
      ["name"]        = "Lacerate",
      ["addedIn"]     = "1.18.1",
      ["note"]        = "40% Attack Power bleed, +15% from all bleed sides. (TODO VERIFY: rank values from Spell.dbc).",
      ["castTime"]    = "Instant",
      ["school"]      = "Physical",
      ["type"]        = "dot",
      ["icon"]        = "Ability_Hunter_Lacerate",       -- TODO ICON confirm
    },

  },

  -- ============================================================
  -- EXPERIMENTAL AMMUNITION (new 1.18.1 mechanic)
  -- States cycle: FIRE -> ARCANE -> NATURE -> (loop)
  -- Aimed Shot resets cycle to FIRE each time it is fired.
  -- ============================================================

  ["expAmmoStates"] = {

    {
      ["state"]       = 1,
      ["label"]       = "Fire Ammo",
      ["school"]      = "Fire",
      ["duration"]    = "60s",                          -- TODO VERIFY from server
      ["consumeSpell"] = "Multi-Shot",                  -- TODO VERIFY spell that consumes this state
      ["icon"]        = "Spell_Fire_FlameBolt",         -- TODO ICON confirm
      ["buffName"]    = nil,                            -- TODO: exact buff name from Spell.dbc
    },

    {
      ["state"]       = 2,
      ["label"]       = "Arcane Ammo",
      ["school"]      = "Arcane",
      ["duration"]    = "60s",                          -- TODO VERIFY
      ["consumeSpell"] = "Arcane Shot",                 -- TODO VERIFY
      ["icon"]        = "Spell_Arcane_ArcaneMissiles",  -- TODO ICON confirm
      ["buffName"]    = nil,                            -- TODO: exact buff name from Spell.dbc
    },

    {
      ["state"]       = 3,
      ["label"]       = "Nature Ammo",
      ["school"]      = "Nature",
      ["duration"]    = "60s",                          -- TODO VERIFY
      ["consumeSpell"] = "Serpent Sting",               -- TODO VERIFY
      ["icon"]        = "Spell_Nature_NatureBolt",      -- TODO ICON confirm
      ["buffName"]    = nil,                            -- TODO: exact buff name from Spell.dbc
    },

  },

}
