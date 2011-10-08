local MogIt,mog = ...;
local L = mog.L;

mog.sub.filt = CreateFrame("Frame",nil,mog.filt);
mog.sub.filt:SetSize(222,370);

mog.sub.filt._minlvl = 0;
mog.sub.filt._maxlvl = UnitLevel("PLAYER");
mog.sub.filt._alliance = UnitFactionGroup("PLAYER") == "Alliance";
mog.sub.filt._horde = UnitFactionGroup("PLAYER") == "Horde";
mog.sub.filt._class = mog.sub.classBits[select(2,UnitClass("PLAYER"))];
mog.sub.filt._sources = {};
mog.sub.filt._slots = {};
mog.sub.filt._quality = {};
mog.sub.filt._sourceSub = {
	[1] = {}, -- Drop
};

mog.sub.filt.lvl = mog.sub.filt:CreateFontString(nil,"ARTWORK","GameFontHighlightSmall");
mog.sub.filt.lvl:SetPoint("TOPLEFT",mog.sub.filt,"TOPLEFT",5,-10);
mog.sub.filt.lvl:SetPoint("RIGHT",mog.sub.filt,"RIGHT",-5,0);
mog.sub.filt.lvl:SetText(LEVEL_RANGE..":");
mog.sub.filt.lvl:SetJustifyH("LEFT");

mog.sub.filt.minlvl = CreateFrame("EditBox","MogItModuleFiltersMinLvl",mog.sub.filt,"InputBoxTemplate");
mog.sub.filt.minlvl:SetSize(25,16);
mog.sub.filt.minlvl:SetPoint("TOPLEFT",mog.sub.filt.lvl,"BOTTOMLEFT",8,-5);
mog.sub.filt.minlvl:SetNumeric(true);
mog.sub.filt.minlvl:SetMaxLetters(2);
mog.sub.filt.minlvl:SetAutoFocus(false);
mog.sub.filt.minlvl:SetScript("OnEnterPressed",EditBox_ClearFocus);
mog.sub.filt.minlvl:SetScript("OnTabPressed",function(self)
	mog.sub.filt.maxlvl:SetFocus();
end);
mog.sub.filt.minlvl:SetScript("OnTextChanged",function(self,user)
	if user then
		mog.sub.filt._minlvl = tonumber(self:GetText()) or 0;
		mog.sub.BuildList();
	end
end);

mog.sub.filt.lvlh = mog.sub.filt:CreateFontString(nil,"ARTWORK","GameFontHighlightSmall");
mog.sub.filt.lvlh:SetPoint("LEFT",mog.sub.filt.minlvl,"RIGHT",0,1);
mog.sub.filt.lvlh:SetText("-");

mog.sub.filt.maxlvl = CreateFrame("EditBox","MogItModuleFiltersMaxLvl",mog.sub.filt,"InputBoxTemplate");
mog.sub.filt.maxlvl:SetSize(25,16);
mog.sub.filt.maxlvl:SetPoint("LEFT",mog.sub.filt.minlvl,"RIGHT",12,0);
mog.sub.filt.maxlvl:SetNumeric(true);
mog.sub.filt.maxlvl:SetMaxLetters(2);
mog.sub.filt.maxlvl:SetAutoFocus(false);
mog.sub.filt.maxlvl:SetScript("OnEnterPressed",EditBox_ClearFocus);
mog.sub.filt.maxlvl:SetScript("OnTabPressed",function(self)
	mog.sub.filt.minlvl:SetFocus();
end);
mog.sub.filt.maxlvl:SetScript("OnTextChanged",function(self,user)
	if user then
		mog.sub.filt._maxlvl = tonumber(self:GetText()) or MAX_PLAYER_LEVEL;
		mog.sub.BuildList();
	end
end);

mog.sub.filt.faction = mog.sub.filt:CreateFontString(nil,"ARTWORK","GameFontHighlightSmall");
mog.sub.filt.faction:SetPoint("TOPLEFT",mog.sub.filt.lvl,"BOTTOMLEFT",0,-35);
mog.sub.filt.faction:SetPoint("RIGHT",mog.sub.filt,"RIGHT",-5,0);
mog.sub.filt.faction:SetText(L["Faction Items"]..":");
mog.sub.filt.faction:SetJustifyH("LEFT");

