------------------------------------------------------
-- MetaHunt: Hunter Talent & Spellbook Scanner
-- Runs once on login and re-runs when spells/talents change.
--
-- Exposes:
--   MTH_HT_GetTalentRank(talentName)  → currentRank (0 if unlearned)
--   MTH_HT_HasTalent(talentName)      → true if rank >= 1
--   MTH_HT_GetSpellInfo(spellName)    → { slot, rank, rankNum } or nil
--   MTH_HT_RescanTalents()            → force re-scan of all talent tabs
--   MTH_HT_RescanSpellbook()          → force re-scan of spellbook
--
-- Results cached in:
--   MTH_HT_Talents["TalentName"] = { tab, idx, rank, maxRank }
--   MTH_HT_Spells["SpellName"]   = { slot, rank, rankNum }
--     (spell entry is the *highest rank* known for that name)
------------------------------------------------------

MTH_HT_Talents = {}
MTH_HT_Spells  = {}

-- ---------------------------------------------------------------------------
-- Talent scanner
-- Uses GetNumTalentTabs / GetNumTalents / GetTalentInfo (all vanilla 1.12)
-- ---------------------------------------------------------------------------

function MTH_HT_RescanTalents()
	MTH_HT_Talents = {}

	local numTabs = GetNumTalentTabs and GetNumTalentTabs() or 0
	for tabIdx = 1, numTabs do
		local numTalents = GetNumTalents and GetNumTalents(tabIdx) or 0
		for talIdx = 1, numTalents do
			local name, _, _, _, currentRank, maxRank = GetTalentInfo(tabIdx, talIdx)
			if name and name ~= "" then
				local existing = MTH_HT_Talents[name]
				-- If the same name appears in multiple tabs (unlikely), keep highest rank.
				if not existing or (tonumber(currentRank) or 0) > (existing.rank or 0) then
					MTH_HT_Talents[name] = {
						tab     = tabIdx,
						idx     = talIdx,
						rank    = tonumber(currentRank) or 0,
						maxRank = tonumber(maxRank) or 0,
					}
				end
			end
		end
	end
end

-- ---------------------------------------------------------------------------
-- Spellbook scanner
-- Iterates all player spell tabs and caches every known spell by name.
-- Stores the highest rank found (so MTH_HT_Spells["Aimed Shot"].slot is
-- always the actionable rank the player actually has).
-- ---------------------------------------------------------------------------

local function MTH_HT_ParseRankNum(rankStr)
	if not rankStr or rankStr == "" then return 0 end
	local _, _, n = string.find(tostring(rankStr), "(%d+)")
	return tonumber(n) or 0
end

function MTH_HT_RescanSpellbook()
	MTH_HT_Spells = {}

	local numTabs = GetNumSpellTabs and GetNumSpellTabs() or 0
	for tabIdx = 1, numTabs do
		local _, _, offset, numSpells = GetSpellTabInfo(tabIdx)
		for i = 1, numSpells do
			local slot = offset + i
			local name, rank = GetSpellName(slot, BOOKTYPE_SPELL)
			if name and name ~= "" then
				local rankNum = MTH_HT_ParseRankNum(rank)
				local existing = MTH_HT_Spells[name]
				if not existing or rankNum > (existing.rankNum or 0) then
					MTH_HT_Spells[name] = {
						slot    = slot,
						rank    = rank or "",
						rankNum = rankNum,
					}
				end
			end
		end
	end
end

-- ---------------------------------------------------------------------------
-- Public accessors
-- ---------------------------------------------------------------------------

function MTH_HT_GetTalentRank(talentName)
	local entry = MTH_HT_Talents[tostring(talentName or "")]
	return entry and (entry.rank or 0) or 0
end

function MTH_HT_HasTalent(talentName)
	return MTH_HT_GetTalentRank(talentName) >= 1
end

function MTH_HT_GetSpellInfo(spellName)
	return MTH_HT_Spells[tostring(spellName or "")]
end

-- ---------------------------------------------------------------------------
-- Event-driven scanning
-- ---------------------------------------------------------------------------

local MTH_HT_Frame = CreateFrame("Frame", "MTH_HunterTalentScanFrame")

local MTH_HT_NeedTalentRescan   = false
local MTH_HT_NeedSpellRescan    = false
local MTH_HT_RescanDelay        = 0.6   -- seconds after event before scanning
local MTH_HT_RescanElapsed      = 0

MTH_HT_Frame:RegisterEvent("PLAYER_ENTERING_WORLD")
MTH_HT_Frame:RegisterEvent("LEARNED_SPELL_IN_TAB")
MTH_HT_Frame:RegisterEvent("SPELLS_CHANGED")
MTH_HT_Frame:RegisterEvent("CHARACTER_POINTS_CHANGED")

MTH_HT_Frame:SetScript("OnEvent", function()
	if event == "PLAYER_ENTERING_WORLD" then
		-- Immediate scan on login
		MTH_HT_RescanTalents()
		MTH_HT_RescanSpellbook()
		if type(MTH_HT_OnScanComplete) == "function" then
			MTH_HT_OnScanComplete()
		end
		-- Also schedule a deferred re-scan: GetTalentInfo can return stale
		-- data for a brief window after PLAYER_ENTERING_WORLD on login.
		MTH_HT_NeedTalentRescan = true
		MTH_HT_NeedSpellRescan  = true
		MTH_HT_RescanElapsed    = 0
		this:Show()  -- enable OnUpdate for the deferred pass
		return
	end

	-- For other events, schedule a deferred rescan so we don't fire
	-- multiple times if several events arrive in the same frame.
	if event == "CHARACTER_POINTS_CHANGED" then
		MTH_HT_NeedTalentRescan = true
	end
	if event == "LEARNED_SPELL_IN_TAB" or event == "SPELLS_CHANGED" then
		MTH_HT_NeedSpellRescan = true
	end
	MTH_HT_RescanElapsed = 0
	this:Show()
end)

MTH_HT_Frame:SetScript("OnUpdate", function()
	MTH_HT_RescanElapsed = (MTH_HT_RescanElapsed or 0) + (arg1 or 0)
	if MTH_HT_RescanElapsed < MTH_HT_RescanDelay then return end

	-- Batch-flush pending scans
	if MTH_HT_NeedTalentRescan then
		MTH_HT_RescanTalents()
		MTH_HT_NeedTalentRescan = false
	end
	if MTH_HT_NeedSpellRescan then
		MTH_HT_RescanSpellbook()
		MTH_HT_NeedSpellRescan = false
	end

	-- Notify dependents
	if type(MTH_HT_OnScanComplete) == "function" then
		MTH_HT_OnScanComplete()
	end

	this:Hide()
	MTH_HT_RescanElapsed = 0
end)

MTH_HT_Frame:Hide()
