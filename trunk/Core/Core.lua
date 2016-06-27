local MogIt,mog = ...;
_G["MogIt"] = mog;
local L = mog.L;

local ItemInfo = LibStub("LibItemInfo-1.0");

LibStub("Libra"):Embed(mog);

local DataStore_Character;
local BrotherBags_Player;

mog.frame = CreateFrame("Frame","MogItFrame",UIParent,"ButtonFrameTemplate");
mog.list = {};

function mog:Error(msg)
	DEFAULT_CHAT_FRAME:AddMessage("MogIt: "..msg,0.9,0.5,0.9);
end

--// Slash Commands
function mog:ToggleFrame()
	ToggleFrame(mog.frame);
end

function mog:TogglePreview()
	ToggleFrame(mog.view);
end
--//


--// Bindings
SLASH_MOGIT1 = "/mog";
SLASH_MOGIT2 = "/mogit";
SlashCmdList["MOGIT"] = mog.ToggleFrame;

BINDING_HEADER_MogIt = "MogIt";
BINDING_NAME_MogIt = L["Toggle Mogit"];
BINDING_NAME_MogItPreview = L["Toggle Preview"];
--//


--// LibDataBroker
mog.LDBI = LibStub("LibDBIcon-1.0");
mog.mmb = LibStub("LibDataBroker-1.1"):NewDataObject("MogIt",{
	type = "launcher",
	icon = "Interface\\Icons\\INV_Enchant_EssenceCosmicGreater",
	OnClick = function(self,btn)
		if btn == "RightButton" then
			mog:TogglePreview();
		else
			mog:ToggleFrame();
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
mog.moduleVersion = 3;
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
		--mog:Error(L["The \124cFFFFFFFF%s\124r module is already loaded."]:format(name));
		return mog.modules[name];
	--elseif type(version) ~= "number" or version < mog.moduleVersion then
		--mog:Error(L["The \124cFFFFFFFF%s\124r module needs to be updated to work with this version of MogIt."]:format(name));
		--return;
	--elseif version > mog.moduleVersion then
		--mog:Error(L["The \124cFFFFFFFF%s\124r module requires you to update MogIt for it to work."]:format(name));
		--return;
	end
	data = data or {};
	data.version = version;
	data.name = name;
	mog.modules[name] = data;
	table.insert(mog.moduleList,data);
	if mog.menu.active == mog.menu.modules then
		mog.menu:Rebuild(1);
	end
	return data;
end

function mog:SetModule(module,text)
	if mog.active and mog.active ~= module and mog.active.Unlist then
		mog.active:Unlist(module);
	end
	mog.active = module;
	mog:BuildList(true);
	mog:FilterUpdate();
	mog.frame.path:SetText(text or module.label or module.name or "");
end

function mog:BuildList(top,module)
	if (module and mog.active and mog.active.name ~= module) then return end;
	mog.list = mog.active and mog.active.BuildList and mog.active:BuildList() or {};
	mog:SortList(nil,true);
	mog:UpdateScroll(top and 1);
	mog.filt.models:SetText(#mog.list);
end
--//


--// Item Cache
local itemCacheCallbacks = {
	BuildList = mog.BuildList;
	ModelOnEnter = function()
		local owner = GameTooltip:GetOwner();
		if owner and GameTooltip[mog] then
			owner:OnEnter();
		end
	end,
	ItemMenu = function()
		mog.Item_Menu:Rebuild(1);
	end,
	SetMenu = function()
		mog.Set_Menu:Rebuild(1);
	end,
};

local pendingCallbacks = {};

for k in pairs(itemCacheCallbacks) do
	pendingCallbacks[k] = {};
end

function mog:AddItemCacheCallback(name, func)
	itemCacheCallbacks[name] = func;
	pendingCallbacks[name] = {};
end

function mog:GetItemInfo(id, callback)
	if not callback then return ItemInfo[id] end
	if ItemInfo[id] then
		-- clear pending items when they are cached
		pendingCallbacks[callback][id] = nil;
		return ItemInfo[id];
	elseif itemCacheCallbacks[callback] then
		-- add to pending items for this callback if not cached
		pendingCallbacks[callback][id] = true;
	end
end

function mog.ItemInfoReceived()
	for k, callback in pairs(pendingCallbacks) do
		-- execute the callback if any items are pending for it
		if next(callback) then
			itemCacheCallbacks[k]();
		end
	end
end

ItemInfo.RegisterCallback(mog, "OnItemInfoReceivedBatch", "ItemInfoReceived");
--//

local characters;
local addedCharacters = {};

function mog:HasItem(itemID, includeAlternate, isAlternate)
	local found = false;
	if not isAlternate then
		characters = {};
	end
	itemID = self:ToNumberItem(itemID);
	if includeAlternate and not isAlternate then
		addedCharacters = {};
		local found = mog:HasItem(itemID);
		local itemIDs = mog:GetData("display", mog:GetData("item", mog:ToStringItem(itemID), "display"), "items");
		if itemIDs then
			local baseItem = mog:ToStringItem(itemID);
			for i, alternateItem in ipairs(itemIDs) do
				if alternateItem ~= baseItem and mog:HasItem(alternateItem, false, true) then
					found = true;
				end
			end
		end
		return found, characters;
	end
	if self.db.profile.ownedCheckAlts then
		if DataStore then
			for account in pairs(DataStore:GetAccounts()) do
				for realm in pairs(DataStore:GetRealms(account)) do
					for k, character in pairs(DataStore:GetCharacters(realm, account)) do
						if not isAlternate or not addedCharacters[character] then
							local inventoryCount = DataStore:GetInventoryItemCount(character, itemID);
							local bagCount, bankCount, voidCount = DataStore:GetContainerItemCount(character, itemID);
							local mailCount = DataStore:GetMailItemCount(character, itemID);
							if ((inventoryCount or 0) + (bagCount or 0) + (bankCount or 0) + (voidCount or 0) + (mailCount or 0)) > 0 then
								found = true;
								local accountKey, realmKey, charKey = strsplit(".", character);
								tinsert(characters, Ambiguate(charKey.."-"..realmKey:gsub(" ", "")..(isAlternate and " (*)" or ""), "none"));
								addedCharacters[character] = true;
							end
						end
					end
				end
			end
			return found, characters;
		end
	end
	-- GetItemCount does not take void storage into account...
	if GetItemCount(itemID, true) > 0 then
		return true;
	end
	-- ...try third party data for that
	if DataStore_Containers then
		local _, _, count = DataStore:GetContainerItemCount(DataStore_Character, itemID);
		if count > 0 then
			return true;
		end
	end
	if BrotherBags_Player and BrotherBags_Player.vault then
		for _, item in pairs(BrotherBags_Player.vault) do
			if tonumber(item) == itemID then
				return true;
			end
		end
	end
end


--// Events
local defaults = {
	profile = {
		tooltipItemID = false,
		tooltipAlwaysShowOwned = true,
		ownedCheckAlts = true,
		tooltipOwnedDetail = true,
		wishlistCheckAlts = true,
		tooltipWishlistDetail = true,
		loadModulesDefault = false,
		
		noAnim = false,
		url = "Battle.net",
		
		dressupPreview = false,
		singlePreview = false,
		previewUIPanel = false,
		previewFixedSize = false,
		previewConfirmClose = true,
		
		sortWishlist = false,
		loadModulesWishlist = false,
		
		tooltip = true,
		tooltipWidth = 300,
		tooltipHeight = 300,
		tooltipMouse = false,
		tooltipDress = false,
		tooltipRotate = true,
		tooltipMog = true,
		tooltipMod = "None",
		tooltipCustomModel = false,
		tooltipRace = 1,
		tooltipGender = 0,
		
		minimap = {},
		
		point = "CENTER",
		gridWidth = 600,
		gridHeight = 400,
		rows = 2;
		columns = 3,
		gridDress = "preview",
		sync = true,
		previewProps = {
			["*"] = {
				w = 335,
				h = 385,
				point = "CENTER",
			}
		},
	}
}

function mog.LoadSettings()
	mog:UpdateGUI();
	
	if mog.db.profile.minimap.hide then
		mog.LDBI:Hide("MogIt");
	else
		mog.LDBI:Show("MogIt");
	end
	
	mog.tooltip:SetSize(mog.db.profile.tooltipWidth, mog.db.profile.tooltipHeight);
	mog.tooltip.rotate:SetShown(mog.db.profile.tooltipRotate);
	
	mog:UpdateScroll();
	
	mog:SetSinglePreview(mog.db.profile.singlePreview);
end

function mog:LoadBaseModules()
	for i, module in ipairs(self.baseModules) do
		if GetAddOnEnableState(myName, module) > 0 and not IsAddOnLoaded(module) then
			LoadAddOn(module)
		end
	end
end

mog.frame:RegisterEvent("ADDON_LOADED");
mog.frame:RegisterEvent("PLAYER_LOGIN");
mog.frame:RegisterEvent("GET_ITEM_INFO_RECEIVED");
mog.frame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED");
mog.frame:SetScript("OnEvent", function(self, event, ...)
	return mog[event] and mog[event](mog, ...)
end);

function mog:ADDON_LOADED(addon)
	if addon == MogIt then
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
		
		
		for name,module in pairs(mog.moduleList) do
			if module.MogItLoaded then
				module:MogItLoaded()
			end
		end

		if mog.db.profile.loadModulesDefault then
			mog:LoadBaseModules()
		end
	elseif mog.modules[addon] then
		mog.modules[addon].loaded = true;
		if mog.menu.active == mog.menu.modules then
			mog.menu:Rebuild(1)
		end
	end
end

function mog:PLAYER_LOGIN()
	DataStore_Character = DataStore and DataStore:GetCharacter();
	BrotherBags_Player = BrotherBags and BrotherBags[GetRealmName()][UnitName("player")];
	
	C_Timer.After(1, function()
		-- this function doesn't yield correct results immediately, so we delay it
		for slot, v in pairs(mog.mogSlots) do
			local isTransmogrified, _, _, _, _, visibleItemID = GetTransmogrifySlotInfo(slot);
			if isTransmogrified then
				mog:GetItemInfo(visibleItemID);
			end
		end
	end)
	
	mog:LoadSettings();
	self.frame:SetScript("OnSizeChanged", function(self, width, height)
		mog.db.profile.gridWidth = width;
		mog.db.profile.gridHeight = height;
		mog:UpdateGUI(true);
	end)
end

function mog:PLAYER_EQUIPMENT_CHANGED(slot, hasItem)
	local slotName = mog.mogSlots[slot];
	local itemID, itemAppearanceModID = GetInventoryItemID("player", slot);
	if slotName then
		local isTransmogrified, _, _, _, _, visibleItemID, _, visibleItemAppearanceModID = GetTransmogrifySlotInfo(slot);
		if isTransmogrified then
			mog:GetItemInfo(visibleItemID);
			itemID = visibleItemID;
			itemAppearanceModID = visibleItemAppearanceModID;
		end
	end
	-- don't do anything if the slot is not visible (necklace, ring, trinket)
	if mog.db.profile.gridDress == "equipped" then
		for i, frame in ipairs(mog.models) do
			if frame.data.item then
				if hasItem then
					if (slot ~= INVSLOT_HEAD or ShowingHelm()) and (slot ~= INVSLOT_BACK or ShowingCloak()) then
						frame:TryOn(itemID, slotName, itemAppearanceModID);
					end
				else
					frame:UndressSlot(slot);
				end
				frame:TryOn(frame.data.item);
			end
		end
	end
end
--//


--// Data API
mog.data = {};

function mog:AddData(data, id, key, value)
	if not (data and id and key) then return end;
	
	--if data == "item" then
	--	id = mog:ItemToString(id);
	--end
	
	if not mog.data[data] then
		mog.data[data] = {};
	end
	if not mog.data[data][key] then
		mog.data[data][key] = {};
	end
	mog.data[data][key][id] = value;
	return value;
end

function mog:DeleteData(data, id, key)
	if not mog.data[data] then return end;
	if id and key then
		mog.data[data][key][id] = nil;
	elseif id then
		for k,v in pairs(mog.data[data]) do
			v[id] = nil;
		end
	elseif key then
		mog.data[data][key] = nil;
	else
		mog.data[data] = nil;
	end
end

function mog:GetData(data, id, key)
	return mog.data[data] and mog.data[data][key] and mog.data[data][key][id];
end

mog.itemStringShort = "item:%d:0";
mog.itemStringLong = "item:%d:0:0:0:0:0:0:0:0:0:0:0:1:%d";

function mog:ToStringItem(id, bonus)
	-- itemID, enchantID, instanceDifficulty, numBonusIDs, bonusID1
	if bonus and bonus ~= 0 then
		return format(mog.itemStringLong, id, bonus);
	else
		return format(mog.itemStringShort, id);
	end
end

local bonusDiffs = {
	-- MoP
	[451] = true, -- Raid Finder
	[449] = true, -- Heroic (Raid)
	[450] = true, -- Mythic (Raid)
	-- WoD
	[518] = true, -- dungeon-level-up-1
	[519] = true, -- dungeon-level-up-2
	[520] = true, -- dungeon-level-up-3
	[521] = true, -- dungeon-level-up-4
	[522] = true, -- dungeon-normal
	[524] = true, -- dungeon-heroic
	[525] = true, -- trade-skill (tier 1)
	[526] = true, -- trade-skill (armor tier 2)
	[527] = true, -- trade-skill (armor tier 3)
	[558] = true, -- trade-skill (weapon tier 2)
	[559] = true, -- trade-skill (weapon tier 3)
	[566] = true, -- raid-heroic
	[567] = true, -- raid-mythic
	[593] = true, -- trade-skill (armor tier 4)
	[594] = true, -- trade-skill (weapon tier 4)
	[615] = true, -- timewalker
	[617] = true, -- trade-skill (armor tier 5)
	[618] = true, -- trade-skill (armor tier 6)
	[619] = true, -- trade-skill (weapon tier 5)
	[620] = true, -- trade-skill (weapon tier 6)
	[642] = true, -- dungeon-mythic
	[648] = true, -- baleful (675)
	[651] = true, -- baleful empowered (695)
};

mog.itemStringPattern = "item:(%d+):%d+:%d+:%d+:%d+:%d+:%d+:%d+:%d+:%d+:%d+:%d+:%d+:([%d:]+)";

function mog:ToNumberItem(item)
	if type(item) == "string" then
		local id, bonus = item:match(mog.itemStringPattern);
		-- bonus ID can also be warforged, socketed, etc
		-- if there is more than one bonus ID, need to check all
		if bonus then
			if not tonumber(bonus) then
				for bonusID in gmatch(bonus, "%d+") do
					if bonusDiffs[tonumber(bonusID)] then
						bonus = bonusID;
						break;
					end
				end
			elseif not bonusDiffs[tonumber(bonus)] then
				bonus = nil;
			end
		end
		id = id or item:match("item:(%d+)");
		return tonumber(id), tonumber(bonus);
	elseif type(item) == "number" then
		return item;
	end
end

function mog:NormaliseItemString(item)
	return self:ToStringItem(self:ToNumberItem(item));
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
};

mog.slotsType = {
	INVTYPE_HEAD = "HeadSlot",
	INVTYPE_SHOULDER = "ShoulderSlot",
	INVTYPE_CLOAK = "BackSlot",
	INVTYPE_CHEST = "ChestSlot",
	INVTYPE_ROBE = "ChestSlot",
	INVTYPE_BODY = "ShirtSlot",
	INVTYPE_TABARD = "TabardSlot",
	INVTYPE_WRIST = "WristSlot",
	INVTYPE_HAND = "HandsSlot",
	INVTYPE_WAIST = "WaistSlot",
	INVTYPE_LEGS = "LegsSlot",
	INVTYPE_FEET = "FeetSlot",
	INVTYPE_2HWEAPON = "MainHandSlot",
	INVTYPE_WEAPON = "MainHandSlot",
	INVTYPE_WEAPONMAINHAND = "MainHandSlot",
	INVTYPE_WEAPONOFFHAND = "SecondaryHandSlot",
	INVTYPE_RANGED = "MainHandSlot",
	INVTYPE_RANGEDRIGHT = "MainHandSlot",
	INVTYPE_SHIELD = "SecondaryHandSlot",
	INVTYPE_HOLDABLE = "SecondaryHandSlot",
};

-- all slot IDs that can be transmogrified
mog.mogSlots = {
	[INVSLOT_HEAD] = "HeadSlot",
	[INVSLOT_SHOULDER] = "ShoulderSlot",
	[INVSLOT_BACK] = "BackSlot",
	[INVSLOT_CHEST] = "ChestSlot",
	[INVSLOT_WRIST] = "WristSlot",
	[INVSLOT_HAND] = "HandsSlot",
	[INVSLOT_WAIST] = "WaistSlot",
	[INVSLOT_LEGS] = "LegsSlot",
	[INVSLOT_FEET] = "FeetSlot",
	[INVSLOT_MAINHAND] = "MainHandSlot",
	[INVSLOT_OFFHAND] = "SecondaryHandSlot",
}

function mog:GetSlot(id)
	return mog.slots[id] or mog.slotsType[id];
end
--//