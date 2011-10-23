local MogIt,mog = ...;
local L = mog.L;

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
	
	local name,link,_,_,_,_,_,_,_,texture = GetItemInfo(item);
	--GameTooltip:AddLine(self.display,1,1,1);
	--GameTooltip:AddLine(" ");
	GameTooltip:AddDoubleLine((texture and "\124T"..texture..":18\124t " or "")..(link or name or ""),data.items and (#data.items > 1) and L["Item %d/%d"]:format(data.cycle,#data.items),nil,nil,nil,1,0,0);
	if mog.sub.data.source[item] then
		GameTooltip:AddDoubleLine(L["Source"]..":",mog.sub.source[mog.sub.data.source[item]],nil,nil,nil,1,1,1);
		if mog.sub.data.source[item] == 1 then -- Drop
			if mog.GetMob(mog.sub.data.sourceid[item]) then
				GameTooltip:AddDoubleLine(BOSS..":",mog.GetMob(mog.sub.data.sourceid[item]),nil,nil,nil,1,1,1);
			end
		--elseif mog.data.source[self.item] == 3 then -- Quest
		elseif mog.sub.data.source[item] == 5 then -- Crafted
			if mog.sub.data.sourceinfo[item] then
				GameTooltip:AddDoubleLine(L["Profession"]..":",mog.sub.professions[mog.sub.data.sourceinfo[item]],nil,nil,nil,1,1,1);
			end
		elseif mog.sub.data.source[item] == 6 then -- Achievement
			if mog.sub.data.sourceid[item] then
				local _,name,_,complete = GetAchievementInfo(mog.sub.data.sourceid[item]);
				GameTooltip:AddDoubleLine(L["Achievement"]..":",name,nil,nil,nil,1,1,1);
				GameTooltip:AddDoubleLine(STATUS..":",complete and COMPLETE or INCOMPLETE,nil,nil,nil,1,1,1);
			end
		end
	end
	if mog.sub.data.zone[item] then
		local zone = GetMapNameByID(mog.sub.data.zone[item]);
		if zone then
			if mog.sub.data.source[item] == 1 and mog.sub.diffs[mog.sub.data.sourceinfo[item]] then
				zone = zone.." ("..mog.sub.diffs[mog.sub.data.sourceinfo[item]]..")";
			end
			GameTooltip:AddDoubleLine(ZONE..":",zone,nil,nil,nil,1,1,1);
		end
	end
	
	GameTooltip:AddLine(" ");
	if mog.sub.data.lvl[item] then
		GameTooltip:AddDoubleLine(LEVEL..":",mog.sub.data.lvl[item],nil,nil,nil,1,1,1);
	end
	if mog.sub.data.faction[item] then
		GameTooltip:AddDoubleLine(FACTION..":",(mog.sub.data.faction[item] == 1 and FACTION_ALLIANCE or FACTION_HORDE),nil,nil,nil,1,1,1);
	end
	if mog.sub.data.class[item] and mog.sub.data.class[item] > 0 then
		local str;
		for k,v in pairs(mog.sub.classBits) do
			if bit.band(mog.sub.data.class[item],v) > 0 then
				if str then
					str = str..", "..string.format("\124cff%.2x%.2x%.2x",RAID_CLASS_COLORS[k].r*255,RAID_CLASS_COLORS[k].g*255,RAID_CLASS_COLORS[k].b*255)..LOCALIZED_CLASS_NAMES_MALE[k].."\124r";
				else
					str = string.format("\124cff%.2x%.2x%.2x",RAID_CLASS_COLORS[k].r*255,RAID_CLASS_COLORS[k].g*255,RAID_CLASS_COLORS[k].b*255)..LOCALIZED_CLASS_NAMES_MALE[k].."\124r";
				end
			end
		end
		GameTooltip:AddDoubleLine(CLASS..":",str,nil,nil,nil,1,1,1);
	end
	if mog.sub.data.slot[item] then
		GameTooltip:AddDoubleLine(L["Slot"]..":",mog.sub.slots[mog.sub.data.slot[item]],nil,nil,nil,1,1,1);
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
			if UIDropDownMenu_GetCurrentDropDown() == mog.Item_Menu and mog.Item_Menu.menuList ~= self and DropDownList1 and DropDownList1:IsShown() then
				HideDropDownMenu(1);
			end
			ToggleDropDownMenu(nil,nil,mog.Item_Menu,"cursor",0,0,self);
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
	self.model:Undress();
	for k, v in pairs(data.items) do
		self.model:TryOn(v);
	end
end

function mog.Set_OnEnter(self, data)
	if not (self and data and data.items) then return end;
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	
	GameTooltip:AddLine(data.name);
	for k, v in pairs(data.items) do
		local name,link,_,_,_,_,_,_,_,texture = GetItemInfo(v);
		GameTooltip:AddLine((texture and "\124T"..texture..":18\124t " or "")..(link or name or ""));
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
			mog:ShowURL(data.set, "set");
		elseif IsControlKeyDown() then
			mog:AddToPreview(data.items);
		else
			ToggleDropDownMenu(nil, nil, mog.Set_Menu, "cursor", 0, 0, self)
		end
	end
end

mog.Item_Menu = CreateFrame("Frame",nil,mog.frame);
mog.Item_Menu.displayMode = "MENU";

do
	local function onClick(self, arg1, arg2)
		arg1.data.cycle = arg2;
		arg1.data.item = arg1.data.items[arg2];
	end
	
	local function setOnClick(self, set)
		mog:GetModule("Wishlist"):AddItem(self.value, set);
		CloseDropDownMenus();
	end
	
	-- create a new set and add the item to it
	local function newSetOnClick(self)
		StaticPopup_Show("MOGIT_WISHLIST_CREATE_SET", nil, nil, self.value);
		CloseDropDownMenus();
	end
	
	local function menuAddItem(self, itemID, index)
		local name,link,_,_,_,_,_,_,_,texture = GetItemInfo(itemID);
		local info = UIDropDownMenu_CreateInfo();
		info.text = (texture and "\124T"..texture..":18\124t " or "")..(link or name or "");
		info.value = itemID;
		info.func = index and onClick;
		info.checked = not index or self.data.cycle == index;
		info.hasArrow = true;
		info.keepShownOnClick = true;
		info.arg1 = self;
		info.arg2 = index;
		UIDropDownMenu_AddButton(info, tier);
	end
	
	local menu = {
		{
			text = "Add to wishlist",
			func = function(self)
				mog:GetModule("Wishlist"):AddItem(self.value)
				CloseDropDownMenus()
			end,
		},
		{
			text = "Add to set",
			hasArrow = true,
		},
		{
			wishlist = true,
			text = "Delete",
			func = function(self)
				mog:GetModule("Wishlist"):DeleteItem(self.value)
				mog:BuildList("Wishlist")
				CloseDropDownMenus()
			end,
			notCheckable = true,
		},
	}
	
	function mog.Item_Menu:initialize(tier, self)
		if tier == 1 then
			local items = self.data.items;
			if items then
				for i, itemID in ipairs(items) do
					menuAddItem(self, itemID, i);
				end
			else
				menuAddItem(self, self.data.item);
			end
		elseif tier == 2 then
			for i, info in ipairs(menu) do
				info.value = UIDROPDOWNMENU_MENU_VALUE;
				info.notCheckable = true;
				UIDropDownMenu_AddButton(info, tier);
			end
		elseif tier == 3 then
			for i, set in ipairs(mog:GetModule("Wishlist"):GetSets()) do
				local info = UIDropDownMenu_CreateInfo();
				info.text = set.name;
				info.value = UIDROPDOWNMENU_MENU_VALUE;
				info.func = setOnClick;
				info.notCheckable = true;
				info.arg1 = set.name;
				UIDropDownMenu_AddButton(info, tier);
			end
			
			local info = UIDropDownMenu_CreateInfo();
			info.text = "New set";
			info.value = UIDROPDOWNMENU_MENU_VALUE;
			info.func = newSetOnClick;
			info.notCheckable = true;
			UIDropDownMenu_AddButton(info, tier);
		end
	end
end

do
	local types = {
		number = "item",
		table = "set",
	}

	mog.Set_Menu = CreateFrame("Frame",nil,mog.frame);
	mog.Set_Menu.displayMode = "MENU";
	--dropdown.point = "TOPLEFT"
	--dropdown.relativePoint = "TOPRIGHT"
	function mog.Set_Menu:initialize(level, menuList)
		self.menu[types[type(menuList.data)]][level](menuList, level)
	end

	local itemMenu = {
		{
			text = "Add to set",
			hasArrow = true,
			notCheckable = true,
		},
		{
			-- wishlist = false,
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
			text = "Delete from set",
			func = function(self, set)
				mog:GetModule("Wishlist"):DeleteItem(self.value, set)
				mog:BuildList(nil, "Wishlist")
				CloseDropDownMenus()
			end,
			notCheckable = true,
		},
	}

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
				tremove(mog:GetModule("Wishlist"):GetSets(), self.value)
				mog:BuildList()
			end,
			notCheckable = true,
		},
	}

	mog.Set_Menu.menu = {
		-- menu used for single items
		item = {
			-- top level menu
			[1] = function(menuList, level)
				for k, v in pairs(itemMenu) do
					if v.wishlist ~= nil and v.wishlist == (mog:GetActiveModule() == "Wishlist") then
						v.value = menuList.index - #wishlist.db.profile.sets
						v.menuList = menuList
						UIDropDownMenu_AddButton(v, level)
					end
				end
			end,
			-- second level menu
			[2] = function(menuList, level)
				for i, set in ipairs(wishlist.db.profile.sets) do
					local info = UIDropDownMenu_CreateInfo()
					info.text = set.name
					info.func = function(self)
						wishlist:AddItem(menuList.item, self.value)
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
				for i, slot in ipairs(mog.itemSlots) do
					local itemID = menuList.data.items[slot] or menuList.data.items[i]
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
				
				for k, v in pairs(setMenu) do
					if v.wishlist == nil or v.wishlist == (mog:GetActiveModule() == "Wishlist") then
						v.value = menuList.index
						v.arg1 = menuList.data
						-- v.menuList = menuList
						UIDropDownMenu_AddButton(v, level)
					end
				end
			end,
			[2] = function(menuList, level)
				for k, v in pairs(itemMenu) do
					if v.wishlist == nil or v.wishlist == (mog:GetActiveModule() == "Wishlist") then
						v.value = UIDROPDOWNMENU_MENU_VALUE
						v.arg1 = menuList.data
						v.menuList = menuList
						UIDropDownMenu_AddButton(v, level)
					end
				end
			end,
			[3] = function(menuList, level)
				for i, set in ipairs(mog:GetModule("Wishlist"):GetSets()) do
					local info = UIDropDownMenu_CreateInfo()
					info.text = set.name
					info.func = function(self, arg1)
						wishlist:AddItem(arg1, self.value)
						mog:BuildList(nil, "Wishlist")
						CloseDropDownMenus()
					end
					info.notCheckable = true
					info.arg1 = UIDROPDOWNMENU_MENU_VALUE
					UIDropDownMenu_AddButton(info, level)
				end
			end,
		}
	}
end