mog.sub.filt.factionAlliance = CreateFrame("CheckButton","MogItModuleFiltersAlliance",mog.sub.filt,"UICheckButtonTemplate");
MogItModuleFiltersAllianceText:SetText(FACTION_ALLIANCE);
mog.sub.filt.factionAlliance:SetPoint("TOPLEFT",mog.sub.filt.faction,"BOTTOMLEFT",0,0);
mog.sub.filt.factionAlliance:SetScript("OnClick",function(self)
	mog.sub.filt._alliance = self:GetChecked();
	mog.sub.BuildList();
end);

mog.sub.filt.factionHorde = CreateFrame("CheckButton","MogItModuleFiltersHorde",mog.sub.filt,"UICheckButtonTemplate");
MogItModuleFiltersHordeText:SetText(FACTION_HORDE);
mog.sub.filt.factionHorde:SetPoint("TOP",mog.sub.filt.factionAlliance,"BOTTOM",0,7);
mog.sub.filt.factionHorde:SetScript("OnClick",function(self)
	mog.sub.filt._horde = self:GetChecked();
	mog.sub.BuildList();
end);

mog.sub.filt.class = mog.sub.filt:CreateFontString(nil,"ARTWORK","GameFontHighlightSmall");
mog.sub.filt.class:SetPoint("TOPLEFT",mog.sub.filt.faction,"BOTTOMLEFT",0,-64);
mog.sub.filt.class:SetPoint("RIGHT",mog.sub.filt,"RIGHT",0,-5);
mog.sub.filt.class:SetText(L["Class Items"]..":");
mog.sub.filt.class:SetJustifyH("LEFT");

local classCoords = CLASS_ICON_TCOORDS;
local classColours = RAID_CLASS_COLORS;
local classSelected = {[select(2,UnitClass("PLAYER"))] = true};
local classNum = 1;
local classAll = true;

mog.sub.filt.classes = CreateFrame("Frame","MogItModuleFiltersClassDropdown",mog.sub.filt,"UIDropDownMenuTemplate");
mog.sub.filt.classes:SetPoint("TOPLEFT",mog.sub.filt.class,"BOTTOMLEFT",-16,-2);
UIDropDownMenu_SetWidth(mog.sub.filt.classes,125);
UIDropDownMenu_SetButtonWidth(mog.sub.filt.classes,140);
UIDropDownMenu_JustifyText(mog.sub.filt.classes,"LEFT");
UIDropDownMenu_SetText(mog.sub.filt.classes,L["%d selected"]:format(1));
function mog.sub.filt.classes:initialize()
	local info;
	info = UIDropDownMenu_CreateInfo();
	info.text =	classAll and L["Select All"] or L["Select None"];
	info.value = "SA";
	info.func = function(self)
		classNum = 0;
		mog.sub.filt._class = 0;
		for k,v in pairs(mog.sub.classes) do
			classSelected[k] = classAll and true;
			classNum = classNum + (classAll and 1 or 0);
			mog.sub.filt._class = mog.sub.filt._class + (classAll and mog.sub.classBits[k] or 0);
		end
		classAll = not classAll;
		UIDropDownMenu_SetText(mog.sub.filt.classes,L["%d selected"]:format(classNum));
		ToggleDropDownMenu(1,nil,mog.sub.filt.classes);
		mog.sub.BuildList();
	end
	info.notCheckable = true;
	UIDropDownMenu_AddButton(info);
	for k,v in pairs(mog.sub.classeses) do
		info = UIDropDownMenu_CreateInfo();
		info.text =	v;
		info.value = k;
		info.colorCode = string.format("\124cff%.2x%.2x%.2x",classColours[k].r*255,classColours[k].g*255,classColours[k].b*255);
		info.func = function(self)
			if classSelected[self.value] and (not self.checked) then
				mog.sub.filt._class = mog.sub.filt._class - mog.sub.classBits[self.value];
				classNum = classNum - 1;
			elseif (not classSelected[self.value]) and self.checked then
				mog.sub.filt._class = mog.sub.filt._class + mog.sub.classBits[self.value];
				classNum = classNum + 1;
			end
			classSelected[self.value] = self.checked;
			UIDropDownMenu_SetText(mog.sub.filt.classes,L["%d selected"]:format(classNum));
			mog.sub.BuildList();
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

