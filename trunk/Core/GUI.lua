local MogIt,mog = ...;
local L = mog.L;

--.AddModel -> .frames
--SetModel? to fix pets?

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
tinsert(UISpecialFrames,"MogItFrame");

mog.frame.TitleText:SetText("MogIt");
mog.frame.TitleText:SetPoint("RIGHT",mog.frame,"RIGHT",-28,0);
mog.frame.portrait:SetTexture("Interface\\AddOns\\MogIt\\Images\\MogIt");
mog.frame.portrait:SetTexCoord(0,106/128,0,105/128);
--mog.frame.Inset.Bg:SetTexture("Interface\\AddOns\\MogIt\\Images\\Background");
--mog.frame.Inset.Bg:SetTexCoord(0,0.666015625,0,0.666015625);
MogItFrameBg:SetVertexColor(0.8,0.3,0.8);

mog.frame.resize = CreateFrame("Frame",nil,mog.frame);
mog.frame.resize:SetSize(16,16);
mog.frame.resize:SetPoint("BOTTOMRIGHT",mog.frame,"BOTTOMRIGHT",-4,3);
mog.frame.resize:EnableMouse(true);
function mog.frame.resize.update(self)
	mog.db.profile.width = floor((mog.frame:GetWidth()+5-(4+10)-(10+18+4))/mog.db.profile.columns)-5; -- needs updating
	mog.db.profile.height = floor((mog.frame:GetHeight()+5-(60+10)-(10+26))/mog.db.profile.rows)-5; -- needs updating
	mog.updateGUI(true);
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

mog.frame.module = mog.frame:CreateFontString(nil,"ARTWORK","GameFontNormal");
mog.frame.module:SetPoint("TOPLEFT",mog.frame,"TOPLEFT",62,-35);
mog.frame.module:SetText(L["Module"]..":");

mog.dropdown = CreateFrame("Frame","MogItDropdown",mog.frame,"UIDropDownMenuTemplate");
mog.dropdown:SetPoint("LEFT",mog.frame.module,"RIGHT",-12,-3);
UIDropDownMenu_SetWidth(mog.dropdown,175);
UIDropDownMenu_SetButtonWidth(mog.dropdown,190);
UIDropDownMenu_JustifyText(mog.dropdown,"LEFT");
UIDropDownMenu_SetText(mog.dropdown,L["Select a module"]);
local tier1;
function mog.dropdown:initialize(tier)
	if tier == 2 then
		tier1 = UIDROPDOWNMENU_MENU_VALUE;
	end
	
	if tier == 1 then
		local info;
		info = UIDropDownMenu_CreateInfo();
		info.text = L["Base Modules"];
		info.isTitle = true;
		info.notCheckable = true;
		info.justifyH = "CENTER";
		UIDropDownMenu_AddButton(info,tier);
		
		for k,v in ipairs(mog.modules.base) do
			if v.Dropdown then
				v:Dropdown(tier);
			end
		end
		
		if #mog.modules.extra > 0 then
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
		
			for k,v in ipairs(mog.modules.extra) do
				if v.Dropdown then
					v:Dropdown(tier);
				end
			end
		end
	elseif tier1.Dropdown then
		tier1:Dropdown(tier);
	end
end

mog.sorting = CreateFrame("Frame","MogItSorting",mog.frame,"UIDropDownMenuTemplate");
mog.sorting:SetPoint("TOPRIGHT",mog.frame,"TOPRIGHT",6,-28);
mog.sorting.label = mog.frame:CreateFontString(nil,"ARTWORK","GameFontNormal");
mog.sorting.label:SetPoint("RIGHT",mog.sorting,"LEFT",12,3);
mog.sorting.label:SetText(L["Sort by"]..":");
UIDropDownMenu_SetWidth(mog.sorting,110);
UIDropDownMenu_SetButtonWidth(mog.sorting,125);
UIDropDownMenu_JustifyText(mog.sorting,"LEFT");
UIDropDownMenu_SetText(mog.sorting,NONE);
UIDropDownMenu_DisableDropDown(mog.sorting);
function mog.sorting:initialize(tier)
	if mog.active and mog.active.sorting then
		for k,v in ipairs(mog.active.sorting) do
			if mog.sorting.sorts[v] and mog.sorting.sorts[v].Dropdown then
				mog.sorting.sorts[v].Dropdown(mog.active,tier);
			end
		end
	end
