local function zButtonCraft_GetRoot()
	return MTH_ZH_GetSavedRoot()
end

local root = zButtonCraft_GetRoot()
if not root["zButtonCraft"] then
	root["zButtonCraft"] = {}
	root["zButtonCraft"]["spells"] = {}
	root["zButtonCraft"]["rows"] = 1
	root["zButtonCraft"]["horizontal"] = nil
	root["zButtonCraft"]["vertical"] = nil
	root["zButtonCraft"]["firstbutton"] = "RIGHT"
	root["zButtonCraft"]["enabled"] = 0
	root["zButtonCraft"]["tooltip"] = 1
	root["zButtonCraft"]["parent"] = {}
	root["zButtonCraft"]["parent"]["size"] = 36
	root["zButtonCraft"]["parent"]["hide"] = nil
	root["zButtonCraft"]["parent"]["circle"] = 1
	root["zButtonCraft"]["children"] = {}
	root["zButtonCraft"]["children"]["size"] = 36
	root["zButtonCraft"]["children"]["hideonclick"] = 1
end

local ZHUNTER_CRAFT_BUTTON_MAX = 14

local zButtonCraft_LastSpellSignature = nil
local zButtonCraft_LastRefreshAt      = 0
local zButtonCraft_MinRefreshInterval = 0.50

-- Exact spell names as they appear in the General spellbook tab.
-- spellName = the name returned by GetSpellName() to match against (case-insensitive)
-- display   = label used for tooltips and options
local ZCRAFT_PROFESSIONS = {
	{ spellName = "Alchemy",        display = "Alchemy"        },
	{ spellName = "Blacksmithing",  display = "Blacksmithing"  },
	{ spellName = "Disenchanting",  display = "Disenchanting"  },
	{ spellName = "Enchanting",     display = "Enchanting"     },
	{ spellName = "Engineering",    display = "Engineering"    },
	{ spellName = "Leatherworking", display = "Leatherworking" },
	{ spellName = "Tailoring",      display = "Tailoring"      },
	{ spellName = "Jewelcrafting",  display = "Jewelcrafting"  },
	{ spellName = "Mining",         display = "Smelting"       },
	{ spellName = "Cooking",        display = "Cooking"        },
	{ spellName = "First Aid",      display = "First Aid"      },
	{ spellName = "Herbalism",      display = "Herbalism"      },
	{ spellName = "Survival",       display = "Survival"       },
	{ spellName = "Fishing",        display = "Fishing"        },
	{ spellName = "Skinning",       display = "Skinning"       },
}

-- Build a lookup: lowercase spell name → ZCRAFT_PROFESSIONS entry
local ZCRAFT_SPELL_LOOKUP = {}
for i = 1, table.getn(ZCRAFT_PROFESSIONS) do
	ZCRAFT_SPELL_LOOKUP[string.lower(ZCRAFT_PROFESSIONS[i].spellName)] = ZCRAFT_PROFESSIONS[i]
end

function zButtonCraft_GetSaved()
	local currentRoot = zButtonCraft_GetRoot()
	if not currentRoot["zButtonCraft"] then
		currentRoot["zButtonCraft"] = {}
	end
	return currentRoot["zButtonCraft"]
end

local function zButtonCraft_EnsureConfig()
	local saved = zButtonCraft_GetSaved()
	saved["count"] = nil
	if saved["enabled"] == nil then
		saved["enabled"] = 0
	end
	if saved["tooltip"] == nil then
		saved["tooltip"] = 1
	end
	if not saved["children"] then
		saved["children"] = {}
	end
	if saved["children"]["hideonclick"] == nil then
		saved["children"]["hideonclick"] = 1
	end
	if not saved["spells"] then
		saved["spells"] = {}
	end
	if not saved["parent"] then
		saved["parent"] = {}
	end
	if not saved["parent"]["size"] then
		saved["parent"]["size"] = 36
	end
	if saved["parent"]["circle"] == nil then
		saved["parent"]["circle"] = 1
	end
	if not saved["children"]["size"] then
		saved["children"]["size"] = 36
	end
	if not saved["rows"] or saved["rows"] < 1 then
		saved["rows"] = 1
	end
	if not saved["firstbutton"] then
		saved["firstbutton"] = "RIGHT"
	end
