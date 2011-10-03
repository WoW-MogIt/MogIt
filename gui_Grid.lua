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

mog.frame:SetFrameLevel(mog.grid:GetFrameLevel()+5);

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
	mog.view.model.model:SetFacing(mog.face);
	if mog.view.model.model:IsVisible() then
		mog.view.model.model:SetPosition(mog.posZ,mog.posX,mog.posY);
	end
	for k,v in ipairs(mog.models) do
		v.model:SetFacing(mog.face);
		if v.model:IsVisible() then
			v.model:SetPosition(mog.posZ,mog.posX,mog.posY);
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
				self.cycle = (self.cycle < #self.list and (self.cycle + 1)) or 1;
				self.item = self.list[self.cycle];
				if self.MogItModel then
					self.model:TryOn(self.item);
				elseif self.MogItSlot then
					mog.view.model.model:TryOn(self.item);
					mog.view.setTexture(self.slot,select(10,GetItemInfo(self.item)));
					if mog.global.gridDress then
						mog.scroll:update();
					end
				end
				mog.itemTooltip(self);
			end
		end
	elseif btn == "RightButton" then
		if IsControlKeyDown() then
			if self.MogItSlot then
				mog.view.delItem(self.slot);
				mog.dressModel(mog.view.model.model);
				if mog.global.gridDress then
					mog.scroll:update();
				end
			else
				mog.view.addItem(self.item);
			end
		elseif IsShiftKeyDown() then
			StaticPopup_Show("MOGIT_URL",mog.global.url,nil,self.item);
		elseif type(self.display) == "table" then
			if self.display.set then
				StaticPopup_Show("MOGIT_DELSETCONFIRM",self.display.data.name,nil,{mog.selected.tbl,self.display.num});
			elseif self.display.item then
				table.remove(self.display.tbl,self.display.num);
				mog.buildList();
			end
		else
			table.insert(mog.wl.items,self.item);
		end
	end
end

function mog.dressModel(model)
	model:Undress();
	if mog.global.gridDress or (model == mog.view.model.model) then
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
		f = CreateFrame("Button",nil,view and mog.view or mog.grid);
		f:Hide();
				
		f:RegisterForDrag("LeftButton","RightButton");
		f:SetScript("OnDragStart",function(self,btn)
			mog.modelUpdater.btn = btn;
			mog.modelUpdater.model = self;
			mog.modelUpdater.prevx,mog.modelUpdater.prevy = GetCursorPosition();
			mog.modelUpdater:Show();
		end);
		f:SetScript("OnDragStop",function(self,btn)
			mog.modelUpdater:Hide();
			mog.modelUpdater.btn = nil;
			mog.modelUpdater.model = nil;
		end);
		
		f.model = CreateFrame("DressUpModel",nil,f);
		f.model:SetBackdrop({
			bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", 
			tile = true, tileSize = 16,
			insets = { left = 0, right = 0, top = 0, bottom = 0 }
		});
		f.model:SetBackdropColor(0,0,0,0.6);
		f.model:SetModelScale(2);
		f.model:SetPosition(0,0,0);
		f.model:SetAllPoints(f);
		f.model.btn = f;
		
		f.model:SetScript("OnShow",function(self)
			self:SetPosition(mog.posZ,mog.posX,mog.posY);
			mog.dressModel(self);
		end);
		f.model:SetScript("OnHide",function(self)
			if mog.modelUpdater.model == self.btn then
				self.btn:GetScript("OnDragStop")(self.btn);
			end
			self:SetPosition(0,0,0);
		end);
		f.model:SetScript("OnUpdate",function(self)
			if mog.global.noAnim then
				self:SetSequence(3);
			end
		end);
		
		if not view then
			f.text = f.model:CreateFontString(nil,"OVERLAY","GameFontNormal");
			f.text:SetPoint("TOP",f,"TOP",0,-1);
			f.text:Hide();
			
			f.model:SetUnit("PLAYER");
			
			f:RegisterForClicks("AnyUp");
			f:SetScript("OnClick",mog.itemClick);
			f:SetScript("OnEnter",mog.itemTooltip);
			f:SetScript("OnLeave",function(self)
				GameTooltip:Hide();
			end);
			
			f:HookScript("OnShow",function(self)
				if self:GetFrameLevel() <= mog.grid:GetFrameLevel() then
					self:SetFrameLevel(mog.grid:GetFrameLevel()+1);
				end
			end);
			
			f.MogItModel = true;
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
	local owner = GameTooltip:IsShown() and GameTooltip:GetOwner();
	
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
			model.display = mog.list[index];
			model.list = mog.display[model.display];
			model.cycle = 1;
			model.item = type(model.list) == "table" and model.list[1] or model.list;
			if model:IsShown() then
				mog.dressModel(model.model);
			else
				model:Show();
			end
			if type(model.display) == "table" and model.display.set then
				model.text:Show();
				model.text:SetText(model.display.data.name);
				for k,v in ipairs(mog.itemSlots) do
					if model.display.data[k] and model.display.data[k][1] then
						model.model:TryOn(model.display.data[k][1]);
					end
				end
			else
				model.text:Hide();
				model.model:TryOn(model.item);
			end
			if owner == model then
				mog.itemTooltip(model);
			end
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
	if mog.selected.wl then
		if mog.selected.tbl == mog.char.wishlist or mog.selected.tbl == mog.global.wishlist then
			for k,v in ipairs(mog.selected.tbl.sets) do
				local data = {set=true,num=k,data=v};
				table.insert(mog.list,data);
				local disp = {};
				for x,y in ipairs(mog.itemSlots) do
					if v[x] then
						for a,b in ipairs(v[x]) do
							table.insert(disp,b);
						end
					end
				end
				mog.display[data] = disp;
			end
			for k,v in ipairs(mog.selected.tbl.items) do
				local data = {item=true,tbl=mog.selected.tbl.items,num=k};
				table.insert(mog.list,data);
				mog.display[data] = v;
			end
		else
			for k,v in ipairs(mog.itemSlots) do
				if mog.selected.tbl[mog.selected.num][k] then
					for x,y in ipairs(mog.selected.tbl[mog.selected.num][k]) do
						local data = {item=true,tbl=mog.selected.tbl[mog.selected.num][k],num=x};
						table.insert(mog.list,data);
						mog.display[data] = y;
					end
				end
			end
		end
		mog.grid.sort:Hide();
		mog.grid.sorting:Hide();
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
		mog.grid.sort:Show();
		mog.grid.sorting:Show();
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
	if not mog.filters.source[v] then
		return true;
	elseif mog.filt._sources[mog.filters.source[v]] then
		if mog.filters.source[v] == 1 then
			if not mog.filters.sourceinfo[v] then
				return mog.filt.sourceSub[1][7];
			elseif mog.filters.sourceinfo[v] == 7 then
				return mog.filt.sourceSub[1][3] or mog.filt.sourceSub[1][5];
			elseif mog.filters.sourceinfo[v] == 8 then
				return mog.filt.sourceSub[1][4] or mog.filt.sourceSub[1][6];
			else
				return mog.filt.sourceSub[1][mog.filters.sourceinfo[v]];
			end
		end
		return true;
	end
end

function mog.filterQuality(v)
	return (not mog.filters.quality[v]) or mog.filt._quality[mog.filters.quality[v]];
end

local colourCache = {};
local itemCache = {};
function mog.sort()
	wipe(colourCache);
	wipe(itemCache);
	if mog.selected.wl then
		
	elseif mog.sorting == "colour" then
		table.sort(mog.list,function(a,b)
			local aS,bS = mog.colourScore(a),mog.colourScore(b);
			if aS == bS then
				return mog.minItem(a) > mog.minItem(b);
			else
				return aS < bS;
			end
		end);
	elseif mog.sorting == "level" then
		table.sort(mog.list,function(a,b)
			local aI,bI = mog.minItem(a),mog.minItem(b);
			if mog.filters.lvl[aI] == mog.filters.lvl[bI] then
				return aI > bI;
			else
				return (mog.filters.lvl[aI] or 0) > (mog.filters.lvl[bI] or 0);
			end
		end);
	end
end

function mog.colourScore(display)
	if not colourCache[display] then
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

			else
				break;
			end
		end
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
mog.grid.sorting:SetPoint("RIGHT",mog.grid.topbar,"RIGHT",-145,0);
mog.grid.sorting:SetText(L["Sort by:"]);
mog.grid.sorting:Hide();

mog.cR,mog.cG,mog.cB = 255,255,255;
mog.sorting = "level";
mog.grid.sort = CreateFrame("Frame","MogItGridSortDropdown",mog.grid,"UIDropDownMenuTemplate");
mog.grid.sort:Hide();
mog.grid.sort:SetPoint("RIGHT",mog.grid.topbar,"RIGHT",16,-2);
UIDropDownMenu_SetWidth(mog.grid.sort,125);
UIDropDownMenu_SetButtonWidth(mog.grid.sort,140);
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
		mog.sort();
		mog.scroll:update();
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
	UIDropDownMenu_AddButton(info);
end

function mog.itemTooltip(self)
	local item = self.item;
	if type(item) ~= "number" then return end;
	GameTooltip:SetOwner(self,"ANCHOR_NONE");
	
	local name,link,_,_,_,_,_,_,_,texture = GetItemInfo(item);
	--GameTooltip:AddLine(self.display,1,1,1);
	--GameTooltip:AddLine(" ");
	GameTooltip:AddDoubleLine((texture and "\124T"..texture..":18\124t " or "")..(link or ("["..(name or UNKNOWN).."]")),(type(self.list) == "table") and (#self.list > 1) and L["Item %d/%d"]:format(self.cycle,#self.list),1,0,0,1,0,0);
	if mog.filters.source[item] then
		GameTooltip:AddDoubleLine(L["Source:"],mog.source[mog.filters.source[item]],nil,nil,nil,1,1,1);
		if mog.filters.source[item] == 1 then -- Drop
			if mog.bosses[mog.filters.sourceid[item]] then
				GameTooltip:AddDoubleLine(BOSS..":",mog.bosses[mog.filters.sourceid[item]],nil,nil,nil,1,1,1);
			end
		--elseif mog.filters.source[self.item] == 3 then -- Quest
		elseif mog.filters.source[item] == 5 then -- Crafted
			if mog.filters.sourceinfo[item] then
				GameTooltip:AddDoubleLine(L["Profession:"],mog.professions[mog.filters.sourceinfo[item]],nil,nil,nil,1,1,1);
			end
		elseif mog.filters.source[item] == 6 then -- Achievement
			if mog.filters.sourceid[item] then
				local _,name,_,complete = GetAchievementInfo(mog.filters.sourceid[item]);
				GameTooltip:AddDoubleLine(L["Achievement"]..":",name,nil,nil,nil,1,1,1);
				GameTooltip:AddDoubleLine(STATUS..":",complete and COMPLETE or INCOMPLETE,nil,nil,nil,1,1,1);
			end
		end
	end
	if mog.filters.zone[item] then
		local zone = GetMapNameByID(mog.filters.zone[item]);
		if zone then
			if mog.filters.source[item] == 1 and mog.diffs[mog.filters.sourceinfo[item]] then
				zone = zone.." ("..mog.diffs[mog.filters.sourceinfo[item]]..")";
			end
			GameTooltip:AddDoubleLine(ZONE..":",zone,nil,nil,nil,1,1,1);
		end
	end
	
	GameTooltip:AddLine(" ");
	GameTooltip:AddDoubleLine(ID..":",item,nil,nil,nil,1,1,1);
	if mog.filters.lvl[item] then
		GameTooltip:AddDoubleLine(LEVEL..":",mog.filters.lvl[item],nil,nil,nil,1,1,1);
	end
	if mog.filters.faction[item] then
		GameTooltip:AddDoubleLine(FACTION..":",(mog.filters.faction[item] == 1 and FACTION_ALLIANCE or FACTION_HORDE),nil,nil,nil,1,1,1);
	end
	if mog.filters.class[item] and mog.filters.class[item] > 0 then
		local str;
		for k,v in pairs(mog.classBits) do
			if band(mog.filters.class[item],v) > 0 then
				if str then
					str = str..", "..string.format("\124cff%.2x%.2x%.2x",RAID_CLASS_COLORS[k].r*255,RAID_CLASS_COLORS[k].g*255,RAID_CLASS_COLORS[k].b*255)..mog.classes[k].."\124r";
				else
					str = string.format("\124cff%.2x%.2x%.2x",RAID_CLASS_COLORS[k].r*255,RAID_CLASS_COLORS[k].g*255,RAID_CLASS_COLORS[k].b*255)..mog.classes[k].."\124r";
				end
			end
		end
		GameTooltip:AddDoubleLine(CLASS..":",str,nil,nil,nil,1,1,1);
	end
	if mog.filters.slot[item] then
		GameTooltip:AddDoubleLine(L["Slot:"],mog.slots[mog.filters.slot[item]],nil,nil,nil,1,1,1);
	end
	
	GameTooltip:Show();
	GameTooltip:ClearAllPoints();
	GameTooltip:SetPoint("TOPRIGHT",mog.frame,"BOTTOMRIGHT",0,-5);
end