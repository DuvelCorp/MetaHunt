-- MAX_SPELLS = 1024

local function ZSpellButton_ApplySavedVisibility(parent, foundCount)
	if not parent then
		return
	end

	local shouldShow = true
	if foundCount and tonumber(foundCount) then
		if tonumber(foundCount) <= 0 then
			shouldShow = false
		end
	end

	if type(MTH_ZH_GetSavedTable) == "function" and parent.name then
		local saved = MTH_ZH_GetSavedTable(parent.name)
		if saved then
			if saved["enabled"] == false or saved["enabled"] == 0 then
				shouldShow = false
			end
			if saved["parent"] and saved["parent"]["hide"] then
				shouldShow = false
			end
		end
	end

	if shouldShow then
		parent:Show()
	else
		parent:Hide()
	end
end


function ZSpellButton_SetButtons(parent, spells)
	--DEFAULT_CHAT_FRAME:AddMessage(" Parent = "..parent.name, 0, 1, 1)
	if not (parent and parent.count and parent.name and spells) then return end
	parent.spells = spells

	if type(parent.customSetButtons) == "function" then
		local customFound = parent.customSetButtons(parent, spells)
		ZSpellButton_ApplySavedVisibility(parent, customFound)
		return customFound
	end

	if not GetSpellName(1, "spell") then
		parent:RegisterEvent("SPELLS_CHANGED")
		return -1
	end
	local spell, finished, temp
	local info = {}
	-- Find All Spell IDs
	for i=1, MAX_SPELLS do
		spell = GetSpellName(i, "spell")
		if not spell or finished then
			break
		end
		finished = 1
		for i2=1, table.getn(spells) do
			if not info[i2] then
				finished = nil
				if spells[i2] == spell then
					temp = i
					while spells[i2] == spell do
						temp = temp + 1
						spell = GetSpellName(temp, "spell")
					end
					info[i2] = (temp-1)
					break
				end
			end
		end
	end
	-- Hide All Children
	for i=1, parent.count do
		local child = getglobal(parent.name..i)
		child:Hide()
		child.id = nil
		child.icon = nil
		child.isspell = nil
	end
	local button
	local count = 1
	-- Set Children IDs
	for i, v in info do
		if count > parent.count then break end
		button = getglobal(parent.name..count)
		button.id = v
		button.isspell=1
		ZSpellButton_UpdateButton(button)
		button:Show()
		-- Set The Parent To The First Spell
		if count == 1 then
			parent.id = v
			parent.isspell=1
			ZSpellButton_UpdateButton(parent)
			parent:Enable()
		end
		count = count + 1
	end
	local foundCount = count - 1
	ZSpellButton_ApplySavedVisibility(parent, foundCount)
	return foundCount
end

local function ZHunterMod_UpdateButtonCount(parent, found)
	return
end

function ZSpellButton_SetExpandDirection(parent, direction)
	local button = getglobal(parent.name.."1")
	local offset = parent:GetWidth() / 36
	local circleVisible = true
	if type(MTH_ZH_GetSavedTable) == "function" and parent and parent.name then
		local saved = MTH_ZH_GetSavedTable(parent.name)
		if saved and saved["parent"] and saved["parent"]["circle"] ~= nil then
			circleVisible = saved["parent"]["circle"] and true or false
		end
	end
	if parent and parent.circle then
		if circleVisible then
			parent.circle:Show()
		else
			parent.circle:Hide()
		end
	end
	if circleVisible then
		offset = offset * 5
	else
		offset = offset * 3
	end
	button:ClearAllPoints()
	if direction == "TOP" then
		button:SetPoint("BOTTOM", parent, "TOP", 0, offset)
	elseif direction == "BOTTOM" then
		button:SetPoint("TOP", parent, "BOTTOM", 0, -1 * offset)
	elseif direction == "LEFT" then
		button:SetPoint("RIGHT", parent, "LEFT", -1 * offset, 0)
	elseif direction == "RIGHT" then
		button:SetPoint("LEFT", parent, "RIGHT", offset, 0)
	end
end

