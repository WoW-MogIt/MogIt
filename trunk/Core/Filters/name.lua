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
--[[f.edit:SetScript("OnFocusGained",function(self)
	
end);--]]
f.edit:SetScript("OnEnterPressed",EditBox_ClearFocus);
f.edit:SetScript("OnTextChanged",function(self,user)
	if user then
		searchString = self:GetText()-- or "";
		searchString = searchString:lower();
		mog:BuildList();
	end
end);
function f.edit.clearFunc(self)
	searchString = "";
	mog:BuildList();
end

function f.Filter(itemID)
	if searchString:trim() == "" then
		return true
	end
	local itemName = mog:GetItemInfo(itemID, "BuildList");
	return not itemName or (itemName:lower():find(searchString, nil, true));
end

function f.Default()
	searchString = "";
	f.edit:SetText(searchString);
end
f.Default();