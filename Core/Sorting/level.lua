local MogIt,mog = ...;
local L = mog.L;

local itemCache = {};
local function minItem(id,args)
	if not itemCache[id] then
		local levels = args and args(id);
		if type(levels) == "table" then
			for k,v in pairs(levels) do
				if (not itemCache[id]) or (v and (v < itemCache[id])) then
					itemCache[id] = v;
				end
			end
			itemCache[id] = itemCache[id] or 0;
		else
			itemCache[id] = levels or 0;
		end
	end
	return itemCache[id];
end

local function dropdownTier1(self)
	mog:SortList("level");
end

mog:CreateSort("level",{
	label = LEVEL,
	Dropdown = function(module,tier)
		local info;
		info = UIDropDownMenu_CreateInfo();
		info.text = LEVEL;
		info.value = "level";
		info.func = dropdownTier1;
		info.checked = mog.sorting.active == "level";
		UIDropDownMenu_AddButton(info);
	end,
	Sort = function(args)
		wipe(itemCache);
		table.sort(mog.list,function(a,b)
			local aLv, bLv = minItem(a,args), minItem(b,args);
			if aLv == bLv then
				return mog:GetData("item", a[1], "display") > mog:GetData("item", b[1], "display");
			else
				return aLv > bLv;
			end
		end);
	end,
	Unlist = function()
		wipe(itemCache);
	end,
});