function ZSpellButton_ArrangeChildren(parent, rows, count, horizontal, vertical)
	if not (parent and parent.count and parent.name) then return end
	local left, right, top, bottom = "LEFT", "RIGHT", "TOP", "BOTTOM"
	local xoffset = parent:GetWidth() / 36
	xoffset = xoffset * 3
	local yoffset = -1 * xoffset
	if horizontal then
		left, right = "RIGHT", "LEFT"
		xoffset = xoffset * -1
	end
	if vertical then
		top, bottom = "BOTTOM", "TOP"
		yoffset = yoffset * -1
	end
	if count > parent.count then
		count = parent.count
	end
	local cols = ceil(count / rows)
	local temp = 1
	local button
	for i=2, parent.count do
		button = getglobal(parent.name..i)
		if i > count then
			button:Hide()
		else
			if button.id then
				button:Show()
			end
			button:ClearAllPoints()
			if temp >= cols then
				button:SetPoint(top, getglobal(parent.name..(i-temp)), bottom, 0, yoffset)
				temp = 1
			else
				button:SetPoint(left, getglobal(parent.name..(i-1)), right, xoffset, 0)
				temp = temp + 1
			end

		end
	end
end

function ZSpellButton_SetSize(parent, size, setChildren)
	local bgscale = 64 / 36
	local cdscale = 0.75 / 36
	if setChildren then
		local button
		for i=1, parent.count do
			button = getglobal(parent.name..i)
			if button then
				button:SetHeight(size)
				button:SetWidth(size)
				if button.background then
					button.background:SetWidth(size * bgscale)
					button.background:SetHeight(size * bgscale)
				end
				if button.cooldown then
					button.cooldown:SetModelScale(size * cdscale)
				end
			end
		end
	else
		local cscale = 100/36
		local cxscale = 20 / 36
		local cyscale = -22 / 36
		local circleVisible = true
		if type(MTH_ZH_GetSavedTable) == "function" and parent and parent.name then
			local saved = MTH_ZH_GetSavedTable(parent.name)
			if saved and saved["parent"] and saved["parent"]["circle"] ~= nil then
				circleVisible = saved["parent"]["circle"] and true or false
			end
		end
		parent:SetHeight(size)
		parent:SetWidth(size)
		if parent.background then
			parent.background:SetWidth(size * bgscale)
			parent.background:SetHeight(size * bgscale)
		end
		if parent.cooldown then
			parent.cooldown:SetModelScale(size * cdscale)
		end
		if parent.circle then
			parent.circle:SetWidth(size * cscale)
			parent.circle:SetHeight(size * cscale)
			parent.circle:SetPoint("CENTER", size * cxscale, size * cyscale)
			if circleVisible then
				parent.circle:Show()
			else
				parent.circle:Hide()
			end
		end
	end
end

function ZSpellButton_UpdateButton(button)
	local texture
	if not button then
		button = this
	end
	if not (button.id and button.icontexture) then 
		return 
	end
	texture = button.icon or GetSpellTexture(button.id, "spell")
	button.icontexture:SetTexture(texture)
	button.icontexture:Show()
end

function ZSpellButton_UpdateCooldown(button)
	if not button then
		button = this
	end
	if not button.id or not button.isspell then return end
	local start, duration, enable = GetSpellCooldown(button.id, "spell")
	CooldownFrame_SetTimer(button.cooldown, start, duration, enable)
	if not button.customcolor then
		local r, g, b = 1.0, 1.0, 1.0
		if enable ~= 1 then
			r, g, b = 0.4, 0.4, 0.4
		end
		button.icontexture:SetVertexColor(r, g, b)
	end
end

function ZSpellButton_CreateChildren(parent, name, count)
	if not (parent and name and count) then return end
	if parent.children and parent.count and parent.name == name then
		parent.count = count
		if type(ZSpellButton_ApplyChildrenExpanded) == "function" then
			ZSpellButton_ApplyChildrenExpanded(parent)
		end
		return
	end
	parent.children = CreateFrame("Frame", parent:GetName().."Children", UIParent)
	parent.count = count
	parent.name = name
	local button
	for i=1, count do
		button = CreateFrame("CheckButton", parent.name..i, parent.children, "ZSpellButtonChildTemplate")
		button.parent = parent
	end
	if type(ZSpellButton_ApplyChildrenExpanded) == "function" then
		ZSpellButton_ApplyChildrenExpanded(parent)
	end
end

function ZSpellButton_OnLoad()
	this:RegisterEvent("SPELL_UPDATE_COOLDOWN")
	this:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	local name = this:GetName()
	this.icontexture = getglobal(name.."IconTexture")
	this.cooldown = getglobal(name.."Cooldown")
	this.background = getglobal(name.."Background")
end

function ZSpellButton_OnEvent() 
	if event == "SPELL_UPDATE_COOLDOWN" then
		ZSpellButton_UpdateCooldown()
	end
end

local function ZSpellButton_EnsureParentFlags(parent)
	if not (parent and parent.name) then
		return
	end
	local saved = MTH_ZH_GetSavedTable(parent.name)
	if parent.tooltip == nil and saved["tooltip"] ~= nil then
		parent.tooltip = saved["tooltip"] and true or false
	end
	if parent.hideonclick == nil and saved["children"] and saved["children"]["hideonclick"] ~= nil then
		parent.hideonclick = saved["children"]["hideonclick"] and true or false
	end
