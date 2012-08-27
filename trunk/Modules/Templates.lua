local MogIt, mog = ...
local L = mog.L

local function itemLabel(itemID, textHeight)
	local name, link = GetItemInfo(itemID) -- need changing to mog:GII
	return format("|T%s:%d|t %s", GetItemIcon(itemID), textHeight or 0, link or name or RED_FONT_COLOR_CODE..RETRIEVING_ITEM_INFO..FONT_COLOR_CODE_CLOSE)
end

-- create a new set and add the item to it
local function newSetOnClick(self)
	StaticPopup_Show("MOGIT_WISHLIST_CREATE_SET", nil, nil, self.value)
	CloseDropDownMenus()
end

local itemOptionsMenu = {
	{
		text = L["Preview"],
		func = function(self)
			mog:AddToPreview(self.value)
			CloseDropDownMenus()
		end,
	},
	{
		set = true,
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
		menuList = function(level)
			mog.wishlist:AddSetMenuItems(level, "addItem", UIDROPDOWNMENU_MENU_VALUE)
			
			local info = UIDropDownMenu_CreateInfo()
			info.text = L["New set"]
			info.value = UIDROPDOWNMENU_MENU_VALUE
			info.func = newSetOnClick
			info.colorCode = GREEN_FONT_COLOR_CODE
			info.notCheckable = true
			UIDropDownMenu_AddButton(info, level)
		end,
	},
	{
		wishlist = true,
		-- text = L["Remove from set"],
		text = L["Delete"],
		func = function(self, set)
			if set.name then
				local slot = mog.wishlist:DeleteItem(self.value, set.name)
				if slot then
					set.frame.model:UndressSlot(GetInventorySlotInfo(slot))
				end
			else
				mog.wishlist:DeleteItem(self.value)
				mog:BuildList(nil, "Wishlist")
			end
			CloseDropDownMenus()
		end,
	},
}

local function createItemMenu(data, func)
	local items = data.items
	if not items then return end
	local isArray = #items > 0
	
	for i, v in ipairs(isArray and items or mog.slots) do
		v = isArray and v or items[v]
		if v then
			local info = UIDropDownMenu_CreateInfo()
			info.text = itemLabel(v, 16)
			info.value = v
			info.func = func
			info.checked = (i == data.cycle)
			info.hasArrow = true
			info.notCheckable = data.isSaved
			info.arg1 = data
			info.arg2 = i
			info.menuList = itemOptionsMenu
			UIDropDownMenu_AddButton(info)
		end
	end
	return true
end

local function createMenu(self, level, menuList)
	local data = self.data
	if type(menuList) == "function" then
		menuList(level)
	else
		for i, info in ipairs(menuList) do
			if (info.wishlist == nil or info.wishlist == data.isSaved) and (not info.set or data.items) then
				info.value = UIDROPDOWNMENU_MENU_VALUE
				info.notCheckable = true
				info.arg1 = data
				UIDropDownMenu_AddButton(info, level)
			end
		end
	end
end

function mog.Item_FrameUpdate(self, data)
	if not (self and data and data.items and data.items and data.cycle) then return end
	mog:DressModel(self);
	self.model:TryOn(data.items[data.cycle])
end

local sourceLabels = {
	[L.source[1]] = BOSS,
}

GameTooltip:RegisterEvent("MODIFIER_STATE_CHANGED")
GameTooltip:HookScript("OnEvent", function(self, event, key, state)
	local owner = self:GetOwner()
	if owner and (owner.type == "preview" or owner.type == "catalogue") then
		mog.ModelOnEnter(owner)
	end
end)

