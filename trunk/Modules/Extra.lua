local MogIt,mog = ...;
local L = mog.L;

local extras = {
	"MogIt_Sets",
	"MogIt_Mounts",
	"MogIt_Companions",
	"MogIt_Pets",
};

local function temp(module,tier)
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
	end
end

for k,v in ipairs(extras) do
	local _,title,_,_,loadable = GetAddOnInfo(v);
	if loadable then
		mog:RegisterModule(v,{
			name = title:match("MogIt_(.+)") or title,
			Dropdown = temp,
			addon = v,
		});
	end
end