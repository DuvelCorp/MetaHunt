-- ============================================================
-- Bag Ammo Labels — standalone overlay for bag & bank ammo slots
-- Uses globals from zButtonAmmo.lua:
--   zButtonAmmo_ShortArrowLabels, zButtonAmmo_ShortBulletLabels,
--   zButtonAmmo_GetQualityColor, zButtonAmmo_GetColorGradient,
--   zButtonAmmo_GetKnownAmmoTypes
-- Uses DPS data from MTH_DS_AmmoItems[id].dps
-- ============================================================

-- Saved variable cache (per-character, stored in "general" module)
local cache = {}  -- bagAmmoLabels, bankAmmoLabels, bagAmmoDamage

local function GetStore()
	return MTH and MTH.GetModuleCharSavedVariables and MTH:GetModuleCharSavedVariables("general")
end

local function GetCached(key, default)
	if cache[key] == nil then
		local store = GetStore()
		if type(store) == "table" and store[key] ~= nil then
			cache[key] = store[key] and true or false
		else
			cache[key] = default or false
		end
	end
	return cache[key]
end

local function SetCached(key, enabled)
	cache[key] = enabled and true or false
	local store = GetStore()
	if type(store) == "table" then
		store[key] = cache[key]
	end
end

-- Public getters/setters
function MTH_BagAmmoLabels_GetEnabled()
	return GetCached("bagAmmoLabels")
end
function MTH_BagAmmoLabels_SetEnabled(enabled)
	SetCached("bagAmmoLabels", enabled)
	MTH_BagAmmoLabels_RefreshAll()
end

function MTH_BankAmmoLabels_GetEnabled()
	return GetCached("bankAmmoLabels")
end
function MTH_BankAmmoLabels_SetEnabled(enabled)
	SetCached("bankAmmoLabels", enabled)
	MTH_BagAmmoLabels_RefreshAllBank()
end

function MTH_BagAmmoDamage_GetEnabled()
	return GetCached("bagAmmoDamage")
end
function MTH_BagAmmoDamage_SetEnabled(enabled)
	SetCached("bagAmmoDamage", enabled)
	MTH_BagAmmoLabels_RefreshAll()
	MTH_BagAmmoLabels_RefreshAllBank()
end

-- Heat color: red (7.5 DPS) → yellow → green (20.5 DPS); below 7.5 = grey
local DPS_MIN = 7.5
local DPS_MAX = 20.5

local function GetDpsHeatColor(dps)
	if not dps then return 1, 1, 1 end
	if dps < DPS_MIN then return 0.6, 0.6, 0.6 end
	local perc = (dps - DPS_MIN) / (DPS_MAX - DPS_MIN)
	return zButtonAmmo_GetColorGradient(perc)
end

-- Look up DPS from MTH_DS_AmmoItems by numeric item ID
local function GetAmmoDps(numericId)
	if not MTH_DS_AmmoItems then return nil end
	local entry = MTH_DS_AmmoItems[numericId]
	return entry and entry.dps
end

-- Detect whether pfUI bags are active
local function HasPfUI()
	return pfUI and pfUI.bags and pfUI.bag and true or false
end

-- Is this bagID a bank bag?
local BANK_BAGS = { [-1] = true, [5] = true, [6] = true, [7] = true, [8] = true, [9] = true, [10] = true, [11] = true }

local function IsBankBag(bagID)
	return BANK_BAGS[bagID] or false
end

-- Apply or clear labels on a single bag-slot button
local function UpdateButton(button, bagID, slot, showName, showDmg)
	if not button then return end

	-- Lazy-create name label (TOPLEFT)
	if not button._mthAmmoLabel then
		button._mthAmmoLabel = button:CreateFontString(nil, "OVERLAY")
		button._mthAmmoLabel:SetPoint("TOPLEFT", button, "TOPLEFT", 1, -1)
		button._mthAmmoLabel:SetFont("Fonts\\ARIALN.ttf", 9, "OUTLINE")
		button._mthAmmoLabel:Hide()
	end
	-- Lazy-create damage label (CENTER, large + bold)
	if not button._mthAmmoDmgLabel then
		button._mthAmmoDmgLabel = button:CreateFontString(nil, "OVERLAY")
		button._mthAmmoDmgLabel:SetPoint("CENTER", button, "CENTER", 0, 0)
		button._mthAmmoDmgLabel:SetFont("Fonts\\ARIALN.ttf", 10, "THICKOUTLINE")
		button._mthAmmoDmgLabel:Hide()
	end

	local nameLabel = button._mthAmmoLabel
	local dmgLabel = button._mthAmmoDmgLabel

	if not showName and not showDmg then
		nameLabel:Hide()
		dmgLabel:Hide()
		return
	end

	local link = GetContainerItemLink(bagID, slot)
	if not link then
		nameLabel:Hide()
		dmgLabel:Hide()
		return
	end

	local _, _, id = string.find(link, "Hitem:(%d+)")
	if not id then
		nameLabel:Hide()
		dmgLabel:Hide()
		return
	end

	local numericId = tonumber(id)
	local itemName, _, itemQuality, _, _, _, _, _, itemSlot = GetItemInfo(id)
	if not itemName then
		nameLabel:Hide()
		dmgLabel:Hide()
		return
	end

	local isAmmo = (itemSlot == "INVTYPE_AMMO")
	if not isAmmo then
		local knownAmmo = zButtonAmmo_GetKnownAmmoTypes and zButtonAmmo_GetKnownAmmoTypes()
		isAmmo = knownAmmo and knownAmmo[itemName]
	end
	if not isAmmo then
		nameLabel:Hide()
		dmgLabel:Hide()
		return
	end

	-- Name label
	if showName then
		local shortText = zButtonAmmo_ShortArrowLabels[itemName]
			or zButtonAmmo_ShortBulletLabels[itemName]
		if shortText then
			local cr, cg, cb = zButtonAmmo_GetQualityColor(itemQuality)
			nameLabel:SetTextColor(cr, cg, cb, 1)
			nameLabel:SetText(shortText)
			nameLabel:Show()
		else
			nameLabel:Hide()
		end
	else
		nameLabel:Hide()
	end

	-- Damage label
	if showDmg then
		local dps = GetAmmoDps(numericId)
		if dps then
			local cr, cg, cb = GetDpsHeatColor(dps)
			dmgLabel:SetTextColor(cr, cg, cb, 1)
			dmgLabel:SetText(dps)
			dmgLabel:Show()
		else
			dmgLabel:Hide()
		end
	else
		dmgLabel:Hide()
	end
