local MogIt,mog = ...;
local L = mog.L;

function mog.createOptions()
	local about = LibStub("LibAboutPanel").new(nil,MogIt);
	about:GetScript("OnShow")(about);
	about:SetScript("OnShow",nil);

	local config = LibStub("AceConfig-3.0");
	local dialog = LibStub("AceConfigDialog-3.0");
	local db = LibStub("AceDBOptions-3.0");

	local function get(info)
		if info.arg == "minimap" then
			return mog.db.profile.minimap.hide;
		else
			return mog.db.profile[info.arg];
		end
	end
	
	local function set(info,value)
		if info.arg == "minimap" then
			mog.db.profile.minimap.hide = value;
		else
			mog.db.profile[info.arg] = value;
		end
	end
	
	local options = {
		type = "group",
		name = MogIt,
		args = {},
	};

	options.args.general = {
		type = "group",
		order = 1,
		name = GENERAL,
		get = get,
		set = set,
		args = {
			minimap = {
				type = "toggle",
				order = 1,
				name = L["Hide minimap button"],
				arg = "minimap",
			},
			catalogue = {
				type = "group",
				order = 2,
				name = L["Catalogue"],
				inline = true,
				args = {
					noAnim = {
						type = "toggle",
						order = 1,
						name = L["No animation"],
						width = "double",
						arg = "noAnim",
					},
					naked = {
						type = "toggle",
						order = 2,
						name = L["Naked models"],
						width = "double",
						arg = "gridDress",
					},
					--[[url = {
						type = "select",
						order = 3,
						name = L["URL website"],
						arg = "url",
					},--]]
				},
			},
			tooltip = {
				type = "group",
				order = 3,
				name = L["Tooltip"],
				inline = true,
				args = {
					tooltip = {
						type = "toggle",
						order = 1,
						name = L["Enable tooltip model"],
						width = "double",
						arg = "tooltip",
					},
					naked = {
						type = "toggle",
						order = 2,
						name = L["Naked model"],
						width = "double",
						arg = "tooltipDress",
					},
					mouse = {
						type = "toggle",
						order = 3,
						name = L["Rotate with mouse wheel"],
						width = "double",
						arg = "tooltipMouse",
					},
					rotate = {
						type = "toggle",
						order = 4,
						name = L["Auto rotate"],
						width = "double",
						arg = "tooltipRotate",
					},
					mog = {
						type = "toggle",
						order = 5,
						name = L["Only transmogrification items"],
						width = "double",
						arg = "tooltipRotate",
					},
					--[[modifier = {
						type = "select",
						order = 6,
						name = L["Only show if modifier is pressed"],
						arg = "tooltipMod",
					},--]]
				},
			},
		},
	};
	config:RegisterOptionsTable("MogIt_General",options.args.general);
	dialog:AddToBlizOptions("MogIt_General",options.args.general.name,MogIt);
	
	options.args.modules = {
		type = "group",
		order = 2,
		name = L["Modules"],
		--[[plugins = {
			
		},--]]
		args = {
			wishlist = db:GetOptionsTable(mog:GetModule("Wishlist").db),
		},
	};
	options.args.modules.args.wishlist.name = L["Wishlist"];
	config:RegisterOptionsTable("MogIt_Modules",options.args.modules);
	dialog:AddToBlizOptions("MogIt_Modules",options.args.modules.name,MogIt);
	
	--[[options.args.wishlist = db:GetOptionsTable(mog:GetModule("Wishlist").db);
	options.args.wishlist.name = L["Wishlist Profile"];
	options.args.wishlist.order = 6;
	config:RegisterOptionsTable("MogIt_Wishlist",options.args.wishlist);
	dialog:AddToBlizOptions("MogIt_Wishlist",options.args.wishlist.name,MogIt);--]]

	options.args.options = db:GetOptionsTable(mog.db);
	options.args.options.name = L["Options Profile"];
	options.args.options.order = 7;
	config:RegisterOptionsTable("MogIt_Options",options.args.options);
	dialog:AddToBlizOptions("MogIt_Options",options.args.options.name,MogIt);
end