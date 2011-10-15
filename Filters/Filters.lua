local MogIt,mog = ...;
local L = mog.L;

local filters = {};

function mog:AddFilter(name,frame)
	if filters[name] then return end;
	if frame then
		frame:SetParent(mog.filt.frame);
	else
		frame = CreateFrame("Frame",nil,mog.filt.frame);
	end
	frame:Hide();
	filters[name] = frame;
	return frame;
end

function mog:GetFilter(name)
	return filters[name];
end

mog.filt = CreateFrame("Frame","MogItFilters",mog.frame,"ButtonFrameTemplate");
mog.filt:Hide();
mog.filt:SetPoint("TOPLEFT",mog.frame,"TOPRIGHT")--,5,-35);
mog.filt:SetSize(200,300);
MogItFiltersCloseButton:SetNormalTexture("Interface\\BUTTONS\\UI-Panel-HideButton-Up");
MogItFiltersCloseButton:SetPushedTexture("Interface\\BUTTONS\\UI-Panel-HideButton-Down");
MogItFiltersBg:SetVertexColor(0.8,0.3,0.8);
MogItFiltersTitleText:SetText(FILTERS);
mog.filt.portraitFrame:Hide();
mog.filt.topLeftCorner:Show();
mog.filt.topBorderBar:SetPoint("TOPLEFT",mog.filt.topLeftCorner,"TOPRIGHT",0,0);
mog.filt.leftBorderBar:SetPoint("TOPLEFT",mog.filt.topLeftCorner,"TOPLEFT",0,0);

mog.filt.results = mog.filt:CreateFontString(nil,"ARTWORK","GameFontNormal");
mog.filt.results:SetPoint("TOPLEFT",mog.filt,"TOPLEFT",10,-35);
mog.filt.results:SetText(L["Results"]..":");

mog.filt.models = mog.filt:CreateFontString(nil,"ARTWORK","GameFontHighlight");
mog.filt.models:SetPoint("LEFT",mog.filt.results,"RIGHT",5,0);
mog.filt.models:SetText(1337);

mog.filt.defaults = CreateFrame("Button","MogItFrameFiltersDefaults",mog.filt,"MagicButtonTemplate");
mog.filt.defaults:SetPoint("BOTTOMLEFT",mog.filt,"BOTTOMLEFT",5,5);
mog.filt.defaults:SetWidth(100);
mog.filt.defaults:SetText(DEFAULTS);
mog.filt.defaults:SetScript("OnClick",function(self,btn)
	
end);

mog.filt.scroll = CreateFrame("ScrollFrame","MogItFiltersScroll",mog.filt,"UIPanelScrollFrameTemplate");
mog.filt.scroll:SetPoint("TOPLEFT",mog.filt.Inset,"TOPLEFT",0,0);
mog.filt.scroll:SetPoint("BOTTOMRIGHT",mog.filt.Inset,"BOTTOMRIGHT",-21,0);

mog.filt.frame = CreateFrame("Frame","MogItFiltersScrollFrame",mog.filt);
mog.filt.scroll:SetScrollChild(mog.filt.frame);
mog.filt.frame:SetWidth(mog.filt:GetWidth()-20);

function mog:FilterUpdate()	
	for k,v in pairs(filters) do
		v:Hide();
	end
	
	if not mog.active or not mog.active.filters then return end;
	
	local height = 0;
	for k,v in ipairs(mog.active.filters) do
		if filters[v] then
			filters[v]:ClearAllPoints();
			if k == 1 then
				filters[v]:SetPoint("TOPLEFT",mog.filt.frame,"TOPLEFT",14,-14);
			else
				filters[v]:SetPoint("TOPLEFT",filters[mog.active.filters[k-1]],"BOTTOMLEFT",0,-14);
			end
			filters[v]:SetPoint("RIGHT",mog.filt.frame,"RIGHT",-14,0);
			last = filters[v];
			if not filters[v].bg then
				filters[v].bg = filters[v]:CreateTexture(nil,"BACKGROUND");
				filters[v].bg:SetPoint("TOPLEFT",filters[v],"TOPLEFT",-5,5);
				filters[v].bg:SetPoint("BOTTOMRIGHT",filters[v],"BOTTOMRIGHT",5,-5);
				filters[v].bg:SetTexture(0.3,0.3,0.3,0.2);
			end
			filters[v]:Show();
			height = height + (filters[v]:GetHeight() or 0) + 5;
		end
	end
	mog.filt.frame:SetHeight(height+20-5);
end