local MogIt,mog = ...;
local L = mog.L;

local GetCursorPosition = GetCursorPosition;
local ipairs = ipairs;

mog.view = CreateFrame("Frame","MogItPreview",mog.container,"BasicFrameTemplate");
mog.view:Hide();
mog.view:SetPoint("CENTER",UIParent,"CENTER");
mog.view:SetSize(310,313);
mog.view:SetToplevel(true);
mog.view:SetClampedToScreen(true);
mog.view:EnableMouse(true);
mog.view:SetMovable(true);
mog.view:SetResizable(true);
mog.view:SetUserPlaced(true);
mog.view:SetScript("OnMouseDown",mog.view.StartMoving);
mog.view:SetScript("OnMouseUp",mog.view.StopMovingOrSizing);
MogItPreviewTitleText:SetText(L["Preview"]);

mog.view.resize = CreateFrame("Frame",nil,mog.view);
mog.view.resize:SetSize(16,16);
mog.view.resize:SetPoint("BOTTOMRIGHT",mog.view,"BOTTOMRIGHT",-1,0);
mog.view.resize:EnableMouse(true);
mog.view.resize:SetScript("OnMouseDown",function(self)
	mog.view:SetMinResize(310,313);
	mog.view:SetMaxResize(GetScreenWidth(),GetScreenHeight());
	mog.view:StartSizing();
end);
mog.view.resize:SetScript("OnMouseUp",function(self)
	mog.view:StopMovingOrSizing();
end);
mog.view.resize:SetScript("OnHide",mog.view.resize:GetScript("OnMouseUp"));
mog.view.resize.texture = mog.view.resize:CreateTexture(nil,"OVERLAY");
mog.view.resize.texture:SetSize(16,16);
mog.view.resize.texture:SetTexture("Interface\\AddOns\\MogIt\\Images\\Resize");
mog.view.resize.texture:SetPoint("BOTTOMRIGHT",mog.view.resize,"BOTTOMRIGHT",-3,3);

mog.view.btnAdd = CreateFrame("Button","MogItViewBtnAdd",mog.view,"UIPanelButtonTemplate2");
mog.view.btnAdd:SetSize(110,22);
mog.view.btnAdd:SetText(L["Add Item"]);
mog.view.btnAdd:SetPoint("TOPRIGHT",mog.view,"TOP",0,-23);
mog.view.btnAdd:SetScript("OnClick",function(self)
	StaticPopup_Show("MOGIT_PREVIEW_ADDITEM");
end);

mog.view.btnImport = CreateFrame("Button","MogItViewBtnImport",mog.view,"UIPanelButtonTemplate2");
mog.view.btnImport:SetSize(110,22);
mog.view.btnImport:SetText(L["Import/Export"]);
mog.view.btnImport:SetPoint("TOPLEFT",mog.view,"TOP",0,-23);
mog.view.btnImport:SetScript("OnClick",function(self)
	StaticPopup_Show("MOGIT_PREVIEW_IMPORT");
end);

mog.view.btnSave = CreateFrame("Button","MogItViewBtnSave",mog.view,"UIPanelButtonTemplate2");
mog.view.btnSave:SetSize(110,22);
mog.view.btnSave:SetText(SAVE);
mog.view.btnSave:SetPoint("BOTTOMRIGHT",mog.view,"BOTTOM",0,4);
mog.view.btnSave:SetScript("OnClick",function(self)
	ToggleDropDownMenu(nil,nil,mog.view.btnSaveDD,self,0,0);
end);
mog.view.btnSaveDD = CreateFrame("Frame");
mog.view.btnSaveDD.displayMode = "MENU";
mog.view.btnSaveDD.wlSave = true;
mog.view.btnSaveDD.initialize = mog.wlMenu;

mog.view.btnClear = CreateFrame("Button","MogItViewBtnClear",mog.view,"UIPanelButtonTemplate2");
mog.view.btnClear:SetSize(110,22);
mog.view.btnClear:SetText(L["Clear"]);
mog.view.btnClear:SetPoint("BOTTOMLEFT",mog.view,"BOTTOM",0,4);
mog.view.btnClear:SetScript("OnClick",function(self)
	mog.view.model.model:Undress();
	for k,v in ipairs(mog.view.slots) do
		wipe(v.list);
		v.item = nil;
		mog.view.setTexture(k);
	end
	if mog.global.gridDress then
		mog.scroll:update();
	end
end);

