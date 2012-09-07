local MogIt,mog = ...;
local L = mog.L;


mog.view = CreateFrame("Frame","MogItPreview",UIParent);
mog.view:SetAllPoints(UIParent);
mog.view:SetScript("OnShow",function(self)
	if #mog.previews == 0 then
		mog:CreatePreview();
	end
end);
tinsert(UISpecialFrames,"MogItPreview");
--ShowUIPanel(mog.view);


function mog:ActivatePreview(preview)
	mog.activePreview = preview;
	_G["MogItPreview"..preview.id.."Bg"]:SetVertexColor(0.8,0.3,0.8);
	preview.activate:Disable();
	for k,v in ipairs(mog.previews) do
		if v ~= preview then
			_G["MogItPreview"..v.id.."Bg"]:SetVertexColor(1,1,1);
			v.activate:Enable();
		end
	end
	if mog.db.profile.gridDress == "preview" then
		mog.scroll:update();
	end
end


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
	local delta = ((v > 0 and 0.6) or -0.6);
	if mog.db.profile.sync then
		mog.posZ = mog.posZ + delta;
		for id,model in ipairs(mog.models) do
			mog:PositionModel(model);
		end
		for id,preview in ipairs(mog.previews) do
			mog:PositionModel(preview.model);
		end
	else
		self.parent.data.posZ = (self.parent.data.posZ or mog.posZ or 0) + delta;
		mog:PositionModel(self);
	end
end

local function slotTexture(f,slot,texture)
	SetItemButtonTexture(f.slots[slot],texture or select(2,GetInventorySlotInfo(slot)));
end

local function slotOnEnter(self)
	if self.item then
		mog.ShowItemTooltip(self, self.item);
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
		local preview = self:GetParent();
		mog.view.DelItem(self.slot,preview);
		if mog.db.profile.gridDress == "preview" and mog.activePreview == preview then
			mog.scroll:update();
		end
		slotOnEnter(self);
	else
		mog.Item_OnClick(self,btn,self);
	end
end

local function previewOnClose(self)
	StaticPopup_Show("MOGIT_PREVIEW_CLOSE", nil, nil, self:GetParent());
end

local function previewActivate(self)
	mog:ActivatePreview(self:GetParent());
end
--//


--// Preview Menu
local currentPreview;

local function setDisplayModel(self, arg1)
	currentPreview.data[arg1] = self.value;
	local model = currentPreview.model;
	model.model:SetPosition(0, 0, 0);
	mog:ResetModel(model);
	model.model:Undress();
	mog.DressFromPreview(model.model, currentPreview);
	mog:PositionModel(model);
	CloseDropDownMenus(1);
end

local previewMenu = {
	{
		text = RACE,
		value = "race",
		notCheckable = true,
		hasArrow = true,
	},
	{
		text = L["Gender"],
		value = "gender",
		notCheckable = true,
		hasArrow = true,
	},
	{
		text = L["Add Item"],
		notCheckable = true,
		func = function(self)
			StaticPopup_Show("MOGIT_PREVIEW_ADDITEM", nil, nil, currentPreview);
		end,
	},
	{
		text = L["Chat Link"],
		notCheckable = true,
		func = function(self)
			local tbl = {};
			for k, v in pairs(currentPreview.slots) do
				if v.item then
					table.insert(tbl, v.item);
				end
			end
			ChatEdit_InsertLink(mog:SetToLink(tbl, currentPreview.data.displayRace, currentPreview.data.displayGender));
			--ChatFrame_OpenChat(link);
		end,
	},
	{
		text = L["Import / Export"],
		notCheckable = true,
		func = function(self)
			StaticPopup_Show("MOGIT_PREVIEW_IMPORT", nil, nil, currentPreview);
		end,
	},
	{
		text = L["Equip current gear"],
		notCheckable = true,
		func = function(self)
			for k, v in pairs(currentPreview.slots) do
				mog.view.DelItem(k, currentPreview);
				local slotID = GetInventorySlotInfo(k);
				local item = mog.mogSlots[slotID] and select(6, GetTransmogrifySlotInfo(slotID)) or GetInventoryItemID("player", slotID)
				mog.view.AddItem(item, currentPreview);
			end
			if mog.activePreview == currentPreview and mog.db.profile.gridDress == "preview" then
				mog.scroll:update();
			end
		end,
	},
	{
		text = L["Clear"],
		notCheckable = true,
		func = function(self)
			for k, v in pairs(currentPreview.slots) do
				mog.view.DelItem(k, currentPreview);
			end
			if mog.activePreview == currentPreview and mog.db.profile.gridDress == "preview" then
				mog.scroll:update();
			end
		end,
	},
}

