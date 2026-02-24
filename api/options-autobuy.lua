local MTH_AB_READY = MTH_OptionsRequire and MTH_OptionsRequire("options-autobuy", {
	"MTH_GetFrame",
	"MTH_ClearContainer",
	"MTH_CreateCheckbox",
})

local MTH_AB_LAYOUT = {
	LEFT_SECTION_X = 0,
	RIGHT_SECTION_X = 290,
	ROW_CHECK_X = 0,
	ROW_CHECK_LABEL_X = 27,
	ROW_DROPDOWN_X = 33,
	ROW_DROPDOWN_WIDTH = 100,
	ROW_QTY_GAP = 6,
	ROW_SUFFIX_GAP = 6,
	ROW_STEP = 40,
	SECTION_TITLE_Y = -110,
	SECTION_ROWS_Y0 = -138,
}

local MTH_AB_STATE = {
	container = nil,
	built = false,
	syncing = false,
	controls = {
		moduleEnabled = nil,
		projectilesEnabled = nil,
		petFoodEnabled = nil,
		petFoodQty = nil,
		petFoodQtyLabel = nil,
		petFoodQtySuffix = nil,
		petFoodScopeCurrent = nil,
		petFoodScopeAll = nil,
		petFoodTitle = nil,
		petFoodPetLines = {},
		title = nil,
		body = nil,
		sectionArrowTitle = nil,
		sectionBulletTitle = nil,
		rows = {
			arrow = {},
			bullet = {},
		},
	},
}

local function MTH_AB_SetCheckedNoClick(check, checked)
	if not check then return end
	MTH_AB_STATE.syncing = true
	check:SetChecked(checked and true or false)
	MTH_AB_STATE.syncing = false
end

local function MTH_AB_GetEngine()
	return MTH_AutoBuyEngine
end

local function MTH_AB_GetStore()
	local engine = MTH_AB_GetEngine()
	if engine and engine.EnsureDefaults then
		return engine:EnsureDefaults()
	end
	MTH_AutoBuy_Saved = MTH_AutoBuy_Saved or {}
	return MTH_AutoBuy_Saved
end

local function MTH_AB_NormalizeRule(rule)
	if type(rule) ~= "table" then
		rule = {}
	end
	if rule.enabled == nil then
		rule.enabled = false
	end
	rule.enabled = rule.enabled and true or false
	rule.itemId = rule.itemId and (tonumber(rule.itemId) or rule.itemId) or nil

	local stacks = tonumber(rule.stacks)
	if not stacks then
		stacks = rule.enabled and 1 or 0
	end
	stacks = math.floor(stacks)
	if stacks < 0 then
		stacks = 0
	end
	if rule.enabled and stacks < 1 then
		stacks = 1
	end
	rule.stacks = stacks
	return rule
end

local function MTH_AB_EnsureConfig()
	local store = MTH_AB_GetStore()
	if store.enabled == nil then store.enabled = true end
	if type(store.projectiles) ~= "table" then store.projectiles = {} end
	if type(store.petFood) ~= "table" then store.petFood = {} end
	if store.projectiles.enabled == nil then store.projectiles.enabled = true end
	if store.petFood.enabled == nil then store.petFood.enabled = false end
	if store.petFood.stacks == nil then store.petFood.stacks = 1 end
	if store.petFood.scope == nil then store.petFood.scope = "current" end
	store.petFood.stacks = math.floor(tonumber(store.petFood.stacks) or 1)
	if store.petFood.stacks < 1 then store.petFood.stacks = 1 end
	if store.petFood.scope ~= "current" and store.petFood.scope ~= "all" then
		store.petFood.scope = "current"
	end
	if type(store.projectiles.arrows) ~= "table" then store.projectiles.arrows = {} end
	if type(store.projectiles.bullets) ~= "table" then store.projectiles.bullets = {} end
	if type(store.projectiles.arrows.rules) ~= "table" then store.projectiles.arrows.rules = {} end
	if type(store.projectiles.bullets.rules) ~= "table" then store.projectiles.bullets.rules = {} end

	for i = 1, 3 do
		store.projectiles.arrows.rules[i] = MTH_AB_NormalizeRule(store.projectiles.arrows.rules[i])
		store.projectiles.bullets.rules[i] = MTH_AB_NormalizeRule(store.projectiles.bullets.rules[i])
	end

	return store
end

