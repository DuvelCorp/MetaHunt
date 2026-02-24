local function MTH_CHRON_GetGlobal(name)
	if type(getglobal) == "function" then
		return getglobal(name)
	end
	if _G then
		return _G[name]
	end
	return nil
end

local function MTH_CHRON_IsReady()
	local required = {
		"MTH_GetFrame",
		"MTH_ClearContainer",
		"MTH_CreateCheckbox",
		"MTH_CreateSlider",
		"MTH_CreateActionButton",
	}

	for i = 1, table.getn(required) do
		if MTH_CHRON_GetGlobal(required[i]) == nil then
			return false
		end
	end
	return true
end

local MTH_CHRON_STATE = {
	controls = {},
}

local MTH_CHRON_DEFAULTS = {
	growup = false,
	reverse = false,
	fadeonkill = true,
	fadeonfade = true,
	barposition = {},
	ghost = 0,
	selfbars = true,
	barwidth = 220,
	barheight = 16,
	spacing = 0,
	barscale = 1,
	iconposition = "LEFT",
	textsize = 10,
	textcolor = "white",
	bgcolor = "teal",
	barcolor = "gray",
	bordercolor = "black",
	bordertex = "None",
	bgalpha = 0.5,
	text = "$t",
	onlyself = false,
	disabledSpells = {
		COMMON = {
			["Ephemeral Power"] = {},
			["Mind Quickening"] = {},
			["Unstable Power"] = {},
		},
		RACIAL = {},
		HUNTER = {},
	},
}

local function MTH_CHRON_SeedDefaultCommonDisabled(commonBucket)
	if type(commonBucket) ~= "table" then
		return
	end
	local names = {
		"Ephemeral Power",
		"Mind Quickening",
		"Unstable Power",
	}
	for i = 1, table.getn(names) do
		local baseName = names[i]
		if commonBucket[baseName] == nil then
			commonBucket[baseName] = {}
		end
		if MTH and MTH.LocalizeSpell then
			local localized = MTH:LocalizeSpell(baseName)
			if localized and localized ~= "" and commonBucket[localized] == nil then
				commonBucket[localized] = {}
			end
		end
	end
end

local function MTH_CHRON_CopyTable(source)
	local target = {}
	for key, value in pairs(source) do
		if type(value) == "table" then
			target[key] = MTH_CHRON_CopyTable(value)
		else
			target[key] = value
		end
	end
	return target
end

local function MTH_CHRON_GetProfile()
	if not (MTH and MTH.GetModuleSavedVariables) then
		return MTH_CHRON_CopyTable(MTH_CHRON_DEFAULTS)
	end

	local store = MTH:GetModuleSavedVariables("chronometer")
	if type(store.profile) ~= "table" then
		store.profile = {}
	end
	local profile = store.profile

	for key, value in pairs(MTH_CHRON_DEFAULTS) do
		if profile[key] == nil then
			if type(value) == "table" then
				profile[key] = MTH_CHRON_CopyTable(value)
			else
				profile[key] = value
			end
		end
	end

	if type(profile.disabledSpells) ~= "table" then
		profile.disabledSpells = {}
	end
	if type(profile.disabledSpells.COMMON) ~= "table" then
		profile.disabledSpells.COMMON = {}
	end
	MTH_CHRON_SeedDefaultCommonDisabled(profile.disabledSpells.COMMON)
	if type(profile.disabledSpells.RACIAL) ~= "table" then
		profile.disabledSpells.RACIAL = {}
	end

	local _, class = UnitClass("player")
	class = class or "HUNTER"
	if type(profile.disabledSpells[class]) ~= "table" then
		profile.disabledSpells[class] = {}
	end

	return profile
end

local function MTH_CHRON_GetTimerDefinitions()
	local engine = MTH_ChronometerHunter
	if engine and engine.timers and (engine.timers[engine.SPELL] or engine.timers[engine.EVENT]) then
		return engine.timers, engine.SPELL, engine.EVENT
	end

	if not engine then
		return nil, 1, 2
	end

	local fake = {
		SPELL = 1,
		EVENT = 2,
		groups = {},
		timers = {},
	}
	function fake:AddGroup(id, forall, color)
		if color then
			self.groups[id] = { fa = forall, cr = color }
		else
			self.groups[id] = { fa = forall }
		end
	end
	function fake:AddTimer(kind, name, duration, targeted, isgain, selforselect, extra)
		if type(self.timers[kind]) ~= "table" then
			self.timers[kind] = {}
		end
		if type(extra) ~= "table" then
			extra = {}
		end
		self.timers[kind][name] = {
			d = duration,
			k = { t = targeted, g = isgain, s = selforselect },
			x = extra,
		}
	end

	if type(engine.dataSetup) == "table" then
		for _, setupFunc in pairs(engine.dataSetup) do
			if type(setupFunc) == "function" then
				setupFunc(fake)
			end
		end
	end

	return fake.timers, fake.SPELL, fake.EVENT
