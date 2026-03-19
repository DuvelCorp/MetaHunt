------------------------------------------------------
-- MetaHunt Profile Management Options Panel
------------------------------------------------------

local MAX_PROFILE_ROWS = 15
local MAX_CHAR_ROWS    = 10
local ROW_H            = 26

-- Row pools — anonymous frames created once against scroll content, reused each refresh
local gProfileRows = {}   -- [i] = { frame, nameText, infoText, loadBtn, delBtn }
local gCharRows    = {}   -- [i] = { frame, nameText, infoText, copyBtn }

-- Static element refs created once
local gActiveLabel = nil
local gSetupDone   = false

-- Pending confirmations — globals so StaticPopup OnAccept can read them
MTH_PROFILE_PENDING_LOAD   = nil
MTH_PROFILE_PENDING_DELETE = nil
MTH_PROFILE_PENDING_SAVE   = nil

-- ── Static popup dialogs ───────────────────────────────────────────────────

StaticPopupDialogs["MTH_PROFILE_LOAD_CONFIRM"] = {
	text = "Load profile \"%s\"?\n\nCurrent settings will be replaced.\nThe UI will reload to apply all changes.",
	button1 = "Load & Reload",
	button2 = "Cancel",
	OnAccept = function()
		if MTH_PROFILE_PENDING_LOAD then
			local ok, err = MTH_Profile_Load(MTH_PROFILE_PENDING_LOAD)
			MTH_PROFILE_PENDING_LOAD = nil
			if ok then
				ReloadUI()
			elseif MTH and MTH.Print then
				MTH:Print("Profile load failed: " .. tostring(err), "error")
			end
		end
	end,
	timeout = 0, whileDead = 0, hideOnEscape = 1,
}

StaticPopupDialogs["MTH_PROFILE_DELETE_CONFIRM"] = {
	text = "Delete profile \"%s\"?\n\nThis cannot be undone.",
	button1 = "Delete",
	button2 = "Cancel",
	OnAccept = function()
		if MTH_PROFILE_PENDING_DELETE then
			MTH_Profile_Delete(MTH_PROFILE_PENDING_DELETE)
			MTH_PROFILE_PENDING_DELETE = nil
			MTH_SetupProfilesOptions()
		end
	end,
	timeout = 0, whileDead = 0, hideOnEscape = 1,
}

StaticPopupDialogs["MTH_PROFILE_SAVE_CONFIRM"] = {
	text = "Profile \"%s\" already exists.\nOverwrite with current settings?",
	button1 = "Overwrite",
	button2 = "Cancel",
	OnAccept = function()
		if MTH_PROFILE_PENDING_SAVE then
			MTH_Profile_Save(MTH_PROFILE_PENDING_SAVE)
			MTH_PROFILE_PENDING_SAVE = nil
			MTH_SetupProfilesOptions()
		end
	end,
	timeout = 0, whileDead = 0, hideOnEscape = 1,
}

-- ── internal helpers ───────────────────────────────────────────────────────

local function PROF_TrimString(s)
	if type(s) ~= "string" then return "" end
	return string.gsub(s, "^%s*(.-)%s*$", "%1")
end

local function PROF_DoSave(rawName)
	local name = PROF_TrimString(rawName)
	if string.len(name) == 0 then
		if MTH and MTH.Print then MTH:Print("Enter a profile name first.", "error") end
		return
	end
	if string.len(name) > 50 then
		if MTH and MTH.Print then MTH:Print("Profile name too long (50 chars max).", "error") end
		return
	end
	local existing = type(MTH_SavedVariables) == "table"
		and type(MTH_SavedVariables.profiles) == "table"
		and MTH_SavedVariables.profiles[name] ~= nil
	if existing then
		MTH_PROFILE_PENDING_SAVE = name
		StaticPopup_Show("MTH_PROFILE_SAVE_CONFIRM", name)
	else
		MTH_Profile_Save(name)
		if MTH and MTH.Print then MTH:Print("Profile saved: " .. name) end
		MTH_SetupProfilesOptions()
	end
end

-- ── scroll frames + row pool creation (idempotent) ────────────────────────