local function MTH_AB_SetPetFoodStacks(store, value)
	if type(store) ~= "table" or type(store.petFood) ~= "table" then
		return
	end
	local stacks = math.floor(tonumber(value) or 1)
	if stacks < 1 then stacks = 1 end
	store.petFood.stacks = stacks
end

local function MTH_AB_TitleCase(text)
	local source = tostring(text or "")
	if source == "" then return "" end
	return string.upper(string.sub(source, 1, 1)) .. string.lower(string.sub(source, 2))
end

local function MTH_AB_NormalizeFamilyToken(text)
	local value = string.lower(tostring(text or ""))
	value = string.gsub(value, "%b()", " ")
	value = string.gsub(value, "[^%a]", "")
	return value
end

local function MTH_AB_SingularizeFamilyToken(token)
	local value = tostring(token or "")
	if string.len(value) <= 3 then
		return value
	end
	if string.sub(value, -3) == "ves" and string.len(value) > 4 then
		return string.sub(value, 1, -4) .. "f"
	end
	if string.sub(value, -3) == "ies" and string.len(value) > 4 then
		return string.sub(value, 1, -4) .. "y"
	end
	if string.sub(value, -3) == "xes" and string.len(value) > 4 then
		return string.sub(value, 1, -3)
	end
	if string.sub(value, -4) == "ches" and string.len(value) > 5 then
		return string.sub(value, 1, -3)
	end
	if string.sub(value, -4) == "shes" and string.len(value) > 5 then
		return string.sub(value, 1, -3)
	end
	if string.sub(value, -3) == "zes" and string.len(value) > 4 then
		return string.sub(value, 1, -3)
	end
	if string.sub(value, -3) == "ses" then
		return string.sub(value, 1, -3)
	end
	if string.sub(value, -1) == "s" then
		return string.sub(value, 1, -2)
	end
	return value
end

local function MTH_AB_FindFamilyDietRow(familyName)
	if type(MTH_DS_Families) ~= "table" then
		return nil
	end

	local needle = MTH_AB_NormalizeFamilyToken(familyName)
	if needle == "" then
		return nil
	end

	local needleSingular = MTH_AB_SingularizeFamilyToken(needle)
	for key, row in pairs(MTH_DS_Families) do
		local candidate = MTH_AB_NormalizeFamilyToken(key)
		if candidate ~= "" then
			if candidate == needle or candidate == needleSingular then
				return row
			end
			local candidateSingular = MTH_AB_SingularizeFamilyToken(candidate)
			if candidateSingular == needle or candidateSingular == needleSingular then
				return row
			end
		end
	end

	return nil
end

local function MTH_AB_GetPetDietText(familyName)
	local family = tostring(familyName or "")
	if family == "" then
		return "unknown diet"
	end
	local row = MTH_AB_FindFamilyDietRow(family)
	if type(row) ~= "table" or type(row.food) ~= "table" then
		return "unknown diet"
	end
	local diets = {}
	for i = 1, table.getn(row.food) do
		local diet = tostring(row.food[i] or "")
		if diet ~= "" then
			table.insert(diets, MTH_AB_TitleCase(diet))
		end
	end
	if table.getn(diets) == 0 then
		return "unknown diet"
	end
	return table.concat(diets, ", ")
end

