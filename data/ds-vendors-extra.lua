-- MetaHunt Vendor Extras (generated from pfQuest/pfQuest-turtle)
-- Adds missing vendors referenced by imported item sources
if not MTH_DS then MTH_DS = {} end
if not MTH_DS_Vendors then MTH_DS_Vendors = {} end

if not MTH_DS_Vendors[7] then
  MTH_DS_Vendors[7] = {
    ["name"] = '*',
    ["lvl"] = '1',
    ["fac"] = 'AH',
    ["meta"] = {
      ["vendor"] = 'AH',
    },
    ["coords"] = {
    },
  }
end

if not MTH_DS_Vendors[3534] then
  MTH_DS_Vendors[3534] = {
    ["name"] = 'Wallace the Blind',
    ["lvl"] = '19',
    ["fac"] = 'AH',
    ["meta"] = {
      ["vendor"] = 'AH',
    },
    ["coords"] = {
      {46.5, 86.5, 130},
      {47.9, 16.2, 5179},
    },
  }
end

if not MTH_DS_Vendors[5814] then
  MTH_DS_Vendors[5814] = {
    ["name"] = 'Innkeeper Thulbek',
    ["lvl"] = '30',
    ["fac"] = 'H',
    ["meta"] = {
      ["vendor"] = 'H',
    },
    ["coords"] = {
      {31.5, 29.8, 33},
    },
  }
end

if not MTH_DS_Vendors[12782] then
  MTH_DS_Vendors[12782] = {
    ["name"] = "Captain O\'Neal",
    ["lvl"] = '55',
    ["fac"] = 'A',
    ["meta"] = {
      ["vendor"] = 'A',
    },
    ["coords"] = {
    },
  }
end

if not MTH_DS_Vendors[14581] then
  MTH_DS_Vendors[14581] = {
    ["name"] = 'Sergeant Thunderhorn',
    ["lvl"] = '55',
    ["fac"] = 'AH',
    ["meta"] = {
      ["vendor"] = 'AH',
    },
    ["coords"] = {
    },
  }
end

if not MTH_DS_Vendors[14753] then
  MTH_DS_Vendors[14753] = {
    ["name"] = 'Illiyana Moonblaze',
    ["lvl"] = '55',
    ["fac"] = 'A',
    ["meta"] = {
      ["vendor"] = 'A',
    },
    ["coords"] = {
      {61.5, 83.9, 331},
    },
  }
end

if not MTH_DS_Vendors[14754] then
  MTH_DS_Vendors[14754] = {
    ["name"] = 'Kelm Hargunth',
    ["lvl"] = '55',
    ["fac"] = 'H',
    ["meta"] = {
      ["vendor"] = 'H',
    },
    ["coords"] = {
      {46.7, 8.4, 17},
    },
  }
end

if not MTH_DS_Vendors[14846] then
  MTH_DS_Vendors[14846] = {
    ["name"] = 'Lhara',
    ["lvl"] = '35',
    ["fac"] = 'AH',
    ["meta"] = {
      ["vendor"] = 'AH',
    },
    ["coords"] = {
      {41.2, 69.9, 12},
      {36.5, 37.9, 215},
    },
  }
end

if not MTH_DS_Vendors[80266] then
  MTH_DS_Vendors[80266] = {
    ["name"] = 'Soalara Dawnstar',
    ["lvl"] = '11',
    ["fac"] = 'A',
    ["meta"] = {
      ["vendor"] = 'A',
    },
    ["coords"] = {
      {60, 61.6, 2040},
      {66.4, 31.4, 5225},
    },
  }
end

if not MTH_DS_Vendors[80807] then
  MTH_DS_Vendors[80807] = {
    ["name"] = 'Reolis Riptusk',
    ["lvl"] = '11',
    ["fac"] = 'H',
    ["meta"] = {
      ["vendor"] = 'H',
    },
    ["coords"] = {
      {25, 12.2, 406},
    },
  }
end

if not MTH_DS_Vendors[80915] then
  MTH_DS_Vendors[80915] = {
    ["name"] = "Tan\'Pogo",
    ["lvl"] = '11',
    ["fac"] = 'H',
    ["meta"] = {
      ["vendor"] = 'H',
    },
    ["coords"] = {
      {25.1, 12, 406},
    },
  }
end

if not MTH_DS_Vendors[80941] then
  MTH_DS_Vendors[80941] = {
    ["name"] = 'Earthcaller Jalyssa',
    ["lvl"] = '11',
    ["fac"] = 'AH',
    ["meta"] = {
      ["vendor"] = 'AH',
    },
    ["coords"] = {
      {36.5, 81.2, 405},
    },
  }
end

if not MTH_DS_Vendors[80942] then
  MTH_DS_Vendors[80942] = {
    ["name"] = 'Deathcaller Aisha',
    ["lvl"] = '11',
    ["fac"] = 'AH',
    ["meta"] = {
      ["vendor"] = 'AH',
    },
    ["coords"] = {
      {73.9, 73.8, 405},
    },
  }
end

if not MTH_DS_Vendors[80943] then
  MTH_DS_Vendors[80943] = {
    ["name"] = 'Dronormu',
    ["lvl"] = '57',
    ["fac"] = 'AH',
    ["meta"] = {
      ["vendor"] = 'AH',
    },
    ["coords"] = {
      {63.5, 57.7, 440},
      {67.2, 56.8, 1941},
    },
  }
end


-- Hunter service NPCs (stable master / hunter trainer / pet trainer)
-- Generated from cached Turtle search pages + pfQuest/pfQuest-turtle lookups
if not MTH_DS_Vendors[543] then
  MTH_DS_Vendors[543] = {
    ["name"] = 'Nalesette Wildbringer',
    ["lvl"] = '40',
    ["fac"] = 'A',
    ["meta"] = {
      ["pettrainer"] = 'A',
    },
    ["coords"] = {
      {62.2, 24.4, 361},
    },
  }
end

if not MTH_DS_Vendors[895] then
  MTH_DS_Vendors[895] = {
    ["name"] = 'Thorgas Grimson',
    ["lvl"] = '5',
    ["fac"] = 'A',
    ["meta"] = {
      ["huntertrainer"] = 'A',
    },
    ["coords"] = {
      {29.2, 67.5, 1},
    },
  }
end