local function previewInitialize(self, level)
	if level == 1 then
		currentPreview = self.parent;
		
		for i, info in ipairs(previewMenu) do
			UIDropDownMenu_AddButton(info, level);
		end
	elseif self.tier[2] == "race" then
		mog:CreateRaceMenu(level, setDisplayModel, self.parent.data.displayRace)
	elseif self.tier[2] == "gender" then
		mog:CreateGenderMenu(level, setDisplayModel, self.parent.data.displayGender)
	end
end
--//


--// Save Menu
local newSet = {items = {}}

local function onClick(self)
	newSet.name = self.value
	wipe(newSet.items)
	for slot, v in pairs(currentPreview.slots) do
		newSet.items[slot] = v.item
	end
	StaticPopup_Show("MOGIT_WISHLIST_OVERWRITE_SET", self.value, nil, newSet)
end

local function newSetOnClick(self)
	wipe(newSet.items)
	newSet.name = "Set "..(#mog.wishlist:GetSets() + 1)
	for slot, v in pairs(currentPreview.slots) do
		newSet.items[slot] = v.item
	end
	StaticPopup_Show("MOGIT_WISHLIST_CREATE_SET", nil, nil, newSet)
end

local function saveInitialize(self, level)
	currentPreview = self.parent;
	
	mog.wishlist:AddSetMenuItems(level, onClick)
	
	local info = UIDropDownMenu_CreateInfo()
	info.text = L["New set"]
	info.func = newSetOnClick
	info.colorCode = GREEN_FONT_COLOR_CODE
	info.notCheckable = true
	UIDropDownMenu_AddButton(info, level)
end
--//


--// Load Menu
local function onClick(self, profile)
	for k, v in pairs(currentPreview.slots) do
		mog.view.DelItem(k,currentPreview)
	end
	for slot, itemID in pairs(mog.wishlist:GetSetItems(self.value, profile)) do
		mog:AddToPreview(itemID,currentPreview)
	end
	CloseDropDownMenus()
end

local function loadInitialize(self, level)
	currentPreview = self.parent;
	
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
			if profile ~= curProfile and mog.wishlist:GetSets(profile) then
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
end;
--//


--// Toolbar
local function helpOnEnter(self)
	self.nt:SetTexture(1,0.82,0,1);
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT");
	GameTooltip:AddLine(L["How to use"]);
	GameTooltip:AddLine(" ");
	GameTooltip:AddLine(L["Basic Controls"]);
	GameTooltip:AddLine(L["Left click and drag horizontally to rotate"],1,1,1);
	GameTooltip:AddLine(L["Left click and drag vertically to zoom"],1,1,1);
	GameTooltip:AddLine(L["Right click and drag to move"],1,1,1);
	GameTooltip:AddLine(L["Click the bottom right corner and drag to resize"],1,1,1);
	GameTooltip:AddLine(L["Click the \"Activate\" button to set this as the active preview"],1,1,1);
	GameTooltip:AddLine(" ");
	GameTooltip:AddLine(L["Slot Controls"]);
	GameTooltip:AddLine(L["Shift + Left click to link an item to chat"],1,1,1);
	GameTooltip:AddLine(L["Ctrl + Left click to try on an item"],1,1,1);
	GameTooltip:AddLine(L["Right click to show the item menu"],1,1,1);
	GameTooltip:AddLine(L["Shift + Right click to show a URL for the item"],1,1,1);
	GameTooltip:AddLine(L["Ctrl + Right click to remove the item from the preview"],1,1,1);
	GameTooltip:Show();
end

local function helpOnLeave(self)
	GameTooltip:Hide();
	self.nt:SetTexture(0,0,0,0);
end

local function createMenuBar(parent)
	local menuBar = mog.CreateMenuBar(parent)
	
	menuBar.preview = menuBar:CreateMenu(L["Preview"], previewInitialize);
	menuBar.preview:SetPoint("TOPLEFT", parent, 62, -31);

	menuBar.load = menuBar:CreateMenu(L["Load"], loadInitialize);
	menuBar.load:SetPoint("LEFT", menuBar.preview, "RIGHT", 5, 0);
	
	menuBar.save = menuBar:CreateMenu(L["Save"], saveInitialize);
	menuBar.save:SetPoint("LEFT", menuBar.load, "RIGHT", 5, 0);
	
	menuBar.help = menuBar:CreateMenu(L["Help"]);
	menuBar.help:SetPoint("LEFT", menuBar.save, "RIGHT", 5, 0);
	menuBar.help:SetScript("OnEnter",helpOnEnter);
	menuBar.help:SetScript("OnLeave",helpOnLeave);
end
--//


--// Preview Frame
mog.previews = {};
mog.previewBin = {};
mog.previewNum = 0;

function mog:CreatePreview()
	if mog.previewBin[1] then
		local f = mog.previewBin[1];
		f.data = {
			displayRace = mog.playerRace,
			displayGender = mog.playerGender,
		};
		f:Show();
		mog:ActivatePreview(f);
		tremove(mog.previewBin,1);
		tinsert(mog.previews, f);
		return f;
	end
	
	mog.previewNum = mog.previewNum + 1;
	local f = CreateFrame("Frame", "MogItPreview"..mog.previewNum, mog.view, "ButtonFrameTemplate");
	f.id = mog.previewNum;
	f.data = {
		displayRace = mog.playerRace,
		displayGender = mog.playerGender,
	};
	
	f:SetPoint("CENTER");
	f:SetSize(335, 385);
	f:SetToplevel(true);
	f:SetClampedToScreen(true);
	f:EnableMouse(true);
	f:SetMovable(true);
	f:SetResizable(true);
	f:Raise();

	_G["MogItPreview"..f.id.."CloseButton"]:SetScript("OnClick",previewOnClose);
	--_G["MogItPreview"..f.id.."Bg"]:SetVertexColor(0.8,0.3,0.8);
	_G["MogItPreview"..f.id.."TitleText"]:SetText(L["Preview %d"]:format(f.id));
	f.portraitFrame:Hide();
	f.topLeftCorner:Show();
	f.topBorderBar:SetPoint("TOPLEFT", f.topLeftCorner, "TOPRIGHT", 0, 0);
	f.leftBorderBar:SetPoint("TOPLEFT", f.topLeftCorner, "BOTTOMLEFT", 0, 0);
	
	f.resize = CreateFrame("Button", nil, f);
	f.resize:SetSize(16, 16);
	f.resize:SetPoint("BOTTOMRIGHT", -4, 3);
	f.resize:EnableMouse(true);
	f.resize:SetHitRectInsets(0, -4, 0, -3)
	f.resize:SetScript("OnMouseDown", resizeOnMouseDown);
	f.resize:SetScript("OnMouseUp", resizeOnMouseUp);
	f.resize:SetScript("OnHide", resizeOnMouseUp);
	f.resize:SetNormalTexture([[Interface\ChatFrame\UI-ChatIM-SizeGrabber-Up]]);
	f.resize:SetPushedTexture([[Interface\ChatFrame\UI-ChatIM-SizeGrabber-Down]])
	f.resize:SetHighlightTexture([[Interface\ChatFrame\UI-ChatIM-SizeGrabber-Highlight]])
	
	f.slots = {};
	for i = 1, 13 do
		local slotIndex = mog:GetSlot(i);
		local slot = CreateFrame("Button", "MogItPreview"..f.id..slotIndex, f, "ItemButtonTemplate");
		slot.slot = slotIndex;
		if i == 1 then
			slot:SetPoint("TOPLEFT", f.Inset, "TOPLEFT", 8, -8);
		elseif i == 8 then
			slot:SetPoint("TOPRIGHT", f.Inset, "TOPRIGHT", -7, -8);
		elseif i == 12 then
			slot:SetPoint("TOP", f.slots[mog:GetSlot(11)], "BOTTOM", 0, -45);
		else
			slot:SetPoint("TOP", f.slots[mog:GetSlot(i-1)], "BOTTOM", 0, -4);
		end
		slot:RegisterForClicks("AnyUp");
		slot:SetScript("OnClick", slotOnClick);
		slot:SetScript("OnEnter", slotOnEnter);
		slot:SetScript("OnLeave", slotOnLeave);
		slot.OnEnter = slotOnEnter;
		f.slots[slotIndex] = slot;
		slotTexture(f, slotIndex);
	end
	
	f.model = mog:CreateModelFrame(f);
	f.model.type = "preview";
	f.model:Show();
	f.model:EnableMouseWheel(true);
	f.model:SetScript("OnMouseWheel", modelOnMouseWheel);
	f.model:SetPoint("TOPLEFT", f.Inset, "TOPLEFT", 49, -8);
	f.model:SetPoint("BOTTOMRIGHT", f.Inset, "BOTTOMRIGHT", -49, 8);
	
	f.activate = CreateFrame("Button", "MogItPreview"..f.id.."Activate", f, "MagicButtonTemplate");
	f.activate:SetText(L["Activate"]);
	f.activate:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 5, 5);
	f.activate:SetWidth(100);
	f.activate:SetScript("OnClick", previewActivate);
	
	f:SetScript("OnMouseDown", f.StartMoving);
	f:SetScript("OnMouseUp", f.StopMovingOrSizing);
	
	createMenuBar(f);
	mog:ActivatePreview(f);
	
	tinsert(mog.previews, f);
	return f;
