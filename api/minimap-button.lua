------------------------------------------------------
-- MetaHunt Minimap Button
--
-- NOTE: The namespace table is MTH_MinimapButton (a plain Lua table).
-- The actual UI frame is named "MTH_MinimapBtn" to avoid a global
-- collision — CreateFrame("...", "MTH_MinimapButton", ...) would
-- OVERWRITE the namespace table with the frame object, orphaning
-- all methods and .frame/.icon references.  pfUI iterates Minimap
-- children by name and calls _G[name]:GetHeight(); if the global is
-- a plain {} table instead of a frame, that call crashes.
------------------------------------------------------

if not MTH_MinimapButton then
	MTH_MinimapButton = {}
end

local function MTH_MB_L(key, default)
	if MTH and MTH.GetLocalization then
		return MTH:GetLocalization(key, default)
	end
	return default or key
end

local function MTH_MB_GetStore()
	if not MTH_CharSavedVariables then
		MTH_CharSavedVariables = {}
	end
	if type(MTH_CharSavedVariables.minimapButton) ~= "table" then
		MTH_CharSavedVariables.minimapButton = {}
	end
	local store = MTH_CharSavedVariables.minimapButton
	if store.angle == nil then
		store.angle = 220
	end
	return store
end

local function MTH_MB_GetRadius()
	return 80
end

local function MTH_MB_UpdatePosition()
	if not MTH_MinimapButton.frame then
		return
	end
	local store = MTH_MB_GetStore()
	local angle = tonumber(store.angle) or 220
	local rad = math.rad(angle)
	local radius = MTH_MB_GetRadius()
	local x = math.cos(rad) * radius
	local y = math.sin(rad) * radius
	MTH_MinimapButton.frame:ClearAllPoints()
	MTH_MinimapButton.frame:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

local function MTH_MB_UpdateDragPosition()
	if not MTH_MinimapButton.frame then
		return
	end
	local mx, my = Minimap:GetCenter()
	local px, py = GetCursorPosition()
	local scale = Minimap:GetEffectiveScale()
	if scale and scale ~= 0 then
		px = px / scale
		py = py / scale
	end
	local dx = px - mx
	local dy = py - my
	local angle = math.deg(math.atan2(dy, dx))
	local store = MTH_MB_GetStore()
	store.angle = angle
	MTH_MB_UpdatePosition()
end

local function MTH_MB_SetHunterIcon(texture)
	if not texture then
		return
	end
	texture:SetTexture("Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES")
	if CLASS_ICON_TCOORDS and CLASS_ICON_TCOORDS["HUNTER"] then
		local coords = CLASS_ICON_TCOORDS["HUNTER"]
		texture:SetTexCoord(coords[1], coords[2], coords[3], coords[4])
	else
		texture:SetTexCoord(0, 0.25, 0.25, 0.5)
	end
end

function MTH_MinimapButton:Initialize()
	if self.frame then
		MTH_MB_UpdatePosition()
		self.frame:Show()
		return
	end

	-- Frame name is MTH_MinimapBtn (NOT "MTH_MinimapButton") to avoid
	-- overwriting the namespace table in _G.
	local button = CreateFrame("Button", "MTH_MinimapBtn", Minimap)
	if not button then
		return
	end

	button:SetWidth(31)
	button:SetHeight(31)
	button:SetFrameStrata("MEDIUM")
	button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	button:RegisterForDrag("LeftButton")

	local border = button:CreateTexture(nil, "OVERLAY")
	border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
	border:SetWidth(54)
	border:SetHeight(54)
	border:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)

	local icon = button:CreateTexture(nil, "BACKGROUND")
	icon:SetWidth(20)
	icon:SetHeight(20)
	icon:SetPoint("CENTER", button, "CENTER", 0, 0)
	MTH_MB_SetHunterIcon(icon)

	local highlight = button:CreateTexture(nil, "HIGHLIGHT")
	highlight:SetTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
	highlight:SetBlendMode("ADD")
	highlight:SetWidth(31)
	highlight:SetHeight(31)
	highlight:SetPoint("CENTER", button, "CENTER", 0, 0)

	button:SetScript("OnEnter", function()
		if not this then return end
		GameTooltip:SetOwner(this, "ANCHOR_LEFT")
		GameTooltip:SetText(MTH_MB_L("MINIMAP_TITLE", "MetaHunt"), 1, 0.82, 0)
		GameTooltip:AddLine(MTH_MB_L("MINIMAP_HINT_LEFT_CLICK", "Left-Click: Open Hunter Book"), 1, 1, 1)
		GameTooltip:AddLine(MTH_MB_L("MINIMAP_HINT_RIGHT_CLICK", "Right-Click: Open MetaHunt Options"), 1, 1, 1)
		GameTooltip:AddLine(MTH_MB_L("MINIMAP_HINT_DRAG", "Drag: Move button"), 0.8, 0.8, 0.8)
		GameTooltip:Show()
	end)

	button:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)

	button:SetScript("OnDragStart", function()
		if not this then return end
		this.dragging = 1
		this:SetScript("OnUpdate", function()
			MTH_MB_UpdateDragPosition()
		end)
	end)

	button:SetScript("OnDragStop", function()
		if not this then return end
		this.dragging = nil
		this:SetScript("OnUpdate", nil)
		MTH_MB_UpdateDragPosition()
	end)

	button:SetScript("OnClick", function()
		local mouseButton = arg1
		if mouseButton == "RightButton" then
			if type(MTH_OpenOptions) == "function" then
				MTH_OpenOptions("General")
			end
			return
		end

		if type(MTH_OpenHunterBook) == "function" then
			MTH_OpenHunterBook()
		elseif type(MTH_ToggleHunterBook) == "function" then
			MTH_ToggleHunterBook()
		end
	end)

	self.frame = button
	self.icon = icon
	MTH_MB_UpdatePosition()
end

local loader = CreateFrame("Frame", "MTH_MinimapLoader")
loader:RegisterEvent("ADDON_LOADED")
loader:SetScript("OnEvent", function()
	if event == "ADDON_LOADED" and arg1 == "MetaHunt" then
		MTH_MinimapButton:Initialize()
		this:UnregisterAllEvents()
		this:SetScript("OnEvent", nil)
	end
end)
