local MogIt,mog = ...;
local L = mog.L;

local function itemIcon(itemID, textHeight)
	return format("|T%s:%d|t ", GetItemIcon(itemID), textHeight or 0)
end

local data = mog.items

local function getSourceInfo(itemID)
	local data = data or mog.items
	local source = data.source[itemID]
	local sourceID = data.sourceid[itemID]
	local sourceInfo = data.sourceinfo[itemID]
	local info = mog.sub.source[source]
	local extraInfo
	if source == 1 and sourceID then -- Drop
		extraInfo = mog.GetMob(sourceID)
	-- elseif source == 3 then -- Quest
	elseif source == 5 and sourceInfo then -- Crafted
		extraInfo = mog.sub.professions[sourceInfo]
	elseif source == 6 and sourceID then -- Achievement
		local _, name, _, complete = GetAchievementInfo(sourceID)
		extraInfo = name
	end
	local zone = data.zone[itemID]
	if zone then
		zone = GetMapNameByID(zone)
		if zone then
			if source == 1 and extraInfo then
				local diff = mog.sub.diffs[sourceInfo]
				if diff then
					zone = format("%s (%s)", zone, diff)
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

function mog.Item_FrameUpdate(self, data)
	if not (self and data and data.item) then return end;
	self.model:Undress();
	mog:DressModel(self.model);
	self.model:TryOn(data.item);
end

