local MogIt,mog = ...;
local L = mog.L;

mog.base = {};
local LBI = LibStub("LibBabble-Inventory-3.0"):GetUnstrictLookupTable();
local LBB = LibStub("LibBabble-Boss-3.0"):GetUnstrictLookupTable();
local tinsert = table.insert;
local sort = table.sort;
local ipairs = ipairs;
local select = select;


--// Input Functions
function mog.base.AddSlot(slot,addon)
	local module = mog:GetModule(addon);
	if not module.slots[slot] then
		module.slots[slot] = {
			label = LBI[slot] or slot,
			list = {},
		};
		tinsert(module.slotList,slot);
	end
	local list = module.slots[slot].list;
	
	return function(id,display,quality,lvl,faction,class,slot,source,sourceid,zone,sourceinfo)
		tinsert(list,id);
		mog:AddData("item", id, "display", display);
		mog:AddData("item", id, "quality", quality);
		mog:AddData("item", id, "level", lvl);
		mog:AddData("item", id, "faction", faction);
		mog:AddData("item", id, "class", class);
		mog:AddData("item", id, "slot", slot);
		mog:AddData("item", id, "source", source);
		mog:AddData("item", id, "sourceid", sourceid);
		mog:AddData("item", id, "sourceinfo", sourceinfo);
		mog:AddData("item", id, "zone", zone);
		tinsert(mog:GetData("display",display,"items") or mog:AddData("display",display,"items",{}),id);
	end
end

function mog.base.AddColours(display,c1,c2,c3)
	--mog:AddData("display",display,"colours",colours);
	mog:AddData("display",display,"colour1",c1);
	mog:AddData("display",display,"colour2",c2);
	mog:AddData("display",display,"colour3",c3);
end

function mog.base.AddNPC(id,name)
	mog:AddData("npc", id, "name", LBB[name] or name);
end

function mog.base.AddObject(id,name)
	mog:AddData("object", id, "name", LBB[name] or name);
end
--//


--// Base Functions
local list = {};

function mog.base.DropdownTier1(self)
	if not self.value.loaded then
		LoadAddOn(self.value.name);
	end
end

function mog.base.DropdownTier2(self)
	self.arg1.active = self.value;
	mog:SetModule(self.arg1,self.arg1.label.." - "..self.value.label);
	CloseDropDownMenus();
end

function mog.base.Dropdown(module,tier)
	local info;
	if tier == 1 then
		info = UIDropDownMenu_CreateInfo();
		info.text = module.label..(module.loaded and "" or " \124cFFFFFFFF("..L["Click to load addon"]..")");
		info.value = module;
		info.colorCode = "\124cFF"..(module.loaded and "00FF00" or "FF0000");
		info.hasArrow = module.loaded;
		info.keepShownOnClick = true;
		info.notCheckable = true;
		info.func = mog.base.DropdownTier1;
		UIDropDownMenu_AddButton(info,tier);
	elseif tier == 2 then
		for _,slot in ipairs(module.slotList) do
			info = UIDropDownMenu_CreateInfo();
			info.text = module.slots[slot].label;
			info.value = module.slots[slot];
			info.notCheckable = true;
			info.func = mog.base.DropdownTier2;
			info.arg1 = module;
			UIDropDownMenu_AddButton(info,tier);
		end
	end
end

function mog.base.FrameUpdate(module,self,value)
	self.data.items = value;
	self.data.cycle = 1;
	self.data.item = self.data.items[self.data.cycle];
	for i, v in ipairs(self.data.items) do
		if GetItemCount(v, true) > 0 then
			self:ShowIndicator("hasItem");
		end
		if mog.wishlist:IsItemInWishlist(v) then
			self:ShowIndicator("wishlist");
		end
	end
	mog.Item_FrameUpdate(self,self.data);
end

function mog.base.OnEnter(module,self,value)
	mog.Item_OnEnter(self,self.data);
