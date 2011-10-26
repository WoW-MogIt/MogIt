local MogIt,mog = ...;
local L = mog.L;

local LBI = LibStub("LibBabble-Inventory-3.0"):GetUnstrictLookupTable();
local list = {};
local display = {};
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

function mog.sub.DropdownTier1(self)
	if not self.value.loaded then
		LoadAddOn(self.value.name);
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
			local disp = mog.items.display[v];
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

function mog.sub.Help(module)
	GameTooltip:AddDoubleLine(L["Change item"],L["Left click"],0,1,0,1,1,1);
	GameTooltip:AddDoubleLine(L["Chat link"],L["Shift + Left click"],0,1,0,1,1,1);
	GameTooltip:AddDoubleLine(L["Try on"],L["Ctrl + Left click"],0,1,0,1,1,1);
	GameTooltip:AddDoubleLine(L["Add to wishlist"],L["Right click"],0,1,0,1,1,1);
	GameTooltip:AddDoubleLine(L["Item URL"],L["Shift + Right click"],0,1,0,1,1,1);
	GameTooltip:AddDoubleLine(L["Add to preview"],L["Ctrl + Right click"],0,1,0,1,1,1);
end

function mog.sub.AddSlot(label,addon)
	local items = {};
	local module = mog:GetModule(addon);
	table.insert(module.slots,{label = LBI[label] or label,items = items});
	return items;
end

mog.items.display = {};
mog.items.quality = {};
mog.items.level = {};
mog.items.faction = {};
mog.items.class = {};
mog.items.slot = {};
mog.items.source = {};
mog.items.sourceid = {};
mog.items.sourceinfo = {};
mog.items.zone = {};
mog.items.colours = {
	[1] = {},
	[2] = {},
	[3] = {},
	--[4] = {},
	--[5] = {},
};

function mog.sub.AddItem(tbl,id,display,quality,lvl,faction,class,slot,source,sourceid,zone,sourceinfo)
	table.insert(tbl,id);
	mog.items.display[id] = display;
	mog.items.quality[id] = quality;
	mog.items.level[id] = lvl;
	mog.items.faction[id] = faction;
	mog.items.class[id] = class;
	mog.items.slot[id] = slot;
	mog.items.source[id] = source;
	mog.items.sourceid[id] = sourceid;
	mog.items.sourceinfo[id] = sourceinfo;
	mog.items.zone[id] = zone;
end

function mog.sub.AddColours(id,c1,c2,c3)--,c4,c5)
	if c1 and (not mog.items.colours[1][id]) then
		mog.items.colours[1][id] = c1;
		mog.items.colours[2][id] = c2;
		mog.items.colours[3][id] = c3;
		--mog.items.colours[4][id] = c4;
		--mog.items.colours[5][id] = c5;
	end
end

function mog.sub.GetFilterArgs(filter,item)
	if filter == "level" then
		return mog.items.level[item];
	elseif filter == "faction" then
		return mog.items.faction[item];
	elseif filter == "class" then
		return mog.items.class[item];
	elseif filter == "source" then
		return mog.items.source[item],mog.items.sourceinfo[item];
	elseif filter == "quality" then
		return mog.items.quality[item];
	elseif filter == "slot" then
		return mog.items.slot[item];
	end
end

function mog.sub.SortLevel(id)
	if type(display[id]) == "table" then
		local tbl = {};
		for k,v in ipairs(display[id]) do
			table.insert(tbl,mog.items.level[v]);
		end
		return tbl;
	else
		return mog.items.level[display[id]];
	end
end

function mog.sub.SortColour(id)
	local tbl = {};
	for i=1,3 do
		if mog.items.colours[i][id] then
			table.insert(tbl,mog.items.colours[i][id]);
		end
	end
	return tbl;
end

for k,v in ipairs(addons) do
	local _,title,_,_,loadable = GetAddOnInfo(v);
	if loadable then
		mog:RegisterModule(v,{
			name = v,
			label = title:match("MogIt_(.+)") or title,
			--addon = v,
			slots = {},
			Dropdown = mog.sub.Dropdown,
			BuildList = mog.sub.BuildList,
			FrameUpdate = mog.sub.FrameUpdate,
			OnEnter = mog.sub.OnEnter,
			OnClick = mog.sub.OnClick,
			Unlist = mog.sub.Unlist,
			Help = mog.sub.Help,
			filters = {
				"level",
				"faction",
				"class",
				"source",
				"quality",
				(v == "MogIt_OneHanded" and "slot") or nil,
			},
			sorting = {
				"level",
				"colour",
			},
			sorts = {
				level = mog.sub.SortLevel,
				colour = mog.sub.SortColour,
			},
		},true);
	end
end

-- addon loader (and edit data.lua)
-- buildlist/setlist
-- filters/sort?
-- click etc