end

function mog:DeletePreview(f)
	f:Hide();
	f:ClearAllPoints();
	f:SetPoint("CENTER",mog.view,"CENTER");
	for slot,data in pairs(f.slots) do
		mog.view.DelItem(slot,f);
	end
	wipe(f.data);
	tinsert(mog.previewBin,f);
	for k,v in ipairs(mog.previews) do
		if v == f then
			tremove(mog.previews,k);
			break;
		end
	end
	if mog.activePreview == f then
		mog.activePreview = nil;
		if mog.db.profile.gridDress == "preview" then
			mog.scroll:update();
		end
	end
	if #mog.previews == 0 then
		HideUIPanel(mog.view);
	end
end

mog.view.queue = {};
mog.cacheFuncs.PreviewAddItem = function()
	for i,action in ipairs(mog.view.queue) do
		if GetItemInfo(action[1]) then
			mog.view.AddItem(action[1],action[2]);
		end
	end
	wipe(mog.view.queue);
end

mog.playerClass = select(2,UnitClass("PLAYER"));
function mog.view.AddItem(item,preview)
	if not (item and preview) then return end;
	
	local slot,texture = select(9,mog:GetItemInfo(item,"PreviewAddItem"));
	if not slot then
		tinsert(mog.view.queue,{item,preview});
		return;
	end
	
	if mog:GetSlot(slot) then
		if slot == "INVTYPE_2HWEAPON" then
			if mog.playerClass == "WARRIOR" and IsSpellKnown(46917) then
				slot = "INVTYPE_WEAPON";
			end
		end
		
		if slot == "INVTYPE_WEAPON" then
			if (not preview.slots.MainHandSlot.item) or preview.data.twohand then
				slot = "INVTYPE_WEAPONMAINHAND";
			elseif (not preview.slots.SecondaryHandSlot.item) then
				slot = "INVTYPE_WEAPONOFFHAND";
			elseif preview.data.mainhand then
				slot = "INVTYPE_WEAPONMAINHAND";
			else
				slot = "INVTYPE_WEAPONOFFHAND";
			end
		
			if slot == "INVTYPE_2HWEAPON" then
				mog.view.DelItem("SecondaryHandSlot",preview);
				preview.data.twohand = true;
			elseif slot == "INVTYPE_WEAPONMAINHAND" or slot == "INVTYPE_WEAPON" then
				preview.data.twohand = nil;
				preview.data.mainhand = nil;
			elseif slot == "INVTYPE_WEAPONOFFHAND" then
				if preview.data.twohand then
					mog.view.DelItem("MainHandSlot",preview);
				end
				preview.data.twohand = nil;
				preview.data.mainhand = true;
			end
		end
		
		--> Undress/TryOn weapon slots if weapon changed?
		preview.slots[mog:GetSlot(slot)].item = item;
		slotTexture(preview,mog:GetSlot(slot),texture);
		if preview:IsVisible() then
			preview.model.model:TryOn(item);
		end
	end
