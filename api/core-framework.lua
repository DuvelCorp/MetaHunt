MTH = MTH or {
	version = "1.2.0",
	name = "MetaHunt",
	modules = {},
	config = {},
	debug = false,
}

local MTH_CHAT_PREFIX = "|cFFFFFFFF[|r|cFFD14A4AMeta|r|cFFABD473Hunt|r|cFFFFFFFF]|r "
local MTH_NON_HUNTER_BLOCK_MESSAGE = "You are not a hunter and you are not allowed here. Disable the add-on for this character."
local MTH_MESSAGE_DEFAULTS = {
	initModulesLoaded = false,
	initSarcasticWelcome = true,
	petHungry = false,
	beastTrainingScan = true,
	spellbookScan = false,
	petRanAway = true,
	mapMarkers = true,
	stableScan = true,
}

local MTH_MODULE_DEFAULT_STATES = {
	autoquest = false,
	autobuy = false,
	feedomatic = false,
	icu = false,
}

local function MTH_ClassGateTrace(_step, _detail)
	return
end

local function MTH_ClassGateClearAnnounceFrame(self)
	if not self or not self._classGateAnnounceFrame then
		return
	end
	self._classGateAnnounceFrame:UnregisterAllEvents()
	self._classGateAnnounceFrame:SetScript("OnEvent", nil)
	self._classGateAnnounceFrame:SetScript("OnUpdate", nil)
	self._classGateAnnounceFrame = nil
end

local function MTH_ClassGateEnsureAnnounceFrame(self)
	if not self or self._classGateAnnounceFrame then
		return
	end
	local frame = CreateFrame("Frame", "MTH_ClassGateAnnounce")
	if not frame then
		return
	end
	frame:RegisterEvent("PLAYER_ENTERING_WORLD")
	frame:SetScript("OnEvent", function()
		if MTH and MTH.AnnounceClassGateBlocked then
			MTH:AnnounceClassGateBlocked()
		end
	end)
	frame._mthElapsed = 0
	frame:SetScript("OnUpdate", function()
		this._mthElapsed = (this._mthElapsed or 0) + (arg1 or 0)
		if this._mthElapsed < 0.5 then
			return
		end
		this._mthElapsed = 0
		if MTH and MTH._classGateAnnouncedChat then
			MTH_ClassGateClearAnnounceFrame(MTH)
			return
		end
		if MTH and MTH._classGateAnnouncePending and MTH.AnnounceClassGateBlocked then
			MTH:AnnounceClassGateBlocked()
		end
	end)
	self._classGateAnnounceFrame = frame
end

local function MTH_TryOutputClassGateMessage(text)
	local msg = tostring(text or "")
	if msg == "" then
		return nil
	end

	local formattedMsg = MTH_CHAT_PREFIX .. msg
	if MTH and MTH.Log and DEFAULT_CHAT_FRAME and DEFAULT_CHAT_FRAME.AddMessage then
		MTH:Log(msg)
		return "chat"
	end

	local shown = false
	local sink = nil
	local function tryFrame(frame)
		if frame and frame.AddMessage then
			frame:AddMessage(formattedMsg, 1, 0.25, 0.25)
			shown = true
			sink = "chat"
		end
	end

	tryFrame(DEFAULT_CHAT_FRAME)
	if not shown and type(getglobal) == "function" then
		tryFrame(getglobal("ChatFrame1"))
		if not shown then
			for i = 2, 7 do
				tryFrame(getglobal("ChatFrame" .. tostring(i)))
				if shown then break end
			end
		end
	end

	if not shown and _G then
		tryFrame(_G["ChatFrame1"])
		if not shown then
			for i = 2, 7 do
				tryFrame(_G["ChatFrame" .. tostring(i)])
				if shown then break end
			end
		end
	end

	if shown then
		return sink
	end

	if UIErrorsFrame and UIErrorsFrame.AddMessage then
		UIErrorsFrame:AddMessage(formattedMsg, 1, 0.25, 0.25, 1.0)
		return "uierrors"
	end

	if type(print) == "function" then
		print(formattedMsg)
		return "print"
	end

	return nil
end

function MTH:IsClassGateBlocked()
	return self and self._classGateBlocked and true or false
end

function MTH:IsHardBlocked()
	return self and self._hardBlocked and true or false
end

function MTH:CheckClassGate()
	if type(UnitClass) ~= "function" then
		return self:IsClassGateBlocked()
	end

	local className, classToken = UnitClass("player")
	if type(classToken) == "string" and classToken ~= "" then
		self._playerClassToken = classToken
		self._classGateBlocked = classToken ~= "HUNTER"
	end

	return self:IsClassGateBlocked()
end

function MTH:AnnounceClassGateBlocked()
	if self._classGateAnnouncedChat then
		return
	end

	if type(IsLoggedIn) == "function" and not IsLoggedIn() then
		self._classGateAnnouncePending = true
		MTH_ClassGateEnsureAnnounceFrame(self)
		return
	end

	local sink = MTH_TryOutputClassGateMessage(MTH_NON_HUNTER_BLOCK_MESSAGE)
	if sink == "chat" or sink == "uierrors" then
		self._classGateAnnouncedChat = true
		self._classGateAnnounced = true
		self._classGateAnnouncePending = nil
		MTH_ClassGateClearAnnounceFrame(self)
		return
	end

	self._classGateAnnouncePending = true
	MTH_ClassGateEnsureAnnounceFrame(self)
end

function MTH:ApplyClassGate(_source)
	local blocked = self:CheckClassGate()
	if blocked then
		self:AnnounceClassGateBlocked()
		if self.ShutdownForNonHunter then
			self:ShutdownForNonHunter(_source or "class-gate")
		end
	end
	return blocked
end

MTH:ApplyClassGate("startup")

if not MTH._classGateLifecycleFrame then
	local classGateFrame = CreateFrame("Frame", "MTH_ClassGateLifecycle")
	if classGateFrame then
		classGateFrame:RegisterEvent("PLAYER_LOGIN")
		classGateFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
		classGateFrame:SetScript("OnEvent", function()
			if MTH and event == "PLAYER_LOGIN" then
				MTH._classGateAnnouncedChat = nil
				MTH._classGateAnnounced = nil
				MTH._classGateAnnouncePending = nil
			end
			if MTH and MTH.ApplyClassGate and MTH:ApplyClassGate(event) and MTH._classGateAnnouncedChat then
				this:UnregisterAllEvents()
				this:SetScript("OnEvent", nil)
			end
		end)
		MTH._classGateLifecycleFrame = classGateFrame
	end
end

MTH.Const = MTH.Const or {}
if type(MTH.Const.SlashAliases) ~= "table" then
	MTH.Const.SlashAliases = { "/mth", "/metahunt" }
end

if not ITEM_QUALITY_COLORS then
	ITEM_QUALITY_COLORS = {
		[0] = { r = 0.62, g = 0.62, b = 0.62 },
		[1] = { r = 1.00, g = 1.00, b = 1.00 },
		[2] = { r = 0.12, g = 1.00, b = 0.00 },
		[3] = { r = 0.00, g = 0.44, b = 0.87 },
		[4] = { r = 0.64, g = 0.21, b = 0.93 },
		[5] = { r = 1.00, g = 0.50, b = 0.00 },
	}