local function MTH_AB_GetPetFoodEntries()
	if type(MTH_PETS_RefreshCurrentPet) == "function" then
		pcall(MTH_PETS_RefreshCurrentPet)
	end

	local entries = {}
	local defaultIcon = "Interface\\Icons\\INV_Misc_QuestionMark"
	local function buildEntryFromRow(row)
		if type(row) ~= "table" then
			return nil
		end
		local name = tostring(row.name or "")
		if name == "" then
			return nil
		end
		local family = tostring(row.family or "")
		local icon = tostring((type(row.stableInfo) == "table" and row.stableInfo.icon) or row.icon or "")
		if icon == "" and type(row.stableRaw) == "table" then
			icon = tostring(row.stableRaw[1] or "")
		end
		if icon == "" then icon = defaultIcon end
		return {
			icon = icon,
			name = name,
			family = family,
			diets = MTH_AB_GetPetDietText(family),
		}
	end

	local function setSlot(slot, data)
		entries[slot + 1] = data
	end

	for slot = 0, 4 do
		setSlot(slot, {
			icon = defaultIcon,
			name = "",
			diets = "",
			placeholder = (slot == 0) and "NO CURRENT PET !" or "Free slot",
		})
	end

	local petsRoot = type(MTH_PETS_GetRootStore) == "function" and MTH_PETS_GetRootStore() or nil
	local petStore = petsRoot and petsRoot.petStore or nil
	local activeById = petStore and petStore.activeById or nil
	local stableSlotIndex = petStore and petStore.stableSlotIndex or nil
	local currentInfo = type(MTH_GetCurrentPetInfo) == "function" and MTH_GetCurrentPetInfo() or nil
	if currentInfo and currentInfo.liveExists then
		local currentName = tostring(currentInfo.name or "")
		if currentName ~= "" then
			local currentFamily = tostring(currentInfo.family or "")
			local currentIcon = defaultIcon
			local currentId = currentInfo.id
			if currentId and type(activeById) == "table" and type(activeById[currentId]) == "table" then
				local currentRow = activeById[currentId]
				local iconFromRow = tostring((type(currentRow.stableInfo) == "table" and currentRow.stableInfo.icon) or currentRow.icon or "")
				if iconFromRow == "" and type(currentRow.stableRaw) == "table" then
					iconFromRow = tostring(currentRow.stableRaw[1] or "")
				end
				if iconFromRow ~= "" then
					currentIcon = iconFromRow
				end
			end
			setSlot(0, {
				icon = currentIcon,
				name = currentName,
				family = currentFamily,
				diets = MTH_AB_GetPetDietText(currentFamily),
			})
		end
	end

	for slot = 1, 4 do
		local petId = nil
		if type(stableSlotIndex) == "table" then
			petId = stableSlotIndex[slot]
		end
		local row = (petId and type(activeById) == "table") and activeById[petId] or nil
		if type(row) ~= "table" and type(activeById) == "table" then
			for _, candidate in pairs(activeById) do
				if type(candidate) == "table" and tonumber(candidate.stableSlot) == slot then
					row = candidate
					break
				end
			end
		end
		local entry = buildEntryFromRow(row)
		if entry then
			setSlot(slot, entry)
		end
	end

	return entries
end

local function MTH_AB_RefreshPetFoodListUI()
	local lines = MTH_AB_STATE.controls.petFoodPetLines or {}
	if table.getn(lines) == 0 then
		return
	end

	local entries = MTH_AB_GetPetFoodEntries()
	for i = 1, table.getn(lines) do
		local line = lines[i]
		local entry = entries[i]
		if line and line.text and line.icon then
			if entry then
				line.icon:Show()
				line.icon:SetTexture(tostring(entry.icon or "Interface\\Icons\\INV_Misc_QuestionMark"))
				line.text:Show()
				if tostring(entry.name or "") ~= "" then
					line.text:SetText(tostring(entry.name) .. " likes " .. tostring(entry.diets or "unknown diet"))
				else
					line.text:SetText(tostring(entry.placeholder or ""))
				end
			else
				line.icon:Hide()
				line.text:SetText("")
			end
		end
	end
end

local function MTH_AB_GetBuyableItems(subtype)
	if type(MTH_AutoBuy_GetProjectileItems) == "function" then
		local result = MTH_AutoBuy_GetProjectileItems(subtype)
		if type(result) == "table" then
			return result
		end
	end

	local wanted = string.lower(tostring(subtype or ""))
	local result = {}
	local source = MTH_DS_AmmoItems or {}
	for itemId, row in pairs(source) do
		if type(row) == "table" and string.lower(tostring(row.subtype or "")) == wanted and type(row.vendors) == "table" then
			for _ in pairs(row.vendors) do
				table.insert(result, {
					itemId = tonumber(itemId) or itemId,
					name = tostring(row.name or ("Item " .. tostring(itemId))),
					level = tonumber(row.level) or 0,
					reqlevel = tonumber(row.reqlevel) or 0,
				})
				break
			end
		end
	end

	table.sort(result, function(a, b)
		if (a.level or 0) ~= (b.level or 0) then
			return (a.level or 0) < (b.level or 0)
		end
		if tostring(a.name or "") ~= tostring(b.name or "") then
			return tostring(a.name or "") < tostring(b.name or "")
		end
		return tonumber(a.itemId or 0) < tonumber(b.itemId or 0)
	end)

	return result
end

local function MTH_AB_GetItemLabel(item)
	if type(item) ~= "table" then return "Unknown" end
	return tostring(item.name or ("Item " .. tostring(item.itemId or "")))
end

