local MogIt,mog = ...;
local L = mog.L;

local f = mog:CreateFilter("moggable");
local showUnmoggable;

f:SetHeight(36);

local label = f:CreateFontString(nil,"ARTWORK","GameFontHighlightSmall");
label:SetPoint("TOPLEFT",f,"TOPLEFT",0,0);
label:SetPoint("RIGHT",f,"RIGHT",0,0);
label:SetText(L["Moggable"]..":");
label:SetJustifyH("LEFT");

local checkButton = CreateFrame("CheckButton","MogItFiltersMoggable",f,"UICheckButtonTemplate");
checkButton:SetText("Moggable");
checkButton:SetPoint("TOPLEFT",label,"BOTTOMLEFT",0,0);
checkButton:SetScript("OnClick",function(self)
	showUnmoggable = self:GetChecked();
	mog:BuildList();
end);

function f.Filter(moggable)
	return moggable or showUnmoggable;
end

function f.Default()
	showUnmoggable = false;
	checkButton:SetChecked(showUnmoggable);
end
f.Default();