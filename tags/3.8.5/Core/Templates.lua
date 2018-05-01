local MogIt, mog = ...
local L = mog.L

local TEXTURE = [[Interface\RaidFrame\ReadyCheck-Ready]]

function mog:GetItemLabel(itemID, callback, includeIcon, iconSize)
	local item = mog:GetItemInfo(itemID, callback)
	local name
	if item then
		name = format("|c%s%s|r", select(4, GetItemQualityColor(item.quality)), item.name)
	else
		name = RED_FONT_COLOR_CODE..RETRIEVING_ITEM_INFO..FONT_COLOR_CODE_CLOSE
	end
	if includeIcon then
		return format("|T%s:%d|t %s", GetItemIcon(itemID), iconSize, name)
	else
		return name
	end
end

local function addItemTooltipLine(itemID, slot, selected, wishlist, isSetItem)
	local texture = format("|T%s:0|t ", (selected and [[Interface\ChatFrame\ChatFrameExpandArrow]]) or (mog:HasItem(mog:GetSourceFromItem(itemID), isSetItem) and TEXTURE) or (wishlist and [[Interface\TargetingFrame\UI-RaidTargetingIcon_1]]) or "")
	GameTooltip:AddDoubleLine(texture..(type(slot) == "string" and _G[strupper(slot)]..": " or "")..mog:GetItemLabel(itemID, "ModelOnEnter"), mog.GetItemSourceShort(itemID), nil, nil, nil, 1, 1, 1)
end

function mog.GetItemSourceInfo(itemID)
	local appearanceID, sourceID = C_TransmogCollection.GetItemInfo(itemID)
	itemID = sourceID
	local source, info, zone;
	local sourceType = mog:GetData("item", itemID, "source");
	local sourceID = mog:GetData("item", itemID, "sourceid");
	local sourceInfo = mog:GetData("item", itemID, "sourceinfo");

	if sourceType == 1 and sourceInfo and #sourceInfo > 0 then -- Drop
		local drop = sourceInfo[1]
		source = drop.encounter
		zone = drop.instance
		local diff = drop.difficulties[1]
		if diff then
			zone = format("%s (%s)", zone, diff);
		end
	elseif sourceType == 3 and sourceID then -- Quest
		info = IsQuestFlaggedCompleted(sourceID) or false;
	elseif sourceType == 5 and sourceInfo then -- Crafted
		source = L.professions[sourceInfo];
	elseif sourceType == 6 and sourceID then -- Achievement
		local _, name, _, complete = GetAchievementInfo(sourceID);
		source = name;
		info = complete;
	end

	-- local zone = mog:GetData("item", itemID, "zone");
	-- if zone then
		-- zone = GetMapNameByID(zone);
		-- if zone then
			-- local diff = L.diffs[sourceInfo];
			-- if sourceType == 1 and diff then
				-- zone = format("%s (%s)", zone, diff);
			-- end
		-- end
	-- end

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
	StaticPopup_Show("MOGIT_WISHLIST_CREATE_SET", nil, nil, {items = {self.value}})
	CloseDropDownMenus()
end

local previewItem = {
	text = L["Preview"],
	menuList = function(self, level)
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
			info.text = format("%s %d", L["Preview"], preview:GetID())
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
}

