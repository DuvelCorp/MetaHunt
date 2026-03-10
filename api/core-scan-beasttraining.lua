if not MTH then
	error("MetaHunt core framework missing: api/core-framework.lua must load before api/core-scan-beasttraining.lua")
end

local function MTH_PT_SafeLower(text)
	if text == nil then return "" end
	return string.lower(tostring(text))
end

local function MTH_PT_GetGlobal(name)
	if type(getglobal) == "function" then
		return getglobal(name)
	end
	if _G then
		return _G[name]
	end
	return nil
end

local MTH_PT_ApplyScan
local MTH_PT_AbilityHasPositiveRanks
local MTH_PT_PromoteUnrankedKnownAliases
local MTH_PT_BootstrapFrame = nil

local MTH_PT_VERBOSE_SCAN_LOGS = false

local function MTH_PT_GetStore()
	if not MTH_CharSavedVariables then MTH_CharSavedVariables = {} end
	if not MTH_CharSavedVariables.trainScan and MTH_CharSavedVariables.petTraining then
		MTH_CharSavedVariables.trainScan = MTH_CharSavedVariables.petTraining
	end
	if not MTH_CharSavedVariables.trainScan then
		MTH_CharSavedVariables.trainScan = {
			spellMap = {},
			hunterKnownMap = {},
			lastScan = 0,
			lastPrompt = 0,
			hasCompletedPetScan = nil,
		}
	end
	if not MTH_CharSavedVariables.trainScan.spellMap then
		MTH_CharSavedVariables.trainScan.spellMap = {}
	end
	if not MTH_CharSavedVariables.trainScan.hunterKnownMap then
		MTH_CharSavedVariables.trainScan.hunterKnownMap = {}
	end
	if MTH_CharSavedVariables.trainScan.hasCompletedPetScan == nil then
		if tonumber(MTH_CharSavedVariables.trainScan.lastScan) and tonumber(MTH_CharSavedVariables.trainScan.lastScan) > 0 then
			MTH_CharSavedVariables.trainScan.hasCompletedPetScan = 1
		elseif MTH_CharSavedVariables.trainScan.spellMap then
			for _ in pairs(MTH_CharSavedVariables.trainScan.spellMap) do
				MTH_CharSavedVariables.trainScan.hasCompletedPetScan = 1
				break
			end
		end
	end
	MTH_CharSavedVariables.petTraining = MTH_CharSavedVariables.trainScan
	MTH_PT_PromoteUnrankedKnownAliases(MTH_CharSavedVariables.trainScan)
	return MTH_CharSavedVariables.trainScan
end

function MTH_GetPetTrainingSnapshot()
	return MTH_PT_GetStore()
end

function MTH_GetKnownPetSpellMap()
	local store = MTH_PT_GetStore()
	if type(store) ~= "table" then
		return nil
	end
	return store.spellMap
end

local function MTH_PT_ParseRank(name, subText)
	local rankNumber = nil
	local sub = tostring(subText or "")
	if sub ~= "" then
		local _, _, subRank = string.find(sub, "(%d+)")
		rankNumber = tonumber(subRank)
	end
	if not rankNumber then
		local nm = tostring(name or "")
		local _, _, nameRank = string.find(nm, "(%d+)")
		rankNumber = tonumber(nameRank)
	end
	if not rankNumber then
		local full = tostring(name or "") .. " " .. tostring(subText or "")
		local _, _, fullRank = string.find(full, "(%d+)")
		rankNumber = tonumber(fullRank)
	end
	if rankNumber then
		return "Rank " .. tostring(rankNumber), rankNumber
	end
	return "", nil
end

local function MTH_PT_NormalizeName(name)
	local label = tostring(name or "")
	label = string.gsub(label, "^%s+", "")
	label = string.gsub(label, "%s+$", "")
	return label
end

local function MTH_PT_BaseAbility(name)
	local base = MTH_PT_NormalizeName(name)
	base = string.gsub(base, "%s*%([^%)]*%d+[^%)]*%)", "")
	base = string.gsub(base, "%s*%([Rr]ank[^%)]*%)", "")
	base = string.gsub(base, "%s+[Rr]ank%s+%d+", "")
	base = string.gsub(base, "%s+%d+$", "")
	base = string.gsub(base, "%s+$", "")
	return base
end