mog.sub.filt.source = mog.sub.filt:CreateFontString(nil,"ARTWORK","GameFontHighlightSmall");
mog.sub.filt.source:SetPoint("TOPLEFT",mog.sub.filt.class,"BOTTOMLEFT",0,-40);
mog.sub.filt.source:SetPoint("RIGHT",mog.sub.filt,"RIGHT",0,-5);
mog.sub.filt.source:SetText(L["Source:"]);
mog.sub.filt.source:SetJustifyH("LEFT");

local sourceNum = 0;
local sourceAll;
for k,v in ipairs(mog.sub.source) do
	mog.sub.filt._sources[k] = true;
	sourceNum = sourceNum + 1;
end
for k,v in ipairs(mog.sub.difficulties) do
	mog.sub.filt._sourceSub[1][k] = true;
end

mog.sub.filt.sources = CreateFrame("Frame","MogItModuleFiltersSourcesDropdown",mog.sub.filt,"UIDropDownMenuTemplate");
mog.sub.filt.sources:SetPoint("TOPLEFT",mog.sub.filt.source,"BOTTOMLEFT",-16,-2);
UIDropDownMenu_SetWidth(mog.sub.filt.sources,125);
UIDropDownMenu_SetButtonWidth(mog.sub.filt.sources,140);
UIDropDownMenu_JustifyText(mog.sub.filt.sources,"LEFT");
UIDropDownMenu_SetText(mog.sub.filt.sources,L["%d selected"]:format(sourceNum));
function mog.sub.filt.sources:initialize(tier)
	if tier == 1 then
		local info;
		info = UIDropDownMenu_CreateInfo();
		info.text =	sourceAll and L["Select All"] or L["Select None"];
		info.value = "SA";
		info.func = function(self)
			sourceNum = 0;
			for k,v in ipairs(mog.sub.source) do
				mog.sub.filt._sources[k] = sourceAll and true;
				sourceNum = sourceNum + (sourceAll and 1 or 0);
			end
			sourceAll = not sourceAll;
			UIDropDownMenu_SetText(mog.sub.filt.sources,L["%d selected"]:format(sourceNum));
			ToggleDropDownMenu(1,nil,mog.sub.filt.sources);
			mog.sub.BuildList();
		end
		info.notCheckable = true;
		UIDropDownMenu_AddButton(info);
		for k,v in ipairs(mog.sub.source) do
			info = UIDropDownMenu_CreateInfo();
			info.text =	v;
			info.value = k;
			info.func = function(self)
				if mog.sub.filt._sources[self.value] and (not self.checked) then
					sourceNum = sourceNum - 1;
				elseif (not mog.sub.filt._sources[self.value]) and self.checked then
					sourceNum = sourceNum + 1;
				end
				mog.sub.filt._sources[self.value] = self.checked;
				UIDropDownMenu_SetText(mog.sub.filt.sources,L["%d selected"]:format(sourceNum));
				mog.sub.BuildList();
			end
			info.keepShownOnClick = true;
			info.isNotRadio = true;
			info.checked = mog.sub.filt._sources[k];
			info.hasArrow = mog.sub.filt.sourceSub[k] and true;
			UIDropDownMenu_AddButton(info);
		end
	elseif tier == 2 then
		local parent = UIDROPDOWNMENU_MENU_VALUE;
		for k,v in ipairs(mog.sub.filt._sourceSub[parent]) do
			info = UIDropDownMenu_CreateInfo();
			if parent == 1 then
				info.text =	mog.sub.difficulties[k];
			end
			info.value = k;
			info.func = function(self)
				mog.sub.filt._sourceSub[parent][self.value] = self.checked;
				if mog.sub.filt._sources[parent] then
					mog.sub.BuildList();
				end
			end
			info.keepShownOnClick = true;
			info.isNotRadio = true;
			info.checked = v;
			UIDropDownMenu_AddButton(info,tier);
		end
	end
end

mog.sub.filt.slot = mog.sub.filt:CreateFontString(nil,"ARTWORK","GameFontHighlightSmall");
mog.sub.filt.slot:SetPoint("TOPLEFT",mog.sub.filt.source,"BOTTOMLEFT",0,-40);
mog.sub.filt.slot:SetPoint("RIGHT",mog.sub.filt,"RIGHT",0,-5);
mog.sub.filt.slot:SetText(L["One-Hand Slot"]..":");
mog.sub.filt.slot:SetJustifyH("LEFT");