if not MTH_DS_Vendors[987] then
  MTH_DS_Vendors[987] = {
    ["name"] = 'Ogromm',
    ["lvl"] = '50',
    ["fac"] = 'H',
    ["meta"] = {
      ["huntertrainer"] = 'H',
    },
    ["coords"] = {
      {47.3, 53.4, 8},
    },
  }
end

if not MTH_DS_Vendors[1231] then
  MTH_DS_Vendors[1231] = {
    ["name"] = 'Grif Wildheart',
    ["lvl"] = '8-12',
    ["fac"] = 'A',
    ["meta"] = {
      ["huntertrainer"] = 'A',
    },
    ["coords"] = {
      {45.8, 53, 1},
    },
  }
end

if not MTH_DS_Vendors[1404] then
  MTH_DS_Vendors[1404] = {
    ["name"] = 'Kragg',
    ["lvl"] = '40',
    ["fac"] = 'H',
    ["meta"] = {
      ["huntertrainer"] = 'H',
    },
    ["coords"] = {
      {31.2, 28.7, 33},
    },
  }
end

if not MTH_DS_Vendors[2878] then
  MTH_DS_Vendors[2878] = {
    ["name"] = 'Peria Lamenur',
    ["lvl"] = '40',
    ["fac"] = 'A',
    ["meta"] = {
      ["pettrainer"] = 'A',
    },
    ["coords"] = {
      {46.7, 54, 1},
      {71, 38, 1},
    },
  }
end

if not MTH_DS_Vendors[2879] then
  MTH_DS_Vendors[2879] = {
    ["name"] = 'Karrina Mekenda',
    ["lvl"] = '40',
    ["fac"] = 'A',
    ["meta"] = {
      ["pettrainer"] = 'A',
    },
    ["coords"] = {
      {67.3, 36.8, 1519},
      {52.6, 97.1, 5581},
    },
  }
end

if not MTH_DS_Vendors[3038] then
  MTH_DS_Vendors[3038] = {
    ["name"] = 'Kary Thunderhorn',
    ["lvl"] = '50',
    ["fac"] = 'H',
    ["meta"] = {
      ["huntertrainer"] = 'H',
    },
    ["coords"] = {
      {41.7, 34.8, 215},
      {58.5, 88.3, 1638},
    },
  }
end

if not MTH_DS_Vendors[3039] then
  MTH_DS_Vendors[3039] = {
    ["name"] = 'Holt Thunderhorn',
    ["lvl"] = '60',
    ["fac"] = 'H',
    ["meta"] = {
      ["huntertrainer"] = 'H',
    },
    ["coords"] = {
      {41.4, 35.1, 215},
      {57.3, 89.8, 1638},
    },
  }
end

if not MTH_DS_Vendors[3040] then
  MTH_DS_Vendors[3040] = {
    ["name"] = 'Urek Thunderhorn',
    ["lvl"] = '40',
    ["fac"] = 'H',
    ["meta"] = {
      ["huntertrainer"] = 'H',
    },
    ["coords"] = {
      {41.8, 34.5, 215},
      {59.1, 86.9, 1638},
    },
  }
end

if not MTH_DS_Vendors[3061] then
  MTH_DS_Vendors[3061] = {
    ["name"] = 'Lanka Farshot',
    ["lvl"] = '11',
    ["fac"] = 'H',
    ["meta"] = {
      ["huntertrainer"] = 'H',
    },
    ["coords"] = {
      {44.3, 75.7, 215},
    },
  }
end

if not MTH_DS_Vendors[3065] then
  MTH_DS_Vendors[3065] = {
    ["name"] = 'Yaw Sharpmane',
    ["lvl"] = '11',
    ["fac"] = 'H',
    ["meta"] = {
      ["huntertrainer"] = 'H',
    },
    ["coords"] = {
      {47.8, 55.7, 215},
    },
  }
end

if not MTH_DS_Vendors[3154] then
  MTH_DS_Vendors[3154] = {
    ["name"] = 'Jen\'shan',
    ["lvl"] = '8',
    ["fac"] = 'H',
    ["meta"] = {
      ["huntertrainer"] = 'H',
    },
    ["coords"] = {
      {42.8, 69.3, 14},
    },
  }
end

if not MTH_DS_Vendors[3171] then
  MTH_DS_Vendors[3171] = {
    ["name"] = 'Thotar',
    ["lvl"] = '16',
    ["fac"] = 'H',
    ["meta"] = {
      ["huntertrainer"] = 'H',
    },
    ["coords"] = {
      {51.8, 43.5, 14},
    },
  }
end

if not MTH_DS_Vendors[3306] then
  MTH_DS_Vendors[3306] = {
    ["name"] = 'Keldas',
    ["lvl"] = '40',
    ["fac"] = 'A',
    ["meta"] = {
      ["pettrainer"] = 'A',
    },
    ["coords"] = {
      {56.8, 59.8, 141},
    },
  }
end

if not MTH_DS_Vendors[3352] then
  MTH_DS_Vendors[3352] = {
    ["name"] = 'Ormak Grimshot',
    ["lvl"] = '60',
    ["fac"] = 'H',
    ["meta"] = {
      ["huntertrainer"] = 'H',
    },
    ["coords"] = {
      {66, 18.5, 1637},
    },
  }
end

if not MTH_DS_Vendors[3406] then
  MTH_DS_Vendors[3406] = {
    ["name"] = 'Xor\'juul',
    ["lvl"] = '50',
    ["fac"] = 'H',
    ["meta"] = {
      ["huntertrainer"] = 'H',
    },
    ["coords"] = {
      {67.2, 20.2, 1637},
    },
  }
end

if not MTH_DS_Vendors[3407] then
  MTH_DS_Vendors[3407] = {
    ["name"] = 'Sian\'dur',
    ["lvl"] = '40',
    ["fac"] = 'H',
    ["meta"] = {
      ["huntertrainer"] = 'H',
    },
    ["coords"] = {
      {68, 17.8, 1637},
    },
  }
end

if not MTH_DS_Vendors[3545] then
  MTH_DS_Vendors[3545] = {
    ["name"] = 'Claude Erksine',
    ["lvl"] = '40',
    ["fac"] = 'A',
    ["meta"] = {
      ["pettrainer"] = 'A',
    },
    ["coords"] = {
      {82.2, 62.8, 38},
      {40.6, 76.4, 5602},
    },
  }