local itemOptions = {
	previewItem,
	{
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
		menuList = function(self, level)
			local info = UIDropDownMenu_CreateInfo()
			info.text = L["New set..."]
			info.value = UIDROPDOWNMENU_MENU_VALUE
			info.func = newSetOnClick
			info.colorCode = GREEN_FONT_COLOR_CODE
			info.notCheckable = true
			UIDropDownMenu_AddButton(info, level)

			mog.wishlist:AddSetMenuItems(level, "addItem", UIDROPDOWNMENU_MENU_VALUE)
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
	tinsert(itemOptions, info)
end

function mog:SetPreviewMenu(isSinglePreview)
	if isSinglePreview then
		previewItem.func = previewOnClick
		previewItem.hasArrow = nil
	else
		previewItem.func = nil
		previewItem.hasArrow = true
	end
end

local function addItemList(dropdown, data, func)
	local items = data.items
	local isArray = #items > 0

	for i, v in ipairs(isArray and items or mog.slots) do
		local item = isArray and v or items[v]
		if item then
			local info = UIDropDownMenu_CreateInfo()
			info.text = mog:GetItemLabel(item, func and "ItemMenu" or "SetMenu")
			info.value = item
			info.func = func
			info.checked = (i == data.cycle)
			info.hasArrow = true
			info.notCheckable = data.isSaved or data.name
			info.arg1 = data
			info.arg2 = i
			info.menuList = itemOptions
			dropdown:AddButton(info)
		end
	end
end

local function createMenu(self, level, menuList)
	local data = self.data
	if type(menuList) == "function" then
		menuList(self, level)
	else
		for i, info in ipairs(menuList) do
			if type(info) == "function" then
				info(self, level, data)
			elseif (info.wishlist == nil or info.wishlist == data.isSaved) and (not info.set or data.items) then
				info.value = UIDROPDOWNMENU_MENU_VALUE
				info.notCheckable = true
				info.arg1 = data
				self:AddButton(info, level)
			end
		end
	end
end

local function showMenu(menu, data, isSaved, isPreview)
	if menu:IsShown() and menu.data ~= data then
		HideDropDownMenu(1)
	end
	-- needs to be either true or false
	data.isSaved = (isSaved ~= nil)
	data.isPreview = isPreview
	menu.data = data
	menu:Toggle(data.item, "cursor")
end

do	-- item functions
	local sourceLabels = {
		[L.source[1]] = BOSS,
	}

	GameTooltip:RegisterEvent("MODIFIER_STATE_CHANGED")
	GameTooltip:HookScript("OnEvent", function(self, event, key, state)
		if self:IsForbidden() then return end
		local owner = self:GetOwner()
		if owner and self[mog] then
			owner:OnEnter()
		end
	end)
	GameTooltip:HookScript("OnTooltipCleared", function(self)
		self[mog] = nil
	end)

	function mog.Item_FrameUpdate(self, data)
		local item = data.item
		self:ApplyDress()
		-- hack for items not returning any transmog info
		if not item then return end
		local _, _, _, slot = GetItemInfoInstant(item)
		local tryonSlot
		if slot == "INVTYPE_WEAPON" then
			tryonSlot = "MAINHANDSLOT"
		end
		if data.sourceID then
			self.model:TryOn(data.sourceID, tryonSlot)
		else
			self:TryOn(format(gsub(item, "item:(%d+):0", "item:%1:%%d"), mog.weaponEnchant), tryonSlot)
		end
		if not mog:GetItemInfo(item) then
			mog.doModelUpdate = true
		end
	end

	function mog.Item_OnClick(self, button, data, isSaved, isPreview)
		local item = data.item
		if not (self and item) then return end

		if button == "LeftButton" then
			if not HandleModifiedItemClick(select(2, GetItemInfo(item))) and data.items then
				data.cycle = (data.cycle % #data.items) + 1
				data.item = data.items[data.cycle]
				self:OnEnter()
			end
		end
		if button == "RightButton" then
			if IsControlKeyDown() then
				mog:AddToPreview(item)
			elseif IsShiftKeyDown() then
				mog:ShowURL(item, "item")
			else
				showMenu(mog.Item_Menu, data, isSaved, isPreview)
			end
		end
	end

	function mog.ShowItemTooltip(self, item, items)
		-- hack for items not returning any transmog info
		if not item then return end
		
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip[mog] = true

		if IsShiftKeyDown() then
			if type(item) == "number" then
				GameTooltip:SetItemByID(item)
			else
				GameTooltip:SetHyperlink(item)
			end
			for _, frame in pairs(GameTooltip.shoppingTooltips) do
				frame:Hide()
			end
			return
		end

		local itemInfo = mog:GetItemInfo(item, "ModelOnEnter")
		local itemLevel = itemInfo and itemInfo.itemLevel
		GameTooltip:AddLine(mog:GetItemLabel(item, "ModelOnEnter"))

		local sourceType, source, zone, info = mog.GetItemSourceInfo(item)
		if sourceType then
			GameTooltip:AddLine(L["Source"]..": |cffffffff"..sourceType)
			if source then
				GameTooltip:AddLine((sourceLabels[sourceType] or sourceType)..": |cffffffff"..source)
			end
			if info ~= nil then
				GameTooltip:AddLine(STATUS..": |cffffffff"..(info and COMPLETE or INCOMPLETE))
			end
		end
		if zone then
			GameTooltip:AddLine(ZONE..": |cffffffff"..zone)
		end

		GameTooltip:AddLine(" ")
		local bindType = mog:GetData("item", item, "bind")
		if bindType then
			GameTooltip:AddLine(L.bind[bindType], 1.0, 1.0, 1.0)
		end
		local requiredLevel = mog:GetData("item", item, "level")
		if itemInfo and itemInfo.reqLevel and itemInfo.reqLevel > 0 then
			GameTooltip:AddLine(L["Required Level"]..": |cffffffff"..itemInfo.reqLevel)
		end
		GameTooltip:AddLine(STAT_AVERAGE_ITEM_LEVEL..": |cffffffff"..(itemLevel or "??"))
		local faction = mog:GetData("item", item, "faction")
		if faction then
			GameTooltip:AddLine(FACTION..": |cffffffff"..(faction == 1 and FACTION_ALLIANCE or FACTION_HORDE))
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
			GameTooltip:AddLine(CLASS..": "..str)
		end
		local slot = mog:GetData("item", item, "slot")
		if slot then
			GameTooltip:AddLine(L["Slot"]..": |cffffffff"..L.slots[slot])
		end

		if mog.db.profile.tooltipItemID then
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(L["Item ID"]..": |cffffffff"..mog:ToNumberItem(item))
		end
		
		-- source sometimes can't be determined if item is not cached
		local hasItem = itemInfo and mog:HasItem(mog:GetSourceFromItem(item))
		if hasItem then
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(format("|T%s:0|t ", TEXTURE)..L["You have this item."], 1, 1, 1)
		end

		local found, profiles = mog.wishlist:IsItemInWishlist(item)
		if (not mog.active or mog.active.name ~= "Wishlist") and found then
			if not hasItem then
				GameTooltip:AddLine(" ")
			end
			GameTooltip:AddLine("|TInterface\\PetBattles\\PetJournal:0:0:0:0:512:1024:62:78:26:42:255:255:255|t "..L["This item is on your wishlist."], 1, 1, 1)
			if mog.db.profile.tooltipWishlistDetail and profiles then
				for i, character in ipairs(profiles) do
					GameTooltip:AddLine("|T:0|t "..character)
				end
			end
		end

		if items then
			if type(items) == "string" then
				local visualID = C_TransmogCollection.GetItemInfo(items)
				if visualID then
					local sources = C_TransmogCollection.GetAllAppearanceSources(visualID)
					items = {}
					for i, source in ipairs(sources) do
						items[i] = mog:NormaliseItemString(select(6, C_TransmogCollection.GetAppearanceSourceInfo(source)))
					end
				end
			end
			if type(items) == "table" and #items > 1 then
				GameTooltip:AddLine(" ")
				GameTooltip:AddLine(L["Items using this appearance:"])
				for i, v in ipairs(items) do
					addItemTooltipLine(v, nil, v == item, (mog.wishlist:IsItemInWishlist(v)))
				end
			end
		end

		GameTooltip:Show()
	end

	local function itemOnClick(self, data, index)
		data.cycle = index
		data.item = data.items[index]
	end

	mog.Item_Menu = mog:CreateDropdown("Menu")
	mog.Item_Menu.initialize = function(self, level, menuList)
		local data = self.data

		local items = data.items
		-- not listing the items if there's only 1 and it's not a set
		if level == 1 and (items and not (data.item and #items == 1)) then
			addItemList(self, data, itemOnClick)
		else
			createMenu(self, level, menuList or itemOptions)
		end
	end
end

do	-- set functions
	function mog.Set_FrameUpdate(self, data)
		self:ShowIndicator("label")
		self:SetText(data.name)
		self:Undress()
		local hasSet = next(data.items)
		for slot, item in pairs(data.items) do
			self:TryOn(item, slot == "SecondaryHandSlot" and slot)
			if not mog:HasItem(mog:GetSourceFromItem(item), true) then
				hasSet = false
			end
			if not mog:GetItemInfo(item) then
				mog.doModelUpdate = true;
			end
		end
		if hasSet then
			self:ShowIndicator("hasItem")
		end
	end

	function mog.Set_OnClick(self, button, data, isSaved)
		if button == "LeftButton" then
			if IsShiftKeyDown() then
				ChatEdit_InsertLink(mog:SetToLink(data.items))
			elseif IsControlKeyDown() then
				if mog.db.profile.dressupPreview then
					mog:AddToPreview(data.items, mog:GetPreview(), data.name)
				else
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
			end
		end
		if button == "RightButton" then
			if IsShiftKeyDown() then
				if data.set then
					mog:ShowURL(data.set, "set")
				else
					mog:ShowURL(data.items, "compare")
				end
			elseif IsControlKeyDown() then
				mog:AddToPreview(data.items, mog:GetPreview(), data.name)
			else
				showMenu(mog.Set_Menu, data, isSaved)
			end
		end
	end

	function mog.ShowSetTooltip(self, items, name)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip[mog] = true

		GameTooltip:AddLine(name)
		for i, slot in ipairs(mog.slots) do
			local item = items[slot] or items[i]
			if item then
				addItemTooltipLine(item, items[slot] and slot, nil, nil, true)
			end
		end
		GameTooltip:Show()
	end

	local setOptions = {
		{
			wishlist = false,
			text = L["Add set to wishlist"],
			func = function(self, set, items)
				if mog.wishlist:CreateSet(set) then
					for i, item in pairs(items) do
						mog.wishlist:AddItem(item, set)
					end
				end
			end,
		},
		{
			wishlist = true,
			text = L["Rename set"],
			func = function(self, set)
				mog.wishlist:RenameSet(set)
			end,
		},
		{
			wishlist = true,
			text = L["Delete set"],
			func = function(self, set)
				mog.wishlist:DeleteSet(set)
			end,
		},
	}

	function mog:AddSetOption(info)
		tinsert(setOptions, info)
	end

	mog.Set_Menu = mog:CreateDropdown("Menu")
	mog.Set_Menu.initialize = function(self, level, menuList)
		if level == 1 then
			local data = self.data
			addItemList(self, data)
			for i, info in ipairs(setOptions) do
				if info.wishlist == nil or info.wishlist == data.isSaved then
					info.value = data.name
					info.notCheckable = true
					info.arg1 = data.name
					info.arg2 = data.items
					self:AddButton(info, level)
				end
			end
		else
			createMenu(self, level, menuList)
		end
	end
end
