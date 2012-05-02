local MogIt,mog = ...;
_G["MogIt"] = mog;
local L = mog.L;


mog.frame = CreateFrame("Frame","MogItFrame",UIParent,"ButtonFrameTemplate");
mog.list = {};

function mog:Error(msg)
	DEFAULT_CHAT_FRAME:AddMessage("MogIt: "..msg,0.9,0.5,0.9);
end

function mog.IsDropdownShown(dd)
	return UIDropDownMenu_GetCurrentDropDown() == dd and DropDownList1 and DropDownList1:IsShown();
end


--// Frame Toggle
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
--//


--// LibDataBroker
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
--//


--// Module API
mog.moduleVersion = 1;
mog.modules = {};
mog.moduleList = {};

function mog:GetModule(name)
	return mog.modules[name];
end

function mog:GetActiveModule()
	return mog.active;
end

function mog:RegisterModule(name,version,data)
	if mog.modules[name] then
		mog:Error(L["The \124cFFFFFFFF%s\124r module is already loaded."]:format(name));
		return;
	elseif type(version) ~= "number" or version < mog.moduleVersion then
		mog:Error(L["The \124cFFFFFFFF%s\124r module needs to be updated to work with this version of MogIt."]:format(name));
		return;
	elseif version > mog.moduleVersion then
		mog:Error(L["The \124cFFFFFFFF%s\124r module requires you to update MogIt for it to work."]:format(name));
		return;
	end
	data = data or {};
	data.name = name;
	mog.modules[name] = data;
	table.insert(mog.moduleList,data);
	if mog.menu.active == mog.menu.modules and mog.IsDropdownShown(mog.menu) then
		HideDropDownMenu(1);
		ToggleDropDownMenu(1,data,mog.menu);
	end
	return data;
end

function mog:SetModule(module,text)
	if mog.active and mog.active ~= module and mog.active.UnList then
		mog.active:Unlist(module);
	end
	mog.active = module;
	mog:BuildList(true);
	mog:FilterUpdate();
	mog.frame.path:SetText(text or module.label or module.name or "");
end

local doBuildList
function mog:BuildList(top,module)
	if (module and mog.active and mog.active.name ~= module) then return end;
	mog.list = mog.active and mog.active:BuildList() or {};
	mog:SortList(nil,true);
	mog.scroll:update(top and 1);
	mog.filt.models:SetText(#mog.list);
	doBuildList = false;
end
--//


--// Events
function mog.ItemInfoReceived()
	local owner = GameTooltip:IsShown() and GameTooltip:GetOwner();
	if owner and owner.MogItModel then
		mog.OnEnter(owner);
	end
	if mog.IsDropdownShown(mog.Item_Menu) then
		HideDropDownMenu(1);
		ToggleDropDownMenu(nil,nil,mog.Item_Menu,"cursor",0,0,mog.Item_Menu.menuList);
	elseif mog.IsDropdownShown(mog.Set_Menu) then
		HideDropDownMenu(1);
		ToggleDropDownMenu(nil,nil,mog.Set_Menu,"cursor",0,0,mog.Set_Menu.menuList);
	end
	
	if doBuildList then
		mog.BuildList();
	end
	
	mog.frame:SetScript("OnUpdate", nil);
end


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
		clearOnPreviewSet = false,
		gridDress = "preview",
		noAnim = false,
		minimap = {},
		url = "Battle.net",
		width = 200,
		height = 200,
		rows = 2;
		columns = 3,
	}
}

function mog.LoadSettings()
	mog.updateGUI();
	if mog.db.profile.minimap.hide then
		mog.LDBI:Hide("MogIt");
	else
		mog.LDBI:Show("MogIt");
	end
	if mog.db.profile.tooltipRotate then
		mog.tooltip.rotate:Show();
	else
		mog.tooltip.rotate:Hide();
	end
	mog.scroll:update();
end

