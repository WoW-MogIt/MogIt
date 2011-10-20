local MogIt,mog = ...;
local L = mog.L;

local LBI = LibStub("LibBabble-Inventory-3.0"):GetUnstrictLookupTable();

local addons = {
	"MogIt_Cloth",
	"MogIt_Leather",
	"MogIt_Mail",
	"MogIt_Plate",
	"MogIt_OneHanded",
	"MogIt_TwoHanded",
	"MogIt_Ranged",
	"MogIt_Other",
	"MogIt_Accessories",
};

local list = {};
local display = {};

mog.sub.data = {
	display = {},
	quality = {},
	lvl = {},
	faction = {},
	class = {},
	slot = {},
	source = {},
	sourceid = {},
	sourceinfo = {},
	zone = {},
};

mog.sub.colours = {
	[1] = {},
	[2] = {},
	[3] = {},
};

mog.sub.source = {
	[1] = L["Drop"],
	[2] = PVP,
	[3] = L["Quest"],
	[4] = L["Vendor"],
	[5] = L["Crafted"],
	[6] = L["Achievement"],
	[7] = L["Code Redemption"],
};

mog.sub.diffs = {
	--[1] = PLAYER_DIFFICULTY1,
	[2] = PLAYER_DIFFICULTY2,
	[3] = L["10N"],
	[4] = L["25N"],
	[5] = L["10H"],
	[6] = L["25H"],
	--[7] = PLAYER_DIFFICULTY1;
	[8] = PLAYER_DIFFICULTY2;
};

mog.sub.difficulties = {
	[1] = DUNGEON_DIFFICULTY_5PLAYER;
	[2] = DUNGEON_DIFFICULTY_5PLAYER_HEROIC;
	[3] = RAID_DIFFICULTY_10PLAYER;
	[4] = RAID_DIFFICULTY_10PLAYER_HEROIC;
	[5] = RAID_DIFFICULTY_25PLAYER;
	[6] = RAID_DIFFICULTY_25PLAYER_HEROIC;
	[7] = OTHER,
};

mog.sub.slots = {
	[1] = INVTYPE_WEAPON,
	[2] = INVTYPE_WEAPONMAINHAND,
	[3] = INVTYPE_WEAPONOFFHAND,
};

mog.sub.professions = {
	[1] = GetSpellInfo(2259), -- Alchemy
	[2] = GetSpellInfo(2018), -- Blacksmithing
	[3] = GetSpellInfo(7411), -- Enchanting
	[4] = GetSpellInfo(4036), -- Engineering
	[5] = GetSpellInfo(45357), -- Inscription
	[6] = GetSpellInfo(25229), -- Jewelcrafting
	[7] = GetSpellInfo(2108), -- Leatherworking
	[8] = GetSpellInfo(3908), -- Tailoring

	[9] = GetSpellInfo(2366), -- Herbalism
	[10] = GetSpellInfo(2575), -- Mining
	[11] = GetSpellInfo(8613), -- Skinning

	[12] = GetSpellInfo(78670), -- Archaeology
	[13] = GetSpellInfo(2550), -- Cooking
	[14] = GetSpellInfo(3273), -- First Aid
	[15] = GetSpellInfo(7620), -- Fishing
};

mog.sub.quality = {
	0, -- Poor
	1, -- Common
	2, -- Uncommon
	3, -- Rare
	4, -- Epic
	5, -- Legendary
	--6, -- Artifact
	7, -- Heirloom
};

mog.sub.classBits = {
	DEATHKNIGHT = 32,
	DRUID = 1024,
	HUNTER = 4,
	MAGE = 128,
	PALADIN = 2,
	PRIEST = 16,
	ROGUE = 8,
	SHAMAN = 64,
	WARLOCK = 256,
	WARRIOR = 1,
};

mog.sub.bind = {
	[0] = NONE,
	[1] = ITEM_BIND_ON_PICKUP,
	[2] = ITEM_BIND_ON_EQUIP,
	[5] = ITEM_BIND_TO_BNETACCOUNT,
};

