local MogIt,mog = ...;
local L = mog.L;

local GetSourceInfo = C_TransmogCollection.GetSourceInfo
local DoesItemExistByID = C_Item.DoesItemExistByID

local f = mog:CreateFilter("expansion");
local selected;
local numSelected;

f:SetHeight(41);

f.quality = f:CreateFontString(nil,"ARTWORK","GameFontHighlightSmall");
f.quality:SetPoint("TOPLEFT",f,"TOPLEFT",0,0);
f.quality:SetPoint("RIGHT",f,"RIGHT",0,0);
f.quality:SetText(EXPANSION_FILTER_TEXT..":");
f.quality:SetJustifyH("LEFT");

f.dd = CreateFrame("Frame","MogItFiltersQualityDropdown",f,"UIDropDownMenuTemplate");
f.dd:SetPoint("TOPLEFT",f.quality,"BOTTOMLEFT",-16,-2);
UIDropDownMenu_SetWidth(f.dd,125);
UIDropDownMenu_SetButtonWidth(f.dd,140);
UIDropDownMenu_JustifyText(f.dd,"LEFT");

function f.dd.SelectAll(self, selectAll)
	local numExpansions = GetNumExpansions();
	if selectAll then
		numSelected = numExpansions;
		for i = 0, (numExpansions - 1) do
			selected[i] = true;
		end
	else
		numSelected = 0;
		selected = {};
	end
	UIDropDownMenu_SetText(f.dd, L["%d selected"]:format(numSelected));
	ToggleDropDownMenu(1, nil, f.dd);
	mog:BuildList();
end

function f.dd.Tier1(self)
	if selected[self.value] and (not self.checked) then
		numSelected = numSelected - 1;
	elseif (not selected[self.value]) and self.checked then
		numSelected = numSelected + 1;
	end
	selected[self.value] = self.checked;
	UIDropDownMenu_SetText(f.dd, L["%d selected"]:format(numSelected));
	mog:BuildList();
end

function f.dd.initialize(self)
	local numExpansions = GetNumExpansions();
	local info = UIDropDownMenu_CreateInfo();
	info.text =	numSelected < numExpansions and L["Select All"] or L["Select None"];
	info.func = f.dd.SelectAll;
	info.arg1 = numSelected < numExpansions;
	info.notCheckable = true;
	UIDropDownMenu_AddButton(info);

	for i = 0, (numExpansions - 1) do
		info = UIDropDownMenu_CreateInfo();
		info.text =	GetExpansionName(i);
		info.value = i;
		info.func = f.dd.Tier1;
		info.keepShownOnClick = true;
		info.isNotRadio = true;
		info.checked = selected[i];
		UIDropDownMenu_AddButton(info);
	end
end

function f.Filter(item)
	if numSelected == GetNumExpansions() then return true end
	local sourceInfo = GetSourceInfo(item)
	if not sourceInfo or not DoesItemExistByID(sourceInfo.itemID) then return end
	local item = mog:GetItemInfo(sourceInfo.itemID, "BuildList");
	return not item or selected[item.expansionID];
end

function f.Default()
	selected = {};
	numSelected = 0;
	for i = 0, (GetNumExpansions() - 1) do
		selected[i] = true;
		numSelected = numSelected + 1;
	end
	UIDropDownMenu_SetText(f.dd, L["%d selected"]:format(numSelected));
end

f.Default();
