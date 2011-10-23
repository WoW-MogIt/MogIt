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

function mog.sub.DropdownTier1(self)
	if not self.value.loaded then
		LoadAddOn(self.value.addon);
	end
end

function mog.sub.DropdownTier2(self)
	self.arg1.active = self.value;
	mog:SetModule(self.arg1,self.arg1.label.." - "..self.value.label);
	CloseDropDownMenus();
end

function mog.sub.Dropdown(module,tier)
	local info;
	if tier == 1 then
		info = UIDropDownMenu_CreateInfo();
		info.text = module.label..(module.loaded and "" or " \124cFFFFFFFF("..L["Click to load addon"]..")");
		info.value = module;
		info.colorCode = "\124cFF"..(module.loaded and "00FF00" or "FF0000");
		info.hasArrow = module.loaded;
		info.keepShownOnClick = true;
		info.notCheckable = true;
		info.func = mog.sub.DropdownTier1;
		UIDropDownMenu_AddButton(info,tier);
	elseif tier == 2 then
		for k,v in ipairs(module.slots) do
			info = UIDropDownMenu_CreateInfo();
			info.text = v.label;
			info.value = v;
			info.notCheckable = true;
			info.func = mog.sub.DropdownTier2;
			info.arg1 = module;
			UIDropDownMenu_AddButton(info,tier);
		end
	end
end

function mog.sub.FrameUpdate(module,self,value)
	if type(display[value]) == "table" then
		self.data.items = display[value];
		self.data.cycle = 1;
		self.data.item = self.data.items[self.data.cycle];
	else
		self.data.item = display[value];
	end
	mog.Item_FrameUpdate(self,self.data);
end

function mog.sub.OnEnter(module,self,value)
	mog.Item_OnEnter(self,self.data);
end

function mog.sub.OnClick(module,self,btn,value)
	mog.Item_OnClick(self,btn,self.data);
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

function mog.sub.SortLevel(id)
	if type(display[id]) == "table" then
		local tbl = {};
		for k,v in ipairs(display[id]) do
			table.insert(tbl,mog.sub.data.lvl[v]);
		end
		return tbl;
	else
		return mog.sub.data.lvl[display[id]];
	end
end

function mog.sub.SortColour(id)
	local tbl = {};
	for i=1,3 do
		if mog.sub.colours[i][id] then
			table.insert(tbl,mog.sub.colours[i][id]);
		end
	end
	return tbl;
end

for k,v in ipairs(addons) do
	local _,title,_,_,loadable = GetAddOnInfo(v);
	if loadable then
		mog:RegisterModule(v,{
			name = title:match("MogIt_(.+)") or title,
			template = "item",
			Dropdown = mog.sub.Dropdown,
			BuildList = mog.sub.BuildList,
			FrameUpdate = mog.sub.FrameUpdate,
			OnEnter = mog.sub.OnEnter,
			OnClick = mog.sub.OnClick,
			Unlist = mog.sub.Unlist,
			filters = {
				"level",
				"faction",
				"class",
				"source",
				"quality",
				(v == "MogIt_OneHanded" and "slot") or nil,
			},
			sorting = {
				level = mog.sub.SortLevel;
				colour = mog.sub.SortColour;
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