------------------------------------------------------
-- MetaHunt: Experimental Ammunition Options Panel
-- TWoW 1.18.1 — "Nightmares of Ursol"
------------------------------------------------------

local function MTH_EA_OPT_Ready()
	return type(MTH_GetFrame) == "function"
		and type(MTH_CreateCheckbox) == "function"
		and type(MTH_CreateSlider) == "function"
end

local function MTH_EA_OPT_GetCfg()
	if type(MTH_SavedVariables) ~= "table" then return {} end
	if type(MTH_SavedVariables.modules) ~= "table" then return {} end
	return MTH_SavedVariables.modules["expammo"] or {}
end

local MTH_EA_OPT_built = false
local MTH_EA_OPT_STATE = { bindStatus = nil, bindButton = nil, captureFrame = nil }

-- ── Layout constants ──────────────────────────────────────────
-- Two equal columns separated by a gutter.  Values are offsets from the
-- container TOPLEFT corner (positive X right, negative Y down).
local OPT_L  = 20    -- left column X
local OPT_R  = 300   -- right column X
local OPT_CW = 255   -- column width (used for text wrapping and sliders)

local function MTH_EA_OPT_GetBindText()
	if not GetBindingKey then return "Unbound" end
	local k1, k2 = GetBindingKey("EXPAMMO ACTION")
	if not k1 and not k2 then return "Unbound" end
	if k1 and k2 then return k1 .. " / " .. k2 end
	return k1 or k2 or "Unbound"
end

local function MTH_EA_OPT_UpdateBindStatus()
	local bs = MTH_EA_OPT_STATE.bindStatus
	if not bs then return end
	bs:SetText("Key: " .. MTH_EA_OPT_GetBindText())
end

-- key must already be the full chord string (e.g. "ALT-F", "BUTTON3", "MOUSEWHEELUP")
local function MTH_EA_OPT_SaveBinding(key)
	if not SetBinding or not SaveBindings or not GetBindingKey then return end
	local old1, old2 = GetBindingKey("EXPAMMO ACTION")
	if old1 then SetBinding(old1) end
	if old2 then SetBinding(old2) end
	if key and key ~= "" then
		SetBinding(key, "EXPAMMO ACTION")
	end
	local bs = 1
	if GetCurrentBindingSet then bs = GetCurrentBindingSet() or 1 end
	SaveBindings(bs)
end

local function MTH_EA_OPT_GetPrefix()
	return string.format("%s%s%s",
		(IsAltKeyDown and IsAltKeyDown() and "ALT-" or ""),
		(IsControlKeyDown and IsControlKeyDown() and "CTRL-" or ""),
		(IsShiftKeyDown and IsShiftKeyDown() and "SHIFT-" or ""))
end

local function MTH_EA_OPT_StopCapture()
	if MTH_EA_OPT_STATE.captureFrame then
		MTH_EA_OPT_STATE.captureFrame:Hide()
	end
	local bb = MTH_EA_OPT_STATE.bindButton
	if bb then bb:SetText("Set Key") end
	MTH_EA_OPT_UpdateBindStatus()
end