local function MTH_PT_MakeToken(name, subText)
	local base = MTH_PT_BaseAbility(name)
	local rankText, rankNumber = MTH_PT_ParseRank(name, subText)
	if rankNumber and rankNumber > 0 and not MTH_PT_AbilityHasPositiveRanks(base) then
		rankText = ""
		rankNumber = nil
	end
	if rankText ~= "" then
		return MTH_PT_SafeLower(base) .. "#" .. tostring(rankNumber), base, rankText, rankNumber
	end
	return MTH_PT_SafeLower(base), base, "", nil
end

local function MTH_PT_HasAnyLearnedSpells()
	local store = MTH_PT_GetStore()
	local spellMap = store.spellMap
	if not spellMap then return false end
	for _ in pairs(spellMap) do
		return true
	end
	return false
end

local function MTH_PT_IsBeastTrainingContextActive()
	local frameNames = { "BeastTrainingFrame", "PetTrainingFrame", "CraftFrame" }
	for i = 1, table.getn(frameNames) do
		local frameName = frameNames[i]
		local frame = (type(getglobal) == "function" and getglobal(frameName)) or (_G and _G[frameName])
		if frame then
			if frame.IsVisible and frame:IsVisible() then
				return true
			end
			if frame.IsShown and frame:IsShown() then
				return true
			end
		end
	end
	return false
end

local function MTH_PT_GetBeastTrainingRowCount()
	if not MTH_PT_IsBeastTrainingContextActive() then
		return 0
	end

	local getNumCrafts = MTH_PT_GetGlobal("GetNumCrafts")
	if type(getNumCrafts) ~= "function" then
		return 0
	end
	return tonumber(getNumCrafts()) or 0
end

function MTH_PT_HasBeastTrainingRows()
	return MTH_PT_GetBeastTrainingRowCount() > 0
end

local function MTH_PT_DebugLog(line)
	return
end

local function MTH_PT_IsScanMessageEnabled()
	if not (MTH and MTH.IsMessageEnabled) then
		return true
	end
	return MTH:IsMessageEnabled("beastTrainingScan", true)
end

local function MTH_PT_MakeTokenFromAbilityRank(abilityName, rankNumber)
	local ability = MTH_PT_NormalizeName(abilityName)
	local key = MTH_PT_SafeLower(ability)
	if key == "" then return "", ability, "", nil end
	local rank = tonumber(rankNumber)
	if rank and rank > 0 and not MTH_PT_AbilityHasPositiveRanks(ability) then
		rank = nil
	end
	if rank and rank > 0 then
		return key .. "#" .. tostring(rank), ability, "Rank " .. tostring(rank), rank
	end
	return key, ability, "", nil
end

local function MTH_PT_AbilityExistsInData(baseAbility)
	local ability = MTH_PT_NormalizeName(baseAbility)
	if ability == "" then return false end
	if not MTH_DS_PetSpells or not MTH_DS_PetSpells.byAbility then
		return false
	end
	if MTH_DS_PetSpells.byAbility[ability] then
		return true
	end
	for abilityName in pairs(MTH_DS_PetSpells.byAbility) do
		if MTH_PT_SafeLower(abilityName) == MTH_PT_SafeLower(ability) then
			return true
		end
	end
	return false
end

MTH_PT_AbilityHasPositiveRanks = function(baseAbility)
	local ability = MTH_PT_NormalizeName(baseAbility)
	if ability == "" then return false end
	if not MTH_DS_PetSpells or not MTH_DS_PetSpells.byAbility then
		return false
	end

	local bucket = MTH_DS_PetSpells.byAbility[ability]
	if not bucket then
		for abilityName, row in pairs(MTH_DS_PetSpells.byAbility) do
			if MTH_PT_SafeLower(abilityName) == MTH_PT_SafeLower(ability) then
				bucket = row
				break
			end
		end
	end

	if not (bucket and bucket.spells) then
		return false
	end

	for i = 1, table.getn(bucket.spells) do
		local spell = bucket.spells[i]
		if spell then
			local rank = tonumber(spell.rankNumber)
			if not rank and spell.rank then
				local _, _, parsed = string.find(tostring(spell.rank), "(%d+)")
				rank = tonumber(parsed)
			end
			if rank and rank > 0 then
				return true
			end
		end
	end

	return false
end

