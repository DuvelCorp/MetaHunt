------------------------------------------------------
-- MetaHunt Profile System
-- Captures:
--   MTH_SavedVariables.modules        (account-wide option values, e.g. feedomatic)
--   MTH_CharSavedVariables.modules    (per-char option values: ICU, Chronometer,
--                                      AutoBuy, AutoQuest, SmartAmmo, tooltips...)
--   MTH_CharSavedVariables.moduleStates (enabled/disabled per char)
--   ZHunterMod_Saved / MTH_CharSavedVariables.modules.zhunter (zButtons layout)
-- Auto-snapshots current character on PLAYER_LOGOUT into
--   MTH_SavedVariables.charSnapshots["CharName-RealmName"]
------------------------------------------------------

local function MTH_Profile_DeepCopy(orig)
	if type(orig) ~= "table" then return orig end
	local copy = {}
	for k, v in orig do
		copy[MTH_Profile_DeepCopy(k)] = MTH_Profile_DeepCopy(v)
	end
	return copy
end

-- Shallow-copy a module's saved data, skipping keys that hold large operational
-- blobs (e.g. feedomatic's "legacy" table which mirrors FOM_Cooking, FOM_QuestFood
-- etc.) — those are runtime migration artifacts, not user configuration settings.
local MTH_PROFILE_SKIP_KEYS = { legacy = true, history = true }

local function MTH_Profile_CopyModules(src)
	if type(src) ~= "table" then return {} end
	local out = {}
	for modName, modData in src do
		if type(modData) == "table" then
			local modCopy = {}
			for k, v in modData do
				if not MTH_PROFILE_SKIP_KEYS[k] then
					modCopy[MTH_Profile_DeepCopy(k)] = MTH_Profile_DeepCopy(v)
				end
			end
			out[modName] = modCopy
		else
			out[modName] = modData
		end
	end
	return out
end

local function MTH_Profile_EnsureStore()
	if type(MTH_SavedVariables) ~= "table" then
		MTH_SavedVariables = {}
	end
	if type(MTH_SavedVariables.profiles) ~= "table" then
		MTH_SavedVariables.profiles = {}
	end
	if type(MTH_SavedVariables.charSnapshots) ~= "table" then
		MTH_SavedVariables.charSnapshots = {}
	end
end

local function MTH_Profile_GetCharKey()
	local name  = (type(UnitName)    == "function") and UnitName("player") or "Unknown"
	local realm = (type(GetRealmName) == "function") and GetRealmName()     or "Unknown"
	name  = (name  and name  ~= "") and name  or "Unknown"
	realm = (realm and realm ~= "") and realm or "Unknown"
	return name .. "-" .. realm
end

local function MTH_Profile_BuildSnapshot()
	local snap    = {}
	snap.savedBy  = MTH_Profile_GetCharKey()
	snap.savedAt  = (type(date) == "function") and date("%Y-%m-%d %H:%M") or ""

	-- Account-wide module option values (e.g. feedomatic)
	snap.config = (type(MTH_SavedVariables) == "table"
		and type(MTH_SavedVariables.modules) == "table")
		and MTH_Profile_CopyModules(MTH_SavedVariables.modules)
		or {}

	-- Per-character module option values (ICU, Chronometer, AutoBuy, SmartAmmo, etc.)
	snap.charConfig = (type(MTH_CharSavedVariables) == "table"
		and type(MTH_CharSavedVariables.modules) == "table")
		and MTH_Profile_CopyModules(MTH_CharSavedVariables.modules)
		or {}

	-- Per-character module enabled/disabled states
	snap.moduleStates = (type(MTH_CharSavedVariables) == "table"
		and type(MTH_CharSavedVariables.moduleStates) == "table")
		and MTH_Profile_DeepCopy(MTH_CharSavedVariables.moduleStates)
		or {}

	-- zButtons config — kept as dedicated key for clarity
	-- (also lives in charConfig.zhunter but we keep it explicit)
	local zh = nil
	if type(MTH_CharSavedVariables) == "table"
		and type(MTH_CharSavedVariables.modules) == "table"
		and type(MTH_CharSavedVariables.modules.zhunter) == "table"
	then
		zh = MTH_CharSavedVariables.modules.zhunter
	elseif type(ZHunterMod_Saved) == "table" then
		zh = ZHunterMod_Saved
	end
	snap.zhunter = zh and MTH_Profile_DeepCopy(zh) or {}

	return snap
end

