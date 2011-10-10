local MogIt,mog = ...;
local L = mog.L;

local f = mog:AddFilter("faction");
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
	if f.data.Alliance then
		f.data.Alliance(f.module,self,f);
	end
	if f.module.FilterUpdate then
		f.module:FilterUpdate(f);
	end
end);

f.horde = CreateFrame("CheckButton","MogItFiltersFactionHorde",f,"UICheckButtonTemplate");
MogItFiltersFactionHordeText:SetText(FACTION_HORDE);
f.horde:SetPoint("TOPLEFT",f.alliance,"BOTTOMLEFT",0,0);
f.horde:SetScript("OnClick",function(self)
	horde = self:GetChecked();
	if f.data.Horde then
		f.data.Horde(f.module,self,f);
	end
	if f.module.FilterUpdate then
		f.module:FilterUpdate(f);
	end
end);

f:SetScript("OnShow",function(self)
	if f.data.OnShow then
		f.data.OnShow(f.module,f);
	end
end);

function f.Filter(faction,a,h)
	a = a or alliance;
	h = h or horde;
	return (not faction) or (faction == 1 and a) or (faction == 2 and h);
end

function f.Default()
	alliance = UnitFactionGroup("PLAYER") == "Alliance";
	f.alliance:SetChecked(alliance);
	horde = UnitFactionGroup("PLAYER") == "Horde";
	f.horde:SetChecked(horde);
end
f.Default();