function mog.Item_OnEnter(self, data)
	local item = data.items[data.cycle];
	if not (self and item) then return end
	
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	
	if IsShiftKeyDown() then
		GameTooltip:SetItemByID(item)
		for _, frame in pairs(GameTooltip.shoppingTooltips) do
			frame:Hide()
		end
		return
	end
	
	local itemName, _, _, itemLevel = mog:GetItemInfo(item,"ModelOnEnter")
	--GameTooltip:AddLine(self.display, 1, 1, 1)
	--GameTooltip:AddLine(" ")
	
	if data.items and #data.items > 1 then
		GameTooltip:AddDoubleLine(itemLabel(item), L["Item %d/%d"]:format(data.cycle, #data.items), nil, nil, nil, 1, 0, 0)
	else
		GameTooltip:AddLine(itemLabel(item))
	end
	
	local sourceType, source, zone, info = mog.GetItemSourceInfo(item)
	if sourceType then
		GameTooltip:AddDoubleLine(L["Source"]..":", sourceType, nil, nil, nil, 1, 1, 1)
		if source then
			GameTooltip:AddDoubleLine((sourceLabels[sourceType] or sourceType)..":", source, nil, nil, nil, 1, 1, 1)
		end
		if info then
			GameTooltip:AddDoubleLine(STATUS..":", info and COMPLETE or INCOMPLETE, nil, nil, nil, 1, 1, 1)
		end
	end
	if zone then
		GameTooltip:AddDoubleLine(ZONE..":", zone, nil, nil, nil, 1, 1, 1)
	end
	
	GameTooltip:AddLine(" ")
	if mog:GetData("item", item, "level") then
		GameTooltip:AddDoubleLine(LEVEL..":", mog:GetData("item", item, "level"), nil, nil, nil, 1, 1, 1)
	end
	GameTooltip:AddDoubleLine(STAT_AVERAGE_ITEM_LEVEL..":", itemLevel, nil, nil, nil, 1, 1, 1)
	if mog:GetData("item", item, "faction") then
		GameTooltip:AddDoubleLine(FACTION..":", (mog:GetData("item", item, "faction") == 1 and FACTION_ALLIANCE or FACTION_HORDE), nil, nil, nil, 1, 1, 1)
	end
	if mog:GetData("item", item, "class") and mog:GetData("item", item, "class") > 0 then
		local str
		for k, v in pairs(L.classBits) do
			if bit.band(mog:GetData("item", item, "class"), v) > 0 then
				local color = RAID_CLASS_COLORS[k]
				if str then
					str = str..", "..string.format("\124cff%.2x%.2x%.2x", color.r * 255, color.g * 255, color.b * 255)..LOCALIZED_CLASS_NAMES_MALE[k].."\124r"
				else
					str = string.format("\124cff%.2x%.2x%.2x", color.r * 255, color.g * 255, color.b * 255)..LOCALIZED_CLASS_NAMES_MALE[k].."\124r"
				end
			end
		end
		GameTooltip:AddDoubleLine(CLASS..":", str, nil, nil, nil, 1, 1, 1)
	end
	if mog:GetData("item", item, "slot") then
		GameTooltip:AddDoubleLine(L["Slot"]..":", L.slots[mog:GetData("item", item, "slot")], nil, nil, nil, 1, 1, 1)
	end
	
	GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine(ID..":", item, nil, nil, nil, 1, 1, 1)
	
	-- add wishlist info about this item
	if GetItemCount(item, true) > 0 then
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(L["You have this item."], 1, 1, 1)
		GameTooltip:AddTexture("Interface\\RaidFrame\\ReadyCheck-Ready")
	end
	
	-- add wishlist info about this item
	if mog.wishlist:IsItemInWishlist(item) then
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(L["This item is on your wishlist."], 1, 1, 1)
		GameTooltip:AddTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_1")
	end
	
	GameTooltip:Show()
end

function mog.Item_OnClick(self, btn, data, isSaved)
	local item = data.items[data.cycle];
	if not (self and item) then return end
	
	if btn == "LeftButton" then
		if not HandleModifiedItemClick(select(2, GetItemInfo(item))) and data.items then -- needs changing to mog:GII
			data.cycle = (data.cycle % #data.items) + 1
			data.item = data.items[data.cycle]
			mog.ModelOnEnter(self)
		end
	elseif btn == "RightButton" then
		if IsControlKeyDown() then
			mog:AddToPreview(item)
		elseif IsShiftKeyDown() then
			mog:ShowURL(item)
		else
			if mog.IsDropdownShown(mog.Item_Menu) and mog.Item_Menu.data ~= data then
				HideDropDownMenu(1)
			end
			-- needs to be either true or false
			data.isSaved = isSaved ~= nil
			mog.Item_Menu.data = data
			ToggleDropDownMenu(nil, data.item, mog.Item_Menu, "cursor", 0, 0)
		end
	end
end

do
	local function itemOnClick(self, data, index)
		data.cycle = index
	end
	
	mog.Item_Menu = CreateFrame("Frame")
	mog.Item_Menu.displayMode = "MENU"
	mog.Item_Menu.initialize = function(self, level, menuList)
		local data = self.data
		
		if not menuList then
			if not createItemMenu(data, itemOnClick) then
				-- this is a single item, so skip directly to the item options menu
				-- menuList = itemOptionsMenu
				createMenu(self, level, itemOptionsMenu)
			end
			return
		end
		
		createMenu(self, level, menuList)
	end
end

--[=[
function mog.ItemOnScroll()
	if UIDropDownMenu_GetCurrentDropDown() == mog.sub.ItemMenu and DropDownList1 and DropDownList1:IsShown() then
		HideDropDownMenu(1)
	end
end


function mog.ItemGET_ITEM_INFO_RECEIVED()
	if UIDropDownMenu_GetCurrentDropDown() == mog.sub.ItemMenu and DropDownList1 and DropDownList1:IsShown() then
		HideDropDownMenu(1)
		ToggleDropDownMenu(nil, nil, mog.sub.ItemMenu, "cursor", 0, 0, mog.sub.ItemMenu.menuList)
	end
end

--]=]

function mog.Set_FrameUpdate(self, data)
	if not (self and data and data.items) then return end
	mog:ShowIndicator(self,"label")
	self:SetText(data.name) -- needs fixing
	self.model:Undress()
	for k, v in pairs(data.items) do
		self.model:TryOn(v)
	end
end

function mog.Set_OnEnter(self, data)
	if not (self and data and data.items) then return end
	
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	
	GameTooltip:AddLine(data.name)
	for i, slot in ipairs(mog.slots) do
		local itemID = data.items[slot] or data.items[i]
		if itemID then
			GameTooltip:AddDoubleLine(itemLabel(itemID)..(GetItemCount(itemID, true) > 0 and " |TInterface\\RaidFrame\\ReadyCheck-Ready:0|t" or ""), mog.GetItemSourceShort(itemID))
		end
	end
	
	GameTooltip:Show()
end

function mog.Set_OnClick(self, btn, data, isSaved)
	if not (self and data and data.items) then return end
	
	if btn == "LeftButton" then
		if IsShiftKeyDown() then
			ChatEdit_InsertLink(mog:SetToLink(data.items))
		elseif IsControlKeyDown() then
			for k, v in pairs(data.items) do
				DressUpItemLink(v)
			end
		end
	elseif btn == "RightButton" then
		if IsShiftKeyDown() then
			if data.set then
				mog:ShowURL(data.set, "set")
			else
				mog:ShowURL(data.items, "compare")
			end
		elseif IsControlKeyDown() then
			mog:AddToPreview(data.items)
		else
			if mog.IsDropdownShown(mog.Set_Menu) and mog.Set_Menu.data ~= data then
				HideDropDownMenu(1)
			end
			mog.Set_Menu.data = data
			data.isSaved = isSaved ~= nil
			ToggleDropDownMenu(nil, nil, mog.Set_Menu, "cursor", 0, 0)
		end
	end
end

do
	local setMenu = {
		{
			wishlist = false,
			text = L["Add set to wishlist"],
			func = function(self, items)
				local create = mog.wishlist:CreateSet(self.value)
				if create then
					for i, itemID in pairs(items) do
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

	mog.Set_Menu = CreateFrame("Frame")
	mog.Set_Menu.displayMode = "MENU"
	mog.Set_Menu.initialize = function(self, level, menuList)
		local data = self.data
		
		if not menuList then
			createItemMenu(data)
			
			for i, info in ipairs(setMenu) do
				if info.wishlist == nil or info.wishlist == data.isSaved then
					info.value = data.name
					info.notCheckable = true
					info.arg1 = data.items
					UIDropDownMenu_AddButton(info, level)
				end
			end
			return
		end
		
		createMenu(self, level, menuList)
	end
end