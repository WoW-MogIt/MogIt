local MogIt,mog = ...;
local L = mog.L;

local IsDressableItem = IsDressableItem;
local GetScreenWidth = GetScreenWidth;
local GetScreenHeight = GetScreenHeight;

local class = L.classBits[select(2,UnitClass("PLAYER"))];


--// Tooltip
mog.tooltip = CreateFrame("Frame","MogItTooltip",UIParent,"TooltipBorderedFrameTemplate");
mog.tooltip:Hide();
mog.tooltip:SetClampedToScreen(true);
mog.tooltip:SetFrameStrata("TOOLTIP");

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

mog.tooltip:SetScript("OnEvent", function(self, event, arg1)
	if event == "PLAYER_LOGIN" then
		mog.tooltip.model:SetUnit("player");
	elseif event == "PLAYER_REGEN_DISABLED" then
		ClearOverrideBindings(mog.tooltip);
	elseif event == "PLAYER_REGEN_ENABLED" then
		if self:IsShown() and mog.db.profile.tooltipMouse then
			SetOverrideBinding(mog.tooltip,true,"MOUSEWHEELUP","MogIt_TooltipScrollUp");
			SetOverrideBinding(mog.tooltip,true,"MOUSEWHEELDOWN","MogIt_TooltipScrollDown");
		end
	end
end);
mog.tooltip:RegisterEvent("PLAYER_LOGIN");
mog.tooltip:RegisterEvent("PLAYER_REGEN_DISABLED");
mog.tooltip:RegisterEvent("PLAYER_REGEN_ENABLED");
--//


--// Model
mog.tooltip.model = CreateFrame("DressUpModel",nil,mog.tooltip);
mog.tooltip.model:SetPoint("TOPLEFT",mog.tooltip,"TOPLEFT",5,-5);
mog.tooltip.model:SetPoint("BOTTOMRIGHT",mog.tooltip,"BOTTOMRIGHT",-5,5);
mog.tooltip.model.ResetModel = function(self)
	local db = mog.db.profile
	if db.tooltipCustomModel then
		self:SetCustomRace(db.tooltipRace, db.tooltipGender);
		self:RefreshCamera();
	else
		self:Dress();
	end
	if not db.tooltipDress then
		self:Undress();
	end
end
mog.tooltip.model:SetScript("OnShow",mog.tooltip.model.ResetModel);


function mog.tooltip:ShowItem(itemLink)
	if not itemLink then return end
	local itemID, _, _, slot = GetItemInfoInstant(itemLink);
	if not itemID then return end
	local self = GameTooltip;
	
	for i = 1, GameTooltip:NumLines() do
		local line = _G["GameTooltipTextLeft"..i]
		if line:GetText() == TRANSMOGRIFY_TOOLTIP_ITEM_UNKNOWN_APPEARANCE_KNOWN then
			line:SetTextColor(136 / 255, 1, 170 / 255)
		end
	end
	
	local db = mog.db.profile;
	local tooltip = mog.tooltip;
	if db.tooltip and (not tooltip.mod[db.tooltipMod] or tooltip.mod[db.tooltipMod]()) then
		if not self[mog] then
			if tooltip.item ~= itemLink then
				tooltip.item = itemLink;
				local token = mog.tokens[itemID];
				if token then
					for item, classBit in pairs(token) do
						if bit.band(class, classBit) > 0 then
							itemLink = "item:"..item;
							itemID = item;
							break;
						end
					end
				end
				local slot = select(4, GetItemInfoInstant(itemLink));
				if (not db.tooltipMog or select(3, C_Transmog.GetItemInfo(itemID))) and tooltip.slots[slot] and IsDressableItem(itemLink) then
					tooltip.model:SetFacing(tooltip.slots[slot]-(db.tooltipRotate and 0.5 or 0));
					tooltip:Show();
					tooltip.owner = self;
					--if mog.global.tooltipAnchor then
						tooltip.repos:Show();
					--else
					--	tooltip:ClearAllPoints();
					--	tooltip:SetPoint("BOTTOMRIGHT","UIParent","BOTTOMRIGHT",-CONTAINER_OFFSET_X - 13,CONTAINER_OFFSET_Y);
					--end
					-- this seems to be needed for when moving from one item to another without the tooltip hiding in between
					tooltip.model:ResetModel();
					tooltip.model:TryOn(itemLink);
				else
					tooltip:Hide();
				end
			end
		else
			-- tooltip:Hide();
		end
	end
	
	local addOwnedItem = mog.db.profile.tooltipAlwaysShowOwned and mog.slotsType[slot];
	if mog.db.profile.tooltipAlwaysShowOwned and mog.slotsType[slot] then
		local addedCharacters = {}
		local hasItem, characters = mog:HasItem(itemID, true);
		addOwnedItem = hasItem;
		if hasItem then
			self:AddLine(" ");
			self:AddLine("|TInterface\\RaidFrame\\ReadyCheck-Ready:0|t "..L["You have this item."], 1, 1, 1);
			if mog.db.profile.tooltipOwnedDetail and characters then
				for i, character in ipairs(characters) do
					self:AddLine("|T:0|t "..character);
					addedCharacters[character] = true;
				end
			end
		end
	end
	
	-- add wishlist info about this item
	if not self[mog] then
		local addedCharacters = {}
		local found, characters = mog.wishlist:IsItemInWishlist(itemID);
		if found then
			if not addOwnedItem then
				self:AddLine(" ");
			end
			self:AddLine("|TInterface\\PetBattles\\PetJournal:0:0:0:0:512:1024:62:78:26:42:255:255:255|t "..L["This item is on your wishlist."], 1, 1, 1);
			if mog.db.profile.tooltipWishlistDetail and characters then
				for i, character in ipairs(characters) do
					self:AddLine("|T:0|t "..character);
					addedCharacters[character] = true;
				end
			end
		end
		local itemIDs = mog:GetData("display", mog:GetData("item", mog:NormaliseItemString(itemLink), "display"), "items");
		if itemIDs then
			for i, item in ipairs(itemIDs) do
				local foundAlternate, profiles = mog.wishlist:IsItemInWishlist(item);
				if foundAlternate then
					if not found then
						self:AddLine(" ");
						self:AddLine("|TInterface\\PetBattles\\PetJournal:0:0:0:0:512:1024:62:78:26:42:255:255:255|t "..L["This item is on your wishlist."], 1, 1, 1);
					end
					found = true;
					if mog.db.profile.tooltipWishlistDetail and profiles then
						for i, character in ipairs(profiles) do
							if not addedCharacters[character] then
								self:AddLine("|T:0|t "..character.." (*)");
							end
						end
					end
				end
			end
		end
	end
