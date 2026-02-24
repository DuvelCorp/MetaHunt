-- MetaHunt Beast Extras (generated from pfQuest + pfQuest-turtle)
-- Adds beast NPC IDs missing from base mth-beasts using known beast-name dictionaries
if not MTH_DS then MTH_DS = {} end
if not MTH_DS_Beasts then MTH_DS_Beasts = {} end

if not MTH_DS_Beasts[521] then
  MTH_DS_Beasts[521] = {
    ["name"] = "Lupos",
    ["family"] = "Unknown",
    ["lvl"] = "23",
    ["fac"] = "Unknown",
    ["abilities"] = "None",
    ["attackSpeed"] = "2.0",
    ["respawnMinSeconds"] = 14400,
    ["respawnMaxSeconds"] = 14400,
    ["respawnSamples"] = 6,
    ["coords"] = {
      {14.9, 29, 10},
      {32.6, 25.8, 10},
      {64.3, 24, 10},
    },
  }
end

if not MTH_DS_Beasts[728] then
  MTH_DS_Beasts[728] = {
    ["name"] = "Bhag'Thera",
    ["family"] = "Cats",
    ["lvl"] = "40",
    ["fac"] = "Unknown",
    ["abilities"] = "Dash 2",
    ["attackSpeed"] = "1.5",
    ["elite"] = true,
    ["respawnMinSeconds"] = 240,
    ["respawnMaxSeconds"] = 600,
    ["respawnSamples"] = 2,
    ["coords"] = {
      {49.6, 24, 33},
    },
  }
end

if not MTH_DS_Beasts[729] then
  MTH_DS_Beasts[729] = {
    ["name"] = "Sin'Dall",
    ["family"] = "Cats",
    ["lvl"] = "37",
    ["fac"] = "Unknown",
    ["abilities"] = "Dash 1",
    ["attackSpeed"] = "1.3",
    ["respawnMinSeconds"] = 300,
    ["respawnMaxSeconds"] = 300,
    ["respawnSamples"] = 1,
    ["coords"] = {
      {32.2, 17.4, 33},
    },
  }
end

if not MTH_DS_Beasts[1199] then
  MTH_DS_Beasts[1199] = {
    ["name"] = "Juvenile Snow Leopard",
    ["family"] = "Unknown",
    ["lvl"] = "5-6",
    ["fac"] = "Unknown",
    ["abilities"] = "None",
    ["attackSpeed"] = "2.0",
    ["respawnMinSeconds"] = 270,
    ["respawnMaxSeconds"] = 270,
    ["respawnSamples"] = 30,
    ["coords"] = {
      {40.5, 62, 1},
      {38.8, 61, 1},
      {38.3, 60.9, 1},
      {38.6, 60.7, 1},
      {35.5, 60.6, 1},
      {36.7, 60.5, 1},
      {43.3, 60.3, 1},
      {39.8, 60.1, 1},
      {41.5, 60.1, 1},
      {43.6, 59.7, 1},
      {40.2, 58.9, 1},
      {45.4, 58.7, 1},
      {45.3, 58.5, 1},
      {42.4, 57.9, 1},
      {43, 56.5, 1},
    },
  }
end

if not MTH_DS_Beasts[1225] then
  MTH_DS_Beasts[1225] = {
    ["name"] = "Ol' Sooty",
    ["family"] = "Bears",
    ["lvl"] = "20",
    ["fac"] = "Unknown",
    ["abilities"] = "Claw 3",
    ["attackSpeed"] = "2.0",
    ["elite"] = true,
    ["respawnMinSeconds"] = 120,
    ["respawnMaxSeconds"] = 300,
    ["respawnSamples"] = 3,
    ["coords"] = {
      {42.5, 64.7, 38},
      {20.3, 77.4, 5602},
    },
  }
end

if not MTH_DS_Beasts[1516] then
  MTH_DS_Beasts[1516] = {
    ["name"] = "Konda",
    ["family"] = "Gorillas",
    ["lvl"] = "43",
    ["fac"] = "Unknown",
    ["abilities"] = "None",
    ["attackSpeed"] = "2.0",
    ["unique"] = true,
    ["coords"] = {
      {36.3, 63.9, 33},
    },
  }
end

if not MTH_DS_Beasts[2275] then
  MTH_DS_Beasts[2275] = {
    ["name"] = "Enraged Stanley",
    ["family"] = "Wolves",
    ["lvl"] = "24",
    ["fac"] = "Unknown",
    ["abilities"] = "None",
    ["attackSpeed"] = "1.3",
    ["unique"] = true,
    ["coords"] = {
    },
  }
end

if not MTH_DS_Beasts[2321] then
  MTH_DS_Beasts[2321] = {
    ["name"] = "Foreststrider Fledgling",
    ["family"] = "Tallstriders",
    ["lvl"] = "11-13",
    ["fac"] = "Unknown",
    ["abilities"] = "Cower 1, Strider Presence",
    ["attackSpeed"] = "2.0",
    ["respawnMinSeconds"] = 413,
    ["respawnMaxSeconds"] = 413,
    ["respawnSamples"] = 196,
    ["coords"] = {
      {34.8, 87.3, 148},
      {43.8, 70.7, 148},
      {43.1, 70.5, 148},
      {42.2, 70.1, 148},
      {44.3, 68.9, 148},
      {39, 68.8, 148},
      {41.4, 68.6, 148},
      {42.3, 68.5, 148},
      {38.4, 68.1, 148},
      {43.2, 68.1, 148},
      {41.7, 67.5, 148},
      {42.8, 67.3, 148},
      {43.9, 67.3, 148},
      {39.9, 67.1, 148},
      {38.8, 67, 148},
      {43.3, 66.1, 148},
      {41.6, 65.8, 148},
      {39.3, 65.6, 148},
      {42, 65.5, 148},
      {38.5, 65.4, 148},
      {38.5, 64.7, 148},
      {38.1, 63.9, 148},
      {38.2, 62.6, 148},
      {39.5, 62.5, 148},
      {39.1, 60.7, 148},
      {39.6, 59.7, 148},
      {38.2, 59.4, 148},
      {38.5, 58.2, 148},
      {45.2, 58, 148},
      {39.8, 57.4, 148},
      {38.2, 56.6, 148},
      {44.3, 55.8, 148},
      {42.9, 55.3, 148},
      {43.6, 55.1, 148},
      {45.7, 54.8, 148},
      {43.4, 53.5, 148},
      {46.1, 53, 148},
      {39, 48.7, 148},
      {38.2, 47.5, 148},
      {42.4, 47.5, 148},
      {41.9, 46, 148},
      {47.2, 44.8, 148},
      {43.3, 44.5, 148},
      {44.6, 44.3, 148},
      {43.9, 43.2, 148},
      {41.1, 43.2, 148},
      {45.6, 42.9, 148},
      {42.8, 42.6, 148},
      {47.2, 42.6, 148},
      {44.7, 42.6, 148},
      {41.3, 41.5, 148},
      {44.4, 41.4, 148},
      {47.3, 41.3, 148},
      {40.3, 41.3, 148},
      {45.4, 41.1, 148},
      {47.9, 41.1, 148},
      {43.4, 40.7, 148},
      {47.6, 40.1, 148},
      {40.1, 39.8, 148},
      {42.6, 39.7, 148},
      {39.3, 38.5, 148},
      {40.5, 38.4, 148},
      {40.5, 36.7, 148},
      {39.7, 36.6, 148},
      {38.8, 36.4, 148},
      {42.4, 35.1, 148},
      {40.4, 35, 148},
      {39.3, 34.8, 148},
      {41.5, 34.7, 148},
      {39.6, 33.9, 148},
      {41.9, 33.7, 148},
      {38.5, 33.5, 148},
      {42.8, 33.5, 148},
      {43.8, 33.4, 148},
      {44.6, 33.4, 148},
      {45.4, 32.2, 148},
      {44, 31.6, 148},
      {44.5, 29.9, 148},
      {43.9, 29.3, 148},
      {44.5, 28.8, 148},
      {43.7, 28.1, 148},
      {45.4, 27.4, 148},
      {42.8, 26.4, 148},
      {44.2, 26.3, 148},
      {46.8, 25.8, 148},
      {43.7, 25.8, 148},
      {44.6, 25.7, 148},
      {45.8, 24.9, 148},
      {44.6, 24.5, 148},
      {46.9, 24.5, 148},
      {47.9, 23.6, 148},
      {45.6, 23.4, 148},
      {44.2, 23.4, 148},
      {45.4, 22.9, 148},
      {48.9, 22.8, 148},
      {47.1, 22.5, 148},
      {45.9, 22.2, 148},
      {29.5, 31.1, 361},
    },
  }
end