mog.itemSlots = {
	"HeadSlot",
	"ShoulderSlot",
	"BackSlot",
	"ChestSlot",
	"ShirtSlot",
	"TabardSlot",
	"WristSlot",
	"HandsSlot",
	"WaistSlot",
	"LegsSlot",
	"FeetSlot",
	"MainHandSlot",
	"SecondaryHandSlot",
	"RangedSlot",
};

mog.invSlots = {
	INVTYPE_HEAD = 1,
	INVTYPE_SHOULDER = 2,
	INVTYPE_CLOAK = 3,
	INVTYPE_CHEST = 4,
	INVTYPE_ROBE = 4,
	INVTYPE_WRIST = 7,
	INVTYPE_2HWEAPON = 12,
	INVTYPE_WEAPON = 12,
	INVTYPE_WEAPONMAINHAND = 12,
	INVTYPE_WEAPONOFFHAND = 13,
	INVTYPE_SHIELD = 13,
	INVTYPE_HOLDABLE = 13,
	INVTYPE_RANGED = 14,
	INVTYPE_RANGEDRIGHT = 14,
	INVTYPE_THROWN = 14,
	INVTYPE_HAND = 8,
	INVTYPE_WAIST = 9,
	INVTYPE_LEGS = 10,
	INVTYPE_FEET = 11,
	INVTYPE_TABARD = 6,
	INVTYPE_BODY = 5,
};

mog.view.slots = {};
for k,v in ipairs(mog.itemSlots) do
	mog.view.slots[k] = CreateFrame("Button","MogItPreview"..v,mog.view,"ItemButtonTemplate");
	if k == 1 then
		mog.view.slots[k]:SetPoint("TOPLEFT",mog.view,"TOPLEFT",5,-24);
	elseif k == 8 then
		mog.view.slots[k]:SetPoint("TOPRIGHT",mog.view,"TOPRIGHT",-5,-24);
	else
		mog.view.slots[k]:SetPoint("TOP",mog.view.slots[k-1],"BOTTOM",0,-4);
	end
	
	local id,texture = GetInventorySlotInfo(v);
	SetItemButtonTexture(mog.view.slots[k],texture);
	
	mog.view.slots[k]:RegisterForClicks("AnyUp");
	mog.view.slots[k]:SetScript("OnClick",mog.itemClick);
	mog.view.slots[k]:SetScript("OnEnter",function(self)
		if self.item then
			--GameTooltip:SetItemByID(self.item);
			mog.itemTooltip(self);
		else
			GameTooltip:SetOwner(self,"ANCHOR_RIGHT");
			GameTooltip:SetText(_G[strupper(mog.itemSlots[self.slot])]);
		end
	end);
	mog.view.slots[k]:SetScript("OnLeave",function(self)
		GameTooltip:Hide();
	end);
	
	mog.view.slots[k].list = {};
	mog.view.slots[k].cycle = 1;
	mog.view.slots[k].slot = k;
	mog.view.slots[k].MogItSlot = true;
end

mog.view.model = mog.addModel(true);
mog.view.model:Show();
mog.view.model:SetPoint("TOP",mog.view.btnAdd,"BOTTOM",0,-2);
mog.view.model:SetPoint("BOTTOM",mog.view.btnSave,"TOP",0,1);
mog.view.model:SetPoint("LEFT",mog.view.slots[1],"RIGHT",3,0);
mog.view.model:SetPoint("RIGHT",mog.view.slots[8],"LEFT",-4,0);
mog.view.model:EnableMouseWheel(true);
mog.view.model:SetScript("OnMouseWheel",function(self,v)
	mog.posZ = mog.posZ + ((v > 0 and 0.6) or -0.6);
	mog.updateModels();
end);

mog.view.waitList = {};
mog.view.waitCount = {};

function mog.view.setTexture(slot,texture)
	SetItemButtonTexture(mog.view.slots[slot],texture or select(2,GetInventorySlotInfo(mog.itemSlots[slot])));
end

