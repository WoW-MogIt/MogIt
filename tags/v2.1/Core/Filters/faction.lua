local MogIt,mog = ...;
local L = mog.L;

local f = mog:CreateFilter("faction");
local alliance;
local horde;

f:SetHeight(69);

f.faction = f:CreateFontString(nil,"ARTWORK","GameFontHighlightSmall");
f.faction:SetPoint("TOPLEFT",f,"TOPLEFT",0,0);
f.faction:SetPoint("RIGHT",f,"RIGHT",0,0);
f.faction:SetText(L["Faction"]..":");
f.faction:SetJustifyH("LEFT");

f.alliance = CreateFrame("CheckButton","MogItFiltersFactionAlliance",f,"UICheckButtonTemplate");
MogItFiltersFactionAllianceText:SetText(FACTION_ALLIANCE);
f.alliance:SetPoint("TOPLEFT",f.faction,"BOTTOMLEFT",0,0);
f.alliance:SetScript("OnClick",function(self)
	alliance = self:GetChecked();
	mog:BuildList();
end);

f.horde = CreateFrame("CheckButton","MogItFiltersFactionHorde",f,"UICheckButtonTemplate");
MogItFiltersFactionHordeText:SetText(FACTION_HORDE);
f.horde:SetPoint("TOPLEFT",f.alliance,"BOTTOMLEFT",0,0);
f.horde:SetScript("OnClick",function(self)
	horde = self:GetChecked();
	mog:BuildList();
end);

function f.Filter(faction)
	return (not faction) or (faction == 1 and alliance) or (faction == 2 and horde);
end

function f.Default()
	alliance = UnitFactionGroup("PLAYER") == "Alliance";
	f.alliance:SetChecked(alliance);
	horde = UnitFactionGroup("PLAYER") == "Horde";
	f.horde:SetChecked(horde);
end
f.Default();