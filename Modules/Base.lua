local MogIt, mog = ...;
local L = mog.L;

mog.base = {};
local tinsert = table.insert;
local sort = table.sort;
local ipairs = ipairs;


--// Base Functions
local list = {};

function mog.base.DropdownTier2(self, module, categoryModule)
	module.active = categoryModule
	if categoryModule.loaded then
		mog:SetModule(module, module.label.." - "..categoryModule.label)
	else
		mog.queueModule = categoryModule
		C_TransmogCollection.SetSearchAndFilterCategory(categoryModule.category)
	end
	CloseDropDownMenus()
end

function mog.base.Dropdown(module, tier)
	if tier == 1 then
		local info = UIDropDownMenu_CreateInfo();
		info.text = module.label;
		info.value = module;
		info.hasArrow = true;
		info.keepShownOnClick = true;
		info.notCheckable = true;
		UIDropDownMenu_AddButton(info, tier);
	elseif tier == 2 then
		local info = UIDropDownMenu_CreateInfo();
		info.text = ARMOR;
		info.isTitle = true;
		info.notCheckable = true;
		UIDropDownMenu_AddButton(info, tier);

		for i, slot in ipairs(module.slotList) do
			if slot.isWeapon and not module.slotList[i - 1].isWeapon then
				local info = UIDropDownMenu_CreateInfo();
				info.text = WEAPON;
				info.isTitle = true;
				info.notCheckable = true;
				UIDropDownMenu_AddButton(info, tier);
			end
			local info = UIDropDownMenu_CreateInfo();
			info.text = slot.label;
			info.value = slot;
			info.notCheckable = true;
			info.func = mog.base.DropdownTier2;
			info.arg1 = module;
			info.arg2 = slot;
			UIDropDownMenu_AddButton(info, tier);
		end
	end
end

function mog.base:FrameUpdate(frame, value)
	local items = { };
	local canUse = false;
	for i, source in ipairs(value) do
		local _, _, _, _, _, itemLink = C_TransmogCollection.GetAppearanceSourceInfo(source);
		tinsert(items, itemLink);
		local sourceInfo = C_TransmogCollection.GetSourceInfo(source);
		if not (sourceInfo.useErrorType == Enum.TransmogUseErrorType.Race or sourceInfo.useErrorType == Enum.TransmogUseErrorType.Faction) then
			canUse = true;
		end
	end
	if not canUse then
		frame.bg:SetColorTexture(1.0, 0.3, 0.3, 0.2);
	else
		frame.bg:SetColorTexture(0.3, 0.3, 0.3, 0.2);
	end
	frame.data.items = items;
	frame.data.sourceID = value[1];
	frame.data.cycle = 1;
	frame.data.item = items[frame.data.cycle];
	for i, item in ipairs(items) do
		if mog:HasItem(value[i]) then
			frame:ShowIndicator("hasItem");
		end
		if mog.wishlist:IsItemInWishlist(item) then
			frame:ShowIndicator("wishlist");
		end
	end
	mog.Item_FrameUpdate(frame, frame.data);
end

function mog.base:OnEnter(frame, value)
	local data = frame.data;
	mog.ShowItemTooltip(frame, data.item, data.items);
end

function mog.base:OnClick(frame, btn, value)
	mog.Item_OnClick(frame, btn, frame.data);
end

function mog.base.Unlist(module)
	wipe(list);
end

local function itemSort(a, b)
	local aLevel = mog:GetData("item", a, "level") or 0;
	local bLevel = mog:GetData("item", b, "level") or 0;
	if aLevel == bLevel then
		return a > b;
	else
		return aLevel < bLevel;
	end
end

local function buildList(module, slot, list, items)
	for _, item in ipairs(slot) do
		if mog:CheckFilters(module, item) then
			local display = mog:GetData("item", item, "display");
			if display then
				if not items[display] then
					items[display] = {};
					tinsert(list, items[display]);
				end
				tinsert(items[display], item);
			end
		end
	end
end

function mog.base.BuildList(module)
	wipe(list);
	local items = {};
	if module.active then
		buildList(module, module.active.list, list, items);
	else
		for _, data in pairs(module.slots) do
			buildList(module, data.list, list, items);
		end
	end
	for _,tbl in ipairs(list) do
		sort(tbl, itemSort);
	end
	items = nil;
	return list;
end

mog.base.Help = {
	L["Left click to cycle through items"],
	L["Right click for additional options"],
	L["Shift-left click to link"],
	L["Shift-right click for item URL"],
	L["Ctrl-left click to try on in dressing room"],
	L["Ctrl-right click to preview with MogIt"],
}

function mog.base.GetFilterArgs(filter,item)
	if filter == "name" or filter == "level" or filter == "expansion" or filter == "quality" or filter == "itemLevel" or filter == "bind" or filter == "hasItem" or filter == "chestType" then
		return item;
	elseif filter == "source" then
		return mog:GetData("item", item, "source"),mog:GetData("item", item, "sourceinfo");
	else
		return mog:GetData("item", item, filter);
	end
end

--//


--// Register Modules
local classes = { }

for classID = 1, GetNumClasses() do
	local classInfo = C_CreatureInfo.GetClassInfo(classID)
	table.insert(classes, classInfo)
end

for _, class in ipairs(classes) do
	local module = mog:RegisterModule(class.classFile, mog.moduleVersion, {
		label = class.className,
		base = true,
		classID = class.classID,
		slots = { },
		slotList = { },
		Dropdown = mog.base.Dropdown,
		BuildList = mog.base.BuildList,
		FrameUpdate = mog.base.FrameUpdate,
		OnEnter = mog.base.OnEnter,
		OnClick = mog.base.OnClick,
		Unlist = mog.base.Unlist,
		Help = mog.base.Help,
		GetFilterArgs = mog.base.GetFilterArgs,
		filters = {
			"name",
			"level",
			"itemLevel",
			"source",
			"expansion",
			"quality",
			"bind",
			"chestType",
		},
		sorting = {
			"display",
		},
		sorts = { },
	})
	if module then
		-- dirty fix for now - if the "slot" filter is not present the array is broken unless we do this
		tinsert(module.filters, "hasItem")
	end
end
--//