end

function ZSpellButton_GetChildrenExpanded(parent)
	if not (parent and parent.name) then
		return true
	end
	local saved = MTH_ZH_GetSavedTable(parent.name)
	if not saved["children"] then
		saved["children"] = {}
	end
	if saved["children"]["expanded"] == nil then
		saved["children"]["expanded"] = 1
	end
	local expanded = saved["children"]["expanded"] ~= false and saved["children"]["expanded"] ~= 0
	return expanded
end


function ZSpellButton_SetChildrenExpanded(parent, expanded)
	if not (parent and parent.name) then
		return
	end
	local saved = MTH_ZH_GetSavedTable(parent.name)
	if not saved["children"] then
		saved["children"] = {}
	end
	if expanded then
		saved["children"]["expanded"] = 1
		if parent.children then
			parent.children:Show()
		end
		if parent.count then
			for i = 1, parent.count do
				local child = getglobal(parent.name .. i)
				if child then
					if child.id then
						child:Show()
					else
						child:Hide()
					end
				end
			end
		end
	else
		saved["children"]["expanded"] = 0
		if parent.children then
			parent.children:Hide()
		end
		if parent.count then
			for i = 1, parent.count do
				local child = getglobal(parent.name .. i)
				if child then
					child:Hide()
				end
			end
		end
	end
end

function ZSpellButton_ApplyChildrenExpanded(parent)
	if not (parent and parent.children) then
		return
	end
	ZSpellButton_SetChildrenExpanded(parent, ZSpellButton_GetChildrenExpanded(parent))
end

local function ZSpellButton_SaveParentPosition(parent)
	if not (parent and parent.GetPoint) then
		return
	end
	if type(MTH_ZH_GetSavedTable) ~= "function" then
		return
	end
	local key = parent.name
	if (type(key) ~= "string" or key == "") and parent.GetName then
		key = parent:GetName()
	end
	if type(key) ~= "string" or key == "" then
		return
	end

	local saved = MTH_ZH_GetSavedTable(key)
	if type(saved) ~= "table" then
		return
	end
	if type(saved["parent"]) ~= "table" then
		saved["parent"] = {}
	end

	local point, _, relPoint, x, y = parent:GetPoint()
	x = tonumber(x)
	y = tonumber(y)
	if not (point and relPoint and x and y) then
		return
	end

	saved["parent"]["point"] = tostring(point)
	saved["parent"]["relativePoint"] = tostring(relPoint)
	saved["parent"]["x"] = math.floor(x + 0.5)
	saved["parent"]["y"] = math.floor(y + 0.5)
	if type(MTH_ZH_Trace) == "function" then
		MTH_ZH_Trace("persist-parent-position key=" .. tostring(key)
			.. " point=" .. tostring(saved["parent"]["point"])
			.. " rel=" .. tostring(saved["parent"]["relativePoint"])
			.. " x=" .. tostring(saved["parent"]["x"])
			.. " y=" .. tostring(saved["parent"]["y"]))
	end
end

local function ZSpellButton_RestoreParentPosition(parent)
	if not (parent and parent.ClearAllPoints and parent.SetPoint) then
		return false
	end
	if type(MTH_ZH_GetSavedTable) ~= "function" then
		return false
	end
	local key = parent.name
	if (type(key) ~= "string" or key == "") and parent.GetName then
		key = parent:GetName()
	end
	if type(key) ~= "string" or key == "" then
		return false
	end

	local saved = MTH_ZH_GetSavedTable(key)
	if type(saved) ~= "table" or type(saved["parent"]) ~= "table" then
		return false
	end

	local parentSaved = saved["parent"]
	local px = tonumber(parentSaved["x"])
	local py = tonumber(parentSaved["y"])
	local point = parentSaved["point"]
	local relPoint = parentSaved["relativePoint"]
	if not (px and py and type(point) == "string" and point ~= "") then
		return false
	end

	if type(relPoint) ~= "string" or relPoint == "" then
		relPoint = point
	end

	parent:ClearAllPoints()
	parent:SetPoint(point, UIParent, relPoint, px, py)
	if type(MTH_ZH_Trace) == "function" then
		MTH_ZH_Trace("restore-parent-position key=" .. tostring(key)
			.. " point=" .. tostring(point)
			.. " rel=" .. tostring(relPoint)
			.. " x=" .. tostring(px)
			.. " y=" .. tostring(py))
	end
	return true