end

function mog.base.OnClick(module,self,btn,value)
	mog.Item_OnClick(self,btn,self.data);
end

function mog.base.Unlist(module)
	wipe(list);
end

local function itemSort(a, b)
	local aLevel = mog:GetData("item",a,"level") or 0;
	local bLevel = mog:GetData("item",b,"level") or 0;
	if aLevel == bLevel then
		return a < b;
	else
		return aLevel < bLevel;
	end
end

function mog.base.BuildList(module)
	wipe(list);
	local items = {};
	for _,item in ipairs(module.active.list) do
		local state = true;
		for _,filter in ipairs(module.filters) do
			if not mog:GetFilter(filter).Filter(mog.base.GetFilterArgs(filter,item)) then
				state = false;
				break;
			end
		end
		if state then
			local display = mog:GetData("item", item, "display");
			if not items[display] then
				items[display] = {};
				tinsert(list,items[display]);
			end
			tinsert(items[display],item);
		end
	end
	for _,tbl in ipairs(list) do
		sort(tbl,itemSort);
	end
	items = nil;
	return list;
end

function mog.base.Help(module)
	GameTooltip:AddDoubleLine(L["Change item"],		L["Left click"],			0,1,0,1,1,1);
	GameTooltip:AddDoubleLine(L["Chat link"],		L["Shift + Left click"],	0,1,0,1,1,1);
	GameTooltip:AddDoubleLine(L["Try on"],			L["Ctrl + Left click"],		0,1,0,1,1,1);
	GameTooltip:AddDoubleLine(L["Wishlist menu"],	L["Right click"],			0,1,0,1,1,1);
	GameTooltip:AddDoubleLine(L["Item URL"],		L["Shift + Right click"],	0,1,0,1,1,1);
	GameTooltip:AddDoubleLine(L["Add to preview"],	L["Ctrl + Right click"],	0,1,0,1,1,1);
end

function mog.base.GetFilterArgs(filter,item)
	if filter == "name" then
		return GetItemInfo(item);
	elseif filter == "itemLevel" then
		return select(4,GetItemInfo(item));
	elseif filter == "source" then
		return mog:GetData("item", item, "source"),mog:GetData("item", item, "sourceinfo");
	else
		return mog:GetData("item", item, filter);
	end
end

function mog.base.SortLevel(items)
	-- return mog:GetData("item",items[1],"level");
	local tbl = {};
	for k,v in ipairs(items) do
		table.insert(tbl,mog:GetData("item", v, "level"));
	end
	return tbl;
end

function mog.base.SortColour(items)
	local display = mog:GetData("item",items[1],"display");
	return {mog:GetData("display",display,"colour1"),mog:GetData("display",display,"colour2"),mog:GetData("display",display,"colour3")};
	--return mog:GetData("display",display,"colours");
end
--//


--// Register Modules
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

for _,addon in ipairs(addons) do
	local _,title,_,_,loadable = GetAddOnInfo(addon);
	if loadable then
		mog:RegisterModule(addon,mog.moduleVersion,{
			label = title:match("MogIt_(.+)") or title,
			base = true,
			slots = {},
			slotList = {},
			Dropdown = mog.base.Dropdown,
			BuildList = mog.base.BuildList,
			FrameUpdate = mog.base.FrameUpdate,
			OnEnter = mog.base.OnEnter,
			OnClick = mog.base.OnClick,
			Unlist = mog.base.Unlist,
			Help = mog.base.Help,
			filters = {
				"name",
				"level",
				"itemLevel",
				"faction",
				"class",
				"source",
				"quality",
				(v == "MogIt_OneHanded" and "slot") or nil,
			},
			sorting = {
				"level",
				"colour",
				"display",
			},
			sorts = {
				level = mog.base.SortLevel,
				colour = mog.base.SortColour,
			},
		});
	end
end
--//


-- options to disable filters/info?