MTH_PT_PromoteUnrankedKnownAliases = function(store)
	if not store or not store.hunterKnownMap or not store.spellMap then
		return
	end

	for token, isKnown in pairs(store.hunterKnownMap) do
		if isKnown == true then
			local _, _, baseToken = string.find(tostring(token), "^(.-)#%d+$")
			if baseToken and baseToken ~= "" then
				local baseRow = store.spellMap[baseToken]
				if baseRow and ((tonumber(baseRow.rankNumber) or 0) <= 0) then
					store.hunterKnownMap[baseToken] = true
					if baseRow.isKnown ~= true then
						baseRow.isKnown = true
					end
				end
			end
		end
	end
end

local function MTH_PT_MarkHunterKnownToken(token)
	if token == nil or token == "" then
		return false
	end

	local store = MTH_PT_GetStore()
	local markToken = token
	local _, _, baseToken = string.find(tostring(token), "^(.-)#%d+$")
	if baseToken and baseToken ~= "" then
		local baseRow = store.spellMap and store.spellMap[baseToken]
		if baseRow and ((tonumber(baseRow.rankNumber) or 0) <= 0) then
			markToken = baseToken
		end
	end
	local changed = false
	if store.hunterKnownMap[markToken] ~= true then
		store.hunterKnownMap[markToken] = true
		changed = true
	end
	if markToken ~= token and store.hunterKnownMap[token] ~= true then
		store.hunterKnownMap[token] = true
		changed = true
	end

	if store.spellMap and store.spellMap[markToken] and store.spellMap[markToken].isKnown ~= true then
		store.spellMap[markToken].isKnown = true
		changed = true
	end
	if markToken ~= token and store.spellMap and store.spellMap[token] and store.spellMap[token].isKnown ~= true then
		store.spellMap[token].isKnown = true
		changed = true
	end

	if changed and MTH_PT_DebugLog then
		MTH_PT_DebugLog("hunter-known token promoted: " .. tostring(token))
	end

	return changed
end

local function MTH_PT_IsHunterTokenKnown(token)
	if token == nil or token == "" then
		return false
	end

	local store = MTH_PT_GetStore()
	if store.hunterKnownMap and store.hunterKnownMap[token] == true then
		return true
	end

	if store.spellMap and store.spellMap[token] and store.spellMap[token].isKnown == true then
		return true
	end

	local _, _, baseToken = string.find(tostring(token), "^(.-)#%d+$")
	if baseToken and baseToken ~= "" then
		if store.hunterKnownMap and store.hunterKnownMap[baseToken] == true then
			return true
		end
		if store.spellMap and store.spellMap[baseToken] and store.spellMap[baseToken].isKnown == true then
			return true
		end
	end

	return false
end

local function MTH_PT_ProcessLearnSystemMessage(rawMessage)
	local message = tostring(rawMessage or "")
	if message == "" then return false end
	message = string.gsub(message, "|c%x%x%x%x%x%x%x%x", "")
	message = string.gsub(message, "|r", "")
	message = string.gsub(message, "^%s+", "")
	message = string.gsub(message, "%s+$", "")

	local _, _, abilityName, rankText = string.find(message, "^[Yy]ou have learned a new spell:%s*(.-)%s*%([Rr]ank%s*(%d+)%)%.?$")
	if not abilityName or not rankText then
		_, _, abilityName, rankText = string.find(message, "^[Yy]ou have learned a new spell:%s*(.-)%s*[Rr]ank%s*(%d+)%.?$")
	end
	if not abilityName or not rankText then
		return false
	end

	local rankNumber = tonumber(rankText)
	if not rankNumber then
		return false
	end

	abilityName = MTH_PT_NormalizeName(abilityName)
	if abilityName == "" then return false end
	if not MTH_PT_AbilityExistsInData(abilityName) then
		if MTH_PT_DebugLog then
			MTH_PT_DebugLog("learn-msg ignored (not pet ability dataset): '" .. tostring(abilityName) .. "'")
		end
		return false
	end

	local token = MTH_PT_MakeTokenFromAbilityRank(abilityName, rankNumber)
	if token == "" then return false end

	local alreadyKnown = MTH_PT_IsHunterTokenKnown(token)
	local changed = false
	if not alreadyKnown then
		changed = MTH_PT_MarkHunterKnownToken(token)
	end

	local petRecorded = false
	if type(MTH_PETS_RecordCurrentPetLearnedAbility) == "function" then
		petRecorded = MTH_PETS_RecordCurrentPetLearnedAbility(abilityName, rankNumber, "beasttraining:learn-msg") and true or false
	end

	if changed or petRecorded then
		if MTH_PT_DebugLog then
			MTH_PT_DebugLog("learn-msg captured: source='you have learned a new spell' ability='" .. tostring(abilityName) .. "' rank=" .. tostring(rankNumber) .. " token='" .. tostring(token) .. "' changed=" .. tostring(changed) .. " petRecorded=" .. tostring(petRecorded))
		end
		local label = tostring(abilityName)
		if rankNumber and rankNumber > 0 then
			label = label .. " (Rank " .. tostring(rankNumber) .. ")"
		end
		if MTH and MTH.Print then
			if MTH:IsMessageEnabled("beastTrainingScan", true) then
				if changed then
					MTH:Print("Pet ability learned and recorded: " .. label .. ". It is now marked as known in MetaHunt.")
				else
					MTH:Print("Pet ability learned for current pet: " .. label .. ".")
				end
			end
		end
		if changed then
			MTH_PT_ApplyScan("learn-msg")
		end
		if type(MTH_PSP_RequestScan) == "function" then
			MTH_PSP_RequestScan("train-learn-msg")
		end
	elseif alreadyKnown and MTH_PT_DebugLog then
		MTH_PT_DebugLog("learn-msg ignored (already known and no active pet row update): token='" .. tostring(token) .. "'")
	end

	return changed or petRecorded
