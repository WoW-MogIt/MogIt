local MogIt,mog = ...;
local L = mog.L;

local LBI = LibStub("LibBabble-Inventory-3.0"):GetUnstrictLookupTable();


mog.view = CreateFrame("Frame","MogItPreview",UIParent);
mog.view:SetAllPoints();
mog.view:SetScript("OnShow",function(self)
	if #mog.previews == 0 then
		mog:CreatePreview();
	end
	if mog.db.profile.singlePreview then
		ShowUIPanel(mog.previews[1]);
	end
end);
mog.view:SetScript("OnHide",function(self)
	if mog.db.profile.singlePreview then
		HideUIPanel(mog.previews[1]);
	end
end);
tinsert(UISpecialFrames,"MogItPreview");
--ShowUIPanel(mog.view);


function mog:ActivatePreview(preview)
	mog.activePreview = preview;
	preview.Bg:SetVertexColor(0.8,0.3,0.8);
	preview.activate:Disable();
	for k,v in ipairs(mog.previews) do
		if v ~= preview then
			v.Bg:SetVertexColor(1,1,1);
			v.activate:Enable();
		end
	end
	if mog.db.profile.gridDress == "preview" then
		mog:UpdateScroll();
	end
end


--// Preview Functions
local function raiseAll(self, ...)
	local newLevel = self:GetFrameLevel() + 1
	for i = 1, select("#", ...) do
		select(i, ...):SetFrameLevel(newLevel)
	end
end

local function stopMovingOrSizing(self)
	self:StopMovingOrSizing();
	local frameProps = mog.db.profile.previewProps[self:GetID()];
	frameProps.point, frameProps.x, frameProps.y = select(3, self:GetPoint());
end

local function resizeOnMouseDown(self)
	local f = self:GetParent();
	f:SetMinResize(335,385);
	f:SetMaxResize(GetScreenWidth(),GetScreenHeight());
	f:StartSizing();
end

local function resizeOnMouseUp(self)
	if mog.db.profile.singlePreview and mog.db.profile.previewUIPanel and mog.db.profile.previewFixedSize then return end
	local f = self:GetParent();
	f:StopMovingOrSizing();
	local frameProps = mog.db.profile.previewProps[f:GetID()];
	frameProps.w, frameProps.h = f:GetSize();
	-- anchors may change from resizing
	if not (mog.db.profile.singlePreview and mog.db.profile.previewUIPanel) then
		frameProps.point, frameProps.x, frameProps.y = select(3, f:GetPoint());
		UpdateUIPanelPositions(f)
	end
end

local function modelOnMouseWheel(self, v)
	local delta = ((v > 0 and 0.6) or -0.6);
	if mog.db.profile.sync then
		mog.posZ = mog.posZ + delta;
		for id, model in ipairs(mog.models) do
			model:PositionModel();
		end
		for id, preview in ipairs(mog.previews) do
			preview.model:PositionModel();
		end
	else
		self.parent.data.posZ = (self.parent.data.posZ or mog.posZ or 0) + delta;
		self:PositionModel();
	end
end

local function slotTexture(f, slot, texture)
	f.slots[slot].icon:SetTexture(texture or select(2, GetInventorySlotInfo(slot)));
end

local function slotOnEnter(self)
	if self.item then
		mog.ShowItemTooltip(self, self.item, mog:GetData("display", mog:GetData("item", self.item, "display"), "items"));
	else
		GameTooltip:SetOwner(self,"ANCHOR_RIGHT");
		GameTooltip:SetText(_G[strupper(self.slot)]);
	end
end

local function historyOnClick(self, item, data)
	mog.view.AddItem(item, data:GetParent(), data.slot)
end

local function previewSlotHistory(self, level, data)
	data = self.data
	if not data.isPreview then return end
	if #data.history == 0 then return end
	local info = UIDropDownMenu_CreateInfo()
	info.text = L["Previous items"]
	info.isTitle = true
	info.notCheckable = true
	self:AddButton(info)
	for i, item in ipairs(data.history) do
		local info = UIDropDownMenu_CreateInfo()
		info.text = mog:GetItemLabel(item)
		info.func = historyOnClick
		info.arg1 = item
		info.arg2 = data
		info.notCheckable = true
		self:AddButton(info)
	end
end