local function PROF_EnsureScrollFrames(container)
	if not MTH_GetFrame("MetaHuntOptionsProfilesScroll") then
		local sf = CreateFrame("ScrollFrame", "MetaHuntOptionsProfilesScroll", container, "UIPanelScrollFrameTemplate")
		local sc = CreateFrame("Frame", "MetaHuntOptionsProfilesContent", sf)
		sc:SetWidth(510)
		sc:SetHeight(MAX_PROFILE_ROWS * ROW_H + 4)
		sf:SetScrollChild(sc)
	end
	if not MTH_GetFrame("MetaHuntOptionsCharScroll") then
		local csf = CreateFrame("ScrollFrame", "MetaHuntOptionsCharScroll", container, "UIPanelScrollFrameTemplate")
		local csc = CreateFrame("Frame", "MetaHuntOptionsCharContent", csf)
		csc:SetWidth(510)
		csc:SetHeight(MAX_CHAR_ROWS * ROW_H + 4)
		csf:SetScrollChild(csc)
	end
end

local function PROF_EnsureProfileRows()
	local sc = MTH_GetFrame("MetaHuntOptionsProfilesContent")
	if not sc then return end
	for i = 1, MAX_PROFILE_ROWS do
		if not gProfileRows[i] then
			local row = CreateFrame("Frame", nil, sc)
			row:SetHeight(ROW_H)
			row:SetWidth(510)
			row:SetPoint("TOPLEFT", sc, "TOPLEFT", 0, -(i - 1) * ROW_H)

			local nameText = row:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
			nameText:SetPoint("LEFT", row, "LEFT", 4, 2)
			nameText:SetWidth(210)
			nameText:SetJustifyH("LEFT")

			local infoText = row:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
			infoText:SetPoint("LEFT", row, "LEFT", 218, 2)
			infoText:SetWidth(155)
			infoText:SetJustifyH("LEFT")
			infoText:SetTextColor(0.55, 0.55, 0.55)

			local loadBtn = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
			loadBtn:SetWidth(58)
			loadBtn:SetHeight(20)
			loadBtn:SetPoint("RIGHT", row, "RIGHT", -62, 0)
			loadBtn:SetText("Load")

			local delBtn = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
			delBtn:SetWidth(58)
			delBtn:SetHeight(20)
			delBtn:SetPoint("RIGHT", row, "RIGHT", 0, 0)
			delBtn:SetText("Delete")

			gProfileRows[i] = { frame = row, nameText = nameText, infoText = infoText, loadBtn = loadBtn, delBtn = delBtn }
		end
	end
end

local function PROF_EnsureCharRows()
	local csc = MTH_GetFrame("MetaHuntOptionsCharContent")
	if not csc then return end
	for i = 1, MAX_CHAR_ROWS do
		if not gCharRows[i] then
			local row = CreateFrame("Frame", nil, csc)
			row:SetHeight(ROW_H)
			row:SetWidth(510)
			row:SetPoint("TOPLEFT", csc, "TOPLEFT", 0, -(i - 1) * ROW_H)

			local nameText = row:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
			nameText:SetPoint("LEFT", row, "LEFT", 4, 2)
			nameText:SetWidth(250)
			nameText:SetJustifyH("LEFT")
			nameText:SetTextColor(0.70, 0.85, 1.00)

			local infoText = row:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
			infoText:SetPoint("LEFT", row, "LEFT", 258, 2)
			infoText:SetWidth(120)
			infoText:SetJustifyH("LEFT")
			infoText:SetTextColor(0.55, 0.55, 0.55)

			local copyBtn = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
			copyBtn:SetWidth(80)
			copyBtn:SetHeight(20)
			copyBtn:SetPoint("RIGHT", row, "RIGHT", 0, 0)
			copyBtn:SetText("Import")

			gCharRows[i] = { frame = row, nameText = nameText, infoText = infoText, copyBtn = copyBtn }
		end
	end
end

-- ── dynamic refresh functions ──────────────────────────────────────────────