if not MTH_DS_Beasts[2560] then
  MTH_DS_Beasts[2560] = {
    ["name"] = "Highland Thrasher",
    ["family"] = "Raptors",
    ["lvl"] = "33-34",
    ["fac"] = "Unknown",
    ["abilities"] = "Savage Rend 3",
    ["attackSpeed"] = "2.0",
    ["respawnMinSeconds"] = 300,
    ["respawnMaxSeconds"] = 400,
    ["respawnSamples"] = 131,
    ["coords"] = {
      {41, 69.9, 45},
      {39.5, 69.9, 45},
      {38.7, 69.1, 45},
      {39.7, 68.9, 45},
      {56, 68.8, 45},
      {37.4, 67.9, 45},
      {58.8, 67.3, 45},
      {38.4, 67.2, 45},
      {40.1, 67.1, 45},
      {36.9, 66.6, 45},
      {39.5, 65.9, 45},
      {35.4, 65.8, 45},
      {62.4, 65.3, 45},
      {31.3, 65.2, 45},
      {36.2, 65.1, 45},
      {39.2, 65, 45},
      {37.4, 64.9, 45},
      {41, 64.8, 45},
      {34.9, 64.3, 45},
      {36.5, 64, 45},
      {32.4, 64, 45},
      {34.1, 61.8, 45},
      {32.1, 60.3, 45},
      {54.5, 59.6, 45},
      {32.1, 59, 45},
      {19.8, 58, 45},
      {31.1, 57.6, 45},
      {54.1, 57.6, 45},
      {32.5, 56.9, 45},
      {32.6, 56.6, 45},
      {30.5, 56.4, 45},
      {30.1, 56.1, 45},
      {31.4, 55.9, 45},
      {21.9, 53.6, 45},
      {23.2, 49.7, 45},
      {19.1, 48.7, 45},
      {20.1, 48.2, 45},
      {20.8, 47.7, 45},
      {22, 47.7, 45},
      {18, 47.2, 45},
      {18.5, 46.3, 45},
      {20.1, 45, 45},
      {40.2, 41.1, 45},
      {41.7, 39.6, 45},
      {38.1, 38.7, 45},
      {43.9, 38.4, 45},
      {39.4, 38.4, 45},
      {37, 38.2, 45},
      {37.9, 36.9, 45},
      {40.2, 36.8, 45},
      {36.5, 36.7, 45},
      {43, 36.4, 45},
      {40.2, 35.3, 45},
      {41.2, 35.3, 45},
      {36.7, 35.2, 45},
      {46.5, 35.1, 45},
      {39.9, 34.2, 45},
      {43.9, 34, 45},
      {38, 33.5, 45},
      {37.8, 33.3, 45},
      {36.3, 33.1, 45},
      {41, 30, 45},
      {37.1, 29.9, 45},
      {39.9, 29.9, 45},
    },
  }
end

if not MTH_DS_Beasts[2563] then
  MTH_DS_Beasts[2563] = {
    ["name"] = "Plains Creeper",
    ["family"] = "Spiders",
    ["lvl"] = "32-33",
    ["fac"] = "Unknown",
    ["abilities"] = "Bite 5, Web",
    ["attackSpeed"] = "2.0",
    ["respawnMinSeconds"] = 300,
    ["respawnMaxSeconds"] = 400,
    ["respawnSamples"] = 229,
    ["coords"] = {
      {42, 75.6, 45},
      {42, 72.7, 45},
      {39.7, 70.9, 45},
      {44.2, 70.5, 45},
      {40.8, 67.8, 45},
      {45.3, 67.4, 45},
      {34.9, 66.2, 45},
      {34, 64.9, 45},
      {45.1, 64.8, 45},
      {43.1, 64.5, 45},
      {45.7, 64.5, 45},
      {38.6, 62.9, 45},
      {43.5, 62.7, 45},
      {41.1, 62.5, 45},
      {41.7, 61.7, 45},
      {42.6, 61.5, 45},
      {50.2, 61.5, 45},
      {47.9, 61.2, 45},
      {32.7, 60.9, 45},
      {48.1, 60.6, 45},
      {42, 59.8, 45},
      {43, 59, 45},
      {41.2, 58.8, 45},
      {47.9, 57.6, 45},
      {43.1, 57.4, 45},
      {69, 56.3, 45},
      {69.8, 56.2, 45},
      {68.1, 56, 45},
      {69.7, 55.1, 45},
      {22.4, 54.6, 45},
      {32.8, 54.4, 45},
      {71.1, 54.3, 45},
      {68, 53.1, 45},
      {67, 52.6, 45},
      {18.1, 52.3, 45},
      {22.7, 52, 45},
      {40, 51.9, 45},
      {48.7, 50.8, 45},
      {18.1, 50.7, 45},
      {58.7, 50.7, 45},
      {65.6, 50.7, 45},
      {69, 50.6, 45},
      {61.6, 50.6, 45},
      {61.4, 50.6, 45},
      {19.9, 50.5, 45},
      {71.8, 50.5, 45},
      {69.9, 50.2, 45},
      {17.3, 49.8, 45},
      {59.8, 49.7, 45},
      {21.6, 49.6, 45},
      {69.9, 49.3, 45},
      {66.6, 49.3, 45},
      {61.6, 49.2, 45},
      {41.4, 48.7, 45},
      {71.8, 48.5, 45},
      {70, 48.3, 45},
      {23.8, 48.3, 45},
      {69, 47.9, 45},
      {73, 47.2, 45},
      {71.1, 47, 45},
      {73.7, 46.9, 45},
      {70.5, 46.7, 45},
      {60.6, 46.6, 45},
      {68.4, 46.5, 45},
      {39.4, 45.4, 45},
      {56, 45.4, 45},
      {17.2, 45.3, 45},
      {22.6, 45.2, 45},
      {57.8, 45.2, 45},
      {18.1, 44.7, 45},
      {16.9, 43.7, 45},
      {64.2, 43.7, 45},
      {19.4, 43.6, 45},
      {62.2, 42.6, 45},
      {17.2, 42.3, 45},
      {20.8, 42.2, 45},
      {50.6, 41.8, 45},
      {20, 41, 45},
      {45.8, 40.9, 45},
      {60.8, 39.7, 45},
      {44.7, 39.2, 45},
      {63.4, 38.3, 45},
      {23.6, 38.2, 45},
      {41.2, 38.2, 45},
      {48.3, 38, 45},
      {50.6, 38, 45},
      {26.4, 38, 45},
      {42.1, 37.2, 45},
      {69.9, 37.1, 45},
      {49.5, 36.7, 45},
      {51.2, 36.6, 45},
      {47.6, 36.4, 45},
      {20.7, 36.3, 45},
      {19.4, 35.9, 45},
      {49.9, 35.6, 45},
      {52.3, 35.5, 45},
      {18.2, 35.5, 45},
      {39.1, 35.4, 45},
      {68.9, 35.4, 45},
      {47.9, 35, 45},
      {29.1, 34.6, 45},
      {36.1, 33.9, 45},
      {57.9, 33.9, 45},
      {69.1, 33.8, 45},
      {55.3, 33.7, 45},
      {53.3, 33.3, 45},
      {56.4, 33.2, 45},
      {54.3, 32.5, 45},
      {37.7, 31.1, 45},
      {62.8, 30.1, 45},
      {26.6, 25.7, 45},
      {28.3, 20.9, 45},
      {80.7, 83.8, 267},
      {79.9, 81, 267},
    },
  }
end

if not MTH_DS_Beasts[2578] then
  MTH_DS_Beasts[2578] = {
    ["name"] = "Young Mesa Buzzard",
    ["family"] = "Carrion Birds",
    ["lvl"] = "31-32",
    ["fac"] = "Unknown",
    ["abilities"] = "Dive 1",
    ["attackSpeed"] = "2.0",
    ["respawnMinSeconds"] = 400,
    ["respawnMaxSeconds"] = 400,
    ["respawnSamples"] = 36,
    ["coords"] = {
      {43.4, 61.2, 45},
      {42.4, 56.6, 45},
      {68.4, 53.2, 45},
      {69.3, 52.4, 45},
      {68.8, 49.6, 45},
      {20.2, 47, 45},
      {73.9, 46.6, 45},
      {54.1, 46.2, 45},
      {17.9, 43.6, 45},
      {60, 41.5, 45},
      {66.5, 40.8, 45},
      {27.1, 38, 45},
      {19.8, 37.4, 45},
      {69.3, 37.2, 45},
      {25.3, 35.1, 45},
      {28.1, 34.4, 45},
      {26.7, 24.8, 45},
      {29.1, 19.8, 45},
    },
  }
end