end

function ZSpellButton_OnEnter()
	ZSpellButton_EnsureParentFlags(this.parent)
	if this.parent.tooltip then
		GameTooltip:SetOwner(this, "ANCHOR_TOPRIGHT")
		if this.isspell then 
			GameTooltip:SetSpell(this.id, "spell") 
		else
			local showedItemTooltip = nil
			if this.ammobag and this.ammoslot and type(GameTooltip.SetBagItem) == "function" then
				GameTooltip:ClearLines()
				GameTooltip:SetBagItem(this.ammobag, this.ammoslot)
				if type(GameTooltip.NumLines) == "function" and GameTooltip:NumLines() > 0 then
					local left1 = getglobal("GameTooltipTextLeft1")
					if left1 and left1.GetText and tostring(left1:GetText() or "") ~= "" then
						showedItemTooltip = true
					end
				end
			end
			if (not showedItemTooltip) and this.ammolink and type(GameTooltip.SetHyperlink) == "function" then
				GameTooltip:ClearLines()
				GameTooltip:SetHyperlink(this.ammolink)
				if type(GameTooltip.NumLines) == "function" and GameTooltip:NumLines() > 0 then
					local left1 = getglobal("GameTooltipTextLeft1")
					if left1 and left1.GetText and tostring(left1:GetText() or "") ~= "" then
						showedItemTooltip = true
					end
				end
			end
			if not showedItemTooltip then
				local label = this.ammoname or this.ammolink or "Ammo"
				if this.ammocount then
					label = tostring(this.ammocount) .. " x " .. tostring(label)
				end
				GameTooltip:SetText(label, 1, 1, 1)
			end
		end 
		GameTooltip:Show()
	end
end

function ZSpellButton_OnClick()
	ZSpellButton_EnsureParentFlags(this.parent)
	this:SetChecked(0)
	if type(this.parent.beforeclick) == "function" then
		if this.parent.beforeclick(this) then
			return
		end
	end
	if this.isspell then 
		CastSpell(this.id, "spell") 
	else
		PickupContainerItem(this.ammobag,this.ammoslot)	
		EquipCursorItem(0)
		
		-- Update parent button immediately to show newly equipped ammo
		if not this.isspell then
			this.parent.id = this.ammoid
			this.parent.icon = this.icon
			this.parent.isspell = nil
			this.parent.ammoname = this.ammoname
			this.parent.ammobrol = this.ammobrol
			this.parent.ammoqual = this.ammoqual
			this.parent.ammolvl = this.ammolvl
			this.parent.ammotype = this.ammotype
			this.parent.ammobag = this.ammobag
			this.parent.ammoslot = this.ammoslot
			this.parent.ammoid = this.ammoid
			this.parent.ammolink = this.ammolink
			this.parent.ammocount = this.ammocount
			if type(this.parent.customUpdateButton) == "function" then
				this.parent.customUpdateButton(this.parent)
			else
				ZSpellButton_UpdateButton(this.parent)
			end
		end
	end
	if type(this.parent.afterclick) == "function" then
		if this.parent.afterclick(this) then
			return
		end
	end
	if this.parent.hideonclick then
		if type(ZSpellButton_SetChildrenExpanded) == "function" then
			ZSpellButton_SetChildrenExpanded(this.parent, false)
		elseif this.parent.children then
			this.parent.children:Hide()
		end
	end
end

function ZSpellButtonParent_OnLoad()
	this:RegisterEvent("SPELL_UPDATE_COOLDOWN")
	this:RegisterEvent("LEARNED_SPELL_IN_TAB")
	this:RegisterForDrag("LeftButton")
	this:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	local name = this:GetName()
	this.icontexture = getglobal(name.."IconTexture")
	this.cooldown = getglobal(name.."Cooldown")
	this.background = getglobal(name.."Background")
	this.circle = getglobal(name.."Circle")
	-- Keep enabled so empty buttons can be moved on low-level characters.
	this:Enable()
	ZSpellButton_RestoreParentPosition(this)
	if this.SetScript then
		this:SetScript("OnDragStart", function(self)
			self = self or this
			if IsAltKeyDown() then
				if type(MTH_ZH_TraceButtonPoint) == "function" then
					MTH_ZH_TraceButtonPoint(self, "drag-start")
				end
				self:StartMoving()
				self.isMoving = true
			end
		end)
		this:SetScript("OnDragStop", function(self)
			self = self or this
			if not self then
				return
			end
			if self.StopMovingOrSizing then
				self:StopMovingOrSizing()
			end
			ZSpellButton_SaveParentPosition(self)
			self.isMoving = false
			if type(MTH_ZH_TraceButtonPoint) == "function" then
				MTH_ZH_TraceButtonPoint(self, "drag-stop")
			end
		end)
		this:SetScript("OnMouseUp", function(self)
			self = self or this
			if self and self.isMoving then
				if self.StopMovingOrSizing then
					self:StopMovingOrSizing()
				end
				ZSpellButton_SaveParentPosition(self)
				self.isMoving = false
				if type(MTH_ZH_TraceButtonPoint) == "function" then
					MTH_ZH_TraceButtonPoint(self, "mouse-up-stop")
				end
			end
		end)
	end
