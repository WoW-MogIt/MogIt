local MogIt,mog = ...;
local L = mog.L;

function mog.createOptions()
	local about = LibStub("LibAboutPanel").new(nil,MogIt);
	about:GetScript("OnShow")(about);
	about:SetScript("OnShow",nil);

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