if not MTH_DS_Beasts[2931] then
  MTH_DS_Beasts[2931] = {
    ["name"] = "Zaricotl",
    ["family"] = "Carrion Birds",
    ["lvl"] = "55",
    ["fac"] = "Unknown",
    ["abilities"] = "Dive 3",
    ["attackSpeed"] = "2.0",
    ["rare"] = true,
    ["elite"] = true,
    ["respawnMinSeconds"] = 18000,
    ["respawnMaxSeconds"] = 38000,
    ["respawnSamples"] = 2,
    ["coords"] = {
      {56.1, 61.7, 3},
    },
  }
end

if not MTH_DS_Beasts[3257] then
  MTH_DS_Beasts[3257] = {
    ["name"] = "Ishamuhale",
    ["family"] = "Raptors",
    ["lvl"] = "19",
    ["fac"] = "Unknown",
    ["abilities"] = "Savage Rend 2",
    ["attackSpeed"] = "2.0",
    ["unique"] = true,
    ["coords"] = {
      {59.7, 30.3, 17},
    },
  }
end

if not MTH_DS_Beasts[3475] then
  MTH_DS_Beasts[3475] = {
    ["name"] = "Echeyakee",
    ["family"] = "Cats",
    ["lvl"] = "16",
    ["fac"] = "Unknown",
    ["abilities"] = "None",
    ["attackSpeed"] = "2.0",
    ["unique"] = true,
    ["coords"] = {
      {56.1, 17.4, 17},
    },
  }
end

if not MTH_DS_Beasts[3503] then
  MTH_DS_Beasts[3503] = {
    ["name"] = "Silithid Protector",
    ["family"] = "Crabs",
    ["lvl"] = "18-19",
    ["fac"] = "Unknown",
    ["abilities"] = "None",
    ["attackSpeed"] = "2.0",
    ["unique"] = true,
    ["respawnMinSeconds"] = 413,
    ["respawnMaxSeconds"] = 413,
    ["respawnSamples"] = 1,
    ["coords"] = {
      {45.5, 72.5, 17},
    },
  }
end

if not MTH_DS_Beasts[3619] then
  MTH_DS_Beasts[3619] = {
    ["name"] = "Ghost Saber",
    ["family"] = "Cats",
    ["lvl"] = "19-20",
    ["fac"] = "Unknown",
    ["abilities"] = "Claw 3",
    ["attackSpeed"] = "2.0",
    ["unique"] = true,
    ["coords"] = {
    },
  }
end

if not MTH_DS_Beasts[3812] then
  MTH_DS_Beasts[3812] = {
    ["name"] = "Clattering Crawler",
    ["family"] = "Crabs",
    ["lvl"] = "19-20",
    ["fac"] = "Unknown",
    ["abilities"] = "Claw 3",
    ["attackSpeed"] = "2.0",
    ["respawnMinSeconds"] = 300,
    ["respawnMaxSeconds"] = 300,
    ["respawnSamples"] = 43,
    ["coords"] = {
      {26.9, 99.3, 148},
      {26.3, 98.8, 148},
      {26.9, 98, 148},
      {30, 97.9, 148},
      {28.4, 97.5, 148},
      {27, 96.7, 148},
      {27.9, 96.6, 148},
      {30, 96.6, 148},
      {29.5, 96, 148},
      {27.4, 95.9, 148},
      {24.9, 95.3, 148},
      {10, 35.4, 331},
      {10.1, 33.4, 331},
      {11.8, 32.7, 331},
      {10.6, 32.1, 331},
      {8.8, 31.1, 331},
      {12.9, 30.7, 331},
      {12.6, 30.3, 331},
      {10, 29.7, 331},
      {14, 29.4, 331},
      {11.8, 29.1, 331},
      {11.1, 28.6, 331},
      {13.5, 28.5, 331},
      {12.4, 28.4, 331},
      {15.4, 27.4, 331},
      {12, 27.3, 331},
      {12.9, 26.6, 331},
      {12.4, 22.9, 331},
      {12.9, 22.2, 331},
      {14.6, 21.4, 331},
      {13.5, 21.1, 331},
      {12.7, 18.8, 331},
      {9, 17.6, 331},
      {8.4, 17, 331},
      {9, 16.1, 331},
      {12.6, 16, 331},
      {10.8, 15.5, 331},
      {9.1, 14.6, 331},
      {10.2, 14.6, 331},
      {12.5, 14.5, 331},
      {11.9, 13.8, 331},
      {9.5, 13.7, 331},
      {6.7, 13, 331},
    },
  }
end

if not MTH_DS_Beasts[4118] then
  MTH_DS_Beasts[4118] = {
    ["name"] = "Venomous Cloud Serpent",
    ["family"] = "Unknown",
    ["lvl"] = "26-28",
    ["fac"] = "Unknown",
    ["abilities"] = "None",
    ["attackSpeed"] = "2.0",
    ["respawnMinSeconds"] = 300,
    ["respawnMaxSeconds"] = 300,
    ["respawnSamples"] = 15,
    ["coords"] = {
      {42.9, 94.8, 17},
      {41.6, 93.7, 17},
      {40, 92.9, 17},
      {51.2, 56.3, 400},
      {36.7, 55.3, 400},
      {52.6, 55.1, 400},
      {34.9, 54.4, 400},
      {37.8, 54, 400},
      {37.5, 53.8, 400},
      {33.2, 52.9, 400},
      {28, 42.2, 400},
      {21.3, 38.1, 400},
      {29.3, 28.1, 400},
      {26.4, 25.6, 400},
      {22.7, 23.7, 400},
    },
  }
end

if not MTH_DS_Beasts[4250] then
  MTH_DS_Beasts[4250] = {
    ["name"] = "Galak Packhound",
    ["family"] = "Hyenas",
    ["lvl"] = "24",
    ["fac"] = "Unknown",
    ["abilities"] = "None",
    ["attackSpeed"] = "1.5",
    ["respawnMinSeconds"] = 18000,
    ["respawnMaxSeconds"] = 18000,
    ["respawnSamples"] = 1,
    ["coords"] = {
      {25.1, 37.2, 400},
    },
  }
end

if not MTH_DS_Beasts[4425] then
  MTH_DS_Beasts[4425] = {
    ["name"] = "Blind Hunter",
    ["family"] = "Bats",
    ["lvl"] = "32",
    ["fac"] = "Unknown",
    ["abilities"] = "None",
    ["attackSpeed"] = "2.0",
    ["rare"] = true,
    ["elite"] = true,
    ["respawnMinSeconds"] = 604800,
    ["respawnMaxSeconds"] = 604800,
    ["respawnSamples"] = 1,
    ["coords"] = {
      {11, 30.3, 491},
    },
  }
end

if not MTH_DS_Beasts[4511] then
  MTH_DS_Beasts[4511] = {
    ["name"] = "Agam'ar",
    ["family"] = "Boars",
    ["lvl"] = "24-25",
    ["fac"] = "Unknown",
    ["abilities"] = "Charge 3",
    ["attackSpeed"] = "2.0",
    ["elite"] = true,
    ["respawnMinSeconds"] = 18000,
    ["respawnMaxSeconds"] = 18000,
    ["respawnSamples"] = 15,
    ["coords"] = {
      {39.9, 61.7, 491},
      {60, 59.1, 491},
      {48.5, 58.6, 491},
      {57.8, 57.8, 491},
      {27, 52.7, 491},
      {34.9, 49.2, 491},
      {53.4, 47.7, 491},
      {28.2, 47.3, 491},
      {35.8, 46.3, 491},
      {43.5, 46.2, 491},
      {35, 43.2, 491},
      {42.7, 43, 491},
      {50.7, 40.8, 491},
      {50.6, 37.4, 491},
      {48.5, 37.2, 491},
    },
  }
end

if not MTH_DS_Beasts[4512] then
  MTH_DS_Beasts[4512] = {
    ["name"] = "Rotting Agam'ar",
    ["family"] = "Boars",
    ["lvl"] = "28",
    ["fac"] = "Unknown",
    ["abilities"] = "Charge 3",
    ["attackSpeed"] = "2.0",
    ["elite"] = true,
    ["respawnMinSeconds"] = 18000,
    ["respawnMaxSeconds"] = 18000,
    ["respawnSamples"] = 3,
    ["coords"] = {
      {28.6, 57.6, 491},
      {54.1, 57.3, 491},
      {48.5, 57.1, 491},
    },
  }
end

if not MTH_DS_Beasts[4514] then
  MTH_DS_Beasts[4514] = {
    ["name"] = "Raging Agam'ar",
    ["family"] = "Boars",
    ["lvl"] = "25-26",
    ["fac"] = "Unknown",
    ["abilities"] = "Charge 3",
    ["attackSpeed"] = "2.0",
    ["elite"] = true,
    ["respawnMinSeconds"] = 18000,
    ["respawnMaxSeconds"] = 18000,
    ["respawnSamples"] = 15,
    ["coords"] = {
      {44.9, 64.6, 491},
      {40.4, 64.2, 491},
      {26.8, 63.6, 491},
      {28.1, 63.3, 491},
      {47.4, 62.2, 491},
      {67.2, 61.9, 491},
      {60.4, 57.7, 491},
      {62.4, 57.5, 491},
      {28.3, 56.8, 491},
      {37.3, 54.9, 491},
      {52.2, 54.8, 491},
      {37.2, 48.4, 491},
      {28.6, 43.4, 491},
      {52.3, 40.7, 491},
      {45.7, 40.1, 491},
    },
  }