end

local function MTH_CHRON_SortKeys(list)
	table.sort(list, function(a, b)
		return tostring(a) < tostring(b)
	end)
end

local function MTH_CHRON_BuildTimerLists()
	local timers, spellKind, eventKind = MTH_CHRON_GetTimerDefinitions()
	local classSpells, classEvents, racial = {}, {}, {}
	if type(timers) ~= "table" then
		return classSpells, classEvents, racial
	end

	local function classify(timerRecord)
		if timerRecord and timerRecord.x and timerRecord.x.cl == "COMMON" then
			return "COMMON"
		elseif timerRecord and timerRecord.x and timerRecord.x.cl == "RACIAL" then
			return "RACIAL"
		end
		local _, class = UnitClass("player")
		return class or "HUNTER"
	end

	for timerName, timerRecord in pairs(timers[spellKind] or {}) do
		local bucket = classify(timerRecord)
		if bucket == "RACIAL" then
			table.insert(racial, timerName)
		elseif bucket ~= "COMMON" then
			table.insert(classSpells, timerName)
		end
	end

	for timerName, timerRecord in pairs(timers[eventKind] or {}) do
		local bucket = classify(timerRecord)
		if bucket == "RACIAL" then
			table.insert(racial, timerName)
		elseif bucket ~= "COMMON" then
			table.insert(classEvents, timerName)
		end
	end

	MTH_CHRON_SortKeys(classSpells)
	MTH_CHRON_SortKeys(classEvents)
	MTH_CHRON_SortKeys(racial)
	return classSpells, classEvents, racial
end

local function MTH_CHRON_ApplyLiveProfile(profile)
	if not profile then
		return
	end
	local engine = MTH_ChronometerHunter
	if not (engine and engine._mth_enabled) then
		return
	end

	engine.profile = profile
	if engine.SetCandyBarGroupGrowth then
		engine:SetCandyBarGroupGrowth("MTHChronometer", profile.growup and true or false)
	end
	if engine.SetCandyBarGroupVerticalSpacing then
		engine:SetCandyBarGroupVerticalSpacing("MTHChronometer", profile.spacing or 0)
	end

	if type(engine.bars) == "table" then
		for i = 1, 20 do
			local bar = engine.bars[i]
			if bar and bar.id then
				if profile.barscale and engine.SetCandyBarScale then
					engine:SetCandyBarScale(bar.id, profile.barscale)
				end
				if profile.barwidth and engine.SetCandyBarWidth then
					engine:SetCandyBarWidth(bar.id, profile.barwidth)
				end
				if profile.barheight and engine.SetCandyBarHeight then
					engine:SetCandyBarHeight(bar.id, profile.barheight)
				end
				if profile.iconposition and engine.SetCandyBarIconPosition then
					engine:SetCandyBarIconPosition(bar.id, profile.iconposition)
				end
				if profile.textsize and engine.SetCandyBarFontSize then
					engine:SetCandyBarFontSize(bar.id, profile.textsize)
				end
				if profile.text and engine.SetCandyBarText then
					local target = bar.target or "none"
					local text = target == "none" and (bar.name or "") or profile.text
					text = string.gsub(tostring(text or ""), "$t", tostring(target))
					text = string.gsub(tostring(text or ""), "$s", tostring(bar.name or ""))
					engine:SetCandyBarText(bar.id, text)
				end
				if engine.SetCandyBarReversed then
					engine:SetCandyBarReversed(bar.id, profile.reverse and true or false)
				end
			end
		end
	end
end

local function MTH_CHRON_MakeTitle(parent, name, text, x, y)
	local label = parent:CreateFontString(name, "ARTWORK", "GameFontHighlight")
	label:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
	label:SetText(text)
	return label