end

MTH_ITEM_QUALITY_COLORS = ITEM_QUALITY_COLORS

function MTH:RegisterSlashAliases(key, aliases)
	if type(key) ~= "string" or key == "" then
		return
	end

	if type(aliases) ~= "table" then
		aliases = self.Const and self.Const.SlashAliases or nil
	end
	if type(aliases) ~= "table" then
		return
	end

	for i = 1, table.getn(aliases) do
		local alias = aliases[i]
		if type(alias) == "string" and alias ~= "" then
			_G["SLASH_" .. key .. i] = alias
		end
	end
end

if type(SlashCmdList) ~= "table" then
	SlashCmdList = {}
end

if type(MTH_SavedVariables) ~= "table" then
	MTH_SavedVariables = {}
end
if type(MTH_SavedVariables.modules) ~= "table" then
	MTH_SavedVariables.modules = {}
end
if type(MTH_CharSavedVariables) ~= "table" then
	MTH_CharSavedVariables = {}
end
if type(MTH_CharSavedVariables.modules) ~= "table" then
	MTH_CharSavedVariables.modules = {}
end

local function MTH_ModuleStateDebug(message)
	local text = "[MODULE STATE] " .. tostring(message or "")
	if MTH and MTH.debug and MTH.Log then
		MTH:Log(text, "debug")
	elseif MTH and MTH.debug and MTH.Print then
		MTH:Print(text, "debug")
	end
end

local function MTH_IsPetUiFrameName(frameName)
	local name = tostring(frameName or "")
	if name == "" then
		return false
	end
	return (
		string.find(name, "PetFrame", 1, true)
		or string.find(name, "PetName", 1, true)
		or string.find(name, "PetActionButton", 1, true)
		or string.find(name, "PetActionBar", 1, true)
		or string.find(name, "PetBar", 1, true)
		or string.find(name, "PetButton", 1, true)
		or string.find(name, "ShaguPet", 1, true)
		or string.find(name, "pfPet", 1, true)
		or string.find(name, "DominosActionButton", 1, true)
		or string.find(name, "BT4PetButton", 1, true)
		or string.find(name, "DominosPet", 1, true)
	) and true or false
end

local function MTH_DetectPetUiFromFrameChain(frame)
	local state = {
		matched = false,
		matchedFrameName = nil,
	}
	local current = frame
	local depth = 0
	while current and depth < 6 do
		local frameName = (type(current.GetName) == "function") and current:GetName() or ""
		if MTH_IsPetUiFrameName(frameName) then
			state.matched = true
			state.matchedFrameName = tostring(frameName or "")
			return state
		end
		if type(current.GetParent) == "function" then
			current = current:GetParent()
		else
			current = nil
		end
		depth = depth + 1
	end
	return state
end

function MTH_IsMouseoverOwnPet()
	if type(UnitClass) == "function" then
		local _, classToken = UnitClass("player")
		if tostring(classToken or "") ~= "HUNTER" then
			return false
		end
	end

	if type(UnitExists) == "function" and type(UnitIsUnit) == "function" then
		if UnitExists("pet") and UnitExists("mouseover") then
			local ok, sameUnit = pcall(UnitIsUnit, "mouseover", "pet")
			if ok and sameUnit then
				return true
			end
		end
	end

	if GameTooltip and type(GameTooltip.GetOwner) == "function" then
		local owner = GameTooltip:GetOwner()
		local tooltipCheck = MTH_DetectPetUiFromFrameChain(owner)
		if tooltipCheck and tooltipCheck.matched then
			return true
		end
	end

	local getMouseFocus = (_G and _G["GetMouseFocus"]) or nil
	if type(getMouseFocus) ~= "function" then
		return false
	end

	local focus = getMouseFocus()
	local focusCheck = MTH_DetectPetUiFromFrameChain(focus)
	return focusCheck and focusCheck.matched and true or false
end

function MTH_GetMouseoverOwnPetState()
	local state = {
		isHunter = false,
		hasPet = false,
		mouseoverIsPetUnit = false,
		mouseoverIsPetFrame = false,
		matchedFrameName = nil,
		detected = false,
	}

	if type(UnitClass) == "function" then
		local _, classToken = UnitClass("player")
		state.isHunter = tostring(classToken or "") == "HUNTER"
	else
		state.isHunter = true
	end

	if type(UnitExists) == "function" then
		state.hasPet = UnitExists("pet") and true or false
	end

	if type(UnitExists) == "function" and type(UnitIsUnit) == "function" then
		if UnitExists("pet") and UnitExists("mouseover") then
			local ok, sameUnit = pcall(UnitIsUnit, "mouseover", "pet")
			state.mouseoverIsPetUnit = ok and sameUnit and true or false
		end
	end

	local getMouseFocus = (_G and _G["GetMouseFocus"]) or nil
	if type(getMouseFocus) == "function" then
		local focus = getMouseFocus()
		local focusCheck = MTH_DetectPetUiFromFrameChain(focus)
		if focusCheck and focusCheck.matched then
			state.mouseoverIsPetFrame = true
			state.matchedFrameName = focusCheck.matchedFrameName
		end
	end

	if not state.mouseoverIsPetFrame and GameTooltip and type(GameTooltip.GetOwner) == "function" then
		local owner = GameTooltip:GetOwner()
		local tooltipCheck = MTH_DetectPetUiFromFrameChain(owner)
		if tooltipCheck and tooltipCheck.matched then
			state.mouseoverIsPetFrame = true
			state.matchedFrameName = tooltipCheck.matchedFrameName
		end
	end

	state.detected = state.isHunter and (state.mouseoverIsPetUnit or state.mouseoverIsPetFrame) and true or false
	return state
end

local function MTH_NormalizeModuleName(name)
	if type(name) ~= "string" then
		return name
	end
	local lowered = string.lower(name)
	if lowered == "zhunter" then
		return "zhunter"
	end
	return name
end

local function MTH_ModuleNameCandidates(name)
	local normalized = MTH_NormalizeModuleName(name)
	return { normalized }
end