function mog.Item_OnEnter(self,data)
	local item = data.item;
	if not (self and item) then return end;
		
	GameTooltip:SetOwner(self,"ANCHOR_RIGHT");
	
	local name,link = GetItemInfo(item);
	--GameTooltip:AddLine(self.display,1,1,1);
	--GameTooltip:AddLine(" ");
	GameTooltip:AddDoubleLine(itemIcon(item)..(link or name or ""),data.items and (#data.items > 1) and L["Item %d/%d"]:format(data.cycle,#data.items),nil,nil,nil,1,0,0);
	if mog.items.source[item] then
		GameTooltip:AddDoubleLine(L["Source"]..":",mog.sub.source[mog.items.source[item]],nil,nil,nil,1,1,1);
		if mog.items.source[item] == 1 then -- Drop
			if mog.GetMob(mog.items.sourceid[item]) then
				GameTooltip:AddDoubleLine(BOSS..":",mog.GetMob(mog.items.sourceid[item]),nil,nil,nil,1,1,1);
			end
		--elseif mog.items.source[self.item] == 3 then -- Quest
		elseif mog.items.source[item] == 5 then -- Crafted
			if mog.items.sourceinfo[item] then
				GameTooltip:AddDoubleLine(L["Profession"]..":",mog.sub.professions[mog.items.sourceinfo[item]],nil,nil,nil,1,1,1);
			end
		elseif mog.items.source[item] == 6 then -- Achievement
			if mog.items.sourceid[item] then
				local _,name,_,complete = GetAchievementInfo(mog.items.sourceid[item]);
				GameTooltip:AddDoubleLine(L["Achievement"]..":",name,nil,nil,nil,1,1,1);
				GameTooltip:AddDoubleLine(STATUS..":",complete and COMPLETE or INCOMPLETE,nil,nil,nil,1,1,1);
			end
		end
	end
	if mog.items.zone[item] then
		local zone = GetMapNameByID(mog.items.zone[item]);
		if zone then
			if mog.items.source[item] == 1 and mog.sub.diffs[mog.items.sourceinfo[item]] then
				zone = zone.." ("..mog.sub.diffs[mog.items.sourceinfo[item]]..")";
			end
			GameTooltip:AddDoubleLine(ZONE..":",zone,nil,nil,nil,1,1,1);
		end
	end
	
	GameTooltip:AddLine(" ");
	if mog.items.level[item] then
		GameTooltip:AddDoubleLine(LEVEL..":",mog.items.level[item],nil,nil,nil,1,1,1);
	end
	if mog.items.faction[item] then
		GameTooltip:AddDoubleLine(FACTION..":",(mog.items.faction[item] == 1 and FACTION_ALLIANCE or FACTION_HORDE),nil,nil,nil,1,1,1);
	end
	if mog.items.class[item] and mog.items.class[item] > 0 then
		local str;
		for k,v in pairs(mog.sub.classBits) do
			if bit.band(mog.items.class[item],v) > 0 then
				if str then
					str = str..", "..string.format("\124cff%.2x%.2x%.2x",RAID_CLASS_COLORS[k].r*255,RAID_CLASS_COLORS[k].g*255,RAID_CLASS_COLORS[k].b*255)..LOCALIZED_CLASS_NAMES_MALE[k].."\124r";
				else
					str = string.format("\124cff%.2x%.2x%.2x",RAID_CLASS_COLORS[k].r*255,RAID_CLASS_COLORS[k].g*255,RAID_CLASS_COLORS[k].b*255)..LOCALIZED_CLASS_NAMES_MALE[k].."\124r";
				end
			end
		end
		GameTooltip:AddDoubleLine(CLASS..":",str,nil,nil,nil,1,1,1);
	end
	if mog.items.slot[item] then
		GameTooltip:AddDoubleLine(L["Slot"]..":",mog.sub.slots[mog.items.slot[item]],nil,nil,nil,1,1,1);
	end
	
	GameTooltip:AddLine(" ");
	GameTooltip:AddDoubleLine(ID..":",item,nil,nil,nil,1,1,1);
	
	GameTooltip:Show();
end

function mog.Item_OnClick(self,btn,data)
	local item = data.item;
	if not (self and item) then return end;
	
	if btn == "LeftButton" then
		if IsShiftKeyDown() then
			local _,link = GetItemInfo(item);
			if link then
				ChatEdit_InsertLink(link);
			end
		elseif IsControlKeyDown() then
			DressUpItemLink(item);
		else
			if data.items then
				data.cycle = (data.cycle < #data.items and (data.cycle + 1)) or 1;
				data.item = data.items[data.cycle];
				mog.OnEnter(self);
			end
		end
	elseif btn == "RightButton" then
		if IsControlKeyDown() then
			mog:AddToPreview(item);
		elseif IsShiftKeyDown() then
			mog:ShowURL(item);
		else
			if UIDropDownMenu_GetCurrentDropDown() == mog.Item_Menu and mog.Item_Menu.menuList ~= self.data and DropDownList1 and DropDownList1:IsShown() then
				HideDropDownMenu(1);
			end
			ToggleDropDownMenu(nil,nil,mog.Item_Menu,"cursor",0,0,data);
		end
	end
end

--[=[
function mog.ItemOnScroll()
	if UIDropDownMenu_GetCurrentDropDown() == mog.sub.ItemMenu and DropDownList1 and DropDownList1:IsShown() then
		HideDropDownMenu(1);
	end
end


function mog.ItemGET_ITEM_INFO_RECEIVED()
	if UIDropDownMenu_GetCurrentDropDown() == mog.sub.ItemMenu and DropDownList1 and DropDownList1:IsShown() then
		HideDropDownMenu(1);
		ToggleDropDownMenu(nil,nil,mog.sub.ItemMenu,"cursor",0,0,mog.sub.ItemMenu.menuList);
	end
end

--]=]

function mog.Set_FrameUpdate(self, data)
	if not (self and data and data.items) then return end
	self.label:SetText(data.name);
	self.label:Show();
	self.model:Undress();
	for k, v in pairs(data.items) do
		self.model:TryOn(v);
	end
end

function mog.Set_OnEnter(self, data)
	if not (self and data and data.items) then return end;
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	
	GameTooltip:AddLine(data.name);
	for i, slot in ipairs(mog.itemSlots) do
		local itemID = data.items[slot] or data.items[i]
		if itemID then
			local name,link = GetItemInfo(itemID);
			GameTooltip:AddDoubleLine(itemIcon(itemID)..(link or name or ""), getSourceInfo(itemID));
		end
	end
	
	GameTooltip:Show();
end

function mog.Set_OnClick(self, btn, data)
	if not (self and data and data.items) then return end;
	if btn == "LeftButton" then
		if IsShiftKeyDown() then
			ChatEdit_InsertLink(mog:SetToLink(data.items));
		elseif IsControlKeyDown() then
			for k,v in pairs(data.items) do
				DressUpItemLink(v);
			end
		end
	elseif btn == "RightButton" then
		if IsShiftKeyDown() then
			mog:ShowURL(data.set or data.items, data.set and "set" or "compare");
		elseif IsControlKeyDown() then
			mog:AddToPreview(data.items);
		else
			if UIDropDownMenu_GetCurrentDropDown() == mog.Set_Menu and mog.Set_Menu.menuList ~= self.data and DropDownList1 and DropDownList1:IsShown() then
				HideDropDownMenu(1);
			end
			ToggleDropDownMenu(nil,nil,mog.Set_Menu,"cursor",0,0,data);
		end
	end
end

mog.Item_Menu = CreateFrame("Frame",nil,mog.frame);
mog.Item_Menu.displayMode = "MENU";
do
	local function onClick(self, arg1, arg2)
		arg1.cycle = arg2;
		arg1.item = arg1.items[arg2];
	end
	
	-- create a new set and add the item to it
	local function newSetOnClick(self)
		StaticPopup_Show("MOGIT_WISHLIST_CREATE_SET", nil, nil, self.value);
		CloseDropDownMenus();
	end
	
	local function menuAddItem(data, itemID, index)
		local name,link = GetItemInfo(itemID);
		local info = UIDropDownMenu_CreateInfo();
		info.text = itemIcon(itemID, 16)..(link or name or "");
		info.value = itemID;
		info.func = index and onClick;
		info.checked = not index or data.cycle == index;
		info.hasArrow = true;
		info.arg1 = data;
		info.arg2 = index;
		UIDropDownMenu_AddButton(info, tier);
	end
	
	local menu = {
		{
			text = "Add to set",
			hasArrow = true,
		},
		{
			text = "Add to wishlist",
			func = function(self)
				mog:GetModule("Wishlist"):AddItem(self.value)
				mog:BuildList(nil, "Wishlist")
				CloseDropDownMenus()
			end,
		},
		{
			wishlist = true,
			text = "Delete",
			func = function(self)
				mog:GetModule("Wishlist"):DeleteItem(self.value)
				mog:BuildList(nil, "Wishlist")
				CloseDropDownMenus()
			end,
		},
	}
	
	function mog.Item_Menu:initialize(tier, data)
		if tier == 1 then
			local items = data.items;
			if items then
				for i, itemID in ipairs(items) do
					menuAddItem(data, itemID, i);
				end
			else
				menuAddItem(data, data.item);
			end
		elseif tier == 2 then
			for i, info in ipairs(menu) do
				info.value = UIDROPDOWNMENU_MENU_VALUE;
				info.notCheckable = true;
				UIDropDownMenu_AddButton(info, tier);
			end
		elseif tier == 3 then
			mog:GetModule("Wishlist"):AddSetMenuItems(tier, "addItem", UIDROPDOWNMENU_MENU_VALUE);
			
			local info = UIDropDownMenu_CreateInfo();
			info.text = "New set";
			info.value = UIDROPDOWNMENU_MENU_VALUE;
			info.func = newSetOnClick;
			info.colorCode = GREEN_FONT_COLOR_CODE;
			info.notCheckable = true;
			UIDropDownMenu_AddButton(info, tier);
		end
	end
end

mog.Set_Menu = CreateFrame("Frame",nil,mog.frame);
mog.Set_Menu.displayMode = "MENU";
do
	function mog.Set_Menu:initialize(level, menuList)
		self.menu[level](menuList, level)
	end

	local setMenu = {
		{
			wishlist = false,
			text = "Add set to wishlist",
			func = function(self, set)
				local wishlist = mog:GetModule("Wishlist")
				local create = wishlist:CreateSet(set.name)
				if create then
					for i, itemID in pairs(set.items) do
						wishlist:AddItem(itemID, set.name)
					end
				end
			end,
			notCheckable = true,
		},
		{
			wishlist = true,
			text = "Rename set",
			func = function(self, set)
				mog:GetModule("Wishlist"):RenameSet(set.name)
			end,
			notCheckable = true,
		},
		{
			wishlist = true,
			text = "Delete set",
			func = function(self)
				mog:GetModule("Wishlist"):DeleteSet(self.value)
			end,
			notCheckable = true,
		},
	}

	local itemMenu = {
		{
			text = "Add to set",
			hasArrow = true,
			notCheckable = true,
		},
		{
			text = "Add to wishlist",
			func = function(self)
				mog:GetModule("Wishlist"):AddItem(self.value)
				mog:BuildList(nil, "Wishlist")
				CloseDropDownMenus()
			end,
			notCheckable = true,
		},
		{
			wishlist = true,
			text = "Remove from set",
			func = function(self, set)
				mog:GetModule("Wishlist"):DeleteItem(self.value, set.name)
				mog:BuildList(nil, "Wishlist")
				CloseDropDownMenus()
			end,
			notCheckable = true,
		},
	}
	
	mog.Set_Menu.menu = {
		-- menu used for sets
		[1] = function(menuList, level)
			for i, slot in ipairs(mog.itemSlots) do
				local itemID = menuList.items[slot] or menuList.items[i]
				if itemID then
					local itemName,itemLink = GetItemInfo(itemID);
					local info = UIDropDownMenu_CreateInfo()
					info.text = itemIcon(itemID, 16)..(itemLink or itemName or "")
					info.value = itemID
					-- info.icon = GetItemIcon(itemID)
					info.hasArrow = true
					--info.colorCode = "|c"..select(4, GetItemQualityColor(itemQuality))
					info.notCheckable = true
					info.menuList = menuList
					UIDropDownMenu_AddButton(info, level)
				end
			end
			
			for k, v in pairs(setMenu) do
				if v.wishlist == nil or v.wishlist == (mog:GetActiveModule() == "Wishlist") then
					v.value = menuList.index
					v.arg1 = menuList
					-- v.menuList = menuList
					UIDropDownMenu_AddButton(v, level)
				end
			end
		end,
		[2] = function(menuList, level)
			for k, v in pairs(itemMenu) do
				if v.wishlist == nil or v.wishlist == (mog:GetActiveModule() == "Wishlist") then
					v.value = UIDROPDOWNMENU_MENU_VALUE
					v.arg1 = menuList
					v.menuList = menuList
					UIDropDownMenu_AddButton(v, level)
				end
			end
		end,
		[3] = function(menuList, level)
			mog:GetModule("Wishlist"):AddSetMenuItems(level, "addItem", UIDROPDOWNMENU_MENU_VALUE)
		end,
	}
end