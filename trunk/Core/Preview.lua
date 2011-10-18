local MogIt,mog = ...;
local L = mog.L;

mog.view = CreateFrame("Frame","MogItPreview",UIParent,"ButtonFrameTemplate");
mog.view:SetPoint("CENTER",UIParent,"CENTER");
mog.view:SetSize(369,369);
mog.view:SetToplevel(true);
mog.view:SetClampedToScreen(true);
mog.view:EnableMouse(true);
mog.view:SetMovable(true);
mog.view:SetResizable(true);
mog.view:SetUserPlaced(true);
mog.view:SetScript("OnMouseDown",mog.view.StartMoving);
mog.view:SetScript("OnMouseUp",mog.view.StopMovingOrSizing);
tinsert(UISpecialFrames,"MogItPreview");

MogItPreviewBg:SetVertexColor(0.8,0.3,0.8);
MogItPreviewTitleText:SetText(L["Preview"]);
mog.view.portraitFrame:Hide();
mog.view.topLeftCorner:Show();
mog.view.topBorderBar:SetPoint("TOPLEFT",mog.view.topLeftCorner,"TOPRIGHT",0,0);
mog.view.leftBorderBar:SetPoint("TOPLEFT",mog.view.topLeftCorner,"BOTTOMLEFT",0,0);
mog.view.Inset:SetPoint("TOPLEFT",mog.view,"TOPLEFT",44,-60);
mog.view.Inset:SetPoint("BOTTOMRIGHT",mog.view,"BOTTOMRIGHT",-47,26);

mog.view.resize = CreateFrame("Frame",nil,mog.view);
mog.view.resize:SetSize(16,16);
mog.view.resize:SetPoint("BOTTOMRIGHT",mog.view,"BOTTOMRIGHT",-4,3);
mog.view.resize:EnableMouse(true);
mog.view.resize:SetScript("OnMouseDown",function(self)
	mog.view:SetMinResize(369,369);
	mog.view:SetMaxResize(GetScreenWidth(),GetScreenHeight());
	mog.view:StartSizing();
end);
mog.view.resize:SetScript("OnMouseUp",function(self)
	mog.view:StopMovingOrSizing();
	self:SetScript("OnUpdate",nil);
end);
mog.view.resize:SetScript("OnHide",mog.view.resize:GetScript("OnMouseUp"));
mog.view.resize.texture = mog.view.resize:CreateTexture(nil,"OVERLAY");
mog.view.resize.texture:SetSize(16,16);
mog.view.resize.texture:SetTexture("Interface\\AddOns\\MogIt\\Images\\Resize");
mog.view.resize.texture:SetAllPoints(mog.view.resize);

mog.view.model = CreateFrame("Button",nil,mog.view);
mog.view.model:SetPoint("TOPLEFT",mog.view.Inset,"TOPLEFT",10,-10);
mog.view.model:SetPoint("BOTTOMRIGHT",mog.view.Inset,"BOTTOMRIGHT",-10,10);
mog.view.model:EnableMouseWheel(true);
mog.view.model:SetScript("OnMouseWheel",function(self,v)
	mog.posZ = mog.posZ + ((v > 0 and 0.6) or -0.6);
	mog.updateModels();
end);
mog.view.model:SetScript("OnShow",function(self,...)
	self.model:SetPosition(mog.posZ,mog.posX,mog.posY);
	self.model:Undress();
	mog:DressModel(self.model);
	if self:GetFrameLevel() <= mog.view:GetFrameLevel() then
		self:SetFrameLevel(mog.view:GetFrameLevel()+1);
	end
end);
mog.view.model:SetScript("OnHide",function(self)
	if mog.modelUpdater.model == self then
		self:GetScript("OnDragStop")(self);
	end
	self.model:SetPosition(0,0,0);
end);
mog.view.model:RegisterForDrag("LeftButton","RightButton");
mog.view.model:SetScript("OnDragStart",function(self,btn)
	mog.modelUpdater.btn = btn;
	mog.modelUpdater.model = self;
	mog.modelUpdater.prevx,mog.modelUpdater.prevy = GetCursorPosition();
	mog.modelUpdater:Show();
end);
mog.view.model:SetScript("OnDragStop",function(self,btn)
	mog.modelUpdater:Hide();
	mog.modelUpdater.btn = nil;
	mog.modelUpdater.model = nil;
end);

