local MogIt,mog = ...;
_G["MogIt"] = mog;
local L = mog.L;

mog.modules = {
	base = {},
	extra = {},
	lookup = {},
};
mog.sub = {};
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

function mog:RegisterModule(name,data,base)
	if mog.modules.lookup[name] then return end;
	mog.modules.lookup[name] = data;
	table.insert(base and mog.modules.base or mog.modules.extras,data);
	if UIDropDownMenu_GetCurrentDropDown() == mog.dropdown and DropDownList1 and DropDownList1:IsShown() then
		HideDropDownMenu(1);
		ToggleDropDownMenu(1,data,mog.dropdown);
	end
	return data;
end

function mog:GetModule(name)
	return mog.modules.lookup[name];
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
	mog:FilterUpdate(); -- dont update if list isnt updated
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

local LDB = LibStub("LibDataBroker-1.1");
mog.LDBI = LibStub("LibDBIcon-1.0");
mog.mmb = LDB:NewDataObject("MogIt",{
	type = "launcher",
	icon = "Interface\\Icons\\INV_Enchant_EssenceCosmicGreater",
	OnClick = function(self,btn)
		if btn == "RightButton" then
			mog.togglePreview();
		else
			mog.toggleFrame();
		end
	end,
	OnTooltipShow = function(self)
		if not self or not self.AddLine then return end
		self:AddLine("MogIt");
		self:AddLine(mog.frame:IsShown() and L["Left click to close MogIt"] or L["Left click to open MogIt"],1,1,1);
		--self:AddLine(mog.preview:IsShown() and L["Right click to close the MogIt preview"] or L["Right click to close the MogIt preview"],1,1,1);
	end,
});


local LBB = LibStub("LibBabble-Boss-3.0"):GetUnstrictLookupTable();
local mobs = {};

--[[local tooltip = CreateFrame("GameTooltip","MogItMobsTooltip");
local text = tooltip:CreateFontString();
tooltip:AddFontStrings(text,tooltip:CreateFontString());

local function CachedMob(id)
	if not id then return end;
	tooltip:SetOwner(WorldFrame,"ANCHOR_NONE");
	tooltip:SetHyperlink(("unit:0xF53%05X00000000"):format(id));
	if (tooltip:IsShown()) then
		return text:GetText();
	end
end--]]

function mog.AddMob(id,name)
	--if not (mobs[id] or CachedMob(id)) then
	if not mobs[id] then
		mobs[id] = LBB[name] or name;
	end
end

function mog.GetMob(id)
	--return mobs[id] or CachedMob(id);
	return mobs[id];
end