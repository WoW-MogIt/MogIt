local MogIt,mog = ...;
local L = mog.L;


mog.models = {};
mog.bin = {};
mog.posX = 0;
mog.posY = 0;
mog.posZ = 0;
mog.face = 0;


--// mog.frame
mog.frame:SetPoint("CENTER",UIParent,"CENTER");
mog.frame:SetSize(252,108);
mog.frame:SetToplevel(true);
mog.frame:SetClampedToScreen(true);
mog.frame:EnableMouse(true);
mog.frame:EnableMouseWheel(true);
mog.frame:SetMovable(true);
mog.frame:SetResizable(true);
mog.frame:SetUserPlaced(true);
mog.frame:SetScript("OnMouseDown",mog.frame.StartMoving);
mog.frame:SetScript("OnMouseUp",mog.frame.StopMovingOrSizing);
mog.frame:SetScript("OnShow",function(self)
	mog.modelUpdater:Show();
end);
mog.frame:SetScript("OnHide",function(self)
	if not mog.view:IsShown() then
		mog.modelUpdater:Hide();
	end
end);
tinsert(UISpecialFrames,"MogItFrame");

mog.frame.TitleText:SetText("MogIt");
mog.frame.TitleText:SetPoint("RIGHT",mog.frame,"RIGHT",-28,0);
mog.frame.portrait:SetTexture("Interface\\AddOns\\MogIt\\Images\\MogIt");
mog.frame.portrait:SetTexCoord(0,106/128,0,105/128);
MogItFrameBg:SetVertexColor(0.8,0.3,0.8);

mog.frame.resize = CreateFrame("Frame",nil,mog.frame);
mog.frame.resize:SetSize(16,16);
mog.frame.resize:SetPoint("BOTTOMRIGHT",mog.frame,"BOTTOMRIGHT",-4,3);
mog.frame.resize:EnableMouse(true);
function mog.frame.resize.update(self)
	mog.db.profile.width = floor((mog.frame:GetWidth()+5-(4+10)-(10+18+4))/mog.db.profile.columns)-5;
	mog.db.profile.height = floor((mog.frame:GetHeight()+5-(60+10)-(10+26))/mog.db.profile.rows)-5;
	mog:UpdateGUI(true);
end
mog.frame.resize:SetScript("OnMouseDown",function(self)
	mog.frame:SetMinResize(510,350);
	mog.frame:SetMaxResize(GetScreenWidth(),GetScreenHeight());
	mog.frame:StartSizing();
	self:SetScript("OnUpdate",self.update);
end);
mog.frame.resize:SetScript("OnMouseUp",function(self)
	mog.frame:StopMovingOrSizing();
	self:SetScript("OnUpdate",nil);
end);
mog.frame.resize:SetScript("OnHide",mog.frame.resize:GetScript("OnMouseUp"));
mog.frame.resize.texture = mog.frame.resize:CreateTexture(nil,"OVERLAY");
mog.frame.resize.texture:SetTexture("Interface\\AddOns\\MogIt\\Images\\Resize");
mog.frame.resize.texture:SetAllPoints(mog.frame.resize);

mog.frame.path = mog.frame:CreateFontString(nil,"ARTWORK","GameFontHighlightSmall");
mog.frame.path:SetPoint("BOTTOMLEFT",mog.frame,"BOTTOMLEFT",17,10);

mog.frame.page = mog.frame:CreateFontString(nil,"ARTWORK","GameFontHighlightSmall");
mog.frame.page:SetPoint("BOTTOMRIGHT",mog.frame,"BOTTOMRIGHT",-17,10);
--//


--// Toolbar
mog.menu = CreateFrame("Frame","MogItMenu",mog.frame);
mog.menu.displayMode = "MENU";
mog.menu.initialize = function(self,level)
	if mog.menu.active and mog.menu.active.func then
		mog.menu.tier[level] = UIDROPDOWNMENU_MENU_VALUE;
		mog.menu.active.func(level);
	end
end
mog.menu.tier = {};

