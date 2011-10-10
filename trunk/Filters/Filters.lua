local MogIt,mog = ...;
local L = mog.L;

mog.filters = {};

function mog:AddFilter(name,frame)
	if mog.filters[name] then return end;
	
	if frame then
		frame:SetParent(mog.filt.frame);
	else
		frame = CreateFrame("Frame",nil,mog.filt.frame);
	end
	frame:Hide();
	frame.data = {};
	mog.filters[name] = frame;
	return frame;
end

mog.filt = CreateFrame("Frame","MogItFilters",mog.frame,"BasicFrameTemplateWithInset");
mog.filt:Hide();
mog.filt:SetPoint("TOPLEFT",mog.frame,"TOPRIGHT",5,-35);
mog.filt:SetSize(150,300);
MogItFiltersCloseButton:SetNormalTexture("Interface\\BUTTONS\\UI-Panel-HideButton-Up");
MogItFiltersCloseButton:SetPushedTexture("Interface\\BUTTONS\\UI-Panel-HideButton-Down");
MogItFiltersBg:SetVertexColor(0.8,0.3,0.8);
MogItFiltersTitleText:SetText(FILTERS);

mog.filt.scroll = CreateFrame("ScrollFrame","MogItFiltersScroll",mog.filt,"UIPanelScrollFrameTemplate");
mog.filt.scroll:SetPoint("TOPLEFT",mog.filt.InsetBorderTopLeft,"TOPLEFT",0,0);
mog.filt.scroll:SetPoint("BOTTOMRIGHT",mog.filt.InsetBorderBottomRight,"BOTTOMRIGHT",-21,0);

mog.filt.frame = CreateFrame("Frame","MogItFiltersScrollFrame",mog.filt);
mog.filt.scroll:SetScrollChild(mog.filt.frame);

function mog:FilterUpdate()
	if not mog.selected or not mog.selected.filters then return end;
	
	local height = 0;
	local width = 150;
	
	for k,v in pairs(mog.filters) do
		v:Hide();
	end
	
	local last;
	for k,v in ipairs(mog.selected.filters) do
		if mog.filters[v] then
			mog.filters[v]:ClearAllPoints();
			if last then
				mog.filters[v]:SetPoint("TOPLEFT",last,"BOTTOMLEFT",0,-5);
			else
				mog.filters[v]:SetPoint("TOPLEFT",mog.filt.frame,"TOPLEFT",5,-5);
			end
			last = mog.filters[v];
			mog.filters[v]:Show();
			width = max(width,mog.filters[v]:GetWidth() or 0);
			height = height + (mog.filters[v]:GetHeight() or 0) + 5;
			if not mog.filters[v].bg then
				mog.filters[v].bg = mog.filters[v]:CreateTexture(nil,"BACKGROUND");
				mog.filters[v].bg:SetPoint("TOPLEFT",mog.filters[v],"TOPLEFT");
				mog.filters[v].bg:SetPoint("BOTTOMLEFT",mog.filters[v],"BOTTOMLEFT");
				mog.filters[v].bg:SetPoint("RIGHT",mog.filt.frame,"RIGHT",-5,0);
				mog.filters[v].bg:SetTexture(0.3,0.3,0.3,0.2);
			end
		end
	end
	
	mog.filt.frame:SetWidth(width+10);
	mog.filt.frame:SetHeight(height+10);
end