local MogIt,mog = ...;
local L = mog.L;

local IsShiftKeyDown = IsShiftKeyDown;
local IsControlKeyDown = IsControlKeyDown;
local GetScreenWidth = GetScreenWidth;
local GetScreenHeight = GetScreenHeight;
local GetMouseFocus = GetMouseFocus;
local GetItemInfo = GetItemInfo;
local GetSpellInfo = GetSpellInfo;
local GetAchievementInfo = GetAchievementInfo;
local type = type;
local pairs = pairs;
local ipairs = ipairs;
local tinsert = table.insert;
local tremove = table.remove;
local floor = math.floor;
local ceil = math.ceil;
local band = bit.band;
local min = min;
local tonumber = tonumber;

mog.models = {};
mog.bin = {};
mog.list = {};
mog.display = {};

mog.posX = 0;
mog.posY = 0;
mog.posZ = 0;
mog.face = 0;

mog.grid = MogItGrid;
mog.grid:Hide();
mog.grid:SetPoint("CENTER",UIParent,"CENTER");
mog.grid:SetFrameLevel(5);
mog.grid:SetClampedToScreen(true);
mog.grid:EnableMouse(true);
mog.grid:EnableMouseWheel(true);
mog.grid:SetMovable(true);
mog.grid:SetResizable(true);
mog.grid:SetUserPlaced(true);
mog.grid:SetScript("OnMouseDown",mog.grid.StartMoving);
mog.grid:SetScript("OnMouseUp",mog.grid.StopMovingOrSizing);
mog.grid:SetHitRectInsets(-10,-10,-10,-10);
mog.grid:SetScript("OnShow",function(self)
	mog.scroll:update();
end);

mog.grid.resize = CreateFrame("Frame",nil,mog.grid);
mog.grid.resize:SetSize(16,16);
mog.grid.resize:SetPoint("BOTTOMRIGHT",mog.grid,"BOTTOMRIGHT",10,-10);
mog.grid.resize:EnableMouse(true);
mog.grid.resize:SetScript("OnMouseDown",function(self)
	mog.grid:SetMinResize((mog.global.columns*35)-5+20+43,(mog.global.rows*35)-5+43+20);
	mog.grid:SetMaxResize(GetScreenWidth(),GetScreenHeight());
	mog.grid:StartSizing();
	mog.grid.resize.update:Show();
end);
mog.grid.resize:SetScript("OnMouseUp",function(self)
	mog.grid.resize.update:Hide();
	mog.grid:StopMovingOrSizing();
	mog.opt.btnUpdate(true,true);
end);
mog.grid.resize:SetScript("OnHide",mog.grid:GetScript("OnMouseUp"));

mog.grid.resize.update = CreateFrame("Frame",nil,mog.grid.resize);
mog.grid.resize.update:Hide();
mog.grid.resize.update:SetScript("OnUpdate",function(self)
	mog.global.gridWidth = floor((mog.grid:GetWidth()+5-20-43)/mog.global.columns)-5;
	mog.global.gridHeight = floor((mog.grid:GetHeight()+5-43-20)/mog.global.rows)-5;
	mog.updateGrid(true);
end);
mog.grid.resize.texture = mog.grid.resize:CreateTexture(nil,"OVERLAY");
mog.grid.resize.texture:SetSize(16,16);
mog.grid.resize.texture:SetTexture("Interface\\AddOns\\MogIt\\Images\\Resize");
mog.grid.resize.texture:SetPoint("BOTTOMRIGHT",mog.grid.resize,"BOTTOMRIGHT",-3,3);

mog.grid.topbar = CreateFrame("Frame",nil,mog.grid);
mog.grid.topbar:SetHeight(18);
mog.grid.topbar:SetPoint("TOPLEFT",mog.grid,"TOPLEFT",20,-20);
mog.grid.topbar:SetPoint("TOPRIGHT",mog.grid,"TOPRIGHT",-20,-20);
mog.grid.topbar:SetBackdrop({
	bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", 
	tile = true, tileSize = 16,
	insets = { left = 0, right = 0, top = 0, bottom = 0 }
});
mog.grid.topbar:SetBackdropColor(0,0,0,0.6);

