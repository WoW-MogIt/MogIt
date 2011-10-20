local MogIt,mog = ...;
local L = mog.L;

do
	local template = mog:CreateTemplate("item");
	
	function template.FrameUpdate(module,self,value)
		self.model:Undress();
		mog:DressModel(self.model);
		self.model:TryOn(self.data.item);
	end
	
	function template.OnEnter(module,self)
		if not self then return end;
		local item = self.data.item;
		if not item then return end;
		
		GameTooltip:SetOwner(self,"ANCHOR_RIGHT");
	
		local name,link,_,_,_,_,_,_,_,texture = GetItemInfo(item);
		--GameTooltip:AddLine(self.display,1,1,1);
		--GameTooltip:AddLine(" ");
		GameTooltip:AddDoubleLine((texture and "\124T"..texture..":18\124t " or "")..(link or name or ""),(type(self.data.items) == "table") and (#self.data.items > 1) and L["Item %d/%d"]:format(self.data.cycle,#self.data.items),nil,nil,nil,1,0,0);
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
	
	function template.OnLeave(module,self)
		GameTooltip:Hide();
	end
	
	function template.OnClick(module,self,btn)
		if btn == "LeftButton" then
			if IsShiftKeyDown() then
				local _,link = GetItemInfo(self.data.item);
				if link then
					ChatEdit_InsertLink(link);
				end
			elseif IsControlKeyDown() then
				DressUpItemLink(self.data.item);
			else
				if type(self.data.items) == "table" then
					self.data.cycle = (self.data.cycle < #self.data.items and (self.data.cycle + 1)) or 1;
					self.data.item = self.data.items[self.data.cycle];
					mog.OnEnter(self);
				end
			end
		elseif btn == "RightButton" then
			if IsControlKeyDown() then
				mog:AddToPreview(self.data.item);
			elseif IsShiftKeyDown() then
				mog:ShowURL(self.data.item);
			else
				if UIDropDownMenu_GetCurrentDropDown() == mog.sub.ItemMenu and mog.sub.ItemMenu.menuList ~= self and DropDownList1 and DropDownList1:IsShown() then
					HideDropDownMenu(1);
				end
				ToggleDropDownMenu(nil,nil,mog.sub.ItemMenu,"cursor",0,0,self);
			end
		end
	end
	
	function template.OnScroll(module)
		if UIDropDownMenu_GetCurrentDropDown() == mog.sub.ItemMenu and DropDownList1 and DropDownList1:IsShown() then
			HideDropDownMenu(1);
		end
	end
	
	function template.GET_ITEM_INFO_RECEIVED()
		if UIDropDownMenu_GetCurrentDropDown() == mog.sub.ItemMenu and DropDownList1 and DropDownList1:IsShown() then
			HideDropDownMenu(1);
			ToggleDropDownMenu(nil,nil,mog.sub.ItemMenu,"cursor",0,0,mog.sub.ItemMenu.menuList);
		end
	end
end

do
	local template = mog:CreateTemplate("set");
	
	function template.FrameUpdate(module,self,value)
		self.model:Undress();
		for k,v in ipairs(self.data.items) do
			self.model:TryOn(v);
		end
	end
	
	function template.OnEnter(module,self)
		if not self or not self.data.set then return end;
		GameTooltip:SetOwner(self,"ANCHOR_RIGHT");
		
		GameTooltip:AddLine(self.data.name);
		for k,v in ipairs(self.data.items) do
			local name,link,_,_,_,_,_,_,_,texture = GetItemInfo(v);
			GameTooltip:AddLine((texture and "\124T"..texture..":18\124t " or "")..(link or name or ""));
		end
		
		GameTooltip:Show();
	end
	
	function template.OnLeave(module,self)
		GameTooltip:Hide();
	end
	
	function template.OnClick(module,self,btn)
		if btn == "LeftButton" then
			if IsShiftKeyDown() then
				ChatEdit_InsertLink(mog:SetToLink(self.data.items));
			elseif IsControlKeyDown() then
				for k,v in ipairs(self.data.items) do
					DressUpItemLink(v);
				end
			end
		elseif btn == "RightButton" then
			if IsShiftKeyDown() then
				mog:ShowURL(self.data.set,"set");
			elseif IsControlKeyDown() then
				mog:AddToPreview(self.data.items);
			else
				local wishlist = mog:GetModule("Wishlist")
				local create = wishlist:CreateSet(self.data.name)
				if create then
					for i, itemID in ipairs(self.data.items) do
						wishlist:AddItem(itemID, self.data.name)
					end
				end
			end
		end
	end
end