local function MTH_AB_DropdownSetText(frame, text)
	if UIDropDownMenu_SetText then
		UIDropDownMenu_SetText(tostring(text or ""), frame)
		return
	end
	if not frame then return end
	local textRegion = getglobal(frame:GetName() .. "Text")
	if textRegion and textRegion.SetText then
		textRegion:SetText(tostring(text or ""))
	end
end

local function MTH_AB_FindItemById(list, itemId)
	itemId = tonumber(itemId)
	if not itemId or type(list) ~= "table" then return nil end
	for i = 1, table.getn(list) do
		if tonumber(list[i].itemId) == itemId then
			return list[i]
		end
	end
	return nil
end

local function MTH_AB_GetRule(store, subtype, index)
	local bucket = subtype == "arrow" and store.projectiles.arrows or store.projectiles.bullets
	if type(bucket.rules[index]) ~= "table" then
		bucket.rules[index] = MTH_AB_NormalizeRule(nil)
	end
	bucket.rules[index] = MTH_AB_NormalizeRule(bucket.rules[index])
	return bucket.rules[index]
end

local function MTH_AB_SetRuleEnabled(store, subtype, index, enabled)
	local rule = MTH_AB_GetRule(store, subtype, index)
	rule.enabled = enabled and true or false
	if not rule.enabled then
		rule.itemId = nil
		rule.stacks = 0
	elseif rule.stacks < 1 then
		rule.stacks = 1
	end
end

local function MTH_AB_SetRuleItem(store, subtype, index, itemId)
	local rule = MTH_AB_GetRule(store, subtype, index)
	rule.itemId = itemId and (tonumber(itemId) or itemId) or nil
end

local function MTH_AB_SetRuleStacks(store, subtype, index, value)
	local rule = MTH_AB_GetRule(store, subtype, index)
	local stacks = math.floor(tonumber(value) or 0)
	if stacks < 0 then stacks = 0 end
	if rule.enabled and stacks < 1 then stacks = 1 end
	rule.stacks = stacks
end

local function MTH_AB_RefreshRowUI(row, store, moduleEnabled, projectilesEnabled)
	local rule = MTH_AB_GetRule(store, row.subtype, row.index)
	local rowEnabled = moduleEnabled and projectilesEnabled and rule.enabled
	local rowInteractive = moduleEnabled and projectilesEnabled
	local muted = rowInteractive and 1 or 0.5

	MTH_AB_SetCheckedNoClick(row.check, rule.enabled)
	if rowInteractive then
		if row.check.Enable then row.check:Enable() end
	else
		if row.check.Disable then row.check:Disable() end
	end

	if UIDropDownMenu_EnableDropDown and UIDropDownMenu_DisableDropDown then
		if rowEnabled then
			UIDropDownMenu_EnableDropDown(row.dropdown)
		else
			UIDropDownMenu_DisableDropDown(row.dropdown)
		end
	end

	local selectedItem = MTH_AB_FindItemById(row.items, rule.itemId)
	if selectedItem then
		MTH_AB_DropdownSetText(row.dropdown, MTH_AB_GetItemLabel(selectedItem))
	else
		MTH_AB_DropdownSetText(row.dropdown, "Select item...")
	end

	if row.qty then
		if rowEnabled then
			if row.qty.Enable then row.qty:Enable() end
			if row.qty.EnableMouse then row.qty:EnableMouse(true) end
			if row.qty.SetTextColor then row.qty:SetTextColor(1, 1, 1) end
		else
			if row.qty.Disable then row.qty:Disable() end
			if row.qty.EnableMouse then row.qty:EnableMouse(false) end
			if row.qty.ClearFocus then row.qty:ClearFocus() end
			if row.qty.SetTextColor then row.qty:SetTextColor(0.6, 0.6, 0.6) end
		end
		row.qty:SetText(tostring(rule.stacks or 0))
	end

	if row.label and row.label.SetTextColor then
		row.label:SetTextColor(muted, muted, muted)
	end
	if row.suffix and row.suffix.SetTextColor then
		row.suffix:SetTextColor(muted, muted, muted)
	end
end