end

if not MTH_DS_Beasts[4660] then
  MTH_DS_Beasts[4660] = {
    ["name"] = "Maraudine Bonepaw",
    ["family"] = "Hyenas",
    ["lvl"] = "37-38",
    ["fac"] = "Unknown",
    ["abilities"] = "None",
    ["attackSpeed"] = "2.0",
    ["unique"] = true,
    ["coords"] = {
    },
  }
end

if not MTH_DS_Beasts[4693] then
  MTH_DS_Beasts[4693] = {
    ["name"] = "Dread Flyer",
    ["family"] = "Carrion Birds",
    ["lvl"] = "36-37",
    ["fac"] = "Unknown",
    ["abilities"] = "Dive 1",
    ["attackSpeed"] = "2.0",
    ["respawnMinSeconds"] = 300,
    ["respawnMaxSeconds"] = 300,
    ["respawnSamples"] = 100,
    ["coords"] = {
      {63.4, 60.4, 405},
      {44.1, 59.2, 405},
      {61.9, 58.9, 405},
      {63.1, 57.3, 405},
      {42.4, 56.9, 405},
      {60.5, 56.4, 405},
      {44.1, 55.9, 405},
      {62.6, 55.1, 405},
      {44.1, 54.5, 405},
      {61.3, 54.4, 405},
      {42.3, 53.6, 405},
      {57.9, 53.1, 405},
      {43.9, 52.4, 405},
      {62.7, 52, 405},
      {60.1, 51.3, 405},
      {61.1, 51.2, 405},
      {57.5, 51.1, 405},
      {40.2, 51, 405},
      {58.5, 50.9, 405},
      {41.7, 50.3, 405},
      {58.2, 50.2, 405},
      {59.7, 49.6, 405},
      {53.6, 49.3, 405},
      {55.4, 49.1, 405},
      {62.8, 48.5, 405},
      {41.7, 48.5, 405},
      {58.9, 48.2, 405},
      {45.4, 48.1, 405},
      {61, 47.9, 405},
      {42.8, 47.7, 405},
      {58.4, 47.3, 405},
      {63.9, 47, 405},
      {45, 46.9, 405},
      {43.5, 46.8, 405},
      {55.4, 46.6, 405},
      {41.7, 45.8, 405},
      {64, 45.6, 405},
      {59.7, 45.6, 405},
      {51.3, 45.2, 405},
      {42.2, 44.7, 405},
      {61.9, 44.6, 405},
      {40.5, 43.2, 405},
      {41.9, 42, 405},
      {42.8, 40.9, 405},
      {39.2, 39.2, 405},
      {41.3, 38.9, 405},
      {35.8, 38.8, 405},
      {40.5, 37.4, 405},
      {73.8, 11.2, 405},
      {50.4, 82.9, 406},
    },
  }
end

if not MTH_DS_Beasts[4824] then
  MTH_DS_Beasts[4824] = {
    ["name"] = "Aku'mai Fisher",
    ["family"] = "Turtles",
    ["lvl"] = "23-24",
    ["fac"] = "Unknown",
    ["abilities"] = "Bite 3, Shell Shield 1",
    ["attackSpeed"] = "2.0",
    ["elite"] = true,
    ["respawnMinSeconds"] = 18000,
    ["respawnMaxSeconds"] = 18000,
    ["respawnSamples"] = 6,
    ["coords"] = {
      {23.3, 44.9, 719},
      {21.4, 44.1, 719},
      {20.3, 41.9, 719},
      {24.3, 41.7, 719},
      {20.6, 38.3, 719},
      {23, 38, 719},
    },
  }
end

if not MTH_DS_Beasts[4825] then
  MTH_DS_Beasts[4825] = {
    ["name"] = "Aku'mai Snapjaw",
    ["family"] = "Turtles",
    ["lvl"] = "26-27",
    ["fac"] = "Unknown",
    ["abilities"] = "Bite 4, Shell Shield 1",
    ["attackSpeed"] = "2.0",
    ["elite"] = true,
    ["respawnMinSeconds"] = 18000,
    ["respawnMaxSeconds"] = 18000,
    ["respawnSamples"] = 7,
    ["coords"] = {
      {73.1, 92.3, 719},
      {68.9, 90.9, 719},
      {57.7, 89.5, 719},
      {60.4, 89.4, 719},
      {72.2, 88.4, 719},
      {60.3, 85.5, 719},
      {57.3, 85.3, 719},
    },
  }
end

if not MTH_DS_Beasts[5224] then
  MTH_DS_Beasts[5224] = {
    ["name"] = "Murk Slitherer",
    ["family"] = "Serpents (Cobra)",
    ["lvl"] = "45-46",
    ["fac"] = "Unknown",
    ["abilities"] = "Poison Spit 2",
    ["attackSpeed"] = "2.0",
    ["respawnMinSeconds"] = 900,
    ["respawnMaxSeconds"] = 900,
    ["respawnSamples"] = 5,
    ["coords"] = {
      {73.7, 44.8, 8},
      {75.9, 44.6, 8},
      {77, 43.2, 8},
      {73.8, 42.6, 8},
      {72, 41.9, 8},
    },
  }
end

if not MTH_DS_Beasts[5260] then
  MTH_DS_Beasts[5260] = {
    ["name"] = "Groddoc Ape",
    ["family"] = "Gorillas",
    ["lvl"] = "42-43",
    ["fac"] = "Unknown",
    ["abilities"] = "None",
    ["attackSpeed"] = "2.0",
    ["respawnMinSeconds"] = 300,
    ["respawnMaxSeconds"] = 300,
    ["respawnSamples"] = 26,
    ["coords"] = {
      {61.7, 64.4, 357},
      {61.7, 64, 357},
      {58.8, 61.6, 357},
      {61.2, 61.4, 357},
      {60.6, 61.2, 357},
      {60.8, 60.8, 357},
      {57.4, 60.7, 357},
      {59.6, 60.5, 357},
      {58.9, 60.3, 357},
      {57.8, 60.3, 357},
      {59.8, 60.1, 357},
      {56.5, 60.1, 357},
      {58.6, 58.7, 357},
      {58.4, 58.1, 357},
      {57.8, 57.9, 357},
      {58, 57.9, 357},
      {57.2, 57.2, 357},
      {58.3, 55.6, 357},
      {57.9, 55.5, 357},
      {56.3, 54.9, 357},
      {56.9, 54.5, 357},
      {57.5, 54.3, 357},
      {73.4, 53.7, 357},
      {57.4, 53.5, 357},
      {68.3, 52.1, 357},
      {74.7, 51.4, 357},
    },
  }
end

if not MTH_DS_Beasts[5432] then
  MTH_DS_Beasts[5432] = {
    ["name"] = "Giant Surf Glider",
    ["family"] = "Unknown",
    ["lvl"] = "48-50",
    ["fac"] = "Unknown",
    ["abilities"] = "None",
    ["attackSpeed"] = "2.0",
    ["respawnMinSeconds"] = 300,
    ["respawnMaxSeconds"] = 300,
    ["respawnSamples"] = 1,
    ["coords"] = {
      {60.2, 81.6, 440},
    },
  }
end

if not MTH_DS_Beasts[5842] then
  MTH_DS_Beasts[5842] = {
    ["name"] = "Takk the Leaper",
    ["family"] = "Raptors",
    ["lvl"] = "19",
    ["fac"] = "Unknown",
    ["abilities"] = "Savage Rend 2",
    ["attackSpeed"] = "2.0",
    ["rare"] = true,
    ["elite"] = true,
    ["respawnMinSeconds"] = 14400,
    ["respawnMaxSeconds"] = 54000,
    ["respawnSamples"] = 2,
    ["coords"] = {
      {59.6, 8.3, 17},
    },
  }
end

if not MTH_DS_Beasts[5984] then
  MTH_DS_Beasts[5984] = {
    ["name"] = "Starving Snickerfang",
    ["family"] = "Hyenas",
    ["lvl"] = "45-46",
    ["fac"] = "Unknown",
    ["abilities"] = "None",
    ["attackSpeed"] = "2.0",
    ["respawnMinSeconds"] = 120,
    ["respawnMaxSeconds"] = 300,
    ["respawnSamples"] = 48,
    ["coords"] = {
      {50.8, 28.1, 4},
      {43.9, 25.5, 4},
      {48.6, 24.5, 4},
      {45.5, 21.4, 4},
      {46.7, 20.9, 4},
      {47.8, 19.7, 4},
      {48.3, 17.8, 4},
      {56, 17.6, 4},
    },
  }
