if type(MTH_HUNTERBOOK_TABS) ~= "table" then MTH_HUNTERBOOK_TABS = {} end

MTH_HUNTERBOOK_TABS.pethistory = {
	headerLabel = "Pet History",
	columnLabels = { "Pet ID", "Name", "Family", "Lvl", "Lost Date/Time", "Lost Cause" },
	columnLayout = {
		{ x = 8, width = 66, align = "LEFT" },
		{ x = 76, width = 104, align = "LEFT" },
		{ x = 182, width = 84, align = "LEFT" },
		{ x = 268, width = 30, align = "LEFT" },
		{ x = 300, width = 128, align = "LEFT" },
		{ x = 430, width = 78, align = "LEFT" },
	},
}

function MTH_BOOK_PetHistorySort(a, b)
	local ra = MTH_BOOK_GetPetStoreRow(a)
	local rb = MTH_BOOK_GetPetStoreRow(b)
	if not ra and not rb then return tostring(a) < tostring(b) end
	if not ra then return false end
	if not rb then return true end
	local ta = tonumber(ra.abandonedAt) or 0
	local tb = tonumber(rb.abandonedAt) or 0
	if ta ~= tb then return ta > tb end
	local nameA = MTH_BOOK_SafeLower(ra.name)
	local nameB = MTH_BOOK_SafeLower(rb.name)
	if nameA ~= nameB then return nameA < nameB end
	return tostring(a) < tostring(b)
end