local function MTH_AB_RefreshOptionsUI()
	if not MTH_AB_STATE.built then return end
	local store = MTH_AB_EnsureConfig()
	local moduleEnabled = true
	if MTH and MTH.IsModuleEnabled then
		moduleEnabled = MTH:IsModuleEnabled("autobuy", true) and true or false
	end

	MTH_AB_SetCheckedNoClick(MTH_AB_STATE.controls.moduleEnabled, moduleEnabled)
	MTH_AB_SetCheckedNoClick(MTH_AB_STATE.controls.projectilesEnabled, store.projectiles.enabled and true or false)

	if MTH_AB_STATE.controls.projectilesEnabled then
		local proj = MTH_AB_STATE.controls.projectilesEnabled
		if moduleEnabled then
			if proj.Enable then
				proj:Enable()
			end
		else
			if proj.Disable then
				proj:Disable()
			end
		end
	end

	if MTH_AB_STATE.controls.petFoodEnabled then
		local pf = MTH_AB_STATE.controls.petFoodEnabled
		MTH_AB_SetCheckedNoClick(pf, store.petFood.enabled and true or false)
		if moduleEnabled then
			if pf.Enable then pf:Enable() end
		else
			if pf.Disable then pf:Disable() end
		end
	end

	local petFoodInteractive = moduleEnabled and store.petFood.enabled
	if MTH_AB_STATE.controls.petFoodQty then
		local qty = MTH_AB_STATE.controls.petFoodQty
		qty:SetText(tostring(store.petFood.stacks or 1))
		if petFoodInteractive then
			if qty.Enable then qty:Enable() end
			if qty.EnableMouse then qty:EnableMouse(true) end
			if qty.SetTextColor then qty:SetTextColor(1, 1, 1) end
		else
			if qty.Disable then qty:Disable() end
			if qty.EnableMouse then qty:EnableMouse(false) end
			if qty.ClearFocus then qty:ClearFocus() end
			if qty.SetTextColor then qty:SetTextColor(0.6, 0.6, 0.6) end
		end
	end

	if MTH_AB_STATE.controls.petFoodScopeCurrent then
		MTH_AB_SetCheckedNoClick(MTH_AB_STATE.controls.petFoodScopeCurrent, store.petFood.scope == "current")
		if petFoodInteractive then
			if MTH_AB_STATE.controls.petFoodScopeCurrent.Enable then MTH_AB_STATE.controls.petFoodScopeCurrent:Enable() end
		else
			if MTH_AB_STATE.controls.petFoodScopeCurrent.Disable then MTH_AB_STATE.controls.petFoodScopeCurrent:Disable() end
		end
	end

	if MTH_AB_STATE.controls.petFoodScopeAll then
		MTH_AB_SetCheckedNoClick(MTH_AB_STATE.controls.petFoodScopeAll, store.petFood.scope == "all")
		if petFoodInteractive then
			if MTH_AB_STATE.controls.petFoodScopeAll.Enable then MTH_AB_STATE.controls.petFoodScopeAll:Enable() end
		else
			if MTH_AB_STATE.controls.petFoodScopeAll.Disable then MTH_AB_STATE.controls.petFoodScopeAll:Disable() end
		end
	end

	MTH_AB_RefreshPetFoodListUI()

	for i = 1, 3 do
		MTH_AB_RefreshRowUI(MTH_AB_STATE.controls.rows.arrow[i], store, moduleEnabled, store.projectiles.enabled)
		MTH_AB_RefreshRowUI(MTH_AB_STATE.controls.rows.bullet[i], store, moduleEnabled, store.projectiles.enabled)
	end
end

