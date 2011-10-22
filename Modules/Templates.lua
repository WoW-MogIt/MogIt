local MogIt,mog = ...;
local L = mog.L;

--[=[
function template.OnLeave(module,self)
	GameTooltip:Hide();
end
--]=]

function mog.Item_FrameUpdate(self,items,cycle)
	local item;
	if type(items) == "table" then
		item = items[cycle];
	else
		item = items;
	end
	self.model:Undress();
	mog:DressModel(self.model);
	self.model:TryOn(item);
end

function mog.Item_OnEnter(self,items,cycle)
	local item;
	if type(items) == "table" then
		item = items[cycle];
	else
		item = items;
	end
	if not (self and item) then return end;
		
	GameTooltip:SetOwner(self,"ANCHOR_RIGHT");
	
	local name,link,_,_,_,_,_,_,_,texture = GetItemInfo(item);
	--GameTooltip:AddLine(self.display,1,1,1);
	--GameTooltip:AddLine(" ");
	GameTooltip:AddDoubleLine((texture and "\124T"..texture..":18\124t " or "")..(link or name or ""),(type(items) == "table") and (#items > 1) and L["Item %d/%d"]:format(cycle,#items),nil,nil,nil,1,0,0);
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



function mog.Item_OnClick(self,btn,items,cycle)
	local item;
	if type(items) == "table" then
		item = items[cycle];
	else
		item = items;
	end
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
			if type(items) == "table" then
				cycle = (cycle < #items and (cycle + 1)) or 1;
				item = items[cycle];
				mog.OnEnter(self);
			end
		end
	elseif btn == "RightButton" then
		if IsControlKeyDown() then
			mog:AddToPreview(item);
		elseif IsShiftKeyDown() then
			mog:ShowURL(item);
		else
			if UIDropDownMenu_GetCurrentDropDown() == mog.sub.ItemMenu and mog.sub.ItemMenu.menuList ~= self and DropDownList1 and DropDownList1:IsShown() then
				HideDropDownMenu(1);
			end
			ToggleDropDownMenu(nil,nil,mog.sub.ItemMenu,"cursor",0,0,self);
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

function mog.Set_FrameUpdate(self,set)
	self.model:Undress();
	for k,v in pairs(set) do
		self.model:TryOn(v);
	end
end

function mog.Set_OnEnter(self,set,name)
	if not (self and set) then return end;
	GameTooltip:SetOwner(self,"ANCHOR_RIGHT");
	
	GameTooltip:AddLine(name);
	for k,v in pairs(set) do
		local name,link,_,_,_,_,_,_,_,texture = GetItemInfo(v);
		GameTooltip:AddLine((texture and "\124T"..texture..":18\124t " or "")..(link or name or ""));
	end
	
	GameTooltip:Show();
end

--[=[
function template.OnLeave(module,self)
	GameTooltip:Hide();
end--]=]

function mog.Set_OnClick(self,btn,set,name,id)
	if not (self and set) then return end;
	if btn == "LeftButton" then
		if IsShiftKeyDown() then
			ChatEdit_InsertLink(mog:SetToLink(set));
		elseif IsControlKeyDown() then
			for k,v in pairs(set) do
				DressUpItemLink(v);
			end
		end
	elseif btn == "RightButton" then
		if IsShiftKeyDown() then
			mog:ShowURL(id,"set");
		elseif IsControlKeyDown() then
			mog:AddToPreview(set);
		else
			local wishlist = mog:GetModule("Wishlist")
			local create = wishlist:CreateSet(name)
			if create then
				for i, itemID in pairs(set) do
					wishlist:AddItem(itemID, name)
				end
			end
		end
	end
end