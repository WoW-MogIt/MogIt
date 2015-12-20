local MogIt,mog = ...;
local L = mog.L;

local f = mog:CreateFilter("name");
local searchString;

f:SetHeight(35);

f.label = f:CreateFontString(nil,"ARTWORK","GameFontHighlightSmall");
f.label:SetPoint("TOPLEFT",f,"TOPLEFT",0,0);
f.label:SetPoint("RIGHT",f,"RIGHT",0,0);
f.label:SetText(NAME..":");
f.label:SetJustifyH("LEFT");

f.edit = CreateFrame("EditBox","MogItFiltersName",f,"SearchBoxTemplate");
f.edit:SetHeight(16);
f.edit:SetPoint("TOPLEFT",f.label,"BOTTOMLEFT",8,-5);
f.edit:SetPoint("RIGHT",f.label,"RIGHT",-2,0);
f.edit:SetAutoFocus(false);
f.edit:HookScript("OnTextChanged",function(self,user)
	searchString = self:GetText():lower();
	mog:BuildList();
end);

function f.Filter(item)
	if searchString:trim() == "" then
		return true
	end
	-- set
	if type(item) == "table" then
		return item.name:lower():find(searchString, nil, true)
	end
	local item = mog:GetItemInfo(item, "BuildList");
	return not item or (item.name:lower():find(searchString, nil, true));
end

function f.Default()
	searchString = "";
	f.edit:SetText(searchString);
end
f.Default();