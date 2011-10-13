local MogIt, mog = ...
local L = mog.L

local db = {}
local wishlist = {}

local levels = {
	[1] = function(menu, level)
		if type(menu) == "table" then
			for k, v in pairs(menu.items) do
				local info = UIDropDownMenu_CreateInfo()
				info.text = GetItemInfo(v)
				info.hasArrow = true
				info.notCheckable = true
				
				UIDropDownMenu_AddButton(info, level)
			end
		end
	end,
	[2] = function(menu, level)
		-- for k, v in pairs(menu) do
			local info = UIDropDownMenu_CreateInfo()
			info.text = "Delete dis"
			-- info.hasArrow = true
			info.notCheckable = true
			UIDropDownMenu_AddButton(info, level)
		-- end
	end,
}

local menu = CreateFrame("Frame")
menu.point = "TOPLEFT"
menu.relativePoint = "TOPRIGHT"
function menu:initialize(level, menulist)
	levels[level](menulist, level)
end

function wishlist:Dropdown(level)
	if level == 1 then
		local info = UIDropDownMenu_CreateInfo()
		info.text = "Wishlist"
		info.value = self
		info.colorCode = "|cFFFFFF00"
		-- info.hasArrow = module.loaded
		info.keepShownOnClick = true
		info.notCheckable = true
		info.func = function(self)
			mog:SetModule(wishlist)
		end
		UIDropDownMenu_AddButton(info, level)
	-- elseif level == 2 then
		-- for k,v in ipairs(module.slots) do
			-- info = UIDropDownMenu_CreateInfo();
			-- info.text = v.label;
			-- info.value = v;
			-- info.notCheckable = true;
			-- info.func = function(self)
				-- UIDropDownMenu_SetText(mog.dropdown,self.arg1.name.." - "..self.value.label);
				-- mog.sub.selected = self.value;
				-- mog.sub.BuildList(self.arg1,self.value.items,true);
				-- CloseDropDownMenus();
			-- end
			-- info.arg1 = module;
			-- UIDropDownMenu_AddButton(info, level)
		-- end
	end
end

function wishlist:FrameUpdate(self, value)
	local data = self.data
	-- self.data.display = value;
	-- self.data.items = mog.sub.display[value];
	-- data.type = value.type
	data.value = value
	self.model:Undress()
	-- if data.type == "set" then
	if type(value) == "table" then
		for slot, itemID in pairs(value.items) do
			self.model:TryOn(itemID)
		end
	else
		-- data.item = value.itemID
		self.model:TryOn(value)
	end
end

function wishlist:OnEnter(self)
	if not self then return end
	local data = self.data
	local value = data.value
	-- GameTooltip:SetOwner(self, "ANCHOR_NONE")
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	
	local data = mog.sub.data
	-- if data.type == "set" then
	if type(value) == "table" then
		GameTooltip:AddLine(value.name)
		for slot, itemID in pairs(value.items) do
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
			GameTooltip:AddDoubleLine(link, source and strjoin(", ", info, extraInfo or ""))
			GameTooltip:AddTexture(GetItemIcon(itemID))
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
	--GameTooltip:ClearAllPoints()
	--GameTooltip:SetPoint("TOPLEFT",mog.frame,"TOPRIGHT",5,0)
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
			ToggleDropDownMenu(nil, nil, menu, self, 0, 0, self.data.value)
		end
	end
end
--[==[
function wishlist:AddItem(item)
	self:BuildList()
end

function mog.sub.OnScroll(module)
	if UIDropDownMenu_GetCurrentDropDown() == mog.sub.LeftClick and DropDownList1 and DropDownList1:IsShown() then
		HideDropDownMenu(1);
	end
end
]==]

mog:RegisterModule("Wishlist", wishlist, true)

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
					set.items[slotID] = itemID
					set[slotID] = nil
				end
			end
		end
	end
	
	-- db.RegisterCallback(self, "OnProfileChanged", "LoadSettings")
	-- db.RegisterCallback(self, "OnProfileCopied", "LoadSettings")
	-- db.RegisterCallback(self, "OnProfileReset", "LoadSettings")
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

function wishlist:IsItemInWishlist(itemID)
	for i, v in ipairs(self.db.profile.items) do
		if v == itemID then
			return true
		end
	end
	return false
end

function wishlist:AddItem(itemID, setName)
	if setName then
		for i, set in ipairs(self.db.profile.sets) do
			if set.name == setName then
				-- ???
				break
			end
		end
	else
		tinsert(self.db.profile.items, itemID)
	end
	self:BuildList()
end