end

local function MTH_PT_CollectKnownBeastTrainingMap()
	if not MTH_PT_IsBeastTrainingContextActive() then
		if MTH_PT_DebugLog then
			MTH_PT_DebugLog("collect beast-training known skipped: explicit beast training context not active")
		end
		return {}
	end

	local getNumCrafts = MTH_PT_GetGlobal("GetNumCrafts")
	local getCraftInfo = MTH_PT_GetGlobal("GetCraftInfo")
	if type(getNumCrafts) ~= "function" or type(getCraftInfo) ~= "function" then
		if MTH_PT_DebugLog then
			MTH_PT_DebugLog("collect beast-training known unavailable: GetNumCrafts=" .. tostring(type(getNumCrafts)) .. ", GetCraftInfo=" .. tostring(type(getCraftInfo)))
		end
		return {}
	end

	local totalCrafts = tonumber(getNumCrafts()) or 0
	local knownMap = {}
	if totalCrafts <= 0 then
		if MTH_PT_DebugLog then
			MTH_PT_DebugLog("collect beast-training known empty: totalRows=0")
		end
		return knownMap
	end

	if MTH_PT_DebugLog then
		MTH_PT_DebugLog("collect beast-training known start: totalRows=" .. tostring(totalCrafts))
	end
	for i = 1, totalCrafts do
		local craftName, craftSubSpellName, craftType = getCraftInfo(i)
		local typeText = tostring(craftType or "")
		local token, base, parsedRankText, rankNumber = MTH_PT_MakeToken(craftName, craftSubSpellName)

		if token ~= "" then
			if MTH_PT_DebugLog then
				MTH_PT_DebugLog("beast-training row=" .. tostring(i) .. " token='" .. tostring(token) .. "' name='" .. tostring(base or "") .. "' rank='" .. tostring(parsedRankText or "") .. "' rankNumber=" .. tostring(rankNumber) .. " type='" .. typeText .. "'")
			end
			knownMap[token] = {
				name = MTH_PT_NormalizeName(base),
				rank = parsedRankText,
				rankNumber = rankNumber,
				fullName = MTH_PT_NormalizeName(craftName),
				subText = tostring(craftSubSpellName or ""),
				isKnown = true,
				scannedAt = time(),
				rowType = typeText,
			}
		end
	end
	if MTH_PT_DebugLog then
		local total = 0
		for _ in pairs(knownMap) do total = total + 1 end
		MTH_PT_DebugLog("collect beast-training known end: tokens=" .. tostring(total))
	end
	return knownMap
end

