-- zBar: Unified draggable anchor bar for all zButton parent buttons.
-- When enabled, all included zButton parents are anchored to the zBar anchor
-- in a configurable row (horizontal) or column (vertical).
-- Individual Alt+drag on each zButton is suppressed while zBar is active.

local ZBAR_FRAME_NAME = "MTH_ZBar_Anchor"

local ZBAR_ALL_BUTTONS = {
	"zButtonAspect",
	"zButtonAmmo",
	"zButtonTrack",
	"zButtonTrap",
	"zButtonPet",
	"zButtonRanged",
	"zButtonMounts",
	"zButtonCompanions",
	"zButtonToys",
	"zButtonCraft",
}

local ZBAR_BUTTON_LABELS = {
	zButtonAspect     = "zAspect",
	zButtonAmmo       = "zAmmo",
	zButtonTrack      = "zTrack",
	zButtonTrap       = "zTrap",
	zButtonPet        = "zPet",
	zButtonRanged     = "zRanged",
	zButtonMounts     = "zMounts",
	zButtonCompanions = "zCompanions",
	zButtonToys       = "zToys",
	zButtonCraft      = "zCraft",
}

function MTH_ZBar_GetAllButtons()
	return ZBAR_ALL_BUTTONS
end

function MTH_ZBar_GetAllButtonLabels()
	return ZBAR_BUTTON_LABELS
end

-- Returns (and initialises on first access) the _zbar saved-variable table.
function MTH_ZBar_GetSaved()
	local root = MTH_ZH_GetSavedRoot()
	if type(root["_zbar"]) ~= "table" then
		root["_zbar"] = {}
	end
	local s = root["_zbar"]

	if s.enabled   == nil then s.enabled   = false        end
	if s.direction == nil then s.direction = "HORIZONTAL" end
	if type(s.spacing) ~= "number" then s.spacing = 4  end
	if type(s.size)    ~= "number" then s.size    = 36 end
	-- childexpand: which side children appear on (TOP/BOTTOM for H bar, LEFT/RIGHT for V bar)
	if s.childexpand  == nil then s.childexpand  = "BOTTOM"   end
	-- childarrange: how children #2+ are laid out (VERTICAL=column, HORIZONTAL=row)
	if s.childarrange == nil then s.childarrange = "VERTICAL" end
	if type(s.order) ~= "table" then
		s.order = {}
		for i = 1, table.getn(ZBAR_ALL_BUTTONS) do
			s.order[i] = ZBAR_ALL_BUTTONS[i]
		end
	end

	if type(s.visible) ~= "table" then
		s.visible = {}
	end

	-- Migration: ensure every known button is present in the order list and
	-- has an explicit visible entry.
	local present = {}
	for _, v in ipairs(s.order) do
		present[v] = true
	end
	for _, v in ipairs(ZBAR_ALL_BUTTONS) do
		if not present[v] then
			table.insert(s.order, v)
		end
		if s.visible[v] == nil then
			s.visible[v] = true
		end
	end

	return s
end

-- Returns true when the zBar feature is both enabled AND the anchor frame
-- has been created in memory.
function MTH_ZBar_IsActive()
	local s = MTH_ZBar_GetSaved()
	return (s.enabled == true) and (getglobal(ZBAR_FRAME_NAME) ~= nil)
end

-- ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
-- Position persistence
-- ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

function MTH_ZBar_SavePosition()
	local bar = getglobal(ZBAR_FRAME_NAME)
	if not (bar and bar.GetPoint) then return end
	local s = MTH_ZBar_GetSaved()
	local point, _, relPoint, x, y = bar:GetPoint()
	if not point then return end
	s.point    = tostring(point)
	s.relPoint = tostring(relPoint or point)
	s.x        = math.floor((tonumber(x) or 0) + 0.5)
	s.y        = math.floor((tonumber(y) or 0) + 0.5)
end

-- ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
-- Anchor frame creation
-- ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

-- Returns the invisible anchor frame (used internally and by button drag code).
function MTH_ZBar_GetAnchor()
	return getglobal(ZBAR_FRAME_NAME)
end

