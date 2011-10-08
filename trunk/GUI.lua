local MogIt,mog = ...;
local L = mog.L;

--.AddModel -> .frames
--SetModel? to fix pets?

mog.frame = CreateFrame("Frame","MogItFrame",UIParent,"ButtonFrameTemplate");
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
mog.frame.resize:SetScript("OnMouseDown",function(self)
	mog.frame:SetMinResize(510,350);
	mog.frame:SetMaxResize(GetScreenWidth(),GetScreenHeight());
	mog.frame:StartSizing();
	self:SetScript("OnUpdate",function(self)
		mog.global.width = floor((mog.frame:GetWidth()+5-(4+10)-(10+18+4))/mog.global.columns)-5;
		mog.global.height = floor((mog.frame:GetHeight()+5-(60+10)-(10+26))/mog.global.rows)-5;
		mog.updateGUI(true);
	end);
end);
mog.frame.resize:SetScript("OnMouseUp",function(self)
	mog.frame:StopMovingOrSizing();
	self:SetScript("OnUpdate",nil);
end);
mog.frame.resize:SetScript("OnHide",mog.frame.resize:GetScript("OnMouseUp"));
mog.frame.resize.texture = mog.frame.resize:CreateTexture(nil,"OVERLAY");
mog.frame.resize.texture:SetSize(16,16);
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
		for k,v in ipairs(mog.modules) do
			if v.Dropdown then
				v:Dropdown(tier);
			end
		end
	elseif tier1.Dropdown then
		tier1:Dropdown(tier);
	end
end

mog.frame.sorting = mog.frame:CreateFontString(nil,"ARTWORK","GameFontNormal");
mog.frame.sorting:SetPoint("TOPRIGHT",mog.frame,"TOPRIGHT",-142,-35);
mog.frame.sorting:SetText(L["Sort by"]..":");

mog.sorting = CreateFrame("Frame","MogItSorting",mog.frame,"UIDropDownMenuTemplate");
mog.sorting:SetPoint("LEFT",mog.frame.sorting,"RIGHT",-12,-3);
UIDropDownMenu_SetWidth(mog.sorting,110);
UIDropDownMenu_SetButtonWidth(mog.sorting,125);
UIDropDownMenu_JustifyText(mog.sorting,"LEFT");
UIDropDownMenu_SetText(mog.sorting,L["Level"]);
function mog.sorting:initialize(tier)
	local info;
end

mog.frame.filters = CreateFrame("Button","MogItFrameFiltersButton",mog.frame,"MagicButtonTemplate");
mog.frame.filters:SetPoint("BOTTOMLEFT",mog.frame,"BOTTOMLEFT",5,5);
mog.frame.filters:SetWidth(100);
mog.frame.filters:SetText(FILTERS);

mog.frame.preview = CreateFrame("Button","MogItFramePreviewButton",mog.frame,"MagicButtonTemplate");
mog.frame.preview:SetPoint("TOPLEFT",mog.frame.filters,"TOPRIGHT");
mog.frame.preview:SetWidth(100);
mog.frame.preview:SetText(L["Preview"]);

mog.frame.options = CreateFrame("Button","MogItFrameOptionsButton",mog.frame,"MagicButtonTemplate");
mog.frame.options:SetPoint("TOPLEFT",mog.frame.preview,"TOPRIGHT");
mog.frame.options:SetWidth(100);
mog.frame.options:SetText(MAIN_MENU);

mog.frame.page = mog.frame:CreateFontString(nil,"ARTWORK","GameFontHighlightSmall");
mog.frame.page:SetPoint("BOTTOMRIGHT",mog.frame,"BOTTOMRIGHT",-17,10);