local function MTH_GetPersistedModuleEnabled(name, defaultEnabled)
	if type(name) ~= "string" or name == "" then
		MTH_ModuleStateDebug("read <invalid-name> fallback-default=" .. tostring(defaultEnabled and true or false))
		return defaultEnabled and true or false
	end

	local resolvedName = MTH_NormalizeModuleName(name)
	local candidates = MTH_ModuleNameCandidates(name)

	if type(MTH_CharSavedVariables) ~= "table" then
		MTH_CharSavedVariables = {}
	end
	if type(MTH_CharSavedVariables.moduleStates) ~= "table" then
		MTH_CharSavedVariables.moduleStates = {}
	end
	if type(MTH_CharSavedVariables.modules) ~= "table" then
		MTH_CharSavedVariables.modules = {}
	end
	if type(MTH_CharSavedVariables.modules[resolvedName]) ~= "table" then
		MTH_CharSavedVariables.modules[resolvedName] = {}
	end

	if type(MTH_SavedVariables) ~= "table" then
		MTH_SavedVariables = {}
	end
	if type(MTH_SavedVariables.moduleStates) ~= "table" then
		MTH_SavedVariables.moduleStates = {}
	end
	if type(MTH_SavedVariables.modules) ~= "table" then
		MTH_SavedVariables.modules = {}
	end

	local hardDefault = MTH_MODULE_DEFAULT_STATES[resolvedName]
	if hardDefault ~= nil then
		local hasCharState = MTH_CharSavedVariables.moduleStates[resolvedName] ~= nil
			or MTH_CharSavedVariables.modules[resolvedName].enabled ~= nil
		if not hasCharState then
			local resolved = hardDefault and true or false
			MTH_CharSavedVariables.moduleStates[resolvedName] = resolved
			MTH_CharSavedVariables.modules[resolvedName].enabled = resolved
			MTH_ModuleStateDebug("read " .. tostring(name) .. " seeded char default=" .. tostring(resolved))
			return resolved
		end
	end

	if type(MTH_CharSavedVariables.moduleStates) == "table"
		then
		for i = 1, table.getn(candidates) do
			local key = candidates[i]
			if MTH_CharSavedVariables.moduleStates[key] ~= nil then
				local resolved = MTH_CharSavedVariables.moduleStates[key] and true or false
				MTH_ModuleStateDebug("read " .. tostring(name) .. " from char.moduleStates." .. tostring(key) .. "=" .. tostring(resolved))
				MTH_CharSavedVariables.moduleStates[resolvedName] = resolved
				return resolved
			end
		end
	end

	if type(MTH_SavedVariables.moduleStates) == "table" then
		for i = 1, table.getn(candidates) do
			local key = candidates[i]
			if MTH_SavedVariables.moduleStates[key] ~= nil then
				local resolved = MTH_SavedVariables.moduleStates[key] and true or false
				MTH_ModuleStateDebug("read " .. tostring(name) .. " from moduleStates." .. tostring(key) .. "=" .. tostring(resolved))
				MTH_CharSavedVariables.moduleStates[resolvedName] = resolved
				if type(MTH_CharSavedVariables.modules[resolvedName]) ~= "table" then
					MTH_CharSavedVariables.modules[resolvedName] = {}
				end
				MTH_CharSavedVariables.modules[resolvedName].enabled = resolved
				return resolved
			end
		end
	end

	if type(MTH_SavedVariables.modules) == "table" then
		for i = 1, table.getn(candidates) do
			local key = candidates[i]
			if type(MTH_SavedVariables.modules[key]) == "table" and MTH_SavedVariables.modules[key].enabled ~= nil then
				local resolved = MTH_SavedVariables.modules[key].enabled and true or false
				MTH_ModuleStateDebug("read " .. tostring(name) .. " from modules." .. tostring(key) .. ".enabled=" .. tostring(resolved))
				MTH_CharSavedVariables.moduleStates[resolvedName] = resolved
				if type(MTH_CharSavedVariables.modules[resolvedName]) ~= "table" then
					MTH_CharSavedVariables.modules[resolvedName] = {}
				end
				MTH_CharSavedVariables.modules[resolvedName].enabled = resolved
				return resolved
			end
		end
	end

	for i = 1, table.getn(candidates) do
		local key = candidates[i]
		if type(MTH_SavedVariables[key]) == "table" and MTH_SavedVariables[key].enabled ~= nil then
			local resolved = MTH_SavedVariables[key].enabled and true or false
			MTH_ModuleStateDebug("read " .. tostring(name) .. " from legacy-top-level." .. tostring(key) .. ".enabled=" .. tostring(resolved))
			MTH_CharSavedVariables.moduleStates[resolvedName] = resolved
			if type(MTH_CharSavedVariables.modules[resolvedName]) ~= "table" then
				MTH_CharSavedVariables.modules[resolvedName] = {}
			end
			MTH_CharSavedVariables.modules[resolvedName].enabled = resolved
			return resolved
		end
	end

	MTH_ModuleStateDebug("read " .. tostring(name) .. " no-persisted-value fallback-default=" .. tostring(defaultEnabled and true or false))
	return defaultEnabled and true or false
end

local function MTH_SetPersistedModuleEnabled(name, enabled)
	if type(name) ~= "string" or name == "" then
		return
	end

	name = MTH_NormalizeModuleName(name)

	if type(MTH_SavedVariables) ~= "table" then
		MTH_SavedVariables = {}
	end
	if type(MTH_CharSavedVariables) ~= "table" then
		MTH_CharSavedVariables = {}
	end
	if type(MTH_CharSavedVariables.moduleStates) ~= "table" then
		MTH_CharSavedVariables.moduleStates = {}
	end
	if type(MTH_CharSavedVariables.modules) ~= "table" then
		MTH_CharSavedVariables.modules = {}
	end
	if type(MTH_CharSavedVariables.modules[name]) ~= "table" then
		MTH_CharSavedVariables.modules[name] = {}
	end

	enabled = enabled and true or false
	MTH_CharSavedVariables.moduleStates[name] = enabled
	MTH_CharSavedVariables.modules[name].enabled = enabled
	MTH_ModuleStateDebug("write " .. tostring(name) .. " enabled=" .. tostring(enabled))
end

function MTH:InitEventRouter()
	if self._eventRouter and self._eventRouter.frame then
		return self._eventRouter.frame
	end

	local frame = CreateFrame("Frame", "MTH_EventRouter")
	frame:SetScript("OnEvent", function()
		if MTH and MTH.DispatchEvent then
			MTH:DispatchEvent(event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9)
		end
	end)

	self._eventRouter = {
		frame = frame,
		eventRefs = {},
	}

	return frame
end

function MTH:RegisterModuleEvents(name, events)
	local module = self.modules[name]
	if not module then
		return false, "module not registered"
	end

	local eventSet = {}
	if type(events) == "table" then
		for key, value in pairs(events) do
			if type(key) == "number" and type(value) == "string" and value ~= "" then
				eventSet[value] = true
			elseif type(key) == "string" and value then
				eventSet[key] = true
			end
		end
	end

	module._mth_eventSet = eventSet
	return true
end

function MTH:_SetModuleEventSubscriptions(name, enabled)
	local module = self.modules[name]
	if not module or not module._mth_eventSet then
		return
	end

	local frame = self:InitEventRouter()
	local refs = self._eventRouter.eventRefs

	for evt in pairs(module._mth_eventSet) do
		if enabled then
			refs[evt] = (refs[evt] or 0) + 1
			if refs[evt] == 1 then
				frame:RegisterEvent(evt)
			end
		else
			if refs[evt] and refs[evt] > 0 then
				refs[evt] = refs[evt] - 1
				if refs[evt] <= 0 then
					refs[evt] = nil
					frame:UnregisterEvent(evt)
				end
			end
		end
	end
end

function MTH:DispatchEvent(evt, ea1, ea2, ea3, ea4, ea5, ea6, ea7, ea8, ea9)
	for name, module in pairs(self.modules) do
		if module.enabled and module.onEvent then
			local allow = true
			if module._mth_eventSet then
				allow = module._mth_eventSet[evt] and true or false
			end
			if allow then
				local ok, err = pcall(function()
					module:onEvent(evt, ea1, ea2, ea3, ea4, ea5, ea6, ea7, ea8, ea9)
				end)
				if not ok then
					MTH:Print("Module '" .. name .. "' event error on '" .. tostring(evt) .. "': " .. tostring(err), "error")
				end
			end
		end
	end