mog.grid.topleft = mog.grid.topbar:CreateFontString(nil,"ARTWORK","GameFontHighlightSmall");
mog.grid.topleft:SetPoint("LEFT",mog.grid.topbar,"LEFT",5,0);

mog.scroll = CreateFrame("Slider","MogItScroll",mog.grid,"UIPanelScrollBarTemplate");
mog.scroll:SetBackdrop({
	bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", 
	tile = true, tileSize = 16, 
	insets = { left = 0, right = 0, top = 0, bottom = 0 }
});
mog.scroll:SetBackdropColor(0,0,0,0.6);
mog.scroll:SetScript("OnValueChanged",function(self,value)
	mog.scroll:update(value);
end);
mog.scroll:SetValueStep(1);
mog.scroll:SetValue(1);
mog.scroll.up = MogItScrollScrollUpButton;
mog.scroll.down = MogItScrollScrollDownButton;
mog.scroll:SetPoint("TOPRIGHT",mog.grid.topbar,"BOTTOMRIGHT",0,-21);
mog.scroll:SetPoint("BOTTOMRIGHT",mog.grid,"BOTTOMRIGHT",-20,36);
mog.scroll.up:SetScript("OnClick",function(self)
	mog.scroll:update(nil,-1);
end);
mog.scroll.down:SetScript("OnClick",function(self)
	mog.scroll:update(nil,1);
end);

function mog.updateModels()
	mog.view.model:SetFacing(mog.face);
	if mog.view.model:IsShown() then
		mog.view.model:SetPosition(mog.posZ,mog.posX,mog.posY);
	end
	for k,v in ipairs(mog.models) do
		v:SetFacing(mog.face);
		if v:IsShown() then
			v:SetPosition(mog.posZ,mog.posX,mog.posY);
		end
	end
end

mog.modelUpdater = CreateFrame("Frame",nil,mog.container);
mog.modelUpdater:Hide();
mog.modelUpdater:SetScript("OnUpdate",function(self,elapsed)
	local currentx,currenty = GetCursorPosition();
	if self.btn == "LeftButton" then
		mog.face = mog.face + ((currentx-self.prevx)/50);
		mog.posZ = mog.posZ + ((currenty-self.prevy)/50);
	elseif self.btn == "RightButton" then
		mog.posX = mog.posX + ((currentx-self.prevx)/50);
		mog.posY = mog.posY + ((currenty-self.prevy)/50);
	end
	mog.updateModels();
	self.prevx,self.prevy = currentx,currenty;
end);