function mog.sub.Dropdown(module,tier)
	local info;
	if tier == 1 then
		info = UIDropDownMenu_CreateInfo();
		info.text = module.name..(module.loaded and "" or " \124cFFFFFFFF("..L["Click to load addon"]..")");
		info.value = module;
		info.colorCode = "\124cFF"..(module.loaded and "00FF00" or "FF0000");
		info.hasArrow = module.loaded;
		info.keepShownOnClick = true;
		info.notCheckable = true;
		info.func = function(self)
			if not self.value.loaded then
				LoadAddOn(self.value.addon);
			end
		end
		UIDropDownMenu_AddButton(info,tier);
	elseif tier == 2 then
		for k,v in ipairs(module.slots) do
			info = UIDropDownMenu_CreateInfo();
			info.text = v.label;
			info.value = v;
			info.notCheckable = true;
			info.func = function(self)
				self.arg1.active = self.value;
				mog:SetModule(self.arg1,self.arg1.name.." - "..self.value.label);
				CloseDropDownMenus();
			end
			info.arg1 = module;
			UIDropDownMenu_AddButton(info,tier);
		end
	end
end

function mog.sub.FrameUpdate(module,self,value)
	self.data.display = value;
	self.data.items = display[value];
	self.data.cycle = 1;
	self.data.item = type(self.data.items) ~= "table" and self.data.items or self.data.items[self.data.cycle];
	
	self.model:Undress();
	mog:DressModel(self.model);
	self.model:TryOn(self.data.item);
end

