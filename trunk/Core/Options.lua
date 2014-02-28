﻿local MogIt,mog = ...;
local L = mog.L;

function mog.createOptions()
	local about = LibStub("LibAddonInfo-1.0"):CreateFrame(MogIt,nil,"Interface\\AddOns\\Mogit\\Images");

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
			if value then
				mog.LDBI:Hide("MogIt");
			else
				mog.LDBI:Show("MogIt");
			end
		else
			mog.db.profile[info.arg] = value;
			if info.arg == "tooltipRotate" then
				mog.tooltip.rotate:SetShown(value);
			elseif info.arg == "singlePreview" then
				mog:SetSinglePreview(value);
			elseif info.arg == "previewUIPanel" then
				mog:SetPreviewUIPanel(value);
			elseif info.arg == "previewFixedSize" then
				mog:SetPreviewFixedSize(value);
			elseif info.arg == "tooltipWidth" then
				mog.tooltip:SetWidth(value);
			elseif info.arg == "tooltipHeight" then
				mog.tooltip:SetHeight(value);
			elseif info.arg == "rows" or info.arg == "columns" then
				mog:UpdateGUI();
			end
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
				width = "full",
				arg = "minimap",
			},
			dressupPreview = {
				type = "toggle",
				order = 1.4,
				name = L["Use preview frame to dress up"],
				width = "full",
				arg = "dressupPreview",
			},
			singlePreview = {
				type = "toggle",
				order = 1.5,
				name = L["Use a single preview frame"],
				width = "full",
				arg = "singlePreview",
				confirm = function()
					return L["This will close all your currently open previews."];
				end,
			},
			previewUIPanel = {
				type = "toggle",
				order = 1.75,
				name = L["Preview frame UI panel behaviour"],
				width = "full",
				arg = "previewUIPanel",
				disabled = function()
					return not mog.db.profile.singlePreview;
				end,
			},
			previewFixedSize = {
				type = "toggle",
				order = 1.8,
				name = L["Preview frame fixed size"],
				width = "full",
				arg = "previewFixedSize",
				disabled = function()
					return not (mog.db.profile.singlePreview and mog.db.profile.previewUIPanel);
				end,
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
					url = {
						type = "select",
						order = 2.5,
						name = L["URL website"],
						values = function()
							local tbl = {};
							for k,v in pairs(mog.url) do
								tbl[k] = (v.fav and "\124T"..v.fav..":16\124t " or "")..k;
							end
							return tbl;
						end,
						arg = "url",
					},
					rows = {
						type = "range",
						order = 4,
						name = L["Rows"],
						step = 1,
						min = 1,
						max = 10,
						arg = "rows",
					},
					columns = {
						type = "range",
						order = 5,
						name = L["Columns"],
						step = 1,
						min = 1,
						max = 15,
						arg = "columns",
					},
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
					dress = {
						type = "toggle",
						order = 2,
						name = L["Dress model"],
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
						width = "full",
						arg = "tooltipRotate",
					},
					width = {
						type = "range",
						order = 5,
						name = L["Width"],
						step = 1,
						min = 100,
						max = 500,
						arg = "tooltipWidth",
					},
					height = {
						type = "range",
						order = 6,
						name = L["Height"],
						step = 1,
						min = 100,
						max = 500,
						arg = "tooltipHeight",
					},
					mog = {
						type = "toggle",
						order = 7,
						name = L["Only transmogrification items"],
						width = "double",
						arg = "tooltipMog",
					},
					modifier = {
						type = "select",
						order = 8,
						name = L["Only show if modifier is pressed"],
						values = function()
							local tbl = {
								None = "None",
							};
							for k,v in pairs(mog.tooltip.mod) do
								tbl[k] = k;
							end
							return tbl;
						end,
						arg = "tooltipMod",
					},
				},
			},
		},
	};
	config:RegisterOptionsTable("MogIt_General",options.args.general);
	dialog:AddToBlizOptions("MogIt_General",options.args.general.name,MogIt);
	
	--[[options.args.modules = {
		type = "group",
		order = 2,
		name = L["Modules"],
		--plugins
		args = {
			wishlist = db:GetOptionsTable(mog.wishlist.db),
		},
	};
	options.args.modules.args.wishlist.name = L["Wishlist"];
	config:RegisterOptionsTable("MogIt_Modules",options.args.modules);
	dialog:AddToBlizOptions("MogIt_Modules",options.args.modules.name,MogIt);--]]

	options.args.options = db:GetOptionsTable(mog.db);
	options.args.options.name = L["Options Profile"];
	options.args.options.order = 5;
	config:RegisterOptionsTable("MogIt_Options",options.args.options);
	dialog:AddToBlizOptions("MogIt_Options",options.args.options.name,MogIt);
	
	options.args.wishlist = db:GetOptionsTable(mog.wishlist.db);
	options.args.wishlist.name = L["Wishlist Profile"];
	options.args.wishlist.order = 6;
	config:RegisterOptionsTable("MogIt_Wishlist",options.args.wishlist);
	dialog:AddToBlizOptions("MogIt_Wishlist",options.args.wishlist.name,MogIt);
	
	mog.options = options;
end

local hook = CreateFrame("Frame",nil,InterfaceOptionsFrame);
hook:SetScript("OnShow",function(self)
	if not mog.options then
		mog.createOptions();
	end
	self:SetScript("OnShow",nil);
end);