mog.view.model.model = CreateFrame("DressUpModel",nil,mog.view.model);
mog.view.model.model:SetModelScale(2);
mog.view.model.model:SetPosition(0,0,0);
mog.view.model.model:SetAllPoints(mog.view.model);
mog.view.model.model.button = mog.view.model;
		
mog.view.model.bg = mog.view.model:CreateTexture(nil,"BACKGROUND");
mog.view.model.bg:SetAllPoints(mog.view.model);
mog.view.model.bg:SetTexture(0.3,0.3,0.3,0.2);

local slots = {
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

function mog.view.setTexture(slot,texture)
	SetItemButtonTexture(mog.view.slots[slot],texture or select(2,GetInventorySlotInfo(slot)));
end

mog.view.slots = {};
for k,v in ipairs(slots) do
	mog.view.slots[v] = CreateFrame("Button","MogItPreview"..v,mog.view,"ItemButtonTemplate");
	mog.view.slots[v].slot = v;
	if k == 1 then
		mog.view.slots[v]:SetPoint("TOPLEFT",mog.view,"TOPLEFT",5,-60);
	elseif k == 8 then
		mog.view.slots[v]:SetPoint("TOPRIGHT",mog.view,"TOPRIGHT",-7,-60);
	else
		mog.view.slots[v]:SetPoint("TOP",mog.view.slots[slots[k-1]],"BOTTOM",0,-4);
	end
	
	local id,texture = GetInventorySlotInfo(v);
	mog.view.setTexture(v);
	
	mog.view.slots[v]:RegisterForClicks("AnyUp");
	mog.view.slots[v]:SetScript("OnClick",function(self,btn)
		if not self.item then return end;
		if btn == "LeftButton" then
			if IsShiftKeyDown() then
				local _,link = GetItemInfo(self.item);
				if link then
					ChatEdit_InsertLink(link);
				end
			elseif IsControlKeyDown() then
				DressUpItemLink(self.item);
			else
				
			end
		elseif btn == "RightButton" then
			if IsControlKeyDown() then
				mog.view.delItem(self.slot);
				if mog.db.profile.gridDress then
					mog.scroll:update();
				end
			elseif IsShiftKeyDown() then
				mog:ShowURL(self.item);
			else
				
			end
		end
	end);
	--[=[mog.view.slots[k]:SetScript("OnEnter",function(self)
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
	end);--]=]
end

mog.view.wait = {};
function mog:AddToPreview(item,set)
	if not item then return end;
	local slot,texture = select(9,GetItemInfo(item));
	if not slot then
		mog.view.wait[item] = (mog.view.wait[item] or 0) + 1;
		return;
	end
	if mog.invSlots[slot] then
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
		
		mog.view.slots[mog.invSlots[slot]].item = item;
		-- item history
		mog.view.setTexture(mog.invSlots[slot],texture);
		if mog.view:IsShown() then
			mog.view.model.model:TryOn(item);
		else
			ShowUIPanel(mog.view);
		end
		
		if (not set) and mog.db.profile.gridDress then
			mog.scroll:update();
		end
	end
end

function mog.view.delItem(slot)
	mog.view.slots[slot].item = nil;
	mog.view.setTexture(slot);
	mog.view.model.model:Undress();
	mog:DressModel(mog.view.model.model);
	--[=[if GameTooltip:GetOwner() == mog.view.slots[slot] then
		GameTooltip:Hide();
	end--]=]
end

function mog:DressModel(model)
	if mog.db.profile.gridDress or (model == mog.view.model.model) then
		for k,v in pairs(mog.view.slots) do
			if v.item then
				model:TryOn(v.item);
			end
		end
	end
end

hooksecurefunc("HandleModifiedItemClick",function(link)
	if link then
		if (GetMouseButtonClicked() == "RightButton") and IsControlKeyDown() then
			if type(link) == "string" then
				link = tonumber(link:match("item:(%d+)"));
			end
			mog:AddToPreview(link);
		end
	end
end);