local function MTH_EA_OPT_MakeCaptureFrame()
	local f = CreateFrame("Frame", "MTH_ExpAmmoBindCapture", UIParent)
	f:SetFrameStrata("FULLSCREEN_DIALOG")
	f:SetAllPoints(UIParent)
	f:EnableKeyboard(true)
	f:EnableMouse(true)
	f:EnableMouseWheel(true)
	f:Hide()
	local bg = f:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints(f)
	bg:SetTexture(0, 0, 0, 0.5)
	local lbl = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	lbl:SetPoint("CENTER", f, "CENTER", 0, 0)
	lbl:SetText("|cffffff00Press a key, mouse button, or scroll wheel|r\n|cffaaaaaa(ESC to cancel)|r")
	f:SetScript("OnKeyUp", function()
		local key = arg1
		if not key or key == "" then return end
		if key == "ESCAPE" then MTH_EA_OPT_StopCapture() return end
		if key == "UNKNOWN" or key == "PRINTSCREEN" then return end
		if key == "ALT" or key == "CTRL" or key == "SHIFT" then return end
		MTH_EA_OPT_SaveBinding(MTH_EA_OPT_GetPrefix() .. key)
		MTH_EA_OPT_StopCapture()
	end)
	f:SetScript("OnMouseUp", function()
		local btmap = { LeftButton="BUTTON1", RightButton="BUTTON2", MiddleButton="BUTTON3", Button4="BUTTON4", Button5="BUTTON5" }
		local mapped = btmap[arg1]
		if not mapped then return end
		local prefix = MTH_EA_OPT_GetPrefix()
		if prefix == "" and (mapped == "BUTTON1" or mapped == "BUTTON2") then return end
		MTH_EA_OPT_SaveBinding(prefix .. mapped)
		MTH_EA_OPT_StopCapture()
	end)
	f:SetScript("OnMouseWheel", function()
		local wheelkey = (arg1 == 1 and "MOUSEWHEELUP") or (arg1 == -1 and "MOUSEWHEELDOWN") or nil
		if not wheelkey then return end
		MTH_EA_OPT_SaveBinding(MTH_EA_OPT_GetPrefix() .. wheelkey)
		MTH_EA_OPT_StopCapture()
	end)
	return f
end

local function MTH_EA_OPT_StartCapture()
	if not MTH_EA_OPT_STATE.captureFrame then
		MTH_EA_OPT_STATE.captureFrame = MTH_EA_OPT_MakeCaptureFrame()
	end
	MTH_EA_OPT_STATE.captureFrame:Show()
	local bb = MTH_EA_OPT_STATE.bindButton
	if bb then bb:SetText("Press key...") end
end

-- Helper: checkbox anchored to a given X column
local function MTH_EA_OPT_CB(container, name, label, yOff, xOff, isChecked, onClick)
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
local function MTH_EA_OPT_Header(container, text, yOff, xOff)
	local fs = container:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	fs:SetPoint("TOPLEFT", container, "TOPLEFT", xOff or OPT_L, yOff)
	fs:SetText("|cffff9900" .. text .. "|r")
	return fs
end

-- Helper: small descriptive text
local function MTH_EA_OPT_Tip(container, text, yOff, xOff, r, g, b)
	local fs = container:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	fs:SetPoint("TOPLEFT", container, "TOPLEFT", xOff or OPT_L, yOff)
	fs:SetWidth(OPT_CW)
	fs:SetJustifyH("LEFT")
	fs:SetTextColor(r or 0.6, g or 0.6, b or 0.6)
	fs:SetText(text)
	return fs
end

-- Enable or disable a list of widgets (supports Frames/Buttons and FontStrings)
local function MTH_EA_OPT_SetGroupEnabled(widgets, enabled)
	for _, w in ipairs(widgets) do
		if w then
			if w.Enable and w.Disable then
				-- Frame / Button / CheckButton
				if enabled then w:Enable() else w:Disable() end
			end
			-- Dim all (including FontStrings and frames) via alpha
			if w.SetAlpha then
				w:SetAlpha(enabled and 1.0 or 0.35)
			end
		end
	end
end

