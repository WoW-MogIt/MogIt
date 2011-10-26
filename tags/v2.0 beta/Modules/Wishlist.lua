local MogIt, mog = ...
local L = mog.L

local wishlist = mog:RegisterModule("Wishlist", {}, true)

local function onProfileUpdated(self, event)
	mog:BuildList(true, "Wishlist")
end

local defaults = {
	profile = {
		items = {},
		sets = {},
	}
}

function wishlist:MogItLoaded()
	local AceDB = LibStub("AceDB-3.0")
	local db = AceDB:New("MogItWishlist", defaults)
	self.db = db
	
	-- convert old database
	if MogIt_Wishlist then -- v1.1.4
		local tbl = {}
		for k, v in pairs(MogIt_Wishlist.display) do
			tinsert(tbl, k)
		end
		sort(tbl, function(a, b)
			return MogIt_Wishlist.time[a] < MogIt_Wishlist.time[b]
		end)
		for k, v in ipairs(tbl) do
			tinsert(self.db.profile.items, tonumber(type(MogIt_Wishlist.display[v]) == "table" and MogIt_Wishlist.display[v][1] or MogIt_Wishlist.display[v]))
		end
		MogIt_Wishlist = nil
	end
	
	local function upgradeDB(dbTable)
		db.profile.items = dbTable.wishlist.items
		db.profile.sets = dbTable.wishlist.sets
		for i, itemID in ipairs(db.profile.items) do
			db.profile.items[i] = tonumber(itemID)
		end
		for i, set in ipairs(db.profile.sets) do
			set.items = {}
			for slotID, items in pairs(set) do
				if type(slotID) == "number" then
					local itemID = tonumber(items[1])
					set.items[mog.itemSlots[slotID]] = itemID
					set[slotID] = nil
				end
			end
		end
	end
	
	-- convert old database
	if MogIt_Global then -- v1.2b
		local prevProfile = db:GetCurrentProfile()
		db:SetProfile("Default")
		upgradeDB(MogIt_Global)
		db:SetProfile(prevProfile)
		MogIt_Global = nil
		print("MogIt: Database upgraded. Previous account wide wishlist was moved to 'Default' profile.")
	end
	if MogIt_Character then -- v1.2b
		upgradeDB(MogIt_Character)
		MogIt_Character = nil
	end
	
	db.RegisterCallback(self, "OnProfileChanged", onProfileUpdated)
	db.RegisterCallback(self, "OnProfileCopied", onProfileUpdated)
	db.RegisterCallback(self, "OnProfileReset", onProfileUpdated)
end

local level3 = {
	{
		text = "Rename set",
		func = function(self)
			wishlist:RenameSet(wishlist.db.profile.sets[self.value].name)
			CloseDropDownMenus()
		end,
	},
	{
		text = "Delete set",
		func = function(self)
			tremove(wishlist.db.profile.sets, self.value)
			mog:BuildList(nil, "Wishlist")
			CloseDropDownMenus()
		end,
	},
}

function wishlist:Dropdown(level)
	if level == 1 then
		local info = UIDropDownMenu_CreateInfo()
		info.text = "Wishlist"
		info.value = self
		info.colorCode = "|cffffff00"
		info.hasArrow = true
		info.notCheckable = true
		info.func = function(self)
			mog:SetModule(wishlist, L["Wishlist"])
		end
		UIDropDownMenu_AddButton(info, level)
	elseif level == 2 then
		local info = UIDropDownMenu_CreateInfo()
		info.text = "New set"
		info.func = function(self)
			StaticPopup_Show("MOGIT_WISHLIST_CREATE_SET")
			CloseDropDownMenus()
		end
		info.notCheckable = true
		UIDropDownMenu_AddButton(info, level)
		
		for i, set in ipairs(wishlist.db.profile.sets) do
			local info = UIDropDownMenu_CreateInfo()
			info.text = set.name
			info.value = i
			-- info.func = function(self)
				-- wishlist:AddItem(menuList.value, self.value)
				-- mog:BuildList()
				-- CloseDropDownMenus()
			-- end
			info.hasArrow = true
			info.notCheckable = true
			UIDropDownMenu_AddButton(info, level)
		end
	elseif level == 3 then
		for i, v in ipairs(level3) do
			v.value = UIDROPDOWNMENU_MENU_VALUE
			v.notCheckable = true
			UIDropDownMenu_AddButton(v, level)
		end
	end