local slotNum = 0;
local slotAll;
for k,v in ipairs(mog.sub.slots) do
	mog.sub.filt._slots[k] = true;
	slotNum = slotNum + 1;
end

mog.sub.filt.slots = CreateFrame("Frame","MogItModuleFiltersSlotsDropdown",mog.sub.filt,"UIDropDownMenuTemplate");
mog.sub.filt.slots:SetPoint("TOPLEFT",mog.sub.filt.slot,"BOTTOMLEFT",-16,-2);
UIDropDownMenu_SetWidth(mog.sub.filt.slots,125);
UIDropDownMenu_SetButtonWidth(mog.sub.filt.slots,140);
UIDropDownMenu_JustifyText(mog.sub.filt.slots,"LEFT");
UIDropDownMenu_SetText(mog.sub.filt.slots,L["%d selected"]:format(slotNum));
function mog.sub.filt.slots:initialize()
	local info;
	info = UIDropDownMenu_CreateInfo();
	info.text =	slotAll and L["Select All"] or L["Select None"];
	info.value = "SA";
	info.func = function(self)
		slotNum = 0;
		for k,v in ipairs(mog.sub.slots) do
			mog.sub.filt._slots[k] = slotAll and true;
			slotNum = slotNum + (slotAll and 1 or 0);
		end
		slotAll = not slotAll;
		UIDropDownMenu_SetText(mog.sub.filt.slots,L["%d selected"]:format(slotNum));
		ToggleDropDownMenu(1,nil,mog.sub.filt.slots);
		mog.sub.BuildList();
	end
	info.notCheckable = true;
	UIDropDownMenu_AddButton(info);
	for k,v in ipairs(mog.sub.slots) do
		info = UIDropDownMenu_CreateInfo();
		info.text =	v;
		info.value = k;
		info.func = function(self)
			if mog.sub.filt._slots[self.value] and (not self.checked) then
				slotNum = slotNum - 1;
			elseif (not mog.sub.filt._slots[self.value]) and self.checked then
				slotNum = slotNum + 1;
			end
			mog.sub.filt._slots[self.value] = self.checked;
			UIDropDownMenu_SetText(mog.sub.filt.slots,L["%d selected"]:format(slotNum));
			mog.sub.BuildList();
		end
		info.keepShownOnClick = true;
		info.isNotRadio = true;
		info.checked = mog.sub.filt._slots[k];
		UIDropDownMenu_AddButton(info);
	end
end

mog.sub.filt.qual = mog.sub.filt:CreateFontString(nil,"ARTWORK","GameFontHighlightSmall");
mog.sub.filt.qual:SetPoint("TOPLEFT",mog.sub.filt.slot,"BOTTOMLEFT",0,-40);
mog.sub.filt.qual:SetPoint("RIGHT",mog.sub.filt,"RIGHT",0,-5);
mog.sub.filt.qual:SetText(QUALITY..":");
mog.sub.filt.qual:SetJustifyH("LEFT");

local qualityNum = 0;
local qualityAll;
for k,v in ipairs(mog.sub.quality) do
	mog.sub.filt._quality[v] = true;
	qualityNum = qualityNum + 1;
end
local qualityColors = ITEM_QUALITY_COLORS;