end

if not MTH_DS_Vendors[3596] then
  MTH_DS_Vendors[3596] = {
    ["name"] = 'Ayanna Everstride',
    ["lvl"] = '10',
    ["fac"] = 'A',
    ["meta"] = {
      ["huntertrainer"] = 'A',
    },
    ["coords"] = {
      {58.7, 40.4, 141},
    },
  }
end

if not MTH_DS_Vendors[3601] then
  MTH_DS_Vendors[3601] = {
    ["name"] = 'Dazalar',
    ["lvl"] = '20',
    ["fac"] = 'A',
    ["meta"] = {
      ["huntertrainer"] = 'A',
    },
    ["coords"] = {
      {56.7, 59.5, 141},
    },
  }
end

if not MTH_DS_Vendors[3620] then
  MTH_DS_Vendors[3620] = {
    ["name"] = 'Harruk',
    ["lvl"] = '40',
    ["fac"] = 'H',
    ["meta"] = {
      ["pettrainer"] = 'H',
    },
    ["coords"] = {
      {52, 43.5, 14},
    },
  }
end

if not MTH_DS_Vendors[3622] then
  MTH_DS_Vendors[3622] = {
    ["name"] = 'Grokor',
    ["lvl"] = '40',
    ["fac"] = 'H',
    ["meta"] = {
      ["pettrainer"] = 'H',
    },
    ["coords"] = {
      {47.4, 52.9, 8},
    },
  }
end

if not MTH_DS_Vendors[3624] then
  MTH_DS_Vendors[3624] = {
    ["name"] = 'Zudd',
    ["lvl"] = '40',
    ["fac"] = 'H',
    ["meta"] = {
      ["pettrainer"] = 'H',
    },
    ["coords"] = {
      {31.1, 28.9, 33},
    },
  }
end

if not MTH_DS_Vendors[3688] then
  MTH_DS_Vendors[3688] = {
    ["name"] = 'Reban Freerunner',
    ["lvl"] = '40',
    ["fac"] = 'H',
    ["meta"] = {
      ["pettrainer"] = 'H',
    },
    ["coords"] = {
      {47.7, 55.7, 215},
    },
  }
end

if not MTH_DS_Vendors[3698] then
  MTH_DS_Vendors[3698] = {
    ["name"] = 'Bolyun',
    ["lvl"] = '40',
    ["fac"] = 'A',
    ["meta"] = {
      ["pettrainer"] = 'A',
    },
    ["coords"] = {
      {18, 60, 331},
      {54.6, 26.8, 406},
    },
  }
end

if not MTH_DS_Vendors[3963] then
  MTH_DS_Vendors[3963] = {
    ["name"] = 'Danlaar Nightstride',
    ["lvl"] = '35',
    ["fac"] = 'A',
    ["meta"] = {
      ["huntertrainer"] = 'A',
    },
    ["coords"] = {
      {50.1, 67.9, 331},
    },
  }
end

if not MTH_DS_Vendors[4138] then
  MTH_DS_Vendors[4138] = {
    ["name"] = 'Jeen\'ra Nightrunner',
    ["lvl"] = '60',
    ["fac"] = 'A',
    ["meta"] = {
      ["huntertrainer"] = 'A',
    },
    ["coords"] = {
      {25.5, 48.1, 141},
      {39.7, 5.4, 1657},
    },
  }
end

if not MTH_DS_Vendors[4146] then
  MTH_DS_Vendors[4146] = {
    ["name"] = 'Jocaste',
    ["lvl"] = '40',
    ["fac"] = 'A',
    ["meta"] = {
      ["huntertrainer"] = 'A',
    },
    ["coords"] = {
      {25.6, 48.7, 141},
      {40.4, 8.5, 1657},
    },
  }
end

if not MTH_DS_Vendors[4205] then
  MTH_DS_Vendors[4205] = {
    ["name"] = 'Dorion',
    ["lvl"] = '50',
    ["fac"] = 'A',
    ["meta"] = {
      ["huntertrainer"] = 'A',
    },
    ["coords"] = {
      {26, 48.4, 141},
      {42.2, 7.3, 1657},
    },
  }
end

if not MTH_DS_Vendors[4320] then
  MTH_DS_Vendors[4320] = {
    ["name"] = 'Caelyb',
    ["lvl"] = '40',
    ["fac"] = 'A',
    ["meta"] = {
      ["pettrainer"] = 'A',
    },
    ["coords"] = {
      {49.7, 67, 331},
    },
  }
end

if not MTH_DS_Vendors[5115] then
  MTH_DS_Vendors[5115] = {
    ["name"] = 'Daera Brightspear',
    ["lvl"] = '60',
    ["fac"] = 'A',
    ["meta"] = {
      ["huntertrainer"] = 'A',
    },
    ["coords"] = {
      {71, 89.8, 1537},
    },
  }
end

if not MTH_DS_Vendors[5116] then
  MTH_DS_Vendors[5116] = {
    ["name"] = 'Olmin Burningbeard',
    ["lvl"] = '50',
    ["fac"] = 'A',
    ["meta"] = {
      ["huntertrainer"] = 'A',
    },
    ["coords"] = {
      {70.9, 83.6, 1537},
    },
  }
end

if not MTH_DS_Vendors[5117] then
  MTH_DS_Vendors[5117] = {
    ["name"] = 'Regnus Thundergranite',
    ["lvl"] = '40',
    ["fac"] = 'A',
    ["meta"] = {
      ["huntertrainer"] = 'A',
    },
    ["coords"] = {
      {69.9, 82.9, 1537},
    },
  }
end

if not MTH_DS_Vendors[5501] then
  MTH_DS_Vendors[5501] = {
    ["name"] = 'Kaerbrus',
    ["lvl"] = '57',
    ["fac"] = 'A',
    ["meta"] = {
      ["huntertrainer"] = 'A',
    },
    ["coords"] = {
      {61.9, 23.6, 361},
    },
  }
end

if not MTH_DS_Vendors[5515] then
  MTH_DS_Vendors[5515] = {
    ["name"] = 'Einris Brightspear',
    ["lvl"] = '60',
    ["fac"] = 'A',
    ["meta"] = {
      ["huntertrainer"] = 'A',
    },
    ["coords"] = {
      {67.4, 36.3, 1519},
      {52.6, 96.8, 5581},
    },
  }
