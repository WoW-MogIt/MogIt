local MogIt,mog = ...;
local L = mog.L;


mog.view = CreateFrame("Frame","MogItPreview",UIParent);
mog.view:SetAllPoints(UIParent);
mog.view:SetScript("OnShow",function(self)
	mog.modelUpdater:Show();
end);
mog.view:SetScript("OnHide",function(self)
	if not mog.frame:IsShown() then
		mog.modelUpdater:Hide();
	end
end);
tinsert(UISpecialFrames,"MogItPreview");

mog.view.bin = {};
mog.view.frames = {};
mog.view.num = 0;


--// Preview Functions
local function resizeOnMouseDown(self)
	local f = self:GetParent();
	f:SetMinResize(335,385);
	f:SetMaxResize(GetScreenWidth(),GetScreenHeight());
	f:StartSizing();
end

local function resizeOnMouseUp(self)
	local f = self:GetParent();
	f:StopMovingOrSizing();
end

local function modelOnMouseWheel(self,v)
	mog.posZ = mog.posZ + ((v > 0 and 0.6) or -0.6);
	mog.updateModels();
end

local function saveOnClick(self,btn)
	ToggleDropDownMenu(nil, nil, self.menu, self, 0, 0)
end

local function loadOnClick(self,btn)
	ToggleDropDownMenu(nil, nil, self.menu, self, 0, 0)
end

local function clearOnClick(self,btn)
	for k,v in pairs(mog.view.slots) do
		mog.view.delItem(k);
	end
	if mog.db.profile.gridDress then
		mog.scroll:update();
	end
end

local function addOnClick(self,btn)
	StaticPopup_Show("MOGIT_PREVIEW_ADDITEM");
end

local function importOnClick(self,btn)
	StaticPopup_Show("MOGIT_PREVIEW_IMPORT");
end

local function linkOnClick(self,btn)
	local tbl = {};
	for k,v in pairs(mog.view.slots) do
		if v.item then
			table.insert(tbl,v.item);
		end
	end
	ChatEdit_InsertLink(mog:SetToLink(tbl));
end

local function slotTexture(f,slot,texture)
	SetItemButtonTexture(f.slots[slot],texture or select(2,GetInventorySlotInfo(slot)));
end

local function slotOnEnter(self)
	if self.item then
		mog.Item_OnEnter(self,self);
		--GameTooltip:SetItemByID(self.item);
	else
		GameTooltip:SetOwner(self,"ANCHOR_RIGHT");
		GameTooltip:SetText(_G[strupper(self.slot)]);
	end
end

local function slotOnLeave(self)
	GameTooltip:Hide();
end

local function slotOnClick(self,btn)
	if btn == "RightButton" and IsControlKeyDown() then
		mog.view.delItem(self.slot);
		if mog.db.profile.gridDress then
			mog.scroll:update();
		end
		slot_OnEnter(self);
	else
		mog.Item_OnClick(self,btn,self);
	end
end
--//


