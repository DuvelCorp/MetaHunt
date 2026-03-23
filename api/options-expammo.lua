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

-- Helper: create a pre-wired checkbox
local function MTH_EA_OPT_CB(container, name, label, yOff, isChecked, onClick)
	local cb = MTH_CreateCheckbox(container, name, label, yOff, 20)
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
local function MTH_EA_OPT_Header(container, text, yOff)
	local fs = container:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	fs:SetPoint("TOPLEFT", container, "TOPLEFT", 20, yOff)
	fs:SetText("|cffff9900" .. text .. "|r")
end

local function MTH_EA_OPT_BuildUI(container)
	if MTH_EA_OPT_built then return end
	MTH_EA_OPT_built = true

	local cfg = MTH_EA_OPT_GetCfg()

	-- Title
	local title = container:CreateFontString(nil, "ARTWORK", "GameFontHighlightLarge")
	title:SetPoint("TOPLEFT", container, "TOPLEFT", 20, -16)
	title:SetText("MM Widget — Experimental Ammunition Tracker")

	-- Short description
	local desc = container:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	desc:SetPoint("TOPLEFT", container, "TOPLEFT", 20, -46)
	desc:SetWidth(540)
	desc:SetJustifyH("LEFT")
	desc:SetJustifyV("TOP")
	desc:SetText(
		"Tracks the 1.18.1 ammo cycling mechanic.\n"
		.. "Aimed Shot starts a 60s cycle: "
		.. "|cffff8833Explosive|r \226\134\146 |cff33ff55Poisonous|r \226\134\146 |cff6633ffEnchanted|r\n"
		.. "Each state is consumed by its matching shot (Multi-Shot / Serpent Sting / Arcane Shot)."
	)

	-- ── Section: Module ──────────────────────────────────────
	MTH_EA_OPT_Header(container, "Module", -112)

	local moduleEnabled = true
	if MTH and MTH.IsModuleEnabled then
		moduleEnabled = MTH:IsModuleEnabled("expammo", true) and true or false
	end
	MTH_EA_OPT_CB(container, "MTH_ExpAmmoModuleCB",
		"Enable MM Widget module",
		-132, moduleEnabled,
		function(v)
			if MTH and MTH.SetModuleEnabled then
				MTH:SetModuleEnabled("expammo", v)
			end
			if MTH_ExpAmmo then MTH_ExpAmmo.SetEnabled(v) end
		end)

	-- ── Section: Tracker Visibility ─────────────────────────
	MTH_EA_OPT_Header(container, "Tracker Visibility", -166)

	MTH_EA_OPT_CB(container, "MTH_ExpAmmoShowLnLCB",
		"Show Lock and Load cell (top)",
		-186, cfg.showLnL ~= false,
		function(v) if MTH_ExpAmmo then MTH_ExpAmmo.SetShowLnL(v) end end)

	MTH_EA_OPT_CB(container, "MTH_ExpAmmoShowHintCB",
		"Show action hint cell (bottom)",
		-210, cfg.showHint ~= false,
		function(v) if MTH_ExpAmmo then MTH_ExpAmmo.SetShowHint(v) end end)

	MTH_EA_OPT_CB(container, "MTH_ExpAmmoHideOOCCB",
		"Hide widget when out of combat",
		-234, cfg.hideOOC == true,
		function(v) if MTH_ExpAmmo then MTH_ExpAmmo.SetHideOOC(v) end end)

	-- ── Section: Appearance ──────────────────────────────────
	MTH_EA_OPT_Header(container, "Appearance", -268)

	local sizeSlider = MTH_CreateSlider(container, "MTH_ExpAmmoCellSizeSlider",
		"Cell Size (px)", 20, 80, 4, -288)
	if sizeSlider then
		sizeSlider:SetValue(math.max(20, math.min(80, cfg.cellSize or 40)))
		sizeSlider.onChange = function(val)
			if MTH_ExpAmmo then MTH_ExpAmmo.SetCellSize(val) end
		end
	end

	MTH_EA_OPT_CB(container, "MTH_ExpAmmoBigCDCB",
		"Large cooldown numbers (centered in cell)",
		-352, cfg.bigCD == true,
		function(v) if MTH_ExpAmmo then MTH_ExpAmmo.SetBigCD(v) end end)

	-- ── Notes ───────────────────────────────────────────────
	local tip = container:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	tip:SetPoint("TOPLEFT", container, "TOPLEFT", 20, -388)
	tip:SetWidth(540)
	tip:SetJustifyH("LEFT")
	tip:SetTextColor(0.3, 0.7, 1.0)
	tip:SetText("Tip: hold ALT and drag the tracker widget to reposition it.")
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
