local MogIt,mog = ...;
local L = mog.L;

local f = mog:CreateFilter("level");
local minlvl;
local maxlvl;

f:SetHeight(35);

f.label = f:CreateFontString(nil,"ARTWORK","GameFontHighlightSmall");
f.label:SetPoint("TOPLEFT",f,"TOPLEFT",0,0);
f.label:SetPoint("RIGHT",f,"RIGHT",0,0);
f.label:SetText(LEVEL_RANGE..":");
f.label:SetJustifyH("LEFT");

f.min = CreateFrame("EditBox","MogItFiltersLevelMin",f,"InputBoxTemplate");
f.min:SetSize(32,16);
f.min:SetPoint("TOPLEFT",f.label,"BOTTOMLEFT",8,-5);
f.min:SetNumeric(true);
f.min:SetMaxLetters(3);
f.min:SetAutoFocus(false);
f.min:SetScript("OnEnterPressed",EditBox_ClearFocus);
f.min:SetScript("OnTabPressed",function(self)
	f.max:SetFocus();
end);
f.min:SetScript("OnTextChanged",function(self,user)
	if user then
		minlvl = self:GetNumber() or 0;
		mog:BuildList();
	end
end);

f.dash = f:CreateFontString(nil,"ARTWORK","GameFontHighlightSmall");
f.dash:SetPoint("LEFT",f.min,"RIGHT",0,1);
f.dash:SetText("-");

f.max = CreateFrame("EditBox","MogItFiltersLevelMax",f,"InputBoxTemplate");
f.max:SetSize(32,16);
f.max:SetPoint("LEFT",f.min,"RIGHT",12,0);
f.max:SetNumeric(true);
f.max:SetMaxLetters(3);
f.max:SetAutoFocus(false);
f.max:SetScript("OnEnterPressed",EditBox_ClearFocus);
f.max:SetScript("OnTabPressed",function(self)
	f.min:SetFocus();
end);
f.max:SetScript("OnTextChanged",function(self,user)
	if user then
		maxlvl = self:GetNumber() or GetMaxPlayerLevel();
		mog:BuildList();
	end
end);

function f.Filter(item)
	-- don't process filter if values encompass the entire player level range
	if minlvl <= 1 and (maxlvl >= GetMaxPlayerLevel() or maxlvl == 0) then
		return true
	end
	local sourceInfo = C_TransmogCollection.GetSourceInfo(item)
	if not sourceInfo or not C_Item.DoesItemExistByID(sourceInfo.itemID) then return end
	local item = mog:GetItemInfo(sourceInfo.itemID, "BuildList");
	return not item or ((item.reqLevel >= minlvl) and (item.reqLevel <= maxlvl));
end

function f.Default()
	minlvl = 0;
	f.min:SetNumber(minlvl);
	maxlvl = GetMaxPlayerLevel();
	f.max:SetNumber(maxlvl);
end
f.Default();


--[[
f.min:SetScript("OnEnterPressed",function(self)
	self:ClearFocus();
	minlvl = self:GetNumber() or 0;
	mog:BuildList();
end);
f.min:SetScript("OnEscapePressed",function(self)
	self:ClearFocus();
	self:SetNumber(minlvl);
end);
f.min:SetScript("OnTabPressed",function(self)
	f.max:SetFocus();
	minlvl = self:GetNumber() or 0;
	mog:BuildList();
end);

f.max:SetScript("OnEnterPressed",function(self)
	self:ClearFocus();
	maxlvl = self:GetNumber() or GetMaxPlayerLevel();
	mog:BuildList();
end);
f.max:SetScript("OnEscapePressed",function(self)
	self:ClearFocus();
	self:SetNumber(maxlvl);
end);
f.max:SetScript("OnTabPressed",function(self)
	f.min:SetFocus();
	maxlvl = self:GetNumber() or GetMaxPlayerLevel();
	mog:BuildList();
end);
--]]