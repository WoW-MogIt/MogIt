local MogIt,mog = ...;
local L = mog.L;

local f = mog:CreateFilter("faction");
local alliance;
local horde;

local factions = {
	[1] = "Alliance",
	[2] = "Horde",
}

local settings = {
	Alliance = false,
	Horde = false,
}

f:SetHeight(69);

f.faction = f:CreateFontString(nil,nil,"GameFontHighlightSmall");
f.faction:SetPoint("TOPLEFT");
f.faction:SetPoint("RIGHT");
f.faction:SetText(L["Faction"]..":");
f.faction:SetJustifyH("LEFT");

local function onClick(self)
	settings[self.value] = self:GetChecked();
	mog:BuildList();
end

f.Alliance = CreateFrame("CheckButton",nil,f,"UICheckButtonTemplate");
f.Alliance.text:SetText(FACTION_ALLIANCE);
f.Alliance:SetPoint("TOPLEFT",f.faction,"BOTTOMLEFT");
f.Alliance:SetScript("OnClick",onClick);
f.Alliance.value = "Alliance";

f.Horde = CreateFrame("CheckButton",nil,f,"UICheckButtonTemplate");
f.Horde.text:SetText(FACTION_HORDE);
f.Horde:SetPoint("TOPLEFT",f.Alliance,"BOTTOMLEFT");
f.Horde:SetScript("OnClick",onClick);
f.Horde.value = "Horde";

function f.Filter(faction)
	return (not faction) or (settings[factions[faction]]);
end

function f.Default()
	for i, faction in ipairs(factions) do
		local value = UnitFactionGroup("PLAYER") == faction;
		settings[faction] = value;
		f[faction]:SetChecked(value);
	end
end
f.Default();