local MogIt,mog = ...;
local L = mog.L;

local LBB = LibStub("LibBabble-Boss-3.0"):GetUnstrictLookupTable();
local bosses = {};

local tooltip = CreateFrame("GameTooltip","MogItBossesTooltip");
local text = tooltip:CreateFontString();
tooltip:AddFontStrings(text,tooltip:CreateFontString());

local function CachedName(id)
	tooltip:SetOwner(WorldFrame,"ANCHOR_NONE");
	tooltip:SetHyperlink(("unit:0xF53%05X00000000"):format(id));
	if (tooltip:IsShown()) then
		return text:GetText();
	end
end

function mog:AddBoss(id,name)
	if not (bosses[id] or CachedName(id)) then
		bosses[id] = LBB[name] or name;
	end
end

function mog:GetBoss(id)
	local name = CachedName(id);
	if name then
		bosses[id] = nil;
		return name;
	else
		return bosses[id];
	end
end