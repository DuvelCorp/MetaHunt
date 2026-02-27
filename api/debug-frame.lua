------------------------------------------------------
-- MetaHunt: Debug Frame
-- Displays errors and debug messages in a scrollable frame
------------------------------------------------------

MTH_DebugFrame = {
	frame = nil,
	scrollFrame = nil,
	scrollText = nil,
	errors = {},
	maxErrors = 500,
	isVisible = false,
	initialized = false,
	captureCount = 0,
	infoCount = 0
}

local function MTH_DF_L(key, default)
	if MTH and MTH.GetLocalization then
		return MTH:GetLocalization(key, default)
	end
	return default or key
end

function MTH_DebugFrame:Initialize()
	if self.initialized then
		return
	end
	self.initialized = true

	-- Create main frame
	self.frame = CreateFrame("Frame", "MTH_DebugFrameWindow", UIParent)
	self.frame:SetWidth(800)
	self.frame:SetHeight(400)
	self.frame:SetPoint("CENTER", UIParent, "CENTER")
	self.frame:SetFrameStrata("DIALOG")
	self.frame:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
		tile = true,
		tileSize = 32,
		edgeSize = 32,
		insets = { left = 11, right = 12, top = 12, bottom = 11 }
	})
	self.frame:SetBackdropColor(0, 0, 0, 0.8)
	self.frame:SetMovable(true)
	self.frame:EnableMouse(true)
	self.frame:RegisterForDrag("LeftButton")
	self.frame:SetScript("OnDragStart", function() self.frame:StartMoving() end)
	self.frame:SetScript("OnDragStop", function() self.frame:StopMovingOrSizing() end)
	if UISpecialFrames then
		local already = false
		for i = 1, table.getn(UISpecialFrames) do
			if UISpecialFrames[i] == "MTH_DebugFrameWindow" then
				already = true
				break
			end
		end
		if not already then
			table.insert(UISpecialFrames, "MTH_DebugFrameWindow")
		end
	end

	-- Title
	local title = self.frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	title:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 20, -15)
	title:SetText(MTH_DF_L("DEBUG_TITLE", "MetaHunt Debug - Errors & Messages"))

	-- Close button
	local closeButton = CreateFrame("Button", nil, self.frame, "UIPanelButtonTemplate")
	closeButton:SetPoint("TOPRIGHT", self.frame, "TOPRIGHT", -8, -8)
	closeButton:SetWidth(22)
	closeButton:SetHeight(22)
	closeButton:SetText(MTH_DF_L("COMMON_CLOSE_SHORT", "X"))
	closeButton:SetScript("OnClick", function() MTH_DebugFrame:Hide() end)

	-- Clear button
	local clearButton = CreateFrame("Button", nil, self.frame, "GameMenuButtonTemplate")
	clearButton:SetPoint("BOTTOMLEFT", self.frame, "BOTTOMLEFT", 10, 10)
	clearButton:SetWidth(100)
	clearButton:SetHeight(25)
	clearButton:SetText(MTH_DF_L("COMMON_CLEAR", "Clear"))
	clearButton:SetScript("OnClick", function() MTH_DebugFrame:Clear() end)

	-- Select-all button
	local copyButton = CreateFrame("Button", nil, self.frame, "GameMenuButtonTemplate")
	copyButton:SetPoint("LEFT", clearButton, "RIGHT", 10, 0)
	copyButton:SetWidth(100)
	copyButton:SetHeight(25)
	copyButton:SetText(MTH_DF_L("COMMON_SELECT_ALL", "Select All"))
	copyButton:SetScript("OnClick", function() MTH_DebugFrame:SelectAllText() end)

	-- Scroll frame + text content with proper vertical scrollbar
	self.scrollFrame = CreateFrame("ScrollFrame", "MTH_DebugScrollFrame", self.frame, "UIPanelScrollFrameTemplate")
	self.scrollFrame:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 15, -50)
	self.scrollFrame:SetPoint("BOTTOMRIGHT", self.frame, "BOTTOMRIGHT", -35, 45)

	self.scrollText = CreateFrame("EditBox", "MTH_DebugScrollText", self.scrollFrame)
	self.scrollText:SetMultiLine(true)
	self.scrollText:SetMaxLetters(999999)
	self.scrollText:SetFont("Fonts\\FRIZQT__.TTF", 11, "")
	self.scrollText:SetTextColor(0.8, 0.8, 0.8, 1)
	self.scrollText:SetWidth(730)
	self.scrollText:SetHeight(1)
	self.scrollText:EnableMouse(true)
	self.scrollText:SetScript("OnCursorChanged", function()
		if not MTH_DebugFrame.scrollFrame then
			return
		end
		local width = MTH_DebugFrame.scrollFrame:GetWidth()
		if width and width > 20 then
			MTH_DebugFrame.scrollText:SetWidth(width - 20)
		end
	end)
	self.scrollText:SetScript("OnEscapePressed", function() self.scrollText:ClearFocus() end)
	self.scrollText:SetAutoFocus(false)
	self.scrollText:EnableMouseWheel(true)
	self.scrollText:SetScript("OnMouseWheel", function()
		if not MTH_DebugFrame.scrollFrame then
			return
		end
		local curr = MTH_DebugFrame.scrollFrame:GetVerticalScroll()
		local step = 24
		if arg1 and arg1 > 0 then
			MTH_DebugFrame.scrollFrame:SetVerticalScroll(curr - step)
		else
			MTH_DebugFrame.scrollFrame:SetVerticalScroll(curr + step)
		end
	end)
	self.scrollText:SetScript("OnTextChanged", nil)

	self.scrollFrame:SetScrollChild(self.scrollText)

	-- Hide by default
	self.frame:Hide()
	self.isVisible = false
