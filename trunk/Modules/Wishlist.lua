local MogIt, mog = ...
local L = mog.L

local wishlist = mog:RegisterModule("Wishlist", {}, true)

local invSlots = {
	INVTYPE_HEAD = "HeadSlot",
	INVTYPE_SHOULDER = "ShoulderSlot",
	INVTYPE_BODY = "ShirtSlot",
	INVTYPE_CLOAK = "BackSlot",
	INVTYPE_CHEST = "ChestSlot",
	INVTYPE_ROBE = "ChestSlot",
	INVTYPE_WAIST = "WaistSlot",
	INVTYPE_LEGS = "LegsSlot",
	INVTYPE_FEET = "FeetSlot",
	INVTYPE_WRIST = "WristSlot",
	INVTYPE_2HWEAPON = "MainHandSlot",
	INVTYPE_WEAPON = "MainHandSlot",
	INVTYPE_WEAPONMAINHAND = "MainHandSlot",
	INVTYPE_WEAPONOFFHAND = "SecondaryHandSlot",
	INVTYPE_SHIELD = "SecondaryHandSlot",
	INVTYPE_HOLDABLE = "SecondaryHandSlot",
	INVTYPE_RANGED = "RangedSlot",
	INVTYPE_RANGEDRIGHT = "RangedSlot",
	INVTYPE_THROWN = "RangedSlot",
	INVTYPE_HAND = "HandsSlot",
	INVTYPE_TABARD = "TabardSlot",
}

local itemSlots = {
	"HeadSlot",
	"ShoulderSlot",
	"BackSlot",
	"ChestSlot",
	"ShirtSlot",
	"TabardSlot",
	"WristSlot",
	"HandsSlot",
	"WaistSlot",
	"LegsSlot",
	"FeetSlot",
	"MainHandSlot",
	"SecondaryHandSlot",
	"RangedSlot",
}