function mog.view.addItem(item,set)
	if not item then return end;
	local slot,texture = select(9,GetItemInfo(item));
	if not slot then
		mog.view.waitList[item] = time();
		mog.view.waitCount[item] = (mog.view.waitCount[item] or 0) + 1;
		return;
	end
	if mog.invSlots[slot] then
		local id;
		if type(item) == "string" then
			id = item:match("|Hitem:([^:]+)");
		end
		id = id and tonumber(id) or item;
		
		if slot == "INVTYPE_2HWEAPON" and select(2,UnitClass("PLAYER")) == "WARRIOR" and (select(5,GetTalentInfo(2,20)) or 0) > 0 then
			slot = "INVTYPE_WEAPON";
		end
		if slot == "INVTYPE_2HWEAPON" then
			mog.view.delItem(13);
			mog.view.th = true;
		elseif slot == "INVTYPE_WEAPONOFFHAND" then
			if mog.view.th then
				mog.view.delItem(12);
			end
			mog.view.th = nil;
		elseif slot == "INVTYPE_WEAPON" then
			if mog.view.slots[12].item and (not mog.view.slots[13].item) or mog.view.slots[12].item == id then
				slot = "INVTYPE_WEAPONOFFHAND";
			end
			mog.view.th = nil;
		elseif slot == "INVTYPE_WEAPONMAINHAND" then
			mog.view.th = nil;
		end
		
		mog.view.slots[mog.invSlots[slot]].item = id;
		table.insert(mog.view.slots[mog.invSlots[slot]].list,id);
		mog.view.slots[mog.invSlots[slot]].cycle = #mog.view.slots[mog.invSlots[slot]].list;
		mog.view.setTexture(mog.invSlots[slot],texture);
		
		if not mog.container:IsShown() then
			ShowUIPanel(mog.container);
		end
		if not mog.view:IsShown() then
			mog.view:Show();
		end
		
		mog.view.model.model:TryOn(item);
		if (not set) and mog.global.gridDress then
			mog.scroll:update();
		end
	end
end

function mog.view.delItem(slot)
	if mog.itemSlots[slot] then
		table.remove(mog.view.slots[slot].list,mog.view.slots[slot].cycle);
		mog.view.slots[slot].cycle = mog.view.slots[slot].cycle > #mog.view.slots[slot].list and 1 or mog.view.slots[slot].cycle;
		mog.view.slots[slot].item = mog.view.slots[slot].list[mog.view.slots[slot].cycle];
		if mog.view.slots[slot].item then
			local texture = select(10,GetItemInfo(mog.view.slots[slot].item));
			mog.view.setTexture(slot,texture);
			mog.itemTooltip(mog.view.slots[slot]);
		else
			mog.view.setTexture(slot);
			if GameTooltip:GetOwner() == mog.view.slots[slot] then
				GameTooltip:Hide();
			end
		end
	end
end

function mog.view.saveSet(set)
	if not set then return end;
	for k,v in ipairs(mog.view.slots) do
		set[k] = nil;
		for x,y in ipairs(v.list) do
			if not set[k] then
				set[k] = {};
			end
			table.insert(set[k],y);
		end
	end
end

hooksecurefunc("HandleModifiedItemClick",function(link)
	if link then
		if (GetMouseButtonClicked() == "RightButton") and IsControlKeyDown() then
			mog.view.addItem(link);
		end
	end
end);

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
		mog.view.addItem(text);
	end,
	OnCancel = function(self) end,
	EditBoxOnEnterPressed = function(self)
		local text = self:GetText();
		text = text and text:match("(%d+).-$");
		self:GetParent():Hide();
		mog.view.addItem(text);
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
		for k,v in ipairs(mog.view.slots) do
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
			mog.view.model.model:Undress();
			for k,v in ipairs(mog.view.slots) do
				mog.view.delItem(k);
			end
			for item in items:gmatch("([^:]+)") do
				item = item:match("^(%d+)");
				if item then
					mog.view.addItem(tonumber(item),true);
				end
			end
			if mog.global.gridDress then
				mog.scroll:update();
			end
		end
	end,
	OnCancel = function(self) end,
	EditBoxOnEnterPressed = function(self)
		self:GetParent():Hide();
		local items = self:GetText();
		items = items and items:match("compare%?items=([^;#]+)");
		if items then
			mog.view.model.model:Undress();
			for k,v in ipairs(mog.view.slots) do
				mog.view.delItem(k);
			end
			for item in items:gmatch("([^:]+)") do
				item = item:match("^(%d+)");
				if item then
					mog.view.addItem(tonumber(item),true);
				end
			end
			if mog.global.gridDress then
				mog.scroll:update();
			end
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