end

local function MTH_CHRON_MakeSmall(parent, name, text, x, y)
	local label = parent:CreateFontString(name, "ARTWORK", "GameFontNormalSmall")
	label:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
	label:SetText(text)
	return label
end


local function MTH_CHRON_MakeInput(parent, name, x, y, width, height, value, onAccept)
	local edit = CreateFrame("EditBox", name, parent, "InputBoxTemplate")
	if not edit then
		return nil
	end
	edit:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
	edit:SetWidth(width or 200)
	edit:SetHeight(height or 20)
	edit:SetAutoFocus(false)
	edit:SetText(tostring(value or ""))
	edit:SetScript("OnEnterPressed", function(self)
		self = self or this
		if not self then return end
		if type(onAccept) == "function" then
			onAccept(self:GetText() or "")
		end
		self:ClearFocus()
	end)
	return edit
end

local function MTH_CHRON_NormalizeSection(tabKey)
	if not tabKey and _G then
		tabKey = _G.MTH_CHRON_OPTIONS_SECTION
	end
	if tabKey == "ChronometerBar" then
		return "bar"
	elseif tabKey == "ChronometerClassSpells" then
		return "classspells"
	elseif tabKey == "ChronometerClassEvents" then
		return "classevents"
	elseif tabKey == "ChronometerRacial" then
		return "racial"
	end
	return "general"
end

local function MTH_CHRON_RenderTimerSection(container, profile, title, items, bucket)
	local timerX = 20
	local timerY = -84
	MTH_CHRON_MakeTitle(container, "MetaHuntOptionsChronometerTimersHeader", title, timerX, timerY)
	timerY = timerY - 24

	if table.getn(items) == 0 then
		MTH_CHRON_MakeSmall(container, "MetaHuntOptionsChronometerSectionEmpty", "(none)", timerX + 8, timerY)
		return
	end

	for i = 1, table.getn(items) do
		if timerY < -560 then
			MTH_CHRON_MakeSmall(container, "MetaHuntOptionsChronometerOverflow", "...more", timerX + 8, timerY)
			break
		end
		local timerName = items[i]
		local controlName = "MetaHuntOptionsChronometerTimer" .. tostring(bucket) .. tostring(i)
		local check = MTH_CreateCheckbox(container, controlName, tostring(timerName), timerY, timerX)
		if check then
			check:SetChecked(profile.disabledSpells[bucket][timerName] == nil and true or false)
			check:SetScript("OnClick", function(self)
				self = self or this
				if not self then return end
				if self:GetChecked() then
					profile.disabledSpells[bucket][timerName] = nil
				else
					profile.disabledSpells[bucket][timerName] = {}
				end
			end)
		end
		timerY = timerY - 20
	end
end

function MTH_RefreshChronometerOptions(tabKey)
	if not MTH_CHRON_IsReady() then return end
	MTH_SetupChronometerOptions(tabKey)
end