end

function mog.view.DelItem(slot,preview)
	if not (preview and slot) then return end;
	preview.slots[slot].item = nil;
	slotTexture(preview,slot);
	if preview:IsVisible() then
		preview.model.model:UndressSlot(GetInventorySlotInfo(slot));
	end
end

function mog:AddToPreview(item,preview)
	if not item then return end;
	preview = preview or mog.activePreview or mog:CreatePreview();
	
	ShowUIPanel(mog.view);
	if type(item) == "number" then
		mog.view.AddItem(item,preview);
	elseif type(item) == "string" then
		mog.view.AddItem(tonumber(item:match("item:(%d+)")),preview);
	elseif type(item) == "table" then
		for k,v in pairs(item) do
			mog.view.AddItem(v,preview);
		end
	end
	
	if mog.db.profile.gridDress == "preview" and mog.activePreview == preview then
		mog.scroll:update();
	end
	
	return preview;
end
--//


--// Hooks
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
	if event == "ADDON_LOADED" then
		if arg1 == "Blizzard_InspectUI" then
			hookInspectUI();
		elseif arg1 == "Blizzard_GuildBankUI" then
			hookGuildBankUI();
		end
	end
end);
mog.view:RegisterEvent("ADDON_LOADED");
--//


--// Popups
StaticPopupDialogs["MOGIT_PREVIEW_ADDITEM"] = {
	text = L["Type the item ID or url in the text box below"],
	button1 = ADD,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 512,
	editBoxWidth = 260,
	OnAccept = function(self,preview)
		local text = self.editBox:GetText();
		text = text and text:match("(%d+).-$");
		mog:AddToPreview(tonumber(text),preview);
	end,
	OnCancel = function(self) end,
	EditBoxOnEnterPressed = function(self,preview)
		local text = self:GetText();
		text = text and text:match("(%d+).-$");
		mog:AddToPreview(tonumber(text),preview);
		self:GetParent():Hide();
	end,
	EditBoxOnEscapePressed = function(self)
		self:GetParent():Hide();
	end,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
};