function MTH_PT_ApplyScan(triggerReason)
	if MTH_PT_DebugLog then
		MTH_PT_DebugLog("scan start: trigger=" .. tostring(triggerReason or ""))
	end

	local store = MTH_PT_GetStore()
	local oldMap = store.spellMap
	if not oldMap then oldMap = {} end
	local hunterKnownMap = store.hunterKnownMap or {}

	local knownMap = MTH_PT_CollectKnownBeastTrainingMap()
	local knownCount = 0
	for _ in pairs(knownMap) do knownCount = knownCount + 1 end
	if knownCount <= 0 then
		if MTH_PT_DebugLog then
			MTH_PT_DebugLog("scan abort: beast-training known count=0")
		end
		return false, 0, 0, 0
	end
	for token in pairs(knownMap) do
		hunterKnownMap[token] = true
	end
	for token, row in pairs(oldMap) do
		if row and row.isKnown then
			hunterKnownMap[token] = true
		end
	end
	for token in pairs(knownMap) do
		if hunterKnownMap[token] == nil then
			hunterKnownMap[token] = false
		end
	end
	store.hunterKnownMap = hunterKnownMap

	local newMap = {}
	if MTH_DS_PetSpells and MTH_DS_PetSpells.byAbility then
		for abilityName, bucket in pairs(MTH_DS_PetSpells.byAbility) do
			if bucket and bucket.spells then
				for i = 1, table.getn(bucket.spells) do
					local spell = bucket.spells[i]
					if spell then
						local rankNumber = tonumber(spell.rankNumber)
						if not rankNumber and spell.rank then
							local _, _, parsed = string.find(tostring(spell.rank), "(%d+)")
							rankNumber = tonumber(parsed)
						end
						local token, baseName, rankText, parsedRankNumber = MTH_PT_MakeTokenFromAbilityRank(abilityName, rankNumber)
						if token ~= "" then
							local tpCost = tonumber(spell.trainingPointCost)
							if not tpCost and spell.cost then
								local _, _, parsedCost = string.find(tostring(spell.cost), "(%d+)")
								tpCost = tonumber(parsedCost)
							end
							newMap[token] = {
								name = baseName,
								rank = rankText,
								rankNumber = parsedRankNumber,
								fullName = rankText ~= "" and (baseName .. " " .. rankText) or baseName,
								subText = rankText,
								serviceType = "datastore",
								reqLevel = tonumber(spell.trainLevel),
								isKnown = hunterKnownMap[token] and true or false,
								isKnownPet = knownMap[token] and true or false,
								scannedAt = time(),
								trainingPointCost = tpCost,
								learnMethod = spell.learnMethod,
								icon = spell.icon,
							}
						end
					end
				end
			end
		end
	end

	for token, row in pairs(knownMap) do
		if newMap[token] then
			newMap[token].isKnownPet = true
			newMap[token].scannedAt = time()
		else
			newMap[token] = {
				name = row.name,
				rank = row.rank,
				rankNumber = row.rankNumber,
				fullName = row.fullName,
				subText = row.subText,
				serviceType = "beast-training",
				reqLevel = nil,
				isKnown = hunterKnownMap[token] and true or false,
				isKnownPet = true,
				scannedAt = time(),
				trainingPointCost = nil,
			}
		end
	end

	local discovered = 0
	for _ in pairs(newMap) do discovered = discovered + 1 end
	if discovered <= 0 then
		return false, 0, 0, 0
	end

	local added = 0
	local removed = 0
	local addedDetails = {}
	for token in pairs(newMap) do
		if not oldMap[token] then
			added = added + 1
			local row = newMap[token]
			local spellName = MTH_PT_NormalizeName((row and row.name) or "")
			local rankText = tostring((row and row.rank) or "")
			if spellName == "" then
				spellName = MTH_PT_NormalizeName((row and row.fullName) or "")
			end
			if spellName ~= "" then
				local label = spellName
				if rankText ~= "" then
					label = label .. " " .. rankText
				end
				table.insert(addedDetails, label)
			end
		end
	end
	for token in pairs(oldMap) do
		if not newMap[token] then
			removed = removed + 1
		end
	end

	store.spellMap = newMap
	store.lastScan = time()
	store.hasCompletedPetScan = 1
	MTH_CharSavedVariables.trainScan = store
	MTH_CharSavedVariables.petTraining = store

	local totalRanks = 0
	local baseSet = {}
	for _, row in pairs(newMap) do
		totalRanks = totalRanks + 1
		local base = MTH_PT_SafeLower(row and row.name)
		if base ~= "" then baseSet[base] = true end
	end
	local totalBaselines = 0
	for _ in pairs(baseSet) do totalBaselines = totalBaselines + 1 end

	if triggerReason == "initial" then
		if MTH_PT_IsScanMessageEnabled() then
			MTH:Print("Initial train scan complete: " .. tostring(totalBaselines) .. " baselines / " .. tostring(totalRanks) .. " ranks recorded for this character.")
		end
	elseif added > 0 then
		table.sort(addedDetails)
		local detailsText = table.concat(addedDetails, ", ")
		if detailsText ~= "" then
			local msg = "New pet data recorded (" .. tostring(added) .. " new rank(s)): " .. detailsText .. ". Known totals for this character: " .. tostring(totalBaselines) .. " ability type(s), " .. tostring(totalRanks) .. " rank(s)."
			if MTH_PT_IsScanMessageEnabled() then
				MTH:Print(msg)
				MTH:Print("INFO: " .. msg, "debug")
			end
		else
			local msg = "New pet data recorded (" .. tostring(added) .. " new rank(s)). Known totals for this character: " .. tostring(totalBaselines) .. " ability type(s), " .. tostring(totalRanks) .. " rank(s)."
			if MTH_PT_IsScanMessageEnabled() then
				MTH:Print(msg)
				MTH:Print("INFO: " .. msg, "debug")
			end
		end
	end

	return true, added, totalBaselines, totalRanks