end

-- Clear both labels on a button
local function ClearButton(button)
	if not button then return end
	if button._mthAmmoLabel then button._mthAmmoLabel:Hide() end
	if button._mthAmmoDmgLabel then button._mthAmmoDmgLabel:Hide() end
end

-- Forward declaration
local RefreshAllVisibleFrames

-- Refresh labels on a single bag (works for any bagID)
local function RefreshBag(bagID, showName, showDmg)
	local numSlots = GetContainerNumSlots(bagID)
	if numSlots == 0 then return end

	-- pfUI path
	if HasPfUI() then
		local pfBag = pfUI.bags[bagID]
		if not pfBag or not pfBag.slots then return end
		for slot = 1, numSlots do
			local slotData = pfBag.slots[slot]
			local button = slotData and slotData.frame
			if button then
				if showName or showDmg then
					UpdateButton(button, bagID, slot, showName, showDmg)
				else
					ClearButton(button)
				end
			end
		end
		return
	end

	-- Default UI path

	-- Main bank (bagID -1): buttons are BankFrameItem1..28
	if bagID == -1 then
		for slot = 1, numSlots do
			local button = getglobal("BankFrameItem" .. slot)
			if button then
				if showName or showDmg then
					UpdateButton(button, -1, slot, showName, showDmg)
				else
					ClearButton(button)
				end
			end
		end
		return
	end

	-- All other bags (0-4 and 5-11): search all ContainerFrames
	for ci = 1, 13 do
		local frame = getglobal("ContainerFrame" .. ci)
		if frame and frame:IsVisible() and frame:GetID() == bagID then
			local frameName = frame:GetName()
			-- Visual button i = API slot (numSlots - i + 1)
			for i = 1, numSlots do
				local button = getglobal(frameName .. "Item" .. i)
				local apiSlot = numSlots - i + 1
				if button then
					if showName or showDmg then
						UpdateButton(button, bagID, apiSlot, showName, showDmg)
					else
						ClearButton(button)
					end
				end
			end
			-- Clear stale labels on any buttons beyond numSlots
			for slot = numSlots + 1, 24 do
				local button = getglobal(frameName .. "Item" .. slot)
				if not button then break end
				ClearButton(button)
			end
			return
		end
	end
end

-- Public: refresh all inventory bags (0-4)
function MTH_BagAmmoLabels_RefreshAll()
	RefreshAllVisibleFrames()
end

-- Public: refresh all bank bags (-1, 5-11)
function MTH_BagAmmoLabels_RefreshAllBank()
	RefreshAllVisibleFrames()
end

-- Refresh all visible default UI ContainerFrames (frame-centric: no bagID lookup)
RefreshAllVisibleFrames = function()
	local bagShowName = MTH_BagAmmoLabels_GetEnabled()
	local bankShowName = MTH_BankAmmoLabels_GetEnabled()
	local showDmg = MTH_BagAmmoDamage_GetEnabled()

	if HasPfUI() then
		-- pfUI: refresh via pfUI bag structure
		for bagID = 0, 4 do
			RefreshBag(bagID, bagShowName, showDmg)
		end
		local bankBags = { -1, 5, 6, 7, 8, 9, 10, 11 }
		for _, bagID in ipairs(bankBags) do
			RefreshBag(bagID, bankShowName, showDmg)
		end
		return
	end

	-- Default UI: iterate all visible ContainerFrames
	for ci = 1, 13 do
		local cf = getglobal("ContainerFrame" .. ci)
		if cf and cf:IsVisible() then
			local bagID = cf:GetID()
			local showName = IsBankBag(bagID) and bankShowName or bagShowName
			local numSlots = GetContainerNumSlots(bagID)
			local fname = cf:GetName()
			-- Visual button i = API slot (numSlots - i + 1)
			for i = 1, numSlots do
				local button = getglobal(fname .. "Item" .. i)
				local apiSlot = numSlots - i + 1
				if button then
					if showName or showDmg then
						UpdateButton(button, bagID, apiSlot, showName, showDmg)
					else
						ClearButton(button)
					end
				end
			end
			for slot = numSlots + 1, 24 do
				local button = getglobal(fname .. "Item" .. slot)
				if not button then break end
				ClearButton(button)
			end
		end
	end

	-- Bank bag -1: BankFrameItem buttons
	if bankShowName or showDmg then
		local numSlots = GetContainerNumSlots(-1)
		for slot = 1, numSlots do
			local button = getglobal("BankFrameItem" .. slot)
			if button then
				UpdateButton(button, -1, slot, bankShowName, showDmg)
			end
		end
	end