end

if not MTH_DS_Beasts[6513] then
  MTH_DS_Beasts[6513] = {
    ["name"] = "Un'Goro Stomper",
    ["family"] = "Gorillas",
    ["lvl"] = "51-52",
    ["fac"] = "Unknown",
    ["abilities"] = "None",
    ["attackSpeed"] = "2.0",
    ["respawnMinSeconds"] = 300,
    ["respawnMaxSeconds"] = 300,
    ["respawnSamples"] = 52,
    ["coords"] = {
      {62.6, 19.7, 490},
      {61.6, 18.1, 490},
      {63.3, 18.1, 490},
      {69, 17.6, 490},
      {66.2, 17.3, 490},
      {62.4, 17.3, 490},
      {67.4, 17.2, 490},
      {68.6, 16.9, 490},
      {63.3, 16.8, 490},
      {64.9, 16.8, 490},
      {60.4, 16.7, 490},
      {65.2, 16.6, 490},
      {67.7, 16.6, 490},
      {64.1, 16.3, 490},
      {68.1, 15.9, 490},
      {69.1, 15.8, 490},
      {65.9, 15.6, 490},
      {67.1, 15.3, 490},
      {68.8, 15.2, 490},
      {67.4, 15.1, 490},
      {65.6, 14.7, 490},
      {68.6, 14.4, 490},
      {66.4, 14.3, 490},
      {68.6, 14.2, 490},
      {67.7, 13.8, 490},
      {68.3, 13.1, 490},
    },
  }
end

if not MTH_DS_Beasts[6514] then
  MTH_DS_Beasts[6514] = {
    ["name"] = "Un'Goro Gorilla",
    ["family"] = "Gorillas",
    ["lvl"] = "50-51",
    ["fac"] = "Unknown",
    ["abilities"] = "None",
    ["attackSpeed"] = "2.0",
    ["respawnMinSeconds"] = 300,
    ["respawnMaxSeconds"] = 300,
    ["respawnSamples"] = 52,
    ["coords"] = {
      {62.6, 19.7, 490},
      {61.6, 18.1, 490},
      {63.3, 18.1, 490},
      {69, 17.6, 490},
      {66.2, 17.3, 490},
      {62.4, 17.3, 490},
      {67.4, 17.2, 490},
      {68.6, 16.9, 490},
      {63.3, 16.8, 490},
      {64.9, 16.8, 490},
      {60.4, 16.7, 490},
      {65.2, 16.6, 490},
      {67.7, 16.6, 490},
      {64.1, 16.3, 490},
      {68.1, 15.9, 490},
      {69.1, 15.8, 490},
      {65.9, 15.6, 490},
      {67.1, 15.3, 490},
      {68.8, 15.2, 490},
      {67.4, 15.1, 490},
      {65.6, 14.7, 490},
      {68.6, 14.4, 490},
      {66.4, 14.3, 490},
      {68.6, 14.2, 490},
      {67.7, 13.8, 490},
      {68.3, 13.1, 490},
    },
  }
end

if not MTH_DS_Beasts[6516] then
  MTH_DS_Beasts[6516] = {
    ["name"] = "Un'Goro Thunderer",
    ["family"] = "Gorillas",
    ["lvl"] = "52-53",
    ["fac"] = "Unknown",
    ["abilities"] = "Thunderstomp 3",
    ["attackSpeed"] = "2.0",
    ["respawnMinSeconds"] = 300,
    ["respawnMaxSeconds"] = 300,
    ["respawnSamples"] = 40,
    ["coords"] = {
      {69, 17.6, 490},
      {66.2, 17.3, 490},
      {67.4, 17.2, 490},
      {68.6, 16.9, 490},
      {64.9, 16.8, 490},
      {65.2, 16.6, 490},
      {67.7, 16.6, 490},
      {64.1, 16.3, 490},
      {68.1, 15.9, 490},
      {69.1, 15.8, 490},
      {65.9, 15.6, 490},
      {67.1, 15.3, 490},
      {68.8, 15.2, 490},
      {67.4, 15.1, 490},
      {65.6, 14.7, 490},
      {68.6, 14.4, 490},
      {66.4, 14.3, 490},
      {68.6, 14.2, 490},
      {67.7, 13.8, 490},
      {68.3, 13.1, 490},
    },
  }
end

if not MTH_DS_Beasts[6585] then
  MTH_DS_Beasts[6585] = {
    ["name"] = "Uhk'loc",
    ["family"] = "Gorillas",
    ["lvl"] = "52-53",
    ["fac"] = "Unknown",
    ["abilities"] = "Bite 7",
    ["attackSpeed"] = "2.0",
    ["rare"] = true,
    ["respawnMinSeconds"] = 18000,
    ["respawnMaxSeconds"] = 27000,
    ["respawnSamples"] = 2,
    ["coords"] = {
      {68.5, 12.7, 490},
    },
  }
end

if not MTH_DS_Beasts[7455] then
  MTH_DS_Beasts[7455] = {
    ["name"] = "Winterspring Owl",
    ["family"] = "Owls",
    ["lvl"] = "54-56",
    ["fac"] = "Unknown",
    ["abilities"] = "Claw 7, Dive 3",
    ["attackSpeed"] = "2.0",
    ["respawnMinSeconds"] = 333,
    ["respawnMaxSeconds"] = 333,
    ["respawnSamples"] = 44,
    ["coords"] = {
      {66.1, 54.2, 618},
      {66.4, 51.9, 618},
      {68.3, 51.5, 618},
      {67.3, 49.5, 618},
      {63.5, 48.3, 618},
      {55.4, 47.2, 618},
      {55.5, 46.7, 618},
      {59.1, 46.2, 618},
      {62.9, 45.4, 618},
      {63.2, 43.9, 618},
      {59.3, 43.6, 618},
      {57.7, 43.4, 618},
      {60.7, 41.2, 618},
      {58.1, 40, 618},
      {57.2, 37.6, 618},
      {64.2, 36.8, 618},
      {59.2, 35.5, 618},
      {56.4, 34.6, 618},
      {57.5, 34.3, 618},
      {63.2, 34.1, 618},
      {50.9, 34, 618},
      {60.9, 33.9, 618},
      {59.4, 33.7, 618},
      {61.3, 33.2, 618},
      {62.6, 33, 618},
      {64.9, 33, 618},
      {57.1, 32.9, 618},
      {61.2, 32.9, 618},
      {50.8, 32.8, 618},
      {67.3, 32, 618},
      {63.5, 31.5, 618},
      {68.3, 31.3, 618},
      {59.1, 30.9, 618},
      {58.1, 30.1, 618},
      {58.9, 29.9, 618},
      {55.2, 29.8, 618},
      {67.2, 29.3, 618},
      {55.8, 29.3, 618},
      {64.5, 29, 618},
      {59, 28.9, 618},
      {65.1, 28.8, 618},
      {63.3, 27.5, 618},
      {63.3, 27.2, 618},
      {65.5, 27, 618},
    },
  }
end

if not MTH_DS_Beasts[7803] then
  MTH_DS_Beasts[7803] = {
    ["name"] = "Scorpid Duneburrower",
    ["family"] = "Scorpids",
    ["lvl"] = "46-47",
    ["fac"] = "Unknown",
    ["abilities"] = "Scorpid Poison 3",
    ["attackSpeed"] = "2.0",
    ["unique"] = true,
    ["coords"] = {
    },
  }
end

if not MTH_DS_Beasts[8277] then
  MTH_DS_Beasts[8277] = {
    ["name"] = "Rekk'tilac",
    ["family"] = "Spiders",
    ["lvl"] = "48",
    ["fac"] = "Unknown",
    ["abilities"] = "Bite 7",
    ["attackSpeed"] = "2.0",
    ["rare"] = true,
    ["respawnMinSeconds"] = 75600,
    ["respawnMaxSeconds"] = 108000,
    ["respawnSamples"] = 2,
    ["coords"] = {
      {61.9, 73.2, 51},
    },
  }
end

if not MTH_DS_Beasts[8926] then
  MTH_DS_Beasts[8926] = {
    ["name"] = "Deep Stinger",
    ["family"] = "Scorpids",
    ["lvl"] = "50-52",
    ["fac"] = "Unknown",
    ["abilities"] = "Scorpid Poison 3",
    ["attackSpeed"] = "2.0",
    ["coords"] = {
    },
  }
end

if not MTH_DS_Beasts[8927] then
  MTH_DS_Beasts[8927] = {
    ["name"] = "Dark Screecher",
    ["family"] = "Bats",
    ["lvl"] = "50-52",
    ["fac"] = "Unknown",
    ["abilities"] = "Dive 3, Screech 3",
    ["attackSpeed"] = "2.0",
    ["coords"] = {
    },
  }
