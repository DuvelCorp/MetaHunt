local MTH_CREDITS_READY = MTH_OptionsRequire and MTH_OptionsRequire("options-credits", {
	"MTH_GetFrame",
	"MTH_ClearContainer",
})

local MTH_CREDITS_FONT_DELTA = 2

local function MTH_CR_L(key, default)
	if MTH and MTH.GetLocalization then
		return MTH:GetLocalization(key, default)
	end
	return default or key
end

local function MTH_CreditsBumpFont(fs)
	if not fs or not fs.GetFont or not fs.SetFont then return end
	local path, size, flags = fs:GetFont()
	if path and size then
		fs:SetFont(path, size + MTH_CREDITS_FONT_DELTA, flags)
	end
end

local function MTH_CreditsInsertLink(url)
	local link = tostring(url or "")
	if link == "" then return end
	if type(MTH_InsertLinkToChat) == "function" and MTH_InsertLinkToChat(link) then
		if MTH and MTH.Print then
			MTH:Print(MTH_CR_L("CREDITS_LINK_INSERTED", "Link inserted in chat: ") .. link)
		end
		return
	end
	if MTH and MTH.Print then
		MTH:Print(MTH_CR_L("CREDITS_LINK_FALLBACK", "Link: ") .. link)
	end
end

local function MTH_CreditsClearFrame(frame)
	if not frame then return end
	local children = { frame:GetChildren() }
	for i = 1, table.getn(children) do
		if children[i] and children[i].Hide then
			children[i]:Hide()
		end
	end
	local regions = { frame:GetRegions() }
	for i = 1, table.getn(regions) do
		if regions[i] and regions[i].Hide then
			regions[i]:Hide()
		end
	end
end

local function MTH_CreditsCreateLink(parent, label, url, anchorTo, y)
	local button = CreateFrame("Button", nil, parent)
	if not button then return nil end
	button:SetPoint("TOPLEFT", anchorTo, "BOTTOMLEFT", 0, y or -4)
	button:SetHeight(18)
	button:SetWidth(500)
	local text = button:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	text:SetPoint("LEFT", button, "LEFT", 0, 0)
	text:SetJustifyH("LEFT")
	text:SetText(label)
	text:SetTextColor(0.40, 0.75, 1.00)
	MTH_CreditsBumpFont(text)
	button:SetScript("OnClick", function()
		MTH_CreditsInsertLink(url)
	end)
	button:SetScript("OnEnter", function()
		text:SetTextColor(0.60, 0.90, 1.00)
	end)
	button:SetScript("OnLeave", function()
		text:SetTextColor(0.40, 0.75, 1.00)
	end)
	return button
end

local function MTH_CreditsCreateText(parent, anchorTo, text, font, y, r, g, b)
	local fs = parent:CreateFontString(nil, "ARTWORK", font or "GameFontNormalSmall")
	if anchorTo == parent then
		fs:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, y or 0)
	else
		fs:SetPoint("TOPLEFT", anchorTo, "BOTTOMLEFT", 0, y or -8)
	end
	fs:SetWidth(500)
	fs:SetJustifyH("LEFT")
	fs:SetJustifyV("TOP")
	fs:SetTextColor(r or 0.93, g or 0.93, b or 0.93)
	fs:SetText(text)
	MTH_CreditsBumpFont(fs)
	return fs
end