local function PROF_RefreshActive()
	if not gActiveLabel then return end
	local active = type(MTH_Profile_GetActive) == "function" and MTH_Profile_GetActive()
	if active then
		gActiveLabel:SetText("Active:  |cffffd200" .. active .. "|r")
		gActiveLabel:SetTextColor(0.90, 0.90, 0.90)
	else
		gActiveLabel:SetText("Active:  |cff888888Custom (unsaved)|r")
		gActiveLabel:SetTextColor(0.90, 0.90, 0.90)
	end
	gActiveLabel:Show()
end

local function PROF_RefreshProfileList()
	PROF_EnsureProfileRows()
	local profiles = type(MTH_Profile_GetList) == "function" and MTH_Profile_GetList() or {}
	local active   = type(MTH_Profile_GetActive) == "function" and MTH_Profile_GetActive()
	local n        = table.getn(profiles)

	local sc = MTH_GetFrame("MetaHuntOptionsProfilesContent")
	if sc then
		sc:SetHeight(math.max(n * ROW_H + 4, ROW_H))
	end

	for i = 1, MAX_PROFILE_ROWS do
		local row  = gProfileRows[i]
		if not row then break end
		local name = profiles[i]
		if name then
			-- Name (with active indicator)
			if name == active then
				row.nameText:SetText(name .. "  |cff00cc44[active]|r")
			else
				row.nameText:SetText(name)
			end
			-- Info: date saved by who
			local p    = type(MTH_SavedVariables) == "table"
				and type(MTH_SavedVariables.profiles) == "table"
				and MTH_SavedVariables.profiles[name]
			local info = ""
			if type(p) == "table" then
				if p.savedAt and p.savedAt ~= "" then
					info = p.savedAt
				end
			end
			row.infoText:SetText(info)
			-- Wire buttons (SetScript replaces previous handler each refresh)
			local rowName = name
			row.loadBtn:SetScript("OnClick", function()
				MTH_PROFILE_PENDING_LOAD = rowName
				StaticPopup_Show("MTH_PROFILE_LOAD_CONFIRM", rowName)
			end)
			row.delBtn:SetScript("OnClick", function()
				MTH_PROFILE_PENDING_DELETE = rowName
				StaticPopup_Show("MTH_PROFILE_DELETE_CONFIRM", rowName)
			end)
			row.frame:Show()
			row.loadBtn:Show()
			row.delBtn:Show()
		else
			row.frame:Hide()
		end
	end
end

local function PROF_RefreshCharList()
	PROF_EnsureCharRows()
	local chars = type(MTH_Profile_GetCharList) == "function" and MTH_Profile_GetCharList() or {}
	local n     = table.getn(chars)

	local csc = MTH_GetFrame("MetaHuntOptionsCharContent")
	if csc then
		csc:SetHeight(math.max(n * ROW_H + 4, ROW_H))
	end

	for i = 1, MAX_CHAR_ROWS do
		local row    = gCharRows[i]
		if not row then break end
		local charKey = chars[i]
		if charKey then
			local snap = type(MTH_SavedVariables) == "table"
				and type(MTH_SavedVariables.charSnapshots) == "table"
				and MTH_SavedVariables.charSnapshots[charKey]
			local info = (type(snap) == "table" and snap.savedAt) and snap.savedAt or ""
			row.nameText:SetText(charKey)
			row.infoText:SetText(info)
			local ck = charKey
			row.copyBtn:SetScript("OnClick", function()
				local ok, pName = MTH_Profile_CopyFromChar(ck)
				if ok then
					MTH_SetupProfilesOptions()
					if MTH and MTH.Print then
						MTH:Print('Imported "' .. ck .. '" as profile "' .. tostring(pName) .. '".')
					end
				end
			end)
			row.frame:Show()
			row.copyBtn:Show()
		else
			row.frame:Hide()
		end
	end
end

-- ── main setup (static elements created once, dynamic lists refreshed every call) ──