function mog.itemClick(self,btn)
	if not self.item then return end;
	if btn == "LeftButton" then
		if IsShiftKeyDown() then
			local _,link = GetItemInfo(self.item);
			if link then
				ChatEdit_InsertLink(link);
			end
		elseif IsControlKeyDown() then
			DressUpItemLink(self.item);
		else
			if type(self.list) == "table" then
				if mog.info.item == self.item then
					self.cycle = (self.cycle < #self.list and (self.cycle + 1)) or 1;
					self.item = self.list[self.cycle];
				end
			end
			mog.info.setItem(self.item);
		end
	elseif btn == "RightButton" then
		if IsControlKeyDown() then
			if self.slot then
				mog.view.delItem(self.slot);
				mog.dressModel(mog.view.model);
				if mog.global.gridDress then
					mog.scroll:update();
				end
			else
				mog.view.addItem(self.item);
			end
		elseif IsShiftKeyDown() then
			StaticPopup_Show("MOGIT_URL",mog.global.url,nil,self.item);
		elseif self.star then
			if mog.char.wishlist.display[self.display] then
				mog.char.wishlist.display[self.display] = nil;
				mog.char.wishlist.time[self.display] = nil;
				if mog.selected == "wl" then
					table.remove(mog.list,self.index);
					mog.display[self.display] = nil;
					mog.scroll:update();
				else
					self.star:Hide();
				end
			else
				mog.char.wishlist.display[self.display] = self.list;
				mog.char.wishlist.time[self.display] = time();
				if mog.selected == "wl" then
					mog.scroll:update();
				else
					self.star:Show();
				end
			end
		end
	end
end

function mog.dressModel(model)
	model:Undress();
	if mog.global.gridDress or (mog.view.model == model) then
		for k,v in ipairs(mog.view.slots) do
			if v.item then
				model:TryOn(v.item);
			end
		end
	end
end

function mog.addModel(view)
	local f;
	if (not view) and mog.bin[1] then
		f = mog.bin[1];
		tremove(mog.bin,1);
	else
		f = CreateFrame("DressUpModel",nil,view and mog.view or mog.grid);
		f:Hide();
		f:SetBackdrop({
			bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", 
			tile = true, tileSize = 16,
			insets = { left = 0, right = 0, top = 0, bottom = 0 }
		});
		f:SetBackdropColor(0,0,0,0.6);
		f:SetModelScale(2);
		f:SetPosition(0,0,0);
		f.btn = CreateFrame("Button",nil,f);
		f.btn:SetAllPoints(f);
		f.btn:RegisterForDrag("LeftButton","RightButton");
		f.btn:SetScript("OnDragStart",function(self,btn)
			mog.modelUpdater.btn = btn;
			mog.modelUpdater.model = self;
			mog.modelUpdater.prevx,mog.modelUpdater.prevy = GetCursorPosition();
			mog.modelUpdater:Show();
		end);
		f.btn:SetScript("OnDragStop",function(self,btn)
			mog.modelUpdater:Hide();
			mog.modelUpdater.btn = nil;
			mog.modelUpdater.model = nil;
		end);
		f:SetScript("OnHide",function(self)
			if mog.modelUpdater.model == self.btn then
				self.btn:GetScript("OnDragStop")(self);
			end
			self:SetPosition(0,0,0);
		end);
		f:SetScript("OnShow",function(self)
			self:SetPosition(mog.posZ,mog.posX,mog.posY);
			mog.dressModel(self);
		end);
		
		if not view then
			f:SetUnit("PLAYER");
			f.btn.star = f:CreateTexture(nil,"ARTWORK");
			f.btn.star:Hide();
			f.btn.star:SetSize(16,16);
			f.btn.star:SetPoint("TOPRIGHT",f,"TOPRIGHT",-4,-4);
			f.btn.star:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_1");
			f.btn:RegisterForClicks("AnyUp");
			f.btn:SetScript("OnClick",mog.itemClick);
			--[[f.c = {};
			f.c[1] = f:CreateTexture(nil,"OVERLAY");
			f.c[1]:SetSize(16,16);
			f.c[1]:SetPoint("BOTTOMLEFT",f,"BOTTOMLEFT",4,4);
			f.c[2] = f:CreateTexture(nil,"OVERLAY");
			f.c[2]:SetSize(16,16);
			f.c[2]:SetPoint("LEFT",f.c[1],"RIGHT",2,0);
			f.c[3] = f:CreateTexture(nil,"OVERLAY");
			f.c[3]:SetSize(16,16);
			f.c[3]:SetPoint("LEFT",f.c[2],"RIGHT",2,0);--]]
		end
	end
	if not view then
		tinsert(mog.models,f);
	end
	return f;
end

function mog.delModel(f)
	mog.models[f]:Hide();
	tinsert(mog.bin,mog.models[f]);
	tremove(mog.models,f);
end

function mog.updateGrid(resize)
	local rows,columns = mog.global.rows,mog.global.columns;
	local total = rows*columns;
	local current = #mog.models;
	local width,height = mog.global.gridWidth,mog.global.gridHeight;
	
	if not resize then
		if current > total then
			for i=current,(total+1),-1 do
				mog.delModel(i);
			end
		elseif current < total then
			for i=(current+1),total,1 do
				mog.addModel();
			end
		end
		mog.grid:SetSize(((width+5)*columns)-5+20+43,((height+5)*rows)-5+43+20);
	end
	
	for row=1,rows do
		for column=1,columns do
			local n = ((row-1)*columns)+column;
			if not resize then
				if n==1 then
					mog.models[n]:SetPoint("TOPLEFT",mog.grid.topbar,"BOTTOMLEFT",0,-5);
				elseif column==1 then
					mog.models[n]:SetPoint("TOPLEFT",mog.models[n-columns],"BOTTOMLEFT",0,-5);
				else
					mog.models[n]:SetPoint("TOPLEFT",mog.models[n-1],"TOPRIGHT",5,0);
				end
			end
			mog.models[n]:SetSize(width,height);
		end
	end
end

function mog.scroll.update(self,page,offset)
	local models = #mog.models;
	local total = ceil(#mog.list/models);
	
	if total > 1 then
		self:SetMinMaxValues(1,total);
		self:Show();
	else
		self:Hide();
	end
	
	if not page then
		page = self:GetValue() or 1;
	end
	
	if offset then
		page = page + offset;
	end
	
	if page < 1 then
		page = 1;
	elseif page > total then
		page = total;
	end
	self:SetValue(page);
	
	if page == 1 then
		self.up:Disable();
	else
		self.up:Enable();
	end
	if page == total then
		self.down:Disable();
	else
		self.down:Enable();
	end
	
	local id,model,index;
	for id,model in ipairs(mog.models) do
		index = ((page-1)*models)+id;
		if mog.list[index] then
			model.btn.display = mog.list[index];
			model.btn.list = mog.display[model.btn.display];
			model.btn.cycle = 1;
			model.btn.item = type(model.btn.list) == "table" and model.btn.list[1] or model.btn.list;
			model.btn.index = index;
			if model:IsShown() then
				mog.dressModel(model);
			else
				model:Show();
			end
			model:TryOn(model.btn.item);
			if mog.char.wishlist.display[model.btn.display] then
				model.btn.star:Show();
			else
				model.btn.star:Hide();
			end
			--[[for i=1,3 do
				if mog.filters.colours[i][model.btn.display] then
					model.c[i]:Show();
					local r,g,b = mog.filters.colours[i][model.btn.display]:match("^(..)(..)(..)$");
					r = tonumber(r,16);
					g = tonumber(g,16);
					b = tonumber(b,16); 
					model.c[i]:SetTexture(r/255,g/255,b/255,1);
				else
					model.c[i]:Hide();
				end
			end--]]
		else
			model:Hide();
		end
	end
	mog.grid.topleft:SetText(L["%d models"]:format(#mog.list)..(total > 0 and " - "..MERCHANT_PAGE_NUMBER:format(page,total) or ""));
end

mog.grid:SetScript("OnMouseWheel",function(self,offset)
	local value = mog.scroll:GetValue();
	local low,high = mog.scroll:GetMinMaxValues();
	if (offset > 0 and value > low) then
		mog.scroll:update(nil,-1);
	elseif (offset < 0 and value < high) then
		mog.scroll:update(nil,1);
	end
end);

function mog.buildList(top,show)
	if not mog.selected then return end;
	wipe(mog.list);
	wipe(mog.display);
	if mog.selected == "wl" then
		for k,v in pairs(mog.char.wishlist.display) do
			table.insert(mog.list,k);
			mog.display[k] = v;
		end
		table.sort(mog.list,function(a,b)
			if mog.char.wishlist.time[a] == mog.char.wishlist.time[b] then
				return a > b;
			else
				return mog.char.wishlist.time[a] > mog.char.wishlist.time[b];
			end
		end);
	else
		for k,v in ipairs(mog.selected.items) do
			if mog.filterLevel(v) and mog.filterFaction(v) and mog.filterClass(v) and mog.filterSlot(v) and mog.filterSource(v) and mog.filterQuality(v) then
				local disp = mog.filters.display[v];
				if not mog.display[disp] then
					mog.display[disp] = v;
					tinsert(mog.list,disp);
				elseif type(mog.display[disp]) == "table" then
					tinsert(mog.display[disp],v);
				else
					mog.display[disp] = {mog.display[disp],v};
				end
			end
		end
	end
	mog.sort();
	mog.scroll:update(top and 1);
	if show then
		mog.grid:Show();
	end
end

function mog.filterLevel(v)
	return ((mog.filters.lvl[v] or 0) >= mog.filt._minlvl) and ((mog.filters.lvl[v] or 0) <= mog.filt._maxlvl);
end

function mog.filterFaction(v)
	return (not mog.filters.faction[v]) or (mog.filters.faction[v] == 1 and mog.filt._alliance) or (mog.filters.faction[v] == 2 and mog.filt._horde);
end

function mog.filterClass(v)
	return (not mog.filters.class[v]) or (band(mog.filters.class[v],mog.filt._class) > 0); 
end

function mog.filterSlot(v)
	return (not mog.filters.slot[v]) or mog.filt._slots[mog.filters.slot[v]];
end

function mog.filterSource(v)
	return (not mog.filters.source[v]) or mog.filt._sources[mog.filters.source[v]];
end

function mog.filterQuality(v)
	return (not mog.filters.quality[v]) or mog.filt._quality[mog.filters.quality[v]];
end

local colourCache = {};
local itemCache = {};
function mog.sort()
	wipe(colourCache);
	wipe(itemCache);
	if mog.sorting == "level" then
		table.sort(mog.list,function(a,b)
			local aI,bI = mog.minItem(a),mog.minItem(b);
			if mog.filters.lvl[aI] == mog.filters.lvl[bI] then
				return aI > bI;
			else
				return (mog.filters.lvl[aI] or 0) > (mog.filters.lvl[bI] or 0);
			end
		end);
	elseif mog.sorting == "colour" then
		table.sort(mog.list,function(a,b)
			local aS,bS = mog.colourScore(a),mog.colourScore(b);
			if aS == bS then
				return mog.minItem(a) > mog.minItem(b);
			else
				return aS < bS;
			end
		end);
	end
end

function mog.colourScore(display)
	if not colourCache[display] then
		--local d1,d2;
		local distance = 195075;
		for i=1,3 do
			if mog.filters.colours[i][display] then
				local r,g,b = mog.filters.colours[i][display]:match("^(..)(..)(..)$");
				r = tonumber(r,16);
				g = tonumber(g,16);
				b = tonumber(b,16);
				local dist = ((mog.cR-r)^2)+((mog.cG-g)^2)+((mog.cB-b)^2);
				if dist < distance then
					distance = dist;
				end
				--[[if (not d1) or dist < d1 then
					d2 = d1 or dist;
					d1 = dist;
				elseif dist < d2 then
					d2 = dist;
				end--]]
			else
				break;
			end
		end
		--local distance = (195075-(d1 or 195075))^2+(195075-(d2 or 195075))^2;
		colourCache[display] = distance;
	end
	return colourCache[display];
end

function mog.minItem(display)
	if not itemCache[display] then
		if type(mog.display[display]) == "table" then
			for k,v in ipairs(mog.display[display]) do
				if (not itemCache[display]) or (not mog.filters.lvl[itemCache[display]]) or (mog.filters.lvl[v] and (mog.filters.lvl[v] < mog.filters.lvl[itemCache[display]])) then
					itemCache[display] = v;
				end
			end
		else
			itemCache[display] = mog.display[display];
		end
	end
	return itemCache[display];
end

mog.grid.sorting = mog.grid.topbar:CreateFontString(nil,"ARTWORK","GameFontHighlightSmall");
mog.grid.sorting:SetPoint("RIGHT",mog.grid.topbar,"RIGHT",-125,0);
mog.grid.sorting:SetText(L["Sort by:"]);

mog.cR,mog.cG,mog.cB = 255,255,255;
mog.sorting = "level";
mog.grid.sort = CreateFrame("Frame","MogItGridSortDropdown",mog.grid,"UIDropDownMenuTemplate");
mog.grid.sort:SetPoint("RIGHT",mog.grid.topbar,"RIGHT",16,-2);
UIDropDownMenu_SetWidth(mog.grid.sort,105);
UIDropDownMenu_SetButtonWidth(mog.grid.sort,120);
UIDropDownMenu_JustifyText(mog.grid.sort,"LEFT");
UIDropDownMenu_SetText(mog.grid.sort,LEVEL);
function mog.grid.sort:initialize()
	local info;
	info = UIDropDownMenu_CreateInfo();
	info.text = LEVEL;
	info.value = "level";
	info.func = function(self)
		mog.sorting = self.value;
		UIDropDownMenu_SetText(mog.grid.sort,LEVEL);
	end
	info.checked = mog.sorting == "level";
	UIDropDownMenu_AddButton(info);
	
	info = UIDropDownMenu_CreateInfo();
	info.text =	L["Approximate Colour"];
	info.value = "colour";
	info.func = function(self)
		mog.sorting = self.value;
		UIDropDownMenu_SetText(mog.grid.sort,L["Approximate Colour"]);
	end
	info.checked = mog.sorting == "colour";
	info.hasColorSwatch = true;
	info.r = mog.cR/255;
	info.g = mog.cG/255;
	info.b = mog.cB/255;
	info.swatchFunc = function()
		if not ColorPickerFrame:IsShown() then
			local r,g,b = ColorPickerFrame:GetColorRGB();
			mog.cR,mog.cG,mog.cB = r*255,g*255,b*255;
			mog.sorting = "colour";
			UIDropDownMenu_SetText(mog.grid.sort,L["Approximate Colour"]);
			mog.sort();
			mog.scroll:update();
		end
	end
	--[[info.cancelFunc = function(prev)
		mog.cR,mog.cG,mog.cB = prev.r*255,prev.g*255,prev.b*255;
	end--]]
	UIDropDownMenu_AddButton(info);
end

function mog.updateTooltip(self)
	mog.over = self;
	GameTooltip:SetOwner(self,"ANCHOR_RIGHT");
	--GameTooltip:ClearLines();
	local name,link = GetItemInfo(self.item);
	--GameTooltip:AddLine(self.display,1,1,1);
	--GameTooltip:AddLine(" ");
	GameTooltip:AddDoubleLine(link or ("["..(name or UNKNOWN).."]"),((type(self.list) == "table") and L["Item %d/%d"]:format(self.cycle,#self.list)),1,0,0,1,0,0);
	if mog.filters.source[self.item] then
		GameTooltip:AddDoubleLine(L["Source:"],mog.source[mog.filters.source[self.item]],nil,nil,nil,1,1,1);
		if mog.filters.source[self.item] == 1 then -- Drop
			if mog.bosses[mog.filters.sourceid[self.item]] then
				GameTooltip:AddDoubleLine(BOSS..":",mog.bosses[mog.filters.sourceid[self.item]],nil,nil,nil,1,1,1);
			end
		--elseif mog.filters.source[self.item] == 3 then -- Quest
		elseif mog.filters.source[self.item] == 5 then -- Crafted
			if mog.filters.sourceinfo[self.item] then
				GameTooltip:AddDoubleLine(L["Profession:"],mog.professions[mog.filters.sourceinfo[self.item]],nil,nil,nil,1,1,1);
			end
		elseif mog.filters.source[self.item] == 6 then -- Achievement
			if mog.filters.sourceid[self.item] then
				local _,name = GetAchievementInfo(mog.filters.sourceid[self.item]);
				GameTooltip:AddDoubleLine(L["Achievement"]..":",name,nil,nil,nil,1,1,1);
			end
		end
	end
	if mog.filters.zone[self.item] then
		local zone = GetMapNameByID(mog.filters.zone[self.item]);
		if mog.filters.source[self.item] == 1 and mog.diffs[mog.filters.sourceinfo[self.item]] then
			zone = zone.." ("..mog.diffs[mog.filters.sourceinfo[self.item]]..")";
		end
		GameTooltip:AddDoubleLine(ZONE..":",zone,nil,nil,nil,1,1,1);
	end
	
	GameTooltip:AddLine(" ");
	GameTooltip:AddDoubleLine(ID..":",self.item,nil,nil,nil,1,1,1);
	if mog.filters.lvl[self.item] then
		GameTooltip:AddDoubleLine(LEVEL..":",mog.filters.lvl[self.item],nil,nil,nil,1,1,1);
	end
	if mog.filters.faction[self.item] then
		GameTooltip:AddDoubleLine(FACTION..":",(mog.filters.faction[self.item] == 1 and FACTION_ALLIANCE or FACTION_HORDE),nil,nil,nil,1,1,1);
	end
	if mog.filters.class[self.item] and mog.filters.class[self.item] > 0 then
		local str;
		for k,v in pairs(mog.classBits) do
			if band(mog.filters.class[self.item],v) > 0 then
				if str then
					str = str..", "..string.format("\124cff%.2x%.2x%.2x",RAID_CLASS_COLORS[k].r*255,RAID_CLASS_COLORS[k].g*255,RAID_CLASS_COLORS[k].b*255)..mog.classes[k].."\124r";
				else
					str = string.format("\124cff%.2x%.2x%.2x",RAID_CLASS_COLORS[k].r*255,RAID_CLASS_COLORS[k].g*255,RAID_CLASS_COLORS[k].b*255)..mog.classes[k].."\124r";
				end
			end
		end
		GameTooltip:AddDoubleLine(CLASS..":",str,nil,nil,nil,1,1,1);
	end
	if mog.filters.slot[self.item] then
		GameTooltip:AddDoubleLine(L["Slot:"],mog.slots[mog.filters.slot[self.item]],nil,nil,nil,1,1,1);
	end
	
	GameTooltip:AddLine(" ");
	GameTooltip:AddLine(CONTROLS_LABEL);
	GameTooltip:AddDoubleLine(L["Scroll through list"],L["Scroll wheel"],0,1,0,1,1,1);
	GameTooltip:AddDoubleLine(L["Change item"],L["Left click"],0,1,0,1,1,1);
	GameTooltip:AddDoubleLine(L["Chat link"],L["Shift + Left click"],0,1,0,1,1,1);
	GameTooltip:AddDoubleLine(L["Try on"],L["Ctrl + Left click"],0,1,0,1,1,1);
	GameTooltip:AddDoubleLine(mog.wishlist.display[self.display] and L["Delete from wishlist"] or L["Add to wishlist"],L["Right click"],0,1,0,1,1,1);
	GameTooltip:AddDoubleLine(L["Item URL"],L["Shift + Right click"],0,1,0,1,1,1);
	GameTooltip:AddDoubleLine(L["Add to control model"],L["Ctrl + Right click"],0,1,0,1,1,1);
	GameTooltip:Show();
	GameTooltip:ClearAllPoints();
	GameTooltip:SetPoint("TOPRIGHT",mog.frame,"BOTTOMRIGHT",0,-35);
end