function MTH_SetupCreditsOptions()
	if not MTH_CREDITS_READY then return end

	local container = MTH_GetFrame("MetaHuntOptionsCredits")
	if not container then return end

	MTH_ClearContainer(container)

	local title = container:CreateFontString("MetaHuntOptionsCreditsTitle", "ARTWORK", "GameFontNormal")
	title:SetPoint("TOPLEFT", container, "TOPLEFT", 10, -10)
	title:SetText(MTH_CR_L("CREDITS_TITLE", "Credits"))
	title:SetTextColor(1.00, 0.82, 0.00)

	local scrollFrame = MTH_GetFrame("MetaHuntOptionsCreditsScroll")
	if not scrollFrame then
		scrollFrame = CreateFrame("ScrollFrame", "MetaHuntOptionsCreditsScroll", container, "UIPanelScrollFrameTemplate")
	end
	scrollFrame:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -10)
	scrollFrame:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", -30, 10)
	scrollFrame:Show()

	local content = MTH_GetFrame("MetaHuntOptionsCreditsContent")
	if not content then
		content = CreateFrame("Frame", "MetaHuntOptionsCreditsContent", scrollFrame)
	end
	content:SetWidth(520)
	content:SetHeight(2600)
	MTH_CreditsClearFrame(content)
	scrollFrame:SetScrollChild(content)

	local cursor = MTH_CreditsCreateText(content, content, MTH_CR_L("CREDITS_ABOUT_CODE_TITLE", "About the code"), "GameFontNormal", -2, 1.00, 0.82, 0.00)
	cursor = MTH_CreditsCreateText(content, cursor,
		MTH_CR_L("CREDITS_ABOUT_CODE_INTRO",
		"This addon is, in others, a compilation of old vanilla addons that I loved and played with during years. But most of them had become very buggy with TwoW as new contain was added to the server. \n I fixed, reworked, enhanced, and melted them within a modern modular framework that I created.\n"
		.. "I want to make it crystal clear about what work is mine, and what is not and respectfully credit the original authors for the great stuff I've taken from them:"),
		"GameFontNormalSmall", -10)

	cursor = MTH_CreditsCreateText(content, cursor,
		MTH_CR_L("CREDITS_ABOUT_ZHUNTER",
		"- zBars, Antidaze and Autostrip were core functionalities of Vanilla zHunterMod addon. And I kept the \"z\" naming of bars/buttons to always remember it. On top of this I have created myself zAmmo, zCompanions, zMount, zToys.\nAlso the SmartAmmo feature idea is coming from Zhuntermod: there was a file in it with that functionality, but was like a work-in-progress, totally unfunctional and even \"dangerous\" in its current state, and was not active in the addon. Since it was a fucking great idea, I recoded it mostly from scratch and made it work reliably and safely."),
		"GameFontNormalSmall", -10)

	cursor = MTH_CreditsCreateText(content, cursor,
		MTH_CR_L("CREDITS_ABOUT_FEEDOMATIC", "- Feed-o-Matic was entirely the work of Fizzwidget. I made it work for Twow, by melting it as a module calling Metahunt core to get pet's state and up-to-date data for new pet families and their diet."),
		"GameFontNormalSmall", -10)
	cursor = MTH_CreditsCreateLink(content,
		"https://www.wowinterface.com/downloads/info4160-FizzwidgetFeed-O-Matic.html",
		"https://www.wowinterface.com/downloads/info4160-FizzwidgetFeed-O-Matic.html",
		cursor,
		-4)

	cursor = MTH_CreditsCreateText(content, cursor,
		MTH_CR_L("CREDITS_ABOUT_TOOLTIPS", "- Tooltips module is based on Hunter Helper, another vanilla addon of Fizzwidget. I kept the general idea, but there's not much original code left from it in Metahunt as I refactored everything so it plugs on MetaHunt controlled event handlers, can work with Turtle wow data, and is now usable on other things than Beasts."),
		"GameFontNormalSmall", -10)
	cursor = MTH_CreditsCreateLink(content,
		"https://legacy-wow.com/vanilla-addons/fizzwidget-hunter-helper/",
		"https://legacy-wow.com/vanilla-addons/fizzwidget-hunter-helper/",
		cursor,
		-4)

	cursor = MTH_CreditsCreateText(content, cursor,
		MTH_CR_L("CREDITS_ABOUT_CHRONOMETER", "- Chronometer was an old and very popular vanilla addon working with ACE2 libraries. It has known uncountable iterations by various people over the years, and I can't credit them all of them here. The current version used by Metahunt is based on this Twow conversion made by \"wigan91\". I have reworked it to have it Hunter-focused-only: removed the non-hunter/race stuff, improved the definition for spells/effects config that were not correct, added missing hunter spells (not many), and implemented my own bar color scheme fitting better the hunter spells."),
		"GameFontNormalSmall", -10)
	cursor = MTH_CreditsCreateLink(content,
		"https://github.com/wigan91/Chronometer-TWoW",
		"https://github.com/wigan91/Chronometer-TWoW",
		cursor,
		-4)


	cursor = MTH_CreditsCreateText(content, cursor,
		MTH_CR_L("CREDITS_ABOUT_ICU", "- ICU was an old vanilla addon. I used the following last revision and added many more features of config options to it."),
		"GameFontNormalSmall", -10)
	cursor = MTH_CreditsCreateLink(content,
		"https://github.com/wigan91/ICU-TWoW",
		"https://github.com/wigan91/ICU-TWoW",
		cursor,
		-4)

	cursor = MTH_CreditsCreateText(content, cursor,
		MTH_CR_L("CREDITS_ABOUT_MAP", "- The Map/Marker system is the one of pfQuest from Master Shagu. Unfortunately he is no more reachable for some months and I could not have some talk with him about this. I mostly let it untouched, I just made slight modifications so it can integrate better within Metahunt, and doesn't conflict with pfQuest."),
		"GameFontNormalSmall", -10)

	cursor = MTH_CreditsCreateText(content, cursor,
		MTH_CR_L("CREDITS_ABOUT_ATLAS_LINKS", "- The system allowing to fetch itemlinks in game (In the Weapon tab of the Hunter Book notably) is the one of Atlas Twow."),
		"GameFontNormalSmall", -10)

	cursor = MTH_CreditsCreateText(content, cursor, MTH_CR_L("CREDITS_ABOUT_DATA_TITLE", "About data sources"), "GameFontNormal", -14, 1.00, 0.82, 0.00)
	cursor = MTH_CreditsCreateText(content, cursor,
		MTH_CR_L("CREDITS_ABOUT_DATA_INTRO", "Metahunt ships with its own Turtle-WoW datastores, limited to hunter stuff only, and most of this data is up-to-date (Feb 2026).\n\n"
		.. "Sources used to build the data include:"),
		"GameFontNormalSmall", -10)

	cursor = MTH_CreditsCreateText(content, cursor,
		MTH_CR_L("CREDITS_DATA_PFQUEST", "- pfQuest for Beasts and Ammo vendors NPCs and their spawn points (and beasts respawn times if any). Thank you again Shagu."),
		"GameFontNormalSmall", -10)

	cursor = MTH_CreditsCreateText(content, cursor,
		MTH_CR_L("CREDITS_DATA_SHEET", "- This invaluable and very accurate spreadsheet for beasts having pet abilities. A big thanks to all twow players that crafted this! Now you dont need that sheet anymore, you have Metahunt! And the Great Book of Huntards is awesome and accurate also because of YOU."),
		"GameFontNormalSmall", -10)
	cursor = MTH_CreditsCreateLink(content,
		"https://docs.google.com/spreadsheets/d/1u33knqlYXvY-jR6pvTd58gyDg8OYEuwYsSoEnIjeA8k/edit?gid=4136205#gid=4136205",
		"https://docs.google.com/spreadsheets/d/1u33knqlYXvY-jR6pvTd58gyDg8OYEuwYsSoEnIjeA8k/edit?gid=4136205#gid=4136205",
		cursor,
		-4)

	cursor = MTH_CreditsCreateText(content, cursor,
		MTH_CR_L("CREDITS_DATA_OTHER", "- Atlas twow for ranged weapon sources\n\n"
		.. "- Twow wiki for pet diet (which was incomplete, missing Serpents and Foxes)"),
		"GameFontNormalSmall", -10)

	cursor = MTH_CreditsCreateText(content, cursor,
		MTH_CR_L("CREDITS_CLOSING", "With that being said, go back hunting fellas!"),
		"GameFontNormalSmall", -10, 1.00, 0.82, 0.00)

	cursor = MTH_CreditsCreateText(content, cursor,
		MTH_CR_L("CREDITS_SIGNATURE", "\n"
		.. "Metasploit <Atlantis>, of Nordaanar."),
		"GameFontNormalSmall", -10)
end