local function MTH_AB_CreateRow(container, subtype, index, xBase, yOffset)
	local row = {
		subtype = subtype,
		index = index,
		items = MTH_AB_GetBuyableItems(subtype),
	}
	local nameBase = "MetaHuntOptionsAutoBuy_" .. subtype .. "_" .. tostring(index)

	row.check = MTH_CreateCheckbox(container, nameBase .. "Check", "", yOffset, xBase + MTH_AB_LAYOUT.ROW_CHECK_X)
	row.label = container:CreateFontString(nameBase .. "Label", "ARTWORK", "GameFontNormalSmall")
	row.label:SetPoint("TOPLEFT", container, "TOPLEFT", xBase + MTH_AB_LAYOUT.ROW_CHECK_LABEL_X, yOffset - 5)
	row.label:SetText("On?")

	row.dropdown = CreateFrame("Frame", nameBase .. "Drop", container, "UIDropDownMenuTemplate")
	row.dropdown:ClearAllPoints()
	row.dropdown:SetPoint("TOPLEFT", container, "TOPLEFT", xBase + MTH_AB_LAYOUT.ROW_DROPDOWN_X, yOffset + 3)
	if UIDropDownMenu_SetWidth then
		UIDropDownMenu_SetWidth(MTH_AB_LAYOUT.ROW_DROPDOWN_WIDTH, row.dropdown)
	end
	if UIDropDownMenu_JustifyText then
		UIDropDownMenu_JustifyText("LEFT", row.dropdown)
	end

	if UIDropDownMenu_Initialize then
		UIDropDownMenu_Initialize(row.dropdown, function()
			local infoFactory = UIDropDownMenu_CreateInfo
			local info = type(infoFactory) == "function" and infoFactory() or {}
			info.text = "Select item..."
			info.func = function()
				local store = MTH_AB_EnsureConfig()
				MTH_AB_SetRuleItem(store, subtype, index, nil)
				MTH_AB_RefreshOptionsUI()
			end
			if UIDropDownMenu_AddButton then UIDropDownMenu_AddButton(info) end

			for j = 1, table.getn(row.items) do
				local item = row.items[j]
				local label = MTH_AB_GetItemLabel(item)
				local itemId = item.itemId
				local entry = type(infoFactory) == "function" and infoFactory() or {}
				entry.text = label
				entry.func = function()
					local store = MTH_AB_EnsureConfig()
					MTH_AB_SetRuleItem(store, subtype, index, itemId)
					MTH_AB_RefreshOptionsUI()
				end
				if UIDropDownMenu_AddButton then UIDropDownMenu_AddButton(entry) end
			end
		end)
	end

	row.qty = CreateFrame("EditBox", nameBase .. "Qty", container, "InputBoxTemplate")
	local dropButton = getglobal(nameBase .. "DropButton")
	if dropButton then
		row.qty:SetPoint("LEFT", dropButton, "RIGHT", MTH_AB_LAYOUT.ROW_QTY_GAP, -1)
	else
		row.qty:SetPoint("LEFT", row.dropdown, "RIGHT", MTH_AB_LAYOUT.ROW_QTY_GAP + 6, -3)
	end
	row.qty:SetWidth(40)
	row.qty:SetHeight(20)
	row.qty:SetNumeric(true)
	row.qty:SetAutoFocus(false)

	row.suffix = container:CreateFontString(nameBase .. "Suffix", "ARTWORK", "GameFontNormalSmall")
	row.suffix:SetPoint("LEFT", row.qty, "RIGHT", MTH_AB_LAYOUT.ROW_SUFFIX_GAP, 0)
	row.suffix:SetText("Stacks")

	if row.check then
		row.check:SetScript("OnClick", function(self)
			self = self or this
			if not self or MTH_AB_STATE.syncing then return end
			local store = MTH_AB_EnsureConfig()
			MTH_AB_SetRuleEnabled(store, subtype, index, self:GetChecked() and true or false)
			MTH_AB_RefreshOptionsUI()
		end)
	end

	row.qty:SetScript("OnEnterPressed", function(self)
		self = self or this
		if not self then return end
		local store = MTH_AB_EnsureConfig()
		MTH_AB_SetRuleStacks(store, subtype, index, self:GetText())
		MTH_AB_RefreshOptionsUI()
		self:ClearFocus()
	end)
	row.qty:SetScript("OnEditFocusLost", function(self)
		self = self or this
		if not self then return end
		local store = MTH_AB_EnsureConfig()
		MTH_AB_SetRuleStacks(store, subtype, index, self:GetText())
		MTH_AB_RefreshOptionsUI()
	end)

	return row
end