end

local function zButtonCraft_ApplyRuntimeSettings()
	if not zButtonCraft then return end
	local saved = zButtonCraft_GetSaved()
	zButtonCraft.tooltip      = saved["tooltip"] and true or false
	zButtonCraft.hideonclick  = saved["children"] and saved["children"]["hideonclick"] and true or false
	zButtonCraft.expandonhover = saved["children"] and saved["children"]["expandonhover"] and true or false
	zButtonCraft.fadetimer    = saved["children"] and tonumber(saved["children"]["fadetimer"]) or 0
end

local function zButtonCraft_GetSpellSignature(spellIds)
	if type(spellIds) ~= "table" or table.getn(spellIds) == 0 then return "" end
	local parts = {}
	for i = 1, table.getn(spellIds) do
		parts[i] = tostring(spellIds[i] or "")
	end
	return table.concat(parts, ",")
end

-- Scans individual spells in the General tab and returns two parallel arrays:
--   spellIds   = spellbook index of each matched craft spell
--   spellNames = display label for that profession
-- Results are ordered by ZCRAFT_PROFESSIONS priority.
local function zButtonCraft_CollectProfessions()
	if type(GetNumSpellTabs) ~= "function" or type(GetSpellTabInfo) ~= "function"
			or type(GetSpellName) ~= "function" then
		return {}, {}
	end
	local bookType = BOOKTYPE_SPELL or "spell"

	-- Find the General tab (always tab 1, but look it up to be safe)
	local generalOffset, generalEntries
	local tabCount = GetNumSpellTabs() or 0
	for tabIndex = 1, tabCount do
		local tabName, _, tabOffset, tabEntries = GetSpellTabInfo(tabIndex)
		if tabName and string.lower(tabName) == "general" then
			generalOffset  = tabOffset
			generalEntries = tabEntries
			break
		end
	end

	if not generalOffset or not generalEntries or generalEntries <= 0 then
		return {}, {}
	end

	-- Scan every spell in General; collect matches keyed by profession order
	local found = {}  -- profession display → spellbook index (first match wins)
	for i = 1, generalEntries do
		local spellIndex = generalOffset + i
		local spellName  = GetSpellName(spellIndex, bookType)
		if spellName then
			local prof = ZCRAFT_SPELL_LOOKUP[string.lower(spellName)]
			if prof and not found[prof.display] then
				found[prof.display] = spellIndex
			end
		end
	end

	-- Return results in ZCRAFT_PROFESSIONS order
	local spellIds   = {}
	local spellNames = {}
	for profIndex = 1, table.getn(ZCRAFT_PROFESSIONS) do
		local prof = ZCRAFT_PROFESSIONS[profIndex]
		local spellIndex = found[prof.display]
		if spellIndex then
			table.insert(spellIds,   spellIndex)
			table.insert(spellNames, prof.display)
		end
	end

	return spellIds, spellNames
end

local function zButtonCraft_ApplySpellIds(spellIds)
	if not zButtonCraft then return 0 end
	local parent     = zButtonCraft
	local childCount = parent.count or ZHUNTER_CRAFT_BUTTON_MAX

	for i = 1, childCount do
		local child = getglobal("zButtonCraft" .. i)
		if child then
			child:Hide()
			child.id      = nil
			child.icon    = nil
			child.isspell = nil
		end
	end

	local found = 0
	for i = 1, table.getn(spellIds) do
		if found >= childCount then break end
		local spellId = spellIds[i]
		if spellId then
			found = found + 1
			local child = getglobal("zButtonCraft" .. found)
			if child then
				child.id      = spellId
				child.isspell = 1
				ZSpellButton_UpdateButton(child)
				child:Show()
			end
		end
	end

	if found > 0 then
		parent.id      = spellIds[1]
		parent.isspell = 1
		ZSpellButton_UpdateButton(parent)
		parent:Enable()
		parent:Show()
	else
		parent.id = nil
		parent:Hide()
	end

	return found
