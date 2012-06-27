local MogIt,mog = ...;
local L = mog.L;

local IsDressableItem = IsDressableItem;
local GetScreenWidth = GetScreenWidth;
local GetScreenHeight = GetScreenHeight;

mog.tooltip = CreateFrame("Frame","MogItTooltip",UIParent);
mog.tooltip:Hide();
mog.tooltip:SetClampedToScreen(true);
mog.tooltip:SetFrameStrata("TOOLTIP");
mog.tooltip:SetBackdrop({
	bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", 
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	tile = true, tileSize = 16, edgeSize = 16, 
	insets = { left = 5, right = 5, top = 5, bottom = 5 }
});
mog.tooltip:SetBackdropColor(0,0,0);

mog.tooltip.slots = {
	INVTYPE_HEAD = 0,
	INVTYPE_SHOULDER = 0,
	INVTYPE_CLOAK = 3.4,
	INVTYPE_CHEST = 0,
	INVTYPE_ROBE = 0,
	INVTYPE_WRIST = 0,
	INVTYPE_2HWEAPON = 1.6,
	INVTYPE_WEAPON = 1.6,
	INVTYPE_WEAPONMAINHAND = 1.6,
	INVTYPE_WEAPONOFFHAND = -0.7,
	INVTYPE_SHIELD = -0.7,
	INVTYPE_HOLDABLE = -0.7,
	INVTYPE_RANGED = 1.6,
	INVTYPE_RANGEDRIGHT = 1.6,
	INVTYPE_THROWN = 1.6,
	INVTYPE_HAND = 0,
	INVTYPE_WAIST = 0,
	INVTYPE_LEGS = 0,
	INVTYPE_FEET = 0,
};
mog.tooltip.mod = {
	Shift = IsShiftKeyDown,
	Ctrl = IsControlKeyDown,
	Alt = IsAltKeyDown,
};

mog.tooltip.model = CreateFrame("DressUpModel",nil,mog.tooltip);
mog.tooltip.model:SetPoint("TOPLEFT",mog.tooltip,"TOPLEFT",5,-5);
mog.tooltip.model:SetPoint("BOTTOMRIGHT",mog.tooltip,"BOTTOMRIGHT",-5,5);
mog.tooltip:SetScript("OnShow",function(self)
	if mog.db.profile.tooltipMouse and not InCombatLockdown() then
		SetOverrideBinding(mog.tooltip,true,"MOUSEWHEELUP","MogIt_TooltipScrollUp");
		SetOverrideBinding(mog.tooltip,true,"MOUSEWHEELDOWN","MogIt_TooltipScrollDown");
	end
end);
mog.tooltip:SetScript("OnHide",function(self)
	if not InCombatLockdown() then
		ClearOverrideBindings(mog.tooltip);
	end
end);
mog.tooltip:RegisterEvent("PLAYER_REGEN_DISABLED");
mog.tooltip:RegisterEvent("PLAYER_REGEN_ENABLED");
mog.tooltip:SetScript("OnEvent", function(self, event)
	if event == "PLAYER_REGEN_DISABLED" then
		ClearOverrideBindings(mog.tooltip);
	elseif self:IsShown() and  mog.db.profile.tooltipMouse then
		SetOverrideBinding(mog.tooltip,true,"MOUSEWHEELUP","MogIt_TooltipScrollUp");
		SetOverrideBinding(mog.tooltip,true,"MOUSEWHEELDOWN","MogIt_TooltipScrollDown");
	end
end);

mog.tooltip.check = CreateFrame("Frame");
mog.tooltip.check:Hide();
mog.tooltip.check:SetScript("OnUpdate",function(self)
	if mog.tooltip.owner and not (mog.tooltip.owner:IsShown() and mog.tooltip.owner:GetItem()) then
		mog.tooltip:Hide();
		mog.tooltip.item = nil;
	end
	self:Hide();
end);