end

if not MTH_DS_Beasts[9622] then
  MTH_DS_Beasts[9622] = {
    ["name"] = "U'cha",
    ["family"] = "Gorillas",
    ["lvl"] = "55",
    ["fac"] = "Unknown",
    ["abilities"] = "Thunderstomp 3",
    ["attackSpeed"] = "2.0",
    ["respawnMinSeconds"] = 300,
    ["respawnMaxSeconds"] = 300,
    ["respawnSamples"] = 1,
    ["coords"] = {
      {68.1, 12.6, 490},
    },
  }
end

if not MTH_DS_Beasts[9683] then
  MTH_DS_Beasts[9683] = {
    ["name"] = "Lar'Korwi Mate",
    ["family"] = "Raptors",
    ["lvl"] = "49-50",
    ["fac"] = "Unknown",
    ["abilities"] = "None",
    ["attackSpeed"] = "1.5",
    ["respawnMinSeconds"] = 25,
    ["respawnMaxSeconds"] = 25,
    ["respawnSamples"] = 1,
    ["coords"] = {
      {66.3, 63.9, 490},
    },
  }
end

if not MTH_DS_Beasts[9684] then
  MTH_DS_Beasts[9684] = {
    ["name"] = "Lar'Korwi",
    ["family"] = "Raptors",
    ["lvl"] = "56",
    ["fac"] = "Unknown",
    ["abilities"] = "Savage Rend 5",
    ["attackSpeed"] = "1.5",
    ["coords"] = {
      {31.7, 28.7, 440},
      {79.4, 49.9, 490},
    },
  }
end

if not MTH_DS_Beasts[10200] then
  MTH_DS_Beasts[10200] = {
    ["name"] = "Rak'shiri",
    ["family"] = "Cats",
    ["lvl"] = "57",
    ["fac"] = "Unknown",
    ["abilities"] = "Dash 3",
    ["attackSpeed"] = "1.5",
    ["rare"] = true,
    ["respawnMinSeconds"] = 37800,
    ["respawnMaxSeconds"] = 54000,
    ["respawnSamples"] = 2,
    ["coords"] = {
      {51.1, 10.7, 618},
    },
  }
end

if not MTH_DS_Beasts[10356] then
  MTH_DS_Beasts[10356] = {
    ["name"] = "Bayne",
    ["family"] = "Wolves",
    ["lvl"] = "10",
    ["fac"] = "Unknown",
    ["abilities"] = "None",
    ["attackSpeed"] = "2.0",
    ["rare"] = true,
    ["respawnMinSeconds"] = 3600,
    ["respawnMaxSeconds"] = 7200,
    ["respawnSamples"] = 2,
    ["coords"] = {
      {45.6, 47.5, 85},
    },
  }
end

if not MTH_DS_Beasts[10359] then
  MTH_DS_Beasts[10359] = {
    ["name"] = "Sri'skulk",
    ["family"] = "Spiders",
    ["lvl"] = "13",
    ["fac"] = "Unknown",
    ["abilities"] = "None",
    ["attackSpeed"] = "2.0",
    ["rare"] = true,
    ["respawnMinSeconds"] = 5400,
    ["respawnMaxSeconds"] = 9000,
    ["respawnSamples"] = 2,
    ["coords"] = {
      {88.2, 51.4, 85},
    },
  }
end

if not MTH_DS_Beasts[10741] then
  MTH_DS_Beasts[10741] = {
    ["name"] = "Sian-Rotam",
    ["family"] = "Cats",
    ["lvl"] = "60",
    ["fac"] = "Unknown",
    ["abilities"] = "None",
    ["attackSpeed"] = "2.0",
    ["elite"] = true,
    ["unique"] = true,
    ["coords"] = {
    },
  }
end

if not MTH_DS_Beasts[10882] then
  MTH_DS_Beasts[10882] = {
    ["name"] = "Arikara",
    ["family"] = "Wind Serpents",
    ["lvl"] = "28",
    ["fac"] = "Unknown",
    ["abilities"] = "None",
    ["attackSpeed"] = "2.0",
    ["elite"] = true,
    ["unique"] = true,
    ["coords"] = {
    },
  }
end

if not MTH_DS_Beasts[10981] then
  MTH_DS_Beasts[10981] = {
    ["name"] = "Frostwolf",
    ["family"] = "Wolves",
    ["lvl"] = "50-51",
    ["fac"] = "Unknown",
    ["abilities"] = "None",
    ["attackSpeed"] = "2.0",
    ["respawnMinSeconds"] = 430,
    ["respawnMaxSeconds"] = 430,
    ["respawnSamples"] = 37,
    ["coords"] = {
      {54.3, 85, 2597},
      {53.1, 82.6, 2597},
      {54.9, 81.2, 2597},
      {55.2, 78.5, 2597},
      {50, 77.2, 2597},
      {52, 77.1, 2597},
      {52.4, 76.1, 2597},
      {53.8, 75.5, 2597},
      {50.7, 74.1, 2597},
      {51.4, 74, 2597},
      {53.2, 72.6, 2597},
      {48.9, 70.4, 2597},
      {49.4, 68.9, 2597},
      {53, 68.8, 2597},
      {53.4, 58.3, 2597},
      {46.7, 58.2, 2597},
      {46.5, 55.5, 2597},
      {45.2, 53.5, 2597},
      {44.9, 51.9, 2597},
    },
  }
end

if not MTH_DS_Beasts[12037] then
  MTH_DS_Beasts[12037] = {
    ["name"] = "Ursol'lok",
    ["family"] = "Bears",
    ["lvl"] = "32",
    ["fac"] = "Unknown",
    ["abilities"] = "None",
    ["attackSpeed"] = "1.39",
    ["rare"] = true,
    ["respawnMinSeconds"] = 37800,
    ["respawnMaxSeconds"] = 54000,
    ["respawnSamples"] = 2,
    ["coords"] = {
      {83.4, 48.5, 331},
    },
  }
end

if not MTH_DS_Beasts[14222] then
  MTH_DS_Beasts[14222] = {
    ["name"] = "Araga",
    ["family"] = "Cats",
    ["lvl"] = "35",
    ["fac"] = "Unknown",
    ["abilities"] = "None",
    ["attackSpeed"] = "1.4",
    ["rare"] = true,
    ["respawnMinSeconds"] = 75600,
    ["respawnMaxSeconds"] = 115200,
    ["respawnSamples"] = 12,
    ["coords"] = {
      {39, 91.2, 36},
      {31, 86, 36},
      {30.2, 72.1, 36},
      {43, 28.3, 267},
      {36, 23.7, 267},
      {35.3, 11.5, 267},
    },
  }
end

if not MTH_DS_Beasts[14223] then
  MTH_DS_Beasts[14223] = {
    ["name"] = "Cranky Benj",
    ["family"] = "Turtles",
    ["lvl"] = "32",
    ["fac"] = "Unknown",
    ["abilities"] = "Bite 4, Shell Shield 1",
    ["attackSpeed"] = "2.0",
    ["rare"] = true,
    ["respawnMinSeconds"] = 115200,
    ["respawnMaxSeconds"] = 180000,
    ["respawnSamples"] = 8,
    ["coords"] = {
      {14.5, 54.1, 36},
      {20.9, 48, 36},
      {27.7, 41.2, 36},
      {36.7, 21.3, 36},
      {73.1, 42, 130},
      {77.5, 38, 130},
      {82, 33.4, 130},
    },
  }
end

if not MTH_DS_Beasts[14234] then
  MTH_DS_Beasts[14234] = {
    ["name"] = "Hayoc",
    ["family"] = "Wind Serpents",
    ["lvl"] = "41",
    ["fac"] = "Unknown",
    ["abilities"] = "None",
    ["attackSpeed"] = "2.0",
    ["rare"] = true,
    ["respawnMinSeconds"] = 38000,
    ["respawnMaxSeconds"] = 38000,
    ["respawnSamples"] = 1,
    ["coords"] = {
      {52, 62.9, 15},
    },
  }
end

if not MTH_DS_Beasts[15041] then
  MTH_DS_Beasts[15041] = {
    ["name"] = "Spawn of Mar'li",
    ["family"] = "Spiders",
    ["lvl"] = "59-60",
    ["fac"] = "Unknown",
    ["abilities"] = "None",
    ["attackSpeed"] = "1.4",
    ["coords"] = {
    },
  }
end

if not MTH_DS_Beasts[36507] then
  MTH_DS_Beasts[36507] = {
    ["name"] = "Spot",
    ["family"] = "Wolves",
    ["lvl"] = "1",
    ["fac"] = "AH",
    ["abilities"] = "Dash 1",
    ["attackSpeed"] = "2.0",
    ["coords"] = {
      {68, 46.8, 15},
    },
  }
