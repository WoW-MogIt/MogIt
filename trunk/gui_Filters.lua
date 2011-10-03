local MogIt,mog = ...;
local L = mog.L;

local pairs = pairs;

mog.filt = CreateFrame("Frame","MogItFilters",mog.container,"BasicFrameTemplate");
mog.filt:Hide();
mog.filt:SetPoint("CENTER",UIParent,"CENTER");
mog.filt:SetSize(252,230);
mog.filt:SetToplevel(true);
mog.filt:SetClampedToScreen(true);
mog.filt:EnableMouse(true);
mog.filt:SetMovable(true);
mog.filt:SetUserPlaced(true);
mog.filt:SetScript("OnMouseDown",mog.filt.StartMoving);
mog.filt:SetScript("OnMouseUp",mog.filt.StopMovingOrSizing);
MogItFiltersTitleText:SetText(FILTERS);
mog.filt:SetScript("OnShow",function(self)
	mog.filt.update();
end);

mog.filt._minlvl = 0;
mog.filt._maxlvl = UnitLevel("PLAYER");
mog.filt._alliance = UnitFactionGroup("PLAYER") == "Alliance";
mog.filt._horde = UnitFactionGroup("PLAYER") == "Horde";
mog.filt._class = mog.classBits[select(2,UnitClass("PLAYER"))];
mog.filt._sources = {};
mog.filt._slots = {};
mog.filt._quality = {};

mog.filt.sourceSub = {
	[1] = {}, -- Drop
};
for k,v in ipairs(mog.difficulties) do
	mog.filt.sourceSub[1][k] = true;
end

mog.filt.scroll = CreateFrame("ScrollFrame","MogItFiltersScroll",mog.filt,"UIPanelScrollFrameTemplate");
mog.filt.scroll:SetPoint("TOPLEFT",mog.filt,"TOPLEFT",5,-23);
mog.filt.scroll:SetPoint("BOTTOMRIGHT",mog.filt,"BOTTOMRIGHT",-26,3);

mog.filt.frame = CreateFrame("Frame","MogItFiltersFrame",mog.filt);
mog.filt.frame:SetSize(222,370);
mog.filt.scroll:SetScrollChild(mog.filt.frame);

mog.filt.lvl = mog.filt.frame:CreateFontString(nil,"ARTWORK","GameFontHighlightSmall");
mog.filt.lvl:SetPoint("TOPLEFT",mog.filt.frame,"TOPLEFT",5,-10);
mog.filt.lvl:SetPoint("RIGHT",mog.filt.frame,"RIGHT",-5,0);
mog.filt.lvl:SetText(LEVEL_RANGE..":");
mog.filt.lvl:SetJustifyH("LEFT");

mog.filt.minlvl = CreateFrame("EditBox","MogItFiltersMinLvl",mog.filt.frame,"InputBoxTemplate");
mog.filt.minlvl:SetSize(25,16);
mog.filt.minlvl:SetPoint("TOPLEFT",mog.filt.lvl,"BOTTOMLEFT",8,-5);
mog.filt.minlvl:SetNumeric(true);
mog.filt.minlvl:SetMaxLetters(2);
mog.filt.minlvl:SetAutoFocus(false);
mog.filt.minlvl:SetScript("OnEnterPressed",EditBox_ClearFocus);
mog.filt.minlvl:SetScript("OnTabPressed",function(self)
	mog.filt.maxlvl:SetFocus();
end);
mog.filt.minlvl:SetScript("OnTextChanged",function(self)
	mog.filt._minlvl = tonumber(self:GetText()) or 0;
	mog.buildList();
end);

mog.filt.lvlh = mog.filt.frame:CreateFontString(nil,"ARTWORK","GameFontHighlightSmall");
mog.filt.lvlh:SetPoint("LEFT",mog.filt.minlvl,"RIGHT",0,1);
mog.filt.lvlh:SetText("-");

