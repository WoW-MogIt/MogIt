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
	for k,v in pairs(filters) do
		v:Hide();
	end
	
	if not mog.active or not mog.active.filters then return end;
	
	local height = 0;
	for k,v in ipairs(mog.active.filters) do
		if filters[v] then
			filters[v]:ClearAllPoints();
			if k == 1 then
				filters[v]:SetPoint("TOPLEFT",mog.filt.frame,"TOPLEFT",10,-10);
			else
				filters[v]:SetPoint("TOPLEFT",filters[mog.active.filters[k-1]],"BOTTOMLEFT",0,-5);
			end
			filters[v]:SetPoint("RIGHT",mog.filt.frame,"RIGHT",-10,0);
			last = filters[v];
			filters[v]:Show();
			--filters[v].module = mog.active;
			height = height + (filters[v]:GetHeight() or 0) + 5;
			--[[if not mog.filters[v].bg then
				mog.filters[v].bg = mog.filters[v]:CreateTexture(nil,"BACKGROUND");
				mog.filters[v].bg:SetPoint("TOPLEFT",mog.filters[v],"TOPLEFT");
				mog.filters[v].bg:SetPoint("BOTTOMLEFT",mog.filters[v],"BOTTOMLEFT");
				mog.filters[v].bg:SetPoint("RIGHT",mog.filt.frame,"RIGHT",-5,0);
				mog.filters[v].bg:SetTexture(0.3,0.3,0.3,0.2);
			end--]]
		end
	end
	mog.filt.frame:SetHeight(height+20-5);
end