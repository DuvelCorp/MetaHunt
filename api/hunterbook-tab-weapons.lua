if type(MTH_HUNTERBOOK_TABS) ~= "table" then MTH_HUNTERBOOK_TABS = {} end

MTH_HUNTERBOOK_TABS.items = {
	headerLabel = "Ranged Weapons",
	columnLabels = { "ID", "Req", "Lvl", "Type", "Name", "DPS", "Speed", "Source" },
	columnLayout = {
		{ x = 8, width = 36, align = "LEFT" },
		{ x = 44, width = 30, align = "LEFT" },
		{ x = 74, width = 30, align = "LEFT" },
		{ x = 104, width = 62, align = "LEFT" },
		{ x = 166, width = 188, align = "LEFT" },
		{ x = 356, width = 44, align = "LEFT" },
		{ x = 402, width = 40, align = "LEFT" },
		{ x = 444, width = 108, align = "LEFT" },
	},
}

function MTH_BOOK_NormalizeItemSubtype(value)
	local subtype = MTH_BOOK_SafeLower(value)
	if subtype == "arrows" then return "arrow" end
	if subtype == "bullets" then return "bullet" end
	if subtype == "bows" then return "bow" end
	if subtype == "rifle" or subtype == "rifles" then return "gun" end
	if subtype == "cross bow" or subtype == "cross-bow" or subtype == "crossbows" or subtype == "xbow" or subtype == "xbows" then return "crossbow" end
	return subtype
end

function MTH_BOOK_IsRangedWeaponSubtype(subtype)
	return subtype == "bow" or subtype == "gun" or subtype == "crossbow"
end

function MTH_BOOK_ItemMatches(itemId, item)
	if not item then return false end
	if item.notingame then return false end
	local itemSubtype = MTH_BOOK_NormalizeItemSubtype(item.subtype)
	if not MTH_BOOK_IsRangedWeaponSubtype(itemSubtype) then return false end
	local selectedSubtype = MTH_BOOK_NormalizeItemSubtype(MTH_BOOK_STATE.itemSubtype)
	if selectedSubtype ~= "all" and itemSubtype ~= selectedSubtype then return false end
	if MTH_BOOK_STATE.itemOnlyMyLevel then
		local playerLevel = MTH_BOOK_GetPlayerLevelValue()
		local reqLevel = tonumber(item.reqlevel)
		if playerLevel and reqLevel and reqLevel > playerLevel then
			return false
		end
	end
	if MTH_BOOK_STATE.flag1 and not MTH_BOOK_HasEntries(item.vendors) then return false end
	if MTH_BOOK_STATE.flag2 and not MTH_BOOK_HasEntries(item.drops) then return false end
	if MTH_BOOK_STATE.flag3 and not MTH_BOOK_HasEntries(item.objects) then return false end

	if MTH_BOOK_STATE.search ~= "" then
		local name = MTH_BOOK_SafeLower(item.name)
		local idText = tostring(itemId)
		if string.find(name, MTH_BOOK_STATE.search, 1, true) == nil and string.find(idText, MTH_BOOK_STATE.search, 1, true) == nil then
			return false
		end
	end

	return true
end

function MTH_BOOK_ItemSort(a, b)
	local items = MTH_BOOK_GetItemsTable()
	local ia = items and items[a]
	local ib = items and items[b]
	if not ia or not ib then return a < b end
	local la = ia.level or 0
	local lb = ib.level or 0
	if la ~= lb then return la < lb end
	local na = ia.name or ""
	local nb = ib.name or ""
	if na ~= nb then return na < nb end
	return a < b
end