end

local function zButtonCraft_RefreshProfessions()
	if not zButtonCraft then return 0 end
	local saved = zButtonCraft_GetSaved()
	local freshIds, freshNames = zButtonCraft_CollectProfessions()

	-- Build lookup: display name → spellbook index from the fresh scan
	local nameToId = {}
	for i = 1, table.getn(freshNames) do
		nameToId[freshNames[i]] = freshIds[i]
	end

	-- Honour saved user order when it exists
	local existing = saved["spells"]
	if existing and table.getn(existing) > 0 then
		local orderedNames = {}
		local orderedIds   = {}
		local seen = {}
		-- Keep entries that still exist, in the user's order
		for i = 1, table.getn(existing) do
			local name = existing[i]
			if nameToId[name] then
				table.insert(orderedNames, name)
				table.insert(orderedIds, nameToId[name])
				seen[name] = true
			end
		end
		-- Append any newly learned professions at the end
		for i = 1, table.getn(freshNames) do
			if not seen[freshNames[i]] then
				table.insert(orderedNames, freshNames[i])
				table.insert(orderedIds, freshIds[i])
			end
		end
		freshNames = orderedNames
		freshIds   = orderedIds
	end

	saved["spellIds"] = freshIds
	saved["spells"]   = freshNames
	zButtonCraft.spells = freshNames
	zButtonCraft.found  = zButtonCraft_ApplySpellIds(freshIds)
	zButtonCraft_ApplyRuntimeSettings()
	return zButtonCraft.found or 0
end

function zButtonCraft_OnLoad()
	this:RegisterEvent("VARIABLES_LOADED")
end

function zButtonCraft_OnEvent()
	if event == "VARIABLES_LOADED" then
		if not zButtonCraft then return end
		if UnitClass("player") ~= ZHUNTER_HUNTER then
			zButtonCraft:UnregisterAllEvents()
			zButtonCraft:Hide()
			return
		end
		zButtonCraft_CreateButtons()
		MTH_ZH_CraftAdjust = CreateFrame("Frame", "MTH_ZH_CraftAdjust")
		MTH_ZH_CraftAdjust:RegisterEvent("SPELLS_CHANGED")
		MTH_ZH_CraftAdjust:RegisterEvent("PLAYER_ENTERING_WORLD")
		MTH_ZH_CraftAdjust:SetScript("OnEvent", MTH_ZH_CraftAdjust_OnEvent)
		zButtonCraft_SetupSizeAndPosition()
	end
end

function zButtonCraft_CreateButtons()
	zButtonCraft_EnsureConfig()
	if not zButtonCraft._mthChildrenCreated then
		ZSpellButton_CreateChildren(zButtonCraft, "zButtonCraft", ZHUNTER_CRAFT_BUTTON_MAX)
		zButtonCraft._mthChildrenCreated = 1
	end
	zButtonCraft_RefreshProfessions()
end

