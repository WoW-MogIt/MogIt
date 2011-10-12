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

local list = {},
local display = {},

mog.sub.filters = {
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

local function Dropdown(module,tier)
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
				UIDropDownMenu_SetText(mog.dropdown,self.arg1.name.." - "..self.value.label);
				mog.sub.selected = self.value;
				mog.sub.BuildList(self.arg1,self.value.items,true);
				CloseDropDownMenus();
			end
			info.arg1 = module;
			UIDropDownMenu_AddButton(info,tier);
		end
	end
end

local function FrameUpdate(module,self,value)
	self.data.display = value;
	self.data.items = display[value];
	self.data.cycle = 1;
	self.data.item = type(self.data.items) ~= "table" and self.data.items or self.data.items[self.data.cycle];
	
	self.model:Undress();
	self.model:TryOn(self.data.item);
end

local function OnEnter(module,self)
	if not self then return end;
	local item = self.data.item;
	if not item then return end;
	--GameTooltip:SetOwner(self,"ANCHOR_NONE");
	GameTooltip:SetOwner(self,"ANCHOR_RIGHT");
	
	local name,link,_,_,_,_,_,_,_,texture = GetItemInfo(item);
	--GameTooltip:AddLine(self.display,1,1,1);
	--GameTooltip:AddLine(" ");
	GameTooltip:AddDoubleLine((texture and "\124T"..texture..":18\124t " or "")..(link or name or ""),(type(self.data.items) == "table") and (#self.data.items > 1) and L["Item %d/%d"]:format(self.data.cycle,#self.data.items),nil,nil,nil,1,0,0);
	if mog.sub.filters.source[item] then
		GameTooltip:AddDoubleLine(L["Source"]..":",mog.sub.source[mog.sub.filters.source[item]],nil,nil,nil,1,1,1);
		if mog.sub.filters.source[item] == 1 then -- Drop
			if mog.GetMob(mog.sub.filters.sourceid[item]) then
				GameTooltip:AddDoubleLine(BOSS..":",mog.GetMob(mog.sub.filters.sourceid[item]),nil,nil,nil,1,1,1);
			end
		--elseif mog.filters.source[self.item] == 3 then -- Quest
		elseif mog.sub.filters.source[item] == 5 then -- Crafted
			if mog.sub.filters.sourceinfo[item] then
				GameTooltip:AddDoubleLine(L["Profession"]..":",mog.sub.professions[mog.sub.filters.sourceinfo[item]],nil,nil,nil,1,1,1);
			end
		elseif mog.sub.filters.source[item] == 6 then -- Achievement
			if mog.sub.filters.sourceid[item] then
				local _,name,_,complete = GetAchievementInfo(mog.sub.filters.sourceid[item]);
				GameTooltip:AddDoubleLine(L["Achievement"]..":",name,nil,nil,nil,1,1,1);
				GameTooltip:AddDoubleLine(STATUS..":",complete and COMPLETE or INCOMPLETE,nil,nil,nil,1,1,1);
			end
		end
	end
	if mog.sub.filters.zone[item] then
		local zone = GetMapNameByID(mog.sub.filters.zone[item]);
		if zone then
			if mog.sub.filters.source[item] == 1 and mog.sub.diffs[mog.sub.filters.sourceinfo[item]] then
				zone = zone.." ("..mog.sub.diffs[mog.sub.filters.sourceinfo[item]]..")";
			end
			GameTooltip:AddDoubleLine(ZONE..":",zone,nil,nil,nil,1,1,1);
		end
	end
	
	GameTooltip:AddLine(" ");
	if mog.sub.filters.lvl[item] then
		GameTooltip:AddDoubleLine(LEVEL..":",mog.sub.filters.lvl[item],nil,nil,nil,1,1,1);
	end
	if mog.sub.filters.faction[item] then
		GameTooltip:AddDoubleLine(FACTION..":",(mog.sub.filters.faction[item] == 1 and FACTION_ALLIANCE or FACTION_HORDE),nil,nil,nil,1,1,1);
	end
	if mog.sub.filters.class[item] and mog.sub.filters.class[item] > 0 then
		local str;
		for k,v in pairs(mog.sub.classBits) do
			if bit.band(mog.sub.filters.class[item],v) > 0 then
				if str then
					str = str..", "..string.format("\124cff%.2x%.2x%.2x",RAID_CLASS_COLORS[k].r*255,RAID_CLASS_COLORS[k].g*255,RAID_CLASS_COLORS[k].b*255)..LOCALIZED_CLASS_NAMES_MALE[k].."\124r";
				else
					str = string.format("\124cff%.2x%.2x%.2x",RAID_CLASS_COLORS[k].r*255,RAID_CLASS_COLORS[k].g*255,RAID_CLASS_COLORS[k].b*255)..LOCALIZED_CLASS_NAMES_MALE[k].."\124r";
				end
			end
		end
		GameTooltip:AddDoubleLine(CLASS..":",str,nil,nil,nil,1,1,1);
	end
	if mog.sub.filters.slot[item] then
		GameTooltip:AddDoubleLine(L["Slot"]..":",mog.sub.slots[mog.sub.filters.slot[item]],nil,nil,nil,1,1,1);
	end
	
	GameTooltip:AddLine(" ");
	GameTooltip:AddDoubleLine(ID..":",item,nil,nil,nil,1,1,1);
	
	GameTooltip:Show();
	--GameTooltip:ClearAllPoints();
	--GameTooltip:SetPoint("TOPLEFT",mog.frame,"TOPRIGHT",5,0);
end

local function OnClick(module,self,btn)
	if btn == "LeftButton" then
		if IsShiftKeyDown() then
			local _,link = GetItemInfo(self.data.item);
			if link then
				ChatEdit_InsertLink(link);
			end
		elseif IsControlKeyDown() then
			DressUpItemLink(self.data.item);
		else
			if UIDropDownMenu_GetCurrentDropDown() == mog.sub.LeftClick and mog.sub.LeftClick.menuList ~= self and DropDownList1 and DropDownList1:IsShown() then
				HideDropDownMenu(1);
			end
			if type(self.data.items) == "table" then
				ToggleDropDownMenu(nil,nil,mog.sub.LeftClick,"cursor",0,0,self);
			end
		end
	elseif btn == "RightButton" then
		if IsControlKeyDown() then
			--[[if self.MogItSlot then
				mog.view.delItem(self.slot);
				mog.dressModel(mog.view.model.model);
				if mog.db.profile.gridDress then
					mog.scroll:update();
				end
			else
				mog.view.addItem(self.item);
			end--]]
		elseif IsShiftKeyDown() then
			mog:ShowURL(self.data.item);
		else
			
		end
	end
end

local function OnScroll(module)
	if UIDropDownMenu_GetCurrentDropDown() == mog.sub.LeftClick and DropDownList1 and DropDownList1:IsShown() then
		HideDropDownMenu(1);
	end
end

local LeftClick = CreateFrame("Frame",nil,mog.frame);
LeftClick.displayMode = "MENU";
function LeftClick:initialize(tier,self)
	local info;
	for k,v in ipairs(self.data.items) do
		local name,link,_,_,_,_,_,_,_,texture = GetItemInfo(v);
		info = UIDropDownMenu_CreateInfo();
		info.text = (texture and "\124T"..texture..":18\124t " or "")..(link or name or "");
		info.value = k;
		info.func = function(self)
			self.arg1.data.cycle = self.value;
			self.arg1.data.item = self.arg1.data.items[self.value];
		end
		info.checked = self.data.cycle == k;
		info.arg1 = self;
		UIDropDownMenu_AddButton(info,tier);
	end
end

local function Unlist(module,new,list)
	if list ~= list then
		wipe(list);
		wipe(display);
	end
end

function mog.sub.AddSlot(label,addon)
	local items = {};
	table.insert(mog.sub.modules[addon].slots,{label = LBI[label] or label,items = items});
	return items;
end

function mog.sub.AddItem(tbl,id,display,quality,lvl,faction,class,slot,source,sourceid,zone,sourceinfo)
	table.insert(tbl,id);
	mog.sub.filters.display[id] = display;
	mog.sub.filters.quality[id] = quality;
	mog.sub.filters.lvl[id] = lvl;
	mog.sub.filters.faction[id] = faction;
	mog.sub.filters.class[id] = class;
	mog.sub.filters.slot[id] = slot;
	mog.sub.filters.source[id] = source;
	mog.sub.filters.sourceid[id] = sourceid;
	mog.sub.filters.sourceinfo[id] = sourceinfo;
	mog.sub.filters.zone[id] = zone;
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
		return mog.sub.filters.lvl[item];
	elseif filter == "faction" then
		return mog.sub.filters.faction[item];
	elseif filter == "class" then
		return mog.sub.filters.class[item];
	elseif filter == "source" then
		return mog.sub.filters.source[item],mog.sub.filters.sourceinfo[item];
	elseif filter == "quality" then
		return mog.sub.filters.quality[item];
	elseif filter == "slot" then
		return mog.sub.filters.slot[item];
	end
end

local function FilterUpdate(module,filter)
	mog.sub.BuildList();
end

function mog.sub.BuildList(module,tbl,top)
	wipe(list);
	wipe(display);
	module = module or mog.selected;
	tbl = tbl or mog.sub.selected.items;
	for k,v in ipairs(tbl) do
		local state = true;
		for x,y in ipairs(module.filters) do
			if not mog.filters[y.name].Filter(mog.sub.GetFilterArgs(y.name,v)) then
				state = false;
				break;
			end
		end
		if state then
			local disp = mog.sub.filters.display[v];
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
	mog:SetList(module,list,top);
end

for k,v in ipairs(addons) do
	local _,title,_,_,loadable = GetAddOnInfo(v);
	if loadable then
		mog:RegisterModule(v,{
			name = title:match("MogIt_(.+)") or title,
			Dropdown = Dropdown,
			FrameUpdate = FrameUpdate,
			FilterUpdate = FilterUpdate,
			OnEnter = OnEnter,
			OnClick = OnClick,
			OnScroll = OnScroll,
			Unlist = Unlist,
			filters = {
				{
					name = "level",
				},
				{
					name = "faction",
				},
				{
					name = "class",
				},
				{
					name = "source",
				},
				{
					name = "quality",
				},
				(v == "MogIt_OneHanded" and {
					name = "slot",
				}) or nil,
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