mog.filt.maxlvl = CreateFrame("EditBox","MogItFiltersMaxLvl",mog.filt.frame,"InputBoxTemplate");
mog.filt.maxlvl:SetSize(25,16);
mog.filt.maxlvl:SetPoint("LEFT",mog.filt.minlvl,"RIGHT",12,0);
mog.filt.maxlvl:SetNumeric(true);
mog.filt.maxlvl:SetMaxLetters(2);
mog.filt.maxlvl:SetAutoFocus(false);
mog.filt.maxlvl:SetScript("OnEnterPressed",EditBox_ClearFocus);
mog.filt.maxlvl:SetScript("OnTabPressed",function(self)
	mog.filt.minlvl:SetFocus();
end);
mog.filt.maxlvl:SetScript("OnTextChanged",function(self)
	mog.filt._maxlvl = tonumber(self:GetText()) or MAX_PLAYER_LEVEL;
	mog.buildList();
end);

mog.filt.faction = mog.filt.frame:CreateFontString(nil,"ARTWORK","GameFontHighlightSmall");
mog.filt.faction:SetPoint("TOPLEFT",mog.filt.lvl,"BOTTOMLEFT",0,-35);
mog.filt.faction:SetPoint("RIGHT",mog.filt.frame,"RIGHT",-5,0);
mog.filt.faction:SetText(L["Faction Items"]..":");
mog.filt.faction:SetJustifyH("LEFT");

mog.filt.factionAlliance = CreateFrame("CheckButton","MogItFiltersFactionAlliance",mog.filt.frame,"UICheckButtonTemplate");
MogItFiltersFactionAllianceText:SetText(FACTION_ALLIANCE);
mog.filt.factionAlliance:SetPoint("TOPLEFT",mog.filt.faction,"BOTTOMLEFT",0,0);
mog.filt.factionAlliance:SetScript("OnClick",function(self)
	mog.filt._alliance = self:GetChecked();
	mog.buildList();
end);

mog.filt.factionHorde = CreateFrame("CheckButton","MogItFiltersFactionHorde",mog.filt.frame,"UICheckButtonTemplate");
MogItFiltersFactionHordeText:SetText(FACTION_HORDE);
mog.filt.factionHorde:SetPoint("TOP",mog.filt.factionAlliance,"BOTTOM",0,7);
mog.filt.factionHorde:SetScript("OnClick",function(self)
	mog.filt._horde = self:GetChecked();
	mog.buildList();
end);

mog.filt.class = mog.filt.frame:CreateFontString(nil,"ARTWORK","GameFontHighlightSmall");
mog.filt.class:SetPoint("TOPLEFT",mog.filt.faction,"BOTTOMLEFT",0,-64);
mog.filt.class:SetPoint("RIGHT",mog.filt.frame,"RIGHT",0,-5);
mog.filt.class:SetText(L["Class Items"]..":");
mog.filt.class:SetJustifyH("LEFT");

local classCoords = CLASS_ICON_TCOORDS;
local classColours = RAID_CLASS_COLORS;
local classSelected = {[select(2,UnitClass("PLAYER"))] = true};
local classNum = 1;
local classAll = true;

mog.filt.classes = CreateFrame("Frame","MogItFiltersClassDropdown",mog.filt.frame,"UIDropDownMenuTemplate");
mog.filt.classes:SetPoint("TOPLEFT",mog.filt.class,"BOTTOMLEFT",-16,-2);
UIDropDownMenu_SetWidth(mog.filt.classes,125);
UIDropDownMenu_SetButtonWidth(mog.filt.classes,140);
UIDropDownMenu_JustifyText(mog.filt.classes,"LEFT");
UIDropDownMenu_SetText(mog.filt.classes,L["%d selected"]:format(1));
function mog.filt.classes:initialize()
	local info;
	info = UIDropDownMenu_CreateInfo();
	info.text =	classAll and L["Select All"] or L["Select None"];
	info.value = "SA";
	info.func = function(self)
		classNum = 0;
		mog.filt._class = 0;
		for k,v in pairs(mog.classes) do
			classSelected[k] = classAll and true;
			classNum = classNum + (classAll and 1 or 0);
			mog.filt._class = mog.filt._class + (classAll and mog.classBits[k] or 0);
		end
		classAll = not classAll;
		UIDropDownMenu_SetText(mog.filt.classes,L["%d selected"]:format(classNum));
		ToggleDropDownMenu(1,nil,mog.filt.classes);
		mog.buildList();
	end
	info.notCheckable = true;
	UIDropDownMenu_AddButton(info);
	for k,v in pairs(mog.classes) do
		info = UIDropDownMenu_CreateInfo();
		info.text =	v;
		info.value = k;
		info.colorCode = string.format("\124cff%.2x%.2x%.2x",classColours[k].r*255,classColours[k].g*255,classColours[k].b*255);
		info.func = function(self)
			if classSelected[self.value] and (not self.checked) then
				mog.filt._class = mog.filt._class - mog.classBits[self.value];
				classNum = classNum - 1;
			elseif (not classSelected[self.value]) and self.checked then
				mog.filt._class = mog.filt._class + mog.classBits[self.value];
				classNum = classNum + 1;
			end
			classSelected[self.value] = self.checked;
			UIDropDownMenu_SetText(mog.filt.classes,L["%d selected"]:format(classNum));
			mog.buildList();
		end
		info.keepShownOnClick = true;
		info.isNotRadio = true;
		info.checked = classSelected[k];
		info.icon = "Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes";
		info.tCoordLeft = classCoords[k][1];
		info.tCoordRight = classCoords[k][2];
		info.tCoordTop = classCoords[k][3];
		info.tCoordBottom = classCoords[k][4];
		UIDropDownMenu_AddButton(info);
	end
