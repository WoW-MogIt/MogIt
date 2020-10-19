local MogIt,mog = ...;
local L = mog.L;

local f = mog:CreateFilter("hasItem");
local collected, notCollected;

f:SetHeight(41);

f.label = f:CreateFontString(nil,nil,"GameFontHighlightSmall");
f.label:SetPoint("TOPLEFT");
f.label:SetPoint("RIGHT");
f.label:SetText(L["Owned items"]..":");
f.label:SetJustifyH("LEFT");

f.hasItem = CreateFrame("CheckButton",nil,f,"UICheckButtonTemplate");
f.hasItem.text:SetText(L["Items you have collected"]);
f.hasItem:SetPoint("TOPLEFT",f.label,"BOTTOMLEFT");
f.hasItem:SetScript("OnClick",function(self)
	collected = self:GetChecked();
	mog:BuildList();
end);

f.hasNotItem = CreateFrame("CheckButton",nil,f,"UICheckButtonTemplate");
f.hasNotItem.text:SetText(L["Items you have not collected"]);
f.hasNotItem:SetPoint("TOPLEFT",f.hasItem,"BOTTOMLEFT");
f.hasNotItem:SetScript("OnClick",function(self)
	notCollected = self:GetChecked();
	mog:BuildList();
end);

function f.Filter(item)
	if collected and notCollected then
		return true
	end
	if not collected and not notCollected then
		return false
	end
	if type(item) == "table" then return end
	if collected then return mog:HasItem(item); end
	if notCollected then return not mog:HasItem(item); end
end

function f.Default()
	f.hasItem:SetChecked(true);
	f.hasNotItem:SetChecked(true);
	collected = true;
	notCollected = true;
end
f.Default();