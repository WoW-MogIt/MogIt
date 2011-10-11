local MogIt,mog = ...;
local L = mog.L;

local LBB = LibStub("LibBabble-Boss-3.0"):GetUnstrictLookupTable();
local mobs = {};

local tooltip = CreateFrame("GameTooltip","MogItMobsTooltip");
local text = tooltip:CreateFontString();
tooltip:AddFontStrings(text,tooltip:CreateFontString());

local function CachedMob(id)
	tooltip:SetOwner(WorldFrame,"ANCHOR_NONE");
	tooltip:SetHyperlink(("unit:0xF53%05X00000000"):format(id));
	if (tooltip:IsShown()) then
		return text:GetText();
	end
end

function mog.AddMob(id,name)
	if not (mobs[id] or CachedMob(id)) then
		mobs[id] = LBB[name] or name;
	end
end

function mog.GetMob(id)
	local name = CachedMob(id);
	if name then
		mobs[id] = nil;
		return name;
	else
		return mobs[id];
	end
end