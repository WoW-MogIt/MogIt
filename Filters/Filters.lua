local MogIt,mog = ...;
local L = mog.L;

mog.filt = CreateFrame("Frame","MogItFilters",mog.frame);

mog.filters = {};

function mog:AddFilter(name,frame)
	if mog.filters[name] then return end;
	frame = frame or CreateFrame("Frame");
	frame:Hide();
	frame:SetParent(mog.filt);
	frame.data = {};
	mog.filters[name] = frame;
	return frame;
end