local function menuOnClick(self,btn)
	if mog.menu.active ~= self then
		HideDropDownMenu(1);
	end
	mog.menu.active = self;
	if self.func then
		ToggleDropDownMenu(1,nil,mog.menu,self,0,0,self,self);
	end
end

local function menuOnEnter(self)
	if mog.menu.active ~= self and mog.IsDropdownShown(mog.menu) then
		HideDropDownMenu(1);
		if self.func then
			mog.menu.active = self;
			ToggleDropDownMenu(1,nil,mog.menu,self,0,0,self,self);
		end
	end
	self.nt:SetTexture(1,0.82,0,1);
end

local function menuOnLeave(self)
	self.nt:SetTexture(0,0,0,0);
end

function mog.CreateMenu(parent,label,func)
	local f = CreateFrame("Button",nil,parent);
	f:SetText(label);
	f:SetNormalFontObject(GameFontNormal);
	f:SetHighlightFontObject(GameFontBlack);
	f:SetSize(f:GetFontString():GetStringWidth()+10,f:GetFontString():GetStringHeight()+10);
	
	f.nt = f:CreateTexture(nil,"BACKGROUND");
	--nt:SetTexture(0.8,0.3,0.8,1);
	f.nt:SetTexture(0,0,0,0);
	f.nt:SetAllPoints(f);
	f:SetNormalTexture(f.nt);
	
	f.func = func;
	f:SetScript("OnClick",menuOnClick);
	f:SetScript("OnEnter",menuOnEnter);
	f:SetScript("OnLeave",menuOnLeave);
	
	return f;
end
--//


--// Modules Menu
mog.menu.modules = mog.CreateMenu(mog.frame,L["Modules"],function(tier)
	if tier == 1 then
		local info;
		info = UIDropDownMenu_CreateInfo();
		info.text = L["Base Modules"];
		info.isTitle = true;
		info.notCheckable = true;
		info.justifyH = "CENTER";
		UIDropDownMenu_AddButton(info,tier);
		
		for k,v in ipairs(mog.moduleList) do
			if v.base and v.Dropdown then
				v:Dropdown(tier);
			end
		end
		
		info = UIDropDownMenu_CreateInfo();
		info.isTitle = true;
		info.notCheckable = true;
		UIDropDownMenu_AddButton(info,tier);
		
		info = UIDropDownMenu_CreateInfo();
		info.text = L["Extra Modules"];
		info.isTitle = true;
		info.notCheckable = true;
		info.justifyH = "CENTER";
		UIDropDownMenu_AddButton(info,tier);
		
		for k,v in ipairs(mog.moduleList) do
			if (not v.base) and v.Dropdown then
				v:Dropdown(tier);
			end
		end
	elseif mog.menu.tier[2] and mog.menu.tier[2].Dropdown then
		mog.menu.tier[2]:Dropdown(tier);
	end
end);
mog.menu.modules:SetPoint("TOPLEFT",mog.frame,"TOPLEFT",62,-31);
--//


--// Catalogue Menu
function mog:ToggleFilters()
	if mog.filt:IsShown() then
		mog.filt:Hide();
	else
		mog.filt:Show();
	end
end

mog.sorting = {};

