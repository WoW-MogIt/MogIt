local MogIt,mog = ...;
local L = mog.L;

mog.filters = {};

function mog:CreateFilter(name,frame)
	if not name or mog.filters[name] then return end;
	if frame then
		frame:SetParent(mog.filt.frame);
	else
		frame = CreateFrame("Frame",nil,mog.filt.frame);
	end
	frame:Hide();
	mog.filters[name] = frame;
	return frame;
end

function mog:GetFilter(name)
	return mog.filters[name];
end

mog.filt = CreateFrame("Frame","MogItFilters",mog.frame,"ButtonFrameTemplate");
mog.filt:Hide();
mog.filt:SetPoint("TOPLEFT",mog.frame,"TOPRIGHT");
mog.filt:SetSize(200,300);
mog.filt:SetClampedToScreen(true);
mog.filt:EnableMouse(true);
--MogItFiltersCloseButton:SetNormalTexture("Interface\\BUTTONS\\UI-Panel-HideButton-Up");
--MogItFiltersCloseButton:SetPushedTexture("Interface\\BUTTONS\\UI-Panel-HideButton-Down");
MogItFiltersBg:SetVertexColor(0.8,0.3,0.8);
MogItFiltersTitleText:SetText(FILTERS);
mog.filt.portraitFrame:Hide();
mog.filt.topLeftCorner:Show();
mog.filt.topBorderBar:SetPoint("TOPLEFT",mog.filt.topLeftCorner,"TOPRIGHT",0,0);
mog.filt.leftBorderBar:SetPoint("TOPLEFT",mog.filt.topLeftCorner,"BOTTOMLEFT",0,0);

mog.filt.results = mog.filt:CreateFontString(nil,"ARTWORK","GameFontNormal");
mog.filt.results:SetPoint("TOPLEFT",mog.filt,"TOPLEFT",10,-35);
mog.filt.results:SetText(L["Results"]..":");

mog.filt.models = mog.filt:CreateFontString(nil,"ARTWORK","GameFontHighlight");
mog.filt.models:SetPoint("LEFT",mog.filt.results,"RIGHT",5,0);

mog.filt.defaults = CreateFrame("Button","MogItFrameFiltersDefaults",mog.filt,"MagicButtonTemplate");
mog.filt.defaults:SetPoint("BOTTOMLEFT",mog.filt,"BOTTOMLEFT",5,5);
mog.filt.defaults:SetWidth(100);
mog.filt.defaults:SetText(DEFAULTS);
mog.filt.defaults:SetScript("OnClick",function(self,btn)
	if mog.active and mog.active.filters then
		for k,v in ipairs(mog.active.filters) do
			if mog.filters[v] and mog.filters[v].Default then
				mog.filters[v].Default();
			end
		end
		mog:BuildList();
	end
end);

mog.filt.scroll = CreateFrame("ScrollFrame","MogItFiltersScroll",mog.filt,"UIPanelScrollFrameTemplate");
mog.filt.scroll:SetPoint("TOPLEFT",mog.filt.Inset,"TOPLEFT",0,-3);
mog.filt.scroll:SetPoint("BOTTOMRIGHT",mog.filt.Inset,"BOTTOMRIGHT",-23,2);
mog.filt.scroll:Hide();

mog.filt.scroll.ScrollBar.top = mog.filt.scroll.ScrollBar:CreateTexture(nil,"ARTWORK");
mog.filt.scroll.ScrollBar.top:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-ScrollBar");
mog.filt.scroll.ScrollBar.top:SetSize(24,48);
mog.filt.scroll.ScrollBar.top:SetPoint("TOPLEFT",mog.filt.scroll.ScrollBar,"TOPLEFT",-6,19);
mog.filt.scroll.ScrollBar.top:SetTexCoord(0,0.45,0,0.2);

