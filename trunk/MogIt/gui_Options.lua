local MogIt,mog = ...;
local L = mog.L;

local GetScreenWidth = GetScreenWidth;
local GetScreenHeight = GetScreenHeight;

mog.opt = CreateFrame("Frame","MogItOptions",mog.container,"BasicFrameTemplate");
mog.opt:Hide();
mog.opt:SetPoint("CENTER",UIParent,"CENTER");
mog.opt:SetSize(252,230);
mog.opt:SetFrameLevel(10);
mog.opt:SetToplevel(true);
mog.opt:SetClampedToScreen(true);
mog.opt:EnableMouse(true);
mog.opt:SetMovable(true);
mog.opt:SetUserPlaced(true);
mog.opt:SetScript("OnMouseDown",mog.opt.StartMoving);
mog.opt:SetScript("OnMouseUp",mog.opt.StopMovingOrSizing);
MogItOptionsTitleText:SetText("Options");
mog.opt:SetScript("OnShow",function(self)
	mog.opt.update();
end);

mog.opt.scroll = CreateFrame("ScrollFrame","MogItOptionsScroll",mog.opt,"UIPanelScrollFrameTemplate");
mog.opt.scroll:SetPoint("TOPLEFT",mog.opt,"TOPLEFT",5,-23);
mog.opt.scroll:SetPoint("BOTTOMRIGHT",mog.opt,"BOTTOMRIGHT",-26,3);

mog.opt.frame = CreateFrame("Frame","MogItOptionsFrame",mog.opt);
mog.opt.frame:SetSize(222,420);
mog.opt.scroll:SetScrollChild(mog.opt.frame);

mog.opt.gen = mog.opt.frame:CreateFontString(nil,"ARTWORK","GameFontHighlightSmall");
mog.opt.gen:SetPoint("TOPLEFT",mog.opt.frame,"TOPLEFT",5,-10);
mog.opt.gen:SetText(GENERAL);

mog.opt.mm = CreateFrame("CheckButton","MogItOptionsMinimap",mog.opt.frame,"UICheckButtonTemplate");
MogItOptionsMinimapText:SetText(L["Hide Minimap Button"]);
MogItOptionsMinimapText:SetWidth(200);
MogItOptionsMinimapText:SetJustifyH("LEFT");
mog.opt.mm:SetPoint("TOPLEFT",mog.opt.gen,"BOTTOMLEFT",0,0);
mog.opt.mm:SetScript("OnClick",function(self)
	mog.global.minimap.hide = not mog.global.minimap.hide;
	if self:GetChecked() then
		mog.LDBI:Hide(MogIt);
	else
		mog.LDBI:Show(MogIt);
	end
end);

mog.opt.cat = mog.opt.frame:CreateFontString(nil,"ARTWORK","GameFontHighlightSmall");
mog.opt.cat:SetPoint("TOPLEFT",mog.opt.mm,"BOTTOMLEFT",0,-15);
mog.opt.cat:SetText(L["Catalogue"]);

mog.opt.cnaked = CreateFrame("CheckButton","MogItOptionsCNaked",mog.opt.frame,"UICheckButtonTemplate");
MogItOptionsCNakedText:SetText(L["Naked models"]);
MogItOptionsCNakedText:SetWidth(200);
MogItOptionsCNakedText:SetJustifyH("LEFT");
mog.opt.cnaked:SetPoint("TOPLEFT",mog.opt.cat,"BOTTOMLEFT",0,0);
mog.opt.cnaked:SetScript("OnClick",function(self)
	mog.global.gridDress = not self:GetChecked();
	if mog.grid:IsShown() then
		mog.scroll:update();
	end
end);

function mog.opt.btnUpdate(rows,columns)
	if rows then
		if mog.global.rows == 1 then
			mog.opt.delrows:Hide();
		else
			mog.opt.delrows:Show();
		end
		local m = ((mog.global.rows + 1)*(mog.global.gridHeight + 5))-5+20+20;
		if m > GetScreenHeight() then
			mog.opt.addrows:Hide();
		else
			mog.opt.addrows:Show();
		end
	end
	if columns then
		if mog.global.columns == 1 then
			mog.opt.delcolumns:Hide();
		else
			mog.opt.delcolumns:Show();
		end
		local m = ((mog.global.columns + 1)*(mog.global.gridWidth + 5))-5+20+43;
		if m > GetScreenWidth() then
			mog.opt.addcolumns:Hide();
		else
			mog.opt.addcolumns:Show();
		end
	end
end

mog.opt.addrows = CreateFrame("Button","MogItOptionsAddRows",mog.opt.frame,"UIPanelButtonTemplate2");
mog.opt.addrows:SetNormalTexture("Interface\\Buttons\\UI-PlusButton-Up");
mog.opt.addrows:SetPushedTexture("Interface\\Buttons\\UI-PlusButton-Down");
mog.opt.addrows:SetHighlightTexture("Interface\\Buttons\\UI-PlusButton-Hilight","ADD");
mog.opt.addrows:SetSize(16,16);
mog.opt.addrows:SetPoint("TOPLEFT",mog.opt.cnaked,"BOTTOMLEFT",5,-3);
mog.opt.addrows:SetScript("OnClick",function(self)
	mog.global.rows = mog.global.rows + 1;
	mog.opt.btnUpdate(true);
	mog.updateGrid();
	mog.scroll:update();
	mog.updateModels();
end);

