local MogIt,mog = ...;
local L = mog.L;

local LBR = LibStub("LibBabble-Race-3.0"):GetUnstrictLookupTable();

local races = {
   "Human",
   "Dwarf",
   "Gnome",
   "Night Elf",
   "Draenei",
   "Worgen",
   "Orc",
   "Undead",
   "Tauren",
   "Troll",
   "Blood Elf",
   "Goblin",
   "Pandaren",
}

local raceID = {
   ["Human"] = 1,
   ["Orc"] = 2,
   ["Dwarf"] = 3,
   ["Night Elf"] = 4,
   ["Undead"] = 5,
   ["Tauren"] = 6,
   ["Gnome"] = 7,
   ["Troll"] = 8,
   ["Goblin"] = 9,
   ["Blood Elf"] = 10,
   ["Draenei"] = 11,
   ["Worgen"] = 22,
   ["Pandaren"] = 24,
}

local gender = {
	[0] = "Male",
	[1] = "Female",
}

local myRace = raceID[select(2, UnitRace("player"))]
local myGender = UnitSex("player") - 2

mog.displayRace = myRace
mog.displayGender = myGender


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
	f.parent = parent;
	f.data = {};
	f.indicators = {};
	
	f.model = CreateFrame("DressUpModel",nil,f);
	f.model:SetAllPoints(f);
	f.model:SetModelScale(2);
	f.model:SetUnit("PLAYER");
	f.model:SetPosition(0,0,0);
	
	f.bg = f:CreateTexture(nil,"BACKGROUND");
	f.bg:SetAllPoints(f);
	f.bg:SetTexture(0.3,0.3,0.3,0.2);
	
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
	self.model:SetCustomRace((self.type == "preview" and self.parent.data.race) or mog.displayRace,(self.type == "preview" and self.parent.data.gender) or mog.displayGender);
end

function mog:DressModel(self)
	if mog.db.profile.gridDress == "equipped" and self.type ~= "preview" then
		if mog.displayRace == myRace and mog.displayGender == myGender then
			self.model:Dress();
		else
			mog:BuildModel(self);
		end
	else
		self.model:Undress();
	end

	local slots = (self.type == "preview" and self.parent.slots) or (mog.db.profile.gridDress == "preview" and mog.activePreview and mog.activePreview.slots);
	if slots then
		for id,slot in pairs(slots) do
			if slot.item then
				self.model:TryOn(slot.item);
			end
		end
	end
end

function mog:PositionModel(self)
	if self.model:IsVisible() then
		local sync = (mog.db.profile.sync or self.type == "catalogue");
		self.model:SetPosition((not sync and self.parent.data.posZ) or mog.posZ or 0,(not sync and self.parent.data.posX) or mog.posX or 0,(not sync and self.parent.data.posY) or mog.posY or 0);
		self.model:SetFacing((not sync and self.parent.data.face) or mog.face or 0);
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
				if GameTooltip:IsOwned(frame) then
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
local function menuBarInitialize(self, level)
	if self.active and self.active.func then
		self.tier[level] = UIDROPDOWNMENU_MENU_VALUE;
		self.active.func(level);
	end
end

local function menuOnClick(self, btn)
	if self.menuBar.active ~= self then
		HideDropDownMenu(1);
	end
	self.menuBar.active = self;
	if self.func then
		ToggleDropDownMenu(1,nil,self.menuBar,self,0,0,self,self);
	end
end

local function menuOnEnter(self)
	if self.menuBar.active ~= self and mog.IsDropdownShown(self.menuBar) then
		HideDropDownMenu(1);
		if self.func then
			self.menuBar.active = self;
			ToggleDropDownMenu(1,nil,self.menuBar,self,0,0,self,self);
		end
	end
	self.nt:SetTexture(1,0.82,0,1);
end

local function menuOnLeave(self)
	self.nt:SetTexture(0,0,0,0);
end

local function createMenu(menuBar, label, func)
	local f = CreateFrame("Button", nil, menuBar.parent);
	f:SetText(label);
	f:SetNormalFontObject(GameFontNormal);
	f:SetHighlightFontObject(GameFontBlack);
	f:SetSize(f:GetFontString():GetStringWidth()+10, f:GetFontString():GetStringHeight()+10);
	f.menuBar = menuBar
	
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

function mog.CreateMenuBar(parent, name)
	local menuBar = CreateFrame("Frame", name, parent);
	menuBar.displayMode = "MENU";
	menuBar.initialize = menuBarInitialize
	menuBar.CreateMenu = createMenu;
	menuBar.parent = parent
	menuBar.tier = {};
	return menuBar;
end

mog.menu = mog.CreateMenuBar(mog.frame, "MogItMenu");
--//


--// Module Menu
mog.menu.modules = mog.menu:CreateMenu(L["Modules"], function(tier)
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
mog.menu.modules:SetPoint("TOPLEFT", mog.frame, "TOPLEFT", 62, -31);
--//


--// Catalogue Menu
local function setDisplayModel(self, arg1)
	mog[arg1] = self.value;
	for i, model in ipairs(mog.models) do
		if model:IsEnabled() then
			mog:BuildModel(model);
			mog:ModelUpdate(model, model.data.value);
		end
	end
	CloseDropDownMenus(1);
end

local dressOptions = {
	none = NONE,
	preview = L["Preview"],
	equipped = L["Equipped"],
}

local function setGridDress(self)
	mog.db.profile.gridDress = self.value;
	mog.scroll:update();
	CloseDropDownMenus(1);
end

function mog:ToggleFilters()
	mog.filt:SetShown(not mog.filt:IsShown());
end

mog.sorting = {};

mog.menu.catalogue = mog.menu:CreateMenu(L["Catalogue"],function(tier)
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
		info.text = "Gender";
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
			for i, race in ipairs(races) do -- pairs may yield unexpected order
				local info = UIDropDownMenu_CreateInfo();
				info.text = LBR[race] or race; -- fall back to English 'race' until there's pandaren localisation
				info.value = raceID[race];
				info.func = setDisplayModel;
				info.checked = mog.displayRace == raceID[race];
				info.keepShownOnClick = true;
				info.arg1 = "displayRace";
				UIDropDownMenu_AddButton(info,tier);
			end
		end
	elseif mog.menu.tier[2] == "gender" then
		if tier == 2 then
			for i, gender in pairs(gender) do -- pairs may yield unexpected order
				local info = UIDropDownMenu_CreateInfo();
				info.text = gender;
				info.value = i;
				info.func = setDisplayModel;
				info.checked = mog.displayGender == i;
				info.keepShownOnClick = true;
				info.arg1 = "displayGender";
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
mog.menu.catalogue:SetPoint("LEFT", mog.menu.modules, "RIGHT", 5, 0);
--//


--// Preview Menu
mog.menu.preview = mog.menu:CreateMenu(L["Preview"], function(tier)
	-- New Preview
	-- Show/Hide All Previews (mog.view:IsShown)
	-- Close All Previews (only add this option if it has a confirmation popup)
	-- Synchronize Preview Positioning
end);
mog.menu.preview:SetPoint("LEFT", mog.menu.catalogue, "RIGHT", 5, 0);
--//


--// Options Menu
function mog:ToggleOptions()
	if not mog.options then
		mog.createOptions();
	end
	InterfaceOptionsFrame_OpenToCategory(MogIt);
end

mog.menu.options = mog.menu:CreateMenu(L["Options"]);
mog.menu.options:SetScript("OnClick", mog.ToggleOptions);
mog.menu.options:SetPoint("LEFT", mog.menu.preview, "RIGHT", 5, 0);
--//


--// Default Indicators
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
--//