end

function MTH:RegisterModule(name, module)
	if self:IsHardBlocked() then
		self:AnnounceClassGateBlocked()
		return false
	end

	MTH_ClassGateTrace("RegisterModule enter", "name=" .. tostring(name) .. " blocked=" .. tostring(self:IsClassGateBlocked()))
	if self:IsClassGateBlocked() then
		MTH_ClassGateTrace("RegisterModule blocked", "name=" .. tostring(name))
		self:AnnounceClassGateBlocked()
		return false
	end

	if type(name) ~= "string" or name == "" then
		self:Print("Cannot register module: invalid module name")
		return false
	end

	if type(module) ~= "table" then
		self:Print("Cannot register module '" .. name .. "': module must be a table")
		return false
	end

	if self.modules[name] then
		if self.debug then print("|cFFFFAA00MetaHunt|r: Module '" .. name .. "' already registered") end
		return false
	end

	module.name = module.name or name
	module._mth_initialized = false

	local defaultEnabled = true
	if module.enabled ~= nil then
		defaultEnabled = module.enabled and true or false
	end
	module._mth_defaultEnabled = defaultEnabled

	local initialEnabled = MTH_GetPersistedModuleEnabled(name, defaultEnabled)
	module.enabled = initialEnabled and true or false
	MTH_ModuleStateDebug("register " .. tostring(name) .. " default=" .. tostring(defaultEnabled) .. " initial=" .. tostring(module.enabled))

	self.modules[name] = module
	self:RegisterModuleEvents(name, module.events)

	if module.init and type(module.init) == "function" then
		MTH_ClassGateTrace("RegisterModule init begin", "name=" .. tostring(name))
		local ok, err = pcall(function()
			module:init()
		end)
		if not ok then
			MTH_ClassGateTrace("RegisterModule init failed", "name=" .. tostring(name) .. " err=" .. tostring(err))
			module.enabled = false
			self:Print("Module '" .. name .. "' init failed: " .. tostring(err))
			MTH:Print("[MTH] Module init failed (" .. name .. "): " .. tostring(err), "error")
			return false
		end
		MTH_ClassGateTrace("RegisterModule init end", "name=" .. tostring(name))
		module._mth_initialized = true
	end

	if module.enabled then
		self:_SetModuleEventSubscriptions(name, true)
	end

	if self.debug then print("|cFF00AA00MetaHunt|r: Module '" .. name .. "' registered") end
	return true
end

function MTH:GetModule(name)
	name = MTH_NormalizeModuleName(name)
	return self.modules[name]
end

function MTH:IsModuleEnabled(name, defaultEnabled)
	if self:IsHardBlocked() then
		return false
	end

	if self:IsClassGateBlocked() then
		return false
	end

	if defaultEnabled == nil then
		defaultEnabled = true
	end

	if type(name) ~= "string" or name == "" then
		return defaultEnabled and true or false
	end

	name = MTH_NormalizeModuleName(name)

	local module = self:GetModule(name)
	if not module then
		return defaultEnabled and true or false
	end

	return module.enabled and true or false
end

function MTH:SetModuleEnabled(name, enabled)
	if self:IsHardBlocked() then
		if enabled then
			self:AnnounceClassGateBlocked()
			return false, "Class gate blocked"
		end
		return true
	end

	if self:IsClassGateBlocked() then
		if enabled then
			self:AnnounceClassGateBlocked()
			return false, "Class gate blocked"
		end
		return true
	end

	name = MTH_NormalizeModuleName(name)
	local module = self:GetModule(name)
	if not module then
		return false, "Module '" .. tostring(name) .. "' not found"
	end

	enabled = enabled and true or false
	if module.enabled == enabled then
		MTH_SetPersistedModuleEnabled(name, enabled)
		if self.SetConfig then
			self:SetConfig(name, "enabled", enabled)
		end
		MTH_ModuleStateDebug("request " .. tostring(name) .. " no-op runtime=" .. tostring(module.enabled) .. " persisted-synced")
		return true
	end

	if module.setEnabled and type(module.setEnabled) == "function" then
		local ok, err = pcall(function()
			module:setEnabled(enabled)
		end)
		if not ok then
			self:Print("Module '" .. name .. "' state change failed: " .. tostring(err))
			MTH:Print("[MTH] Module state change failed (" .. name .. "): " .. tostring(err), "error")
			return false, tostring(err)
		end
	end

	self:_SetModuleEventSubscriptions(name, enabled)

	module.enabled = enabled
	MTH_SetPersistedModuleEnabled(name, enabled)
	if self.SetConfig then
		self:SetConfig(name, "enabled", enabled)
	end
	MTH_ModuleStateDebug("request " .. tostring(name) .. " applied runtime=" .. tostring(module.enabled))

	return true
end

function MTH:UnloadModule(name)
	local module = self:GetModule(name)
	if module then
		if module.enabled then
			self:_SetModuleEventSubscriptions(name, false)
		end
		if module.cleanup and type(module.cleanup) == "function" then
			local ok, err = pcall(function()
				module:cleanup()
			end)
			if not ok then
				self:Print("Module '" .. name .. "' cleanup failed: " .. tostring(err))
				MTH:Print("[MTH] Module cleanup failed (" .. name .. "): " .. tostring(err), "error")
			end
		end
		self.modules[name] = nil
	end
end

function MTH:FireEvent(event, arg1, arg2, arg3, arg4, arg5)
	self:DispatchEvent(event, arg1, arg2, arg3, arg4, arg5)
end

local function MTH_GetGlobalByName(name)
	if type(name) ~= "string" or name == "" then
		return nil
	end
	if type(getglobal) == "function" then
		return getglobal(name)
	end
	if _G then
		return _G[name]
	end
	return nil
end

local function MTH_SetGlobalByName(name, value)
	if type(name) ~= "string" or name == "" then
		return
	end
	if type(setglobal) == "function" then
		setglobal(name, value)
		return
	end
	if _G then
		_G[name] = value
	end
end

local function MTH_GetHookOwnerStore()
	if not MTH._globalHookOwners then
		MTH._globalHookOwners = {}
	end
	return MTH._globalHookOwners
end

function MTH:GetGlobalHookOwner(globalName)
	if type(globalName) ~= "string" or globalName == "" then
		return nil
	end
	local owners = MTH_GetHookOwnerStore()
	local owner = owners[globalName]
	if type(owner) ~= "table" then
		return nil
	end
	return owner.key
end

function MTH:GetGlobalHookOwnersSnapshot()
	local snapshot = {}
	local owners = MTH_GetHookOwnerStore()
	for globalName, owner in pairs(owners) do
		if type(globalName) == "string" and type(owner) == "table" then
			local active = false
			if type(owner.hookFunc) == "function" then
				active = MTH_GetGlobalByName(globalName) == owner.hookFunc
			end
			snapshot[globalName] = {
				key = owner.key,
				active = active,
			}
		end
	end
	return snapshot
end

function MTH:PruneInactiveGlobalHookOwners()
	local owners = MTH_GetHookOwnerStore()
	local removed = 0

	for globalName, owner in pairs(owners) do
		local keep = false
		if type(globalName) == "string" and type(owner) == "table" and type(owner.key) == "string" and owner.key ~= "" then
			if type(owner.hookFunc) == "function" and MTH_GetGlobalByName(globalName) == owner.hookFunc then
				keep = true
			end
		end

		if not keep then
			owners[globalName] = nil
			removed = removed + 1
		end
	end

	return removed