end

if not MTH_DS_Vendors[5516] then
  MTH_DS_Vendors[5516] = {
    ["name"] = 'Ulfir Ironbeard',
    ["lvl"] = '50',
    ["fac"] = 'A',
    ["meta"] = {
      ["huntertrainer"] = 'A',
    },
    ["coords"] = {
      {67.6, 35.8, 1519},
      {52.7, 96.6, 5581},
    },
  }
end

if not MTH_DS_Vendors[5517] then
  MTH_DS_Vendors[5517] = {
    ["name"] = 'Thorfin Stoneshield',
    ["lvl"] = '40',
    ["fac"] = 'A',
    ["meta"] = {
      ["huntertrainer"] = 'A',
    },
    ["coords"] = {
      {68, 36, 1519},
      {53, 96.7, 5581},
    },
  }
end

if not MTH_DS_Vendors[6749] then
  MTH_DS_Vendors[6749] = {
    ["name"] = 'Erma',
    ["lvl"] = '30',
    ["fac"] = 'A',
    ["meta"] = {
      ["stablemaster"] = 'A',
    },
    ["coords"] = {
      {42.9, 65.9, 12},
    },
  }
end

if not MTH_DS_Vendors[8308] then
  MTH_DS_Vendors[8308] = {
    ["name"] = 'Alenndaar Lapidaar',
    ["lvl"] = '27',
    ["fac"] = 'A',
    ["meta"] = {
      ["huntertrainer"] = 'A',
    },
    ["coords"] = {
      {18, 59.8, 331},
      {54.6, 26.6, 406},
    },
  }
end

if not MTH_DS_Vendors[9976] then
  MTH_DS_Vendors[9976] = {
    ["name"] = 'Tharlidun',
    ["lvl"] = '30',
    ["fac"] = 'H',
    ["meta"] = {
      ["stablemaster"] = 'H',
    },
    ["coords"] = {
      {73.9, 33.1, 45},
    },
  }
end

if not MTH_DS_Vendors[9977] then
  MTH_DS_Vendors[9977] = {
    ["name"] = 'Sylista',
    ["lvl"] = '30',
    ["fac"] = 'A',
    ["meta"] = {
      ["stablemaster"] = 'A',
    },
    ["coords"] = {
      {42.6, 64.1, 1519},
    },
  }
end

if not MTH_DS_Vendors[9978] then
  MTH_DS_Vendors[9978] = {
    ["name"] = 'Wesley',
    ["lvl"] = '30',
    ["fac"] = 'A',
    ["meta"] = {
      ["stablemaster"] = 'A',
    },
    ["coords"] = {
      {50.4, 58.8, 267},
    },
  }
end

if not MTH_DS_Vendors[9979] then
  MTH_DS_Vendors[9979] = {
    ["name"] = 'Sarah Goode',
    ["lvl"] = '30',
    ["fac"] = 'H',
    ["meta"] = {
      ["stablemaster"] = 'H',
    },
    ["coords"] = {
      {43.5, 41.2, 130},
    },
  }
end

if not MTH_DS_Vendors[9980] then
  MTH_DS_Vendors[9980] = {
    ["name"] = 'Shelby Stoneflint',
    ["lvl"] = '30',
    ["fac"] = 'A',
    ["meta"] = {
      ["stablemaster"] = 'A',
    },
    ["coords"] = {
      {47, 52.7, 1},
    },
  }
end

if not MTH_DS_Vendors[9981] then
  MTH_DS_Vendors[9981] = {
    ["name"] = 'Sikwa',
    ["lvl"] = '30',
    ["fac"] = 'H',
    ["meta"] = {
      ["stablemaster"] = 'H',
    },
    ["coords"] = {
      {51.7, 29.7, 17},
    },
  }
end

if not MTH_DS_Vendors[9982] then
  MTH_DS_Vendors[9982] = {
    ["name"] = 'Penny',
    ["lvl"] = '30',
    ["fac"] = 'A',
    ["meta"] = {
      ["stablemaster"] = 'A',
    },
    ["coords"] = {
      {26.8, 46.6, 44},
    },
  }
end

if not MTH_DS_Vendors[9983] then
  MTH_DS_Vendors[9983] = {
    ["name"] = 'Kelsuwa',
    ["lvl"] = '30',
    ["fac"] = 'H',
    ["meta"] = {
      ["stablemaster"] = 'H',
    },
    ["coords"] = {
      {45.3, 58.7, 17},
    },
  }
end

if not MTH_DS_Vendors[9984] then
  MTH_DS_Vendors[9984] = {
    ["name"] = 'Ulbrek Firehand',
    ["lvl"] = '30',
    ["fac"] = 'A',
    ["meta"] = {
      ["stablemaster"] = 'A',
    },
    ["coords"] = {
      {69.3, 83.6, 1537},
    },
  }
end

if not MTH_DS_Vendors[9985] then
  MTH_DS_Vendors[9985] = {
    ["name"] = 'Laziphus',
    ["lvl"] = '30',
    ["fac"] = 'AH',
    ["meta"] = {
      ["stablemaster"] = 'AH',
    },
    ["coords"] = {
      {52.3, 28.4, 440},
    },
  }
end

if not MTH_DS_Vendors[9986] then
  MTH_DS_Vendors[9986] = {
    ["name"] = 'Shyrka Wolfrunner',
    ["lvl"] = '30',
    ["fac"] = 'H',
    ["meta"] = {
      ["stablemaster"] = 'H',
    },
    ["coords"] = {
      {74.5, 43.3, 357},
    },
  }
end

if not MTH_DS_Vendors[9987] then
  MTH_DS_Vendors[9987] = {
    ["name"] = 'Shoja\'my',
    ["lvl"] = '30',
    ["fac"] = 'H',
    ["meta"] = {
      ["stablemaster"] = 'H',
    },
    ["coords"] = {
      {52, 41.8, 14},
    },
  }
end

if not MTH_DS_Vendors[9988] then
  MTH_DS_Vendors[9988] = {
    ["name"] = 'Xon\'cha',
    ["lvl"] = '30',
    ["fac"] = 'H',
    ["meta"] = {
      ["stablemaster"] = 'H',
    },
    ["coords"] = {
      {70.4, 15, 1637},
    },
  }
end