StaticPopupDialogs["MOGIT_PREVIEW_IMPORT"] = {
	text = L["Copy and paste a Wowhead Compare URL into the text box below to import"],
	button1 = L["Import"],
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 512,
	editBoxWidth = 260,
	OnShow = function(self,preview)
		local str;
		for k,v in pairs(preview.slots) do
			if v.item then
				if str then
					str = str..":"..v.item;
				else
					str = L["http://www.wowhead.com/"].."compare?items="..v.item;
				end
			end
		end
		self.editBox:SetText(str or "");
		self.editBox:HighlightText();
	end,
	OnAccept = function(self,preview)
		local items = self.editBox:GetText();
		items = items and items:match("compare%?items=([^;#]+)");
		if items then
			local tbl = {};
			for item in items:gmatch("([^:]+)") do
				item = item:match("^(%d+)");
				table.insert(tbl,tonumber(item));
			end
			mog:AddToPreview(tbl,preview);
		end
	end,
	OnCancel = function(self) end,
	EditBoxOnEnterPressed = function(self,preview)
		self:GetParent():Hide();
		local items = self:GetText();
		items = items and items:match("compare%?items=([^;#]+)");
		if items then
			local tbl = {};
			for item in items:gmatch("([^:]+)") do
				item = item:match("^(%d+)");
				table.insert(tbl,tonumber(item));
			end
			mog:AddToPreview(tbl,preview);
		end
	end,
	EditBoxOnEscapePressed = function(self)
		self:GetParent():Hide();
	end,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
};

StaticPopupDialogs["MOGIT_PREVIEW_CLOSE"] = {
	text = L["Are you sure you want to close this set?"],
	button1 = YES,
	button2 = NO,
	OnAccept = function(self, frame)
		mog:DeletePreview(frame);
	end,
	hideOnEscape = true,
	whileDead = true,
	timeout = 0,
}
--//


--[[
One-Handed Weapon Logic
- First goes into main hand, then alternates
- Equipping 2h weapon causes to next to go into main hand
- Equipping a right handed ranged weapon (gun, crossbow, thrown) will cause the next two one hand weapons to go into main hand (above rule still applies)
]]