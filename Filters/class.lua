local MogIt,mog = ...;
local L = mog.L;

local f = mog:CreateFilter("class");
local coords = CLASS_ICON_TCOORDS;
local colours = RAID_CLASS_COLORS;
local class;
local selected;
local num;
local all;

f:SetHeight(41);

f.class = f:CreateFontString(nil,"ARTWORK","GameFontHighlightSmall");
f.class:SetPoint("TOPLEFT",f,"TOPLEFT",0,0);
f.class:SetPoint("RIGHT",f,"RIGHT",0,0);
f.class:SetText(CLASS..":");
f.class:SetJustifyH("LEFT");

f.dd = CreateFrame("Frame","MogItFiltersClassDropdown",f,"UIDropDownMenuTemplate");
f.dd:SetPoint("TOPLEFT",f.class,"BOTTOMLEFT",-16,-2);
UIDropDownMenu_SetWidth(f.dd,125);
UIDropDownMenu_SetButtonWidth(f.dd,140);
UIDropDownMenu_JustifyText(f.dd,"LEFT");

local function SelectAll(self)
	num = 0;
	class = 0;
	for k,v in pairs(LOCALIZED_CLASS_NAMES_MALE) do
		selected[k] = all;
		num = num + (all and 1 or 0);
		class = class + (all and mog.sub.classBits[k] or 0);
	end
	all = not all;
	UIDropDownMenu_SetText(f.dd,L["%d selected"]:format(num));
	ToggleDropDownMenu(1,nil,f.dd);
	mog:BuildList();
end

local function ddTier1(self)
	if selected[self.value] and (not self.checked) then
		class = class - mog.sub.classBits[self.value];
		num = num - 1;
	elseif (not selected[self.value]) and self.checked then
		class = class + mog.sub.classBits[self.value];
		num = num + 1;
	end
	selected[self.value] = self.checked;
	UIDropDownMenu_SetText(f.dd,L["%d selected"]:format(num));
	mog:BuildList();
end

function f.dd.initialize(self)
	local info;
	info = UIDropDownMenu_CreateInfo();
	info.text =	all and L["Select All"] or L["Select None"];
	info.func = SelectAll;
	info.notCheckable = true;
	UIDropDownMenu_AddButton(info);
	
	for k,v in pairs(LOCALIZED_CLASS_NAMES_MALE) do
		info = UIDropDownMenu_CreateInfo();
		info.text =	v;
		info.value = k;
		info.colorCode = string.format("\124cff%.2x%.2x%.2x",colours[k].r*255,colours[k].g*255,colours[k].b*255);
		info.func = ddTier1;
		info.keepShownOnClick = true;
		info.isNotRadio = true;
		info.checked = selected[k];
		info.icon = "Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes";
		info.tCoordLeft = coords[k][1];
		info.tCoordRight = coords[k][2];
		info.tCoordTop = coords[k][3];
		info.tCoordBottom = coords[k][4];
		UIDropDownMenu_AddButton(info);
	end
end

function f.Filter(input)
	return (not input) or (bit.band(class,input)>0); 
end

function f.Default()
	class = mog.sub.classBits[select(2,UnitClass("PLAYER"))];
	selected = {[select(2,UnitClass("PLAYER"))] = true};
	num = 1;
	all = true;
	UIDropDownMenu_SetText(f.dd,L["%d selected"]:format(num));
end
f.Default();