local function MTH_EA_OPT_BuildUI(container)
	if MTH_EA_OPT_built then return end
	MTH_EA_OPT_built = true

	local cfg = MTH_EA_OPT_GetCfg()
	local showHint = cfg.showHint ~= false

	---------------------------------------------------------------------------
	-- Title
	---------------------------------------------------------------------------
	local title = container:CreateFontString(nil, "ARTWORK", "GameFontHighlightLarge")
	title:SetPoint("TOPLEFT", container, "TOPLEFT", OPT_L, -16)
	title:SetText("MM Widget — Experimental Ammunition Tracker")

	---------------------------------------------------------------------------
	-- LEFT COLUMN
	---------------------------------------------------------------------------

	-- ── Module ──────────────────────────────────────────────
	MTH_EA_OPT_Header(container, "Module", -46)

	local moduleEnabled = true
	if MTH and MTH.IsModuleEnabled then
		moduleEnabled = MTH:IsModuleEnabled("expammo", true) and true or false
	end
	MTH_EA_OPT_CB(container, "MTH_ExpAmmoModuleCB",
		"Enable MM Widget module",
		-66, OPT_L, moduleEnabled,
		function(v)
			if MTH and MTH.SetModuleEnabled then MTH:SetModuleEnabled("expammo", v) end
			if MTH_ExpAmmo then MTH_ExpAmmo.SetEnabled(v) end
		end)

	-- ── Tracker Visibility ───────────────────────────────────
	MTH_EA_OPT_Header(container, "Tracker Visibility", -100)

	MTH_EA_OPT_CB(container, "MTH_ExpAmmoShowLnLCB",
		"Show Lock and Load cell (top)",
		-120, OPT_L, cfg.showLnL ~= false,
		function(v) if MTH_ExpAmmo then MTH_ExpAmmo.SetShowLnL(v) end end)

	-- "Show action hint cell" also gates the right column
	local rightGroup = {}  -- filled below; toggled when this CB changes
	local showHintCB = MTH_EA_OPT_CB(container, "MTH_ExpAmmoShowHintCB",
		"Show action hint cell (bottom)",
		-144, OPT_L, showHint,
		function(v)
			if MTH_ExpAmmo then MTH_ExpAmmo.SetShowHint(v) end
			MTH_EA_OPT_SetGroupEnabled(rightGroup, v)
		end)

	MTH_EA_OPT_CB(container, "MTH_ExpAmmoHideOOCCB",
		"Hide widget when out of combat",
		-168, OPT_L, cfg.hideOOC == true,
		function(v) if MTH_ExpAmmo then MTH_ExpAmmo.SetHideOOC(v) end end)

	-- ── Appearance ───────────────────────────────────────────
	MTH_EA_OPT_Header(container, "Appearance", -202)

	local sizeSlider = MTH_CreateSlider(container, "MTH_ExpAmmoCellSizeSlider",
		"Cell Size (px)", 20, 80, 4, -222)
	if sizeSlider then
		sizeSlider:ClearAllPoints()
		sizeSlider:SetPoint("TOPLEFT", container, "TOPLEFT", OPT_L + 5, -222)
		sizeSlider:SetWidth(OPT_CW - 10)
		sizeSlider:SetValue(math.max(20, math.min(80, cfg.cellSize or 40)))
		sizeSlider.onChange = function(val)
			if MTH_ExpAmmo then MTH_ExpAmmo.SetCellSize(val) end
		end
	end

	local gapSlider = MTH_CreateSlider(container, "MTH_ExpAmmoCellGapSlider",
		"Cell Spacing (px)", 0, 20, 1, -286)
	if gapSlider then
		gapSlider:ClearAllPoints()
		gapSlider:SetPoint("TOPLEFT", container, "TOPLEFT", OPT_L + 5, -286)
		gapSlider:SetWidth(OPT_CW - 10)
		gapSlider:SetValue(math.max(0, math.min(20, cfg.cellGap or 2)))
		gapSlider.onChange = function(val)
			if MTH_ExpAmmo then MTH_ExpAmmo.SetCellGap(val) end
		end
	end

	MTH_EA_OPT_CB(container, "MTH_ExpAmmoBigCDCB",
		"Large cooldown numbers (centered in cell)",
		-350, OPT_L, cfg.bigCD == true,
		function(v) if MTH_ExpAmmo then MTH_ExpAmmo.SetBigCD(v) end end)

	-- ── Position ─────────────────────────────────────────────
	MTH_EA_OPT_Header(container, "Position", -390)

	local anchorButton = MTH_CreateActionButton(container, "MTH_ExpAmmoToggleAnchor",
		"Toggle Anchor", OPT_L, -410, 130, 22, function()
			if MTH_ExpAmmo then MTH_ExpAmmo.ToggleAnchor() end
		end)
	if anchorButton then anchorButton:Show() end

	MTH_EA_OPT_Tip(container,
		"Shows 4 drag handles around the widget (top / bottom / left / right). Drag any one to reposition it.",
		-436, OPT_L)

	---------------------------------------------------------------------------
	-- RIGHT COLUMN — Action Hint Cell (keybind + casting)
	-- All widgets here are greyed out when the bottom cell is hidden.
	---------------------------------------------------------------------------

	-- Vertical divider line
	local divider = container:CreateTexture(nil, "BACKGROUND")
	divider:SetTexture(0.3, 0.3, 0.3, 0.6)
	divider:SetPoint("TOPLEFT",  container, "TOPLEFT",  OPT_R - 10, -46)
	divider:SetPoint("BOTTOMLEFT", container, "TOPLEFT", OPT_R - 10, -530)
	divider:SetWidth(1)
	
	-- Column title
	local rTitle = container:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	rTitle:SetPoint("TOPLEFT", container, "TOPLEFT", OPT_R, -46)
	rTitle:SetText("|cffff9900" .. "Action Hint Cell" .. "|r")
	table.insert(rightGroup, rTitle)


	local rSubtitle = MTH_EA_OPT_Tip(container,
		"Options below apply to the bottom cell only.\n Disable \"Show action hint cell\" to hide the cell and these controls.",
		-64, OPT_R, 1.00, 1.00, 1.00)
	if rSubtitle then rSubtitle:SetWidth(290) end
	table.insert(rightGroup, rSubtitle)

	local rNamPowerTip = MTH_EA_OPT_Tip(container,
		"Notes:\n - You need NAMPOWER for this to work reliably.\n - Aimed/Steady/Multi/Arcane Shots SHOULD BE on your action bars.",
		-100, OPT_R, 0.35, 0.65, 1.00)
	if rNamPowerTip then rNamPowerTip:SetWidth(290) end
	table.insert(rightGroup, rNamPowerTip)

	-- ── Keybind ──────────────────────────────────────────────
	table.insert(rightGroup, MTH_EA_OPT_Header(container, "Keybind", -182, OPT_R))

	local bindTip = MTH_EA_OPT_Tip(container,
		"One key to rule them all.\n Aimed Shot when ready, Steady Shot while Aimed is on cooldown,\n consume-spell (Multi / Serpent / Arcane) when proc is up.",
		-200, OPT_R, 0.65, 0.65, 0.65)
	if bindTip then bindTip:SetWidth(290) end
	table.insert(rightGroup, bindTip)

	local bindStatus = container:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	bindStatus:SetPoint("TOPLEFT", container, "TOPLEFT", OPT_R, -248)
	bindStatus:SetText("Key: " .. MTH_EA_OPT_GetBindText())
	MTH_EA_OPT_STATE.bindStatus = bindStatus
	table.insert(rightGroup, bindStatus)

	local bindButton = CreateFrame("Button", "MTH_ExpAmmoBindButton", container, "UIPanelButtonTemplate")
	bindButton:SetPoint("TOPLEFT", container, "TOPLEFT", OPT_R, -264)
	bindButton:SetWidth(90)
	bindButton:SetHeight(22)
	bindButton:SetText("Set Key")
	bindButton:EnableKeyboard(false)
	bindButton:SetScript("OnClick", function()
		if MTH_EA_OPT_STATE.captureFrame and MTH_EA_OPT_STATE.captureFrame:IsShown() then
			MTH_EA_OPT_StopCapture()
		else
			MTH_EA_OPT_StartCapture()
		end
	end)
	MTH_EA_OPT_STATE.bindButton = bindButton
	table.insert(rightGroup, bindButton)

	local clearButton = CreateFrame("Button", "MTH_ExpAmmoBindClear", container, "UIPanelButtonTemplate")
	clearButton:SetPoint("LEFT", bindButton, "RIGHT", 6, 0)
	clearButton:SetWidth(70)
	clearButton:SetHeight(22)
	clearButton:SetText("Clear")
	clearButton:SetScript("OnClick", function()
		MTH_EA_OPT_SaveBinding(nil)
	end)
	table.insert(rightGroup, clearButton)

	-- ── Casting ──────────────────────────────────────────────
	table.insert(rightGroup, MTH_EA_OPT_Header(container, "Casting", -304, OPT_R))

	local quiverCB = MTH_EA_OPT_CB(container, "MTH_ExpAmmoQuiverNoClipCB",
		"Use Quiver no-clip casting",
		-324, OPT_R, cfg.useQuiverNoClip == true,
		function(v) if MTH_ExpAmmo then MTH_ExpAmmo.SetUseQuiverNoClip(v) end end)
	table.insert(rightGroup, quiverCB)

	local quiverTip = MTH_EA_OPT_Tip(container,
		"|cff4d9cffRequires the Quiver addon.|r \n Routes Aimed/Steady/Multi cast through Quiver.CastNoClip \n to avoid clipping your auto-shot swing timer",
		-350, OPT_R, 1, 1, 1)
	if quiverTip then quiverTip:SetWidth(290) end
	table.insert(rightGroup, quiverTip)

	-- ── Rotation ─────────────────────────────────────────────
	table.insert(rightGroup, MTH_EA_OPT_Header(container, "Rotation", -400, OPT_R))

	local rotTip = MTH_EA_OPT_Tip(container,
		"Uncheck a shot to permanently skip it during its proc window.\n The keybind will cast Steady/Aimed instead.",
		-418, OPT_R, 0.65, 0.65, 0.65)
	if rotTip then rotTip:SetWidth(290) end
	table.insert(rightGroup, rotTip)

	local multiCB = MTH_EA_OPT_CB(container, "MTH_ExpAmmoBlockMultiCB",
		"Multi-Shot (Explosive)",
		-452, OPT_R, cfg.blockExplosive ~= true,
		function(v) if MTH_ExpAmmo then MTH_ExpAmmo.SetBlockExplosive(not v) end end)
	table.insert(rightGroup, multiCB)

	local serpentCB = MTH_EA_OPT_CB(container, "MTH_ExpAmmoBlockSerpentCB",
		"Serpent Sting (Poisonous)",
		-476, OPT_R, cfg.blockPoisonous ~= true,
		function(v) if MTH_ExpAmmo then MTH_ExpAmmo.SetBlockPoisonous(not v) end end)
	table.insert(rightGroup, serpentCB)

	local arcaneCB = MTH_EA_OPT_CB(container, "MTH_ExpAmmoBlockArcaneCB",
		"Arcane Shot (Enchanted)",
		-500, OPT_R, cfg.blockEnchanted ~= true,
		function(v) if MTH_ExpAmmo then MTH_ExpAmmo.SetBlockEnchanted(not v) end end)
	table.insert(rightGroup, arcaneCB)

	-- Apply initial enabled state
	MTH_EA_OPT_SetGroupEnabled(rightGroup, showHint)
end

function MTH_SetupExpAmmoOptions()
	if not MTH_EA_OPT_Ready() then return end
	local container = MTH_GetFrame("MetaHuntOptionsExpAmmo")
	if not container then return end
	local ok, err = pcall(MTH_EA_OPT_BuildUI, container)
	if not ok and MTH and MTH.Print then
		MTH:Print("[MTH ExpAmmo OPTIONS] " .. tostring(err), "error")
	end
end