end

mog.filt.source = mog.filt.frame:CreateFontString(nil,"ARTWORK","GameFontHighlightSmall");
mog.filt.source:SetPoint("TOPLEFT",mog.filt.class,"BOTTOMLEFT",0,-40);
mog.filt.source:SetPoint("RIGHT",mog.filt.frame,"RIGHT",0,-5);
mog.filt.source:SetText(L["Source:"]);
mog.filt.source:SetJustifyH("LEFT");

local sourceNum = 0;
local sourceAll;
for k,v in ipairs(mog.source) do
	mog.filt._sources[k] = true;
	sourceNum = sourceNum + 1;
end

mog.filt.sources = CreateFrame("Frame","MogItFiltersSourcesDropdown",mog.filt.frame,"UIDropDownMenuTemplate");
mog.filt.sources:SetPoint("TOPLEFT",mog.filt.source,"BOTTOMLEFT",-16,-2);
UIDropDownMenu_SetWidth(mog.filt.sources,125);
UIDropDownMenu_SetButtonWidth(mog.filt.sources,140);
UIDropDownMenu_JustifyText(mog.filt.sources,"LEFT");
UIDropDownMenu_SetText(mog.filt.sources,L["%d selected"]:format(sourceNum));
function mog.filt.sources:initialize(tier)
	if tier == 1 then
		local info;
		info = UIDropDownMenu_CreateInfo();
		info.text =	sourceAll and L["Select All"] or L["Select None"];
		info.value = "SA";
		info.func = function(self)
			sourceNum = 0;
			for k,v in ipairs(mog.source) do
				mog.filt._sources[k] = sourceAll and true;
				sourceNum = sourceNum + (sourceAll and 1 or 0);
			end
			sourceAll = not sourceAll;
			UIDropDownMenu_SetText(mog.filt.sources,L["%d selected"]:format(sourceNum));
			ToggleDropDownMenu(1,nil,mog.filt.sources);
			mog.buildList();
		end
		info.notCheckable = true;
		UIDropDownMenu_AddButton(info);
		for k,v in ipairs(mog.source) do
			info = UIDropDownMenu_CreateInfo();
			info.text =	v;
			info.value = k;
			info.func = function(self)
				if mog.filt._sources[self.value] and (not self.checked) then
					sourceNum = sourceNum - 1;
				elseif (not mog.filt._sources[self.value]) and self.checked then
					sourceNum = sourceNum + 1;
				end
				mog.filt._sources[self.value] = self.checked;
				UIDropDownMenu_SetText(mog.filt.sources,L["%d selected"]:format(sourceNum));
				mog.buildList();
			end
			info.keepShownOnClick = true;
			info.isNotRadio = true;
			info.checked = mog.filt._sources[k];
			info.hasArrow = mog.filt.sourceSub[k] and true;
			UIDropDownMenu_AddButton(info);
		end
	elseif tier == 2 then
		local parent = UIDROPDOWNMENU_MENU_VALUE;
		for k,v in ipairs(mog.filt.sourceSub[parent]) do
			info = UIDropDownMenu_CreateInfo();
			if parent == 1 then
				info.text =	mog.difficulties[k];
			end
			info.value = k;
			info.func = function(self)
				mog.filt.sourceSub[parent][self.value] = self.checked;
				if mog.filt._sources[parent] then
					mog.buildList();
				end
			end
			info.keepShownOnClick = true;
			info.isNotRadio = true;
			info.checked = v;
			UIDropDownMenu_AddButton(info,tier);
		end
	end