end

function wishlist:FrameUpdate(frame, value, index)
	local data = frame.data
	local type = type(value) == "table"
	if type then
		data.name = value.name
		data.items = value.items
		mog.Set_FrameUpdate(frame, frame.data)
	else
		data.item = value
		mog.Item_FrameUpdate(frame, frame.data)
	end
end

local data = mog.items

local function getSourceInfo(itemID)
	local data = data or mog.items
	local source = data.source[itemID]
	local sourceID = data.sourceid[itemID]
	local sourceInfo = data.sourceinfo[itemID]
	local info = mog.sub.source[source]
	local extraInfo
	if source == 1 then -- Drop
		if sourceID then
			extraInfo = mog.GetMob(sourceID)
		end
	-- elseif source == 3 then -- Quest
	elseif source == 5 then -- Crafted
		if sourceInfo then
			extraInfo = mog.sub.professions[sourceInfo]
		end
	elseif source == 6 then -- Achievement
		if sourceID then
			local _, name, _, complete = GetAchievementInfo(sourceID)
			extraInfo = name
		end
	end
	local zone
	if data.zone[itemID] then
		zone = GetMapNameByID(data.zone[itemID])
		if zone then
			if source == 1 and extraInfo then
				if mog.sub.diffs[sourceInfo] then
					zone = zone.." ("..mog.sub.diffs[sourceInfo]..")"
				end
				info = extraInfo
				extraInfo = zone
			else
				extraInfo = zone
			end
		end
	end
	return extraInfo and format("%s (%s)", info, extraInfo) or info
end

local displayIDs = {}

function wishlist:OnEnter(frame, value)
	GameTooltip:SetOwner(frame, "ANCHOR_RIGHT")
	-- GameTooltip:SetOwner(self, "ANCHOR_NONE")
	-- GameTooltip:ClearAllPoints()
	-- GameTooltip:SetPoint("TOPLEFT", mog.frame, "TOPRIGHT", 5, 0)
	
	-- if self.data.type == "set" then
	if type(value) == "table" then
		GameTooltip:AddLine(value.name)
		for i, slot in ipairs(mog.itemSlots) do
			local itemID = value.items[slot]
			if itemID then
				local name, link, _, _, _, _, _, _, _, texture = GetItemInfo(itemID)
				GameTooltip:AddDoubleLine(link, getSourceInfo(itemID))
				GameTooltip:AddTexture(GetItemIcon(itemID))
			end
		end
	else
		local name, link, _, _, _, _, _, _, _, texture = GetItemInfo(value)
		GameTooltip:AddDoubleLine(link, getSourceInfo(value))
		
		local display = mog.items.display
		if display[value] then
			local d = display[value]
			if not displayIDs[d] then
				displayIDs[d] = {}
				for itemID, displayID in pairs(display) do
					if displayID == d then
						tinsert(displayIDs[d], itemID)
					end
				end
			end
			if #displayIDs[d] > 1 then
				GameTooltip:AddLine(" ")
				GameTooltip:AddLine("Alternate items:")
				for i, itemID in ipairs(displayIDs[d]) do
					if itemID ~= value then
						local name, link, _, _, _, _, _, _, _, texture = GetItemInfo(itemID)
						GameTooltip:AddDoubleLine(link, getSourceInfo(itemID))
					end
				end
			end
		end
	end
	
	--[=[
	if mog.sub.filters.slot[item] then
		GameTooltip:AddDoubleLine(L["Slot"]..":",mog.sub.slots[mog.sub.filters.slot[item]],nil,nil,nil,1,1,1);
	end
	]=]
	GameTooltip:Show()
end

function wishlist:OnClick(frame, button, value)
	if type(value) == "table" then
		mog.Set_OnClick(frame, button, frame.data)
	else
		mog.Item_OnClick(frame, button, frame.data)
	end
end

local list = {}