function MTH_SetupProfilesOptions()
	local container = MTH_GetFrame("MetaHuntOptionsProfiles")
	if not container then return end

	if not gSetupDone then
		-- Title
		local title = container:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		title:SetPoint("TOPLEFT", container, "TOPLEFT", 6, -6)
		title:SetText("Profiles")
		title:SetTextColor(1.00, 0.82, 0.00)

		-- Active profile indicator
		gActiveLabel = container:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
		gActiveLabel:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -4)
		gActiveLabel:SetWidth(540)
		gActiveLabel:SetJustifyH("LEFT")

		-- ── Save As section ───────────────────────────────────────────────
		local saveHdr = container:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		saveHdr:SetPoint("TOPLEFT", gActiveLabel, "BOTTOMLEFT", 0, -10)
		saveHdr:SetText("Save current settings as:")
		saveHdr:SetTextColor(0.90, 0.90, 0.90)

		local eb = CreateFrame("EditBox", "MTH_ProfileNameInput", container, "InputBoxTemplate")
		eb:SetWidth(240)
		eb:SetHeight(20)
		eb:SetMaxLetters(50)
		eb:SetAutoFocus(false)
		eb:SetPoint("TOPLEFT", saveHdr, "BOTTOMLEFT", 2, -6)
		eb:SetScript("OnEnterPressed", function()
			PROF_DoSave(this:GetText())
			this:SetText("")
			this:ClearFocus()
		end)
		eb:SetScript("OnEscapePressed", function()
			this:SetText("")
			this:ClearFocus()
		end)

		local saveBtn = CreateFrame("Button", "MTH_ProfileSaveBtn", container, "UIPanelButtonTemplate")
		saveBtn:SetWidth(70)
		saveBtn:SetHeight(20)
		saveBtn:SetPoint("LEFT", eb, "RIGHT", 6, 0)
		saveBtn:SetText("Save")
		saveBtn:SetScript("OnClick", function()
			local box = MTH_GetFrame("MTH_ProfileNameInput")
			if box then
				PROF_DoSave(box:GetText())
				box:SetText("")
				box:ClearFocus()
			end
		end)

		-- ── Saved Profiles section ────────────────────────────────────────
		local profHdr = container:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		profHdr:SetPoint("TOPLEFT", eb, "BOTTOMLEFT", -2, -12)
		profHdr:SetText("Saved Profiles")
		profHdr:SetTextColor(1.00, 0.82, 0.00)

		local rule1 = container:CreateTexture(nil, "ARTWORK")
		rule1:SetPoint("TOPLEFT", profHdr, "BOTTOMLEFT", 0, -3)
		rule1:SetWidth(540)
		rule1:SetHeight(1)
		rule1:SetTexture(0.30, 0.30, 0.30, 0.80)

		PROF_EnsureScrollFrames(container)

		local sf = MTH_GetFrame("MetaHuntOptionsProfilesScroll")
		sf:SetPoint("TOPLEFT", rule1, "BOTTOMLEFT", 0, -4)
		sf:SetWidth(530)
		sf:SetHeight(170)
		sf:Show()

		-- ── Copy from Character section ───────────────────────────────────
		local charHdr = container:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		charHdr:SetPoint("TOPLEFT", sf, "BOTTOMLEFT", 0, -10)
		charHdr:SetText("Copy from Character")
		charHdr:SetTextColor(1.00, 0.82, 0.00)

		local charNote = container:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
		charNote:SetPoint("TOPLEFT", charHdr, "BOTTOMLEFT", 0, -2)
		charNote:SetWidth(540)
		charNote:SetJustifyH("LEFT")
		charNote:SetText("Snapshots are saved automatically on logout. Click Import to create a profile from one.")
		charNote:SetTextColor(0.60, 0.60, 0.60)

		local rule2 = container:CreateTexture(nil, "ARTWORK")
		rule2:SetPoint("TOPLEFT", charNote, "BOTTOMLEFT", 0, -3)
		rule2:SetWidth(540)
		rule2:SetHeight(1)
		rule2:SetTexture(0.30, 0.30, 0.30, 0.80)

		local csf = MTH_GetFrame("MetaHuntOptionsCharScroll")
		csf:SetPoint("TOPLEFT", rule2, "BOTTOMLEFT", 0, -4)
		csf:SetWidth(530)
		csf:SetHeight(140)
		csf:Show()

		gSetupDone = true
	end

	-- Refresh dynamic content every time the panel is opened
	PROF_RefreshActive()
	PROF_RefreshProfileList()
	PROF_RefreshCharList()
end