if not MTH_DS_Vendors[9989] then
  MTH_DS_Vendors[9989] = {
    ["name"] = 'Lina Hearthstove',
    ["lvl"] = '30',
    ["fac"] = 'A',
    ["meta"] = {
      ["stablemaster"] = 'A',
    },
    ["coords"] = {
      {34.6, 48.1, 38},
      {16.3, 68.9, 5602},
    },
  }
end

if not MTH_DS_Vendors[10045] then
  MTH_DS_Vendors[10045] = {
    ["name"] = 'Kirk Maxwell',
    ["lvl"] = '30',
    ["fac"] = 'A',
    ["meta"] = {
      ["stablemaster"] = 'A',
    },
    ["coords"] = {
      {52.9, 53.1, 40},
    },
  }
end

if not MTH_DS_Vendors[10046] then
  MTH_DS_Vendors[10046] = {
    ["name"] = 'Bethaine Flinthammer',
    ["lvl"] = '30',
    ["fac"] = 'A',
    ["meta"] = {
      ["stablemaster"] = 'A',
    },
    ["coords"] = {
      {10.5, 59.7, 11},
    },
  }
end

if not MTH_DS_Vendors[10047] then
  MTH_DS_Vendors[10047] = {
    ["name"] = 'Michael',
    ["lvl"] = '30',
    ["fac"] = 'A',
    ["meta"] = {
      ["stablemaster"] = 'A',
    },
    ["coords"] = {
      {66, 45.5, 15},
    },
  }
end

if not MTH_DS_Vendors[10048] then
  MTH_DS_Vendors[10048] = {
    ["name"] = 'Gereck',
    ["lvl"] = '30',
    ["fac"] = 'H',
    ["meta"] = {
      ["stablemaster"] = 'H',
    },
    ["coords"] = {
      {50.6, 62.9, 406},
    },
  }
end

if not MTH_DS_Vendors[10049] then
  MTH_DS_Vendors[10049] = {
    ["name"] = 'Hekkru',
    ["lvl"] = '30',
    ["fac"] = 'H',
    ["meta"] = {
      ["stablemaster"] = 'H',
    },
    ["coords"] = {
      {45.6, 55.2, 8},
    },
  }
end

if not MTH_DS_Vendors[10050] then
  MTH_DS_Vendors[10050] = {
    ["name"] = 'Seikwa',
    ["lvl"] = '30',
    ["fac"] = 'H',
    ["meta"] = {
      ["stablemaster"] = 'H',
    },
    ["coords"] = {
      {46.8, 60.4, 215},
    },
  }
end

if not MTH_DS_Vendors[10051] then
  MTH_DS_Vendors[10051] = {
    ["name"] = 'Seriadne',
    ["lvl"] = '30',
    ["fac"] = 'A',
    ["meta"] = {
      ["stablemaster"] = 'A',
    },
    ["coords"] = {
      {56.6, 59.6, 141},
    },
  }
end

if not MTH_DS_Vendors[10052] then
  MTH_DS_Vendors[10052] = {
    ["name"] = 'Maluressian',
    ["lvl"] = '30',
    ["fac"] = 'A',
    ["meta"] = {
      ["stablemaster"] = 'A',
    },
    ["coords"] = {
      {36.5, 50.4, 331},
    },
  }
end

if not MTH_DS_Vendors[10053] then
  MTH_DS_Vendors[10053] = {
    ["name"] = 'Anya Maulray',
    ["lvl"] = '30',
    ["fac"] = 'H',
    ["meta"] = {
      ["stablemaster"] = 'H',
    },
    ["coords"] = {
      {67.4, 37.6, 1497},
    },
  }
end

if not MTH_DS_Vendors[10054] then
  MTH_DS_Vendors[10054] = {
    ["name"] = 'Bulrug',
    ["lvl"] = '30',
    ["fac"] = 'H',
    ["meta"] = {
      ["stablemaster"] = 'H',
    },
    ["coords"] = {
      {39, 29.1, 215},
      {45.1, 60.2, 1638},
    },
  }
end

if not MTH_DS_Vendors[10055] then
  MTH_DS_Vendors[10055] = {
    ["name"] = 'Morganus',
    ["lvl"] = '30',
    ["fac"] = 'H',
    ["meta"] = {
      ["stablemaster"] = 'H',
    },
    ["coords"] = {
      {60, 52.2, 85},
    },
  }
end

if not MTH_DS_Vendors[10056] then
  MTH_DS_Vendors[10056] = {
    ["name"] = 'Alassin',
    ["lvl"] = '30',
    ["fac"] = 'A',
    ["meta"] = {
      ["stablemaster"] = 'A',
    },
    ["coords"] = {
      {25.4, 49, 141},
      {39.3, 10, 1657},
    },
  }
end

if not MTH_DS_Vendors[10057] then
  MTH_DS_Vendors[10057] = {
    ["name"] = 'Theodore Mont Claire',
    ["lvl"] = '30',
    ["fac"] = 'H',
    ["meta"] = {
      ["stablemaster"] = 'H',
    },
    ["coords"] = {
      {61.1, 81.4, 36},
      {62.3, 19.7, 267},
    },
  }
end

if not MTH_DS_Vendors[10058] then
  MTH_DS_Vendors[10058] = {
    ["name"] = 'Greth',
    ["lvl"] = '30',
    ["fac"] = 'H',
    ["meta"] = {
      ["stablemaster"] = 'H',
    },
    ["coords"] = {
      {3.7, 47.6, 3},
      {82.8, 38.9, 51},
    },
  }
end

if not MTH_DS_Vendors[10059] then
  MTH_DS_Vendors[10059] = {
    ["name"] = 'Antarius',
    ["lvl"] = '30',
    ["fac"] = 'A',
    ["meta"] = {
      ["stablemaster"] = 'A',
    },
    ["coords"] = {
      {31.5, 43.1, 357},
    },
  }
end

if not MTH_DS_Vendors[10060] then
  MTH_DS_Vendors[10060] = {
    ["name"] = 'Grimestack',
    ["lvl"] = '46',
    ["fac"] = 'AH',
    ["meta"] = {
      ["stablemaster"] = 'AH',
    },
    ["coords"] = {
      {27.3, 77.2, 33},
    },
  }
end

