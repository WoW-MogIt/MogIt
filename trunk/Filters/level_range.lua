local MogIt,mog = ...;
local L = mog.L;

local f = mog:AddFilter("level_range");
local minlvl;
local maxlvl;

f.label = f:CreateFontString(nil,"ARTWORK","GameFontHighlightSmall");
f.label:SetPoint("TOPLEFT",f,"TOPLEFT",0,0);
f.label:SetPoint("RIGHT",f,"RIGHT",0,0);
f.label:SetText(LEVEL_RANGE..":");
f.label:SetJustifyH("LEFT");

f.min = CreateFrame("EditBox","MogItFiltersLevelRangeMin",f,"InputBoxTemplate");
f.min:SetSize(25,16);
f.min:SetPoint("TOPLEFT",f.label,"BOTTOMLEFT",8,-5);
f.min:SetNumeric(true);
f.min:SetMaxLetters(2);
f.min:SetAutoFocus(false);
f.min:SetScript("OnEnterPressed",EditBox_ClearFocus);
f.min:SetScript("OnTabPressed",function(self)
	f.max:SetFocus();
end);
f.min:SetScript("OnTextChanged",function(self,user)
	minlvl = self:GetNumber() or 0;
	if user then
		if f.data.MinLevel then
			f.data.MinLevel(f.module,self,f);
		end
	end
end);

f.dash = f:CreateFontString(nil,"ARTWORK","GameFontHighlightSmall");
f.dash:SetPoint("LEFT",f.min,"RIGHT",0,1);
f.dash:SetText("-");

f.max = CreateFrame("EditBox","MogItFiltersLevelRangeMax",f,"InputBoxTemplate");
f.max:SetSize(25,16);
f.max:SetPoint("LEFT",f.min,"RIGHT",12,0);
f.max:SetNumeric(true);
f.max:SetMaxLetters(2);
f.max:SetAutoFocus(false);
f.max:SetScript("OnEnterPressed",EditBox_ClearFocus);
f.max:SetScript("OnTabPressed",function(self)
	f.min:SetFocus();
end);
f.max:SetScript("OnTextChanged",function(self,user)
	maxlvl = self:GetNumber() or PLAYER_MAX_LEVEL;
	if user then
		if f.data.MaxLevel then
			f.data.MaxLevel(f.module,self,f);
		end
	end
end);

f:SetScript("OnShow",function(self)
	if f.data.OnShow then
		f.data.OnShow(f.module,f);
	end
end);

function f.Filter(lvl,min,max)
	min = min or minlvl or 0;
	max = max or maxlvl or MAX_PLAYER_LEVEL;
	lvl = lvl or 0;
	return (lvl >= min) and (lvl <= max);
end

function f.Default()
	f.min:SetNumber(0);
	f.max:SetNumber(UnitLevel("PLAYER"));
end
f.Default();