mog.frame:SetScript("OnEvent",function(self,event,arg1,...)
	if event == "PLAYER_LOGIN" then
		-- mog.view.model.model:SetUnit("PLAYER");
		mog.updateGUI();
		mog.tooltip.model:SetUnit("PLAYER");
	elseif event == "GET_ITEM_INFO_RECEIVED" then
		doBuildList = true
		self:SetScript("OnUpdate", mog.ItemInfoReceived);
	elseif event == "PLAYER_EQUIPMENT_CHANGED" then
		if mog.db.profile.gridDress == "equipped" then
			mog.scroll:update();
		end
	elseif event == "ADDON_LOADED" then
		if arg1 == MogIt then
			local AceDB = LibStub("AceDB-3.0")
			mog.db = AceDB:New("MogItDB", defaults, true)
			mog.db.RegisterCallback(mog, "OnProfileChanged", "LoadSettings")
			mog.db.RegisterCallback(mog, "OnProfileCopied", "LoadSettings")
			mog.db.RegisterCallback(mog, "OnProfileReset", "LoadSettings")

			if not mog.db.global.version then
				mog:Error(L["MogIt has loaded! Type \"/mog\" to open it."]);
			end
			mog.db.global.version = GetAddOnMetadata(MogIt,"Version");
			
			mog.LDBI:Register("MogIt",mog.mmb,mog.db.profile.minimap);
			
			mog.tooltip:SetSize(mog.db.profile.tooltipWidth,mog.db.profile.tooltipHeight);
			if mog.db.profile.tooltipRotate then
				mog.tooltip.rotate:Show();
			end
			
			for name,module in pairs(mog.moduleList) do
				if module.MogItLoaded then
					module:MogItLoaded()
				end
			end
		elseif mog.modules[arg1] then
			mog.modules[arg1].loaded = true;
			if mog.menu.active == mog.menu.modules and mog.IsDropdownShown(mog.menu) then
				HideDropDownMenu(1);
				ToggleDropDownMenu(1,mog.modules[arg1],mog.menu,mog.menu.modules,0,0);
			end
		elseif arg1 == "AtlasLoot" then
			mog.tooltip.hookAtlasLoot();
		end
	end
end);
mog.frame:RegisterEvent("PLAYER_LOGIN");
mog.frame:RegisterEvent("GET_ITEM_INFO_RECEIVED");
mog.frame:RegisterEvent("ADDON_LOADED");
mog.frame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED");
--//


--// Data API
mog.data = {};

function mog:AddData(data,id,key,value)
	if not mog.data[data] then
		mog.data[data] = {};
	end
	if not mog.data[data][key] then
		mog.data[data][key] = {};
	end
	mog.data[data][key][id] = value;
end

function mog:DeleteData(data,id,key)
	if not mog.data[data] then return end;
	if key then
		if mog.data[data][key] then
			mog.data[data][key][id] = nil;
		end
	else
		for k,v in pairs(mog.data[data]) do
			v[id] = nil;
		end
	end
end

function mog:GetData(data,id,key)
	return mog.data[data] and mog.data[data][key] and mog.data[data][key][id];
end
--//


--// Slot Conversion
mog.slots = {
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

mog.slotsType = {
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

function mog:GetSlot(id)
	return mog.slots[id] or mog.slotsType[id];
end
--//


-- temporary wrapper
function mog.AddMob(id, name)
	mog:AddData("npc", id, "name", name)
end























function mog.GetItemSourceInfo(itemID)
	local source, info;
	local sourceType = mog:GetData("item", itemID, "source");
	local sourceID = mog:GetData("item", itemID, "sourceid");
	local sourceInfo = mog:GetData("item", itemID, "sourceinfo");
	
	if sourceType == 1 and sourceID then -- Drop
		source = mog:GetData("npc", sourceID, "name");
	-- elseif sourceType == 3 then -- Quest
	elseif sourceType == 5 and sourceInfo then -- Crafted
		source = L.professions[sourceInfo];
	elseif sourceType == 6 and sourceID then -- Achievement
		local _, name, _, complete = GetAchievementInfo(sourceID);
		source = name;
		info = complete;
	end
	
	local zone = mog:GetData("item", itemID, "zone");
	if zone then
		zone = GetMapNameByID(zone);
		if zone then
			local diff = L.diffs[sourceInfo];
			if sourceType == 1 and diff then
				zone = format("%s (%s)", zone, diff);
			end
		end
	end
	
	return L.source[sourceType], source, zone, info;
end

function mog.GetItemSourceShort(itemID)
	local sourceType, source, zone, info = mog.GetItemSourceInfo(itemID);
	if zone then
		if source then
			sourceType = source;
		end
		source = zone;
	end
	if source then
		return format("%s (%s)", sourceType, source)
	else
		return sourceType
	end
end