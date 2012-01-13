local MogIt, mog = ...;
local L = mog.L;

local function itemLabel(itemID, textHeight)
	local name, link = GetItemInfo(itemID);
	return format("|T%s:%d|t %s", GetItemIcon(itemID), textHeight or 0, link or name or "");
end

function mog.Item_FrameUpdate(self, data)
	if not (self and data and data.item) then return end;
	if mog.db.profile.gridDress == "equipped" then
		self.model:Dress();
	else
		self.model:Undress();
	end
	mog:DressModel(self.model);
	self.model:TryOn(data.item);
end

local sourceLabels = {
	[mog.sub.source[1]] = BOSS,
}

function mog.Item_OnEnter(self, data)
	local item = data.item;
	if not (self and item) then return end;
		
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	
	local itemName, _, _, itemLevel = GetItemInfo(item);
	--GameTooltip:AddLine(self.display, 1, 1, 1);
	--GameTooltip:AddLine(" ");
	
	if data.items and #data.items > 1 then
		GameTooltip:AddDoubleLine(itemLabel(item), L["Item %d/%d"]:format(data.cycle, #data.items), nil, nil, nil, 1, 0, 0);
	else
		GameTooltip:AddLine(itemLabel(item));
	end
	
	local sourceType, source, zone, info = mog.GetItemSourceInfo(item);
	if sourceType then
		GameTooltip:AddDoubleLine(L["Source"]..":", sourceType, nil, nil, nil, 1, 1, 1);
		if source then
			GameTooltip:AddDoubleLine((sourceLabels[sourceType] or sourceType)..":", source, nil, nil, nil, 1, 1, 1);
		end
		if info then
			GameTooltip:AddDoubleLine(STATUS..":", info and COMPLETE or INCOMPLETE, nil, nil, nil, 1, 1, 1);
		end
	end
	if zone then
		GameTooltip:AddDoubleLine(ZONE..":", zone, nil, nil, nil, 1, 1, 1);
	end
	
	GameTooltip:AddLine(" ");
	if mog.items.level[item] then
		GameTooltip:AddDoubleLine(LEVEL..":", mog.items.level[item], nil, nil, nil, 1, 1, 1);
	end
	GameTooltip:AddDoubleLine(STAT_AVERAGE_ITEM_LEVEL..":", itemLevel, nil, nil, nil, 1, 1, 1);
	if mog.items.faction[item] then
		GameTooltip:AddDoubleLine(FACTION..":", (mog.items.faction[item] == 1 and FACTION_ALLIANCE or FACTION_HORDE), nil, nil, nil, 1, 1, 1);
	end
	if mog.items.class[item] and mog.items.class[item] > 0 then
		local str;
		for k, v in pairs(mog.sub.classBits) do
			if bit.band(mog.items.class[item], v) > 0 then
				if str then
					str = str..", "..string.format("\124cff%.2x%.2x%.2x", RAID_CLASS_COLORS[k].r*255, RAID_CLASS_COLORS[k].g*255, RAID_CLASS_COLORS[k].b*255)..LOCALIZED_CLASS_NAMES_MALE[k].."\124r";
				else
					str = string.format("\124cff%.2x%.2x%.2x", RAID_CLASS_COLORS[k].r*255, RAID_CLASS_COLORS[k].g*255, RAID_CLASS_COLORS[k].b*255)..LOCALIZED_CLASS_NAMES_MALE[k].."\124r";
				end
			end
		end
		GameTooltip:AddDoubleLine(CLASS..":", str, nil, nil, nil, 1, 1, 1);
	end
	if mog.items.slot[item] then
		GameTooltip:AddDoubleLine(L["Slot"]..":", mog.sub.slots[mog.items.slot[item]], nil, nil, nil, 1, 1, 1);
	end
	
	GameTooltip:AddLine(" ");
	GameTooltip:AddDoubleLine(ID..":", item, nil, nil, nil, 1, 1, 1);
	
	if itemName then
		-- need to hack a random suffix into the link, or those items will be thought not moggable because they have no stats
		local canBeChanged, noChangeReason, canBeSource, noSourceReason = GetItemTransmogrifyInfo(format("item:%d:0:0:0:0:0:5", item));
		if not canBeSource then
			GameTooltip:AddLine(" ");
			GameTooltip:AddLine(ERR_TRANSMOGRIFY_INVALID_SOURCE, 1, 0, 0);
		end
	end
	
	GameTooltip:Show();
end

function mog.Item_OnClick(self, btn, data, isSaved)
	local item = data.item;
	if not (self and item) then return end;
	
	if btn == "LeftButton" then
		if IsShiftKeyDown() then
			local _, link = GetItemInfo(item);
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
			data.isSaved = isSaved ~= nil
			ToggleDropDownMenu(nil, nil, mog.Item_Menu, "cursor", 0, 0, data);
		end
	end
end

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
		local name, link = GetItemInfo(itemID);
		local info = UIDropDownMenu_CreateInfo();
		info.text = itemLabel(itemID, 16);
		info.value = itemID;
		info.func = index and onClick;
		info.checked = not index or data.cycle == index;
		info.hasArrow = true;
		info.arg1 = data;
		info.arg2 = index;
		info.menuList = data;
		UIDropDownMenu_AddButton(info);
	end
	
	local menu = {
		{
			text = L["Preview"],
			func = function(self)
				mog:AddToPreview(self.value)
				CloseDropDownMenus()
			end,
			notCheckable = true,
		},
		{
			wishlist = false,
			text = L["Add to wishlist"],
			func = function(self)
				mog.wishlist:AddItem(self.value)
				mog:BuildList(nil, "Wishlist")
				CloseDropDownMenus()
			end,
		},
		{
			text = L["Add to set"],
			hasArrow = true,
		},
		{
			wishlist = true,
			text = "Delete",
			func = function(self)
				mog.wishlist:DeleteItem(self.value)
				mog:BuildList(nil, "Wishlist")
				CloseDropDownMenus()
			end,
		},
	}
	
	mog.Item_Menu = CreateFrame("Frame");
	mog.Item_Menu.displayMode = "MENU";
	mog.Item_Menu.initialize = function(self, level, data)
		if level == 1 then
			local items = data.items;
			if items then
				for i, itemID in ipairs(items) do
					menuAddItem(data, itemID, i);
				end
			else
				menuAddItem(data, data.item);
			end
		elseif level == 2 then
			for i, info in ipairs(menu) do
				if info.wishlist == nil or info.wishlist == data.isSaved then
					info.value = UIDROPDOWNMENU_MENU_VALUE;
					info.notCheckable = true;
					UIDropDownMenu_AddButton(info, level);
				end
			end
		elseif level == 3 then
			mog.wishlist:AddSetMenuItems(level, "addItem", UIDROPDOWNMENU_MENU_VALUE);
			
			local info = UIDropDownMenu_CreateInfo();
			info.text = L["New set"];
			info.value = UIDROPDOWNMENU_MENU_VALUE;
			info.func = newSetOnClick;
			info.colorCode = GREEN_FONT_COLOR_CODE;
			info.notCheckable = true;
			UIDropDownMenu_AddButton(info, level);
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
		ToggleDropDownMenu(nil, nil, mog.sub.ItemMenu, "cursor", 0, 0, mog.sub.ItemMenu.menuList);
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
			local name, link = GetItemInfo(itemID);
			GameTooltip:AddDoubleLine(itemLabel(itemID), mog.GetItemSourceShort(itemID));
		end
	end
	
	GameTooltip:Show();
end

function mog.Set_OnClick(self, btn, data, isSaved)
	if not (self and data and data.items) then return end;
	
	if btn == "LeftButton" then
		if IsShiftKeyDown() then
			ChatEdit_InsertLink(mog:SetToLink(data.items));
		elseif IsControlKeyDown() then
			for k, v in pairs(data.items) do
				DressUpItemLink(v);
			end
		end
	elseif btn == "RightButton" then
		if IsShiftKeyDown() then
			if data.set then
				mog:ShowURL(data.set, "set");
			else
				mog:ShowURL(data.items, "compare");
			end
		elseif IsControlKeyDown() then
			mog:AddToPreview(data.items);
		else
			if UIDropDownMenu_GetCurrentDropDown() == mog.Set_Menu and mog.Set_Menu.menuList ~= self.data and DropDownList1 and DropDownList1:IsShown() then
				HideDropDownMenu(1);
			end
			data.isSaved = isSaved ~= nil
			ToggleDropDownMenu(nil, nil, mog.Set_Menu, "cursor", 0, 0, data);
		end
	end
end

do
	local setMenu = {
		{
			wishlist = false,
			text = L["Add set to wishlist"],
			func = function(self)
				local create = mog.wishlist:CreateSet(self.value)
				if create then
					for i, itemID in pairs(mog.wishlist:GetSetItems(self.value)) do
						mog.wishlist:AddItem(itemID, self.value)
					end
				end
			end,
		},
		{
			wishlist = true,
			text = L["Rename set"],
			func = function(self)
				mog.wishlist:RenameSet(self.value)
			end,
		},
		{
			wishlist = true,
			text = L["Delete set"],
			func = function(self)
				mog.wishlist:DeleteSet(self.value)
			end,
		},
	}

	local itemMenu = {
		{
			text = L["Preview"],
			func = function(self)
				mog:AddToPreview(self.value)
				CloseDropDownMenus()
			end,
		},
		{
			text = L["Add to wishlist"],
			func = function(self)
				mog.wishlist:AddItem(self.value)
				mog:BuildList(nil, "Wishlist")
				CloseDropDownMenus()
			end,
		},
		{
			text = L["Add to set"],
			hasArrow = true,
		},
		{
			wishlist = true,
			text = L["Remove from set"],
			func = function(self, set)
				mog.wishlist:DeleteItem(self.value, set.name)
				mog:BuildList(nil, "Wishlist")
				CloseDropDownMenus()
			end,
		},
	}
	
	mog.Set_Menu = CreateFrame("Frame");
	mog.Set_Menu.displayMode = "MENU";
	mog.Set_Menu.initialize = function(self, level, data)
		if level == 1 then
			for i, slot in ipairs(mog.itemSlots) do
				local itemID = data.items[slot] or data.items[i]
				if itemID then
					local itemName, itemLink = GetItemInfo(itemID);
					local info = UIDropDownMenu_CreateInfo()
					info.text = itemLabel(itemID, 16)
					info.value = itemID
					info.hasArrow = true
					info.notCheckable = true
					info.menuList = data
					UIDropDownMenu_AddButton(info, level)
				end
			end
			
			for i, v in ipairs(setMenu) do
				if v.wishlist == nil or v.wishlist == data.isSaved then
					v.value = data.name
					v.notCheckable = true
					UIDropDownMenu_AddButton(v, level)
				end
			end
		elseif level == 2 then
			for i, v in ipairs(itemMenu) do
				if v.wishlist == nil or v.wishlist == data.isSaved then
					v.value = UIDROPDOWNMENU_MENU_VALUE
					v.notCheckable = true
					v.arg1 = data
					v.menuList = data
					UIDropDownMenu_AddButton(v, level)
				end
			end
		elseif level == 3 then
			mog.wishlist:AddSetMenuItems(level, "addItem", UIDROPDOWNMENU_MENU_VALUE)
		end
	end
end