end

if not MTH_DS_Beasts[36514] then
  MTH_DS_Beasts[36514] = {
    ["name"] = "Frostsaber Cub",
    ["family"] = "Cats",
    ["lvl"] = "1",
    ["fac"] = "AH",
    ["abilities"] = "Cower 6",
    ["attackSpeed"] = "1.5",
    ["coords"] = {
      {48.9, 19, 618},
    },
  }
end

if not MTH_DS_Beasts[37007] then
  MTH_DS_Beasts[37007] = {
    ["name"] = "Black Widow Hatchling",
    ["family"] = "Spiders",
    ["lvl"] = "1",
    ["fac"] = "AH",
    ["abilities"] = "None",
    ["attackSpeed"] = "2.0",
    ["coords"] = {
      {80.7, 62.8, 10},
    },
  }
end

if not MTH_DS_Beasts[50624] then
  MTH_DS_Beasts[50624] = {
    ["name"] = "Silithid Swarmer",
    ["family"] = "Scorpids",
    ["lvl"] = "30-43",
    ["fac"] = "Unknown",
    ["abilities"] = "Scorpid Poison 1",
    ["attackSpeed"] = "2.0",
    ["coords"] = {
      {26.5, 30.9, 15},
    },
  }
end

if not MTH_DS_Beasts[50627] then
  MTH_DS_Beasts[50627] = {
    ["name"] = "Silithid Swarmer",
    ["family"] = "Scorpids",
    ["lvl"] = "30-43",
    ["fac"] = "Unknown",
    ["abilities"] = "Scorpid Poison 1",
    ["attackSpeed"] = "2.0",
    ["coords"] = {
      {26.5, 30.9, 15},
    },
  }
end

if not MTH_DS_Beasts[50630] then
  MTH_DS_Beasts[50630] = {
    ["name"] = "Silithid Swarmer",
    ["family"] = "Scorpids",
    ["lvl"] = "30-43",
    ["fac"] = "Unknown",
    ["abilities"] = "Scorpid Poison 1",
    ["attackSpeed"] = "2.0",
    ["coords"] = {
      {26.5, 30.9, 15},
    },
  }
end

if not MTH_DS_Beasts[60697] then
  MTH_DS_Beasts[60697] = {
    ["name"] = "Soothound",
    ["family"] = "Hyenas",
    ["lvl"] = "51-52",
    ["fac"] = "Unknown",
    ["abilities"] = "None",
    ["attackSpeed"] = "2.0",
    ["untameable"] = true,
    ["respawnMinSeconds"] = 480,
    ["respawnMaxSeconds"] = 480,
    ["respawnSamples"] = 5,
    ["coords"] = {
      {94.1, 62.8, 46},
      {96.3, 58.3, 46},
      {93.7, 58.1, 46},
      {93.7, 57.2, 46},
      {97.1, 51.2, 46},
    },
  }
end

if not MTH_DS_Beasts[61096] then
  MTH_DS_Beasts[61096] = {
    ["name"] = "Venomflayer Serpent",
    ["family"] = "Wind Serpents",
    ["lvl"] = "57-58",
    ["fac"] = "Unknown",
    ["abilities"] = "TBD",
    ["attackSpeed"] = "2.0",
    ["untameable"] = true,
    ["respawnMinSeconds"] = 280,
    ["respawnMaxSeconds"] = 280,
    ["respawnSamples"] = 17,
    ["coords"] = {
      {45.2, 42.4, 5121},
      {44.5, 41.6, 5121},
      {47.3, 40.1, 5121},
      {42.6, 39.1, 5121},
      {45.5, 38, 5121},
      {44.1, 37.2, 5121},
      {46.3, 37.1, 5121},
      {43.5, 36.1, 5121},
      {47, 35.3, 5121},
      {42, 34.6, 5121},
      {45.3, 33.7, 5121},
      {41.5, 32.1, 5121},
      {47.8, 21, 5121},
      {50.2, 20.7, 5121},
      {47.6, 20.1, 5121},
      {47.3, 18.8, 5121},
      {49.4, 18.2, 5121},
    },
  }
end

if not MTH_DS_Beasts[61500] then
  MTH_DS_Beasts[61500] = {
    ["name"] = "Highvale Silverback",
    ["family"] = "Gorillas",
    ["lvl"] = "58",
    ["fac"] = "Unknown",
    ["abilities"] = "Thunderstomp 4",
    ["attackSpeed"] = "1.5",
    ["rare"] = true,
    ["respawnMinSeconds"] = 108000,
    ["respawnMaxSeconds"] = 108000,
    ["respawnSamples"] = 1,
    ["coords"] = {
      {56.7, 48.3, 5121},
    },
  }
end

if not MTH_DS_Beasts[61552] then
  MTH_DS_Beasts[61552] = {
    ["name"] = "Duskskitterer",
    ["family"] = "Spiders",
    ["lvl"] = "44",
    ["fac"] = "Unknown",
    ["abilities"] = "None",
    ["attackSpeed"] = "1.29",
    ["rare"] = true,
    ["respawnMinSeconds"] = 43200,
    ["respawnMaxSeconds"] = 43200,
    ["respawnSamples"] = 1,
    ["coords"] = {
      {45.6, 78, 5179},
    },
  }
end

if not MTH_DS_Beasts[61554] then
  MTH_DS_Beasts[61554] = {
    ["name"] = "Dawnhowl",
    ["family"] = "Wolves",
    ["lvl"] = "40",
    ["fac"] = "Unknown",
    ["abilities"] = "None",
    ["attackSpeed"] = "2.0",
    ["rare"] = true,
    ["respawnMinSeconds"] = 43200,
    ["respawnMaxSeconds"] = 43200,
    ["respawnSamples"] = 2,
    ["coords"] = {
      {47.4, 92.2, 130},
      {48.9, 22.7, 5179},
    },
  }
end

if not MTH_DS_Beasts[61699] then
  MTH_DS_Beasts[61699] = {
    ["name"] = "Shar'lan",
    ["family"] = "Cats",
    ["lvl"] = "8",
    ["fac"] = "Unknown",
    ["abilities"] = "Bite 2",
    ["attackSpeed"] = "2.0",
    ["respawnMinSeconds"] = 150,
    ["respawnMaxSeconds"] = 150,
    ["respawnSamples"] = 2,
    ["coords"] = {
      {20.6, 8.9, 139},
      {64.2, 67, 5225},
    },
  }
end

if not MTH_DS_Beasts[61975] then
  MTH_DS_Beasts[61975] = {
    ["name"] = "Hightusk Boar",
    ["family"] = "Boars",
    ["lvl"] = "33-34",
    ["fac"] = "Unknown",
    ["abilities"] = "Charge 4",
    ["attackSpeed"] = "2.0",
    ["respawnMinSeconds"] = 300,
    ["respawnMaxSeconds"] = 300,
    ["respawnSamples"] = 13,
    ["coords"] = {
      {20.8, 54.9, 45},
      {20.4, 54.8, 45},
      {19.9, 54.4, 45},
      {20.8, 54.3, 45},
      {20.9, 53.7, 45},
      {19.8, 53.5, 45},
      {19.4, 53.4, 45},
      {20.5, 53.2, 45},
      {20.9, 52.8, 45},
      {19.3, 52.7, 45},
      {19.6, 52.3, 45},
      {20.1, 52.3, 45},
      {20.8, 52.2, 45},
    },
  }
end

if not MTH_DS_Beasts[62066] then
  MTH_DS_Beasts[62066] = {
    ["name"] = "Cavernweb Broodmother",
    ["family"] = "Spider",
    ["lvl"] = "27",
    ["fac"] = "Unknown",
    ["abilities"] = "None",
    ["attackSpeed"] = "2.0",
    ["respawnMinSeconds"] = 604800,
    ["respawnMaxSeconds"] = 604800,
    ["respawnSamples"] = 1,
    ["coords"] = {
      {33.6, 44.3, 5601},
    },
  }
end

if not MTH_DS_Beasts[62073] then
  MTH_DS_Beasts[62073] = {
    ["name"] = "Cavernweb Spider",
    ["family"] = "Spider",
    ["lvl"] = "26-27",
    ["fac"] = "Unknown",
    ["abilities"] = "None",
    ["attackSpeed"] = "2.0",
    ["respawnMinSeconds"] = 604800,
    ["respawnMaxSeconds"] = 604800,
    ["respawnSamples"] = 8,
    ["coords"] = {
      {29, 60, 5601},
      {27.5, 58.8, 5601},
      {31.9, 57.4, 5601},
      {27.9, 55.1, 5601},
      {32, 53.6, 5601},
      {31.7, 51.6, 5601},
      {31.9, 50.2, 5601},
      {35.3, 47.3, 5601},
    },
  }