end

function MTH_DebugFrame:AddError(message)
	if not message then return end
	
	self.captureCount = self.captureCount + 1
	
	if string.len(message) > 1000 then
		message = string.sub(message, 1, 1000) .. "..."
	end

	table.insert(self.errors, 1, {
		time = date("%H:%M:%S"),
		message = message,
		level = "error"
	})

	-- Limit stored errors
	if table.getn(self.errors) > self.maxErrors then
		table.remove(self.errors, self.maxErrors + 1)
	end

	self:UpdateDisplay()
end

function MTH_DebugFrame:AddInfo(message)
	if not message then return end

	self.infoCount = self.infoCount + 1

	if string.len(message) > 1000 then
		message = string.sub(message, 1, 1000) .. "..."
	end

	table.insert(self.errors, 1, {
		time = date("%H:%M:%S"),
		message = message,
		level = "info"
	})

	if table.getn(self.errors) > self.maxErrors then
		table.remove(self.errors, self.maxErrors + 1)
	end

	self:UpdateDisplay()
end

function MTH_DebugFrame:UpdateDisplay()
	if not self.scrollText or not self.initialized then
		return
	end

	local text = string.format(MTH_DF_L("DEBUG_SUMMARY_ERRORS", "=== Errors Captured: %s ==="), tostring(self.captureCount)) .. "\n"
	text = text .. string.format(MTH_DF_L("DEBUG_SUMMARY_INFO", "=== Info Captured: %s ==="), tostring(self.infoCount or 0)) .. "\n"
	text = text .. string.format(MTH_DF_L("DEBUG_SUMMARY_QUEUE", "=== Total in queue: %s ==="), tostring(table.getn(self.errors))) .. "\n\n"
	
	for i = 1, table.getn(self.errors) do
		local err = self.errors[i]
		text = text .. "[" .. err.time .. "] " .. err.message .. "\n"
	end

	local _, lineCount = string.gsub(text, "\n", "\n")
	local lineHeight = 13
	local contentHeight = (lineCount + 1) * lineHeight + 8
	if contentHeight < 1 then
		contentHeight = 1
	end
	self.scrollText:SetHeight(contentHeight)
	self.scrollText:SetText(text)
	if self.scrollFrame then
		self.scrollFrame:SetVerticalScroll(0)
	end
end

function MTH_DebugFrame:Toggle()
	if self.isVisible then
		self.frame:Hide()
		self.isVisible = false
	else
		if not self.initialized then
			self:Initialize()
		end
		self.frame:Show()
		self.isVisible = true
		self:UpdateDisplay()
	end
end

function MTH_DebugFrame:Show()
	if not self.initialized then
		self:Initialize()
	end
	self.frame:Show()
	self.isVisible = true
	self:UpdateDisplay()
end

function MTH_DebugFrame:Hide()
	if self.frame then
		self.frame:Hide()
	end
	self.isVisible = false
end

function MTH_DebugFrame:Clear()
	self.errors = {}
	self.captureCount = 0
	self.infoCount = 0
	self:UpdateDisplay()
	if self.initialized and self.isVisible then
		if MTH and MTH.Print then
			MTH:Print(MTH_DF_L("DEBUG_CLEARED", "Debug frame cleared"))
		end
	end
end

function MTH_DebugFrame:SelectAllText()
	if not self.scrollText or not self.initialized then
		return
	end
	-- Select all text
	self.scrollText:HighlightText(0, -1)
	self.scrollText:SetFocus()
	if MTH and MTH.Print then
		MTH:Print(MTH_DF_L("DEBUG_ALL_SELECTED", "All text selected - press Ctrl+C to copy"))
	end
