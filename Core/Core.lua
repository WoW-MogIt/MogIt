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
	data.label = name;
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
	return mog.active.label;
end

function mog:SetModule(module,text)
	if not module then return end;
	if mog.active and mog.active.Unlist and mog.active ~= module then
		mog.active:Unlist(module);
	end
	mog.active = module;
	if text then
		UIDropDownMenu_SetText(mog.dropdown,text);
	end
	mog:BuildList(true);
	mog:FilterUpdate();
	if module.Sorting then
		UIDropDownMenu_EnableDropDown(mog.sorting);
	else
		UIDropDownMenu_DisableDropDown(mog.sorting);
	end
end

function mog:BuildList(top, module)
	if not mog.active or (module and mog.active.label ~= module) then return end;
	mog.list = mog.active:BuildList();
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
		self:AddLine(L["Left click to toggle MogIt"],1,1,1);
		self:AddLine(L["Right click to toggle the preview"],1,1,1);
	end,
});

local defaults = {
	profile = {
		tooltip = true,
		tooltipMouse = false,
		tooltipDress = false,
		tooltipRotate = true,
		tooltipMog = true,
		gridDress = true,
		noAnim = false,
		minimap = {},
		url = "Battle.net",
		--tooltipWidth = 300,
		--tooltipHeight = 300,
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
		
		--[[mog.tooltip.model:SetUnit("PLAYER");
		mog.tooltip:SetSize(mog.db.profile.tooltipWidth,mog.db.profile.tooltipHeight);
		if mog.db.profile.tooltipRotate then
			mog.tooltip.rotate:Show();
		end--]]
	elseif event == "GET_ITEM_INFO_RECEIVED" then
		local owner = GameTooltip:IsShown() and GameTooltip:GetOwner();
		if owner and owner.MogItModel then
			mog.OnEnter(owner);
		end
		--mog.GET_ITEM_INFO_RECEIVED();
	elseif event == "ADDON_LOADED" then
		if arg1 == MogIt then
			local AceDB = LibStub("AceDB-3.0")
			
			mog.db = AceDB:New("MogItDB", defaults, true)
			
			-- deal with old saved variables
			if MogIt_Global then
				MogIt_Global.wishlist = nil
				for k, v in pairs (MogIt_Global) do
					mog.db.profile[k] = v
				end
				-- MogIt_Global = nil
			end
			
			-- db.RegisterCallback(self, "OnProfileChanged", "LoadSettings")
			-- db.RegisterCallback(self, "OnProfileCopied", "LoadSettings")
			-- db.RegisterCallback(self, "OnProfileReset", "LoadSettings")
			
			if not mog.db.global.version then
				DEFAULT_CHAT_FRAME:AddMessage(L["MogIt has loaded! Type \"/mog\" to open it."]);
			end
			mog.db.global.version = GetAddOnMetadata(MogIt,"Version");
			
			mog.LDBI:Register(MogIt,mog.mmb,mog.db.profile.minimap);
			
			-- fire every module's "init" method (if they have one)
			for name,module in pairs(mog.modules.lookup) do
				if module.AddonLoaded then
					module:AddonLoaded()
				end
			end
		elseif mog.modules.lookup[arg1] then
			--collectgarbage("collect");
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