if not MTH_DS_Vendors[10061] then
  MTH_DS_Vendors[10061] = {
    ["name"] = 'Killium Bouldertoe',
    ["lvl"] = '30',
    ["fac"] = 'A',
    ["meta"] = {
      ["stablemaster"] = 'A',
    },
    ["coords"] = {
      {14.4, 45.2, 47},
      {99.9, 4.4, 267},
    },
  }
end

if not MTH_DS_Vendors[10062] then
  MTH_DS_Vendors[10062] = {
    ["name"] = 'Steven Black',
    ["lvl"] = '30',
    ["fac"] = 'A',
    ["meta"] = {
      ["stablemaster"] = 'A',
    },
    ["coords"] = {
      {74, 46.1, 10},
    },
  }
end

if not MTH_DS_Vendors[10063] then
  MTH_DS_Vendors[10063] = {
    ["name"] = 'Reggifuz',
    ["lvl"] = '35',
    ["fac"] = 'AH',
    ["meta"] = {
      ["stablemaster"] = 'AH',
    },
    ["coords"] = {
      {62.2, 39.2, 17},
    },
  }
end

if not MTH_DS_Vendors[10085] then
  MTH_DS_Vendors[10085] = {
    ["name"] = 'Jaelysia',
    ["lvl"] = '30',
    ["fac"] = 'A',
    ["meta"] = {
      ["stablemaster"] = 'A',
    },
    ["coords"] = {
      {37.4, 44.3, 148},
    },
  }
end

if not MTH_DS_Vendors[10086] then
  MTH_DS_Vendors[10086] = {
    ["name"] = 'Hesuwa Thunderhorn',
    ["lvl"] = '40',
    ["fac"] = 'H',
    ["meta"] = {
      ["pettrainer"] = 'H',
    },
    ["coords"] = {
      {40.8, 33.9, 215},
      {54.1, 84, 1638},
    },
  }
end

if not MTH_DS_Vendors[10088] then
  MTH_DS_Vendors[10088] = {
    ["name"] = 'Xao\'tsu',
    ["lvl"] = '40',
    ["fac"] = 'H',
    ["meta"] = {
      ["pettrainer"] = 'H',
    },
    ["coords"] = {
      {66.3, 14.8, 1637},
    },
  }
end

if not MTH_DS_Vendors[10089] then
  MTH_DS_Vendors[10089] = {
    ["name"] = 'Silvaria',
    ["lvl"] = '40',
    ["fac"] = 'A',
    ["meta"] = {
      ["pettrainer"] = 'A',
    },
    ["coords"] = {
      {26, 48.8, 141},
      {42.5, 9.2, 1657},
    },
  }
end

if not MTH_DS_Vendors[10090] then
  MTH_DS_Vendors[10090] = {
    ["name"] = 'Belia Thundergranite',
    ["lvl"] = '40',
    ["fac"] = 'A',
    ["meta"] = {
      ["pettrainer"] = 'A',
    },
    ["coords"] = {
      {70.9, 85.8, 1537},
    },
  }
end

if not MTH_DS_Vendors[10930] then
  MTH_DS_Vendors[10930] = {
    ["name"] = 'Dargh Trueaim',
    ["lvl"] = '25',
    ["fac"] = 'A',
    ["meta"] = {
      ["huntertrainer"] = 'A',
    },
    ["coords"] = {
      {35, 47.7, 38},
      {16.5, 68.7, 5602},
    },
  }
end

if not MTH_DS_Vendors[11069] then
  MTH_DS_Vendors[11069] = {
    ["name"] = 'Jenova Stoneshield',
    ["lvl"] = '30',
    ["fac"] = 'A',
    ["meta"] = {
      ["stablemaster"] = 'A',
    },
    ["coords"] = {
      {67.2, 37.7, 1519},
      {52.6, 97.6, 5581},
    },
  }
end

if not MTH_DS_Vendors[11104] then
  MTH_DS_Vendors[11104] = {
    ["name"] = 'Shelgrayn',
    ["lvl"] = '30',
    ["fac"] = 'A',
    ["meta"] = {
      ["stablemaster"] = 'A',
    },
    ["coords"] = {
      {65.6, 7.8, 405},
      {44.3, 80.4, 406},
    },
  }
end

if not MTH_DS_Vendors[11105] then
  MTH_DS_Vendors[11105] = {
    ["name"] = 'Aboda',
    ["lvl"] = '30',
    ["fac"] = 'H',
    ["meta"] = {
      ["stablemaster"] = 'H',
    },
    ["coords"] = {
      {24.9, 68.7, 405},
      {11.4, 92.8, 2100},
    },
  }
end

if not MTH_DS_Vendors[11117] then
  MTH_DS_Vendors[11117] = {
    ["name"] = 'Awenasa',
    ["lvl"] = '30',
    ["fac"] = 'H',
    ["meta"] = {
      ["stablemaster"] = 'H',
    },
    ["coords"] = {
      {45.8, 51.1, 400},
    },
  }
end

if not MTH_DS_Vendors[11119] then
  MTH_DS_Vendors[11119] = {
    ["name"] = 'Azzleby',
    ["lvl"] = '30',
    ["fac"] = 'AH',
    ["meta"] = {
      ["stablemaster"] = 'AH',
    },
    ["coords"] = {
      {60.4, 37.9, 618},
    },
  }
end

if not MTH_DS_Vendors[13616] then
  MTH_DS_Vendors[13616] = {
    ["name"] = 'Frostwolf Stable Master',
    ["lvl"] = '60',
    ["fac"] = 'H',
    ["meta"] = {
      ["stablemaster"] = 'H',
    },
    ["coords"] = {
      {57.1, 82.5, 2597},
    },
  }
end

if not MTH_DS_Vendors[13617] then
  MTH_DS_Vendors[13617] = {
    ["name"] = 'Stormpike Stable Master',
    ["lvl"] = '60',
    ["fac"] = 'A',
    ["meta"] = {
      ["stablemaster"] = 'A',
    },
    ["coords"] = {
      {42.6, 16.8, 2597},
    },
  }
end

if not MTH_DS_Vendors[14741] then
  MTH_DS_Vendors[14741] = {
    ["name"] = 'Huntsman Markhor',
    ["lvl"] = '45',
    ["fac"] = 'H',
    ["meta"] = {
      ["stablemaster"] = 'H',
    },
    ["coords"] = {
      {79.2, 79.5, 47},
    },
  }
end

