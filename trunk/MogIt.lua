local MogIt,mog = ...;
_G["MogIt"] = mog;
local L = mog.L;

mog.LBB = LibStub("LibBabble-Boss-3.0"):GetUnstrictLookupTable();
mog.LBI = LibStub("LibBabble-Inventory-3.0"):GetUnstrictLookupTable();
mog.LDB = LibStub("LibDataBroker-1.1");
mog.LDBI = LibStub("LibDBIcon-1.0");

mog.modules = {
	base = {},
	extra = {},
};
mog.list = {};
mog.models = {};
mog.bin = {};
mog.posX = 0;
mog.posY = 0;
mog.posZ = 0;
mog.face = 0;

-- dropdown()
-- setlist()
-- update()
-- mouseover()
-- onclick()

-- UnsetList?
-- :Gets?
-- Sort/Filter/URL

function mog:RegisterModule(data,base)
	if base then
		table.insert(mog.modules.base,data);
	else
		table.insert(mog.modules.extra,data);
	end
	if UIDropDownMenu_GetCurrentDropDown() == mog.dropdown and DropDownList1 and DropDownList1:IsShown() then
		HideDropDownMenu(1);
		ToggleDropDownMenu(1,data,mog.dropdown);
	end
	return data;
end

function mog:SetList(module,list,top)
	if mog.selected and mog.selected.Unlist then
		mog.selected:Unlist(module,list);
	end
	mog.selected = module;
	mog.list = list;
	--sorting
	--showfilter
	mog.scroll:update(top and 1);
	mog:FilterUpdate();
end

function mog.toggleFrame()
	if mog.frame:IsShown() then
		HideUIPanel(mog.frame);
	else
		ShowUIPanel(mog.frame);
	end
end

function mog.togglePreview()
	if mog.preview:IsShown() then
		HideUIPanel(mog.preview);
	else
		ShowUIPanel(mog.preview);
	end
end

SLASH_MOGIT1 = "/mog";
SLASH_MOGIT2 = "/mogit";
SlashCmdList["MOGIT"] = toggleFrame;
--[[function(msg)
	if msg and msg > "" then
		if msg:match("item:(%d+)") then
			local id = msg:match("item:(%d+)");
			mog:ShowURL(id);
			return;
		elseif msg:match("spell:(%d+)") then
			local id = msg:match("spell:(%d+)");
			mog:ShowURL(id,"spell");
			return;
		end
	end
	mog.toggleFrame();
end--]]

BINDING_HEADER_MogIt = "MogIt";
BINDING_NAME_MogIt = L["Toggle Mogit"];