end

-- Event-driven refresh: coalesce with a short delay
do
	local frame = CreateFrame("Frame", "MTH_BagAmmoLabelsFrame", UIParent)
	local needsRefresh = false
	local elapsed = 0

	frame:RegisterEvent("BAG_UPDATE")
	frame:RegisterEvent("PLAYERBANKSLOTS_CHANGED")
	frame:RegisterEvent("PLAYERBANKBAGSLOTS_CHANGED")
	frame:RegisterEvent("BANKFRAME_OPENED")
	frame:RegisterEvent("PLAYER_ENTERING_WORLD")

	frame:SetScript("OnEvent", function()
		if event == "PLAYER_ENTERING_WORLD" then
			-- After login/reload, delay 1s for item cache to populate
			elapsed = -0.95
			needsRefresh = true
			frame:Show()
			return
		end

		if event == "BANKFRAME_OPENED" then
			if MTH_BankAmmoLabels_GetEnabled() or MTH_BagAmmoDamage_GetEnabled() then
				needsRefresh = true
				if not frame:IsShown() then
					elapsed = 0
					frame:Show()
				end
			end
			return
		end

		if event == "PLAYERBANKSLOTS_CHANGED" or event == "PLAYERBANKBAGSLOTS_CHANGED" then
			if MTH_BankAmmoLabels_GetEnabled() or MTH_BagAmmoDamage_GetEnabled() then
				needsRefresh = true
				if not frame:IsShown() then
					elapsed = 0
					frame:Show()
				end
			end
			return
		end

		-- BAG_UPDATE
		local bagID = arg1
		if not bagID then return end
		if IsBankBag(bagID) then
			if not MTH_BankAmmoLabels_GetEnabled() and not MTH_BagAmmoDamage_GetEnabled() then return end
		else
			if not MTH_BagAmmoLabels_GetEnabled() and not MTH_BagAmmoDamage_GetEnabled() then return end
		end
		needsRefresh = true
		if not frame:IsShown() then
			elapsed = 0
			frame:Show()
		end
	end)

	frame:SetScript("OnUpdate", function()
		elapsed = elapsed + (arg1 or 0.016)
		if elapsed < 0.05 then return end
		needsRefresh = false
		frame:Hide()
		RefreshAllVisibleFrames()
	end)
	frame:Hide()

	-- Hook ContainerFrame OnShow: trigger a refresh when a bag becomes visible
	if not HasPfUI() then
		for ci = 1, 13 do
			local cf = getglobal("ContainerFrame" .. ci)
			if cf then
				local origOnShow = cf:GetScript("OnShow")
				cf:SetScript("OnShow", function()
					if origOnShow then origOnShow() end
					needsRefresh = true
					if not frame:IsShown() then
						elapsed = 0
						frame:Show()
					end
				end)
			end
		end
	end

	-- Post-hook ContainerFrame_Update for default UI (synchronous update)
	if type(ContainerFrame_Update) == "function" then
		local origCFU = ContainerFrame_Update
		ContainerFrame_Update = function(cf)
			origCFU(cf)
			if cf and cf:IsVisible() then
				local bagID = cf:GetID()
				local showDmg = MTH_BagAmmoDamage_GetEnabled()
				local showName
				if IsBankBag(bagID) then
					showName = MTH_BankAmmoLabels_GetEnabled()
				else
					showName = MTH_BagAmmoLabels_GetEnabled()
				end
				if showName or showDmg then
					local numSlots = GetContainerNumSlots(bagID)
					local fname = cf:GetName()
					-- Visual button i = API slot (numSlots - i + 1)
					for i = 1, numSlots do
						local button = getglobal(fname .. "Item" .. i)
						local apiSlot = numSlots - i + 1
						if button then
							UpdateButton(button, bagID, apiSlot, showName, showDmg)
						end
					end
					for slot = numSlots + 1, 24 do
						local button = getglobal(fname .. "Item" .. slot)
						if not button then break end
						ClearButton(button)
					end
				end
			else
				-- Frame hidden: clear all labels
				if cf then
					local fname = cf:GetName()
					if fname then
						for slot = 1, 24 do
							local button = getglobal(fname .. "Item" .. slot)
							if not button then break end
							ClearButton(button)
						end
					end
				end
			end
		end
	end
end