--// Create Preview
function mog:CreatePreview()
	local f;
	if mog.view.bin[1] then
		f = mog.view.bin[1];
		tremove(mog.view.bin,1);
		f:Show();
	else
		mog.view.num = mog.view.num + 1;
		f = CreateFrame("Frame","MogItPreview"..mog.view.num,mog.view,"ButtonFrameTemplate");
		f.id = mog.view.num;
		
		f:SetPoint("CENTER",mog.view,"CENTER");
		f:SetSize(335,385);
		f:SetToplevel(true);
		f:SetClampedToScreen(true);
		f:EnableMouse(true);
		f:SetMovable(true);
		f:SetResizable(true);
		f:SetScript("OnMouseDown",f.StartMoving);
		f:SetScript("OnMouseUp",f.StopMovingOrSizing);

		_G["MogItPreview"..mog.view.num.."Bg"]:SetVertexColor(0.8,0.3,0.8);
		_G["MogItPreview"..mog.view.num.."TitleText"]:SetText(L["Preview"].." "..mog.view.num);
		f.portraitFrame:Hide();
		f.topLeftCorner:Show();
		f.topBorderBar:SetPoint("TOPLEFT",f.topLeftCorner,"TOPRIGHT",0,0);
		f.leftBorderBar:SetPoint("TOPLEFT",f.topLeftCorner,"BOTTOMLEFT",0,0);

		f.resize = CreateFrame("Frame",nil,f);
		f.resize:SetSize(16,16);
		f.resize:SetPoint("BOTTOMRIGHT",f,"BOTTOMRIGHT",-4,3);
		f.resize:EnableMouse(true);
		f.resize:SetScript("OnMouseDown",resizeOnMouseDown);
		f.resize:SetScript("OnMouseUp",resizeOnMouseUp);
		f.resize:SetScript("OnHide",resizeOnMouseUp);
		f.resize.texture = f.resize:CreateTexture(nil,"OVERLAY");
		f.resize.texture:SetTexture("Interface\\AddOns\\MogIt\\Images\\Resize");
		f.resize.texture:SetAllPoints(f.resize);
		
		f.model = mog.addModel(true);
		f.model:SetPoint("TOPLEFT",f.Inset,"TOPLEFT",49,-8);
		f.model:SetPoint("BOTTOMRIGHT",f.Inset,"BOTTOMRIGHT",-49,8);
		f.model:EnableMouseWheel(true);
		f.model:SetScript("OnMouseWheel",modelOnMouseWheel);

		f.save = CreateFrame("Button","MogItPreview"..mog.view.num.."Save",f,"UIPanelButtonTemplate2");
		f.save:SetPoint("TOPLEFT",10,-30);
		f.save:SetWidth(100);
		f.save:SetText(L["Save"]);
		f.save:SetScript("OnClick",saveOnClick);
		
		f.load = CreateFrame("Button","MogItPreview"..mog.view.num.."Load",f,"UIPanelButtonTemplate2");
		f.load:SetPoint("LEFT",f.save,"RIGHT",8,0);
		f.load:SetWidth(100);
		f.load:SetText(L["Load"]);
		f.load:SetScript("OnClick",loadOnClick);
		
		f.clear = CreateFrame("Button","MogItPreview"..mog.view.num.."Clear",f,"UIPanelButtonTemplate2");
		f.clear:SetPoint("TOPRIGHT",f,"TOPRIGHT",-10,-30);
		f.clear:SetWidth(100);
		f.clear:SetText(L["Clear"]);
		f.clear:SetScript("OnClick",clearOnClick);

		f.add = CreateFrame("Button","MogItPreview"..mog.view.num.."AddItem",f,"MagicButtonTemplate");
		f.add:SetPoint("BOTTOMLEFT",f,"BOTTOMLEFT",5,5);
		f.add:SetWidth(100);
		f.add:SetText(L["Add Item"]);
		f.add:SetScript("OnClick",addOnClick);

		f.import = CreateFrame("Button","MogItPreview"..mog.view.num.."Import",f,"MagicButtonTemplate");
		f.import:SetPoint("TOPLEFT",f.add,"TOPRIGHT");
		f.import:SetWidth(100);
		f.import:SetText(L["Import"]);
		f.import:SetScript("OnClick",importOnClick);

		f.link = CreateFrame("Button","MogItPreview"..mog.view.num.."Link",f,"MagicButtonTemplate");
		f.link:SetPoint("TOPLEFT",f.import,"TOPRIGHT");
		f.link:SetWidth(100);
		f.link:SetText(L["Chat Link"]);
		f.link:SetScript("OnClick",linkOnClick);
		
		f.slots = {};
		for i=1,14 do
			local slot = mog:GetSlot(i);
			f.slots[slot] = CreateFrame("Button","MogItPreview"..mog.view.num..slot,f,"ItemButtonTemplate");
			f.slots[slot].slot = slot;
			if i == 1 then
				f.slots[slot]:SetPoint("TOPLEFT",f.Inset,"TOPLEFT",8,-8);
			elseif i == 8 then
				f.slots[slot]:SetPoint("TOPRIGHT",f.Inset,"TOPRIGHT",-7,-8);
			else
				f.slots[slot]:SetPoint("TOP",f.slots[mog:GetSlot(i-1)],"BOTTOM",0,-4);
			end
			slotTexture(f,slot);
			f.slots[slot]:RegisterForClicks("AnyUp");
			f.slots[slot]:SetScript("OnClick",slotOnClick);
			f.slots[slot]:SetScript("OnEnter",slotOnEnter);
			f.slots[slot]:SetScript("OnLeave",slotOnLeave);
		end
	end
	tinsert(mog.view.frames,f);
	return f;
