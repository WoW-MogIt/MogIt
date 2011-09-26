local MogIt,mog = ...;
local L = mog.L;

local GetCursorPosition = GetCursorPosition;
local ipairs = ipairs;

mog.view = CreateFrame("Frame","MogItPreview",mog.container,"BasicFrameTemplate");
mog.view:Hide();
mog.view:SetPoint("CENTER",UIParent,"CENTER");
mog.view:SetSize(310,313);
mog.view:SetFrameLevel(10);
mog.view:SetToplevel(true);
mog.view:SetClampedToScreen(true);
mog.view:EnableMouse(true);
mog.view:SetMovable(true);
mog.view:SetResizable(true);
mog.view:SetUserPlaced(true);
mog.view:SetScript("OnMouseDown",mog.view.StartMoving);
mog.view:SetScript("OnMouseUp",mog.view.StopMovingOrSizing);
MogItPreviewTitleText:SetText("Preview");

mog.view.resize = CreateFrame("Frame",nil,mog.view);
mog.view.resize:SetSize(16,16);
mog.view.resize:SetPoint("BOTTOMRIGHT",mog.view,"BOTTOMRIGHT");
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
mog.view.btnAdd:SetText("Add Item");
mog.view.btnAdd:SetPoint("TOPRIGHT",mog.view,"TOP",0,-23);
mog.view.btnAdd:SetScript("OnClick",function(self)
	StaticPopup_Show("MOGIT_PREVIEW_ADDITEM");
end);

mog.view.btnImport = CreateFrame("Button","MogItViewBtnImport",mog.view,"UIPanelButtonTemplate2");
mog.view.btnImport:SetSize(110,22);
mog.view.btnImport:SetText("Import/Export");
mog.view.btnImport:SetPoint("TOPLEFT",mog.view,"TOP",0,-23);
mog.view.btnImport:SetScript("OnClick",function(self)
	StaticPopup_Show("MOGIT_PREVIEW_IMPORT");
end);

mog.view.btnSave = CreateFrame("Button","MogItViewBtnSave",mog.view,"UIPanelButtonTemplate2");
mog.view.btnSave:SetSize(110,22);
mog.view.btnSave:SetText("Save");
mog.view.btnSave:SetPoint("BOTTOMRIGHT",mog.view,"BOTTOM",0,4);

mog.view.btnClear = CreateFrame("Button","MogItViewBtnClear",mog.view,"UIPanelButtonTemplate2");
mog.view.btnClear:SetSize(110,22);
mog.view.btnClear:SetText("Clear");
mog.view.btnClear:SetPoint("BOTTOMLEFT",mog.view,"BOTTOM",0,4);
mog.view.btnClear:SetScript("OnClick",function(self)
	mog.view.model:Undress();
	for k,v in ipairs(mog.view.slots) do
		mog.view.delItem(k);
	end
	if mog.global.gridDress then
		mog.scroll:update();
	end
end);

local itemSlots = {
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
local invSlots = {
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
for k,v in ipairs(itemSlots) do
	mog.view.slots[k] = CreateFrame("Button","MogItPreview"..v,mog.view,"ItemButtonTemplate");
	mog.view.slots[k]:RegisterForClicks("AnyUp");
	mog.view.slots[k].bg = mog.view.slots[k]:CreateTexture(nil,"BACKGROUND","Char-LeftSlot",-1);
	if k == 1 then
		mog.view.slots[k]:SetPoint("TOPLEFT",mog.view,"TOPLEFT",5,-24);
	elseif k == 8 then
		mog.view.slots[k]:SetPoint("TOPRIGHT",mog.view,"TOPRIGHT",-5,-24);
	else
		mog.view.slots[k]:SetPoint("TOP",mog.view.slots[k-1],"BOTTOM",0,-4);
	end
	local id,texture = GetInventorySlotInfo(v);
	SetItemButtonTexture(mog.view.slots[k],texture);
	mog.view.slots[k]:SetScript("OnClick",mog.itemClick);
	mog.view.slots[k].slot = k;
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
function mog.view.addItem(item,set)
	if not item then return end;
	local slot,texture = select(9,GetItemInfo(item));
	if not slot then
		mog.view.waitList[item] = time();
		mog.view.waitCount[item] = (mog.view.waitCount[item] or 0) + 1;
		return;
	end
	if invSlots[slot] then
		local id;
		if type(item) == "string" then
			id = item:match("|Hitem:([^:]+)");
		end
		id = id and tonumber(id) or item;
		
		-- fix (inc titans grip, dw?, warriors?)
		if slot == "INVTYPE_2HWEAPON" then
			mog.view.delItem(13);
			mog.view.th = true;
		elseif slot == "INVTYPE_WEAPONOFFHAND" then
			if mog.view.th then
				mog.view.delItem(12);
			end
			mog.view.th = nil;
		elseif slot == "INVTYPE_WEAPON" then
			if mog.view.slots[12].item == id then
				slot = "INVTYPE_WEAPONOFFHAND";
			end
			mog.view.th = nil;
		elseif slot == "INVTYPE_WEAPONMAINHAND" then
			mog.view.th = nil;
		end
		mog.view.slots[invSlots[slot]].item = id;
		if texture then
			SetItemButtonTexture(mog.view.slots[invSlots[slot]],texture);
		end
		if not mog.container:IsShown() then
			ShowUIPanel(mog.container);
		end
		if not mog.view:IsShown() then
			mog.view:Show();
		end
		mog.view.model:TryOn(item);
		if (not set) and mog.global.gridDress then
			mog.scroll:update();
		end
	end
end

function mog.view.delItem(slot)
	if itemSlots[slot] then
		local id,texture = GetInventorySlotInfo(itemSlots[slot]);
		SetItemButtonTexture(mog.view.slots[slot],texture);
		mog.view.slots[slot].item = nil;
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
	text = L["Type the item ID in the text box below"],
	button1 = ADD,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 512,
	editBoxWidth = 260,
	OnShow = function(self,item)
		self.editBox:SetFocus();
	end,
	OnAccept = function(self)
		mog.view.addItem(self.editBox:GetText());
	end,
	OnCancel = function(self) end,
	EditBoxOnEnterPressed = function(self)
		self:GetParent():Hide();
		mog.view.addItem(self:GetText());
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
					str = L["http://www.wowhead.com/compare?items="]..v.item;
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
			mog.view.model:Undress();
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
			mog.view.model:Undress();
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