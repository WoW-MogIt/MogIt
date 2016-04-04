local MogIt,mog = ...;
local L = mog.L;

local f = mog:CreateFilter("hasItem");
local enabled;

f:SetHeight(41);

f.label = f:CreateFontString(nil,nil,"GameFontHighlightSmall");
f.label:SetPoint("TOPLEFT");
f.label:SetPoint("RIGHT");
f.label:SetText(L["Owned items"]..":");
f.label:SetJustifyH("LEFT");

f.hasItem = CreateFrame("CheckButton",nil,f,"UICheckButtonTemplate");
f.hasItem.text:SetText(L["Only items you own"]);
f.hasItem:SetPoint("TOPLEFT",f.label,"BOTTOMLEFT");
f.hasItem:SetScript("OnClick",function(self)
	enabled = self:GetChecked();
	mog:BuildList();
end);

function f.Filter(item)
	if not enabled then
		return true
	end
	if type(item) == "table" then return end
	return mog:HasItem(item);
end

function f.Default()
	f.hasItem:SetChecked(false);
	enabled = false;
end
f.Default();