end

function MTH:CaptureHookBoundary(key, defs)
	if type(key) ~= "string" or key == "" then
		return nil, "invalid boundary key"
	end
	if type(defs) ~= "table" then
		return nil, "invalid boundary definitions"
	end

	self._hookBoundaries = self._hookBoundaries or {}
	local boundary = self._hookBoundaries[key]
	if boundary and boundary.captured then
		return boundary
	end

	boundary = {
		captured = true,
		entries = {},
	}

	local owners = MTH_GetHookOwnerStore()

	for _, def in ipairs(defs) do
		if type(def) == "table" and type(def.globalName) == "string" and def.globalName ~= "" then
			local currentGlobal = MTH_GetGlobalByName(def.globalName)
			local entry = {
				globalName = def.globalName,
				originalName = def.originalName,
				hookFunc = currentGlobal,
				originalFunc = MTH_GetGlobalByName(def.originalName),
			}

			local existingOwner = owners[def.globalName]
			if type(existingOwner) == "table"
				and existingOwner.key ~= key
				and existingOwner.hookFunc
				and currentGlobal == existingOwner.hookFunc
			then
				entry.ownerConflict = existingOwner.key
			else
				owners[def.globalName] = {
					key = key,
					hookFunc = currentGlobal,
				}
			end

			table.insert(boundary.entries, entry)
		end
	end

	self._hookBoundaries[key] = boundary
	return boundary
end

function MTH:RestoreHookBoundary(key)
	if type(key) ~= "string" or key == "" then
		return false, "invalid boundary key"
	end

	local boundary = self._hookBoundaries and self._hookBoundaries[key]
	if not boundary or not boundary.captured then
		return false
	end

	local owners = MTH_GetHookOwnerStore()

	for _, entry in ipairs(boundary.entries) do
		if type(entry) == "table" and type(entry.globalName) == "string" then
			local owner = owners[entry.globalName]
			local ownerAllowsRestore = true
			if type(owner) == "table" and owner.key and owner.key ~= key then
				ownerAllowsRestore = false
			end

			local current = MTH_GetGlobalByName(entry.globalName)
			if ownerAllowsRestore and type(entry.originalFunc) == "function" and current == entry.hookFunc then
				MTH_SetGlobalByName(entry.globalName, entry.originalFunc)
			end

			if type(owner) == "table" and owner.key == key then
				owners[entry.globalName] = nil
			end
		end
	end

	boundary.captured = false
	return true
end

local function MTH_NormalizeSeverity(severity)
	if severity == "debug" or severity == "error" then
		return severity
	end
	return ""
end

local function MTH_BuildChatPrefix(severity)
	return "|cFFFFFFFF[|r|cFFD14A4AMeta|r|cFFABD473Hunt|r|cFFFFFFFF]|r "
end

function MTH:Log(msg, severity)
	local text = tostring(msg or "")
	local level = MTH_NormalizeSeverity(severity)
	local chatText = MTH_BuildChatPrefix(level) .. text

	if DEFAULT_CHAT_FRAME and DEFAULT_CHAT_FRAME.AddMessage then
		if level == "debug" then
			DEFAULT_CHAT_FRAME:AddMessage(chatText, 0.4, 0.8, 1)
		elseif level == "error" then
			DEFAULT_CHAT_FRAME:AddMessage(chatText, 1, 0.2, 0.2)
		else
			DEFAULT_CHAT_FRAME:AddMessage(chatText, 1, 0.9, 0.3)
		end
	else
		print(chatText)
	end

	if MTH_DebugFrame then
		if level == "debug" and MTH_DebugFrame.AddInfo then
			MTH_DebugFrame:AddInfo(text)
		elseif level == "error" and MTH_DebugFrame.AddError then
			MTH_DebugFrame:AddError(text)
		end
	end

	return chatText
end

function MTH:Print(msg, severity)
	return self:Log(msg, severity)
end

function MTH:GetMessageSettings()
	if not MTH_SavedVariables then
		self:InitSavedVariables()
	end
	if type(MTH_SavedVariables.messages) ~= "table" then
		MTH_SavedVariables.messages = {}
	end
	local settings = MTH_SavedVariables.messages
	for key, defaultValue in pairs(MTH_MESSAGE_DEFAULTS) do
		if settings[key] == nil then
			settings[key] = defaultValue and true or false
		else
			settings[key] = settings[key] and true or false
		end
	end
	return settings
end

function MTH:IsMessageEnabled(key, defaultEnabled)
	local settings = self:GetMessageSettings()
	local value = settings and settings[key]
	if value == nil then
		if defaultEnabled ~= nil then
			value = defaultEnabled and true or false
		else
			value = true
		end
		settings[key] = value
	end
	return value and true or false
end

function MTH:SetMessageEnabled(key, enabled)
	if type(key) ~= "string" or key == "" then
		return false
	end
	local settings = self:GetMessageSettings()
	if not settings then
		return false
	end
	settings[key] = enabled and true or false
	return true
end

function MTH:DebugPrint(msg)
	if self.debug then
		self:Print("[DEBUG] " .. tostring(msg), "debug")
	end
end

function MTH_Log(message, severity)
	if MTH and MTH.Log then
		return MTH:Log(message, severity)
	end
	if DEFAULT_CHAT_FRAME and DEFAULT_CHAT_FRAME.AddMessage then
		DEFAULT_CHAT_FRAME:AddMessage("[MetaHunt] " .. tostring(message or ""), 1, 0.9, 0.3)
	else
		print("[MetaHunt] " .. tostring(message or ""))
	end
end

local function MTH_SplitMoney(money)
	local value = math.floor(tonumber(money) or 0)
	if value < 0 then value = 0 end
	local gold = math.floor(value / 10000)
	local silver = math.floor((value - (gold * 10000)) / 100)
	local copper = value - (gold * 10000) - (silver * 100)
	return gold, silver, copper
end

function MTH_FormatMoney(money)
	local value = math.floor(tonumber(money) or 0)
	if value < 0 then value = 0 end

	local gold, silver, copper = MTH_SplitMoney(value)
	local text = ""
	if gold > 0 then
		text = text .. "|cffffffff" .. tostring(gold) .. "|cffffd700g"
	end
	if silver > 0 or gold > 0 then
		text = text .. "|cffffffff " .. tostring(silver) .. "|cffc7c7cfs"
	end
	text = text .. "|cffffffff " .. tostring(copper) .. "|cffeda55fc"
	return text
end

function MTH:FormatMoney(money)
	return MTH_FormatMoney(money)
end

function MTH_IsModuleEnabled(name, defaultEnabled)
	if not (MTH and MTH.IsModuleEnabled) then
		if defaultEnabled == nil then
			return true
		end
		return defaultEnabled and true or false
	end
	return MTH:IsModuleEnabled(name, defaultEnabled)
end

