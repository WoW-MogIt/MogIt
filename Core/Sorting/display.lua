local MogIt,mog = ...;
local L = mog.L;

local function dropdownTier1(self)
	mog:SortList("display");
end

mog:CreateSort("display",{
	label = L["Display ID"],
	Dropdown = function(module,tier)
		local info;
		info = UIDropDownMenu_CreateInfo();
		info.text = L["Display ID"];
		info.value = "display";
		info.func = dropdownTier1;
		info.checked = mog.sorting.active == "display";
		UIDropDownMenu_AddButton(info);
	end,
	Sort = function(args)
		table.sort(mog.list, function(a, b) return a > b end);
	end,
});