function zButtonCraft_SetupSizeAndPosition()
	local saved = zButtonCraft_GetSaved()
	if saved["enabled"] == false or saved["enabled"] == 0 then
		if MTH_ZH_CraftAdjust then
			MTH_ZH_CraftAdjust:UnregisterAllEvents()
			MTH_ZH_CraftAdjust:SetScript("OnEvent", nil)
		end
		if zButtonCraft and zButtonCraft.Hide then
			zButtonCraft:Hide()
		end
		return
	end
	if MTH_ZH_CraftAdjust then
		MTH_ZH_CraftAdjust:RegisterEvent("SPELLS_CHANGED")
		MTH_ZH_CraftAdjust:RegisterEvent("PLAYER_ENTERING_WORLD")
		MTH_ZH_CraftAdjust:SetScript("OnEvent", MTH_ZH_CraftAdjust_OnEvent)
	end
	local displayCount = zButtonCraft.found or 0
	if displayCount < 0 then displayCount = 0 end
	if not (type(MTH_ZBar_ApplyToButton) == "function" and MTH_ZBar_ApplyToButton(zButtonCraft, displayCount)) then
		ZSpellButton_SetSize(zButtonCraft, saved["parent"]["size"])
		ZSpellButton_SetSize(zButtonCraft, saved["children"]["size"], 1)
		ZSpellButton_SetExpandDirection(zButtonCraft, saved["firstbutton"])
		ZSpellButton_ArrangeChildren(zButtonCraft, saved["rows"],
			displayCount, saved["horizontal"], saved["vertical"])
	end
end

function zButtonCraft_Reset()
	local currentRoot = zButtonCraft_GetRoot()
	currentRoot["zButtonCraft"] = {}
	local saved = zButtonCraft_GetSaved()
	saved["spells"]                  = {}
	saved["rows"]                    = 1
	saved["horizontal"]              = nil
	saved["vertical"]                = nil
	saved["firstbutton"]             = "RIGHT"
	saved["enabled"]                 = 1
	saved["tooltip"]                 = 1
	saved["parent"]                  = {}
	saved["parent"]["size"]          = 36
	saved["parent"]["hide"]          = nil
	saved["parent"]["circle"]        = 1
	saved["children"]                = {}
	saved["children"]["size"]        = 36
	saved["children"]["hideonclick"] = 1
	zButtonCraft_EnsureConfig()
end

function MTH_ZH_CraftAdjust_OnEvent()
	if not zButtonCraft then return end
	if event == "SPELLS_CHANGED" then
		local now = GetTime and GetTime() or 0
		if now > 0 and zButtonCraft_LastRefreshAt > 0 and (now - zButtonCraft_LastRefreshAt) < zButtonCraft_MinRefreshInterval then
			return
		end
		local spellIds, _ = zButtonCraft_CollectProfessions()
		local signature   = zButtonCraft_GetSpellSignature(spellIds)
		if signature == zButtonCraft_LastSpellSignature and not GameTooltip:IsOwned(zButtonCraft) then
			return
		end
		zButtonCraft_LastSpellSignature = signature
		zButtonCraft_LastRefreshAt      = now
	end
	zButtonCraft_RefreshProfessions()
	zButtonCraft_SetupSizeAndPosition()
	if GameTooltip:IsOwned(zButtonCraft) then
		ZSpellButtonParent_OnEnter(zButtonCraft)
	end
end

function zButtonCraft_KeyBinding(index)
	if MTH_ZH_IsModuleEnabled and not MTH_ZH_IsModuleEnabled() then return end
	local button
	if index then
		button = getglobal("zButtonCraft" .. index)
	else
		button = zButtonCraft
	end
	if button and button.id then
		CastSpell(button.id, "spell")
		if zButtonCraft.hideonclick then
			if type(ZSpellButton_SetChildrenExpanded) == "function" then
				ZSpellButton_SetChildrenExpanded(zButtonCraft, false)
			elseif zButtonCraft.children then
				zButtonCraft.children:Hide()
			end
		end
	end
end

SLASH_zButtonCraft1 = "/ZCraft"
SlashCmdList["zButtonCraft"] = function(msg)
	if MTH_ZH_HandleDisabledSlash and MTH_ZH_HandleDisabledSlash("Craft button is disabled while module 'zhunter' is disabled.") then
		return
	end
	if msg == "reset" then
		zButtonCraft_Reset()
		zButtonCraft:ClearAllPoints()
		zButtonCraft:SetPoint("TOP", UIParent, "TOP", 0, -558)
		zButtonCraft_RefreshProfessions()
		zButtonCraft_SetupSizeAndPosition()
	else
		MTH_ZH_Print("Possible Commands: \"reset\"")
	end
end