function MTH_SetupChronometerOptions(tabKey)
	if not MTH_CHRON_IsReady() then
		if MTH and MTH.Print then
			MTH:Print("Chronometer options dependencies missing", "error")
		end
		return
	end
	local section = MTH_CHRON_NormalizeSection(tabKey)
	local container = MTH_GetFrame("MetaHuntOptionsChronometer")
	if not container then return end

	MTH_ClearContainer(container)
	MTH_CHRON_STATE.controls = {}

	local profile = MTH_CHRON_GetProfile()
	local _, class = UnitClass("player")
	class = class or "HUNTER"

	MTH_CHRON_MakeTitle(container, "MetaHuntOptionsChronometerTitle", "Chronometer", 20, -10)

	local moduleCheck = MTH_CreateCheckbox(container, "MetaHuntOptionsChronometerEnabled", "Enable Chronometer module", -54)
	if moduleCheck then
		local module = MTH and MTH:GetModule("chronometer")
		moduleCheck:SetChecked(module and module.enabled and true or false)
		moduleCheck:SetScript("OnClick", function(self)
			self = self or this
			if not self then return end
			local enabled = self:GetChecked() and true or false
			if MTH and MTH.SetModuleEnabled then
				MTH:SetModuleEnabled("chronometer", enabled)
			end
		end)
	end

	if section == "general" then
		MTH_CHRON_MakeTitle(container, "MetaHuntOptionsChronometerGeneralHeader", "General", 20, -84)

		local ghostSlider = MTH_CreateSlider(container, "MetaHuntOptionsChronometerGhost", "Ghost Duration", 0, 30, 1, -112)
		if ghostSlider then
			ghostSlider:SetValue(tonumber(profile.ghost) or 0)
			ghostSlider.onChange = function(value)
				profile.ghost = tonumber(value) or 0
				MTH_CHRON_ApplyLiveProfile(profile)
			end
		end

		local killCheck = MTH_CreateCheckbox(container, "MetaHuntOptionsChronometerFadeOnKill", "Fade on kill", -154)
		if killCheck then
			killCheck:SetChecked(profile.fadeonkill and true or false)
			killCheck:SetScript("OnClick", function(self)
				self = self or this
				if not self then return end
				profile.fadeonkill = self:GetChecked() and true or false
			end)
		end

		local fadeCheck = MTH_CreateCheckbox(container, "MetaHuntOptionsChronometerFadeOnFade", "Fade on aura fade", -179)
		if fadeCheck then
			fadeCheck:SetChecked(profile.fadeonfade and true or false)
			fadeCheck:SetScript("OnClick", function(self)
				self = self or this
				if not self then return end
				profile.fadeonfade = self:GetChecked() and true or false
			end)
		end

		local selfCheck = MTH_CreateCheckbox(container, "MetaHuntOptionsChronometerSelfBars", "Show self bars", -204)
		if selfCheck then
			selfCheck:SetChecked(profile.selfbars and true or false)
			selfCheck:SetScript("OnClick", function(self)
				self = self or this
				if not self then return end
				profile.selfbars = self:GetChecked() and true or false
			end)
		end

		local onlySelfCheck = MTH_CreateCheckbox(container, "MetaHuntOptionsChronometerOnlySelf", "Only self target", -229)
		if onlySelfCheck then
			onlySelfCheck:SetChecked(profile.onlyself and true or false)
			onlySelfCheck:SetScript("OnClick", function(self)
				self = self or this
				if not self then return end
				profile.onlyself = self:GetChecked() and true or false
			end)
		end
	elseif section == "bar" then
		MTH_CHRON_MakeTitle(container, "MetaHuntOptionsChronometerBarHeader", "Bars", 20, -84)

		local runTestButton = MTH_CreateActionButton(container, "MetaHuntOptionsChronometerRunTest", "Run Test", 20, -112, 130, 22, function()
			local engine = MTH_ChronometerHunter
			if engine and engine.RunTest then
				engine:RunTest()
			end
		end)
		local anchorButton = MTH_CreateActionButton(container, "MetaHuntOptionsChronometerAnchor", "Toggle Anchor", 165, -112, 130, 22, function()
			local engine = MTH_ChronometerHunter
			if engine and engine.ToggleAnchor then
				engine:ToggleAnchor()
			end
		end)
		if runTestButton then runTestButton:Show() end
		if anchorButton then anchorButton:Show() end

		local anchorX = tonumber(profile.barposition and profile.barposition.x) or 0
		local anchorY = tonumber(profile.barposition and profile.barposition.y) or 0
		MTH_CHRON_MakeSmall(container, "MetaHuntOptionsChronometerAnchorPos", "Anchor: X " .. tostring(anchorX) .. "  Y " .. tostring(anchorY), 20, -142)

		local widthSlider = MTH_CreateSlider(container, "MetaHuntOptionsChronometerBarWidth", "Bar Width", 80, 320, 1, -180)
		if widthSlider then
			widthSlider:SetValue(tonumber(profile.barwidth) or 220)
			widthSlider.onChange = function(value)
				profile.barwidth = tonumber(value) or 220
				MTH_CHRON_ApplyLiveProfile(profile)
			end
		end

		local scaleSlider = MTH_CreateSlider(container, "MetaHuntOptionsChronometerBarScale", "Bar Scale", 0.5, 1.5, 0.1, -222)
		if scaleSlider then
			scaleSlider:SetValue(tonumber(profile.barscale) or 1)
			scaleSlider.onChange = function(value)
				profile.barscale = tonumber(value) or 1
				MTH_CHRON_ApplyLiveProfile(profile)
			end
		end

		local heightSlider = MTH_CreateSlider(container, "MetaHuntOptionsChronometerBarHeight", "Bar Height", 8, 30, 1, -264)
		if heightSlider then
			heightSlider:SetValue(tonumber(profile.barheight) or 16)
			heightSlider.onChange = function(value)
				profile.barheight = tonumber(value) or 16
				MTH_CHRON_ApplyLiveProfile(profile)
			end
		end

		local spacingSlider = MTH_CreateSlider(container, "MetaHuntOptionsChronometerBarSpacing", "Bar Spacing", 0, 15, 1, -306)
		if spacingSlider then
			spacingSlider:SetValue(tonumber(profile.spacing) or 0)
			spacingSlider.onChange = function(value)
				profile.spacing = tonumber(value) or 0
				MTH_CHRON_ApplyLiveProfile(profile)
			end
		end

		local textSizeSlider = MTH_CreateSlider(container, "MetaHuntOptionsChronometerTextSize", "Text Size", 8, 20, 1, -348)
		if textSizeSlider then
			textSizeSlider:SetValue(tonumber(profile.textsize) or 10)
			textSizeSlider.onChange = function(value)
				profile.textsize = tonumber(value) or 10
				MTH_CHRON_ApplyLiveProfile(profile)
			end
		end

		MTH_CHRON_MakeSmall(container, "MetaHuntOptionsChronometerTextPatternLabel", "Bar Text ($s spell, $t target)", 20, -390)
		MTH_CHRON_MakeInput(container, "MetaHuntOptionsChronometerTextPattern", 20, -408, 220, 20, profile.text or "$t", function(newText)
			if not newText or newText == "" then
				newText = "$t"
			end
			profile.text = tostring(newText)
			MTH_CHRON_ApplyLiveProfile(profile)
		end)

		local growCheck = MTH_CreateCheckbox(container, "MetaHuntOptionsChronometerGrowUp", "Grow bars upward", -438)
		if growCheck then
			growCheck:SetChecked(profile.growup and true or false)
			growCheck:SetScript("OnClick", function(self)
				self = self or this
				if not self then return end
				profile.growup = self:GetChecked() and true or false
				MTH_CHRON_ApplyLiveProfile(profile)
			end)
		end

		local reverseCheck = MTH_CreateCheckbox(container, "MetaHuntOptionsChronometerReverse", "Reverse bars", -463)
		if reverseCheck then
			reverseCheck:SetChecked(profile.reverse and true or false)
			reverseCheck:SetScript("OnClick", function(self)
				self = self or this
				if not self then return end
				profile.reverse = self:GetChecked() and true or false
				MTH_CHRON_ApplyLiveProfile(profile)
			end)
		end

		MTH_CHRON_MakeSmall(container, "MetaHuntOptionsChronometerIconPosLabel", "Icon Position", 20, -494)
		local iconLeft = MTH_CreateCheckbox(container, "MetaHuntOptionsChronometerIconLeft", "Left", -514)
		local iconRight = MTH_CreateCheckbox(container, "MetaHuntOptionsChronometerIconRight", "Right", -538)
		if iconLeft and iconRight then
			iconLeft:SetChecked(profile.iconposition ~= "RIGHT")
			iconRight:SetChecked(profile.iconposition == "RIGHT")
			iconLeft:SetScript("OnClick", function()
				profile.iconposition = "LEFT"
				iconLeft:SetChecked(true)
				iconRight:SetChecked(nil)
				MTH_CHRON_ApplyLiveProfile(profile)
			end)
			iconRight:SetScript("OnClick", function()
				profile.iconposition = "RIGHT"
				iconRight:SetChecked(true)
				iconLeft:SetChecked(nil)
				MTH_CHRON_ApplyLiveProfile(profile)
			end)
		end

	else
		local classSpells, classEvents, racial = MTH_CHRON_BuildTimerLists()
		if section == "classspells" then
			MTH_CHRON_RenderTimerSection(container, profile, "Hunter Spells", classSpells, class)
		elseif section == "classevents" then
			MTH_CHRON_RenderTimerSection(container, profile, "Hunter Events", classEvents, class)
		elseif section == "racial" then
			MTH_CHRON_RenderTimerSection(container, profile, "Racial", racial, "RACIAL")
		end
	end
end

	if _G then
		_G.MTH_SetupChronometerOptions = MTH_SetupChronometerOptions
		_G.MTH_RefreshChronometerOptions = MTH_RefreshChronometerOptions
	end