end

mog.frame.filters = CreateFrame("Button","MogItFrameFiltersButton",mog.frame,"MagicButtonTemplate");
mog.frame.filters:SetPoint("BOTTOMLEFT",mog.frame,"BOTTOMLEFT",5,5);
mog.frame.filters:SetWidth(100);
mog.frame.filters:SetText(FILTERS);
mog.frame.filters:SetScript("OnClick",function(self,btn)
	if mog.filt:IsShown() then
		mog.filt:Hide();
	else
		mog.filt:Show();
	end
end);

mog.frame.preview = CreateFrame("Button","MogItFramePreviewButton",mog.frame,"MagicButtonTemplate");
mog.frame.preview:SetPoint("TOPLEFT",mog.frame.filters,"TOPRIGHT");
mog.frame.preview:SetWidth(100);
mog.frame.preview:SetText(L["Preview"]);
mog.frame.preview:SetScript("OnClick",function(self,btn)
	if mog.view:IsShown() then
		HideUIPanel(mog.view);
	else
		ShowUIPanel(mog.view);
	end
end);

mog.frame.options = CreateFrame("Button","MogItFrameOptionsButton",mog.frame,"MagicButtonTemplate");
mog.frame.options:SetPoint("TOPLEFT",mog.frame.preview,"TOPRIGHT");
mog.frame.options:SetWidth(100);
mog.frame.options:SetText(MAIN_MENU);
mog.frame.options:SetScript("OnClick",function(self,btn)
	if not mog.options then
		mog.createOptions();
	end
	InterfaceOptionsFrame_OpenToCategory(MogIt);
end);

mog.frame.help = CreateFrame("Button","MogItFrameHelpButton",mog.frame,"MagicButtonTemplate");
mog.frame.help:SetPoint("TOPLEFT",mog.frame.options,"TOPRIGHT");
mog.frame.help:SetWidth(100);
mog.frame.help:SetText(L["Help"]);
mog.frame.help:Disable();
mog.frame.help:SetScript("OnEnter",function(self,btn)
	if mog.active and mog.active.Help then
		mog.active:Help(self);
	end
end);
mog.frame.help:SetScript("OnLeave",function(self,btn)
	GameTooltip:Hide();
end);

mog.frame.page = mog.frame:CreateFontString(nil,"ARTWORK","GameFontHighlightSmall");
mog.frame.page:SetPoint("BOTTOMRIGHT",mog.frame,"BOTTOMRIGHT",-17,10);

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
	
	if mog.active and mog.active.OnScroll then
		mog.active:OnScroll();
	end
	
	local owner = GameTooltip:IsShown() and GameTooltip:GetOwner();	
	local id,frame,index;
	for id,frame in ipairs(mog.models) do
		index = ((value-1)*models)+id;
		if mog.list[index] then
			frame.index = index;
			wipe(frame.data);
			frame.label:Hide();
			--frame.icon:Hide();
			if frame:IsShown() then
				mog.FrameUpdate(frame);
				if owner == frame then
					mog.OnEnter(frame);
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

mog.modelUpdater = CreateFrame("Frame",nil,UIParent);
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