mog:AddItemOption(previewSlotHistory)

local function slotOnClick(self, button)
	if button == "RightButton" and IsControlKeyDown() then
		local preview = self:GetParent();
		mog.view.DelItem(self.slot, preview);
		mog.Item_Menu:Close()
		if mog.db.profile.gridDress == "preview" and mog.activePreview == preview then
			mog:UpdateScroll();
		end
		self:OnEnter();
	else
		mog.Item_OnClick(self, button, self, nil, true);
		-- dropdown is normally not shown for empty slots
		if button == "RightButton" and not self.item then
			if mog.Item_Menu.data ~= self then
				mog.Item_Menu:Hide(1)
			end
			self.isPreview = true
			mog.Item_Menu.data = self
			mog.Item_Menu:Toggle(nil, "cursor", nil, nil, previewSlotHistory)
		end
	end
end

local function previewOnClose(self)
	if mog.db.profile.singlePreview then
		mog.view:Hide();
	elseif mog.db.profile.previewConfirmClose then
		StaticPopup_Show("MOGIT_PREVIEW_CLOSE", nil, nil, self:GetParent());
	else
		mog:DeletePreview(self:GetParent());
	end
end

local function previewActivate(self)
	mog:ActivatePreview(self:GetParent());
end
--//


--// Preview Menu
local currentPreview;

local function setDisplayModel(self, arg1, value)
	currentPreview.data[arg1] = value;
	local model = currentPreview.model;
	model:ResetModel();
	model:Undress();
	mog.DressFromPreview(model, currentPreview);
	CloseDropDownMenus();
end