end

local function MTH_PT_ShouldScanNow()
	return MTH_PT_HasBeastTrainingRows()
end

MTH_PT_IsPetBookVisible = function()
	local frameNames = { "BeastTrainingFrame", "PetTrainingFrame", "CraftFrame" }
	for i = 1, table.getn(frameNames) do
		local frameName = frameNames[i]
		local frame = (type(getglobal) == "function" and getglobal(frameName)) or (_G and _G[frameName])
		if frame then
			if frame.IsVisible and frame:IsVisible() then
				return true
			end
			if frame.IsShown and frame:IsShown() then
				return true
			end
		end
	end
	return false
end

local function MTH_PT_RunDoubleScan(triggerBase)
	local triggerText = tostring(triggerBase or "")
	local feedbackOnOpen = (
		triggerText == "petbook-open"
		or triggerText == "craft-open"
		or triggerText == "craft-update"
		or triggerText == "beast-training-rows-open"
		or triggerText == "petbook-visible-poll"
	)
	if not MTH_PT_ShouldScanNow() then
		if MTH_PT_DebugLog then
			MTH_PT_DebugLog("scan skipped: no beast-training rows, trigger=" .. tostring(triggerBase or ""))
		end
		if feedbackOnOpen and MTH and MTH.Print and MTH_PT_IsScanMessageEnabled() then
			MTH:Print("Beast Training opened, but scan did not run yet (no scannable rows detected).")
		end
		return false
	end

	local t0 = time()
	local ok, added, baselines, ranks = MTH_PT_ApplyScan(triggerText .. ":single")
	local t1 = time()

	if MTH_PT_DebugLog then
		MTH_PT_DebugLog("scan complete: trigger=" .. tostring(triggerBase or "") .. " ok=" .. tostring(ok and true or false) .. " dt=" .. tostring((t1 or 0) - (t0 or 0)) .. "s")
	end
	if feedbackOnOpen and MTH and MTH.Print and MTH_PT_IsScanMessageEnabled() then
		if ok then
			local addedCount = tonumber(added) or 0
			local msg = "Beast Training scan complete: " .. tostring(baselines or 0) .. " baselines / " .. tostring(ranks or 0) .. " ranks."
			if addedCount > 0 then
				msg = msg .. " Added +" .. tostring(addedCount) .. " new rank(s)."
			end
			MTH:Print(msg)
		else
			MTH:Print("Beast Training scan attempted, but no data was recorded.")
		end
	end

	return ok and true or false
end

local MTH_PetTrainingFrame = nil
local MTH_PT_PetBookWasVisible = false
local MTH_PT_PetBookPollElapsed = 0
local MTH_PT_TrainingRowsWerePresent = false
local MTH_PT_LastTrainingRowCount = 0
local MTH_PT_LastAutoDoubleScanAt = 0

local function MTH_PT_RunDoubleScanThrottled(triggerBase, minIntervalSeconds)
	local now = tonumber(time()) or 0
	local minInterval = tonumber(minIntervalSeconds) or 0
	if minInterval > 0 and (now - (MTH_PT_LastAutoDoubleScanAt or 0)) < minInterval then
		return false
	end
	MTH_PT_LastAutoDoubleScanAt = now
	return MTH_PT_RunDoubleScan(triggerBase)
end

