local MogIt,mog = ...;
local L = mog.L;

function mog.createOptions()
	do
		local about = CreateFrame("Frame",nil,InterfaceOptionsFramePanelContainer);
		about.name = MogIt;
		about:Hide();
		
		local title = about:CreateFontString(nil,"ARTWORK","GameFontNormalLarge");
		title:SetPoint("TOPLEFT",16,-16);
		title:SetText(MogIt);
		
		local desc = about:CreateFontString(nil,"ARTWORK","GameFontHighlightSmall");
		desc:SetHeight(32);
		desc:SetPoint("TOPLEFT",title,"BOTTOMLEFT",0,-8);
		desc:SetPoint("RIGHT",about,-32,0);
		desc:SetNonSpaceWrap(true);
		desc:SetJustifyH("LEFT");
		desc:SetJustifyV("TOP");
		desc:SetText(GetAddOnMetadata(MogIt,"Notes"));
	
		InterfaceOptions_AddCategory(about);
	end

	local config = LibStub("AceConfig-3.0");
	local dialog = LibStub("AceConfigDialog-3.0");
	local db = LibStub("AceDBOptions-3.0");

	local options = {
		type = "group",
		name = MogIt,
		args = {},
	};

	options.args.general = {
		type = "group",
		order = 1,
		name = GENERAL,
		--desc = L["General options"],
		args = {
		
		},
	};
	config:RegisterOptionsTable("MogIt_General",options.args.general);
	dialog:AddToBlizOptions("MogIt_General",options.args.general.name,MogIt);
	
	options.args.tooltip = {
		type = "group",
		order = 1,
		name = L["Tooltip"],
		--desc = L["Tooltip options"],
		args = {
		
		},
	};
	config:RegisterOptionsTable("MogIt_Tooltip",options.args.tooltip);
	dialog:AddToBlizOptions("MogIt_Tooltip",options.args.tooltip.name,MogIt);

	options.args.wishlist = db:GetOptionsTable(mog:GetModule("Wishlist").db);
	options.args.wishlist.name = L["Wishlist Profile"];
	options.args.wishlist.order = 6;
	config:RegisterOptionsTable("MogIt_Wishlist",options.args.wishlist);
	dialog:AddToBlizOptions("MogIt_Wishlist",options.args.wishlist.name,MogIt);

	options.args.options = db:GetOptionsTable(mog.db);
	options.args.options.name = L["Options Profile"];
	options.args.options.order = 7;
	config:RegisterOptionsTable("MogIt_Options",options.args.options);
	dialog:AddToBlizOptions("MogIt_Options",options.args.options.name,MogIt);
end