local MogIt,mog = ...;
local L = mog.L;

local function temp(module,tier)
	local info;
	if tier == 1 then
		info = UIDropDownMenu_CreateInfo();
		info.text = module.name..(module.loaded and "" or " \124cFFFFFFFF("..L["Click to load addon"]..")");
		info.value = module;
		info.colorCode = "\124cFF"..(module.loaded and "00FF00" or "FF0000");
		info.keepShownOnClick = true;
		info.notCheckable = true;
		info.func = function(self)
			if not self.value.loaded then
				LoadAddOn(self.value.addon);
			end
		end
		UIDropDownMenu_AddButton(info,tier);
	end
end

local base = {
	MogIt_Cloth = true,
	MogIt_Leather = true,
	MogIt_Mail = true,
	MogIt_Plate = true,
	MogIt_OneHanded = true,
	MogIt_TwoHanded = true,
	MogIt_Ranged = true,
	MogIt_Other = true,
	MogIt_Accessories = true,
};

for i=1,GetNumAddOns() do
	local name,title,_,_,loadable = GetAddOnInfo(i);
	if loadable and (not base[name]) and name:find("^MogIt_") then
		mog:RegisterModule(name,{
			name = title:match("^MogIt_(.+)") or title,
			Dropdown = temp,
			addon = name,
		});
	end
end