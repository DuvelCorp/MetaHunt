local BS = setmetatable({}, {
	__index = function(_, key)
		if MTH and MTH.LocalizeSpell then
			return MTH:LocalizeSpell(key)
		end
		return key
	end,
})

function MTH_ChronometerHunterInstallData(engine)
	if not engine then
		return
	end

	local _, class = UnitClass("player")
	if class == "HUNTER" then
		engine:AddGroup(1, true, "MAGENTA")
		engine:AddGroup(2, false, "MAROON")
		engine:AddGroup(3, false, "GREEN")

		engine:AddTimer(engine.SPELL, BS["Bestial Wrath"], 18, 0, 1, 1, { cr = "RED" })
		engine:AddTimer(engine.SPELL, BS["Concussive Shot"], 4, 1, 0, 0, { cr = "BLUE", ea = { [BS["Improved Concussive Shot"]] = 4 } })
		engine:AddTimer(engine.SPELL, BS["Counterattack"], 5, 1, 0, 0, { cr = "ORANGE" })
		engine:AddTimer(engine.SPELL, BS["Deterrence"], 10, 0, 1, 1, { cr = "ORANGE" })
		engine:AddTimer(engine.SPELL, BS["Explosive Trap"], 60, 0, 0, 0, { gr = 1, cr = "ORANGE", rc = true, ea = { [BS["Explosive Trap Effect"]] = 60 } })
		engine:AddTimer(engine.SPELL, BS["Freezing Trap"], 60, 0, 0, 0, { gr = 1, cr = "CYAN", rc = true, ea = { [BS["Freezing Trap Effect"]] = 60 } })
		engine:AddTimer(engine.SPELL, BS["Frost Trap"], 60, 0, 0, 0, { gr = 1, cr = "CYAN", rc = true, ea = { [BS["Frost Trap Aura"]] = 60 } })
		engine:AddTimer(engine.SPELL, BS["Flare"], 30, 0, 0, 0, { cr = "YELLOW", rc = true })
		engine:AddTimer(engine.SPELL, BS["Hunter's Mark"], 120, 1, 0, 0, { cr = "RED", rc = true })
		engine:AddTimer(engine.SPELL, BS["Immolation Trap"], 60, 0, 0, 0, { gr = 1, cr = "ORANGE", ea = { [BS["Immolation Trap Effect"]] = 60 } })
		engine:AddTimer(engine.SPELL, BS["Rapid Fire"], 15, 0, 1, 1, { cr = "RED" })
		engine:AddTimer(engine.SPELL, BS["Scare Beast"], 10, 1, 0, 0, { cr = "BLUE", rc = true, d = { rs = 5 } })
		engine:AddTimer(engine.SPELL, BS["Scatter Shot"], 4, 1, 0, 0, { cr = "MAROON" })
		engine:AddTimer(engine.SPELL, BS["Scorpid Sting"], 20, 1, 0, 0, { gr = 2, cr = "PURPLE", rc = true })
		engine:AddTimer(engine.SPELL, BS["Serpent Sting"], 15, 1, 0, 0, { gr = 2, cr = "GREEN", rc = true })
		engine:AddTimer(engine.SPELL, BS["Viper Sting"], 8, 1, 0, 0, { gr = 2, cr = "CYAN", rc = true })
		engine:AddTimer(engine.SPELL, BS["Wing Clip"], 10, 1, 0, 0, { cr = "YELLOW", rc = true, ea = { [BS["Improved Wing Clip"]] = 10 } })
		engine:AddTimer(engine.SPELL, BS["Wyvern Sting"], 12, 1, 0, 0, { gr = 2, cr = "MAROON", rc = true })
		engine:AddTimer(engine.SPELL, BS["Feed Pet"], 20, 0, 0, 0, { cr = "MAROON" })

		engine:AddTimer(engine.EVENT, BS["Explosive Trap Effect"], 20, 1, 0, 1, { gr = 1, cr = "ORANGE", a = 1, xn = BS["Explosive Trap"] })
		engine:AddTimer(engine.EVENT, BS["Freezing Trap Effect"], 10, 1, 0, 1, { gr = 1, cr = "CYAN", a = 1, d = { rs = 5, tn = BS["Clever Traps"], tb = 0.15, tp = 1 }, xn = BS["Freezing Trap"] })
		engine:AddTimer(engine.EVENT, BS["Frost Trap Aura"], 30, 0, 0, 0, { gr = 1, cr = "CYAN", a = 1, d = { tn = BS["Clever Traps"], tb = 0.15, tp = 1 }, xn = BS["Frost Trap"] })
		engine:AddTimer(engine.EVENT, BS["Immolation Trap Effect"], 15, 1, 0, 1, { gr = 1, cr = "ORANGE", a = 1, xn = BS["Immolation Trap"] })
		engine:AddTimer(engine.EVENT, BS["Improved Concussive Shot"], 3, 1, 0, 0, { a = 1, cr = "BLUE", xn = BS["Concussive Shot"] })
		engine:AddTimer(engine.EVENT, BS["Improved Wing Clip"], 5, 1, 0, 0, { a = 1, cr = "YELLOW", xn = BS["Wing Clip"] })
		engine:AddTimer(engine.EVENT, BS["Piercing Shot"], 8, 1, 0, 1, { a = 1, cr = "PURPLE", tx = "Interface\\Icons\\Ability_Hunter_DisarmingShot" })
		engine:AddTimer(engine.EVENT, BS["Quick Shots"], 12, 0, 1, 1, { a = 1, cr = "MAROON", tx = "Interface\\Icons\\Ability_Hunter_Quickshot" })
		engine:AddTimer(engine.EVENT, BS["Scorpid Poison"], 10, 1, 0, 0, { gr = 3, cr = "PURPLE", a = 1, dn = 1 })
	end

	local _, race = UnitRace("player")
	if race == "Dwarf" then
		engine:AddTimer(engine.SPELL, BS["Stoneform"], 8, 0, 1, 1, { cl = "RACIAL" })
	elseif race == "Human" then
		engine:AddTimer(engine.SPELL, BS["Perception"], 20, 0, 1, 1, { cl = "RACIAL" })
	elseif race == "Orc" then
		engine:AddTimer(engine.SPELL, BS["Blood Fury"], 15, 0, 1, 1, { cl = "RACIAL" })
	elseif race == "Tauren" then
		engine:AddTimer(engine.SPELL, BS["War Stomp"], 2, 0, 0, 0, { cl = "RACIAL" })
	elseif race == "Troll" then
		engine:AddTimer(engine.SPELL, BS["Berserking"], 10, 0, 1, 1, { cl = "RACIAL" })
	elseif race == "Scourge" then
		engine:AddTimer(engine.SPELL, BS["Will of the Forsaken"], 5, 0, 1, 1, { cl = "RACIAL" })
	end

	if class == "PALADIN" or class == "WARRIOR" or class == "ROGUE" or class == "SHAMAN" then
		engine:AddTimer(engine.EVENT, BS["Holy Strength"], 15, 0, 1, 1, { cr = "YELLOW", a = 1, cl = "COMMON" })
	end
	engine:AddTimer(engine.EVENT, BS["Unstable Power"], 20, 0, 1, 1, { a = 1, cr = "CYAN", cl = "COMMON" })
	engine:AddTimer(engine.EVENT, BS["Ephemeral Power"], 15, 0, 1, 1, { a = 1, cr = "CYAN", cl = "COMMON" })
	engine:AddTimer(engine.EVENT, BS["Mind Quickening"], 20, 0, 1, 1, { a = 1, cr = "CYAN", cl = "COMMON", xn = BS["Critical Mass"] })
end

if MTH_ChronometerHunter and MTH_ChronometerHunter.dataSetup then
	table.insert(MTH_ChronometerHunter.dataSetup, MTH_ChronometerHunterInstallData)
end