function mog.sub.OnEnter(module,self)
	if not self then return end;
	local item = self.data.item;
	if not item then return end;
	--GameTooltip:SetOwner(self,"ANCHOR_NONE");
	GameTooltip:SetOwner(self,"ANCHOR_RIGHT");
	
	local name,link,_,_,_,_,_,_,_,texture = GetItemInfo(item);
	--GameTooltip:AddLine(self.display,1,1,1);
	--GameTooltip:AddLine(" ");
	GameTooltip:AddDoubleLine((texture and "\124T"..texture..":18\124t " or "")..(link or name or ""),(type(self.data.items) == "table") and (#self.data.items > 1) and L["Item %d/%d"]:format(self.data.cycle,#self.data.items),nil,nil,nil,1,0,0);
	if mog.sub.data.source[item] then
		GameTooltip:AddDoubleLine(L["Source"]..":",mog.sub.source[mog.sub.data.source[item]],nil,nil,nil,1,1,1);
		if mog.sub.data.source[item] == 1 then -- Drop
			if mog.GetMob(mog.sub.data.sourceid[item]) then
				GameTooltip:AddDoubleLine(BOSS..":",mog.GetMob(mog.sub.data.sourceid[item]),nil,nil,nil,1,1,1);
			end
		--elseif mog.data.source[self.item] == 3 then -- Quest
		elseif mog.sub.data.source[item] == 5 then -- Crafted
			if mog.sub.data.sourceinfo[item] then
				GameTooltip:AddDoubleLine(L["Profession"]..":",mog.sub.professions[mog.sub.data.sourceinfo[item]],nil,nil,nil,1,1,1);
			end
		elseif mog.sub.data.source[item] == 6 then -- Achievement
			if mog.sub.data.sourceid[item] then
				local _,name,_,complete = GetAchievementInfo(mog.sub.data.sourceid[item]);
				GameTooltip:AddDoubleLine(L["Achievement"]..":",name,nil,nil,nil,1,1,1);
				GameTooltip:AddDoubleLine(STATUS..":",complete and COMPLETE or INCOMPLETE,nil,nil,nil,1,1,1);
			end
		end
	end
	if mog.sub.data.zone[item] then
		local zone = GetMapNameByID(mog.sub.data.zone[item]);
		if zone then
			if mog.sub.data.source[item] == 1 and mog.sub.diffs[mog.sub.data.sourceinfo[item]] then
				zone = zone.." ("..mog.sub.diffs[mog.sub.data.sourceinfo[item]]..")";
			end
			GameTooltip:AddDoubleLine(ZONE..":",zone,nil,nil,nil,1,1,1);
		end
	end
	
	GameTooltip:AddLine(" ");
	if mog.sub.data.lvl[item] then
		GameTooltip:AddDoubleLine(LEVEL..":",mog.sub.data.lvl[item],nil,nil,nil,1,1,1);
	end
	if mog.sub.data.faction[item] then
		GameTooltip:AddDoubleLine(FACTION..":",(mog.sub.data.faction[item] == 1 and FACTION_ALLIANCE or FACTION_HORDE),nil,nil,nil,1,1,1);
	end
	if mog.sub.data.class[item] and mog.sub.data.class[item] > 0 then
		local str;
		for k,v in pairs(mog.sub.classBits) do
			if bit.band(mog.sub.data.class[item],v) > 0 then
				if str then
					str = str..", "..string.format("\124cff%.2x%.2x%.2x",RAID_CLASS_COLORS[k].r*255,RAID_CLASS_COLORS[k].g*255,RAID_CLASS_COLORS[k].b*255)..LOCALIZED_CLASS_NAMES_MALE[k].."\124r";
				else
					str = string.format("\124cff%.2x%.2x%.2x",RAID_CLASS_COLORS[k].r*255,RAID_CLASS_COLORS[k].g*255,RAID_CLASS_COLORS[k].b*255)..LOCALIZED_CLASS_NAMES_MALE[k].."\124r";
				end
			end
		end
		GameTooltip:AddDoubleLine(CLASS..":",str,nil,nil,nil,1,1,1);
	end
	if mog.sub.data.slot[item] then
		GameTooltip:AddDoubleLine(L["Slot"]..":",mog.sub.slots[mog.sub.data.slot[item]],nil,nil,nil,1,1,1);
	end
	
	GameTooltip:AddLine(" ");
	GameTooltip:AddDoubleLine(ID..":",item,nil,nil,nil,1,1,1);
	
	GameTooltip:Show();
	--GameTooltip:ClearAllPoints();
	--GameTooltip:SetPoint("TOPLEFT",mog.frame,"TOPRIGHT",5,0);
end

function mog.sub.OnClick(module,self,btn)
	if btn == "LeftButton" then
		if IsShiftKeyDown() then
			local _,link = GetItemInfo(self.data.item);
			if link then
				ChatEdit_InsertLink(link);
			end
		elseif IsControlKeyDown() then
			DressUpItemLink(self.data.item);
		else
			if type(self.data.items) == "table" then
				self.data.cycle = (self.data.cycle < #self.data.items and (self.data.cycle + 1)) or 1;
				self.data.item = self.data.items[self.data.cycle];
				module:OnEnter(self);
			end
		end
	elseif btn == "RightButton" then
		if IsControlKeyDown() then
			mog:AddToPreview(self.data.item);
		elseif IsShiftKeyDown() then
			mog:ShowURL(self.data.item);
		else
			if UIDropDownMenu_GetCurrentDropDown() == mog.sub.ItemMenu and mog.sub.ItemMenu.menuList ~= self and DropDownList1 and DropDownList1:IsShown() then
				HideDropDownMenu(1);
			end
			ToggleDropDownMenu(nil,nil,mog.sub.ItemMenu,"cursor",0,0,self);
		end
	end
end

function mog.sub.OnScroll(module)
	if UIDropDownMenu_GetCurrentDropDown() == mog.sub.ItemMenu and DropDownList1 and DropDownList1:IsShown() then
		HideDropDownMenu(1);
	end
end

do
	local function menuAddItem(self, itemID, index)
		local name,link,_,_,_,_,_,_,_,texture = GetItemInfo(itemID);
		local info = UIDropDownMenu_CreateInfo();
		info.text = (texture and "\124T"..texture..":18\124t " or "")..(link or name or "");
		info.value = itemID;
		info.func = onClick;
		info.checked = self.data.cycle == index;
		info.hasArrow = true;
		info.arg1 = self;
		info.arg2 = index;
		UIDropDownMenu_AddButton(info,tier);
	end
	
	local function onClick(self, arg1, arg2)
		arg1.data.cycle = arg2;
		arg1.data.item = arg1.data.items[arg2];
	end
	
	local function setOnClick(self, set)
		mog:GetModule("Wishlist"):AddItem(self.value, set);
		CloseDropDownMenus();
	end
	
	local menu = {
		{
			text = "Add to wishlist",
			func = function(self)
				mog:GetModule("Wishlist"):AddItem(self.value);
				CloseDropDownMenus();
			end,
		},
		{
			text = "Add to set",
			hasArrow = true,
		},
	}
	
	mog.sub.ItemMenu = CreateFrame("Frame",nil,mog.frame);
	mog.sub.ItemMenu.displayMode = "MENU";
	function mog.sub.ItemMenu:initialize(tier,self)
		if tier == 1 then
			local items = self.data.items;
			if type(items) == "table" then
				for i,itemID in ipairs(items) do
					menuAddItem(self, itemID, i);
				end
			else
				menuAddItem(self, items, index);
			end
		elseif tier == 2 then
			for i, info in ipairs(menu) do
				-- local info = UIDropDownMenu_CreateInfo();
				-- info.text = set.name;
				info.value = UIDROPDOWNMENU_MENU_VALUE;
				-- info.func = setOnClick;
				info.notCheckable = true;
				-- info.arg1 = set.items;
				UIDropDownMenu_AddButton(info, tier);
			end
		elseif tier == 3 then
			for i, set in ipairs(mog:GetModule("Wishlist"):GetSets()) do
				local info = UIDropDownMenu_CreateInfo();
				info.text = set.name;
				info.value = UIDROPDOWNMENU_MENU_VALUE;
				info.func = setOnClick;
				info.notCheckable = true;
				info.arg1 = set.name;
				UIDropDownMenu_AddButton(info, tier);
			end
		end
	end
end

function mog.sub.GET_ITEM_INFO_RECEIVED()
	if UIDropDownMenu_GetCurrentDropDown() == mog.sub.ItemMenu and DropDownList1 and DropDownList1:IsShown() then
		HideDropDownMenu(1);
		ToggleDropDownMenu(nil,nil,mog.sub.ItemMenu,"cursor",0,0,mog.sub.ItemMenu.menuList);
	end
end

function mog.sub.Unlist(module)
	wipe(list);
	wipe(display);
end

function mog.sub.BuildList(module)
	wipe(list);
	wipe(display);
	for k,v in ipairs(module.active.items) do
		local state = true;
		for x,y in ipairs(module.filters) do
			if not mog:GetFilter(y).Filter(mog.sub.GetFilterArgs(y,v)) then
				state = false;
				break;
			end
		end
		if state then
			local disp = mog.sub.data.display[v];
			if not display[disp] then
				display[disp] = v;
				tinsert(list,disp);
			elseif type(display[disp]) == "table" then
				tinsert(display[disp],v);
			else
				display[disp] = {display[disp],v};
			end
		end
	end
	return list;
end

function mog.sub.AddSlot(label,addon)
	local items = {};
	local module = mog:GetModule(addon);
	table.insert(module.slots,{label = LBI[label] or label,items = items});
	return items;
end

function mog.sub.AddItem(tbl,id,display,quality,lvl,faction,class,slot,source,sourceid,zone,sourceinfo)
	table.insert(tbl,id);
	mog.sub.data.display[id] = display;
	mog.sub.data.quality[id] = quality;
	mog.sub.data.lvl[id] = lvl;
	mog.sub.data.faction[id] = faction;
	mog.sub.data.class[id] = class;
	mog.sub.data.slot[id] = slot;
	mog.sub.data.source[id] = source;
	mog.sub.data.sourceid[id] = sourceid;
	mog.sub.data.sourceinfo[id] = sourceinfo;
	mog.sub.data.zone[id] = zone;
end

function mog.sub.AddColours(id,c1,c2,c3)
	if c1 and (not mog.sub.colours[1][id]) then
		mog.sub.colours[1][id] = c1;
		mog.sub.colours[2][id] = c2;
		mog.sub.colours[3][id] = c3;
	end
end

function mog.sub.GetFilterArgs(filter,item)
	if filter == "level" then
		return mog.sub.data.lvl[item];
	elseif filter == "faction" then
		return mog.sub.data.faction[item];
	elseif filter == "class" then
		return mog.sub.data.class[item];
	elseif filter == "source" then
		return mog.sub.data.source[item],mog.sub.data.sourceinfo[item];
	elseif filter == "quality" then
		return mog.sub.data.quality[item];
	elseif filter == "slot" then
		return mog.sub.data.slot[item];
	end
end

for k,v in ipairs(addons) do
	local _,title,_,_,loadable = GetAddOnInfo(v);
	if loadable then
		mog:RegisterModule(v,{
			name = title:match("MogIt_(.+)") or title,
			Dropdown = mog.sub.Dropdown,
			BuildList = mog.sub.BuildList,
			FrameUpdate = mog.sub.FrameUpdate,
			OnEnter = mog.sub.OnEnter,
			OnClick = mog.sub.OnClick,
			OnScroll = mog.sub.OnScroll,
			Unlist = mog.sub.Unlist,
			GET_ITEM_INFO_RECEIVED = mog.sub.GET_ITEM_INFO_RECEIVED,
			filters = {
				"level",
				"faction",
				"class",
				"source",
				"quality",
				(v == "MogIt_OneHanded" and "slot") or nil,
			},
			addon = v,
			slots = {},
		},true);
	end
end

-- addon loader (and edit data.lua)
-- buildlist/setlist
-- filters/sort?
-- click etc



--[[
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
--]]