mog.opt.delrows = CreateFrame("Button","MogItOptionsDelRows",mog.opt.frame,"UIPanelButtonTemplate2");
mog.opt.delrows:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-Up");
mog.opt.delrows:SetPushedTexture("Interface\\Buttons\\UI-MinusButton-Down");
mog.opt.delrows:SetHighlightTexture("Interface\\Buttons\\UI-PlusButton-Hilight","ADD");
mog.opt.delrows:SetSize(16,16);
mog.opt.delrows:SetPoint("TOPLEFT",mog.opt.addrows,"TOPRIGHT",0,0);
mog.opt.delrows:SetScript("OnClick",function(self)
	mog.global.rows = mog.global.rows - 1;
	mog.opt.btnUpdate(true);
	mog.updateGrid();
	mog.scroll:update();
end);

mog.opt.rows = mog.opt.frame:CreateFontString(nil,"ARTWORK","GameFontNormalSmall");
mog.opt.rows:SetPoint("TOPLEFT",mog.opt.delrows,"TOPRIGHT",3,-4);
mog.opt.rows:SetText(L["Rows"]);

mog.opt.addcolumns = CreateFrame("Button","MogItOptionsAddColumns",mog.opt.frame,"UIPanelButtonTemplate2");
mog.opt.addcolumns:SetNormalTexture("Interface\\Buttons\\UI-PlusButton-Up");
mog.opt.addcolumns:SetPushedTexture("Interface\\Buttons\\UI-PlusButton-Down");
mog.opt.addcolumns:SetHighlightTexture("Interface\\Buttons\\UI-PlusButton-Hilight","ADD");
mog.opt.addcolumns:SetSize(16,16);
mog.opt.addcolumns:SetPoint("TOPLEFT",mog.opt.addrows,"BOTTOMLEFT",0,-3);
mog.opt.addcolumns:SetScript("OnClick",function(self)
	mog.global.columns = mog.global.columns + 1;
	mog.opt.btnUpdate(nil,true);
	mog.updateGrid();
	mog.scroll:update();
	mog.updateModels();
end);

mog.opt.delcolumns = CreateFrame("Button","MogItOptionsDelColumns",mog.opt.frame,"UIPanelButtonTemplate2");
mog.opt.delcolumns:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-Up");
mog.opt.delcolumns:SetPushedTexture("Interface\\Buttons\\UI-MinusButton-Down");
mog.opt.delcolumns:SetHighlightTexture("Interface\\Buttons\\UI-PlusButton-Hilight","ADD");
mog.opt.delcolumns:SetSize(16,16);
mog.opt.delcolumns:SetPoint("TOPLEFT",mog.opt.addcolumns,"TOPRIGHT",0,0);
mog.opt.delcolumns:SetScript("OnClick",function(self)
	mog.global.columns = mog.global.columns - 1;
	mog.opt.btnUpdate(nil,true);
	mog.updateGrid();
	mog.scroll:update();
end);

mog.opt.columns = mog.opt.frame:CreateFontString(nil,"ARTWORK","GameFontNormalSmall");
mog.opt.columns:SetPoint("TOPLEFT",mog.opt.delcolumns,"TOPRIGHT",3,-4);
mog.opt.columns:SetText(L["Columns"]);

mog.opt.itemurl = mog.opt.frame:CreateFontString(nil,"ARTWORK","GameFontNormalSmall");
mog.opt.itemurl:SetPoint("TOPLEFT",mog.opt.addcolumns,"BOTTOMLEFT",0,-12);
mog.opt.itemurl:SetText(L["Item URL"]..":");
mog.opt.itemurl:SetJustifyH("LEFT");

mog.opt.url = CreateFrame("Frame","MogItOptionsURLDropdown",mog.opt.frame,"UIDropDownMenuTemplate");
mog.opt.url:SetPoint("TOPLEFT",mog.opt.itemurl,"BOTTOMLEFT",-16,-2);
UIDropDownMenu_SetWidth(mog.opt.url,105);
UIDropDownMenu_SetButtonWidth(mog.opt.url,120);
UIDropDownMenu_JustifyText(mog.opt.url,"LEFT");
function mog.opt.url:initialize()
	local info;
	for k,v in ipairs(mog.urlList) do
		info = UIDropDownMenu_CreateInfo();
		info.text =	v; --"\124TInterface\\AddOns\\MogIt\\Images\\"..mog.urlFav[v]..".tga:18:18\124t "..v;
		info.value = v;
		info.func = function(self)
			mog.global.url = self.value;
			UIDropDownMenu_SetText(mog.opt.url,self.value);
		end
		info.notCheckable = true;
		info.icon = "Interface\\AddOns\\MogIt\\Images\\"..mog.urlFav[v];
		UIDropDownMenu_AddButton(info);
	end
end