function MTH_ZBar_EnsureAnchor()
	local existing = getglobal(ZBAR_FRAME_NAME)
	if existing then
		existing:Show()
		return existing
	end

	local s = MTH_ZBar_GetSaved()

	-- Invisible 1x1 movable frame — used only as a position anchor for the bar.
	-- Users interact via the zButton buttons themselves (Alt+drag any of them).
	local bar = CreateFrame("Frame", ZBAR_FRAME_NAME, UIParent)
	if not bar then return nil end

	bar:SetWidth(1)
	bar:SetHeight(1)
	bar:SetFrameStrata("MEDIUM")
	bar:SetFrameLevel(5)
	bar:SetMovable(true)
	bar:SetClampedToScreen(true)

	-- Restore saved position (or fall back to a sensible default)
	bar:ClearAllPoints()
	if s.point and s.x and s.y then
		bar:SetPoint(s.point, UIParent, s.relPoint or s.point, s.x, s.y)
	else
		bar:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 400, -140)
	end

	bar:Show()
	return bar
end

-- ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
-- Layout engine
-- ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

-- Anchors every included+enabled zButton parent relative to the zBar anchor
-- (or the previous button in the chain).
function MTH_ZBar_ApplyLayout()
	local s = MTH_ZBar_GetSaved()
	if not s.enabled then return end

	local bar = getglobal(ZBAR_FRAME_NAME)
	if not bar then return end

	local direction = s.direction or "HORIZONTAL"
	local spacing   = tonumber(s.spacing) or 4

	local prevFrame = bar
	local count     = 0
	local placed    = {}

	for i = 1, table.getn(s.order) do
		local buttonName = s.order[i]
		if type(buttonName) == "string" then
			local btn = getglobal(buttonName)

			local globalEnabled = ZHunterMod_Saved
				and type(ZHunterMod_Saved[buttonName]) == "table"
				and ZHunterMod_Saved[buttonName]["enabled"] ~= false
				and ZHunterMod_Saved[buttonName]["enabled"] ~= 0
			local zbarVisible = s.visible[buttonName] ~= false

			if btn and globalEnabled and zbarVisible then
				btn:ClearAllPoints()
				if direction == "HORIZONTAL" then
					btn:SetPoint("LEFT", prevFrame, "RIGHT", spacing, 0)
				else
					btn:SetPoint("TOP", prevFrame, "BOTTOM", 0, -spacing)
				end
				-- Size, expand direction and child arrangement are handled by each
				-- bar's own _SetupSizeAndPosition, which now calls MTH_ZBar_ApplyToButton.
				local setupFunc = getglobal(buttonName .. "_SetupSizeAndPosition")
				if type(setupFunc) == "function" then
					setupFunc()
				end
				prevFrame = btn
				count = count + 1
				placed[buttonName] = true
			end
		end
	end

	-- For every button NOT placed in the bar, call its own setup function so that:
	-- * disabled buttons get Hide() called on them immediately
	-- * excluded buttons get their individual size/expand/position applied
	for _, buttonName in ipairs(ZBAR_ALL_BUTTONS) do
		if not placed[buttonName] then
			local setupFunc = getglobal(buttonName .. "_SetupSizeAndPosition")
			if type(setupFunc) == "function" then
				setupFunc()
			end
		end
	end
end

-- ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
-- Per-button zBar override (called from each zButton's _SetupSizeAndPosition)
-- ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

-- When zBar is active this is the MASTER for size, expand direction and child
-- layout. Each zButton's _SetupSizeAndPosition calls this first; if it returns
-- true the bar must skip its own saved settings entirely.
function MTH_ZBar_ApplyToButton(btn, displayCount)
	if not (type(MTH_ZBar_IsActive) == "function" and MTH_ZBar_IsActive()) then
		return false
	end
	local s      = MTH_ZBar_GetSaved()
	local btnKey = (btn and btn.name) or (btn and btn.GetName and btn:GetName()) or ""
	-- Only take master control if this button is actually placed in the active bar.
	local globalEnabled = ZHunterMod_Saved
		and type(ZHunterMod_Saved[btnKey]) == "table"
		and ZHunterMod_Saved[btnKey]["enabled"] ~= false
		and ZHunterMod_Saved[btnKey]["enabled"] ~= 0
	if not globalEnabled or s.visible[btnKey] == false then
		return false
	end
	local btnSize   = tonumber(s.size) or 36
	local expandDir = s.childexpand  or "BOTTOM"
	local arrange   = s.childarrange or "VERTICAL"
	local arHoriz   = (expandDir == "LEFT")
	local arVert    = (expandDir == "TOP")
	ZSpellButton_SetSize(btn, btnSize)
	ZSpellButton_SetExpandDirection(btn, expandDir)
	if displayCount and displayCount > 1 then
		local rows = (arrange == "VERTICAL") and displayCount or 1
		ZSpellButton_ArrangeChildren(btn, rows, displayCount, arHoriz, arVert)
	end
	if btn.circle then btn.circle:Hide() end
	return true
end

-- ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
-- Enable / disable
-- ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

-- Restores each bar to its individually saved position and hides the anchor.
function MTH_ZBar_Release()
	local bar = getglobal(ZBAR_FRAME_NAME)
	if bar then bar:Hide() end

	for _, buttonName in ipairs(ZBAR_ALL_BUTTONS) do
		local btn = getglobal(buttonName)
		if btn and ZHunterMod_Saved and type(ZHunterMod_Saved[buttonName]) == "table" then
			-- Restore individually saved position
			local parentSaved = ZHunterMod_Saved[buttonName]["parent"]
			if type(parentSaved) == "table" then
				local px     = tonumber(parentSaved["x"])
				local py     = tonumber(parentSaved["y"])
				local point  = parentSaved["point"]
				local rPoint = parentSaved["relativePoint"] or point
				if px and py and type(point) == "string" and point ~= "" then
					btn:ClearAllPoints()
					btn:SetPoint(point, UIParent, rPoint, px, py)
				end
			end
			-- Restore size, circle, expand direction and child layout from the bar's own saved settings
			local setupFunc = getglobal(buttonName .. "_SetupSizeAndPosition")
			if type(setupFunc) == "function" then
				setupFunc()
			end
		end
	end
end

-- Called when the user toggles the Enable checkbox in the options.
function MTH_ZBar_SetEnabled(enabled)
	local s   = MTH_ZBar_GetSaved()
	s.enabled = enabled and true or false
	if enabled then
		MTH_ZBar_EnsureAnchor()
		MTH_ZBar_ApplyLayout()
	else
		MTH_ZBar_Release()
	end
end

-- Resize all bar buttons (and persist the value).
function MTH_ZBar_SetSize(size)
	local s = MTH_ZBar_GetSaved()
	s.size = tonumber(size) or 36
	if s.enabled and type(MTH_ZBar_ApplyLayout) == "function" then
		MTH_ZBar_ApplyLayout()
	end
end

-- Called from DeferredInit / RestoreRuntimeFeatureFlags after saved vars are
-- fully loaded; creates the anchor and applies layout only when enabled.
function MTH_ZBar_Init()
	local s = MTH_ZBar_GetSaved()

	-- One-time migration: fix firstbutton values corrupted to "BOTTOM" by an
	-- early version of zBar that incorrectly wrote per-bar saved variables.
	if not s._firstbutton_fixed then
		for _, buttonName in ipairs(ZBAR_ALL_BUTTONS) do
			if ZHunterMod_Saved and type(ZHunterMod_Saved[buttonName]) == "table" then
				if ZHunterMod_Saved[buttonName]["firstbutton"] == "BOTTOM" then
					ZHunterMod_Saved[buttonName]["firstbutton"] = "RIGHT"
				end
			end
		end
		s._firstbutton_fixed = true
		-- Re-run each bar's own setup now so the fix takes immediate visual effect
		for _, buttonName in ipairs(ZBAR_ALL_BUTTONS) do
			local setupFunc = getglobal(buttonName .. "_SetupSizeAndPosition")
			if type(setupFunc) == "function" then setupFunc() end
		end
	end

	if s.enabled then
		MTH_ZBar_EnsureAnchor()
		MTH_ZBar_ApplyLayout()
	end
end