end

mog.filt.slot = mog.filt.frame:CreateFontString(nil,"ARTWORK","GameFontHighlightSmall");
mog.filt.slot:SetPoint("TOPLEFT",mog.filt.source,"BOTTOMLEFT",0,-40);
mog.filt.slot:SetPoint("RIGHT",mog.filt.frame,"RIGHT",0,-5);
mog.filt.slot:SetText(L["One-Hand Slot"]..":");
mog.filt.slot:SetJustifyH("LEFT");

local slotNum = 0;
local slotAll;
for k,v in ipairs(mog.slots) do
	mog.filt._slots[k] = true;
	slotNum = slotNum + 1;
end

mog.filt.slots = CreateFrame("Frame","MogItFiltersSlotsDropdown",mog.filt.frame,"UIDropDownMenuTemplate");
mog.filt.slots:SetPoint("TOPLEFT",mog.filt.slot,"BOTTOMLEFT",-16,-2);
UIDropDownMenu_SetWidth(mog.filt.slots,125);
UIDropDownMenu_SetButtonWidth(mog.filt.slots,140);
UIDropDownMenu_JustifyText(mog.filt.slots,"LEFT");
UIDropDownMenu_SetText(mog.filt.slots,L["%d selected"]:format(slotNum));
function mog.filt.slots:initialize()
	local info;
	info = UIDropDownMenu_CreateInfo();
	info.text =	slotAll and L["Select All"] or L["Select None"];
	info.value = "SA";
	info.func = function(self)
		slotNum = 0;
		for k,v in ipairs(mog.slots) do
			mog.filt._slots[k] = slotAll and true;
			slotNum = slotNum + (slotAll and 1 or 0);
		end
		slotAll = not slotAll;
		UIDropDownMenu_SetText(mog.filt.slots,L["%d selected"]:format(slotNum));
		ToggleDropDownMenu(1,nil,mog.filt.slots);
		mog.buildList();
	end
	info.notCheckable = true;
	UIDropDownMenu_AddButton(info);
	for k,v in ipairs(mog.slots) do
		info = UIDropDownMenu_CreateInfo();
		info.text =	v;
		info.value = k;
		info.func = function(self)
			if mog.filt._slots[self.value] and (not self.checked) then
				slotNum = slotNum - 1;
			elseif (not mog.filt._slots[self.value]) and self.checked then
				slotNum = slotNum + 1;
			end
			mog.filt._slots[self.value] = self.checked;
			UIDropDownMenu_SetText(mog.filt.slots,L["%d selected"]:format(slotNum));
			mog.buildList();
		end
		info.keepShownOnClick = true;
		info.isNotRadio = true;
		info.checked = mog.filt._slots[k];
		UIDropDownMenu_AddButton(info);
	end
end

mog.filt.qual = mog.filt.frame:CreateFontString(nil,"ARTWORK","GameFontHighlightSmall");
mog.filt.qual:SetPoint("TOPLEFT",mog.filt.slot,"BOTTOMLEFT",0,-40);
mog.filt.qual:SetPoint("RIGHT",mog.filt.frame,"RIGHT",0,-5);
mog.filt.qual:SetText(QUALITY..":");
mog.filt.qual:SetJustifyH("LEFT");

local qualityNum = 0;
local qualityAll;
for k,v in ipairs(mog.quality) do
	mog.filt._quality[v] = true;
	qualityNum = qualityNum + 1;
end
local qualityColors = ITEM_QUALITY_COLORS;