function MTH:InitSavedVariables()
	if not MTH_SavedVariables then
		MTH_SavedVariables = {
			modules = {},
			feedomatic = {},
			zhunter = {},
		}
	end

	if not MTH_SavedVariables.modules then
		MTH_SavedVariables.modules = {}
	end
	if not MTH_SavedVariables.moduleStates then
		MTH_SavedVariables.moduleStates = {}
	end
	if not MTH_SavedVariables.modules.feedomatic then
		MTH_SavedVariables.modules.feedomatic = MTH_SavedVariables.feedomatic or {}
	end
	if not MTH_SavedVariables.modules.zhunter then
		MTH_SavedVariables.modules.zhunter = MTH_SavedVariables.zhunter or {}
	end
	if type(MTH_SavedVariables.messages) ~= "table" then
		MTH_SavedVariables.messages = {}
	end
	for key, defaultValue in pairs(MTH_MESSAGE_DEFAULTS) do
		if MTH_SavedVariables.messages[key] == nil then
			MTH_SavedVariables.messages[key] = defaultValue and true or false
		else
			MTH_SavedVariables.messages[key] = MTH_SavedVariables.messages[key] and true or false
		end
	end

	MTH_SavedVariables.feedomatic = MTH_SavedVariables.modules.feedomatic
	MTH_SavedVariables.zhunter = MTH_SavedVariables.modules.zhunter

	if not MTH_CharSavedVariables then
		MTH_CharSavedVariables = {}
	end
	if not MTH_CharSavedVariables.modules then
		MTH_CharSavedVariables.modules = {}
	end
	if not MTH_CharSavedVariables.moduleStates then
		MTH_CharSavedVariables.moduleStates = {}
	end
	if not MTH_CharSavedVariables.petTraining then
		MTH_CharSavedVariables.petTraining = {
			spellMap = {},
			lastScan = 0,
			lastPrompt = 0,
			hasCompletedPetScan = nil,
		}
	end
	if not MTH_CharSavedVariables.trainScan then
		MTH_CharSavedVariables.trainScan = MTH_CharSavedVariables.petTraining
	end
	if MTH_CharSavedVariables.petTraining ~= MTH_CharSavedVariables.trainScan then
		MTH_CharSavedVariables.petTraining = MTH_CharSavedVariables.trainScan
	end
	if MTH_CharSavedVariables.petTraining.hasCompletedPetScan == nil then
		local pt = MTH_CharSavedVariables.petTraining
		if tonumber(pt.lastScan) and tonumber(pt.lastScan) > 0 then
			pt.hasCompletedPetScan = 1
		elseif pt.spellMap then
			for _ in pairs(pt.spellMap) do
				pt.hasCompletedPetScan = 1
				break
			end
		end
	end

	if type(MTH_PETS_GetRootStore) == "function" then
		local pets = MTH_PETS_GetRootStore()
		if type(pets) == "table" and type(pets.trainScan or pets.petTraining) == "table" then
			MTH_CharSavedVariables.trainScan = pets.trainScan or pets.petTraining
			MTH_CharSavedVariables.petTraining = MTH_CharSavedVariables.trainScan
			if MTH_CharSavedVariables.petTraining.hasCompletedPetScan == nil then
				local pt = MTH_CharSavedVariables.petTraining
				if (tonumber(pt.lastScan) or 0) > 0 then
					pt.hasCompletedPetScan = 1
				elseif type(pt.spellMap) == "table" then
					for _ in pairs(pt.spellMap) do
						pt.hasCompletedPetScan = 1
						break
					end
				end
			end
		end
	end
end

function MTH:GetModuleSavedVariables(name)
	name = MTH_NormalizeModuleName(name)
	if not MTH_SavedVariables then
		self:InitSavedVariables()
	end
	if not MTH_SavedVariables.modules then
		MTH_SavedVariables.modules = {}
	end
	if not MTH_SavedVariables.modules[name] then
		MTH_SavedVariables.modules[name] = {}
	end
	return MTH_SavedVariables.modules[name]
end

function MTH:GetModuleCharSavedVariables(name)
	name = MTH_NormalizeModuleName(name)
	if not MTH_CharSavedVariables then
		self:InitSavedVariables()
	end
	if not MTH_CharSavedVariables.modules then
		MTH_CharSavedVariables.modules = {}
	end
	if not MTH_CharSavedVariables.modules[name] then
		MTH_CharSavedVariables.modules[name] = {}
	end
	return MTH_CharSavedVariables.modules[name]
end

function MTH:ApplyPersistedModuleStates(source)
	if self:IsClassGateBlocked() then
		return
	end

	self:InitSavedVariables()
	for name, module in pairs(self.modules) do
		local defaultEnabled = module._mth_defaultEnabled
		if defaultEnabled == nil then
			defaultEnabled = module.enabled and true or false
		end

		local persistedEnabled = MTH_GetPersistedModuleEnabled(name, defaultEnabled)
		MTH_ModuleStateDebug("bootstrap " .. tostring(source or "") .. " " .. tostring(name) .. " persisted=" .. tostring(persistedEnabled) .. " runtime=" .. tostring(module.enabled and true or false))

		if module.enabled ~= persistedEnabled then
			local ok, err = self:SetModuleEnabled(name, persistedEnabled)
			if not ok then
				MTH_ModuleStateDebug("bootstrap apply failed " .. tostring(name) .. ": " .. tostring(err))
			end
		else
			MTH_SetPersistedModuleEnabled(name, persistedEnabled)
		end
	end
end

function MTH:EnsureModuleStateBootstrap()
	if self:IsClassGateBlocked() then
		return nil
	end

	if self._moduleStateBootstrapFrame then
		return self._moduleStateBootstrapFrame
	end

	local frame = CreateFrame("Frame", "MTH_ModuleBootstrap")
	if not frame then
		return nil
	end

	frame:RegisterEvent("VARIABLES_LOADED")
	frame:SetScript("OnEvent", function()
		if event ~= "VARIABLES_LOADED" then
			return
		end
		if MTH and MTH.ApplyPersistedModuleStates then
			MTH:ApplyPersistedModuleStates("VARIABLES_LOADED")
		end
		if not this then return end
		this:UnregisterAllEvents()
		this:SetScript("OnEvent", nil)
	end)

	self._moduleStateBootstrapFrame = frame
	return frame
end