-- "create set" popup
StaticPopupDialogs["MOGIT_WISHLIST_CREATE_SET"] = {
	text = L["Enter set name"],
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = true,
	OnAccept = function(self)
		local text = self.editBox:GetText()
		wishlist:CreateSet(text)
		mog:BuildList()
	end,
	EditBoxOnEnterPressed = function(self)
		local text = self:GetParent().editBox:GetText()
		wishlist:CreateSet(text)
		mog:BuildList()
		self:GetParent():Hide()
	end,
	OnShow = function(self)
		self.editBox:SetText("Set "..(#wishlist.db.profile.sets + 1))
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
		-- mog:BuildList()
	end,
	EditBoxOnEnterPressed = function(self)
		local text = self:GetParent().editBox:GetText()
		self:GetParent().data.name = text
		-- mog:BuildList()
		self:GetParent():Hide()
	end,
	OnShow = function(self)
		self.editBox:SetText(self.data.name)
		-- self.editBox:SetFocus()
	end,
	whileDead = true,
	timeout = 0,
}

local dropdown = CreateFrame("Frame")
dropdown.displayMode = "MENU"
--dropdown.point = "TOPLEFT"
--dropdown.relativePoint = "TOPRIGHT"
function dropdown:initialize(level, menuList)
	self.menu[menuList.type][level](menuList, level)
end

local itemMenu = {
	{
		text = "Add to set",
		hasArrow = true,
		notCheckable = true,
	},
	{
		text = "Delete",
		func = function(self)
			tremove(wishlist.db.profile.items, self.value)
			mog:BuildList()
		end,
		notCheckable = true,
	},
}

dropdown.menu = {
	-- menu used for single items
	item = {
		-- top level menu
		[1] = function(menuList, level)
			for k, v in pairs(itemMenu) do
				v.value = menuList.index - #wishlist.db.profile.sets
				v.menuList = menuList
				UIDropDownMenu_AddButton(v, level)
			end
		end,
		-- second level menu
		[2] = function(menuList, level)
			for i, set in ipairs(wishlist.db.profile.sets) do
				local info = UIDropDownMenu_CreateInfo()
				info.text = set.name
				info.func = function(self)
					wishlist:AddItem(menuList.value, self.value)
					mog:BuildList()
					CloseDropDownMenus()
				end
				info.notCheckable = true
				UIDropDownMenu_AddButton(info, level)
			end
		end,
	},
	-- menu used for sets
	set = {
		[1] = function(menuList, level)
			for i, slot in ipairs(itemSlots) do
				local itemID = menuList.value.items[slot]
				if itemID then
					local itemName, _, itemQuality = GetItemInfo(itemID)
					local info = UIDropDownMenu_CreateInfo()
					info.text = itemName
					info.value = itemID
					-- info.icon = GetItemIcon(itemID)
					info.hasArrow = true
					info.colorCode = "|c"..select(4, GetItemQualityColor(itemQuality))
					info.notCheckable = true
					info.menuList = menuList
					UIDropDownMenu_AddButton(info, level)
				end
			end
			local info = UIDropDownMenu_CreateInfo()
			info.text = "Delete set"
			info.value = menuList.index
			info.func = function(self)
				tremove(wishlist.db.profile.sets, self.value)
				mog:BuildList()
			end
			info.notCheckable = true
			UIDropDownMenu_AddButton(info, level)
		end,
		[2] = function(menuList, level)
			local info = UIDropDownMenu_CreateInfo()
			info.text = "Add to set"
			info.value = UIDROPDOWNMENU_MENU_VALUE
			info.hasArrow = true
			info.notCheckable = true
			info.menuList = menuList
			UIDropDownMenu_AddButton(info, level)
			
			local info = UIDropDownMenu_CreateInfo()
			info.text = "Add as single item"
			info.value = UIDROPDOWNMENU_MENU_VALUE
			info.func = function(self)
				wishlist:AddItem(self.value)
				mog:BuildList()
				CloseDropDownMenus()
			end
			info.notCheckable = true
			UIDropDownMenu_AddButton(info, level)
			
			local info = UIDropDownMenu_CreateInfo()
			info.text = "Delete"
			-- info.value = 
			info.func = function(self)
				wishlist.db.profile.sets[menuList.index].items[invSlots[select(9, GetItemInfo(UIDROPDOWNMENU_MENU_VALUE))]] = nil
				mog:BuildList()
				CloseDropDownMenus()
			end
			info.notCheckable = true
			UIDropDownMenu_AddButton(info, level)
		end,
		[3] = function(menuList, level)
			for i, set in ipairs(wishlist.db.profile.sets) do
				local info = UIDropDownMenu_CreateInfo()
				info.text = set.name
				info.func = function(self, arg1)
					wishlist:AddItem(arg1, self.value)
					mog:BuildList()
					CloseDropDownMenus()
				end
				info.notCheckable = true
				info.arg1 = UIDROPDOWNMENU_MENU_VALUE
				UIDropDownMenu_AddButton(info, level)
			end
		end,
	}
}

local defaults = {
	profile = {
		items = {},
		sets = {},
	}
}

function wishlist:AddonLoaded()
	local AceDB = LibStub("AceDB-3.0")
	local db = AceDB:New("MogItWishlist", defaults)
	self.db = db
	
	-- convert old database
	if MogIt_Character then
		db.profile.items = MogIt_Character.wishlist.items
		db.profile.sets = MogIt_Character.wishlist.sets
		for i, itemID in ipairs(db.profile.items) do
			db.profile.items[i] = tonumber(itemID)
		end
		for i, set in ipairs(db.profile.sets) do
			set.items = {}
			for slotID, items in pairs(set) do
				if type(slotID) == "number" then
					local itemID = tonumber(items[1])
					set.items[itemSlots[slotID]] = itemID
					set[slotID] = nil
				end
			end
		end
	end
	
	for key, profile in pairs(db.profiles) do
		if profile.sets then
			for i, set in ipairs(profile.sets) do
				if type(next(set.items)) == "string" then
					break
				end
				for slotID = 1, #itemSlots do
					local itemID = set.items[slotID]
					local slotName = itemID and itemSlots[slotID]
					if slotName then
						set.items[slotName] = itemID
						set.items[slotID] = nil
					end
				end
			end
		end
	end
	
	-- db.RegisterCallback(self, "OnProfileChanged", "LoadSettings")
	-- db.RegisterCallback(self, "OnProfileCopied", "LoadSettings")
	-- db.RegisterCallback(self, "OnProfileReset", "LoadSettings")
end

local level3 = {
	{
		text = "Rename set",
		func = function(self)
			StaticPopup_Show("MOGIT_WISHLIST_RENAME_SET", nil, nil, wishlist.db.profile.sets[self.value])
			CloseDropDownMenus()
		end,
	},
	{
		text = "Delete set",
		func = function(self)
			tremove(wishlist.db.profile.sets, self.value)
			mog:BuildList()
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
		-- info.value = v
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

function wishlist:FrameUpdate(self, value, index)
	local data = self.data
	data.type = type(value) == "table" and "set" or "item"
	data.value = value
	data.index = index
	self.model:Undress()
	if data.type == "set" then
		for slot, itemID in pairs(value.items) do
			self.model:TryOn(itemID)
		end
	else
		-- data.item = value.itemID
		self.model:TryOn(value)
	end
end

function wishlist:OnEnter(self)
	-- if not self then return end
	local data = self.data
	local value = data.value
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	-- GameTooltip:SetOwner(self, "ANCHOR_NONE")
	-- GameTooltip:ClearAllPoints()
	-- GameTooltip:SetPoint("TOPLEFT",mog.frame,"TOPRIGHT",5,0)
	
	local data = mog.sub.data
	-- if data.type == "set" then
	if self.data.type == "set" then
		GameTooltip:AddLine(value.name)
		for i, slot in ipairs(itemSlots) do
			local itemID = value.items[slot]
			if itemID then
				local name, link, _, _, _, _, _, _, _, texture = GetItemInfo(itemID)
				local source = data.source[itemID]
				local sourceID = data.sourceid[itemID]
				local sourceInfo = data.sourceinfo[itemID]
				local info = mog.sub.source[source]
				local extraInfo
				if source == 1 then -- Drop
					if sourceID then
						extraInfo = mog.GetMob(sourceID)
					end
				--elseif source == 3 then -- Quest
				elseif source == 5 then -- Crafted
					if sourceInfo then
						extraInfo = mog.sub.professions[sourceInfo]
					end
				-- elseif source == 6 then -- Achievement
					-- if mog.sub.filters.sourceid[item] then
						-- local _,name,_,complete = GetAchievementInfo(mog.sub.filters.sourceid[item]);
						-- GameTooltip:AddDoubleLine(L["Achievement"]..":",name,nil,nil,nil,1,1,1);
						-- GameTooltip:AddDoubleLine(STATUS..":",complete and COMPLETE or INCOMPLETE,nil,nil,nil,1,1,1);
					-- end
				end
				local zone
				if data.zone[itemID] then
					zone = GetMapNameByID(data.zone[itemID])
					if zone then
						if source == 1 and extraInfo then
							if mog.sub.diffs[sourceInfo] then
								zone = zone.." ("..mog.sub.diffs[sourceInfo]..")"
							end
							info = zone
							-- extraInfo = 
						else
							extraInfo = zone
						end
					end
				end
				GameTooltip:AddDoubleLine(link, source and (extraInfo and strjoin(", ", info, extraInfo or "") or info))
				GameTooltip:AddTexture(GetItemIcon(itemID))
			end
		end
	else
		local name, link, _, _, _, _, _, _, _, texture = GetItemInfo(value)
		-- GameTooltip:AddLine(self.display,1,1,1)
		-- GameTooltip:AddLine(" ")
		
		-- for i = 1, #items do
			-- local item, source = items[i]
			-- local source = sources[item.id]
			GameTooltip:AddDoubleLine(link, mog.sub.source[data.source[value]])
		-- end
	end
	
	--[=[
	if mog.sub.filters.source[item] then
		GameTooltip:AddDoubleLine(L["Source"]..":",mog.sub.source[mog.sub.filters.source[item]],nil,nil,nil,1,1,1);
		if mog.sub.filters.source[item] == 1 then -- Drop
			if mog.sub.bosses[mog.sub.filters.sourceid[item]] then
				GameTooltip:AddDoubleLine(BOSS..":",mog.sub.bosses[mog.sub.filters.sourceid[item]],nil,nil,nil,1,1,1);
			end
		--elseif mog.filters.source[self.item] == 3 then -- Quest
		elseif mog.sub.filters.source[item] == 5 then -- Crafted
			if mog.sub.filters.sourceinfo[item] then
				GameTooltip:AddDoubleLine(L["Profession"]..":",mog.sub.professions[mog.sub.filters.sourceinfo[item]],nil,nil,nil,1,1,1);
			end
		elseif mog.sub.filters.source[item] == 6 then -- Achievement
			if mog.sub.filters.sourceid[item] then
				local _,name,_,complete = GetAchievementInfo(mog.sub.filters.sourceid[item]);
				GameTooltip:AddDoubleLine(L["Achievement"]..":",name,nil,nil,nil,1,1,1);
				GameTooltip:AddDoubleLine(STATUS..":",complete and COMPLETE or INCOMPLETE,nil,nil,nil,1,1,1);
			end
		end
	end
	if mog.sub.filters.zone[item] then
		local zone = GetMapNameByID(mog.sub.filters.zone[item]);
		if zone then
			if mog.sub.filters.source[item] == 1 and mog.sub.diffs[mog.sub.filters.sourceinfo[item]] then
				zone = zone.." ("..mog.sub.diffs[mog.sub.filters.sourceinfo[item]]..")";
			end
			GameTooltip:AddDoubleLine(ZONE..":",zone,nil,nil,nil,1,1,1);
		end
	end
	
	GameTooltip:AddLine(" ");
	GameTooltip:AddDoubleLine(ID..":",item,nil,nil,nil,1,1,1);
	if mog.sub.filters.lvl[item] then
		GameTooltip:AddDoubleLine(LEVEL..":",mog.sub.filters.lvl[item],nil,nil,nil,1,1,1);
	end
	if mog.sub.filters.faction[item] then
		GameTooltip:AddDoubleLine(FACTION..":",(mog.sub.filters.faction[item] == 1 and FACTION_ALLIANCE or FACTION_HORDE),nil,nil,nil,1,1,1);
	end
	if mog.sub.filters.class[item] and mog.sub.filters.class[item] > 0 then
		local str;
		for k,v in pairs(mog.sub.classBits) do
			if bit.band(mog.sub.filters.class[item],v) > 0 then
				if str then
					str = str..", "..string.format("\124cff%.2x%.2x%.2x",RAID_CLASS_COLORS[k].r*255,RAID_CLASS_COLORS[k].g*255,RAID_CLASS_COLORS[k].b*255)..mog.classes[k].."\124r";
				else
					str = string.format("\124cff%.2x%.2x%.2x",RAID_CLASS_COLORS[k].r*255,RAID_CLASS_COLORS[k].g*255,RAID_CLASS_COLORS[k].b*255)..mog.sub.classes[k].."\124r";
				end
			end
		end
		GameTooltip:AddDoubleLine(CLASS..":",str,nil,nil,nil,1,1,1);
	end
	if mog.sub.filters.slot[item] then
		GameTooltip:AddDoubleLine(L["Slot"]..":",mog.sub.slots[mog.sub.filters.slot[item]],nil,nil,nil,1,1,1);
	end
	]=]
	GameTooltip:Show()
end

function wishlist:OnClick(self, button)
	if button == "LeftButton" then
		if IsShiftKeyDown() then
			local _, link = GetItemInfo(self.data.item)
			if link then
				ChatEdit_InsertLink(link)
			end
		elseif IsControlKeyDown() then
			local value = self.data.value
			if type(value) == "table" then
				DressUpModel:Undress()
				for slot, itemID in pairs(value.items) do
					local name, link, _, _, _, _, _, _, _, texture = GetItemInfo(itemID)
					DressUpItemLink(itemID)
				end
			else
				local name, link, _, _, _, _, _, _, _, texture = GetItemInfo(value)
				DressUpItemLink(value)
			end
		else
			if UIDropDownMenu_GetCurrentDropDown() == mog.sub.LeftClick and mog.sub.LeftClick.menuList ~= self and DropDownList1 and DropDownList1:IsShown() then
				HideDropDownMenu(1)
			end
			if type(self.data.items) == "table" then
				ToggleDropDownMenu(nil, nil, mog.sub.LeftClick, "cursor", 0, 0, self)
			end
		end
	elseif button == "RightButton" then
		if IsControlKeyDown() then
			--[[if self.MogItSlot then
				mog.view.delItem(self.slot)
				mog.dressModel(mog.view.model.model)
				if mog.global.gridDress then
					mog.scroll:update()
				end
			else
				mog.view.addItem(self.item)
			end--]]
		elseif IsShiftKeyDown() then
			mog:ShowURL(self.data.item)
		else
			ToggleDropDownMenu(nil, nil, dropdown, "cursor", 0, 0, self.data) -- replaced self with "cursor"
		end
	end
end

--[==[
function mog.sub.OnScroll(module)
	if UIDropDownMenu_GetCurrentDropDown() == mog.sub.LeftClick and DropDownList1 and DropDownList1:IsShown() then
		HideDropDownMenu(1);
	end
end
]==]

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

--[=[function wishlist:Unlist()
	wipe(list);
end--]=]

function wishlist:AddItem(itemID, setName)
	if not setName and self:IsItemInWishlist(itemID) then
		return false
	end
	if setName then
		for i, set in ipairs(self.db.profile.sets) do
			if set.name == setName then
				local slot = invSlots[select(9, GetItemInfo(itemID))]
				set.items[slot] = itemID
				break
			end
		end
	else
		tinsert(self.db.profile.items, itemID)
	end
	self:BuildList()
	return true
end

function wishlist:CreateSet(name)
	if self:IsSetInWishlist(name) then
		return false
	end
	tinsert(self.db.profile.sets, {name = name, items = {}})
	return true
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