local function MTH_AB_BuildUI(container)
	if MTH_AB_STATE.built and MTH_AB_STATE.container == container then
		return
	end

	MTH_ClearContainer(container)
	MTH_AB_STATE.container = container
	MTH_AB_STATE.built = true

	local controls = MTH_AB_STATE.controls

	controls.title = container:CreateFontString("MetaHuntOptionsAutoBuyTitle", "ARTWORK", "GameFontHighlight")
	if controls.title then
		if controls.title.SetPoint then controls.title:SetPoint("TOPLEFT", container, "TOPLEFT", 20, -10) end
		if controls.title.SetText then controls.title:SetText("Auto Buy") end
	end

	controls.body = container:CreateFontString("MetaHuntOptionsAutoBuyBody", "ARTWORK", "GameFontNormalSmall")
	if controls.body then
		if controls.body.SetPoint then controls.body:SetPoint("TOPLEFT", container, "TOPLEFT", 176, -30) end
		if controls.body.SetWidth then controls.body:SetWidth(400) end
		if controls.body.SetJustifyH then controls.body:SetJustifyH("LEFT") end
		if controls.body.SetTextColor then controls.body:SetTextColor(1, 1, 1) end
		if controls.body.SetText then
			controls.body:SetText("Configure automatic buying rules that triggers when you open a vendor.\nThe quantity refers to how many STACKS of the item you want to have in your bags after your purchase")
		end
	end

	controls.moduleEnabled = MTH_CreateCheckbox(container, "MetaHuntOptionsAutoBuyModuleEnabled", "Enable Auto Buy module", -30)
	if controls.moduleEnabled then
		controls.moduleEnabled:SetScript("OnClick", function(self)
			self = self or this
			if not self or MTH_AB_STATE.syncing then return end
			if MTH and MTH.SetModuleEnabled then
				local ok, err = MTH:SetModuleEnabled("autobuy", self:GetChecked() and true or false)
				if not ok and MTH and MTH.Print then
					MTH:Print("Failed to change Auto Buy state: " .. tostring(err), "error")
				end
			end
			MTH_AB_RefreshOptionsUI()
		end)
	end

	controls.projectilesEnabled = MTH_CreateCheckbox(container, "MetaHuntOptionsAutoBuyProjectilesEnabled", "Enable for Projectiles", -74)
	if controls.projectilesEnabled then
		controls.projectilesEnabled:SetScript("OnClick", function(self)
			self = self or this
			if not self or MTH_AB_STATE.syncing then return end
			local store = MTH_AB_EnsureConfig()
			store.projectiles.enabled = self:GetChecked() and true or false
			MTH_AB_RefreshOptionsUI()
		end)
	end

	controls.sectionArrowTitle = container:CreateFontString("MetaHuntOptionsAutoBuyArrowsTitle", "ARTWORK", "GameFontHighlight")
	if controls.sectionArrowTitle then
		if controls.sectionArrowTitle.SetPoint then
			controls.sectionArrowTitle:SetPoint("TOPLEFT", container, "TOPLEFT", MTH_AB_LAYOUT.LEFT_SECTION_X, MTH_AB_LAYOUT.SECTION_TITLE_Y)
		end
		if controls.sectionArrowTitle.SetText then controls.sectionArrowTitle:SetText("Arrows") end
	end

	controls.sectionBulletTitle = container:CreateFontString("MetaHuntOptionsAutoBuyBulletsTitle", "ARTWORK", "GameFontHighlight")
	if controls.sectionBulletTitle then
		if controls.sectionBulletTitle.SetPoint then
			controls.sectionBulletTitle:SetPoint("TOPLEFT", container, "TOPLEFT", MTH_AB_LAYOUT.RIGHT_SECTION_X, MTH_AB_LAYOUT.SECTION_TITLE_Y)
		end
		if controls.sectionBulletTitle.SetText then controls.sectionBulletTitle:SetText("Bullets") end
	end

	for i = 1, 3 do
		local rowY = MTH_AB_LAYOUT.SECTION_ROWS_Y0 - ((i - 1) * MTH_AB_LAYOUT.ROW_STEP)
		controls.rows.arrow[i] = MTH_AB_CreateRow(container, "arrow", i, MTH_AB_LAYOUT.LEFT_SECTION_X, rowY)
		controls.rows.bullet[i] = MTH_AB_CreateRow(container, "bullet", i, MTH_AB_LAYOUT.RIGHT_SECTION_X, rowY)
	end

	controls.petFoodTitle = container:CreateFontString("MetaHuntOptionsAutoBuyPetFoodTitle", "ARTWORK", "GameFontHighlight")
	if controls.petFoodTitle then
		controls.petFoodTitle:SetPoint("TOPLEFT", container, "TOPLEFT", MTH_AB_LAYOUT.LEFT_SECTION_X, -300)
		controls.petFoodTitle:SetText("Pet Food")
	end

	controls.petFoodEnabled = MTH_CreateCheckbox(container, "MetaHuntOptionsAutoBuyPetFoodEnabled", "Enable for Pet Food", -322, MTH_AB_LAYOUT.LEFT_SECTION_X)
	if controls.petFoodEnabled then
		controls.petFoodEnabled:SetScript("OnClick", function(self)
			self = self or this
			if not self or MTH_AB_STATE.syncing then return end
			local store = MTH_AB_EnsureConfig()
			store.petFood.enabled = self:GetChecked() and true or false
			MTH_AB_RefreshOptionsUI()
		end)
	end

	controls.petFoodQtyLabel = container:CreateFontString("MetaHuntOptionsAutoBuyPetFoodQtyLabel", "ARTWORK", "GameFontNormalSmall")
	if controls.petFoodQtyLabel then
		controls.petFoodQtyLabel:SetPoint("TOPLEFT", container, "TOPLEFT", MTH_AB_LAYOUT.LEFT_SECTION_X + 28, -350)
		controls.petFoodQtyLabel:SetText("Quantity :")
	end

	controls.petFoodQty = CreateFrame("EditBox", "MetaHuntOptionsAutoBuyPetFoodQty", container, "InputBoxTemplate")
	if controls.petFoodQty then
		controls.petFoodQty:SetPoint("TOPLEFT", container, "TOPLEFT", MTH_AB_LAYOUT.LEFT_SECTION_X + 95, -347)
		controls.petFoodQty:SetWidth(40)
		controls.petFoodQty:SetHeight(20)
		controls.petFoodQty:SetNumeric(true)
		controls.petFoodQty:SetAutoFocus(false)
		controls.petFoodQty:SetScript("OnEnterPressed", function(self)
			self = self or this
			if not self then return end
			local store = MTH_AB_EnsureConfig()
			MTH_AB_SetPetFoodStacks(store, self:GetText())
			MTH_AB_RefreshOptionsUI()
			self:ClearFocus()
		end)
		controls.petFoodQty:SetScript("OnEditFocusLost", function(self)
			self = self or this
			if not self then return end
			local store = MTH_AB_EnsureConfig()
			MTH_AB_SetPetFoodStacks(store, self:GetText())
			MTH_AB_RefreshOptionsUI()
		end)
	end

	controls.petFoodQtySuffix = container:CreateFontString("MetaHuntOptionsAutoBuyPetFoodQtySuffix", "ARTWORK", "GameFontNormalSmall")
	if controls.petFoodQtySuffix then
		controls.petFoodQtySuffix:SetPoint("LEFT", controls.petFoodQty, "RIGHT", 8, 0)
		controls.petFoodQtySuffix:SetText("stacks")
	end

	controls.petFoodScopeCurrent = MTH_CreateCheckbox(container, "MetaHuntOptionsAutoBuyPetFoodScopeCurrent", "Buy only for my current pet", -376, MTH_AB_LAYOUT.LEFT_SECTION_X + 28)
	if controls.petFoodScopeCurrent then
		controls.petFoodScopeCurrent:SetScript("OnClick", function(self)
			self = self or this
			if not self or MTH_AB_STATE.syncing then return end
			local store = MTH_AB_EnsureConfig()
			store.petFood.scope = "current"
			MTH_AB_RefreshOptionsUI()
		end)
	end

	controls.petFoodScopeAll = MTH_CreateCheckbox(container, "MetaHuntOptionsAutoBuyPetFoodScopeAll", "Buy for all my pets", -402, MTH_AB_LAYOUT.LEFT_SECTION_X + 28)
	if controls.petFoodScopeAll then
		controls.petFoodScopeAll:SetScript("OnClick", function(self)
			self = self or this
			if not self or MTH_AB_STATE.syncing then return end
			local store = MTH_AB_EnsureConfig()
			store.petFood.scope = "all"
			MTH_AB_RefreshOptionsUI()
		end)
	end

	controls.petFoodPetLines = {}
	for i = 1, 5 do
		local rowY = -434 - ((i - 1) * 22)
		local icon = container:CreateTexture("MetaHuntOptionsAutoBuyPetFoodPetIcon" .. tostring(i), "ARTWORK")
		icon:SetWidth(16)
		icon:SetHeight(16)
		icon:SetPoint("TOPLEFT", container, "TOPLEFT", MTH_AB_LAYOUT.LEFT_SECTION_X + 28, rowY)
		icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
		local text = container:CreateFontString("MetaHuntOptionsAutoBuyPetFoodPetText" .. tostring(i), "ARTWORK", "GameFontNormalSmall")
		text:SetPoint("LEFT", icon, "RIGHT", 6, 0)
		text:SetJustifyH("LEFT")
		text:SetTextColor(1, 1, 1)
		text:SetText("")
		controls.petFoodPetLines[i] = { icon = icon, text = text }
	end
end

function MTH_SetupAutoBuyOptions()
	if not MTH_AB_READY then return end
	local container = MTH_GetFrame("MetaHuntOptionsAutoBuy")
	if not container then return end

	if CloseDropDownMenus then
		CloseDropDownMenus()
	end

	MTH_AB_BuildUI(container)
	MTH_AB_RefreshOptionsUI()
end