mog.scroll = CreateFrame("Slider","MogItScroll",mog.frame,"UIPanelScrollBarTrimTemplate");
mog.scroll:Hide();
mog.scroll:SetPoint("TOPRIGHT",mog.frame.Inset,"TOPRIGHT",1,-17);
mog.scroll:SetPoint("BOTTOMRIGHT",mog.frame.Inset,"BOTTOMRIGHT",1,16);
mog.scroll:SetScript("OnValueChanged",function(self,value)
	mog.scroll:update(value);
end);
mog.scroll:SetValueStep(1);
mog.scroll:SetValue(1);
mog.scroll.up = MogItScrollScrollUpButton;
mog.scroll.down = MogItScrollScrollDownButton;
mog.scroll.up:SetScript("OnClick",function(self)
	mog.scroll:update(nil,-1);
end);
mog.scroll.down:SetScript("OnClick",function(self)
	mog.scroll:update(nil,1);
end);

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
	
	if mog.selected and mog.selected.OnScroll then
		mog.selected:OnScroll();
	end
	
	local id,frame,index;
	for id,frame in ipairs(mog.models) do
		index = ((page-1)*models)+id;
		if mog.list[index] then
			wipe(frame.data);
			if mog.selected.FrameUpdate then
				mog.selected:FrameUpdate(frame,mog.list[index],index);
			end
			frame:Show();
			if owner == frame and mog.selected.OnEnter then
				mog.selected:OnEnter(frame);
			end
		else
			frame:Hide();
		end
	end
	if total > 0 then
		mog.frame.page:SetText(MERCHANT_PAGE_NUMBER:format(page,total));
		mog.frame.page:Show();
	else
		mog.frame.page:Hide();
	end
end

mog.frame:SetScript("OnMouseWheel",function(self,offset)
	local value = mog.scroll:GetValue();
	local low,high = mog.scroll:GetMinMaxValues();
	if (offset > 0 and value > low) then
		mog.scroll:update(nil,-1);
	elseif (offset < 0 and value < high) then
		mog.scroll:update(nil,1);
	end
end);

function mog.updateModels()
	--mog.view.model.model:SetFacing(mog.face);
	--if mog.view.model.model:IsVisible() then
	--	mog.view.model.model:SetPosition(mog.posZ,mog.posX,mog.posY);
	--end
	for k,v in ipairs(mog.models) do
		v.model:SetFacing(mog.face);
		if v.model:IsVisible() then
			v.model:SetPosition(mog.posZ,mog.posX,mog.posY);
		end
	end
end

mog.modelUpdater = CreateFrame("Frame",nil,mog.frame);
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

function mog.addModel()
	local f;
	if mog.bin[1] then
		f = mog.bin[1];
		tremove(mog.bin,1);
	else
		f = CreateFrame("Button",nil,mog.frame);
		f:Hide();
		f.MogItModel = true;
		
		f:SetScript("OnShow",function(self,...)
			self.model:SetPosition(mog.posZ,mog.posX,mog.posY);
			--if mog.selected and mog.selected.OnShow then
			--mog.dressModel(self.model);
		end);
		f:SetScript("OnHide",function(self)
			if mog.modelUpdater.model == self then
				self:GetScript("OnDragStop")(self);
			end
			self.model:SetPosition(0,0,0);
		end);
		f:SetScript("OnUpdate",function(self)
			--noAnim
			--autorotate
		end);
		f:RegisterForClicks("AnyUp");
		f:SetScript("OnClick",function(self,...)
			if mog.selected and mog.selected.OnClick then
				mog.selected:OnClick(self,...);
			end
		end);
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
		f:SetScript("OnEnter",function(self,...)
			if mog.selected and mog.selected.OnEnter then
				mog.selected:OnEnter(self,...);
			end
		end);
		f:SetScript("OnLeave",function(self)
			GameTooltip:Hide();
		end);
		
		f.model = CreateFrame("DressUpModel",nil,f);
		f.model:SetUnit("PLAYER");
		f.model:SetModelScale(2);
		f.model:SetPosition(0,0,0);
		f.model:SetAllPoints(f);
		f.model.button = f;
		
		f.bg = f:CreateTexture(nil,"BACKGROUND");
		f.bg:SetAllPoints(f);
		f.bg:SetTexture(0.3,0.3,0.3,0.2);
		
		f.data = {};
	end
	tinsert(mog.models,f);
	return f;
end

function mog.delModel(f)
	mog.models[f]:Hide();
	tinsert(mog.bin,mog.models[f]);
	tremove(mog.models,f);
end

function mog.updateGUI(resize)
	local rows,columns = mog.global.rows,mog.global.columns;
	local total = rows*columns;
	local current = #mog.models;
	local width,height = mog.global.width,mog.global.height;
	
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