mog.filt.quality = CreateFrame("Frame","MogItFiltersQualityDropdown",mog.filt.frame,"UIDropDownMenuTemplate");
mog.filt.quality:SetPoint("TOPLEFT",mog.filt.qual,"BOTTOMLEFT",-16,-2);
UIDropDownMenu_SetWidth(mog.filt.quality,125);
UIDropDownMenu_SetButtonWidth(mog.filt.quality,140);
UIDropDownMenu_JustifyText(mog.filt.quality,"LEFT");
UIDropDownMenu_SetText(mog.filt.quality,L["%d selected"]:format(qualityNum));
function mog.filt.quality:initialize()
	local info;
	info = UIDropDownMenu_CreateInfo();
	info.text =	qualityAll and L["Select All"] or L["Select None"];
	info.value = "SA";
	info.func = function(self)
		qualityNum = 0;
		for k,v in ipairs(mog.quality) do
			mog.filt._quality[v] = qualityAll and true;
			qualityNum = qualityNum + (qualityAll and 1 or 0);
		end
		qualityAll = not qualityAll;
		UIDropDownMenu_SetText(mog.filt.quality,L["%d selected"]:format(qualityNum));
		ToggleDropDownMenu(1,nil,mog.filt.quality);
		mog.buildList();
	end
	info.notCheckable = true;
	UIDropDownMenu_AddButton(info);
	for k,v in ipairs(mog.quality) do
		info = UIDropDownMenu_CreateInfo();
		info.text =	_G["ITEM_QUALITY"..v.."_DESC"];
		info.value = v;
		info.colorCode = qualityColors[v].hex;
		info.func = function(self)
			if mog.filt._quality[self.value] and (not self.checked) then
				qualityNum = qualityNum - 1;
			elseif (not mog.filt._quality[self.value]) and self.checked then
				qualityNum = qualityNum + 1;
			end
			mog.filt._quality[self.value] = self.checked;
			UIDropDownMenu_SetText(mog.filt.quality,L["%d selected"]:format(qualityNum));
			mog.buildList();
		end
		info.keepShownOnClick = true;
		info.isNotRadio = true;
		info.checked = mog.filt._quality[v];
		UIDropDownMenu_AddButton(info);
	end
end

mog.filt.defaults = CreateFrame("Button","MogItFiltersDefaults",mog.filt.frame,"UIPanelButtonTemplate2");
mog.filt.defaults:SetText(DEFAULTS);
mog.filt.defaults:SetSize(100,22);
mog.filt.defaults:SetPoint("BOTTOMRIGHT",mog.filt.frame,"BOTTOMRIGHT",0,5);
mog.filt.defaults:SetScript("OnClick",function(self,btn)
	mog.filt._minlvl = 0;
	mog.filt._maxlvl = UnitLevel("PLAYER");
	mog.filt._alliance = UnitFactionGroup("PLAYER") == "Alliance";
	mog.filt._horde = UnitFactionGroup("PLAYER") == "Horde";
	
	mog.filt._class = mog.classBits[select(2,UnitClass("PLAYER"))];
	classNum = 1;
	classSelected = {[select(2,UnitClass("PLAYER"))] = true};
	
	mog.filt._sources = {};
	sourceNum = 0;
	for k,v in ipairs(mog.source) do
		mog.filt._sources[k] = true;
		sourceNum = sourceNum + 1;
	end
	
	mog.filt._slots = {};
	slotNum = 0;
	for k,v in ipairs(mog.slots) do
		mog.filt._slots[k] = true;
		slotNum = slotNum + 1;
	end
	
	mog.filt._quality = {};
	qualityNum = 0;
	for k,v in ipairs(mog.quality) do
		mog.filt._quality[v] = true;
		qualityNum = qualityNum + 1;
	end

	mog.filt.sourceSub = {
		[1] = {}, -- Drop
	};
	for k,v in ipairs(mog.difficulties) do
		mog.filt.sourceSub[1][k] = true;
	end
	
	mog.filt.update();
	mog.buildList();
end);

function mog.filt.update()
	mog.filt.minlvl:SetNumber(mog.filt._minlvl);
	mog.filt.maxlvl:SetNumber(mog.filt._maxlvl);
	mog.filt.factionAlliance:SetChecked(mog.filt._alliance);
	mog.filt.factionHorde:SetChecked(mog.filt._horde);
	UIDropDownMenu_SetText(mog.filt.classes,L["%d selected"]:format(classNum));
	UIDropDownMenu_SetText(mog.filt.sources,L["%d selected"]:format(sourceNum));
	UIDropDownMenu_SetText(mog.filt.slots,L["%d selected"]:format(slotNum));
	UIDropDownMenu_SetText(mog.filt.quality,L["%d selected"]:format(qualityNum));
end