function MTH:AnnounceLoadComplete()
	if self:IsClassGateBlocked() then
		return
	end

	if self._loadCompleteAnnounced then
		return
	end

	local enabled = {}
	for name, module in pairs(self.modules or {}) do
		if module and module.enabled then
			table.insert(enabled, tostring(name))
		end
	end
	table.sort(enabled)

	local moduleList = "none"
	if table.getn(enabled) > 0 then
		moduleList = table.concat(enabled, ", ")
	end

	self:Print("Check ignition: OK! Version " .. tostring(self.version or "unknown") .. " loaded.")
	if self:IsMessageEnabled("initModulesLoaded", false) then
		self:Print("Modules enabled : " .. moduleList .. ".")
	end

	local petTrainingStore = nil
	if type(MTH_PETS_GetRootStore) == "function" then
		local pets = MTH_PETS_GetRootStore()
		if type(pets) == "table" and type(pets.trainScan or pets.petTraining) == "table" then
			petTrainingStore = pets.trainScan or pets.petTraining
			if MTH_CharSavedVariables then
				MTH_CharSavedVariables.trainScan = petTrainingStore
				MTH_CharSavedVariables.petTraining = petTrainingStore
			end
		end
	end
	if not petTrainingStore then
		petTrainingStore = MTH_CharSavedVariables and (MTH_CharSavedVariables.trainScan or MTH_CharSavedVariables.petTraining)
	end
	local hasCompletedPetScan = false
	if petTrainingStore then
		if petTrainingStore.hasCompletedPetScan then
			hasCompletedPetScan = true
		elseif (tonumber(petTrainingStore.lastScan) or 0) > 0 then
			hasCompletedPetScan = true
		elseif type(petTrainingStore.spellMap) == "table" then
			for _ in pairs(petTrainingStore.spellMap) do
				hasCompletedPetScan = true
				break
			end
		elseif type(petTrainingStore.hunterKnownMap) == "table" then
			for _ in pairs(petTrainingStore.hunterKnownMap) do
				hasCompletedPetScan = true
				break
			end
		end
	end
	if not hasCompletedPetScan then
		local rawPlayerLevel = (type(UnitLevel) == "function") and UnitLevel("player") or nil
		local playerLevel = tonumber(rawPlayerLevel) or 0
		local shouldShowBeastTrainingReminder = (playerLevel >= 12 and playerLevel <= 60)
		if shouldShowBeastTrainingReminder then
			self:Print("You should open your Beast Training once to save your learned pet abilities.")
			self._loadCompleteAnnounced = true
			return
		end
	end

	local welcomeMessages = {
		"You are now shipping the latest cutting-edge Nelf technology.",
		"SHELLS ARE FOR PUSSIES.",
		"Sometimes, you just need a little less gun.",
		"Repeat 5 times : \"Un chasseur sachant chasser sans son chien\".",
		"Welcome back, hunter — your pet filed three HR complaints while you were offline.",
		"Fresh build loaded: now with 12% more pew and 38% less panic.",
		"If it moves, track it. If it doesn't move, it’s probably a trap you already dropped.",
		"Your arrows are sorted, your bars are neat, and your excuses are currently on cooldown.",
		"Remember: missing shots are just warning shots for nearby wildlife.",
		"Pet status: loyal, hungry, and judging your last pull.",
		"Consider joining <Atlantis> if you like being called a Silly Goose.",
		"Today’s strategy: confidence, chaos, and pretending it was all planned.",
		"You don’t need luck — just line of sight and questionable self-control.",
		"Chronometer is awake, traps are armed, and diplomacy has left the chat.",
		"Go make bad decisions at range.",
		"Hunter online. Morals offline. Ammo questionable.",
		"If your pull feels safe, you probably pulled the wrong pack.",
		"Pet AI says \"follow.\" Pet heart says \"chaos.\"",
		"Today’s build is stable, unlike your threat meter.",
		"Get ready for a bloody hunting session.",
		"You miss 100% of the shots you don’t blame on lag.",
		"Traps are temporary, embarrassment in party chat is forever.",
		"Your quiver is full, your bags are not, your choices are yours.",
		"Keep calm and feign absolutely everything.",
		"If diplomacy fails, send the pet. If pet fails, send apology.",
		"Welcome back. Try not to invent a new wipe mechanic.",
		"Welcome back, hunter. Your pet says it carried the last dungeon and requests hazard pay.",
		"MetaHunt loaded. Confidence initialized. Accuracy still loading...",
		"Arrows: stocked. Traps: armed. Group chat patience: limited.",
		"If the pull looks clean, you forgot at least one patrol.",
		"Your pet is ready, your bags are not, and destiny is slightly overpulled.",
		"Good news: your aim is back. Bad news: so is your aggro.",
		"The cake is a lie.",
		"Today’s forecast: scattered crits with a high chance of panic kiting.",
		"Welcome back. Remember: Feign Death is not a lifestyle, it’s a tool.",
		"Fresh session started. Please keep all limbs inside line of sight.",
		"Your pet has accepted this mission. Your healer has not.",
		"Calm mind, steady hand, absolutely chaotic pull order.",
		"Reload complete. Morale high. Ammo probably in the wrong bag.",
		"You bring the damage, the pet brings the drama, the party brings questions.",
		"Traps placed with confidence and minimal understanding of consequences.",
		"You are now entering a no-fault zone. Any wipes are purely atmospheric.",
		"Welcome back, ranger. Please ping responsibly and overpull professionally.",
		"Target acquired. Plan prepared. Plan ignored.",
		"Pet mood: loyal. Pet hunger: eternal. Pet pathing: experimental.",
		"Another day, another masterpiece in ranged chaos.",
		"MetaHunt online. Go forth and make very confident tactical mistakes.",
		"Dry sarcasm mode activated. Expectations lowered to safe operating levels.",
		"Great news: you logged in. Even better news: your pet still believes in you.",
		"You are absolutely prepared for this pull, in the same way a torch is prepared for rain.",
		"Welcome back. Your cooldowns are ready and your judgment is on a short break.",
		"If this run goes smoothly, we’ll all pretend it was intentional.",
		"You bring precision, your pet brings enthusiasm, and reality brings pathing.",
		"Today’s objective: do your best, then blame line of sight professionally.",
		"Friendly reminder: overconfidence is a buff with a very short duration.",
		"You’re not behind schedule; you’re operating on cinematic timing.",
		"Your pet is doing its best, which is more than we can ask from stairs.",
		"New day, new hunt, same wholesome chaos with extra snacks for the pet.",
		"You’ve got this — and if not, you’ve got Feign Death, which is basically plan B.",
		"Be kind, pull smart, and let your arrows do the confident talking.",
		"Your healer appreciates communication. Your tank appreciates fewer surprises.",
		"May your crits be high and your repair bill spiritually manageable.",
		"Extra savage forecast: 100% chance of \"I meant to do that.\"",
		"Pull like a legend, recover like a professional, explain like a politician.",
		"If your trap catches nothing, call it zoning control and move on.",
		"Your threat meter is not a suggestion box.",
		"Go forth, ranged menace — be accurate, be humble, and be slightly less feral than your pet.",
		"Welcome back, outlaw — your pet already blamed you in guild chat.",
		"MetaHunt online. Good decisions remain optional.",
		"You logged in with confidence and approximately zero accountability.",
		"Your pull plan is bold, reckless, and legally fascinating.",
		"Arrows loaded, ego loaded, consequences loading...",
		"Hunter mode engaged: precision first, apologies later.",
		"Your healer saw you log in and started pre-drinking mana potions.",
		"Cooldowns ready. Morals unavailable in your region.",
		"Pet is loyal, hungry, and deeply concerned about your strategy.",
		"Welcome back, menace. Try not to speedrun another wipe.",
		"You bring damage, drama, and highly questionable target priority.",
		"If this goes smoothly, nobody will believe you.",
		"Your threat meter is a warning, not a lifestyle choice.",
		"Traps armed. Safety standards disarmed.",
		"You are one bad pull away from becoming a cautionary tale.",
		"Great posture, sharp aim, catastrophic impulse control.",
		"MetaHunt loaded. The chaos now has proper tooling.",
		"Your pet follows orders. Pathing follows dark magic.",
		"Today’s objective: hit crits and dodge responsibility.",
		"Go forth, badboy ranger — leave footprints, not explanations.",
		"MetaHunt loaded. Your plan has been forwarded to Quality Control for comedy review.",
		"Systems online. Tactical brilliance still listed as a future expansion feature.",
		"Hunter detected. Restraint not detected.",
		"Startup complete. Your pet is the adult in this relationship.",
		"All modules green. Your target selection remains performance art.",
		"Welcome back. The dungeon requested a waiver after seeing your login.",
		"Interface stable. Decision-making unstable. Proceed.",
		"MetaHunt armed. Your confidence has entered the area without supervision.",
		"Ready to hunt. Ready to kite. Not ready to explain any of it.",
		"Boot successful. Friendly fire is still technically ‘friendly.’",
		"Addon synced. Your threat meter just sent a stress signal.",
		"Loaded cleanly. Reputation with healers currently in freefall.",
		"Mission start: hit things from far away and deny everything in chat.",
		"Welcome back. Your pet missed you. Just kidding, it ran away.",
		"MetaHunt loaded. You're still a Huntard, but now you're an organized one.",
		"Aspects, traps, tracking... Don't worry, I'll handle the hard parts.",
		"Oh good, another hunter who needs an addon to remember their own spells.",
		"MetaHunt ready. Feign Death is not a personality trait.",
		"Loaded successfully. No, I can't fix your DPS.",
		"Welcome. Your pet's loyalty is higher than your raid attendance.",
		"MetaHunt online. Please don't Multishot the sheep.",
		"Greetings, hunter. I see you've chosen the 'easy' class and still need help.",
		"All systems go. Try not to pull the entire dungeon this time.",
		"MetaHunt activated. Reminder: Melee range is not your home.",
		"Welcome back. Your ammo count is almost as low as your situational awareness.",
		"Loaded. I'll manage your buttons since you clearly have too many.",
		"MetaHunt ready. Aspect of the Cheetah in dungeons is a choice, not a strategy.",
		"Oh look, a hunter that uses addons. There might be hope for you yet.",
		"Welcome. No, you cannot tame that. Or that. Stop asking.",
		"MetaHunt standing by. Unlike you during your last Feign Death.",
		"Initialized. Fun fact: your pet has more utility than you do.",
		"All buttons configured. Now if only I could configure your aim.",
		"MetaHunt loaded. Growl is off, right? ...RIGHT?",
		"MetaHunt loaded. Your Freezing Trap will still break early. That's on you.",
		"Welcome. Aspect of the Pack is ready. Your group is not.",
		"Initializing... unlike your pet, I actually come when called.",
		"MetaHunt online. Remember: Hunter loot is everything. Everything.",
		"Loaded. Concussive Shot the flag carrier, not the rogue vanishing.",
		"Welcome back. Eyes of the Beast is not a valid boss strategy.",
		"Ready. Your Aimed Shot takes longer to cast than this addon took to load.",
		"MetaHunt armed. Scatter Shot into Freezing Trap — you'll get it right someday.",
		"Online. Don't worry, I track your cooldowns since you clearly don't.",
		"Welcome. Wing Clip and run. It's what you do best.",
		"Loaded. Distracting Shot is for the boss, not for your ego.",
		"MetaHunt ready. Your quiver is full but your skill bar is empty.",
		"Initialized. Serpent Sting on every target doesn't make you a DoT class.",
		"Welcome, hunter. Viper Sting the healer. No, the OTHER healer.",
		"Ready to hunt. Mend Pet is not optional, it's a lifestyle.",
		"MetaHunt loaded. Tranquilizing Shot the enrage, not the warrior.",
		"Online. Rapid Fire is a cooldown, not your approach to pulling.",
		"Welcome. You have 28 arrows left. Should've checked before the raid.",
		"Loaded. Bestial Wrath does not make YOU immune. Learned that yet?",
		"MetaHunt standing by. Dead zone? What dead zone? Oh... that dead zone.",
	}

	local welcomeIndex = 1
	local welcomeCount = table.getn(welcomeMessages)
	if welcomeCount > 1 then
		if type(random) == "function" then
			welcomeIndex = random(1, welcomeCount)
		elseif type(math) == "table" and type(math.random) == "function" then
			welcomeIndex = math.random(1, welcomeCount)
		end
	end
	if self:IsMessageEnabled("initSarcasticWelcome", true) then
		self:Print(welcomeMessages[welcomeIndex])
	end
	self._loadCompleteAnnounced = true