function mog.addModel(view)
	local f;
	if not mog.view and mog.bin[1] then
		f = mog.bin[1];
		tremove(mog.bin,1);
	else
		f = CreateFrame("Button",nil,view and mog.view or mog.frame);
		
		f:SetScript("OnShow",mog.OnShow);
		f:SetScript("OnHide",mog.OnHide);
		f:SetScript("OnUpdate",mog.OnUpdate);
		
		f:RegisterForDrag("LeftButton","RightButton");
		f:SetScript("OnDragStart",mog.OnDragStart);
		f:SetScript("OnDragStop",mog.OnDragStop);
		
		f.model = CreateFrame("DressUpModel",nil,f);
		f.model:SetAllPoints(f);
		f.model.button = f;
		
		f.bg = f:CreateTexture(nil,"BACKGROUND");
		f.bg:SetAllPoints(f);
		f.bg:SetTexture(0.3,0.3,0.3,0.2);
		
		if not view then
			f:Hide();
			f.MogItModel = true;
			f.data = {};
			f.model:SetUnit("PLAYER");
			
			f:RegisterForClicks("AnyUp");
			f:SetScript("OnClick",mog.OnClick);
			f:SetScript("OnEnter",mog.OnEnter);
			f:SetScript("OnLeave",mog.OnLeave);
			
			f.label = f:CreateFontString(nil, nil, "GameFontNormalLarge")
			f.label:SetPoint("TOPLEFT", 16, -16);
			f.label:SetPoint("BOTTOMRIGHT", -16, 16);
			f.label:SetJustifyV("BOTTOM");
			f.label:SetJustifyH("CENTER");
			f.label:SetNonSpaceWrap(true);
			
			--f.icon = f:CreateTexture(nil,"ARTWORK");
			--f.icon:SetPoint("TOPRIGHT",f,"TOPRIGHT",-4,-4);
			--f.icon:SetSize(16,16);
			--f.icon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_1");
		end
		
		f.model:SetModelScale(2);
		f.model:SetPosition(0,0,0);
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

function mog.updateGUI(resize)
	local rows,columns = mog.db.profile.rows,mog.db.profile.columns;
	local total = rows*columns;
	local current = #mog.models;
	local width,height = mog.db.profile.width,mog.db.profile.height;
	
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

function mog.FrameUpdate(frame)
	if mog.active and mog.active.FrameUpdate then
		mog.active:FrameUpdate(frame,mog.list[frame.index]);
	end
end

function mog.OnShow(self)
	self.model:SetPosition(mog.posZ,mog.posX,mog.posY);
	local lvl = self:GetParent():GetFrameLevel();
	if self:GetFrameLevel() <= lvl then
		self:SetFrameLevel(lvl+1);
	end
	if self == mog.view.model then
		self.model:Undress();
		mog:DressModel(self.model);
	else
		mog.FrameUpdate(self);
	end
end

function mog.OnHide(self)
	if mog.modelUpdater.model == self then
		self:GetScript("OnDragStop")(self);
	end
	self.model:SetPosition(0,0,0);
end

--56, 108, 237, 238, 239, 243, 249, 250, 251, 252, 253, 254, 255
function mog.OnUpdate(self)
	if mog.db.profile.noAnim then
		self.model:SetSequence(254);
	end
	--autorotate?
end

function mog.OnClick(self,btn,...)
	if mog.active and mog.active.OnClick then
		mog.active:OnClick(self,btn,mog.list[self.index],...);
	end
end

function mog.OnDragStart(self,btn)
	mog.modelUpdater.btn = btn;
	mog.modelUpdater.model = self;
	mog.modelUpdater.prevx,mog.modelUpdater.prevy = GetCursorPosition();
	mog.modelUpdater:Show();
end

function mog.OnDragStop(self,btn)
	mog.modelUpdater:Hide();
	mog.modelUpdater.btn = nil;
	mog.modelUpdater.model = nil;
end

function mog.OnEnter(self,...)
	if mog.active and mog.active.OnEnter then
		mog.active:OnEnter(self,mog.list[self.index],...);
	end
end

function mog.OnLeave(self,...)
	if mog.active and mog.active.OnLeave then
		mog.active:OnLeave(self,...);
	else
		GameTooltip:Hide();
	end
end