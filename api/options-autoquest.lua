local MTH_AQ_READY = MTH_OptionsRequire and MTH_OptionsRequire("options-autoquest", {
	"MTH_GetFrame",
	"MTH_ClearContainer",
	"MTH_CreateCheckbox",
})

local function MTH_AQ_IsChecked(control)
	if not control or type(control.GetChecked) ~= "function" then
		return false
	end
	local checked = control:GetChecked()
	return checked == 1 or checked == true
end

local function MTH_AQ_EnsureStore()
	if type(MTH_CharSavedVariables) ~= "table" then
		MTH_CharSavedVariables = {}
	end
	if type(MTH_CharSavedVariables.autoquest) ~= "table" then
		MTH_CharSavedVariables.autoquest = {}
	end
	local store = MTH_CharSavedVariables.autoquest
	if type(MTH_CharSavedVariables.questautomation) == "table" then
		local legacy = MTH_CharSavedVariables.questautomation
		if store.scorpokDrazial == nil and legacy.scorpokDrazial ~= nil then
			store.scorpokDrazial = legacy.scorpokDrazial and true or false
		end
		if store.scorpokTooltip == nil and legacy.scorpokTooltip ~= nil then
			store.scorpokTooltip = legacy.scorpokTooltip and true or false
		end
	end
	if store.scorpokDrazial == nil then
		store.scorpokDrazial = false
	end
	if store.arrowsForSissies == nil then
		store.arrowsForSissies = false
	end
	return store
end

