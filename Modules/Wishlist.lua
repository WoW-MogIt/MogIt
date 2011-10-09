local MogIt, mog = ...
local L = mog.L

local db = {}
local wishlist = {}

local menu = CreateFrame("Frame")
function menu:initialize(level, menulist)
	if type(menulist) == "table" then
		for k, v in pairs(menulist) do
			if v[1] then
				local info = UIDropDownMenu_CreateInfo()
				info.text = GetItemInfo(v[1])
				UIDropDownMenu_AddButton(info, level)
			end
		end
	end
end

function wishlist:Dropdown(level)
	if level == 1 then
		local info = UIDropDownMenu_CreateInfo()
		info.text = "Wishlist"
		info.value = module
		-- info.colorCode = "|cFF"..(module.loaded and "00FF00" or "FF0000")
		-- info.hasArrow = module.loaded
		info.keepShownOnClick = true
		info.notCheckable = true
		info.func = function(self)
			wishlist:BuildList()
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
		for slot, itemID in pairs(value) do
			if itemID[1] then
				self.model:TryOn(itemID[1])
			end
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
	
	local source = mog.sub.filters.source
	-- if data.type == "set" then
	if type(value) == "table" then
		GameTooltip:AddLine(value.name)
		for slot, itemID in pairs(value) do
		-- for slot, itemID in pairs(entry.items) do
			if itemID[1] then
				local name, link, _, _, _, _, _, _, _, texture = GetItemInfo(itemID[1])
				GameTooltip:AddDoubleLine(link, mog.sub.source[source[itemID[1]]])
				GameTooltip:AddTexture(GetItemIcon(itemID[1]))
			end
		end
	else
		local name, link, _, _, _, _, _, _, _, texture = GetItemInfo(value)
		-- GameTooltip:AddLine(self.display,1,1,1)
		-- GameTooltip:AddLine(" ")
		
		-- for i = 1, #items do
			-- local item, source = items[i]
			-- local source = sources[item.id]
			GameTooltip:AddDoubleLine(link, mog.sub.source[source[value]])
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
				for slot, itemID in pairs(value) do
				-- for slot, itemID in pairs(entry.items) do
					if itemID[1] then
						local name, link, _, _, _, _, _, _, _, texture = GetItemInfo(itemID[1])
						DressUpItemLink(itemID[1])
					end
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

mog:RegisterModule(wishlist)

function wishlist:BuildList()
	-- wipe(mog.sub.list);
	-- wipe(mog.sub.display);
	-- module = module or mog.selected;
	-- tbl = tbl or mog.sub.selected.items;
	-- for k,v in ipairs(tbl) do
		-- if mog.sub.filterLevel(v) and mog.sub.filterFaction(v) and mog.sub.filterClass(v) and mog.sub.filterSlot(v) and mog.sub.filterSource(v) and mog.sub.filterQuality(v) then
			-- local disp = mog.sub.filters.display[v];
			-- if not mog.sub.display[disp] then
				-- mog.sub.display[disp] = v;
				-- tinsert(mog.sub.list,disp);
			-- elseif type(mog.sub.display[disp]) == "table" then
				-- tinsert(mog.sub.display[disp],v);
			-- else
				-- mog.sub.display[disp] = {mog.sub.display[disp],v};
			-- end
		-- end
	-- end
	local list = {}
	local db = mog.char.wishlist
	for i, v in ipairs(db.sets) do
		list[#list + 1] = v
	end
	for i, v in ipairs(db.items) do
		list[#list + 1] = v
	end
	mog:SetList(wishlist, list, top)
end