end

function MTH:EnsureLoadCompleteAnnouncement()
	if self:IsHardBlocked() then
		return nil
	end

	if self:IsClassGateBlocked() then
		return nil
	end

	if self._loadCompleteFrame then
		return self._loadCompleteFrame
	end

	local frame = CreateFrame("Frame", "MTH_LoadAnnounce")
	if not frame then
		return nil
	end

	frame:RegisterEvent("PLAYER_ENTERING_WORLD")
	frame:SetScript("OnEvent", function()
		if event ~= "PLAYER_ENTERING_WORLD" then
			return
		end
		if MTH and MTH.AnnounceLoadComplete then
			MTH:AnnounceLoadComplete()
		end
		if not this then return end
		this:UnregisterAllEvents()
		this:SetScript("OnEvent", nil)
	end)

	self._loadCompleteFrame = frame
	return frame
end

MTH:EnsureModuleStateBootstrap()
MTH:EnsureLoadCompleteAnnouncement()

function MTH:ShutdownForNonHunter(source)
	if self:IsHardBlocked() then
		return true
	end

	self._hardBlocked = true
	MTH_ClassGateTrace("ShutdownForNonHunter", "source=" .. tostring(source))

	for name, module in pairs(self.modules or {}) do
		if module and module.enabled then
			self:_SetModuleEventSubscriptions(name, false)
		end

		if module and module.setEnabled and type(module.setEnabled) == "function" then
			pcall(function()
				module:setEnabled(false)
			end)
		end

		if module and module.cleanup and type(module.cleanup) == "function" then
			pcall(function()
				module:cleanup()
			end)
		end

		if module then
			module.enabled = false
		end
	end

	if self._eventRouter and self._eventRouter.frame then
		self._eventRouter.frame:UnregisterAllEvents()
		self._eventRouter.frame:SetScript("OnEvent", nil)
		self._eventRouter.eventRefs = {}
	end

	if self._moduleStateBootstrapFrame then
		self._moduleStateBootstrapFrame:UnregisterAllEvents()
		self._moduleStateBootstrapFrame:SetScript("OnEvent", nil)
		self._moduleStateBootstrapFrame = nil
	end

	if self._loadCompleteFrame then
		self._loadCompleteFrame:UnregisterAllEvents()
		self._loadCompleteFrame:SetScript("OnEvent", nil)
		self._loadCompleteFrame = nil
	end

	if type(MTH_TR_ShutdownService) == "function" then
		pcall(function()
			MTH_TR_ShutdownService("class-gate")
		end)
	elseif type(MTH_PT_ShutdownService) == "function" then
		pcall(function()
			MTH_PT_ShutdownService("class-gate")
		end)
	end

	if type(MTH_PS_ShutdownService) == "function" then
		pcall(function()
			MTH_PS_ShutdownService("class-gate")
		end)
	end

	if type(MTH_ST_ShutdownService) == "function" then
		pcall(function()
			MTH_ST_ShutdownService("class-gate")
		end)
	end

	return true
end