mog.sub.filt.quality = CreateFrame("Frame","MogItModuleFiltersQualityDropdown",mog.sub.filt,"UIDropDownMenuTemplate");
mog.sub.filt.quality:SetPoint("TOPLEFT",mog.sub.filt.qual,"BOTTOMLEFT",-16,-2);
UIDropDownMenu_SetWidth(mog.sub.filt.quality,125);
UIDropDownMenu_SetButtonWidth(mog.sub.filt.quality,140);
UIDropDownMenu_JustifyText(mog.sub.filt.quality,"LEFT");
UIDropDownMenu_SetText(mog.sub.filt.quality,L["%d selected"]:format(qualityNum));
function mog.sub.filt.quality:initialize()
	local info;
	info = UIDropDownMenu_CreateInfo();
	info.text =	qualityAll and L["Select All"] or L["Select None"];
	info.value = "SA";
	info.func = function(self)
		qualityNum = 0;
		for k,v in ipairs(mog.sub.quality) do
			mog.sub.filt._quality[v] = qualityAll and true;
			qualityNum = qualityNum + (qualityAll and 1 or 0);
		end
		qualityAll = not qualityAll;
		UIDropDownMenu_SetText(mog.sub.filt.quality,L["%d selected"]:format(qualityNum));
		ToggleDropDownMenu(1,nil,mog.sub.filt.quality);
		mog.sub.BuildList();
	end
	info.notCheckable = true;
	UIDropDownMenu_AddButton(info);
	for k,v in ipairs(mog.sub.quality) do
		info = UIDropDownMenu_CreateInfo();
		info.text =	_G["ITEM_QUALITY"..v.."_DESC"];
		info.value = v;
		info.colorCode = qualityColors[v].hex;
		info.func = function(self)
			if mog.sub.filt._quality[self.value] and (not self.checked) then
				qualityNum = qualityNum - 1;
			elseif (not mog.sub.filt._quality[self.value]) and self.checked then
				qualityNum = qualityNum + 1;
			end
			mog.sub.filt._quality[self.value] = self.checked;
			UIDropDownMenu_SetText(mog.sub.filt.quality,L["%d selected"]:format(qualityNum));
			mog.sub.BuildList();
		end
		info.keepShownOnClick = true;
		info.isNotRadio = true;
		info.checked = mog.sub.filt._quality[v];
		UIDropDownMenu_AddButton(info);
	end
end

mog.sub.filt.defaults = CreateFrame("Button","MogItModuleFiltersDefaults",mog.sub.filt,"UIPanelButtonTemplate2");
mog.sub.filt.defaults:SetText(DEFAULTS);
mog.sub.filt.defaults:SetSize(100,22);
mog.sub.filt.defaults:SetPoint("BOTTOMRIGHT",mog.sub.filt,"BOTTOMRIGHT",0,5);
mog.sub.filt.defaults:SetScript("OnClick",function(self,btn)
	mog.sub.filt._minlvl = 0;
	mog.sub.filt._maxlvl = UnitLevel("PLAYER");
	mog.sub.filt._alliance = UnitFactionGroup("PLAYER") == "Alliance";
	mog.sub.filt._horde = UnitFactionGroup("PLAYER") == "Horde";
	
	mog.sub.filt._class = mog.sub.classBits[select(2,UnitClass("PLAYER"))];
	classNum = 1;
	classSelected = {[select(2,UnitClass("PLAYER"))] = true};
	
	mog.sub.filt._sources = {};
	sourceNum = 0;
	for k,v in ipairs(mog.sub.source) do
		mog.sub.filt._sources[k] = true;
		sourceNum = sourceNum + 1;
	end
	mog.sub.filt._sourceSub = {
		[1] = {}, -- Drop
	};
	for k,v in ipairs(mog.sub.difficulties) do
		mog.sub.filt._sourceSub[1][k] = true;
	end
	
	mog.sub.filt._slots = {};
	slotNum = 0;
	for k,v in ipairs(mog.sub.slots) do
		mog.sub.filt._slots[k] = true;
		slotNum = slotNum + 1;
	end
	
	mog.sub.filt._quality = {};
	qualityNum = 0;
	for k,v in ipairs(mog.sub.quality) do
		mog.sub.filt._quality[v] = true;
		qualityNum = qualityNum + 1;
	end
	
	mog.sub.filt.update();
	mog.sub.BuildList();
end);

function mog.sub.filt.update()
	mog.sub.filt.minlvl:SetNumber(mog.sub.filt._minlvl);
	mog.sub.filt.maxlvl:SetNumber(mog.sub.filt._maxlvl);
	mog.sub.filt.factionAlliance:SetChecked(mog.sub.filt._alliance);
	mog.sub.filt.factionHorde:SetChecked(mog.sub.filt._horde);
	UIDropDownMenu_SetText(mog.sub.filt.classes,L["%d selected"]:format(classNum));
	UIDropDownMenu_SetText(mog.sub.filt.sources,L["%d selected"]:format(sourceNum));
	UIDropDownMenu_SetText(mog.sub.filt.slots,L["%d selected"]:format(slotNum));
	UIDropDownMenu_SetText(mog.sub.filt.quality,L["%d selected"]:format(qualityNum));
end