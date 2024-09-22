local MogIt,mog = ...;
local L = mog.L;

local function onClick(self)
	if self.value.loaded then
		self.value.active = nil;
		mog:SetModule(self.value, self.value.label);
	else
		C_AddOns.LoadAddOn(self.value.name);
	end
end

local function temp(module,tier)
	local info;
	if tier == 1 then
		info = UIDropDownMenu_CreateInfo();
		info.text = module.label..(module.loaded and "" or " \124cFFFFFFFF("..L["Click to load addon"]..")");
		info.value = module;
		info.colorCode = "\124cFF"..(module.loaded and "00FF00" or "FF0000");
		info.keepShownOnClick = true;
		info.notCheckable = true;
		info.func = onClick;
		if module.version < mog.moduleVersion then
			info.tooltipOnButton = true;
			info.tooltipTitle = RED_FONT_COLOR_CODE..ADDON_INTERFACE_VERSION;
			info.tooltipText = L["This module was created for an older version of MogIt and may not work correctly."];
		elseif module.version > mog.moduleVersion then
			info.tooltipOnButton = true;
			info.tooltipTitle = RED_FONT_COLOR_CODE..ADDON_INTERFACE_VERSION;
			info.tooltipText = L["This module was created for a newer version of MogIt and may not work correctly."];
		end
		UIDropDownMenu_AddButton(info,tier);
	end
end

for i=1,C_AddOns.GetNumAddOns() do
	local name,title,_,_,loadable = C_AddOns.GetAddOnInfo(i);
	if loadable and (not mog:GetModule(name)) then
		local version = tonumber(C_AddOns.GetAddOnMetadata(name,"X-MogItModuleVersion"));
		if version then
			mog:RegisterModule(name,version,{
				label = title:match("^MogIt[%s%-_:]+(.+)") or title,
				Dropdown = temp,
			});
		end
	end
end