mog.mmb = mog.LDB:NewDataObject("MogIt",{
	type = "launcher",
	icon = "Interface\\Icons\\INV_Enchant_EssenceCosmicGreater",
	OnClick = function(self,btn)
		if btn == "RightButton" then
			mog.togglePreview();
		else
			mog.toggleFrame();
		end
	end,
	OnTooltipShow = function(self)
		if not self or not self.AddLine then return end
		self:AddLine("MogIt");
		self:AddLine(mog.frame:IsShown() and L["Left click to close MogIt"] or L["Left click to open MogIt"],1,1,1);
		--self:AddLine(mog.preview:IsShown() and L["Right click to close the MogIt preview"] or L["Right click to close the MogIt preview"],1,1,1);
	end,
});

mog.frame:SetScript("OnEvent",function(self,event,arg1,...)
	if event == "PLAYER_LOGIN" then
		if not MogIt_Global then
			MogIt_Global = {
				tooltip = true,
				tooltipMouse = false,
				tooltipDress = false,
				tooltipRotate = true,
				tooltipMog = true,
				gridDress = true,
				noAnim = false;
			};
		end
		mog.global = MogIt_Global;
		--mog.global.wishlist = mog.global.wishlist or {};
		--mog.global.wishlist.sets = mog.global.wishlist.sets or {};
		--mog.global.wishlist.items = mog.global.wishlist.items or {};
		mog.global.minimap = mog.global.minimap or {};
		mog.global.url = mog.global.url or "Battle.net";
		--mog.global.tooltipWidth = mog.global.tooltipWidth or 300;
		--mog.global.tooltipHeight = mog.global.tooltipHeight or 300;
		mog.global.width = mog.global.width or 200;
		mog.global.height = mog.global.height or 200;
		mog.global.rows = mog.global.rows or 2;
		mog.global.columns = mog.global.columns or 3;
		if not mog.global.version then
			DEFAULT_CHAT_FRAME:AddMessage(L["MogIt has loaded! Type \"/mog\" to open it."]);
		end
		mog.global.version = GetAddOnMetadata(MogIt,"Version");
		
		if not MogIt_Character then
			MogIt_Character = {};
		end
		mog.char = MogIt_Character;
		--mog.char.wishlist = mog.char.wishlist or {};
		--mog.char.wishlist.sets = mog.char.wishlist.sets or {};
		--mog.char.wishlist.items = mog.char.wishlist.items or {};
		if not mog.char.version then
			--if MogIt_Wishlist then
			--	for k,v in pairs(MogIt_Wishlist.display) do
			--		table.insert(mog.char.wishlist.items,type(v) == "table" and v[1] or v);
			--	end
			--end
		end
		mog.char.version = GetAddOnMetadata(MogIt,"Version");
		
		--mog.view.model.model:SetUnit("PLAYER");
		mog.updateGUI();
		--mog.updateModels();
		
		--[[mog.tooltip.model:SetUnit("PLAYER");
		mog.tooltip:SetSize(mog.global.tooltipWidth,mog.global.tooltipHeight);
		if mog.global.tooltipRotate then
			mog.tooltip.rotate:Show();
		end--]]
		
		mog.LDBI:Register(MogIt,mog.mmb,mog.global.minimap);
		mog.frame:UnregisterEvent("PLAYER_LOGIN");
	elseif event == "GET_ITEM_INFO_RECEIVED" then
		local owner = GameTooltip:IsShown() and GameTooltip:GetOwner();
		if owner and owner.MogItModel and mog.selected and mog.selected.OnEnter then
			mog.selected:OnEnter(owner);
		end
		if UIDropDownMenu_GetCurrentDropDown() == mog.sub.LeftClick and DropDownList1 and DropDownList1:IsShown() then
			HideDropDownMenu(1);
			ToggleDropDownMenu(nil,nil,mog.sub.LeftClick,"cursor",0,0,mog.sub.LeftClick.menuList);
		end
	elseif event == "ADDON_LOADED" then
		if mog.sub.modules[arg1] then
			mog.sub.modules[arg1].loaded = true;
			if UIDropDownMenu_GetCurrentDropDown() == mog.dropdown and DropDownList1 and DropDownList1:IsShown() then
				HideDropDownMenu(1);
				ToggleDropDownMenu(1,mog.sub.modules[arg1],mog.dropdown);
			end
		end
	end
end);
mog.frame:RegisterEvent("PLAYER_LOGIN");
mog.frame:RegisterEvent("GET_ITEM_INFO_RECEIVED");
mog.frame:RegisterEvent("ADDON_LOADED");