end
--//


--// Delete Preview

--//





local newSet = {items = {}}

local function onClick(self)
	newSet.name = self.value
	wipe(newSet.items)
	for slot, v in pairs(mog.view.slots) do
		newSet.items[slot] = v.item
	end
	StaticPopup_Show("MOGIT_WISHLIST_OVERWRITE_SET", self.value, nil, newSet)
end

local function newSetOnClick(self)
	wipe(newSet.items)
	newSet.name = "Set "..(#mog.wishlist:GetSets() + 1)
	for slot, v in pairs(mog.view.slots) do
		newSet.items[slot] = v.item
	end
	StaticPopup_Show("MOGIT_WISHLIST_CREATE_SET", nil, nil, newSet)
end

local saveMenu = CreateFrame("Frame")
saveMenu.displayMode = "MENU"
saveMenu.initialize = function(self, level)
	mog.wishlist:AddSetMenuItems(level, onClick)
	
	local info = UIDropDownMenu_CreateInfo()
	info.text = L["New set"]
	info.func = newSetOnClick
	info.colorCode = GREEN_FONT_COLOR_CODE
	info.notCheckable = true
	UIDropDownMenu_AddButton(info, level)
end
-- mog.view.save.menu = saveMenu


local function onClick(self, profile)
	for k, v in pairs(mog.view.slots) do
		mog.view.delItem(k)
	end
	for slot, itemID in pairs(mog.wishlist:GetSetItems(self.value, profile)) do
		mog:AddToPreview(itemID)
	end
	CloseDropDownMenus()
end

local loadMenu = CreateFrame("Frame")
loadMenu.displayMode = "MENU"
loadMenu.initialize = function(self, level)
	if level == 1 then
		mog.wishlist:AddSetMenuItems(level, onClick)
		
		local info = UIDropDownMenu_CreateInfo()
		info.text = L["Other profiles"]
		info.hasArrow = true
		info.notCheckable = true
		UIDropDownMenu_AddButton(info, level)
	elseif level == 2 then
		local curProfile = mog.wishlist:GetCurrentProfile()
		for i, profile in ipairs(mog.wishlist:GetProfiles()) do
			if profile ~= curProfile then
				local info = UIDropDownMenu_CreateInfo()
				info.text = profile
				info.hasArrow = true
				info.notCheckable = true
				UIDropDownMenu_AddButton(info, level)
			end
		end
	elseif level == 3 then
		mog.wishlist:AddSetMenuItems(level, onClick, UIDROPDOWNMENU_MENU_VALUE, UIDROPDOWNMENU_MENU_VALUE)
	end
end
-- mog.view.load.menu = loadMenu





--[[

one handed weapons first go into main hand slot, then alternate between off and main hand, does not have to be same item

equipping any non one handed weapon will cause the next one handed weapon to go into main hand

equipping a right handed ranged weapon (gun, crossbow, thrown) will cause the next two one hand weapons to go into main hand (above rule still applies)

]]

mog.view.wait = {};
function mog.view.addItem(item)
	if not item then return end;
	local slot,texture = select(9,GetItemInfo(item));
	if not slot then
		mog.view.wait[item] = (mog.view.wait[item] or 0) + 1;
		return;
	end
	if mog.slotsType[slot] then
		if slot == "INVTYPE_2HWEAPON" then
			if select(2,UnitClass("PLAYER")) == "WARRIOR" and (select(5,GetTalentInfo(2,20)) or 0) > 0 then
				slot = "INVTYPE_WEAPON";
			end
		end
		if slot == "INVTYPE_WEAPON" and not mog.view.twohand then
			if mog.view.slots.MainHandSlot.item and ((not mog.view.slots.SecondaryHandSlot.item) or mog.view.slots.MainHandSlot.item == item) then
				slot = "INVTYPE_WEAPONOFFHAND";
			end
		end
		
		if slot == "INVTYPE_2HWEAPON" then
			mog.view.delItem("SecondaryHandSlot");
			mog.view.twohand = true;
		elseif slot == "INVTYPE_WEAPONOFFHAND" then
			if mog.view.twohand then
				mog.view.delItem("MainHandSlot");
			end
			mog.view.twohand = nil;
		elseif slot == "INVTYPE_WEAPON" then
			mog.view.twohand = nil;
		elseif slot == "INVTYPE_WEAPONMAINHAND" then
			mog.view.twohand = nil;
		end
		
		mog.view.slots[mog.slotsType[slot]].item = item;
		-- item history
		mog.view.setTexture(mog.slotsType[slot],texture);
		if mog.view:IsShown() then
			mog.view.model.model:TryOn(item);
		end
	end
end

function mog:AddToPreview(item)
	if not item then return end;
	if type(item) == "number" then
		mog.view.addItem(item);
	elseif type(item) == "string" then
		mog.view.addItem(tonumber(item:match("item:(%d+)")));
	elseif type(item) == "table" then
		if mog.db.profile.clearOnPreviewSet then
			for k,v in pairs(mog.view.slots) do
				mog.view.delItem(k);
			end
		end
		for k,v in pairs(item) do
			mog.view.addItem(v);
		end
	end
	ShowUIPanel(mog.view);
	if mog.db.profile.gridDress == "preview" then
		mog.scroll:update();
	end
end

function mog.view.delItem(slot)
	mog.view.slots[slot].item = nil;
	mog.view.setTexture(slot);
	mog.view.model.model:UndressSlot(GetInventorySlotInfo(slot)); -- needs cleanup
	-- mog:DressModel(mog.view.model);
end

function mog:DressModel(frame)
	if mog.db.profile.gridDress == "preview" or (frame == mog.view.model) then
		for k,v in pairs(mog.view.slots) do
			if v.item then
				frame.model:TryOn(v.item);
			end
		end
	end
end

hooksecurefunc("HandleModifiedItemClick",function(link)
	if link then
		if (GetMouseButtonClicked() == "RightButton") and IsControlKeyDown() then
			mog:AddToPreview(link);
		end
	end
end);

local function hookInspectUI()
	local function inspect_OnClick(self,btn)
		if InspectFrame.unit and self.hasItem then
			if btn == "RightButton" and IsControlKeyDown() then
				mog:AddToPreview(GetInventoryItemID(InspectFrame.unit,GetInventorySlotInfo(self.slot)));
			end
		end
	end
	for k,v in ipairs(mog.slots) do
		_G["Inspect"..v].slot = v;
		_G["Inspect"..v]:RegisterForClicks("AnyUp");
		_G["Inspect"..v]:HookScript("OnClick",inspect_OnClick);
	end
	hookInspectUI = nil;
end
if InspectFrame then
	hookInspectUI();
end

local function hookGuildBankUI()
	local old = GuildBankColumn1Button1:GetScript("OnClick");
	local function guildbank_OnClick(self,btn,...)
		if btn == "RightButton" and IsControlKeyDown() then
			mog:AddToPreview(GetGuildBankItemLink(GetCurrentGuildBankTab(),self:GetID()));
		else
			return old(self,btn,...);
		end
	end
	for column=1,NUM_GUILDBANK_COLUMNS do
		for row=1,NUM_SLOTS_PER_GUILDBANK_GROUP do
			_G["GuildBankColumn"..column.."Button"..row]:SetScript("OnClick",guildbank_OnClick);
		end
	end
	hookGuildBankUI = nil;
end
if GuildBankFrame then
	hookGuildBankUI();
end

local old_SetItemRef = SetItemRef;
function SetItemRef(link,text,btn,...)
	local id = tonumber(link:match("^item:(%d+)"));
	if id and btn == "RightButton" and IsControlKeyDown() then
		mog:AddToPreview(id);
	else
		return old_SetItemRef(link,text,btn,...);
	end
end

mog.view:SetScript("OnEvent",function(self,event,arg1,...)
	if event == "GET_ITEM_INFO_RECEIVED" then
		for k,v in pairs(mog.view.wait) do
			if select(9,GetItemInfo(k)) then
				for i=1,v do
					mog:AddToPreview(k);
				end
				mog.view.wait[k] = nil;
			end
		end
	elseif event == "ADDON_LOADED" then
		if arg1 == "Blizzard_InspectUI" then
			hookInspectUI();
		elseif arg1 == "Blizzard_GuildBankUI" then
			hookGuildBankUI();
		end
	end
end);
mog.view:RegisterEvent("ADDON_LOADED");
mog.view:RegisterEvent("GET_ITEM_INFO_RECEIVED");

StaticPopupDialogs["MOGIT_PREVIEW_ADDITEM"] = {
	text = L["Type the item ID or url in the text box below"],
	button1 = ADD,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 512,
	editBoxWidth = 260,
	OnShow = function(self,item)
		self.editBox:SetFocus();
	end,
	OnAccept = function(self)
		local text = self.editBox:GetText();
		text = text and text:match("(%d+).-$");
		mog:AddToPreview(tonumber(text));
	end,
	OnCancel = function(self) end,
	EditBoxOnEnterPressed = function(self)
		local text = self:GetText();
		text = text and text:match("(%d+).-$");
		mog:AddToPreview(tonumber(text));
		self:GetParent():Hide();
	end,
	EditBoxOnEscapePressed = function(self)
		self:GetParent():Hide();
	end,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["MOGIT_PREVIEW_IMPORT"] = {
	text = L["Copy and paste a Wowhead Compare URL into the text box below to import"],
	button1 = L["Import"],
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 512,
	editBoxWidth = 260,
	OnShow = function(self,item)
		local str;
		for k,v in pairs(mog.view.slots) do
			if v.item then
				if str then
					str = str..":"..v.item;
				else
					str = L["http://www.wowhead.com/"].."compare?items="..v.item;
				end
			end
		end
		self.editBox:SetText(str or "");
		self.editBox:SetFocus();
		self.editBox:HighlightText();
	end,
	OnAccept = function(self)
		local items = self.editBox:GetText();
		items = items and items:match("compare%?items=([^;#]+)");
		if items then
			local tbl = {};
			for item in items:gmatch("([^:]+)") do
				item = item:match("^(%d+)");
				table.insert(tbl,tonumber(item));
			end
			mog:AddToPreview(tbl);
		end
	end,
	OnCancel = function(self) end,
	EditBoxOnEnterPressed = function(self)
		self:GetParent():Hide();
		local items = self:GetText();
		items = items and items:match("compare%?items=([^;#]+)");
		if items then
			local tbl = {};
			for item in items:gmatch("([^:]+)") do
				item = item:match("^(%d+)");
				table.insert(tbl,tonumber(item));
			end
			mog:AddToPreview(tbl);
		end
	end,
	EditBoxOnEscapePressed = function(self)
		self:GetParent():Hide();
	end,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1
};