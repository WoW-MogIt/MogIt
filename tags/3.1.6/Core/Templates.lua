local MogIt, mog = ...
local L = mog.L

local TEXTURE = [[Interface\RaidFrame\ReadyCheck-Ready]]

local function getTexture(hasItem, embedded)
	local texture = hasItem and TEXTURE or ""
	return embedded and format("|T%s:0|t ", texture) or texture
end

local function itemLabel(itemID, callback)
	local name, _, quality = mog:GetItemInfo(itemID, callback)
	if name then
		return format("|c%s%s|r", select(4, GetItemQualityColor(quality)), name)
	else
		return RED_FONT_COLOR_CODE..RETRIEVING_ITEM_INFO..FONT_COLOR_CODE_CLOSE
	end
end

local function addTooltipDoubleLine(textLeft, textRight)
	GameTooltip:AddDoubleLine(textLeft, textRight, nil, nil, nil, 1, 1, 1)
end

local function addItemTooltipLine(itemID)
	addTooltipDoubleLine(getTexture(mog:HasItem(itemID), true)..itemLabel(itemID, "ModelOnEnter"), mog.GetItemSourceShort(itemID))
end

function mog.GetItemSourceInfo(itemID)
	local source, info;
	local sourceType = mog:GetData("item", itemID, "source");
	local sourceID = mog:GetData("item", itemID, "sourceid");
	local sourceInfo = mog:GetData("item", itemID, "sourceinfo");
	
	if sourceType == 1 and sourceID then -- Drop
		source = mog:GetData("npc", sourceID, "name");
	elseif sourceType == 3 and sourceID then -- Quest
		info = IsQuestFlaggedCompleted(sourceID) or false;
	elseif sourceType == 5 and sourceInfo then -- Crafted
		source = L.professions[sourceInfo];
	elseif sourceType == 6 and sourceID then -- Achievement
		local _, name, _, complete = GetAchievementInfo(sourceID);
		source = name;
		info = complete;
	end
	
	local zone = mog:GetData("item", itemID, "zone");
	if zone then
		zone = GetMapNameByID(zone);
		if zone then
			local diff = L.diffs[sourceInfo];
			if sourceType == 1 and diff then
				zone = format("%s (%s)", zone, diff);
			end
		end
	end
	
	return L.source[sourceType], source, zone, info;
end

function mog.GetItemSourceShort(itemID)
	local sourceType, source, zone, info = mog.GetItemSourceInfo(itemID);
	if zone then
		if source then
			sourceType = source;
		end
		source = zone;
		if sourceType == L.source[3] then
			source = format("%s (%s)", source, sourceType)
		end
	end
	return source or sourceType
end

-- create a new set and add the item to it
local function previewOnClick(self, previewFrame)
	mog:AddToPreview(self.value, mog:GetPreview(previewFrame))
	CloseDropDownMenus()
end

-- create a new set and add the item to it
local function newSetOnClick(self)
	StaticPopup_Show("MOGIT_WISHLIST_CREATE_SET", nil, nil, self.value)
	CloseDropDownMenus()
end

