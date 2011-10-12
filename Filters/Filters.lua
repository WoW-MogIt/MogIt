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

function mog:GetFilter(name)
	return mog.filters[name];
end

mog.filt = CreateFrame("Frame","MogItFilters",mog.frame,"BasicFrameTemplateWithInset");
mog.filt:Hide();
mog.filt:SetPoint("TOPLEFT",mog.frame,"TOPRIGHT")--,5,-35);
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
mog.filt.frame:SetWidth(150);

function mog:FilterUpdate()
	if not mog.selected or not mog.selected.filters then return end;
	
	for k,v in pairs(mog.filters) do
		v:Hide();
	end
	
	local height = 0;
	local last;
	for k,v in ipairs(mog.selected.filters) do
		if mog.filters[v.name] then
			mog.filters[v.name]:ClearAllPoints();
			if last then
				mog.filters[v.name]:SetPoint("TOPLEFT",last,"BOTTOMLEFT",0,-5);
			else
				mog.filters[v.name]:SetPoint("TOPLEFT",mog.filt.frame,"TOPLEFT",10,-10);
			end
			mog.filters[v.name]:SetPoint("RIGHT",mog.filt.frame,"RIGHT",-10,0);
			last = mog.filters[v.name];
			mog.filters[v.name]:Show();
			mog.filters[v.name].module = mog.selected;
			height = height + (mog.filters[v.name]:GetHeight() or 0) + 5;
			if not mog.filters[v.name].bg then
				mog.filters[v.name].bg = mog.filters[v.name]:CreateTexture(nil,"BACKGROUND");
				mog.filters[v.name].bg:SetPoint("TOPLEFT",mog.filters[v.name],"TOPLEFT");
				mog.filters[v.name].bg:SetPoint("BOTTOMLEFT",mog.filters[v.name],"BOTTOMLEFT");
				mog.filters[v.name].bg:SetPoint("RIGHT",mog.filt.frame,"RIGHT",-5,0);
				mog.filters[v.name].bg:SetTexture(0.3,0.3,0.3,0.2);
			end
		end
	end
	mog.filt.frame:SetHeight(height+20-5);
end