local MogIt,mog = ...;
_G["MogIt"] = mog;
local L = mog.L;

mog.list = {};
mog.models = {};
mog.bin = {};
mog.modules = {
	base = {},
	extra = {},
	lookup = {},
};
mog.sub = {};
mog.items = {};

mog.posX = 0;
mog.posY = 0;
mog.posZ = 0;
mog.face = 0;

mog.invSlots = {
	INVTYPE_HEAD = "HeadSlot",
	INVTYPE_SHOULDER = "ShoulderSlot",
	INVTYPE_BODY = "ShirtSlot",
	INVTYPE_CLOAK = "BackSlot",
	INVTYPE_CHEST = "ChestSlot",
	INVTYPE_ROBE = "ChestSlot",
	INVTYPE_WAIST = "WaistSlot",
	INVTYPE_LEGS = "LegsSlot",
	INVTYPE_FEET = "FeetSlot",
	INVTYPE_WRIST = "WristSlot",
	INVTYPE_2HWEAPON = "MainHandSlot",
	INVTYPE_WEAPON = "MainHandSlot",
	INVTYPE_WEAPONMAINHAND = "MainHandSlot",
	INVTYPE_WEAPONOFFHAND = "SecondaryHandSlot",
	INVTYPE_SHIELD = "SecondaryHandSlot",
	INVTYPE_HOLDABLE = "SecondaryHandSlot",
	INVTYPE_RANGED = "RangedSlot",
	INVTYPE_RANGEDRIGHT = "RangedSlot",
	INVTYPE_THROWN = "RangedSlot",
	INVTYPE_HAND = "HandsSlot",
	INVTYPE_TABARD = "TabardSlot",
};

mog.itemSlots = {
	"HeadSlot",
	"ShoulderSlot",
	"BackSlot",
	"ChestSlot",
	"ShirtSlot",
	"TabardSlot",
	"WristSlot",
	"HandsSlot",
	"WaistSlot",
	"LegsSlot",
	"FeetSlot",
	"MainHandSlot",
	"SecondaryHandSlot",
	"RangedSlot",
};

function mog:RegisterModule(name,data,base)
	if mog.modules.lookup[name] then return end;
	data = data or {};
	data.name = name;
	mog.modules.lookup[name] = data;
	table.insert(base and mog.modules.base or mog.modules.extra,data);
	if UIDropDownMenu_GetCurrentDropDown() == mog.dropdown and DropDownList1 and DropDownList1:IsShown() then
		HideDropDownMenu(1);
		ToggleDropDownMenu(1,data,mog.dropdown);
	end
	return data;
end

function mog:GetModule(name)
	return mog.modules.lookup[name];
end

function mog:GetActiveModule()
	return mog.active.name;
end

function mog:SetModule(module,text)
	if mog.active and mog.active.Unlist and mog.active ~= module then
		mog.active:Unlist(module);
	end
	mog.active = module;
	mog:BuildList(true);
	mog:FilterUpdate();
	if module then
		UIDropDownMenu_SetText(mog.dropdown,text or module.label or module.name);
	else
		UIDropDownMenu_SetText(mog.dropdown,L["Select a module"]);
	end
end

function mog:BuildList(top,module)
	if (module and mog.active and mog.active.name ~= module) then return end;
	mog.list = mog.active and mog.active:BuildList() or {};
	mog:SortList(nil,true);
	mog.scroll:update(top and 1);
	mog.filt.models:SetText(#mog.list);
end

function mog.toggleFrame()
	if mog.frame:IsShown() then
		HideUIPanel(mog.frame);
	else
		ShowUIPanel(mog.frame);
	end
end

function mog.togglePreview()
	if mog.view:IsShown() then
		HideUIPanel(mog.view);
	else
		ShowUIPanel(mog.view);
	end
end

SLASH_MOGIT1 = "/mog";
SLASH_MOGIT2 = "/mogit";
SlashCmdList["MOGIT"] = mog.toggleFrame;

BINDING_HEADER_MogIt = "MogIt";
BINDING_NAME_MogIt = L["Toggle Mogit"];
BINDING_NAME_MogItPreview = L["Toggle Preview"];

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
		self:AddLine(L["Left click to toggle MogIt"],1,1,1);
		self:AddLine(L["Right click to toggle the preview"],1,1,1);
	end,
});