end

------------------------------------------------------
-- Error Capture Hooks
------------------------------------------------------
local function MTH_DF_AddMessageCapture(msg)
	if msg then
		local msgStr = tostring(msg)
		if string.find(msgStr, "%.lua:%d+:") then
			MTH_DebugFrame:AddError(msgStr)
		end
	end
end

local function MTH_DF_IsGlobalCaptureEnabled()
	if MTH and MTH.GetConfig then
		return MTH:GetConfig("debug", "globalErrorCapture", false) and true or false
	end
	return false
end

local function MTH_DF_SetGlobalCaptureEnabled(enabled)
	if MTH and MTH.SetConfig then
		MTH:SetConfig("debug", "globalErrorCapture", enabled and true or false)
	end
end

local function MTH_DF_InstallHooks()
	if MTH_DebugFrame.hooksInstalled then
		return
	end
	if not MTH_DF_IsGlobalCaptureEnabled() then
		return
	end

	if DEFAULT_CHAT_FRAME and type(DEFAULT_CHAT_FRAME.AddMessage) == "function" then
		MTH_DebugFrame.originalAddMessage = DEFAULT_CHAT_FRAME.AddMessage
		MTH_DebugFrame.addMessageHook = function(self, msg, arg1, arg2, arg3, arg4, arg5)
			MTH_DF_AddMessageCapture(msg)
			if MTH_DebugFrame.originalAddMessage then
				return MTH_DebugFrame.originalAddMessage(self, msg, arg1, arg2, arg3, arg4, arg5)
			end
		end
		DEFAULT_CHAT_FRAME.AddMessage = MTH_DebugFrame.addMessageHook
	end

	if _G and type(_G["ScriptErrors"]) == "function" then
		MTH_DebugFrame.originalScriptErrors = _G["ScriptErrors"]
		MTH_DebugFrame.scriptErrorsHook = function(msg)
			if msg then
				MTH_DebugFrame:AddError(tostring(msg))
			end
			if MTH_DebugFrame.originalScriptErrors then
				return MTH_DebugFrame.originalScriptErrors(msg)
			end
		end
		_G["ScriptErrors"] = MTH_DebugFrame.scriptErrorsHook
	end

	MTH_DebugFrame.hooksInstalled = true
end

local function MTH_DF_UninstallHooks()
	if not MTH_DebugFrame.hooksInstalled then
		return
	end

	if DEFAULT_CHAT_FRAME
		and MTH_DebugFrame.addMessageHook
		and DEFAULT_CHAT_FRAME.AddMessage == MTH_DebugFrame.addMessageHook
		and MTH_DebugFrame.originalAddMessage
	then
		DEFAULT_CHAT_FRAME.AddMessage = MTH_DebugFrame.originalAddMessage
	end

	if _G
		and MTH_DebugFrame.scriptErrorsHook
		and _G["ScriptErrors"] == MTH_DebugFrame.scriptErrorsHook
		and MTH_DebugFrame.originalScriptErrors
	then
		_G["ScriptErrors"] = MTH_DebugFrame.originalScriptErrors
	end

	MTH_DebugFrame.hooksInstalled = false
end

function MTH_DebugFrame:IsGlobalCaptureEnabled()
	return MTH_DF_IsGlobalCaptureEnabled()
end

function MTH_DebugFrame:SetGlobalCaptureEnabled(enabled)
	local want = enabled and true or false
	MTH_DF_SetGlobalCaptureEnabled(want)
	if want then
		MTH_DF_InstallHooks()
	else
		MTH_DF_UninstallHooks()
	end
end

MTH_DebugFrame.InstallHooks = MTH_DF_InstallHooks
MTH_DebugFrame.UninstallHooks = MTH_DF_UninstallHooks

-- Event listener for addon load
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:SetScript("OnEvent", function(self, event, addonName)
	if event == "ADDON_LOADED" and addonName == "MetaHunt" then
		if MTH and MTH.GetConfig then
			MTH_DF_SetGlobalCaptureEnabled(MTH:GetConfig("debug", "globalErrorCapture", false))
		end
		MTH_DF_InstallHooks()
		MTH_DebugFrame:Initialize()
		if MTH and MTH.Print then
			local mode = MTH_DF_IsGlobalCaptureEnabled() and "legacy-global" or "safe-local"
			MTH:Print("=== MetaHunt Debug Frame Initialized (" .. mode .. ") ===", "debug")
		end
	end
end)
