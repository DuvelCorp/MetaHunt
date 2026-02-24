if not ZHunterMod_Saved then
	ZHunterMod_Saved = {}
end

BINDING_HEADER_ZAspectHeader = "ZAspect Buttons"
BINDING_HEADER_ZTrackHeader = "ZTrack Buttons"
BINDING_HEADER_ZTrapHeader = "ZTrap Buttons"
BINDING_HEADER_ZPetHeader = "ZPet Buttons"
BINDING_HEADER_ZAmmoHeader = "ZAmmo Buttons"
BINDING_HEADER_ZMountsHeader = "ZMounts Buttons"
BINDING_HEADER_ZCompanionsHeader = "ZCompanions Buttons"
BINDING_HEADER_ZToysHeader = "ZToys Buttons"

ZHunterModTooltip = CreateFrame("GameTooltip", "ZHunterModTooltip", nil, "GameTooltipTemplate")

function MTH_ZH_IsModuleEnabled()
	if not (MTH and MTH.IsModuleEnabled) then
		return true
	end
	return MTH:IsModuleEnabled("zhunter", true)
end

function MTH_ZH_GetSavedRoot()
	if type(ZHunterMod_Saved) ~= "table" then
		ZHunterMod_Saved = {}
	end
	return ZHunterMod_Saved
end

function MTH_ZH_GetSavedTable(key)
	local root = MTH_ZH_GetSavedRoot()
	if type(key) ~= "string" or key == "" then
		return root
	end
	if type(root[key]) ~= "table" then
		root[key] = {}
	end
	return root[key]
end

local function MTH_ZH_MigrateButtonSavedKeys_Replace()
	local root = MTH_ZH_GetSavedRoot()
	if type(root) ~= "table" then
		return
	end

	local mapping = {
		{"ZHunterButtonAspect", "zButtonAspect"},
		{"ZHunterButtonTrack", "zButtonTrack"},
		{"ZHunterButtonTrap", "zButtonTrap"},
		{"ZHunterButtonAmmo", "zButtonAmmo"},
		{"ZHunterButtonPet", "zButtonPet"},
		{"ZHunterButtonMounts", "zButtonMounts"},
		{"ZHunterButtonCompanions", "zButtonCompanions"},
		{"ZHunterButtonToys", "zButtonToys"},
	}

	for i = 1, table.getn(mapping) do
		local oldKey = mapping[i][1]
		local newKey = mapping[i][2]
		if root[oldKey] ~= nil then
			root[newKey] = root[oldKey]
			root[oldKey] = nil
		end
	end
end

MTH_ZH_MigrateButtonSavedKeys_Replace()

function MTH_ZH_Print(message, severity)
	if type(MTH_Log) == "function" then
		MTH_Log(message, severity)
		return
	end
	if MTH and MTH.Print then
		MTH:Print(message, severity)
		return
	end
	if DEFAULT_CHAT_FRAME and DEFAULT_CHAT_FRAME.AddMessage then
		DEFAULT_CHAT_FRAME:AddMessage("[MetaHunt] " .. tostring(message or ""), 1, 0.9, 0.3)
	end
end

function MTH_ZH_HandleDisabledSlash(message, tableKey, fieldKey)
	if MTH_ZH_IsModuleEnabled() then
		return false
	end

	if type(tableKey) == "string" and tableKey ~= "" then
		if fieldKey then
			local tbl = MTH_ZH_GetSavedTable(tableKey)
			tbl[fieldKey] = nil
		else
			local root = MTH_ZH_GetSavedRoot()
			root[tableKey] = nil
		end
	end

	if message then
		MTH_ZH_Print(message)
	end

	return true
end

function ZHunterMod_AlignButtons()
	zButtonAmmo:ClearAllPoints()
	zButtonAmmo:SetPoint("TOP", zButtonAspect, "BOTTOM", 0, -15)
	zButtonTrack:ClearAllPoints()
	zButtonTrack:SetPoint("TOP", zButtonAmmo, "BOTTOM", 0, -15)	
	zButtonTrap:ClearAllPoints()
	zButtonTrap:SetPoint("TOP", zButtonTrack, "BOTTOM", 0, -15)
	zButtonPet:ClearAllPoints()
	zButtonPet:SetPoint("TOP", zButtonTrap, "BOTTOM", 0, -15)
	zButtonMounts:ClearAllPoints()
	zButtonMounts:SetPoint("TOP", zButtonPet, "BOTTOM", 0, -15)
	zButtonCompanions:ClearAllPoints()
	zButtonCompanions:SetPoint("TOP", zButtonMounts, "BOTTOM", 0, -15)
	zButtonToys:ClearAllPoints()
	zButtonToys:SetPoint("TOP", zButtonCompanions, "BOTTOM", 0, -15)
	if AutoStripDisplay then
		AutoStripDisplay:ClearAllPoints()
		AutoStripDisplay:SetPoint("TOP", zButtonToys, "BOTTOM", 0, -10)
	end
end

function ZMarkTarget()
	if not MTH_ZH_IsModuleEnabled() then
		return
	end

	if not UnitExists("target") then return end
	for i=1, 40 do
		if not UnitDebuff("target", i) then break end
		ZHunterModTooltip:SetOwner(UIParent, "ANCHOR_NONE")
		ZHunterModTooltip:SetUnitDebuff("target", i)
		local spell = ZHunterModTooltipTextLeft1:GetText()
		if spell == ZHUNTER_HUNTERSMARK then
			return
		end
	end
	CastSpellByName(ZHUNTER_HUNTERSMARK)
	return 1
end

SLASH_ZHunterMod1 = "/zhunter"
SlashCmdList["ZHunterMod"] = function(msg)
	MTH_ZH_Print("Possible Slash Commands: \"/zammo\", \"/zaspect\", \"/ztrack\", \"/ztrap\", \"/zpet\", \"/zmounts\", \"/zcompanions\", \"/zminipets\", \"/ztoys\", \"/zstrip\", \"/zantidaze\"")
end
