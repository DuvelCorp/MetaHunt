-- MetaHunt Beast Families Database
-- Food map sourced from Turtle WoW Hunter Pets wiki
-- Total: 19 families

if not MTH_DS then MTH_DS = {} end

MTH_DS_Families = {
  ["Bats"] = {
    ["named"] = 20,
    ["coords"] = 18,
    ["food"] = {
      "fruit",
      "fungus",
    },
    ["abilities"] = {
      "Bite",
      "Cower",
      "Dive",
      "Growl",
      "Screech",
    },
  },
  ["Bears"] = {
    ["named"] = 45,
    ["coords"] = 45,
    ["food"] = {
      "meat",
      "fish",
      "bread",
      "cheese",
      "fruit",
      "fungus",
    },
    ["abilities"] = {
      "Bite",
      "Claw",
      "Cower",
      "Growl",
      "Roar of Fortitude",
    },
  },
  ["Boars"] = {
    ["named"] = 45,
    ["coords"] = 87,
    ["food"] = {
      "meat",
      "fish",
      "bread",
      "cheese",
      "fruit",
      "fungus",
    },
    ["abilities"] = {
      "Bite",
      "Charge",
      "Cower",
      "Dash",
      "Growl",
    },
  },
  ["Carrion Birds"] = {
    ["named"] = 36,
    ["coords"] = 101,
    ["food"] = {
      "meat",
    },
    ["abilities"] = {
      "Bite",
      "Claw",
      "Cower",
      "Dive",
      "Growl",
      "Screech",
    },
  },
  ["Cats"] = {
    ["named"] = 85,
    ["coords"] = 88,
    ["food"] = {
      "meat",
      "fish",
    },
    ["abilities"] = {
      "Bite",
      "Claw",
      "Cower",
      "Dash",
      "Growl",
      "Prowl",
    },
  },
  ["Crabs"] = {
    ["named"] = 32,
    ["coords"] = 74,
    ["food"] = {
      "fruit",
      "fish",
      "fungus",
      "bread",
    },
    ["abilities"] = {
      "Bubble Barrier",
      "Claw",
      "Cower",
      "Growl",
    },
  },
  ["Crocolisks"] = {
    ["named"] = 27,
    ["coords"] = 71,
    ["food"] = {
      "meat",
      "fish",
    },
    ["abilities"] = {
      "Bite",
      "Cower",
      "Death Roll",
      "Growl",
    },
  },
  ["Foxes"] = {
    ["named"] = 9,
    ["coords"] = 51,
    ["food"] = {
      "meat",
      "fruit",
    },
    ["abilities"] = {
      "Bite",
      "Cower",
      "Dash",
      "Grace",
      "Growl",
    },
  },
  ["Gorillas"] = {
    ["named"] = 24,
    ["coords"] = 117,
    ["food"] = {
      "fruit",
      "fungus",
    },
    ["abilities"] = {
      "Bite",
      "Cower",
      "Growl",
      "Thunderstomp",
    },
  },
  ["Hyenas"] = {
    ["named"] = 26,
    ["coords"] = 36,
    ["food"] = {
      "meat",
      "fruit",
    },
    ["abilities"] = {
      "Bite",
      "Cower",
      "Dash",
      "Growl",
      "Packleader",
    },
  },
  ["Owls"] = {
    ["named"] = 16,
    ["coords"] = 59,
    ["food"] = {
      "meat",
    },
    ["abilities"] = {
      "Claw",
      "Cower",
      "Dive",
      "Growl",
      "Screech",
    },
  },
  ["Raptors"] = {
    ["named"] = 51,
    ["coords"] = 115,
    ["food"] = {
      "meat",
    },
    ["abilities"] = {
      "Bite",
      "Claw",
      "Cower",
      "Dash",
      "Growl",
      "Savage Rend",
    },
  },
  ["Scorpids"] = {
    ["named"] = 38,
    ["coords"] = 36,
    ["food"] = {
      "meat",
    },
    ["abilities"] = {
      "Claw",
      "Cower",
      "Growl",
      "Scorpid Poison",
    },
  },
  ["Serpents (Cobra)"] = {
    ["named"] = 10,
    ["coords"] = 13,
    ["food"] = {
      "meat",
      "fish",
    },
    ["abilities"] = {
      "Bite",
      "Cower",
      "Growl",
      "Poison Spit",
    },
  },
  ["Spiders"] = {
    ["named"] = 91,
    ["coords"] = 213,
    ["food"] = {
      "meat",
    },
    ["abilities"] = {
      "Bite",
      "Cower",
      "Growl",
      "Web",
    },
  },
  ["Tallstriders"] = {
    ["named"] = 15,
    ["coords"] = 112,
    ["food"] = {
      "fruit",
      "fungus",
      "bread",
    },
    ["abilities"] = {
      "Bite",
      "Cower",
      "Dash",
      "Growl",
      "Strider Presence",
    },
  },
  ["Turtles"] = {
    ["named"] = 25,
    ["coords"] = 42,
    ["food"] = {
      "fruit",
      "fish",
      "fungus",
    },
    ["abilities"] = {
      "Bite",
      "Cower",
      "Growl",
      "Shell Shield",
    },
  },
  ["Wind Serpents"] = {
    ["named"] = 27,
    ["coords"] = 42,
    ["food"] = {
      "fish",
      "cheese",
      "bread",
    },
    ["abilities"] = {
      "Bite",
      "Cower",
      "Dive",
      "Growl",
      "Lightning Breath",
    },
  },
  ["Wolves"] = {
    ["named"] = 81,
    ["coords"] = 99,
    ["food"] = {
      "meat",
    },
    ["abilities"] = {
      "Bite",
      "Cower",
      "Dash",
      "Furious Howl",
      "Growl",
    },
  },
}