-- Save current settings as a named profile
function MTH_Profile_Save(name)
	if type(name) ~= "string" or string.len(name) == 0 then
		return false, "invalid name"
	end
	MTH_Profile_EnsureStore()
	MTH_SavedVariables.profiles[name] = MTH_Profile_BuildSnapshot()
	return true
end

-- Delete a named profile
function MTH_Profile_Delete(name)
	MTH_Profile_EnsureStore()
	if MTH_SavedVariables.profiles[name] == nil then return false end
	MTH_SavedVariables.profiles[name] = nil
	if type(MTH_CharSavedVariables) == "table"
		and MTH_CharSavedVariables.activeProfile == name
	then
		MTH_CharSavedVariables.activeProfile = nil
	end
	return true
end

-- Apply a profile to SavedVariables; a /reload is required for changes to take full effect
function MTH_Profile_Load(name)
	MTH_Profile_EnsureStore()
	local p = MTH_SavedVariables.profiles[name]
	if type(p) ~= "table" then return false, "profile not found" end

	if type(MTH_CharSavedVariables) ~= "table" then MTH_CharSavedVariables = {} end
	if type(MTH_CharSavedVariables.modules) ~= "table" then MTH_CharSavedVariables.modules = {} end

	-- Apply account-wide module option values (e.g. feedomatic)
	if type(p.config) == "table" then
		if type(MTH_SavedVariables.modules) ~= "table" then
			MTH_SavedVariables.modules = {}
		end
		for modName, modData in p.config do
			MTH_SavedVariables.modules[modName] = MTH_Profile_DeepCopy(modData)
		end
	end

	-- Apply per-character module option values (ICU, Chronometer, AutoBuy, SmartAmmo, etc.)
	if type(p.charConfig) == "table" then
		for modName, modData in p.charConfig do
			MTH_CharSavedVariables.modules[modName] = MTH_Profile_DeepCopy(modData)
		end
	end

	-- Apply module enabled/disabled
	if type(p.moduleStates) == "table" then
		if type(MTH_CharSavedVariables.moduleStates) ~= "table" then
			MTH_CharSavedVariables.moduleStates = {}
		end
		for k, v in p.moduleStates do
			MTH_CharSavedVariables.moduleStates[k] = v
		end
	end

	-- Apply zButtons (also written into charConfig.zhunter above, but keep explicit)
	if type(p.zhunter) == "table" then
		ZHunterMod_Saved = MTH_Profile_DeepCopy(p.zhunter)
		MTH_CharSavedVariables.modules.zhunter = ZHunterMod_Saved
	end

	MTH_CharSavedVariables.activeProfile = name
	return true
end

-- Create a named profile from another character's auto-snapshot
-- profileName defaults to charKey if not provided
function MTH_Profile_CopyFromChar(charKey, profileName)
	MTH_Profile_EnsureStore()
	local snap = MTH_SavedVariables.charSnapshots[charKey]
	if type(snap) ~= "table" then
		return false, "no snapshot for " .. tostring(charKey)
	end
	local name = (type(profileName) == "string" and string.len(profileName) > 0)
		and profileName or charKey
	MTH_SavedVariables.profiles[name] = MTH_Profile_DeepCopy(snap)
	return true, name
end

-- Return sorted list of profile names
function MTH_Profile_GetList()
	MTH_Profile_EnsureStore()
	local list = {}
	for name, _ in MTH_SavedVariables.profiles do
		table.insert(list, name)
	end
	table.sort(list)
	return list
end

-- Return sorted list of character snapshot keys
function MTH_Profile_GetCharList()
	MTH_Profile_EnsureStore()
	local list = {}
	for charKey, _ in MTH_SavedVariables.charSnapshots do
		table.insert(list, charKey)
	end
	table.sort(list)
	return list
end

-- Return the active profile name for the current character, or nil
function MTH_Profile_GetActive()
	if type(MTH_CharSavedVariables) == "table" then
		return MTH_CharSavedVariables.activeProfile
	end
	return nil
end

-- Auto-snapshot on logout so other characters can import this config
local MTH_ProfileEventFrame = CreateFrame("Frame", "MTH_ProfileEventFrame")
MTH_ProfileEventFrame:RegisterEvent("PLAYER_LOGOUT")
MTH_ProfileEventFrame:SetScript("OnEvent", function()
	if event == "PLAYER_LOGOUT" then
		MTH_Profile_EnsureStore()
		MTH_SavedVariables.charSnapshots[MTH_Profile_GetCharKey()] = MTH_Profile_BuildSnapshot()
	end
end)