local function MTH_PT_OnEvent(_, evt, eventArg1)
	evt = evt or event
	eventArg1 = eventArg1 or arg1
	if not evt then
		return
	end

	if evt == "PLAYER_ENTERING_WORLD" then
		local playerLevel = 0
		if type(UnitLevel) == "function" then
			playerLevel = tonumber(UnitLevel("player")) or 0
		end
		if UnitClass then
			local _, classToken = UnitClass("player")
			if classToken ~= "HUNTER" then return end
		end
		if playerLevel >= 12 and not MTH_PT_HasAnyLearnedSpells() then
			local store = MTH_PT_GetStore()
			local now = time()
			if not store.lastPrompt or (now - store.lastPrompt) > 60 then
				store.lastPrompt = now
				if MTH_PT_IsScanMessageEnabled() then
					MTH:Print("No Beast Training scan found for this character. Open Beast Training (right panel) to record pet spell ranks.")
				end
			end
		end
		return
	end

	if evt == "LEARNED_SPELL_IN_TAB" then
		if MTH_PT_ShouldScanNow() then
			MTH_PT_RunDoubleScan("petbook-visible:" .. tostring(evt))
		end
		return
	end

	if evt == "PET_TRAINING_SHOW" then
		MTH_PT_RunDoubleScan("petbook-open")
		return
	end

	if evt == "CRAFT_SHOW" then
		MTH_PT_RunDoubleScanThrottled("craft-open", 1)
		return
	end

	if evt == "CRAFT_UPDATE" then
		if MTH_PT_ShouldScanNow() then
			MTH_PT_RunDoubleScanThrottled("craft-update", 1)
		end
		return
	end

	if evt == "SPELLS_CHANGED" then
		if MTH_PT_ShouldScanNow() then
			MTH_PT_RunDoubleScan("petbook-visible:" .. tostring(evt))
		end
		return
	end

	if evt == "UNIT_PET" or evt == "PET_BAR_UPDATE" then
		if evt == "UNIT_PET" then
			local unit = eventArg1
			if unit ~= "player" then return end
		end
		if MTH_PT_ShouldScanNow() then
			MTH_PT_RunDoubleScan("petbook-visible:" .. tostring(evt))
		end
		return
	end

	if evt == "CHAT_MSG_SYSTEM" then
		MTH_PT_ProcessLearnSystemMessage(eventArg1)
		return
	end
end

function MTH_PT_InitService()
	if MTH and MTH.ApplyClassGate and MTH:ApplyClassGate("trainscan-init") then
		return
	end

	if MTH_PetTrainingFrame then
		return
	end
	MTH_PetTrainingFrame = CreateFrame("Frame", "MTH_PetTrainingScan")
	MTH_PetTrainingFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	MTH_PetTrainingFrame:RegisterEvent("LEARNED_SPELL_IN_TAB")
	MTH_PetTrainingFrame:RegisterEvent("PET_TRAINING_SHOW")
	MTH_PetTrainingFrame:RegisterEvent("SPELLS_CHANGED")
	MTH_PetTrainingFrame:RegisterEvent("UNIT_PET")
	MTH_PetTrainingFrame:RegisterEvent("PET_BAR_UPDATE")
	MTH_PetTrainingFrame:RegisterEvent("CHAT_MSG_SYSTEM")
	MTH_PetTrainingFrame:RegisterEvent("CRAFT_SHOW")
	MTH_PetTrainingFrame:RegisterEvent("CRAFT_UPDATE")
	MTH_PetTrainingFrame:SetScript("OnEvent", MTH_PT_OnEvent)
	MTH_PetTrainingFrame:SetScript("OnUpdate", function()
		MTH_PT_PetBookPollElapsed = (MTH_PT_PetBookPollElapsed or 0) + (arg1 or 0)
		if MTH_PT_PetBookPollElapsed < 0.20 then
			return
		end
		MTH_PT_PetBookPollElapsed = 0

		local rowCount = MTH_PT_GetBeastTrainingRowCount()
		local hasRows = rowCount > 0
		if hasRows and not MTH_PT_TrainingRowsWerePresent then
			MTH_PT_RunDoubleScanThrottled("beast-training-rows-open", 1)
		end

		if hasRows and rowCount ~= (MTH_PT_LastTrainingRowCount or 0) then
			MTH_PT_RunDoubleScanThrottled("beast-training-rows-changed", 1)
		end

		if hasRows then
			MTH_PT_RunDoubleScanThrottled("beast-training-rows-present", 8)
		end

		MTH_PT_TrainingRowsWerePresent = hasRows
		MTH_PT_LastTrainingRowCount = rowCount

		local visible = MTH_PT_IsPetBookVisible()
		if visible and not MTH_PT_PetBookWasVisible then
			MTH_PT_RunDoubleScanThrottled("petbook-visible-poll", 1)
		end

		MTH_PT_PetBookWasVisible = visible and true or false
	end)
