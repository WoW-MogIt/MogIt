local MogIt,mog = ...;
local L = mog.L;

local LBB = LibStub("LibBabble-Boss-3.0"):GetUnstrictLookupTable();
local mobs = {};
local objects = {};

local tooltip = CreateFrame("GameTooltip","MogItMobsTooltip");
local text = tooltip:CreateFontString();
tooltip:AddFontStrings(text,tooltip:CreateFontString());

local function CachedMob(id)
	if not id then return end;
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
	return mobs[id] or CachedMob(id);
end

function mog.AddObject(id,name)
	objects[id] = LBB[name] or name;
end

function mog.GetObject(id)
	return objects[id];
end