local function setWeaponEnchant(self, preview, enchant)
	preview.data.weaponEnchant = enchant;
	self.owner:Rebuild(2);
	mog:UpdateScroll();
	local mainHandItem = preview.slots["MainHandSlot"].item;
	local offHandItem = preview.slots["SecondaryHandSlot"].item;
	if mainHandItem then
		preview.model:TryOn(format("item:%s:%d", mainHandItem:match("item:(%d+)"), preview.data.weaponEnchant), "MainHandSlot");
	end
	if offHandItem then
		preview.model:TryOn(format("item:%s:%d", offHandItem:match("item:(%d+)"), preview.data.weaponEnchant), "SecondaryHandSlot");
	end
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
		text = L["Weapon enchant"],
		value = "weaponEnchant",
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
			ChatEdit_InsertLink(mog:SetToLink(tbl, currentPreview.data.displayRace, currentPreview.data.displayGender, currentPreview.data.weaponEnchant));
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
				local item = GetInventoryItemLink("player", slotID);
				if mog.mogSlots[slotID] then
					local isTransmogrified, _, _, _, _, _, isHideVisual, texture = C_Transmog.GetSlotInfo(slotID, LE_TRANSMOG_TYPE_APPEARANCE);
					local baseSourceID, baseVisualID, appliedSourceID, appliedVisualID = C_Transmog.GetSlotVisualInfo(slotID, LE_TRANSMOG_TYPE_APPEARANCE);
					if isTransmogrified then
						if isHideVisual then
							item = nil
						else
							local categoryID, appearanceVisualID, canEnchant, icon, isCollected, link = C_TransmogCollection.GetAppearanceSourceInfo(appliedSourceID)
							item = link;
						end
					end
				end
				if item then
					mog.view.AddItem(item, currentPreview);
				end
			end
			if mog.activePreview == currentPreview and mog.db.profile.gridDress == "preview" then
				mog:UpdateScroll();
			end
		end,
	},
	{
		text = L["Clear"],
		notCheckable = true,
		func = function(self)
			mog.view:Undress(currentPreview);
			if mog.activePreview == currentPreview and mog.db.profile.gridDress == "preview" then
				mog:UpdateScroll();
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
		mog:CreateRaceMenu(self, level, setDisplayModel, self.parent.data.displayRace)
	elseif self.tier[2] == "gender" then
		mog:CreateGenderMenu(self, level, setDisplayModel, self.parent.data.displayGender)
	elseif self.tier[2] == "weaponEnchant" then
		if level == 2 then
			local info = UIDropDownMenu_CreateInfo();
			info.text = NONE;
			info.func = setWeaponEnchant;
			info.arg1 = self.parent;
			info.arg2 = nil;
			info.checked = (self.parent.data.weaponEnchant == nil);
			info.keepShownOnClick = true;
			self:AddButton(info, level);
			
			for i, enchantCategory in ipairs(mog.enchants) do
				local info = UIDropDownMenu_CreateInfo();
				info.text = enchantCategory.name;
				info.value = enchantCategory;
				info.notCheckable = true;
				info.hasArrow = true;
				info.keepShownOnClick = true;
				self:AddButton(info, level);
			end
		elseif level == 3 then
			for i, enchant in ipairs(self.tier[3]) do
				local info = UIDropDownMenu_CreateInfo();
				info.text = enchant.name;
				info.func = setWeaponEnchant;
				info.arg1 = self.parent;
				info.arg2 = enchant.id;
				info.checked = (self.parent.data.weaponEnchant == enchant.id);
				info.keepShownOnClick = true;
				self:AddButton(info, level);
			end
		end
	end
end
--//


--// Save Menu
local newSet = {items = {}}

local function onClick(self, set)
	newSet.name = set
	newSet.previewFrame = currentPreview
	wipe(newSet.items)
	for slot, v in pairs(currentPreview.slots) do
		newSet.items[slot] = v.item
	end
	StaticPopup_Show("MOGIT_WISHLIST_OVERWRITE_SET", set, nil, newSet)
end

local function newSetOnClick(self)
	wipe(newSet.items)
	newSet.name = "Set "..(#mog.wishlist:GetSets() + 1)
	newSet.previewFrame = currentPreview
	for slot, v in pairs(currentPreview.slots) do
		newSet.items[slot] = v.item
	end
	StaticPopup_Show("MOGIT_WISHLIST_CREATE_SET", nil, nil, newSet)
end

local function saveInitialize(self, level)
	currentPreview = self.parent;
	
	local info = UIDropDownMenu_CreateInfo()
	info.text = L["New set..."]
	info.func = newSetOnClick
	info.colorCode = GREEN_FONT_COLOR_CODE
	info.notCheckable = true
	self:AddButton(info, level)
	
	mog.wishlist:AddSetMenuItems(level, onClick)
end
--//


--// Load Menu
local function onClick(self, set, profile)
	mog:AddToPreview(mog.wishlist:GetSetItems(set, profile), currentPreview, set)
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
		self:AddButton(info, level)
	elseif level == 2 then
		local curProfile = mog.wishlist:GetCurrentProfile()
		for i, profile in ipairs(mog.wishlist:GetProfiles()) do
			if profile ~= curProfile and mog.wishlist:GetSets(profile) then
				local info = UIDropDownMenu_CreateInfo()
				info.text = profile
				info.hasArrow = true
				info.notCheckable = true
				self:AddButton(info, level)
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
local function initPreview(frame, id)
	frame:SetID(id);
	local props = mog.db.profile.previewProps[id];
	frame:ClearAllPoints();
	frame:SetPoint(props.point, props.x, props.y);
	frame:SetSize(props.w, props.h);
	frame.TitleText:SetText(L["Preview %d"]:format(id));
	frame.data = {
		displayRace = mog.playerRace,
		displayGender = mog.playerGender,
	};
end

mog.previews = {};
mog.previewBin = {};
mog.previewNum = 0;

function mog:CreatePreview()
	if mog.previewBin[1] then
		local f = mog.previewBin[1];
		local leastIndex = #mog.previews + 1;
		-- find the lowest unused frame ID
		for i, v in ipairs(self.previewBin) do
			leastIndex = min(v:GetID(), leastIndex);
		end
		initPreview(f, leastIndex);
		f:Show();
		mog:ActivatePreview(f);
		tremove(mog.previewBin,1);
		tinsert(mog.previews, f);
		return f;
	end
	
	mog.previewNum = mog.previewNum + 1;
	local id = mog.previewNum;
	local f = CreateFrame("Frame", "MogItPreview"..id, mog.view, "ButtonFrameTemplate");
	initPreview(f, id);
	
	f:SetToplevel(true);
	f:SetClampedToScreen(true);
	f:EnableMouse(true);
	f:SetMovable(true);
	f:SetResizable(true);
	f:Raise();
	
	f.onCloseCallback = previewOnClose;
	f.Bg = _G["MogItPreview"..id.."Bg"];
	--f.Bg:SetVertexColor(0.8,0.3,0.8);
	ButtonFrameTemplate_HidePortrait(f);
	
	f.resize = CreateFrame("Button", nil, f);
	f.resize:SetSize(16, 16);
	f.resize:SetPoint("BOTTOMRIGHT", -4, 3);
	f.resize:EnableMouse(true);
	f.resize:SetHitRectInsets(0, -4, 0, -3);
	f.resize:SetScript("OnMouseDown", resizeOnMouseDown);
	f.resize:SetScript("OnMouseUp", resizeOnMouseUp);
	f.resize:SetScript("OnHide", resizeOnMouseUp);
	f.resize:SetNormalTexture([[Interface\ChatFrame\UI-ChatIM-SizeGrabber-Up]]);
	f.resize:SetPushedTexture([[Interface\ChatFrame\UI-ChatIM-SizeGrabber-Down]])
	f.resize:SetHighlightTexture([[Interface\ChatFrame\UI-ChatIM-SizeGrabber-Highlight]])
	
	f.slots = {};
	for i, slotIndex in ipairs(mog.slots) do
		local slot = CreateFrame("Button", nil, f, "ItemButtonTemplate");
		slot.slot = slotIndex;
		if i == 1 then
			slot:SetPoint("TOPLEFT", f.Inset, "TOPLEFT", 8, -8);
		elseif i == 8 then
			slot:SetPoint("TOPRIGHT", f.Inset, "TOPRIGHT", -7, -8);
		elseif i == 12 then
			slot:SetPoint("TOP", f.slots[mog:GetSlot(i-1)], "BOTTOM", 0, -45);
		else
			slot:SetPoint("TOP", f.slots[mog:GetSlot(i-1)], "BOTTOM", 0, -4);
		end
		slot:RegisterForClicks("AnyUp");
		slot:SetScript("OnClick", slotOnClick);
		slot:SetScript("OnEnter", slotOnEnter);
		slot:SetScript("OnLeave", GameTooltip_Hide);
		slot.OnEnter = slotOnEnter;
		slot.history = {};
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
	
	f.activate = CreateFrame("Button", "MogItPreview"..id.."Activate", f, "MagicButtonTemplate");
	f.activate:SetText(L["Activate"]);
	f.activate:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 5, 5);
	f.activate:SetWidth(100);
	f.activate:SetScript("OnClick", previewActivate);
	
	f:SetScript("OnMouseDown", f.StartMoving);
	f:SetScript("OnMouseUp", stopMovingOrSizing);
	
	createMenuBar(f);
	mog:ActivatePreview(f);
	
	-- child frames occasionally appears behind the parent for whatever reason, so we raise them here
	raiseAll(f, f:GetChildren())
	
	tinsert(mog.previews, f);
	return f;
end

function mog:DeletePreview(f)
	HideUIPanel(f);
	f:ClearAllPoints();
	f:SetPoint("CENTER",mog.view,"CENTER");
	mog.view:Undress(f);
	wipe(f.data);
	for k, slot in pairs(f.slots) do
		slot.history = {};
	end
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
			mog:UpdateScroll();
		end
	end
	if #mog.previews == 0 then
		HideUIPanel(mog.view);
	end
end

function mog:GetPreview(frame)
	if self.db.profile.singlePreview then
		frame = self.previews[1];
	end

	return frame or self:CreatePreview();
end

function mog:SetSinglePreview(isSinglePreview)
	for i = #mog.previews, 1, -1 do
		mog:DeletePreview(mog.previews[i]);
	end
	if isSinglePreview then
		-- hack to make sure CreatePreview gets the frame named MogItPreview1
		if #mog.previewBin > 1 and mog.previewBin[1] ~= MogItPreview1 then
			for i = 2, #mog.previewBin do
				if mog.previewBin[i] == MogItPreview1 then
					tremove(mog.previewBin, i);
					tinsert(mog.previewBin, 1, MogItPreview1);
					break;
				end
			end
		end
		mog:CreatePreview();
	end
	if MogItPreview1 then
		mog:SetPreviewUIPanel(mog.db.profile.previewUIPanel);
	end
	mog:SetPreviewMenu(isSinglePreview);
end

function mog:SetPreviewUIPanel(isUIPanel)
	if isUIPanel and mog.db.profile.singlePreview then
		MogItPreview1:SetScript("OnMouseDown", nil);
		MogItPreview1:SetScript("OnMouseUp", nil);
		MogItPreview1:SetScript("OnHide", HideParentPanel);
		UIPanelWindows["MogItPreview1"] = {
			area = "left",
			pushable = 1,
			whileDead = true,
		}
		HideUIPanel(MogItPreview1);
	else
		local props = mog.db.profile.previewProps[1];
		local point, x, y = props.point, props.x, props.y;
		HideUIPanel(MogItPreview1);
		MogItPreview1:SetScript("OnMouseDown", MogItPreview1.StartMoving);
		MogItPreview1:SetScript("OnMouseUp", stopMovingOrSizing);
		MogItPreview1:SetScript("OnHide", nil);
		UIPanelWindows["MogItPreview1"] = nil;
		MogItPreview1:SetAttribute("UIPanelLayout-defined", nil);
		MogItPreview1:ClearAllPoints();
		MogItPreview1:SetPoint(point, x, y);
	end
	mog:SetPreviewFixedSize(mog.db.profile.previewFixedSize);
end

function mog:SetPreviewFixedSize(isFixedSize)
	local isUIPanel = mog.db.profile.previewUIPanel;
	if isFixedSize and isUIPanel then
		MogItPreview1:SetSize(PANEL_DEFAULT_WIDTH, PANEL_DEFAULT_HEIGHT);
	else
		local props = mog.db.profile.previewProps[1];
		MogItPreview1:SetSize(props.w, props.h);
	end
	MogItPreview1.resize:SetShown(not (isUIPanel and isFixedSize));
	UpdateUIPanelPositions(MogItPreview1);
end

local cachedPreviews;
local doCache = {};
mog:AddItemCacheCallback("PreviewAddItem", function()
	cachedPreviews = {};
	for i = #doCache, 1, -1 do
		local item = doCache[i];
		if mog:GetItemInfo(item.id) then
			cachedPreviews[item.frame] = true;
			mog.view.AddItem(item.id, item.frame, item.slot, item.set);
			tremove(doCache, i);
		end
	end
	-- update the grid if using preview grid dress, and an item was cached on the active preview
	if mog.db.profile.gridDress == "preview" and cachedPreviews[mog.activePreview] then
		mog:UpdateScroll();
	end
end)

local playerClass = select(2, UnitClass("player"));

function mog.view.AddItem(item, preview, forceSlot, setItem)
	if not (item and preview) then return end;
	
	local itemID, bonusID = item
	if type(item) == "string" then
		itemID, bonusID = mog:ToNumberItem(item);
	end
	item = mog:ToStringItem(itemID, bonusID);
	
	local itemInfo = mog:GetItemInfo(item, "PreviewAddItem");
	if not itemInfo then
		tinsert(doCache, {
			id = item,
			frame = preview,
			slot = forceSlot,
			set = setItem,
		});
		return;
	end
	local invType = itemInfo.invType;
	
	local slot = mog:GetSlot(invType);
	if type(forceSlot) == "string" then
		slot = forceSlot;
	end
	if slot then
		if slot == "MainHandSlot" or slot == "SecondaryHandSlot" then
			if invType == "INVTYPE_2HWEAPON" then
				if playerClass == "WARRIOR" and IsSpellKnown(23588) then
					-- Titan's Grip exists in the spellbook, so we can treat this weapon as one handed
					invType = "INVTYPE_WEAPON";
				end
			end
			
			if invType == "INVTYPE_WEAPON" then
				-- put one handed weapons in the off hand if: main hand is occupied, off hand is free and a two handed weapon isn't equipped
				if preview.slots["MainHandSlot"].item and not preview.slots["SecondaryHandSlot"].item and not preview.data.twohand then
					slot = "SecondaryHandSlot";
				end
			end
			
			if invType == "INVTYPE_2HWEAPON" or invType == "INVTYPE_RANGED" or (invType == "INVTYPE_RANGEDRIGHT" and itemInfo.subType ~= LBI["Wands"]) then
				-- if any two handed weapon is being equipped, first clear up both hands
				mog.view.DelItem("MainHandSlot", preview);
				mog.view.DelItem("SecondaryHandSlot", preview);
				preview.data.twohand = true;
			elseif preview.data.twohand then
				preview.data.twohand = false;
				if slot == "MainHandSlot" then
					mog.view.DelItem("SecondaryHandSlot", preview);
				elseif slot == "SecondaryHandSlot" then
					mog.view.DelItem("MainHandSlot", preview);
				end
			end
		end
		
		if item ~= preview.slots[slot].item then
			local history = preview.slots[slot].history
			for i, v in ipairs(history) do
				if v == item then
					tremove(history, i);
					break;
				end
			end
			if preview.slots[slot].item then
				tinsert(history, 1, preview.slots[slot].item);
				-- make sure there's never more than five items
				history[6] = nil;
			end
		end
		preview.slots[slot].item = item;
		slotTexture(preview, slot, GetItemIcon(item));
		if preview:IsVisible() then
			if (slot == "MainHandSlot" or slot == "SecondaryHandSlot") and preview.data.weaponEnchant then
				item = format(gsub(item, "item:(%d+):0", "item:%1:%%d"), preview.data.weaponEnchant);
			end
			if invType == "INVTYPE_RANGED" then
				slot = "SecondaryHandSlot";
			end
			preview.model:TryOn(item, slot);
			if preview.data.title and not setItem then
				preview.TitleText:SetText("*"..preview.data.title);
			end
		end
	end
end

function mog.view.DelItem(slot, preview)
	if not (preview and slot) or not preview.slots[slot].item then return end;
	local invType = mog:GetItemInfo(preview.slots[slot].item).invType;
	local history = preview.slots[slot].history
	tinsert(history, 1, preview.slots[slot].item);
	-- make sure there's never more than five items
	history[6] = nil;
	preview.slots[slot].item = nil;
	slotTexture(preview,slot);
	if preview.data.title then
		preview.TitleText:SetText("*"..preview.data.title);
	end
	if preview:IsVisible() then
		if invType == "INVTYPE_RANGED" then
			slot = "SecondaryHandSlot"
		end
		preview.model:UndressSlot(GetInventorySlotInfo(slot));
	end
end

function mog:AddToPreview(item, preview, title)
	if not item then return end;
	preview = mog:GetPreview(preview or mog.activePreview);
	
	ShowUIPanel(mog.view);
	if type(item) == "table" then
		mog.view:Undress(preview);
		for k, v in pairs(item) do
			mog.view.AddItem(v, preview, k, true);
		end
		if title then
			preview.TitleText:SetText(title);
			preview.data.title = title;
		end
	else
		mog.view.AddItem(item, preview);
	end
	
	if mog.db.profile.gridDress == "preview" and mog.activePreview == preview then
		mog:UpdateScroll();
	end
	
	return preview;
end

function mog.view:Undress(preview)
	for k, v in pairs(preview.slots) do
		mog.view.DelItem(k, preview);
	end
end
--//


--// Hooks
if not ModifiedItemClickHandlers then
	ModifiedItemClickHandlers = {};
	
	local origHandleModifiedItemClick = HandleModifiedItemClick;
	
	function HandleModifiedItemClick(link)
		if not link then
			return false;
		end
		for i, v in ipairs(ModifiedItemClickHandlers) do
			if v(link) then
				return true;
			end
		end
		return origHandleModifiedItemClick(link);
	end
end

-- hack to allow post hooking SetItemRef for previewing
tinsert(ModifiedItemClickHandlers, function(link)
	local button = GetMouseButtonClicked()
	if button then
		if link and IsDressableItem(link) then
			if IsModifiedClick("DRESSUP") then
				return DressUpItemLink(link);
			elseif IsControlKeyDown() and button == "RightButton" then
				mog:AddToPreview(link);
				return true;
			end
		end
	elseif IsModifiedClick("DRESSUP") then
		-- if no mouse button was detected, this happened through a chat link
		-- if it's a dressup modified click and a dressable item, intercept the call here and let SetItemRef hook handle it
		return link and IsDressableItem(link);
	end
	local _, staticPopup = StaticPopup_Visible("MOGIT_PREVIEW_ADDITEM");
	if IsModifiedClick("CHATLINK") and staticPopup then
		staticPopup.editBox:SetText(link);
		return true
	end
end);

hooksecurefunc("SetItemRef", function(link, text, button, chatFrame)
	local id = tonumber(link:match("^item:(%d+)"));
	if link:match("item:%d+") and IsModifiedClick("DRESSUP") then
		if button == "RightButton" then
			mog:AddToPreview(link);
		else
			DressUpItemLink(link);
		end
	end
end)

local origDressUpItemLink = DressUpItemLink;
function DressUpItemLink(link)
	if not (link and IsDressableItem(link)) then
		return false;
	end
	if mog.db.profile.dressupPreview then
		mog:AddToPreview(link);
		return true;
	end
	return origDressUpItemLink(link);
end

local function hookInspectUI()
	local function onClick(self, button)
		if InspectFrame.unit and self.hasItem and IsControlKeyDown() and button == "RightButton" then
			-- GetInventoryItemID actually returns the transmogged-into item for inspect units
			mog:AddToPreview((GetInventoryItemID(InspectFrame.unit, self:GetID())));
		else
			HandleModifiedItemClick(GetInventoryItemLink(InspectFrame.unit, self:GetID()));
		end
	end
	for k, v in ipairs(mog.slots) do
		_G["Inspect"..v]:RegisterForClicks("AnyUp");
		_G["Inspect"..v]:SetScript("OnClick", onClick);
	end
	hookInspectUI = nil;
end

if InspectFrame then
	hookInspectUI();
else
	mog.view:SetScript("OnEvent",function(self,event,addon)
		if addon == "Blizzard_InspectUI" then
			hookInspectUI();
			self:UnregisterEvent(event);
			self:SetScript("OnEvent", nil);
		end
	end);
	mog.view:RegisterEvent("ADDON_LOADED");
end
--//


--// Popups
local function onAccept(self, preview)
	local text = self.editBox:GetText();
	if text then
		local id,bonus = mog:ToNumberItem(text);
		if not id then
			id,bonus = text:match("item=(%d+)"),text:match("bonus=(%d+)");
		end
		if not id then
			id = text:match("(%d+).-$");
			bonus = nil;
		end
		mog:AddToPreview(mog:ToStringItem(tonumber(id),tonumber(bonus)), preview);
	end
end

StaticPopupDialogs["MOGIT_PREVIEW_ADDITEM"] = {
	text = L["Type the item ID or url in the text box below"],
	button1 = ADD,
	button2 = CANCEL,
	hasEditBox = true,
	maxLetters = 512,
	editBoxWidth = 260,
	OnAccept = onAccept,
	EditBoxOnEnterPressed = function(self, data)
		local parent = self:GetParent();
		onAccept(parent, data);
		parent:Hide();
	end,
	EditBoxOnEscapePressed = HideParentPanel;
	exclusive = true,
	whileDead = true,
};

local function onAccept(self, preview)
	local items = self.editBox:GetText();
	items = items and items:match("compare%?items=([^#]+)");
	if items then
		local tbl = {};
		for item in items:gmatch("([^:;]+)") do
			local id, bonus = item:match("^(%d+)%.%d+%.%d+%.%d+%.%d+%.%d+%.%d+%.%d+%.%d+%.%d+%.(%d+)");
			id = id or item:match("^(%d+)");
			table.insert(tbl, mog:ToStringItem(tonumber(id), tonumber(bonus)));
		end
		mog:AddToPreview(tbl, preview);
	end
end

StaticPopupDialogs["MOGIT_PREVIEW_IMPORT"] = {
	text = L["Copy and paste a Wowhead Compare URL into the text box below to import"],
	button1 = L["Import"],
	button2 = CANCEL,
	hasEditBox = true,
	maxLetters = 512,
	editBoxWidth = 260,
	OnShow = function(self, preview)
		local str;
		for k, v in pairs(preview.slots) do
			if v.item then
				local id,bonus = mog:ToNumberItem(v.item);
				str = (str and str..":" or L["http://www.wowhead.com/"].."compare?items=")..id..(bonus and ".0.0.0.0.0.0.0.0.0."..bonus or "")
			end
		end
		self.editBox:SetText(str or "");
		self.editBox:HighlightText();
	end,
	OnAccept = onAccept,
	EditBoxOnEnterPressed = function(self, data)
		local parent = self:GetParent();
		onAccept(parent, data);
		parent:Hide();
	end,
	EditBoxOnEscapePressed = HideParentPanel,
	exclusive = true,
	whileDead = true,
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
}