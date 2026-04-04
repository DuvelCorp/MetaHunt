------------------------------------------------------
-- MetaHunt: SmartPet Options Panel
-- TWoW 1.18.1
------------------------------------------------------

local function MTH_SP_OPT_Ready()
	return type(MTH_GetFrame) == "function"
		and type(MTH_CreateCheckbox) == "function"
		and type(MTH_CreateSlider) == "function"
end

local function MTH_SP_OPT_GetCfg()
	if not MTH_SmartPet or not MTH_SmartPet.GetConfig then return {} end
	return MTH_SmartPet.GetConfig()
end

local MTH_SP_OPT_built = false

-- Layout constants
local OPT_L  = 16    -- left column X
local OPT_R  = 290   -- right column X
local OPT_CW = 250   -- column width (for tip text wrapping)

-- Spacing constants
local GAP_SECTION  = 34  -- between sections
local GAP_CB       = 24  -- checkbox height (icon + text)
local GAP_TIP      = 16  -- small tip text height
local GAP_BTN      = 28  -- button height + margin
local GAP_SLIDER   = 52  -- slider total height (label + track + value)
local GAP_CB_SLIDER = 40 -- checkbox to slider (checkbox + slider label above track)

-- Helper: checkbox with click handler
local function SP_CB(container, name, label, yOff, xOff, isChecked, onClick)
	local cb = MTH_CreateCheckbox(container, name, label, yOff, xOff or OPT_L)
	if cb then
		cb:SetChecked(isChecked and 1 or 0)
		cb:SetScript("OnClick", function()
			local v = this:GetChecked()
			onClick(v == 1 or v == true)
		end)
	end
	return cb
end

-- Helper: section header label
local function SP_Header(container, text, yOff, xOff)
	local fs = container:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	fs:SetPoint("TOPLEFT", container, "TOPLEFT", xOff or OPT_L, yOff)
	fs:SetText("|cffff9900" .. text .. "|r")
	return fs
end

-- Helper: small descriptive text
local function SP_Tip(container, text, yOff, xOff)
	local fs = container:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	fs:SetPoint("TOPLEFT", container, "TOPLEFT", xOff or OPT_L, yOff)
	fs:SetWidth(OPT_CW)
	fs:SetJustifyH("LEFT")
	fs:SetTextColor(0.4, 0.6, 1.0)
	fs:SetText(text)
	return fs
end

-- Taunt Mode cycle
local TAUNT_MODES = { "auto", "growl", "cower", "off" }
local TAUNT_LABELS = {
	auto   = "Auto (solo=Growl, tank=Cower)",
	growl  = "Always Growl",
	cower  = "Always Cower",
	off    = "Off (manual)",
}

local function SP_NextTauntMode(current)
	for i = 1, 4 do
		if TAUNT_MODES[i] == current then
			return TAUNT_MODES[math.mod(i, 4) + 1]
		end
	end
	return "auto"
end

-- Channel cycle
local CHANNELS = { "SAY", "PARTY", "RAID", "GUILD" }

local function SP_NextChannel(current)
	for i = 1, 4 do
		if CHANNELS[i] == current then
			return CHANNELS[math.mod(i, 4) + 1]
		end
	end
	return "SAY"
end