if not MTH_DS_Vendors[15131] then
  MTH_DS_Vendors[15131] = {
    ["name"] = 'Qeeju',
    ["lvl"] = '45',
    ["fac"] = 'H',
    ["meta"] = {
      ["stablemaster"] = 'H',
    },
    ["coords"] = {
      {73.4, 61, 331},
    },
  }
end

if not MTH_DS_Vendors[15722] then
  MTH_DS_Vendors[15722] = {
    ["name"] = 'Squire Leoren Mal\'derath',
    ["lvl"] = '60',
    ["fac"] = 'AH',
    ["meta"] = {
      ["stablemaster"] = 'AH',
    },
    ["coords"] = {
      {49.3, 36.4, 1377},
    },
  }
end

if not MTH_DS_Vendors[16094] then
  MTH_DS_Vendors[16094] = {
    ["name"] = 'Durik',
    ["lvl"] = '30',
    ["fac"] = 'H',
    ["meta"] = {
      ["stablemaster"] = 'H',
    },
    ["coords"] = {
      {31.9, 29.5, 33},
    },
  }
end

if not MTH_DS_Vendors[16156] then
  MTH_DS_Vendors[16156] = {
    ["name"] = 'Dark Touched Warrior',
    ["lvl"] = '61',
    ["fac"] = 'AH',
    ["meta"] = {
      ["stablemaster"] = 'AH',
    },
    ["coords"] = {
      {38.7, 64.4, 3456},
      {38.5, 63.6, 3456},
      {37.9, 60.5, 3456},
      {41.9, 59.5, 3456},
      {47.2, 58.3, 3456},
    },
  }
end

if not MTH_DS_Vendors[60483] then
  MTH_DS_Vendors[60483] = {
    ["name"] = 'Morpheus Ribcage',
    ["lvl"] = '5',
    ["fac"] = 'H',
    ["meta"] = {
      ["huntertrainer"] = 'H',
    },
    ["coords"] = {
      {31, 64.3, 85},
    },
  }
end

if not MTH_DS_Vendors[60484] then
  MTH_DS_Vendors[60484] = {
    ["name"] = 'Liott Maneskin',
    ["lvl"] = '15',
    ["fac"] = 'H',
    ["meta"] = {
      ["huntertrainer"] = 'H',
    },
    ["coords"] = {
      {60.1, 51.5, 85},
    },
  }
end

if not MTH_DS_Vendors[60485] then
  MTH_DS_Vendors[60485] = {
    ["name"] = 'Noel Bearfinger',
    ["lvl"] = '60',
    ["fac"] = 'H',
    ["meta"] = {
      ["huntertrainer"] = 'H',
    },
    ["coords"] = {
      {61.4, 24.8, 1497},
    },
  }
end

if not MTH_DS_Vendors[60486] then
  MTH_DS_Vendors[60486] = {
    ["name"] = 'Vaya Spidersbite',
    ["lvl"] = '60',
    ["fac"] = 'H',
    ["meta"] = {
      ["huntertrainer"] = 'H',
    },
    ["coords"] = {
      {58.7, 30.9, 1497},
    },
  }
end

if not MTH_DS_Vendors[60487] then
  MTH_DS_Vendors[60487] = {
    ["name"] = 'Valdos Madhound',
    ["lvl"] = '60',
    ["fac"] = 'H',
    ["meta"] = {
      ["huntertrainer"] = 'H',
    },
    ["coords"] = {
      {62, 26.2, 1497},
    },
  }
end

if not MTH_DS_Vendors[60488] then
  MTH_DS_Vendors[60488] = {
    ["name"] = 'Diane Willowfield',
    ["lvl"] = '40',
    ["fac"] = 'H',
    ["meta"] = {
      ["pettrainer"] = 'H',
    },
    ["coords"] = {
      {54.6, 37.2, 1497},
    },
  }
end

if not MTH_DS_Vendors[60768] then
  MTH_DS_Vendors[60768] = {
    ["name"] = 'Herekk',
    ["lvl"] = '48',
    ["fac"] = 'H',
    ["meta"] = {
      ["stablemaster"] = 'H',
    },
    ["coords"] = {
      {93, 23.9, 46},
    },
  }
end

if not MTH_DS_Vendors[61266] then
  MTH_DS_Vendors[61266] = {
    ["name"] = 'Alexandra',
    ["lvl"] = '30',
    ["fac"] = 'A',
    ["meta"] = {
      ["stablemaster"] = 'A',
    },
    ["coords"] = {
      {57.8, 69.5, 5179},
    },
  }
end

if not MTH_DS_Vendors[61624] then
  MTH_DS_Vendors[61624] = {
    ["name"] = 'AJ Springberry',
    ["lvl"] = '12',
    ["fac"] = 'A',
    ["meta"] = {
      ["huntertrainer"] = 'A',
    },
    ["coords"] = {
      {34.1, 72.1, 1519},
    },
  }
end

if not MTH_DS_Vendors[61625] then
  MTH_DS_Vendors[61625] = {
    ["name"] = 'Daisy Windhelm',
    ["lvl"] = '20',
    ["fac"] = 'A',
    ["meta"] = {
      ["huntertrainer"] = 'A',
    },
    ["coords"] = {
      {40.9, 65.9, 12},
    },
  }
end

if not MTH_DS_Vendors[61626] then
  MTH_DS_Vendors[61626] = {
    ["name"] = 'Diane Cloverfield',
    ["lvl"] = '35',
    ["fac"] = 'A',
    ["meta"] = {
      ["huntertrainer"] = 'A',
    },
    ["coords"] = {
      {34.1, 56.5, 5179},
    },
  }
end

if not MTH_DS_Vendors[61627] then
  MTH_DS_Vendors[61627] = {
    ["name"] = 'Old Jonah',
    ["lvl"] = '5',
    ["fac"] = 'A',
    ["meta"] = {
      ["huntertrainer"] = 'A',
    },
    ["coords"] = {
      {50.8, 40, 12},
    },
  }
end

if not MTH_DS_Vendors[61628] then
  MTH_DS_Vendors[61628] = {
    ["name"] = 'Willhelm Rockdust',
    ["lvl"] = '60',
    ["fac"] = 'A',
    ["meta"] = {
      ["huntertrainer"] = 'A',
    },
    ["coords"] = {
      {34.1, 71.2, 1519},
    },
  }
end