function MTH_SetupAutoQuestOptions()
	if not MTH_AQ_READY then return end

	local container = MTH_GetFrame("MetaHuntOptionsAutoQuest")
	if not container then return end

	MTH_ClearContainer(container)

	local title = container:CreateFontString("MetaHuntOptionsAutoQuestTitle", "ARTWORK", "GameFontHighlight")
	title:SetPoint("TOPLEFT", container, "TOPLEFT", 20, -10)
	title:SetText("Auto Quest")

	local body = container:CreateFontString("MetaHuntOptionsAutoQuestBody", "ARTWORK", "GameFontNormalSmall")
	body:SetPoint("TOPLEFT", container, "TOPLEFT", 20, -30)
	body:SetWidth(560)
	body:SetJustifyH("LEFT")
	body:SetJustifyV("TOP")
	body:SetTextColor(0.45, 0.75, 1)
	body:SetText("Automation for specific quest interactions.")

	local moduleEnabled = true
	if MTH and MTH.GetModule then
		local module = MTH:GetModule("autoquest")
		if type(module) == "table" and module.enabled ~= nil then
			moduleEnabled = module.enabled and true or false
		elseif MTH and MTH.IsModuleEnabled then
			moduleEnabled = MTH:IsModuleEnabled("autoquest", false) and true or false
		end
	elseif MTH and MTH.IsModuleEnabled then
		moduleEnabled = MTH:IsModuleEnabled("autoquest", false) and true or false
	end
	local moduleToggle = MTH_CreateCheckbox(container, "MetaHuntOptionsAutoQuestModuleToggle", "Enable Auto Quest module", -70, 20)
	if moduleToggle then
		moduleToggle:SetChecked(moduleEnabled and true or false)
		moduleToggle:SetScript("OnClick", function()
			if not this then return end
			local enabled = MTH_AQ_IsChecked(this)
			if MTH and MTH.SetModuleEnabled then
				local ok, err = MTH:SetModuleEnabled("autoquest", enabled)
				if not ok and MTH and MTH.Print then
					MTH:Print("Failed to change Auto Quest module state: " .. tostring(err), "error")
				end
			end
			local module = MTH and MTH.GetModule and MTH:GetModule("autoquest") or nil
			local actual = (type(module) == "table" and module.enabled ~= nil) and (module.enabled and true or false) or enabled
			this:SetChecked(actual and true or false)
		end)
	end

	local store = MTH_AQ_EnsureStore()
	if store.scorpokTooltip == nil then
		store.scorpokTooltip = false
	end

	local sectionWidth = (container:GetWidth() or 600) - 40
	if sectionWidth < 360 then
		sectionWidth = 360
	end

	local function ensureSection(name, sectionTitle, yOffset, height)
		local section = getglobal(name)
		if not section then
			section = CreateFrame("Frame", name, container, "OptionFrameBoxTemplate")
		end
		if not section then
			return nil
		end
		section:SetParent(container)
		section:ClearAllPoints()
		section:SetPoint("TOPLEFT", container, "TOPLEFT", 20, yOffset)
		section:SetWidth(sectionWidth)
		section:SetHeight(height)
		section:Show()

		local titleFrame = getglobal(name .. "Title")
		if titleFrame then
			titleFrame:SetText(sectionTitle)
		end
		return section
	end

	local function ensureCheckbox(section, name, label, yOffset, checked)
		local check = getglobal(name)
		if not check then
			check = CreateFrame("CheckButton", name, section, "OptionsCheckButtonTemplate")
		end
		if not check then
			return nil
		end
		check:SetParent(section)
		check:ClearAllPoints()
		check:SetPoint("TOPLEFT", section, "TOPLEFT", 12, yOffset)
		check:SetChecked(checked and true or false)
		check:Show()

		local text = getglobal(name .. "Text")
		if text then
			text:SetText(label)
		end
		return check
	end

	local scorpokSection = ensureSection("MetaHuntAutoQuestScorpokBox", "Salt of the Scorpok", -130, 112)
	if scorpokSection then
		local scorpokToggle = ensureCheckbox(
			scorpokSection,
			"MetaHuntOptionsAutoQuestScorpokToggle",
			"Enable SHIFT-rightclick for Bloodmage Drazial",
			-10,
			store.scorpokDrazial and true or false
		)
		if scorpokToggle then
			scorpokToggle:SetScript("OnClick", function()
				local enabled = MTH_AQ_IsChecked(this)
				store.scorpokDrazial = enabled and true or false
				if MTH and MTH.GetModuleCharSavedVariables then
					local moduleStore = MTH:GetModuleCharSavedVariables("autoquest")
					if type(moduleStore) == "table" then
						moduleStore.scorpokDrazial = store.scorpokDrazial and true or false
					end
				end
				local module = MTH and MTH.GetModule and MTH:GetModule("autoquest")
				if module and module.SetScorpokDrazialEnabled then
					module:SetScorpokDrazialEnabled(enabled)
				end
			end)
		end

		local tooltipToggle = ensureCheckbox(
			scorpokSection,
			"MetaHuntOptionsAutoQuestScorpokTooltipToggle",
			"Enhance Tooltip on Drazial and related beasts (requires Tooltips module enabled)",
			-42,
			store.scorpokTooltip and true or false
		)
		if tooltipToggle then
			tooltipToggle:SetScript("OnClick", function()
				local enabled = MTH_AQ_IsChecked(this)
				store.scorpokTooltip = enabled and true or false
				if MTH and MTH.GetModuleCharSavedVariables then
					local moduleStore = MTH:GetModuleCharSavedVariables("autoquest")
					if type(moduleStore) == "table" then
						moduleStore.scorpokTooltip = store.scorpokTooltip and true or false
					end
				end
			end)
		end
	end

	local sissiesSection = ensureSection("MetaHuntAutoQuestSissiesBox", "Arrows Are For Sissies", -255, 108)
	if sissiesSection then
		local sissiesNote = getglobal("MetaHuntOptionsAutoQuestSissiesNote")
		if not sissiesNote then
			sissiesNote = sissiesSection:CreateFontString("MetaHuntOptionsAutoQuestSissiesNote", "ARTWORK", "GameFontNormalSmall")
		end
		sissiesNote:ClearAllPoints()
		sissiesNote:SetPoint("TOPLEFT", sissiesSection, "TOPLEFT", 14, -10)
		sissiesNote:SetWidth(sectionWidth - 28)
		sissiesNote:SetJustifyH("LEFT")
		sissiesNote:SetTextColor(0.45, 0.75, 1)
		sissiesNote:SetText("Note that you should not activate this if you are using LazyPig")
		sissiesNote:Show()

		local sissiesToggle = ensureCheckbox(
			sissiesSection,
			"MetaHuntOptionsAutoQuestSissiesToggle",
			"Enable SHIFT-rightclick for Artilleryman Sheldonore",
			-40,
			store.arrowsForSissies and true or false
		)
		if sissiesToggle then
			sissiesToggle:SetScript("OnClick", function()
				local enabled = MTH_AQ_IsChecked(this)
				store.arrowsForSissies = enabled and true or false
				if MTH and MTH.GetModuleCharSavedVariables then
					local moduleStore = MTH:GetModuleCharSavedVariables("autoquest")
					if type(moduleStore) == "table" then
						moduleStore.arrowsForSissies = store.arrowsForSissies and true or false
					end
				end
				local module = MTH and MTH.GetModule and MTH:GetModule("autoquest")
				if module and module.SetArrowsForSissiesEnabled then
					module:SetArrowsForSissiesEnabled(enabled)
				end
			end)
		end
	end
end