local itemOptionsMenu = {
	{
		text = L["Preview"],
		hasArrow = true,
		menuList = function(level)
			local info = UIDropDownMenu_CreateInfo()
			info.text = L["Active preview"]
			info.value = UIDROPDOWNMENU_MENU_VALUE
			info.func = previewOnClick
			info.disabled = not mog.activePreview
			info.notCheckable = true
			info.arg1 = mog.activePreview
			UIDropDownMenu_AddButton(info, level)
			
			for i, preview in ipairs(mog.previews) do
				local info = UIDropDownMenu_CreateInfo()
				info.text = format("%s %d", L["Preview"], preview.id)
				info.value = UIDROPDOWNMENU_MENU_VALUE
				info.func = previewOnClick
				info.notCheckable = true
				info.arg1 = preview
				UIDropDownMenu_AddButton(info, level)
			end
			
			local info = UIDropDownMenu_CreateInfo()
			info.text = L["New preview"]
			info.value = UIDROPDOWNMENU_MENU_VALUE
			info.func = previewOnClick
			info.notCheckable = true
			UIDropDownMenu_AddButton(info, level)
		end,
	},
	{
		set = true,
		text = L["Add to wishlist"],
		func = function(self)
			mog.wishlist:AddItem(self.value)
			mog:BuildList()
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

function mog:AddItemOption(info)
	tinsert(itemOptionsMenu, info)
end

local function createItemMenu(data, func)
	local items = data.items
	-- not listing the items if it's only 1 and it's not a set
	if not items or (data.item and #items == 1) then
		return
	end
	local isArray = #items > 0
	
	for i, v in ipairs(isArray and items or mog.slots) do
		v = isArray and v or items[v]
		if v then
			local info = UIDropDownMenu_CreateInfo()
			info.text = itemLabel(v, func and "ItemMenu" or "SetMenu")
			info.value = v
			info.func = func
			info.checked = (i == data.cycle)
			info.hasArrow = true
			info.notCheckable = data.isSaved or data.name
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

local slots = {
	[1] = "MainHandSlot",
	-- [2] = "mainhand",
	-- [3] = "offhand",
}

function mog.Item_FrameUpdate(self, data)
	self:ApplyDress()
	self:TryOn(data.item, slots[mog:GetData("item", data.item, "slot")])
end

local sourceLabels = {
	[L.source[1]] = BOSS,
}

GameTooltip:RegisterEvent("MODIFIER_STATE_CHANGED")
GameTooltip:HookScript("OnEvent", function(self, event, key, state)
	local owner = self:GetOwner()
	if owner and self[mog] then
		owner:OnEnter()
	end
end)
GameTooltip:HookScript("OnTooltipCleared", function(self)
	self[mog] = nil
end)

function mog.ShowItemTooltip(self, item, items, cycle)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip[mog] = true
	
	if IsShiftKeyDown() then
		GameTooltip:SetItemByID(item)
		for _, frame in pairs(GameTooltip.shoppingTooltips) do
			frame:Hide()
		end
		return
	end
	
	local itemName, _, _, itemLevel = mog:GetItemInfo(item, "ModelOnEnter")
	local itemLabel = itemLabel(item, "ModelOnEnter")
	if cycle and #items > 1 then
		GameTooltip:AddDoubleLine(itemLabel, L["Item %d/%d"]:format(cycle, #items), nil, nil, nil, 1, 0, 0)
	else
		GameTooltip:AddLine(itemLabel)
	end
	
	local sourceType, source, zone, info = mog.GetItemSourceInfo(item)
	if sourceType then
		addTooltipDoubleLine(L["Source"]..":", sourceType)
		if source then
			addTooltipDoubleLine((sourceLabels[sourceType] or sourceType)..":", source)
		end
		if info ~= nil then
			addTooltipDoubleLine(STATUS..":", info and COMPLETE or INCOMPLETE)
		end
	end
	if zone then
		addTooltipDoubleLine(ZONE..":", zone)
	end
	
	GameTooltip:AddLine(" ")
	local requiredLevel = mog:GetData("item", item, "level")
	if requiredLevel then
		addTooltipDoubleLine(LEVEL..":", requiredLevel)
	end
	addTooltipDoubleLine(STAT_AVERAGE_ITEM_LEVEL..":", itemLevel)
	local faction = mog:GetData("item", item, "faction")
	if faction then
		addTooltipDoubleLine(FACTION..":", (faction == 1 and FACTION_ALLIANCE or FACTION_HORDE))
	end
	local class = mog:GetData("item", item, "class")
	if class and class > 0 then
		local str
		for k, v in pairs(L.classBits) do
			if bit.band(class, v) > 0 then
				local color = RAID_CLASS_COLORS[k].colorStr
				if str then
					str = format("%s, |c%s%s|r", str, color, LOCALIZED_CLASS_NAMES_MALE[k])
				else
					str = format("|c%s%s|r", color, LOCALIZED_CLASS_NAMES_MALE[k])
				end
			end
		end
		addTooltipDoubleLine(CLASS..":", str)
	end
	local slot = mog:GetData("item", item, "slot")
	if slot then
		addTooltipDoubleLine(L["Slot"]..":", L.slots[slot])
	end
	
	GameTooltip:AddLine(" ")
	addTooltipDoubleLine(ID..":", item)
	
	if mog:HasItem(item) then
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(L["You have this item."], 1, 1, 1)
		GameTooltip:AddTexture(TEXTURE)
	end
	
	if (not mog.active or mog.active.name ~= "Wishlist") and mog.wishlist:IsItemInWishlist(item) then
		if not mog:HasItem(item) then
			GameTooltip:AddLine(" ")
		end
		GameTooltip:AddLine(L["This item is on your wishlist."], 1, 1, 1)
		GameTooltip:AddTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_1")
	end
	
	if not items then
		--GameTooltip:AddLine(" ")
		--GameTooltip:AddLine(L["Load module to see other items using this appearance."], nil, nil, nil, true)
	elseif #items > 1 then
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(L["Other items using this appearance:"])
		for i, v in ipairs(items) do
			if v ~= item then
				addItemTooltipLine(v)
			end
		end
	end
	
	GameTooltip:Show()
end

local function showMenu(menu, data, isSaved)
	if mog.IsDropdownShown(menu) and menu.data ~= data then
		HideDropDownMenu(1)
	end
	-- needs to be either true or false
	data.isSaved = isSaved ~= nil
	menu.data = data
	ToggleDropDownMenu(nil, data.item, menu, "cursor", 0, 0)
end

function mog.Item_OnClick(self, btn, data, isSaved)
	local item = data.item
	if not (self and item) then return end
	
	if btn == "LeftButton" then
		if not HandleModifiedItemClick(select(2, GetItemInfo(item))) and data.items then
			data.cycle = (data.cycle % #data.items) + 1
			data.item = data.items[data.cycle]
			self:OnEnter()
		end
	elseif btn == "RightButton" then
		if IsControlKeyDown() then
			mog:AddToPreview(item)
		elseif IsShiftKeyDown() then
			mog:ShowURL(item)
		else
			showMenu(mog.Item_Menu, data, isSaved)
		end
	end
end

do
	local function itemOnClick(self, data, index)
		data.cycle = index
		data.item = data.items[index]
	end
	
	mog.Item_Menu = CreateFrame("Frame")
	mog.Item_Menu.displayMode = "MENU"
	mog.Item_Menu.initialize = function(self, level, menuList)
		local data = self.data
		
		if not menuList then
			if not createItemMenu(data, itemOnClick) then
				-- this is a single item, so skip directly to the item options menu
				createMenu(self, level, itemOptionsMenu)
			end
			return
		end
		
		createMenu(self, level, menuList)
	end
end

function mog.Set_FrameUpdate(self, data)
	self:ShowIndicator("label")
	self:SetText(data.name)
	self:Undress()
	for k, v in pairs(data.items) do
		self:TryOn(v, k)
	end
end

function mog.ShowSetTooltip(self, items, name)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip[mog] = true
	
	GameTooltip:AddLine(name)
	for i, slot in ipairs(mog.slots) do
		local itemID = items[slot] or items[i]
		if itemID then
			addItemTooltipLine(itemID)
		end
	end
	GameTooltip:Show()
end

function mog.Set_OnClick(self, btn, data, isSaved)
	if btn == "LeftButton" then
		if IsShiftKeyDown() then
			ChatEdit_InsertLink(mog:SetToLink(data.items))
		elseif IsControlKeyDown() then
			if not DressUpFrame:IsShown() or DressUpFrame.mode ~= "player" then
				DressUpFrame.mode = "player"
				DressUpFrame.ResetButton:Show()

				local race, fileName = UnitRace("player")
				SetDressUpBackground(DressUpFrame, fileName)

				ShowUIPanel(DressUpFrame)
				DressUpModel:SetUnit("player")
			end
			DressUpModel:Undress()
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
			mog:AddToPreview(data.items, mog:GetPreview())
		else
			showMenu(mog.Set_Menu, data, isSaved)
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
	
	function mog:AddSetOption(info)
		tinsert(setMenu, info)
	end
	
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
					info.arg2 = data.index
					UIDropDownMenu_AddButton(info, level)
				end
			end
			return
		end
		
		createMenu(self, level, menuList)
	end
end