mog.opt.tt = mog.opt.frame:CreateFontString(nil,"ARTWORK","GameFontHighlightSmall");
mog.opt.tt:SetPoint("TOPLEFT",mog.opt.cat,"BOTTOMLEFT",0,-140);
mog.opt.tt:SetText(L["Tooltip"]);

mog.opt.tooltip = CreateFrame("CheckButton","MogItOptionsTooltip",mog.opt.frame,"UICheckButtonTemplate");
MogItOptionsTooltipText:SetText(L["Enable tooltip model"]);
MogItOptionsTooltipText:SetWidth(200);
MogItOptionsTooltipText:SetJustifyH("LEFT");
mog.opt.tooltip:SetPoint("TOPLEFT",mog.opt.tt,"BOTTOMLEFT",0,0);
mog.opt.tooltip:SetScript("OnClick",function(self)
	mog.global.tooltip = self:GetChecked();
end);

mog.opt.tnaked = CreateFrame("CheckButton","MogItOptionsTNaked",mog.opt.frame,"UICheckButtonTemplate");
MogItOptionsTNakedText:SetText(L["Naked model"]);
MogItOptionsTNakedText:SetWidth(200);
MogItOptionsTNakedText:SetJustifyH("LEFT");
mog.opt.tnaked:SetPoint("TOPLEFT",mog.opt.tooltip,"BOTTOMLEFT",0,0);
mog.opt.tnaked:SetScript("OnClick",function(self)
	mog.global.tooltipDress = not self:GetChecked();
end);

mog.opt.mouse = CreateFrame("CheckButton","MogItOptionsMouse",mog.opt.frame,"UICheckButtonTemplate");
MogItOptionsMouseText:SetText(L["Rotate with mouse wheel"]);
MogItOptionsMouseText:SetWidth(200);
MogItOptionsMouseText:SetJustifyH("LEFT");
mog.opt.mouse:SetPoint("TOPLEFT",mog.opt.tnaked,"BOTTOMLEFT",0,0);
mog.opt.mouse:SetScript("OnClick",function(self)
	mog.global.tooltipMouse = self:GetChecked();
end);

mog.opt.auto = CreateFrame("CheckButton","MogItOptionsAuto",mog.opt.frame,"UICheckButtonTemplate");
MogItOptionsAutoText:SetText(L["Auto rotate"]);
MogItOptionsAutoText:SetWidth(200);
MogItOptionsAutoText:SetJustifyH("LEFT");
mog.opt.auto:SetPoint("TOPLEFT",mog.opt.mouse,"BOTTOMLEFT",0,0);
mog.opt.auto:SetScript("OnClick",function(self)
	mog.global.tooltipRotate = self:GetChecked();
	if mog.global.tooltipRotate then
		mog.tooltip.rotate:Show();
	else
		mog.tooltip.rotate:Hide();
	end
end);

mog.opt.mog = CreateFrame("CheckButton","MogItOptionsMog",mog.opt.frame,"UICheckButtonTemplate");
MogItOptionsMogText:SetText(L["Only uncommon/rare/epic"]);
MogItOptionsMogText:SetWidth(200);
MogItOptionsMogText:SetJustifyH("LEFT");
mog.opt.mog:SetPoint("TOPLEFT",mog.opt.auto,"BOTTOMLEFT",0,0);
mog.opt.mog:SetScript("OnClick",function(self)
	mog.global.tooltipMog = self:GetChecked();
end);

mog.opt.defaults = CreateFrame("Button","MogItOptionsDefaults",mog.opt.frame,"UIPanelButtonTemplate2");
mog.opt.defaults:SetText(DEFAULTS);
mog.opt.defaults:SetSize(100,22);
mog.opt.defaults:SetPoint("BOTTOMRIGHT",mog.opt.frame,"BOTTOMRIGHT",-5,10);
mog.opt.defaults:SetScript("OnClick",function(self,btn)
	mog.global.minimap.hide = false;
	mog.LDBI:Show(MogIt);
	mog.global.gridDress = true;
	mog.global.tooltip = true;
	mog.global.tooltipDress = false;
	mog.global.tooltipMouse = false;
	mog.global.tooltipRotate = true;
	mog.global.tooltipMog = true;
	mog.global.url = "Battle.net";
	
	mog.global.gridWidth = 200;
	mog.global.gridHeight = 200;
	mog.global.rows = 2;
	mog.global.columns = 3;
	
	mog.opt.update();
	mog.updateGrid();
	mog.scroll:update();
end);

function mog.opt.update()
	mog.opt.mm:SetChecked(mog.global.minimap.hide);
	mog.opt.cnaked:SetChecked(not mog.global.gridDress);
	mog.opt.tooltip:SetChecked(mog.global.tooltip);
	mog.opt.tnaked:SetChecked(not mog.global.tooltipDress);
	mog.opt.mouse:SetChecked(mog.global.tooltipMouse);
	mog.opt.auto:SetChecked(mog.global.tooltipRotate);
	mog.opt.mog:SetChecked(mog.global.tooltipMog);
	UIDropDownMenu_SetText(mog.opt.url,mog.global.url);
	mog.opt.btnUpdate(true,true);
end