-- Build the UI
local function MTH_SP_OPT_BuildUI(container)
	if MTH_SP_OPT_built then return end
	MTH_SP_OPT_built = true

	local cfg = MTH_SP_OPT_GetCfg()
	local api = MTH_SmartPet or {}

	---------------------------------------------------------------------------
	-- Title (large, like ExpAmmo)
	---------------------------------------------------------------------------
	local title = container:CreateFontString(nil, "ARTWORK", "GameFontHighlightLarge")
	title:SetPoint("TOPLEFT", container, "TOPLEFT", OPT_L, -16)
	title:SetText("Smart Pet - Pet Combat Management")

	---------------------------------------------------------------------------
	-- Module enable checkbox
	---------------------------------------------------------------------------
	local moduleEnabled = true
	if MTH and MTH.IsModuleEnabled then
		moduleEnabled = MTH:IsModuleEnabled("smartpet", false) and true or false
	end
	SP_CB(container, "MTH_SP_OPT_ModuleEnable", "Enable Smart Pet module",
		-46, OPT_L, moduleEnabled, function(v)
			if MTH and MTH.SetModuleEnabled then MTH:SetModuleEnabled("smartpet", v) end
		end)

	-- Columns start below the module checkbox
	local COL_TOP = -80

	-- Vertical divider
	local divider = container:CreateTexture(nil, "BACKGROUND")
	divider:SetTexture(0.3, 0.3, 0.3, 0.6)
	divider:SetPoint("TOPLEFT",    container, "TOPLEFT", OPT_R - 14, COL_TOP)
	divider:SetPoint("BOTTOMLEFT", container, "TOPLEFT", OPT_R - 14, -530)
	divider:SetWidth(1)

	---------------------------------------------------------------------------
	-- LEFT COLUMN — Focus Management
	---------------------------------------------------------------------------
	local y = COL_TOP

	SP_Header(container, "Focus Management", y)
	y = y - 22

	-- Smart Focus
	SP_CB(container, "MTH_SP_OPT_SmartFocus", "Enable Smart Focus",
		y, OPT_L, cfg.smartFocus, function(v)
			if api.SetSmartFocus then api.SetSmartFocus(v) end
		end)
	y = y - GAP_CB
	SP_Tip(container, "Budget pet focus across DPS abilities.", y)
	y = y - GAP_TIP
	SP_Tip(container, "|cff80ff80High focus|r — all DPS abilities ON.", y)
	y = y - GAP_TIP
	SP_Tip(container, "|cffffcc00Mid focus|r — expensive ability first, others wait.", y)
	y = y - GAP_TIP
	SP_Tip(container, "|cffff8080Low focus|r — cheapest ability always ON (never idle).", y)
	y = y - GAP_TIP
	SP_Tip(container, "Taunt cost is always reserved.", y)
	y = y - GAP_SECTION

	---------------------------------------------------------------------------
	-- LEFT COLUMN — Taunt Management
	---------------------------------------------------------------------------
	SP_Header(container, "Taunt Management", y)
	y = y - GAP_TIP
	SP_Tip(container, "Controls Growl/Cower autocast based on party.", y)
	y = y - 22

	local tauntBtn = CreateFrame("Button", "MTH_SP_OPT_TauntBtn", container, "UIPanelButtonTemplate")
	tauntBtn:SetPoint("TOPLEFT", container, "TOPLEFT", OPT_L, y)
	tauntBtn:SetWidth(250)
	tauntBtn:SetHeight(22)
	tauntBtn:SetText("Mode: " .. (TAUNT_LABELS[cfg.tauntMode] or "Auto"))
	tauntBtn:SetScript("OnClick", function()
		local c = MTH_SP_OPT_GetCfg()
		local newMode = SP_NextTauntMode(c.tauntMode)
		if api.SetTauntMode then api.SetTauntMode(newMode) end
		this:SetText("Mode: " .. (TAUNT_LABELS[newMode] or newMode))
	end)
	y = y - GAP_BTN

	SP_CB(container, "MTH_SP_OPT_PvpDetaunt", "PVP Auto-Detaunt",
		y, OPT_L, cfg.pvpDetaunt, function(v)
			if api.SetPvpDetaunt then api.SetPvpDetaunt(v) end
		end)
	y = y - GAP_SECTION

	---------------------------------------------------------------------------
	-- LEFT COLUMN — CC-Break Prevention
	---------------------------------------------------------------------------
	SP_Header(container, "CC-Break Prevention", y)
	y = y - 22

	SP_CB(container, "MTH_SP_OPT_CcBreak", "Check for breakable CC",
		y, OPT_L, cfg.ccBreakCheck, function(v)
			if api.SetCcBreakCheck then api.SetCcBreakCheck(v) end
		end)
	y = y - GAP_CB

	local ccLabels = { block = "Block attack", warn = "Warn only" }
	local ccModeBtn = CreateFrame("Button", "MTH_SP_OPT_CcModeBtn", container, "UIPanelButtonTemplate")
	ccModeBtn:SetPoint("TOPLEFT", container, "TOPLEFT", OPT_L + 20, y)
	ccModeBtn:SetWidth(180)
	ccModeBtn:SetHeight(20)
	ccModeBtn:SetText("CC Mode: " .. (ccLabels[cfg.ccBreakMode] or "Block"))
	ccModeBtn:SetScript("OnClick", function()
		local c = MTH_SP_OPT_GetCfg()
		local newMode = (c.ccBreakMode == "block") and "warn" or "block"
		if api.SetCcBreakMode then api.SetCcBreakMode(newMode) end
		this:SetText("CC Mode: " .. (ccLabels[newMode] or newMode))
	end)
	y = y - GAP_SECTION

	---------------------------------------------------------------------------
	-- RIGHT COLUMN — General
	---------------------------------------------------------------------------
	local ry = COL_TOP

	-- The Button
	SP_Header(container, "The Button", ry, OPT_R)
	ry = ry - 22

	SP_CB(container, "MTH_SP_OPT_TheButton", "Enable The Button keybind",
		ry, OPT_R, cfg.theButton, function(v)
			if api.SetTheButton then api.SetTheButton(v) end
		end)
	ry = ry - GAP_CB
	SP_Tip(container, "Enemy=attack, friendly=assist, none=recall.", ry, OPT_R)
	ry = ry - GAP_SECTION

	-- Rush on Attack
	SP_CB(container, "MTH_SP_OPT_Rush", "Rush on initial attack",
		ry, OPT_R, cfg.rushOnAttack, function(v)
			if api.SetRushOnAttack then api.SetRushOnAttack(v) end
		end)
	ry = ry - GAP_CB
	SP_Tip(container, "Charge / Dash / Dive when pet is sent to attack.", ry, OPT_R)
	ry = ry - GAP_SECTION

	-- NoChase
	SP_CB(container, "MTH_SP_OPT_NoChase", "NoChase (recall on mob flee)",
		ry, OPT_R, cfg.noChase, function(v)
			if api.SetNoChase then api.SetNoChase(v) end
		end)
	ry = ry - GAP_CB
	SP_Tip(container, "Recall pet when target attempts to flee.", ry, OPT_R)
	ry = ry - GAP_SECTION

	-- AutoCower
	SP_Header(container, "AutoCower", ry, OPT_R)
	ry = ry - 22

	SP_CB(container, "MTH_SP_OPT_AutoCower", "Enable AutoCower on low HP",
		ry, OPT_R, cfg.autoCower, function(v)
			if api.SetAutoCower then api.SetAutoCower(v) end
		end)
	ry = ry - GAP_CB_SLIDER

	local acSlider = MTH_CreateSlider(container, "MTH_SP_OPT_AutoCowerSlider",
		"HP Threshold (%)", 5, 80, 5, ry)
	if acSlider then
		acSlider:ClearAllPoints()
		acSlider:SetPoint("TOPLEFT", container, "TOPLEFT", OPT_R, ry)
		acSlider:SetWidth(200)
		acSlider:SetValue(cfg.autoCowerPct or 30)
		local valText = getglobal("MTH_SP_OPT_AutoCowerSliderValue")
		if valText then valText:SetText(tostring(cfg.autoCowerPct or 30)) end
		acSlider.onChange = function(val)
			if api.SetAutoCowerPct then api.SetAutoCowerPct(val) end
		end
	end
	ry = ry - GAP_SLIDER

	-- AutoWarn
	SP_Header(container, "AutoWarn", ry, OPT_R)
	ry = ry - 22

	SP_CB(container, "MTH_SP_OPT_AutoWarn", "Warn when pet HP is low",
		ry, OPT_R, cfg.autoWarn, function(v)
			if api.SetAutoWarn then api.SetAutoWarn(v) end
		end)
	ry = ry - GAP_CB_SLIDER

	local awSlider = MTH_CreateSlider(container, "MTH_SP_OPT_AutoWarnSlider",
		"HP Threshold (%)", 5, 60, 5, ry)
	if awSlider then
		awSlider:ClearAllPoints()
		awSlider:SetPoint("TOPLEFT", container, "TOPLEFT", OPT_R, ry)
		awSlider:SetWidth(200)
		awSlider:SetValue(cfg.autoWarnPct or 20)
		local valText = getglobal("MTH_SP_OPT_AutoWarnSliderValue")
		if valText then valText:SetText(tostring(cfg.autoWarnPct or 20)) end
		awSlider.onChange = function(val)
			if api.SetAutoWarnPct then api.SetAutoWarnPct(val) end
		end
	end
	ry = ry - GAP_SLIDER

	local chanBtn = CreateFrame("Button", "MTH_SP_OPT_ChanBtn", container, "UIPanelButtonTemplate")
	chanBtn:SetPoint("TOPLEFT", container, "TOPLEFT", OPT_R, ry)
	chanBtn:SetWidth(180)
	chanBtn:SetHeight(22)
	chanBtn:SetText("Channel: " .. (cfg.autoWarnChannel or "SAY"))
	chanBtn:SetScript("OnClick", function()
		local c = MTH_SP_OPT_GetCfg()
		local newChan = SP_NextChannel(c.autoWarnChannel or "SAY")
		if api.SetAutoWarnChannel then api.SetAutoWarnChannel(newChan) end
		this:SetText("Channel: " .. newChan)
	end)
	ry = ry - GAP_CB
	SP_Tip(container, "Chat channel for low-HP warnings.", ry, OPT_R)
end

-- Public setup function (called by options-shell.lua)
function MTH_SetupSmartPetOptions()
	if not MTH_SP_OPT_Ready() then return end
	local container = MTH_GetFrame("MetaHuntOptionsSmartPet")
	if not container then return end
	local ok, err = pcall(MTH_SP_OPT_BuildUI, container)
	if not ok then
		if MTH and MTH.Print then
			MTH:Print("[SmartPet Options] " .. tostring(err), "error")
		end
		MTH_SP_OPT_built = false
	end
end