if not MTH_DS_Vendors[61629] then
  MTH_DS_Vendors[61629] = {
    ["name"] = 'Marven',
    ["lvl"] = '35',
    ["fac"] = 'A',
    ["meta"] = {
      ["pettrainer"] = 'A',
    },
    ["coords"] = {
      {33.5, 71.8, 1519},
    },
  }
end

if not MTH_DS_Vendors[61640] then
  MTH_DS_Vendors[61640] = {
    ["name"] = 'Marksman Rembrandt Olar',
    ["lvl"] = '48',
    ["fac"] = 'A',
    ["meta"] = {
      ["huntertrainer"] = 'A',
    },
    ["coords"] = {
    },
  }
end

if not MTH_DS_Vendors[61722] then
  MTH_DS_Vendors[61722] = {
    ["name"] = 'Sazzlix',
    ["lvl"] = '35',
    ["fac"] = 'AH',
    ["meta"] = {
      ["stablemaster"] = 'AH',
    },
    ["coords"] = {
      {48.5, 65.7, 5536},
    },
  }
end

if not MTH_DS_Vendors[62098] then
  MTH_DS_Vendors[62098] = {
    ["name"] = 'Gozzlek',
    ["lvl"] = '51',
    ["fac"] = 'AH',
    ["meta"] = {
      ["stablemaster"] = 'AH',
    },
    ["coords"] = {
      {42.4, 77.3, 5121},
    },
  }
end

if not MTH_DS_Vendors[62099] then
  MTH_DS_Vendors[62099] = {
    ["name"] = 'Guzhek',
    ["lvl"] = '35',
    ["fac"] = 'AH',
    ["meta"] = {
      ["stablemaster"] = 'AH',
    },
    ["coords"] = {
      {37, 51.7, 406},
    },
  }
end

if not MTH_DS_Vendors[62161] then
  MTH_DS_Vendors[62161] = {
    ["name"] = 'Leander Hering',
    ["lvl"] = '45',
    ["fac"] = 'A',
    ["meta"] = {
      ["stablemaster"] = 'A',
    },
    ["coords"] = {
      {45.7, 58.4, 5581},
    },
  }
end

if not MTH_DS_Vendors[62401] then
  MTH_DS_Vendors[62401] = {
    ["name"] = 'Farwyn Barleynight',
    ["lvl"] = '30',
    ["fac"] = 'A',
    ["meta"] = {
      ["stablemaster"] = 'A',
    },
    ["coords"] = {
      {52.9, 57.7, 5602},
    },
  }
end

if not MTH_DS_Vendors[80105] then
  MTH_DS_Vendors[80105] = {
    ["name"] = 'Mayten Boomrifle',
    ["lvl"] = '8',
    ["fac"] = 'AH',
    ["meta"] = {
      ["huntertrainer"] = 'AH',
    },
    ["coords"] = {
      {49.3, 63.1, 5536},
    },
  }
end

if not MTH_DS_Vendors[80219] then
  MTH_DS_Vendors[80219] = {
    ["name"] = 'Ranger Rubinah Sunsworn',
    ["lvl"] = '8',
    ["fac"] = 'A',
    ["meta"] = {
      ["huntertrainer"] = 'A',
    },
    ["coords"] = {
      {6.6, 22.7, 139},
      {46.5, 84.4, 5225},
    },
  }
end

if not MTH_DS_Vendors[80245] then
  MTH_DS_Vendors[80245] = {
    ["name"] = 'Damilara Sunsorrow',
    ["lvl"] = '60',
    ["fac"] = 'A',
    ["meta"] = {
      ["huntertrainer"] = 'A',
    },
    ["coords"] = {
      {40.7, 68.5, 2040},
      {57.2, 34.6, 5225},
    },
  }
end

if not MTH_DS_Vendors[80457] then
  MTH_DS_Vendors[80457] = {
    ["name"] = 'Andrelas Thas\'danil',
    ["lvl"] = '30',
    ["fac"] = 'A',
    ["meta"] = {
      ["stablemaster"] = 'A',
    },
    ["coords"] = {
      {40.7, 68.3, 2040},
      {57.2, 34.5, 5225},
    },
  }
end

if not MTH_DS_Vendors[80458] then
  MTH_DS_Vendors[80458] = {
    ["name"] = 'Ranger Canarah Kim\'Alah',
    ["lvl"] = '55',
    ["fac"] = 'A',
    ["meta"] = {
      ["huntertrainer"] = 'A',
    },
    ["coords"] = {
      {65.2, 45.4, 1519},
    },
  }
end

if not MTH_DS_Vendors[80810] then
  MTH_DS_Vendors[80810] = {
    ["name"] = 'Rinja Scenttusk',
    ["lvl"] = '30',
    ["fac"] = 'H',
    ["meta"] = {
      ["stablemaster"] = 'H',
    },
    ["coords"] = {
      {24.4, 12.8, 406},
    },
  }
end

if not MTH_DS_Vendors[80855] then
  MTH_DS_Vendors[80855] = {
    ["name"] = 'Clover Spinpistol',
    ["lvl"] = '8',
    ["fac"] = 'A',
    ["meta"] = {
      ["huntertrainer"] = 'A',
    },
    ["coords"] = {
      {46.7, 54, 1},
    },
  }
end

if not MTH_DS_Vendors[80856] then
  MTH_DS_Vendors[80856] = {
    ["name"] = 'Twinkie Boomstick',
    ["lvl"] = '8',
    ["fac"] = 'AH',
    ["meta"] = {
      ["huntertrainer"] = 'AH',
    },
    ["coords"] = {
      {42.4, 72.9, 15},
    },
  }
end

if not MTH_DS_Vendors[80903] then
  MTH_DS_Vendors[80903] = {
    ["name"] = 'Viz Fizbeast',
    ["lvl"] = '16',
    ["fac"] = 'AH',
    ["meta"] = {
      ["huntertrainer"] = 'AH',
    },
    ["coords"] = {
    },
  }
end

if not MTH_DS_Vendors[81050] then
  MTH_DS_Vendors[81050] = {
    ["name"] = 'Dark Ranger Lanissa',
    ["lvl"] = '24',
    ["fac"] = 'H',
    ["meta"] = {
      ["huntertrainer"] = 'H',
    },
    ["coords"] = {
      {60.7, 53.5, 85},
    },
  }
end