mog.menu.catalogue = mog.CreateMenu(mog.frame,L["Catalogue"],function(tier)
	if tier == 1 then
		local info;
		info = UIDropDownMenu_CreateInfo();
		info.text = mog.filt:IsShown() and L["Hide Filters"] or L["Show Filters"];
		info.notCheckable = true;
		info.func = mog.ToggleFilters;
		UIDropDownMenu_AddButton(info,tier);
		
		info = UIDropDownMenu_CreateInfo();
		info.text = L["Sorting"];
		info.value = "sorting";
		info.notCheckable = true;
		info.disabled = not (mog.active and mog.active.sorting and #mog.active.sorting > 0);
		UIDropDownMenu_AddButton(info,tier);
	elseif mog.menu.tier[2] == "sorting" then
		if tier == 2 then
			if mog.active and mog.active.sorting then
				for k,v in ipairs(mog.active.sorting) do
					if mog.sorting[v] and mog.sorting[v].Dropdown then
						mog.sorting[v].Dropdown(mog.active,tier);
					end
				end
			end
		elseif mog.menu.tier[3] and mog.menu.tier[3].Dropdown then
			mog.menu.tier[3].Dropdown(mog.active,tier);
		end
	end
end);
mog.menu.catalogue:SetPoint("LEFT",mog.menu.modules,"RIGHT",5,0);
--//


--// Preview Menu
mog.menu.preview = mog.CreateMenu(mog.frame,L["Preview"],function(tier)
	
end);
mog.menu.preview:SetPoint("LEFT",mog.menu.catalogue,"RIGHT",5,0);
--//


--// Options Menu
function mog:ToggleOptions()
	if not mog.options then
		mog.createOptions();
	end
	InterfaceOptionsFrame_OpenToCategory(MogIt);
end

mog.menu.options = mog.CreateMenu(mog.frame,L["Options"]);
mog.menu.options:SetScript("OnClick",mog.ToggleOptions);
mog.menu.options:SetPoint("LEFT",mog.menu.preview,"RIGHT",5,0);
--//


--// Scroll Frame
mog.scroll = CreateFrame("Slider","MogItScroll",mog.frame,"UIPanelScrollBarTrimTemplate");
mog.scroll:Hide();
mog.scroll:SetPoint("TOPRIGHT",mog.frame.Inset,"TOPRIGHT",1,-17);
mog.scroll:SetPoint("BOTTOMRIGHT",mog.frame.Inset,"BOTTOMRIGHT",1,16);
mog.scroll:SetValueStep(1);
mog.scroll:SetScript("OnValueChanged",function(self,value)
	self:update(nil,nil,value);
end);

mog.scroll.up = MogItScrollScrollUpButton;
mog.scroll.down = MogItScrollScrollDownButton;
mog.scroll.up:SetScript("OnClick",function(self)
	mog.scroll:update(nil,-1);
end);
mog.scroll.down:SetScript("OnClick",function(self)
	mog.scroll:update(nil,1);
end);

function mog.scroll.update(self,value,offset,onscroll)
	local models = #mog.models;
	local total = ceil(#mog.list/models);
	
	if onscroll then
		value = onscroll;
	else
		if total > 0 then
			self:SetMinMaxValues(1,total);
		end
		if total > 1 then
			self:Show();
		else
			self:Hide();
		end
		
		local old = self:GetValue();
		value = (value or old or 1) + (offset or 0);
		if value ~= old then
			self:SetValue(value);
			return;
		end
	end

	if value == 1 then
		self.up:Disable();
	else
		self.up:Enable();
	end
	if value == total then
		self.down:Disable();
	else
		self.down:Enable();
	end
	
	if mog.IsDropdownShown(mog.Item_Menu) or mog.IsDropdownShown(mog.Set_Menu) then
		HideDropDownMenu(1);
	end
	
	if mog.active and mog.active.OnScroll then
		mog.active:OnScroll();
	end
	
	local owner = GameTooltip:IsShown() and GameTooltip:GetOwner();	
	local id,frame,index;
	for id,frame in ipairs(mog.models) do
		index = ((value-1)*models)+id;
		if mog.list[index] then
			wipe(frame.data);
			frame.data.index = index;
			for k, v in pairs(frame.indicators) do
				v:Hide();
			end
			if frame:IsShown() then
				mog:ModelUpdate(frame);
				if owner == frame then
					mog.ModelOnEnter(frame);
				end
			else
				frame:Show();
			end
		else
			frame:Hide();
		end
	end
	
	if total > 0 then
		mog.frame.page:SetText(MERCHANT_PAGE_NUMBER:format(value,total));
		mog.frame.page:Show();
	else
		mog.frame.page:Hide();
	end
end

mog.frame:SetScript("OnMouseWheel",function(self,offset)
	mog.scroll:update(nil,offset > 0 and -1 or 1);
end);

function mog:UpdateScroll(value,offset)
	mog.scroll:update(value,offset);
end

function mog:ModelUpdate(frame)
	if mog.active and mog.active.FrameUpdate then
		mog.active:FrameUpdate(frame,mog.list[frame.data.index]);
	end
end
--//


--// Model Positioning
function mog:IsModelSynced(model)
	return (model == true) or (model and (not model.nosync) and (model.type == "catalogue" or (mog.db.profile.sync and model.type == "preview")));
end

function mog:PositionModel(model,posX,posY,posZ,face)
	model.model:SetFacing(face);
	if model.model:IsVisible() then
		model.model:SetPosition(posZ,posX,posY);
	end
end

function mog:GetModelPosition(model)
	local data = mog:IsModelSynced(model) and mog or model;
	return (data.posX or mog.posX or 0),(data.posY or mog.posY or 0),(data.posZ or mog.posZ or 0),(data.face or mog.face or 0);
end

function mog:SetModelPosition(model,posX,posY,posZ,face,delta)
	local data = mog:IsModelSynced(model) and mog or model;
	if data then
		data.posX = delta and ((data.posX or 0) + (posX or 0)) or posX or data.posX or mog.posX or 0;
		data.posY = delta and ((data.posY or 0) + (posY or 0)) or posY or data.posY or mog.posY or 0;
		data.posZ = delta and ((data.posZ or 0) + (posZ or 0)) or posZ or data.posZ or mog.posZ or 0;
		data.face = delta and ((data.face or 0) + (face or 0)) or face or data.face or mog.face or 0;
	end
	if not model then
		for k,v in ipairs(mog.models) do
			if not mog:IsModelSynced(v) then
				mog:SetModelPosition(v,posX,posY,posZ,face,delta);
			end
		end
		for k,v in ipairs(mog.view.frames) do
			v = v.model;
			if not mog:IsModelSynced(v) then
				mog:SetModelPosition(v,posX,posY,posZ,face,delta);
			end
		end
	end
end

function mog:UpdateModelPosition(model)
	if model and (model ~= true) then
		mog:PositionModel(model,mog:GetModelPosition(model));
	else
		for k,v in ipairs(mog.models) do
			if mog:IsModelSynced(v) then
				if (model == true) then
					mog:UpdateModelPosition(v);
				end
			elseif (not model) then
				mog:UpdateModelPosition(v);
			end
		end
		for k,v in ipairs(mog.view.frames) do
			v = v.model;
			if mog:IsModelSynced(v) then
				if (model == true) then
					mog:UpdateModelPosition(v);
				end
			elseif (not model) then
				mog:UpdateModelPosition(v);
			end
		end
	end
end

mog.modelUpdater = CreateFrame("Frame",nil,UIParent);
mog.modelUpdater:Hide();
mog.modelUpdater.elapsed = 0;
mog.modelUpdater:SetScript("OnUpdate",function(self,elapsed)
	self.elapsed = self.elapsed + elapsed;
	if self.elapsed < 0.05 then return end;
	
	local sync;
	if self.model then
		sync = mog:IsModelSynced(self.model);
		local cx,cy = GetCursorPosition();
		if self.btn == "LeftButton" then
			mog:SetModelPosition(self.model,nil,nil,(cy-self.py)/50,(cx-self.px)/50,true);
		elseif self.btn == "RightButton" then
			mog:SetModelPosition(self.model,(cx-self.px)/50,(cy-self.py)/50,nil,nil,true);
		end
		self.px,self.py = cx,cy;
	end
	
	if mog.db.profile.rotateSynced then
		mog:SetModelPosition(true,nil,nil,nil,self.elapsed,true);
		mog:UpdateModelPosition(true);
	elseif self.model and sync then
		mog:UpdateModelPosition(true);
	end
	
	if mog.db.profile.rotateNoSynced then
		mog:SetModelPosition(false,nil,nil,nil,self.elapsed,true);
		mog:UpdateModelPosition(false);
	elseif self.model and (not sync) then
		mog:UpdateModelPosition(false);
	end
	
	--56, 108, 237, 238, 239, 243, 249, 250, 251, 252, 253, 254, 255
	if mog.db.profile.noAnim then
		for k,v in ipairs(mog.models) do
			v.model:SetSequence(254);
		end
		for k,v in ipairs(mog.view.frames) do
			v.model.model:SetSequence(254);
		end
	end
	
	self.elapsed = 0;
end);

function mog:StartModelUpdater(model,btn)
	mog.modelUpdater.btn = btn;
	mog.modelUpdater.model = model;
	mog.modelUpdater.px,mog.modelUpdater.py = GetCursorPosition();
end

function mog:StopModelUpdater()
	mog.modelUpdater.btn = nil;
	mog.modelUpdater.model = nil;
end
--//


--// Indicators
mog.indicators = {};

function mog.CreateModelIndicator(model,name)
	if model.indicators[name] then return end;
	model.indicators[name] = CreateFrame("Frame",nil,model);
	mog.indicators[name](model,model.indicators[name]);
end

function mog:CreateIndicator(name,func)
	if mog.indicators[name] then return end;
	mog.indicators[name] = func;
	for k,v in ipairs(mog.models) do
		mog.CreateModelIndicator(v,name);
	end
end

function mog:ShowIndicator(model,name)
	if model.indicators[name] then
		model.indicators[name]:Show();
	end
end

function mog:GetIndicator(model,name)
	return model.indicators[name];
end
--//


--// Model Frames
function mog:CreateModel(view)
	local f;
	if (not view) and mog.bin[1] then
		f = mog.bin[1];
		tremove(mog.bin,1);
	else
		f = CreateFrame("Button",nil,view and mog.view or mog.frame);
		f:Hide();
		f.type = view and "preview" or "catalogue";
		f.data = {};
		
		f:SetScript("OnShow",mog.ModelOnShow);
		f:SetScript("OnHide",mog.ModelOnHide);
		--f:SetScript("OnUpdate",mog.ModelOnUpdate);
		
		f:RegisterForDrag("LeftButton","RightButton");
		f:SetScript("OnDragStart",mog.ModelOnDragStart);
		f:SetScript("OnDragStop",mog.ModelOnDragStop);
		
		f.model = CreateFrame("DressUpModel",nil,f);
		f.model:SetAllPoints(f);
		f.model:SetUnit("PLAYER");
		f.model:SetModelScale(2);
		f.model:SetPosition(0,0,0);
		f.model.parent = f;
		
		f.bg = f:CreateTexture(nil,"BACKGROUND");
		f.bg:SetAllPoints(f);
		f.bg:SetTexture(0.3,0.3,0.3,0.2);
		
		if not view then
			f:RegisterForClicks("AnyUp");
			f:SetScript("OnClick",mog.ModelOnClick);
			f:SetScript("OnEnter",mog.ModelOnEnter);
			f:SetScript("OnLeave",mog.ModelOnLeave);
			
			f.indicators = {};
			for k,v in pairs(mog.indicators) do
				mog.CreateModelIndicator(f,k);
			end
		end
	end
	if not view then
		tinsert(mog.models,f);
	end
	return f;
end

function mog:DeleteModel(f)
	mog.models[f]:Hide();
	tinsert(mog.bin,mog.models[f]);
	tremove(mog.models,f);
end

function mog.ModelOnShow(self)
	mog:UpdateModelPosition(self);
	local lvl = self:GetParent():GetFrameLevel();
	if self:GetFrameLevel() <= lvl then
		self:SetFrameLevel(lvl+1);
	end
	if self == mog.view.model then
		self.model:Undress();
		mog:DressModel(self.model);
	else
		mog:ModelUpdate(self);
	end
end

function mog.ModelOnHide(self)
	if mog.modelUpdater.model == self then
		mog:StopModelUpdater();
	end
	self.model:SetPosition(0,0,0);
end

function mog.ModelOnClick(self,btn,...)
	if mog.active and mog.active.OnClick then
		mog.active:OnClick(self,btn,mog.list[self.data.index],...);
	end
end

function mog.ModelOnDragStart(self,btn)
	mog:StartModelUpdater(self,btn);
end

function mog.ModelOnDragStop(self,btn)
	mog:StopModelUpdater();
end

function mog.ModelOnEnter(self,...)
	if mog.active and mog.active.OnEnter then
		mog.active:OnEnter(self,mog.list[self.data.index],...);
	end
end

function mog.ModelOnLeave(self,...)
	if mog.active and mog.active.OnLeave then
		mog.active:OnLeave(self,...);
	else
		GameTooltip:Hide();
	end
end
--//


--// GUI
function mog:UpdateGUI(resize)
	local rows,columns = mog.db.profile.rows,mog.db.profile.columns;
	local total = rows*columns;
	local current = #mog.models;
	local width,height = mog.db.profile.width,mog.db.profile.height;
	
	if not resize then
		if current > total then
			for i=current,(total+1),-1 do
				mog:DeleteModel(i);
			end
		elseif current < total then
			for i=(current+1),total,1 do
				mog:CreateModel();
			end
		end
		mog.frame:SetSize(((width+5)*columns)-5+(4+10)+(10+18+4),((height+5)*rows)-5+(60+10)+(10+26));
		if mog.frame:IsShown() then
			mog.scroll:update();
		end
	end
	
	for row=1,rows do
		for column=1,columns do
			local n = ((row-1)*columns)+column;
			if not resize then
				if n==1 then
					mog.models[n]:SetPoint("TOPLEFT",mog.frame.Inset,"TOPLEFT",10,-10);
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
--//



















--[[
			local label = f:CreateFontString(nil, nil, "GameFontNormalLarge");
			label:SetPoint("TOPLEFT", 16, -16);
			label:SetPoint("BOTTOMRIGHT", -16, 16);
			label:SetJustifyV("BOTTOM");
			label:SetJustifyH("CENTER");
			label:SetNonSpaceWrap(true);
			f.indicators.label = label;
			
			local hasItem = f:CreateTexture();
			hasItem:SetTexture("Interface\\RaidFrame\\ReadyCheck-Ready");
			hasItem:SetSize(32, 32);
			hasItem:SetPoint("BOTTOMRIGHT", -8, 8);
			f.indicators.hasItem = hasItem;
			
			local wishlist = f:CreateTexture();
			wishlist:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_1");
			wishlist:SetSize(32, 32);
			wishlist:SetPoint("TOPRIGHT", -8, -8);
			f.indicators.wishlist = wishlist;
			
			
			
			
			
			
						-- f.c1Bg = f:CreateTexture()
			-- f.c1Bg:SetTexture(0, 0, 0)
			-- f.c1Bg:SetSize(32, 32)
			-- f.c1Bg:SetPoint("BOTTOM", 0, 8)
			-- f.c1 = f:CreateTexture()
			-- f.c1:SetPoint("TOPLEFT", f.c1Bg, 4, -4)
			-- f.c1:SetPoint("BOTTOMRIGHT", f.c1Bg, -4, 4)
			
			-- f.c2Bg = f:CreateTexture()
			-- f.c2Bg:SetTexture(0, 0, 0)
			-- f.c2Bg:SetSize(32, 32)
			-- f.c2Bg:SetPoint("RIGHT", f.c1Bg, "LEFT", -8, 0)
			-- f.c2 = f:CreateTexture()
			-- f.c2:SetPoint("TOPLEFT", f.c2Bg, 4, -4)
			-- f.c2:SetPoint("BOTTOMRIGHT", f.c2Bg, -4, 4)
			
			-- f.c3Bg = f:CreateTexture()
			-- f.c3Bg:SetTexture(0, 0, 0)
			-- f.c3Bg:SetSize(32, 32)
			-- f.c3Bg:SetPoint("LEFT", f.c1Bg, "RIGHT", 8, 0)
			-- f.c3 = f:CreateTexture()
			-- f.c3:SetPoint("TOPLEFT", f.c3Bg, 4, -4)
			-- f.c3:SetPoint("BOTTOMRIGHT", f.c3Bg, -4, 4)
			--]]