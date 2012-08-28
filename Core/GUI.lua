local MogIt,mog = ...;
local L = mog.L;


--// mog.frame
mog.frame:SetPoint("CENTER");
mog.frame:SetSize(252,108);
mog.frame:SetToplevel(true);
mog.frame:SetClampedToScreen(true);
mog.frame:EnableMouse(true);
mog.frame:EnableMouseWheel(true);
mog.frame:SetMovable(true);
mog.frame:SetResizable(true);
mog.frame:SetDontSavePosition(true);
mog.frame:SetScript("OnMouseDown",mog.frame.StartMoving);
mog.frame:SetScript("OnMouseUp",function(self)
	self:StopMovingOrSizing();
	local profile = mog.db.profile;
	profile.point, profile.x, profile.y = select(3, self:GetPoint());
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
	mog.db.profile.gridWidth = mog.frame:GetWidth();
	mog.db.profile.gridHeight = mog.frame:GetHeight();
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


--// Model Frames
local mixins = {
	"ShowIndicator",
	"SetText",
}

mog.models = {};
mog.modelBin = {};
mog.posX = 0;
mog.posY = 0;
mog.posZ = 0;
mog.face = 0;

function mog:CreateModelFrame(parent)
	if mog.modelBin[1] then
		local f = mog.modelBin[1];
		f.parent = parent;
		f:SetParent(parent);
		--f:Show();
		tremove(mog.modelBin,1);
		return f;
	end
	
	local f = CreateFrame("Button",nil,parent);
	f:Hide();
	
	f.type = (parent == mog.frame) and "catalogue" or "preview";
	f.data = {parent = parent};
	f.indicators = {};
	
	f.model = CreateFrame("DressUpModel",nil,f);
	f.model:SetAllPoints(f);
	f.model:SetModelScale(2);
	f.model:SetUnit("PLAYER");
	f.model:SetPosition(0,0,0);
	
	f.bg = f:CreateTexture(nil,"BACKGROUND");
	f.bg:SetAllPoints(f);
	f.bg:SetTexture(0.3,0.3,0.3,0.2);
	
	f:SetScript("OnUpdate",mog.ModelOnUpdate);
	f:SetScript("OnShow",mog.ModelOnShow);
	f:SetScript("OnHide",mog.ModelOnHide);
	f:RegisterForClicks("AnyUp");
	f:RegisterForDrag("LeftButton","RightButton");
	f:SetScript("OnDragStart",mog.ModelOnDragStart);
	f:SetScript("OnDragStop",mog.ModelOnDragStop);
	
	for i, v in ipairs(mixins) do
		f[v] = mog[v];
	end
	
	return f;
end

function mog:DeleteModelFrame(f)
	f:Hide();
	f:ClearAllPoints();
	f:SetScript("OnClick",nil);
	f:SetScript("OnEnter",nil);
	f:SetScript("OnLeave",nil);
	f:SetScript("OnMouseWheel",nil);
	f:EnableMouseWheel(false);
	for ind,frame in pairs(f.indicators) do
		frame:Hide();
	end
	wipe(f.data);
	f:SetAlpha(1);
	f:Enable();
	tinsert(mog.modelBin,f);
end

function mog:CreateCatalogueModel()
	local f = mog:CreateModelFrame(mog.frame);
	f:SetScript("OnClick",mog.ModelOnClick);
	f:SetScript("OnEnter",mog.ModelOnEnter);
	f:SetScript("OnLeave",mog.ModelOnLeave);
	tinsert(mog.models,f);
	return f;
end

function mog:DeleteCatalogueModel(n)
	mog:DeleteModelFrame(mog.models[n]);
	tremove(mog.models,n);
end

function mog:BuildModel(self)
	self.model:SetCustomRace(self.data.race or (self.type == "catalogue" and mog.displayRace),self.data.gender or (self.type == "catalogue" and mog.displayGender));
end

function mog:DressModel(self)
	if mog.db.profile.gridDress == "equipped" and self.type ~= "preview" then
		self.model:Dress();
	else
		self.model:Undress();
	end

	local slots = (self.type == "preview" and self.data.parent.slots) or (mog.db.profile.gridDress == "preview" and mog.activePreview and mog.activePreview.slots);
	if slots then
		for id,slot in pairs(slots) do
			if slot.items[1] then
				self.model:TryOn(slot.items[1]);
			end
		end
	end
end

function mog:PositionModel(self)
	if self.model:IsVisible() then
		local sync = (mog.db.profile.sync or self.type == "catalogue");
		self.model:SetPosition((not sync and self.data.posZ) or mog.posZ or 0,(not sync and self.data.posX) or mog.posX or 0,(not sync and self.data.posY) or mog.posY or 0);
		self.model:SetFacing((not sync and self.data.face) or mog.face or 0);
	end
end
--//


--// Model Updater
mog.modelUpdater = CreateFrame("Frame",nil,UIParent);
mog.modelUpdater:Hide();
mog.modelUpdater:SetScript("OnUpdate",function(self,elapsed)
	local cX,cY = GetCursorPosition();
	local dX = (cX-self.pX)/50;
	local dY = (cY-self.pY)/50;
	
	if (mog.db.profile.sync or self.model.type == "catalogue") then
		if self.btn == "LeftButton" then
			mog.posZ = mog.posZ + dY;
			mog.face = mog.face + dX;
		elseif self.btn == "RightButton" then
			mog.posX = mog.posX + dX;
			mog.posY = mog.posY + dY;
		end
		for id,model in ipairs(mog.models) do
			mog:PositionModel(model);
		end
		if mog.db.profile.sync then
			for id,preview in ipairs(mog.previews) do
				mog:PositionModel(preview.model);
			end
		end
	else
		if self.btn == "LeftButton" then
			self.model.data.posZ = (self.model.data.posZ or mog.posZ or 0) + dY;
			self.model.data.face = (self.model.data.face or mog.face or 0) + dX;
		elseif self.btn == "RightButton" then
			self.model.data.posX = (self.model.data.posX or mog.posX or 0) + dX;
			self.model.data.posY = (self.model.data.posY or mog.posY or 0) + dY;
		end
		mog:PositionModel(self.model);
	end
	
	self.pX,self.pY = cX,cY;
end);

function mog:StartModelUpdater(model,btn)
	mog.modelUpdater.btn = btn;
	mog.modelUpdater.model = model;
	mog.modelUpdater.pX,mog.modelUpdater.pY = GetCursorPosition();
	mog.modelUpdater:Show();
end

function mog:StopModelUpdater()
	mog.modelUpdater:Hide();
	mog.modelUpdater.btn = nil;
	mog.modelUpdater.model = nil;
end
--//


--// Model Functions
function mog.ModelOnUpdate(self)
	--56, 108, 237, 238, 239, 243, 249, 250, 251, 252, 253, 254, 255
	if mog.db.profile.noAnim then
		self.model:SetSequence(254);
	end
end

function mog.ModelOnShow(self)
	local lvl = self:GetParent():GetFrameLevel();
	if self:GetFrameLevel() <= lvl then
		self:SetFrameLevel(lvl+1);
	end
	mog:BuildModel(self);
	if self.type == "preview" then
		mog:DressModel(self);
	else
		mog:ModelUpdate(self,self.data.value);
	end
	mog:PositionModel(self);
end

function mog.ModelOnHide(self)
	if mog.modelUpdater.model == self then
		mog:StopModelUpdater();
	end
	self.model:SetPosition(0,0,0);
end

function mog.ModelOnClick(self,btn,...)
	if mog.active and mog.active.OnClick then
		mog.active:OnClick(self,btn,self.data.value,...);
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
		mog.active:OnEnter(self,self.data.value,...);
	end
end

function mog.ModelOnLeave(self,...)
	if mog.active and mog.active.OnLeave then
		mog.active:OnLeave(self,self.data.value,...);
	else
		GameTooltip:Hide();
	end
end
--//


--// Indicators
mog.indicators = {};

function mog:CreateIndicator(name,func)
	if mog.indicators[name] then return end;
	mog.indicators[name] = func;
end

function mog:ShowIndicator(name)
	if not mog.indicators[name] then return end;
	if not self.indicators[name] then
		self.indicators[name] = mog.indicators[name](self.model);
	end
	self.indicators[name]:Show();
end

function mog:SetText(text)
	if not self.indicators.label then
		self.indicators.label = mog.indicators.label(self.model);
	end
	self.indicators.label:SetText(text);
end
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
	for id,frame in ipairs(mog.models) do
		local index = ((value-1)*models)+id;
		local value = mog.list[index];
		if value then
			wipe(frame.data);
			frame.data.value = value;
			frame.data.frame = frame;
			for k, v in pairs(frame.indicators) do
				v:Hide();
			end
			frame:SetAlpha(1);
			frame:Enable();
			if frame:IsShown() then
				mog:ModelUpdate(frame,value);
				if owner == frame then
					mog.ModelOnEnter(frame,value);
				end
			else
				frame:Show();
			end
		else
			frame:SetAlpha(0);
			frame:Disable();
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

function mog:ModelUpdate(frame,value)
	if mog.active and mog.active.FrameUpdate then
		mog.active:FrameUpdate(frame,value);
	end
end
--//


--// GUI
function mog:GetModelSize()
	local x = floor((mog.db.profile.gridWidth+5-(4+10)-(10+18+4))/mog.db.profile.columns)-5;
	local y = floor((mog.db.profile.gridHeight+5-(60+10)-(10+26))/mog.db.profile.rows)-5;
	return x,y;
end

function mog:UpdateGUI(resize)
	local profile = mog.db.profile;
	local rows,columns = profile.rows,profile.columns;
	local total = rows*columns;
	local current = #mog.models;
	local modelWidth,modelHeight = mog:GetModelSize();
	
	if not resize then
		if current > total then
			for i=current,(total+1),-1 do
				mog:DeleteCatalogueModel(i);
			end
		elseif current < total then
			for i=(current+1),total,1 do
				mog:CreateCatalogueModel();
			end
		end
		mog.frame:SetPoint(profile.point, profile.x, profile.y);
		mog.frame:SetSize(profile.gridWidth,profile.gridHeight);
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
			mog.models[n]:SetSize(modelWidth,modelHeight);
		end
	end
end
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
--// Race Menu
local races = {
   [1] = "HUMAN",
   [2] = "ORC",
   [3] = "DWARF",
   [4] = "NIGHTELF",
   [5] = "SCOURGE",
   [6] = "TAUREN",
   [7] = "GNOME",
   [8] = "TROLL",
   [9] = "GOBLIN",
   [10] = "BLOODELF",
   [11] = "DRAENEI",
   [22] = "WORGEN",
}

local gender = {
	[0] = "Male",
	[1] = "Female",
}

local menuModelNames = {
	HUMAN = "Human",
	ORC = "Orc",
	DWARF = "Dwarf",
	NIGHTELF = "Nightelf",
	SCOURGE = "Undead",
	TAUREN = "Tauren",
	GNOME = "Gnome",
	TROLL = "Troll",
	GOBLIN = "Goblin",
	BLOODELF = "Bloodelf",
	DRAENEI = "Draenei",
	WORGEN = "Worgen",
}

local dressOptions = {
	none = NONE,
	preview = L["Preview"],
	equipped = L["Equipped"],
}

local function setGridDress(self)
	mog.db.profile.gridDress = self.value;
	mog.scroll:update();
end

function mog:ToggleFilters()
	mog.filt:SetShown(not mog.filt:IsShown());
end

mog.sorting = {};

mog.menu.catalogue = mog.CreateMenu(mog.frame,L["Catalogue"],function(tier)
	if tier == 1 then
		local info = UIDropDownMenu_CreateInfo();
		info.text = mog.filt:IsShown() and L["Hide Filters"] or L["Show Filters"];
		info.notCheckable = true;
		info.func = mog.ToggleFilters;
		UIDropDownMenu_AddButton(info,tier);
		
		local info = UIDropDownMenu_CreateInfo();
		info.text = L["Sorting"];
		info.value = "sorting";
		info.notCheckable = true;
		info.hasArrow = true;
		info.disabled = not (mog.active and mog.active.sorting and #mog.active.sorting > 0);
		UIDropDownMenu_AddButton(info,tier);
		
		local info = UIDropDownMenu_CreateInfo();
		info.text = "Race";
		info.value = "race";
		info.notCheckable = true;
		info.hasArrow = true;
		-- info.disabled = not (mog.active and mog.active.sorting and #mog.active.sorting > 0);
		UIDropDownMenu_AddButton(info,tier);
		
		local info = UIDropDownMenu_CreateInfo();
		info.text = "Sechs";
		info.value = "gender";
		info.notCheckable = true;
		info.hasArrow = true;
		-- info.disabled = not (mog.active and mog.active.sorting and #mog.active.sorting > 0);
		UIDropDownMenu_AddButton(info,tier);
		
		local info = UIDropDownMenu_CreateInfo();
		info.text = L["Dress models"];
		info.value = "gridDress";
		info.notCheckable = true;
		info.hasArrow = true;
		-- info.disabled = not (mog.active and mog.active.sorting and #mog.active.sorting > 0);
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
	elseif mog.menu.tier[2] == "race" then
		if tier == 2 then
			for i, race in pairs(races) do -- pairs may yield unexpected order
				local info = UIDropDownMenu_CreateInfo();
				info.text = menuModelNames[race];
				info.value = race;
				-- info.func = setRace;
				-- info.checked = selectedRace == race;
				info.keepShownOnClick = true;
				UIDropDownMenu_AddButton(info,tier);
			end
		end
	elseif mog.menu.tier[2] == "gender" then
		if tier == 2 then
			for i, gender in pairs(gender) do -- pairs may yield unexpected order
				local info = UIDropDownMenu_CreateInfo();
				info.text = gender;
				info.value = i;
				-- info.func = setGender;
				-- info.checked = selectedGender == race;
				info.keepShownOnClick = true;
				UIDropDownMenu_AddButton(info,tier);
			end
		end
	elseif mog.menu.tier[2] == "gridDress" then
		if tier == 2 then
			for k, v in pairs(dressOptions) do
				local info = UIDropDownMenu_CreateInfo();
				info.text = v;
				info.value = k;
				info.func = setGridDress;
				info.checked = mog.db.profile.gridDress == k;
				info.keepShownOnClick = true;
				UIDropDownMenu_AddButton(info,tier);
			end
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







mog:CreateIndicator("label", function(model)
	local label = model:CreateFontString(nil, "OVERLAY", "GameFontNormalMed3");
	label:SetPoint("TOPLEFT", 12, -12);
	label:SetPoint("BOTTOMRIGHT", -12, 12);
	label:SetJustifyV("BOTTOM");
	label:SetJustifyH("CENTER");
	label:SetNonSpaceWrap(true);
	return label;
end)

mog:CreateIndicator("hasItem", function(model)
	local hasItem = model:CreateTexture(nil, "OVERLAY");
	hasItem:SetTexture("Interface\\RaidFrame\\ReadyCheck-Ready");
	hasItem:SetSize(32, 32);
	hasItem:SetPoint("BOTTOMRIGHT", -8, 8);
	return hasItem;
end)

mog:CreateIndicator("wishlist", function(model)
	local wishlist = model:CreateTexture(nil, "OVERLAY");
	wishlist:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_1");
	wishlist:SetSize(32, 32);
	wishlist:SetPoint("TOPRIGHT", -8, -8);
	return wishlist;
end)






--[[
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
]]