end

function ZSpellButtonParent_OnEvent()
	if event == "SPELL_UPDATE_COOLDOWN" then
		ZSpellButton_UpdateCooldown()
	elseif event == "LEARNED_SPELL_IN_TAB" then
		if this.name and this.count and this.spells then
			local found = ZSpellButton_SetButtons(this, this.spells)
			ZHunterMod_UpdateButtonCount(this, found)
		end
	elseif event == "SPELLS_CHANGED" then
		this.found = ZSpellButton_SetButtons(this, this.spells)
		ZHunterMod_UpdateButtonCount(this, this.found)
		if this.found == 0 then
			this:Hide()
		end
		if this.found > -1 then
			this:UnregisterEvent("SPELLS_CHANGED")
		end
	end
end

function ZSpellButtonParent_OnEnter(frame)
	if not frame then
		frame = this
	end
	ZSpellButton_EnsureParentFlags(frame)
	if frame.tooltip and frame.id then
		GameTooltip:SetOwner(frame, "ANCHOR_TOPLEFT")
		local msg, rank
	
		if frame.isspell then 
			msg, rank = GetSpellName(frame.id, "spell")
			if string.len(rank) > 0 then
				msg = msg.." ("..rank..")"
			end
			GameTooltip:SetText(msg, 1, 1, 1)
		else
			local showedItemTooltip = nil
			if frame.ammobag and frame.ammoslot and type(GameTooltip.SetBagItem) == "function" then
				GameTooltip:ClearLines()
				GameTooltip:SetBagItem(frame.ammobag, frame.ammoslot)
				if type(GameTooltip.NumLines) == "function" and GameTooltip:NumLines() > 0 then
					local left1 = getglobal("GameTooltipTextLeft1")
					if left1 and left1.GetText and tostring(left1:GetText() or "") ~= "" then
						showedItemTooltip = true
					end
				end
			end
			if (not showedItemTooltip) and frame.ammolink and type(GameTooltip.SetHyperlink) == "function" then
				GameTooltip:ClearLines()
				GameTooltip:SetHyperlink(frame.ammolink)
				if type(GameTooltip.NumLines) == "function" and GameTooltip:NumLines() > 0 then
					local left1 = getglobal("GameTooltipTextLeft1")
					if left1 and left1.GetText and tostring(left1:GetText() or "") ~= "" then
						showedItemTooltip = true
					end
				end
			end
			if not showedItemTooltip then
				msg = frame.ammoname or frame.ammolink or "Ammo"
				if frame.ammocount then
					msg = tostring(frame.ammocount) .. " x " .. tostring(msg)
				end
				GameTooltip:SetText(msg, 1, 1, 1)
			end
		end 

		GameTooltip:AddLine("Alt+Drag To Move This Button")
		GameTooltip:Show()
	end
end

function ZSpellButtonParent_OnClick()
	ZSpellButton_EnsureParentFlags(this)
	this:SetChecked(0)
	if arg1 == "RightButton" then
		local showChildren = not this.children:IsVisible()
		if type(ZSpellButton_SetChildrenExpanded) == "function" then
			ZSpellButton_SetChildrenExpanded(this, showChildren)
		elseif showChildren then
			this.children:Show()
		else
			this.children:Hide()
		end
	else
		if type(this.beforeclick) == "function" then
			if this.beforeclick(this) then
				return
			end
		end
		if this.isspell then
			if not this.id then
				return
			end
			CastSpell(this.id, "spell")
		else
			if not (this.ammobag and this.ammoslot) then
				return
			end
			PickupContainerItem(this.ammobag,this.ammoslot)	
			EquipCursorItem(0)		
		end
		if type(this.afterclick) == "function" then
			if this.afterclick(this) then
				return
			end
		end
		if this.hideonclick then
			if type(ZSpellButton_SetChildrenExpanded) == "function" then
				ZSpellButton_SetChildrenExpanded(this, false)
			elseif this.children then
				this.children:Hide()
			end
		end
	end
end