mog.filt.scroll.ScrollBar.bottom = mog.filt.scroll.ScrollBar:CreateTexture(nil,"ARTWORK");
mog.filt.scroll.ScrollBar.bottom:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-ScrollBar");
mog.filt.scroll.ScrollBar.bottom:SetSize(24,64);
mog.filt.scroll.ScrollBar.bottom:SetPoint("BOTTOMLEFT",mog.filt.scroll.ScrollBar,"BOTTOMLEFT",-6,-17);
mog.filt.scroll.ScrollBar.bottom:SetTexCoord(0.515625,0.97,0.1440625,0.4140625);

mog.filt.scroll.ScrollBar.middle = mog.filt.scroll.ScrollBar:CreateTexture(nil,"ARTWORK");
mog.filt.scroll.ScrollBar.middle:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-ScrollBar");
mog.filt.scroll.ScrollBar.middle:SetPoint("TOPLEFT",mog.filt.scroll.ScrollBar.top,"BOTTOMLEFT");
mog.filt.scroll.ScrollBar.middle:SetPoint("BOTTOMRIGHT",mog.filt.scroll.ScrollBar.bottom,"TOPRIGHT");
mog.filt.scroll.ScrollBar.middle:SetTexCoord(0,0.45,0.1640625,1);

mog.filt.frame = CreateFrame("Frame","MogItFiltersScrollFrame",mog.filt);
mog.filt.scroll:SetScrollChild(mog.filt.frame);
mog.filt.frame:SetWidth(180);

mog.filt.error = mog.filt:CreateFontString(nil,"ARTWORK","GameFontRed");
mog.filt.error:SetPoint("TOPLEFT",mog.filt.Inset,"TOPLEFT",7,-5);
mog.filt.error:SetPoint("BOTTOMRIGHT",mog.filt.Inset,"BOTTOMRIGHT",-7,5);
--mog.filt.error:SetJustifyV("TOP");
mog.filt.error:SetText(L["No module is selected"]);

function mog:FilterUpdate()
	if not mog.active then
		mog.filt.scroll:Hide();
		mog.filt.error:SetText(L["No module is selected"]);
		mog.filt.error:Show();
		return;
	elseif not mog.active.filters then
		mog.filt.scroll:Hide();
		mog.filt.error:SetText(L["This module has no filters"]);
		mog.filt.error:Show();
		return;
	end
	
	mog.filt.scroll:Show();
	mog.filt.error:Hide();
	for k,v in pairs(mog.filters) do
		v:Hide();
	end
	
	local height = 20;
	local last;
	for k,v in ipairs(mog.active.filters) do
		if mog.filters[v] then
			mog.filters[v]:ClearAllPoints();
			if last then
				mog.filters[v]:SetPoint("TOPLEFT",last,"BOTTOMLEFT",0,-14);
			else
				mog.filters[v]:SetPoint("TOPLEFT",mog.filt.frame,"TOPLEFT",12,-10);
			end
			mog.filters[v]:SetPoint("RIGHT",mog.filt.frame,"RIGHT",-19,0);
			if not mog.filters[v].bg then
				mog.filters[v].bg = mog.filters[v]:CreateTexture(nil,"BACKGROUND");
				mog.filters[v].bg:SetPoint("TOPLEFT",mog.filters[v],"TOPLEFT",-5,5);
				mog.filters[v].bg:SetPoint("BOTTOMRIGHT",mog.filters[v],"BOTTOMRIGHT",5,-5);
				mog.filters[v].bg:SetTexture(0.3,0.3,0.3,0.2);
			end
			height = height + mog.filters[v]:GetHeight() + (last and 14 or 0);
			last = mog.filters[v];
			mog.filters[v]:Show();
		end
	end
	mog.filt.frame:SetHeight(height);
end

function mog:CheckFilters(module,value)
	if module.filters and module.GetFilterArgs then
		for _,filter in ipairs(module.filters) do
			if not mog:GetFilter(filter).Filter(module.GetFilterArgs(filter,value)) then
				return;
			end
		end
	end
	return true;
end


--[[
VENDOR?
Valor Points
Justice Points
Conquest Points
Honor Points
Tier Tokens
--> Tier 1
--> Tier 2
--> etc
Gold
Other

ZONES
-- current zone

NAME

QUEST/ACHI
- complete?
--]]