end

function mog.tooltip.HideItem(self)
	mog.tooltip.check:Show();
end
--//


--// GameTooltip
mog.tooltip.check = CreateFrame("Frame");
mog.tooltip.check:Hide();
mog.tooltip.check:SetScript("OnUpdate",function(self)
	if (mog.tooltip.owner and not (mog.tooltip.owner:IsShown() and mog.tooltip.owner:GetItem())) or not mog.tooltip.owner then
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
		if mog.db.profile.tooltipAnchor == "vertical" then
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
		else
			if x/GetScreenWidth() > 0.5 then
				mogpoint = "RIGHT";
				ownerpoint = "LEFT";
			else
				mogpoint = "LEFT";
				ownerpoint = "RIGHT";
			end
			if y/GetScreenHeight() > 0.5 then
				mogpoint = "TOP"..mogpoint;
				ownerpoint = "TOP"..ownerpoint;
			else
				mogpoint = "BOTTOM"..mogpoint;
				ownerpoint = "BOTTOM"..ownerpoint;
			end
		end
		mog.tooltip:SetPoint(mogpoint,mog.tooltip.owner,ownerpoint);
		self:Hide();
	end
end);

GameTooltip:HookScript("OnTooltipSetItem", function(self)
	local _, itemLink = self:GetItem();
	mog.tooltip:ShowItem(itemLink);
end);
GameTooltip:HookScript("OnHide",mog.tooltip.HideItem);

-- temporary hacks for tooltips where GameTooltip:GetItem() returns a broken link
hooksecurefunc(GameTooltip, "SetQuestItem", function(self, itemType, index)
	mog.tooltip:ShowItem(GetQuestItemLink(itemType, index));
	GameTooltip:Show();
end);

hooksecurefunc(GameTooltip, "SetQuestLogItem", function(self, itemType, index)
	mog.tooltip:ShowItem(GetQuestLogItemLink(itemType, index));
	GameTooltip:Show();
end);

-- hooksecurefunc(GameTooltip, "SetRecipeResultItem", function(self, recipeID)
	-- mog.tooltip:ShowItem(C_TradeSkillUI.GetRecipeItemLink(recipeID));
	-- GameTooltip:Show();
-- end);

hooksecurefunc(GameTooltip, "SetRecipeReagentItem", function(self, recipeID, reagentIndex)
	mog.tooltip:ShowItem(C_TradeSkillUI.GetRecipeReagentItemLink(recipeID, reagentIndex));
	GameTooltip:Show();
end);
--//


--// Auto-Rotate
mog.tooltip.rotate = CreateFrame("Frame",nil,mog.tooltip);
mog.tooltip.rotate:Hide();
mog.tooltip.rotate:SetScript("OnUpdate",function(self,elapsed)
	mog.tooltip.model:SetFacing(mog.tooltip.model:GetFacing() + elapsed);
end);
--//


--// Tables
mog.tooltip.slots = {
	INVTYPE_HEAD = 0,
	INVTYPE_SHOULDER = 0,
	INVTYPE_CLOAK = 3.4,
	INVTYPE_CHEST = 0,
	INVTYPE_ROBE = 0,
	INVTYPE_SHIRT = 0,
	INVTYPE_TABARD = 0,
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
--//