function wishlist:BuildList()
	wipe(list)
	local db = self.db.profile
	for i, v in ipairs(db.sets) do
		list[#list + 1] = v
	end
	for i, v in ipairs(db.items) do
		list[#list + 1] = v
	end
	return list
end

function wishlist:Unlist()
	wipe(list);
end

function wishlist:Help()
	--GameTooltip:AddDoubleLine(L["Change item"],L["Left click"],0,1,0,1,1,1);
	GameTooltip:AddDoubleLine(L["Chat link"],L["Shift + Left click"],0,1,0,1,1,1);
	GameTooltip:AddDoubleLine(L["Try on"],L["Ctrl + Left click"],0,1,0,1,1,1);
	GameTooltip:AddDoubleLine(L["Wishlist menu"],L["Right click"],0,1,0,1,1,1);
	GameTooltip:AddDoubleLine(L["Item URL"],L["Shift + Right click"],0,1,0,1,1,1);
	GameTooltip:AddDoubleLine(L["Add to preview"],L["Ctrl + Right click"],0,1,0,1,1,1);
end
	
function wishlist:AddItem(itemID, setName)
	if not setName and self:IsItemInWishlist(itemID) then
		return false
	end
	if setName then
		for i, set in ipairs(self.db.profile.sets) do
			if set.name == setName then
				local slot = mog.invSlots[select(9, GetItemInfo(itemID))]
				set.items[slot] = itemID
				break
			end
		end
	else
		tinsert(self.db.profile.items, itemID)
	end
	return true
end

function wishlist:DeleteItem(itemID, setName)
	-- if not setName and self:IsItemInWishlist(itemID) then
		-- return false
	-- end
	if setName then
		for i, set in ipairs(self.db.profile.sets) do
			if set.name == setName then
				for slot, item in pairs(set.items) do
					if item == itemID then
						set.items[slot] = nil
						return
					end
				end
			end
		end
	else
		local items = self.db.profile.items
		for i = 1, #items do
			local v = items[i]
			if v == itemID then
				tremove(items, i)
				break
			end
		end
	end
end

function wishlist:CreateSet(name)
	if self:IsSetInWishlist(name) then
		return false
	end
	tinsert(self.db.profile.sets, {name = name, items = {}})
	return true
end

function wishlist:RenameSet(set)
	StaticPopup_Show("MOGIT_WISHLIST_RENAME_SET", nil, nil, self:GetSet(set))
end

function wishlist:IsItemInWishlist(itemID)
	for i, v in ipairs(self.db.profile.items) do
		if v == itemID then
			return true
		end
	end
	return false
end

function wishlist:IsSetInWishlist(setName)
	for i, set in ipairs(self.db.profile.sets) do
		if set.name == setName then
			return true
		end
	end
	return false
end

function wishlist:GetSets()
	return self.db.profile.sets
end

function wishlist:GetSet(name)
	for i, set in ipairs(self.db.profile.sets) do
		if set.name == name then
			return set
		end
	end
end

local function onAccept(self)
	local text = self.editBox:GetText()
	local create = wishlist:CreateSet(text)
	if not create then
		return
	end
	if self.data then
		if type(self.data) == "table" then
			for i, v in ipairs(self.data.items) do
				wishlist:AddItem(v, text)
			end
		else
			wishlist:AddItem(self.data, text)
		end
	end
	mog:BuildList(nil, "Wishlist")
end

-- "create set" popup
StaticPopupDialogs["MOGIT_WISHLIST_CREATE_SET"] = {
	text = L["Enter set name"],
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = true,
	OnAccept = onAccept,
	EditBoxOnEnterPressed = function(self)
		local parent = self:GetParent()
		onAccept(parent)
		parent:Hide()
	end,
	OnShow = function(self)
		self.editBox:SetText("Set "..(#wishlist:GetSets() + 1))
		self.editBox:SetFocus()
	end,
	whileDead = true,
	timeout = 0,
}

-- "rename set" popup
StaticPopupDialogs["MOGIT_WISHLIST_RENAME_SET"] = {
	text = L["Enter set name"],
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = true,
	OnAccept = function(self)
		local text = self.editBox:GetText()
		self.data.name = text
		mog:BuildList(nil, "Wishlist")
	end,
	EditBoxOnEnterPressed = function(self)
		local text = self:GetText()
		self:GetParent().data.name = text
		mog:BuildList(nil, "Wishlist")
		self:GetParent():Hide()
	end,
	OnShow = function(self)
		self.editBox:SetText(self.data.name)
		self.editBox:HighlightText()
	end,
	whileDead = true,
	timeout = 0,
}