mog.tooltip.repos = CreateFrame("Frame");
mog.tooltip.repos:Hide();
mog.tooltip.repos:SetScript("OnUpdate",function(self)
	local x,y = mog.tooltip.owner:GetCenter();
	if x and y then
		mog.tooltip:ClearAllPoints();
		local mogpoint,ownerpoint;
		if y/GetScreenHeight() > 0.5 then
			mogpoint = "TOP";
			ownerpoint = "BOTTOM";
		else
			mogpoint = "BOTTOM";
			ownerpoint = "TOP";
		end
		if x/GetScreenWidth() > 0.5 then
			mogpoint = mogpoint.."LEFT";
			ownerpoint = ownerpoint.."LEFT";
		else
			mogpoint = mogpoint.."RIGHT";
			ownerpoint = ownerpoint.."RIGHT";
		end
		mog.tooltip:SetPoint(mogpoint,mog.tooltip.owner,ownerpoint);
		self:Hide();
	end
end);

function mog.tooltip.ShowItem(self)
	local _,itemLink = self:GetItem();
	
	if mog.db.profile.tooltip and (not mog.tooltip.mod[mog.db.profile.tooltipMod] or mog.tooltip.mod[mog.db.profile.tooltipMod]()) then
		local owner = self:GetOwner();
		if itemLink and owner then --and not (owner.MogItModel or owner.MogItSlot) then
			if mog.tooltip.item ~= itemLink then
				mog.tooltip.item = itemLink;
				local _,_,quality,_,_,class,subclass,_,slot = GetItemInfo(itemLink);
				if (not mog.db.profile.tooltipMog or select(3, GetItemTransmogrifyInfo(itemLink))) and mog.tooltip.slots[slot] and IsDressableItem(itemLink) then
					mog.tooltip.model:SetFacing(mog.tooltip.slots[slot]-(mog.db.profile.tooltipRotate and 0.5 or 0));
					mog.tooltip:Show();
					mog.tooltip.owner = self;
					--if mog.global.tooltipAnchor then
						mog.tooltip.repos:Show();
					--else
					--	mog.tooltip:ClearAllPoints();
					--	mog.tooltip:SetPoint("BOTTOMRIGHT","UIParent","BOTTOMRIGHT",-CONTAINER_OFFSET_X - 13,CONTAINER_OFFSET_Y);
					--end
					if mog.db.profile.tooltipDress then
						mog.tooltip.model:Dress();
					else
						mog.tooltip.model:Undress();
					end
					mog.tooltip.model:TryOn(itemLink);
				else
					mog.tooltip:Hide();
				end
			end
		else
			mog.tooltip:Hide();
		end
	end
	
	-- add wishlist info about this item
	if not self.MogIt and mog.wishlist:IsItemInWishlist(tonumber(itemLink:match("item:(%d+)"))) then
		self:AddLine(" ");
		self:AddLine(L["This item is on your wishlist."], 1, 1, 0);
		self:AddTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_1");
	end
end

function mog.tooltip.HideItem(self)
	mog.tooltip.check:Show();
end

mog.tooltip.rotate = CreateFrame("Frame",nil,mog.tooltip);
mog.tooltip.rotate:Hide();
mog.tooltip.rotate:SetScript("OnUpdate",function(self,elapsed)
	mog.tooltip.model:SetFacing(mog.tooltip.model:GetFacing() + elapsed);
end);

GameTooltip:HookScript("OnTooltipSetItem",mog.tooltip.ShowItem);
GameTooltip:HookScript("OnHide",mog.tooltip.HideItem);

function mog.tooltip.hookAtlasLoot()
	if AtlasLootTooltipTEMP then
		AtlasLootTooltipTEMP:HookScript("OnTooltipSetItem",mog.tooltip.ShowItem);
		AtlasLootTooltipTEMP:HookScript("OnHide",mog.tooltip.HideItem);
	end
end
mog.tooltip.hookAtlasLoot();