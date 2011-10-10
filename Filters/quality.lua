local MogIt,mog = ...;
local L = mog.L;

local f = mog:AddFilter("quality");
local colours = ITEM_QUALITY_COLORS;
local selected;
local num;
local all;

f:SetHeight(41);

f.quality = f:CreateFontString(nil,"ARTWORK","GameFontHighlightSmall");
f.quality:SetPoint("TOPLEFT",f,"TOPLEFT",0,0);
f.quality:SetPoint("RIGHT",f,"RIGHT",0,0);
f.quality:SetText(QUALITY..":");
f.quality:SetJustifyH("LEFT");

f.dd = CreateFrame("Frame","MogItFiltersQualityDropdown",f,"UIDropDownMenuTemplate");
f.dd:SetPoint("TOPLEFT",f.quality,"BOTTOMLEFT",-16,-2);
UIDropDownMenu_SetWidth(f.dd,125);
UIDropDownMenu_SetButtonWidth(f.dd,140);
UIDropDownMenu_JustifyText(f.dd,"LEFT");
function f.dd.initialize(self)
	local info;
	info = UIDropDownMenu_CreateInfo();
	info.text =	all and L["Select All"] or L["Select None"];
	info.func = function(self)
		num = 0;
		for k,v in ipairs(mog.sub.slots) do
			selected[k] = all;
			num = num + (all and 1 or 0);
		end
		all = not all;
		UIDropDownMenu_SetText(f.dd,L["%d selected"]:format(num));
		ToggleDropDownMenu(1,nil,f.dd);
		if f.data.Dropdown then
			f.data.Dropdown(f.module,self,f);
		end
		if f.module.FilterUpdate then
			f.module:FilterUpdate(f);
		end
	end
	info.notCheckable = true;
	UIDropDownMenu_AddButton(info);
	
	for k,v in ipairs(mog.sub.quality) do
		info = UIDropDownMenu_CreateInfo();
		info.text =	_G["ITEM_QUALITY"..v.."_DESC"];
		info.value = v;
		info.colorCode = colours[v].hex;
		info.func = function(self)
			if selected[self.value] and (not self.checked) then
				num = num - 1;
			elseif (not selected[self.value]) and self.checked then
				num = num + 1;
			end
			selected[self.value] = self.checked;
			UIDropDownMenu_SetText(f.dd,L["%d selected"]:format(num));
			if f.data.Dropdown then
				f.data.Dropdown(f.module,self,f);
			end
			if f.module.FilterUpdate then
				f.module:FilterUpdate(f);
			end
		end
		info.keepShownOnClick = true;
		info.isNotRadio = true;
		info.checked = selected[k];
		UIDropDownMenu_AddButton(info);
	end
end

f:SetScript("OnShow",function(self)
	if f.data.OnShow then
		f.data.OnShow(f.module,f);
	end
end);

function f.Filter(qual)
	return (not qual) or selected[qual];
end

function f.Default()
	selected = {};
	num = 0;
	all = nil;
	
	for k,v in ipairs(mog.sub.quality) do
		selected[k] = true;
		num = num + 1;
	end

	UIDropDownMenu_SetText(f.dd,L["%d selected"]:format(num));
end
f.Default();