end

function MTH_PT_InitBootstrap()
	if MTH and MTH.ApplyClassGate and MTH:ApplyClassGate("trainscan-bootstrap") then
		return
	end
	if MTH_PetTrainingFrame or MTH_PT_BootstrapFrame then
		return
	end

	local frame = CreateFrame("Frame")
	if not frame then
		return
	end
	frame:RegisterEvent("PET_TRAINING_SHOW")
	frame:RegisterEvent("CRAFT_SHOW")
	frame:SetScript("OnEvent", function()
		if event ~= "PET_TRAINING_SHOW" and event ~= "CRAFT_SHOW" then
			return
		end
		MTH_PT_InitService()
		if type(MTH_PT_OnEvent) == "function" then
			MTH_PT_OnEvent(MTH_PetTrainingFrame, event)
		end
		this:UnregisterAllEvents()
		this:SetScript("OnEvent", nil)
		MTH_PT_BootstrapFrame = nil
	end)
	MTH_PT_BootstrapFrame = frame
end

function MTH_PT_ShutdownService(_reason)
	if not MTH_PetTrainingFrame then
		return
	end

	MTH_PetTrainingFrame:UnregisterAllEvents()
	MTH_PetTrainingFrame:SetScript("OnEvent", nil)
	MTH_PetTrainingFrame:SetScript("OnUpdate", nil)
	MTH_PetTrainingFrame = nil

	MTH_PT_PetBookWasVisible = false
	MTH_PT_PetBookPollElapsed = 0
	MTH_PT_TrainingRowsWerePresent = false
	MTH_PT_LastTrainingRowCount = 0
	MTH_PT_LastAutoDoubleScanAt = 0
end

function MTH_CommandPetScan()
	local function requestBeastTrainingOpen()
		if MTH_PT_IsPetBookVisible and MTH_PT_IsPetBookVisible() then
			return true
		end

		local bookTypePet = MTH_PT_GetGlobal("BOOKTYPE_PET")
		local openSpellBook = MTH_PT_GetGlobal("OpenSpellBook")
		if type(openSpellBook) == "function" and bookTypePet then
			openSpellBook(bookTypePet)
		end

		if MTH_PT_IsPetBookVisible and MTH_PT_IsPetBookVisible() then
			return true
		end

		local toggleSpellBook = MTH_PT_GetGlobal("ToggleSpellBook")
		if type(toggleSpellBook) == "function" then
			if bookTypePet then
				toggleSpellBook(bookTypePet)
			else
				toggleSpellBook()
			end
		end

		return MTH_PT_IsPetBookVisible and MTH_PT_IsPetBookVisible() or false
	end

	if UnitClass then
		local _, classToken = UnitClass("player")
		if classToken ~= "HUNTER" then
			MTH:Print("Train scan is hunter-only.")
			return
		end
	end

	if not MTH_PT_ShouldScanNow() then
		local opened = requestBeastTrainingOpen()
		if not MTH_PT_ShouldScanNow() then
			if opened then
				MTH:Print("Beast Training is open, but no scannable rows were detected yet. Try once more after the list fully loads.")
			else
				MTH:Print("Could not detect Beast Training rows. Open Beast Training (right panel) and run /mth trainscan again.")
			end
			return
		end
	end

	local ok, added, baselines, ranks = MTH_PT_ApplyScan("manual")
	if not ok then
		MTH:Print("Train scan failed. Keep Beast Training open and try /mth trainscan again.")
		return
	end

	MTH:Print("Train scan saved for this character: " .. tostring(baselines) .. " baselines / " .. tostring(ranks) .. " ranks.")
	if (tonumber(added) or 0) > 0 then
		MTH:Print("Newly recorded ranks: +" .. tostring(added))
	end
end

function MTH_CommandTrainScan()
	return MTH_CommandPetScan()
end

MTH_TR_InitService = MTH_PT_InitService
MTH_TR_ShutdownService = MTH_PT_ShutdownService
MTH_TR_InitBootstrap = MTH_PT_InitBootstrap