local defaults = {
	profile = {
		tooltip = true,
		tooltipWidth = 300,
		tooltipHeight = 300,
		tooltipMouse = false,
		tooltipDress = false,
		tooltipRotate = true,
		tooltipMog = true,
		tooltipMod = "None",
		gridDress = true,
		noAnim = false,
		minimap = {},
		url = "Battle.net",
		width = 200,
		height = 200,
		rows = 2;
		columns = 3,
	}
}

mog.frame = CreateFrame("Frame","MogItFrame",UIParent,"ButtonFrameTemplate");
mog.frame:SetScript("OnEvent",function(self,event,arg1,...)
	if event == "PLAYER_LOGIN" then
		mog.view.model.model:SetUnit("PLAYER");
		mog.updateGUI();
		mog.tooltip.model:SetUnit("PLAYER");
	elseif event == "GET_ITEM_INFO_RECEIVED" then
		local owner = GameTooltip:IsShown() and GameTooltip:GetOwner();
		if owner and owner.MogItModel then
			mog.OnEnter(owner);
		end
	elseif event == "ADDON_LOADED" then
		if arg1 == MogIt then
			local AceDB = LibStub("AceDB-3.0")
			mog.db = AceDB:New("MogItDB", defaults, true)
			
			if not mog.db.global.version then
				DEFAULT_CHAT_FRAME:AddMessage(L["MogIt has loaded! Type \"/mog\" to open it."]);
			end
			mog.db.global.version = GetAddOnMetadata(MogIt,"Version");
			
			mog.LDBI:Register("MogIt",mog.mmb,mog.db.profile.minimap);
			
			mog.tooltip:SetSize(mog.db.profile.tooltipWidth,mog.db.profile.tooltipHeight);
			if mog.db.profile.tooltipRotate then
				mog.tooltip.rotate:Show();
			end
			
			for name,module in pairs(mog.modules.lookup) do
				if module.MogItLoaded then
					module:MogItLoaded()
				end
			end
		elseif mog.modules.lookup[arg1] then
			mog.modules.lookup[arg1].loaded = true;
			if UIDropDownMenu_GetCurrentDropDown() == mog.dropdown and DropDownList1 and DropDownList1:IsShown() then
				HideDropDownMenu(1);
				ToggleDropDownMenu(1,mog.modules.lookup[arg1],mog.dropdown);
			end
		end
	end
end);
mog.frame:RegisterEvent("PLAYER_LOGIN");
mog.frame:RegisterEvent("GET_ITEM_INFO_RECEIVED");
mog.frame:RegisterEvent("ADDON_LOADED");

--[=[
function mog:AddItemData(id,field,value)
	if not id then return end;
	if not mog.items[field] then
		mog.items[field] = {};
	end
	mog.items[field][id] = value;
end

function mog:GetItemData(id,field)
	if not mog.items[field] then return end;
	return mog.items[field][id];
end

function mog:DeleteItemData(id,field)
	if field then
		if mog.items[field] then
			mog.items[field][id] = nil;
		end
	else
		for k,v in pairs(mog.items) do
			v[id] = nil;
		end
	end
end--]=]

local LBB = LibStub("LibBabble-Boss-3.0"):GetUnstrictLookupTable();
mog.mobs = {};

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
	if not mog.mobs[id] then
		mog.mobs[id] = LBB[name] or name;
	end
end

function mog.GetMob(id)
	--return mobs[id] or CachedMob(id);
	return mog.mobs[id];
end