end

if not MTH_DS_Beasts[62074] then
  MTH_DS_Beasts[62074] = {
    ["name"] = "Cavernweb Creeper",
    ["family"] = "Spider",
    ["lvl"] = "26-27",
    ["fac"] = "Unknown",
    ["abilities"] = "Web",
    ["attackSpeed"] = "2.0",
    ["respawnMinSeconds"] = 604800,
    ["respawnMaxSeconds"] = 604800,
    ["respawnSamples"] = 6,
    ["coords"] = {
      {39.3, 64.8, 5601},
      {39.3, 64.5, 5601},
      {28.7, 57.7, 5601},
      {34, 50.9, 5601},
      {30.3, 48.6, 5601},
      {33.2, 47, 5601},
    },
  }
end

if not MTH_DS_Beasts[62075] then
  MTH_DS_Beasts[62075] = {
    ["name"] = "Cavernweb Venomspitter",
    ["family"] = "Spider",
    ["lvl"] = "27-28",
    ["fac"] = "Unknown",
    ["abilities"] = "None",
    ["attackSpeed"] = "2.0",
    ["respawnMinSeconds"] = 604800,
    ["respawnMaxSeconds"] = 604800,
    ["respawnSamples"] = 3,
    ["coords"] = {
      {30.5, 53.7, 5601},
      {30.3, 50.6, 5601},
      {36.3, 48.3, 5601},
    },
  }
end

if not MTH_DS_Beasts[62345] then
  MTH_DS_Beasts[62345] = {
    ["name"] = "Sorrowmore Crocolisk",
    ["family"] = "Crocolisks",
    ["lvl"] = "29-31",
    ["fac"] = "Unknown",
    ["abilities"] = "None",
    ["attackSpeed"] = "2.0",
    ["respawnMinSeconds"] = 300,
    ["respawnMaxSeconds"] = 300,
    ["respawnSamples"] = 45,
    ["coords"] = {
      {41.7, 65, 5561},
      {41.7, 62.9, 5561},
      {40.9, 62, 5561},
      {39.9, 59.6, 5561},
      {38.9, 57.8, 5561},
      {37.6, 57.7, 5561},
      {40.1, 57.7, 5561},
      {41, 57.2, 5561},
      {37.3, 57.1, 5561},
      {39.9, 56.9, 5561},
      {40.9, 56.6, 5561},
      {39, 56.4, 5561},
      {39.7, 56.2, 5561},
      {41.3, 56, 5561},
      {41.9, 55, 5561},
      {42, 53.6, 5561},
      {38.9, 53, 5561},
      {42.5, 52.5, 5561},
      {38.8, 52.3, 5561},
      {41.5, 51.6, 5561},
      {43, 51.3, 5561},
      {38.9, 50.9, 5561},
      {39.5, 50.8, 5561},
      {42.1, 50.6, 5561},
      {43, 50.3, 5561},
      {44, 50.2, 5561},
      {40.6, 50, 5561},
      {39.5, 49.4, 5561},
      {41.8, 49.3, 5561},
      {43, 49, 5561},
      {40.5, 48.8, 5561},
      {42.5, 48.8, 5561},
      {41.1, 48.5, 5561},
      {38.7, 48.2, 5561},
      {37.7, 48, 5561},
      {42.3, 47.9, 5561},
      {41.5, 47.8, 5561},
      {40.4, 47.1, 5561},
      {39.2, 46.8, 5561},
      {38.5, 46.8, 5561},
      {41.3, 24.9, 5561},
      {40.6, 23.7, 5561},
      {42.2, 22.7, 5561},
      {40.9, 22.5, 5561},
      {41.5, 21.8, 5561},
    },
  }
end

if not MTH_DS_Beasts[80250] then
  MTH_DS_Beasts[80250] = {
    ["name"] = "Crimson Lynx",
    ["family"] = "Cats",
    ["lvl"] = "10",
    ["fac"] = "Unknown",
    ["abilities"] = "Claw 1",
    ["attackSpeed"] = "2.0",
    ["coords"] = {
      {9.7, 16.2, 139},
    },
  }
end

if not MTH_DS_Beasts[80257] then
  MTH_DS_Beasts[80257] = {
    ["name"] = "Red Fox",
    ["family"] = "Foxes",
    ["lvl"] = "10-11",
    ["fac"] = "AH",
    ["abilities"] = "Grace 1",
    ["attackSpeed"] = "2.0",
    ["respawnMinSeconds"] = 300,
    ["respawnMaxSeconds"] = 300,
    ["respawnSamples"] = 42,
    ["coords"] = {
      {19.7, 83.7, 38},
      {22.3, 75.6, 38},
      {20.5, 71.3, 38},
      {28.6, 66.4, 38},
      {29.6, 58.5, 38},
      {42.7, 57.3, 38},
      {28.3, 56.2, 38},
      {32.7, 55.2, 38},
      {35.4, 52.9, 38},
      {41, 50.2, 38},
      {27.9, 49.9, 38},
      {30.2, 42.9, 38},
      {26.9, 41.7, 38},
      {35.4, 37.9, 38},
      {36.3, 37.5, 38},
      {33.7, 31.1, 38},
      {26.8, 31, 38},
      {38.6, 30.5, 38},
      {36, 29.4, 38},
      {32.5, 29, 38},
      {35.5, 28.1, 38},
      {8.6, 87.2, 5602},
      {10, 83, 5602},
      {9.1, 80.8, 5602},
      {13.2, 78.3, 5602},
      {13.7, 74.2, 5602},
      {20.4, 73.6, 5602},
      {13, 73, 5602},
      {15.3, 72.5, 5602},
      {16.7, 71.3, 5602},
      {19.5, 70, 5602},
      {12.8, 69.8, 5602},
      {14, 66.2, 5602},
      {12.3, 65.6, 5602},
      {16.7, 63.6, 5602},
      {17.1, 63.4, 5602},
      {15.8, 60.1, 5602},
      {12.3, 60.1, 5602},
      {18.3, 59.8, 5602},
      {17, 59.3, 5602},
      {15.2, 59.1, 5602},
      {16.7, 58.6, 5602},
    },
  }
end

if not MTH_DS_Beasts[80259] then
  MTH_DS_Beasts[80259] = {
    ["name"] = "Mist Fox",
    ["family"] = "Foxes",
    ["lvl"] = "50-51",
    ["fac"] = "Unknown",
    ["abilities"] = "Bite 7, Grace 1",
    ["attackSpeed"] = "2.0",
    ["respawnMinSeconds"] = 300,
    ["respawnMaxSeconds"] = 300,
    ["respawnSamples"] = 3,
    ["coords"] = {
      {46.5, 79, 41},
      {50, 77.8, 41},
      {52.4, 36.6, 41},
    },
  }
end

if not MTH_DS_Beasts[80260] then
  MTH_DS_Beasts[80260] = {
    ["name"] = "Spirit Fox",
    ["family"] = "Foxes",
    ["lvl"] = "53",
    ["fac"] = "Unknown",
    ["abilities"] = "Grace 1",
    ["attackSpeed"] = "1.2",
    ["rare"] = true,
    ["respawnMinSeconds"] = 172800,
    ["respawnMaxSeconds"] = 172800,
    ["respawnSamples"] = 1,
    ["coords"] = {
      {63.6, 15.8, 618},
    },
  }
end

if not MTH_DS_Beasts[80920] then
  MTH_DS_Beasts[80920] = {
    ["name"] = "Amani Eagle",
    ["family"] = "Owls",
    ["lvl"] = "1",
    ["fac"] = "AH",
    ["abilities"] = "Screech 1, Claw 2",
    ["attackSpeed"] = "2.0",
    ["coords"] = {
      {36.4, 18.3, 406},
    },
  }
end

if not MTH_DS_Beasts[90980] then
  MTH_DS_Beasts[90980] = {
    ["name"] = "Zulian Panther",
    ["family"] = "Cats",
    ["lvl"] = "1",
    ["fac"] = "AH",
    ["abilities"] = "Dash 3",
    ["attackSpeed"] = "2.0",
    ["elite"] = true,
    ["coords"] = {
      {50.3, 28.9, 1977},
    },
  }
end

if not MTH_DS_Beasts[90981] then
  MTH_DS_Beasts[90981] = {
    ["name"] = "Zulian Panther",
    ["family"] = "Cats",
    ["lvl"] = "1",
    ["fac"] = "AH",
    ["abilities"] = "Dash 3",
    ["attackSpeed"] = "2.0",
    ["elite"] = true,
    ["coords"] = {
      {50.3, 28.9, 1977},
    },
  }
end

MTH_DS_BeastsExtraMeta = {
  generated = "2026-02-15",
  baseBeasts = 627,
  knownBeastNames = 710,
  addedIDs = 80,
}
