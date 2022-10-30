local MogIt,mog = ...;
_G["MogIt"] = mog;
local L = mog.L;

local ItemInfo = LibStub("LibItemInfo-1.0");

LibStub("Libra"):Embed(mog);

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

local sourceItemLink = {}

function mog:GetItemLinkFromSource(source)
	if not sourceItemLink[source] then
		local _, _, _, _, _, link = C_TransmogCollection.GetAppearanceSourceInfo(source)
		sourceItemLink[source] = link
	end
	return sourceItemLink[source]
end

local itemSourceID = {}

local model = CreateFrame("DressUpModel")
model:SetAutoDress(false)

function mog:GetSourceFromItem(item)
	if not itemSourceID[item] then
		local visualID, sourceID = C_TransmogCollection.GetItemInfo(item)
		itemSourceID[item] = sourceID
		if not itemSourceID[item] then
			model:SetUnit("player")
			model:Undress()
			model:TryOn(item)
			for i = 1, 19 do
				local itemTransmogInfo = model:GetItemTransmogInfo(i)
				local appearanceID = itemTransmogInfo and itemTransmogInfo.appearanceID or Constants.Transmog.NoTransmogID
				if appearanceID ~= Constants.Transmog.NoTransmogID then
					itemSourceID[item] = appearanceID
					break
				end
			end
		end
	end
	return itemSourceID[item]
end

function mog:HasItem(sourceID, includeAlternate)
	if not sourceID then return end
	local found = false;
	local sourceInfo = C_TransmogCollection.GetSourceInfo(sourceID)
	if not sourceInfo then return end
	found = sourceInfo.isCollected
	if includeAlternate then
		local _, _, _, _, _, itemClassID, itemSubclassID = GetItemInfoInstant(sourceInfo.itemID);
		local sources = C_TransmogCollection.GetAllAppearanceSources(sourceInfo.visualID)
		for i, sourceID in ipairs(sources) do
			local sourceInfo = C_TransmogCollection.GetSourceInfo(sourceID)
			local _, _, _, _, _, itemClassID2, itemSubclassID2 = GetItemInfoInstant(sourceInfo.itemID);
			if itemSubclassID2 == itemSubclassID and sourceInfo.isCollected then
				found = true
				break
			end
		end
	end
	return found
end


--// Events
local defaults = {
	profile = {
		tooltipItemID = false,
		alwaysShowCollected = true,
		tooltipAlwaysShowOwned = true,
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
		tooltipAnchor = "vertical",
		
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
		
		slotLabels = {},
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
mog.frame:RegisterEvent("TRANSMOG_SEARCH_UPDATED");
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
		
		SetCVar("missingTransmogSourceInItemTooltips", mog.db.profile.alwaysShowCollected)

		if mog.db.profile.loadModulesDefault then
			mog:LoadBaseModules()
		end
	elseif mog.modules[addon] then
		mog:LoadDB(addon)
		mog.modules[addon].loaded = true;
		if mog.menu.active == mog.menu.modules then
			mog.menu:Rebuild(1)
		end
	elseif addon == "Blizzard_Collections" then
		for i, model in ipairs(WardrobeCollectionFrame.ItemsCollectionFrame.Models) do
			model:SetScript("OnMouseDown", function(self, button)
				if IsControlKeyDown() and button == "RightButton" then
					local link
					local sources = WardrobeCollectionFrame_GetSortedAppearanceSources(self.visualInfo.visualID)
					if WardrobeCollectionFrame.tooltipSourceIndex then
						local index = WardrobeUtils_GetValidIndexForNumSources(WardrobeCollectionFrame.tooltipSourceIndex, #sources)
						link = select(6, C_TransmogCollection.GetAppearanceSourceInfo(sources[index].sourceID))
					end
					mog:AddToPreview(link)
					return
				end
				self:OnMouseDown(button)
			end)
		end
		local orig_OnMouseUp = WardrobeCollectionFrame.SetsCollectionFrame.ScrollFrame.buttons[1]:GetScript("OnMouseUp")
		for i, button in ipairs(WardrobeCollectionFrame.SetsCollectionFrame.ScrollFrame.buttons) do
			button:SetScript("OnMouseUp", function(self, button)
				if IsControlKeyDown() and button == "RightButton" then
					local preview = mog:GetPreview()
					for source in pairs(C_TransmogSets.GetSetSources(self.setID)) do
						mog:AddToPreview(select(6, C_TransmogCollection.GetAppearanceSourceInfo(source)), preview)
					end
					return
				end
				orig_OnMouseUp(self, button)
			end)
		end
		-- WardrobeCollectionFrame.SetsCollectionFrame.DetailsFrame.itemFramesPool.resetterFunc = function(self, obj) obj:RegisterForDrag("LeftButton", "RightButton") end
	end
end


local SLOTS = {
	[Enum.TransmogCollectionType["Head"]] = "Head",
	[Enum.TransmogCollectionType["Shoulder"]] = "Shoulder",
	[Enum.TransmogCollectionType["Back"]] = "Back",
	[Enum.TransmogCollectionType["Chest"]] = "Chest",
	[Enum.TransmogCollectionType["Shirt"]] = "Shirt",
	[Enum.TransmogCollectionType["Tabard"]] = "Tabard",
	[Enum.TransmogCollectionType["Wrist"]] = "Wrist",
	[Enum.TransmogCollectionType["Hands"]] = "Hands",
	[Enum.TransmogCollectionType["Waist"]] = "Waist",
	[Enum.TransmogCollectionType["Legs"]] = "Legs",
	[Enum.TransmogCollectionType["Feet"]] = "Feet",
	[Enum.TransmogCollectionType["Wand"]] = "Wand",
	[Enum.TransmogCollectionType["OneHAxe"]] = "1H-axe",
	[Enum.TransmogCollectionType["OneHSword"]] = "1H-sword",
	[Enum.TransmogCollectionType["OneHMace"]] = "1H-mace",
	[Enum.TransmogCollectionType["Dagger"]] = "Dagger",
	[Enum.TransmogCollectionType["Fist"]] = "Fist",
	[Enum.TransmogCollectionType["Shield"]] = "Shield",
	[Enum.TransmogCollectionType["Holdable"]] = "Holdable",
	[Enum.TransmogCollectionType["TwoHAxe"]] = "2H-axe",
	[Enum.TransmogCollectionType["TwoHSword"]] = "2H-sword",
	[Enum.TransmogCollectionType["TwoHMace"]] = "2H-mace",
	[Enum.TransmogCollectionType["Staff"]] = "Staff",
	[Enum.TransmogCollectionType["Polearm"]] = "Polearm",
	[Enum.TransmogCollectionType["Bow"]] = "Bow",
	[Enum.TransmogCollectionType["Gun"]] = "Gun",
	[Enum.TransmogCollectionType["Crossbow"]] = "Crossbow",
	[Enum.TransmogCollectionType["Warglaives"]] = "Warglaives",
	[Enum.TransmogCollectionType["Paired"]] = "ArtifactLegion",
}

local SLOT_MODULES = {
	[Enum.TransmogCollectionType["Back"]] = "Other",
	[Enum.TransmogCollectionType["Shirt"]] = "Other",
	[Enum.TransmogCollectionType["Tabard"]] = "Other",
	[Enum.TransmogCollectionType["Wand"]] = "Ranged",
	[Enum.TransmogCollectionType["OneHAxe"]] = "OneHanded",
	[Enum.TransmogCollectionType["OneHSword"]] = "OneHanded",
	[Enum.TransmogCollectionType["OneHMace"]] = "OneHanded",
	[Enum.TransmogCollectionType["Dagger"]] = "OneHanded",
	[Enum.TransmogCollectionType["Fist"]] = "OneHanded",
	[Enum.TransmogCollectionType["Shield"]] = "Other",
	[Enum.TransmogCollectionType["Holdable"]] = "Other",
	[Enum.TransmogCollectionType["TwoHAxe"]] = "TwoHanded",
	[Enum.TransmogCollectionType["TwoHSword"]] = "TwoHanded",
	[Enum.TransmogCollectionType["TwoHMace"]] = "TwoHanded",
	[Enum.TransmogCollectionType["Staff"]] = "TwoHanded",
	[Enum.TransmogCollectionType["Polearm"]] = "TwoHanded",
	[Enum.TransmogCollectionType["Bow"]] = "Ranged",
	[Enum.TransmogCollectionType["Gun"]] = "Ranged",
	[Enum.TransmogCollectionType["Crossbow"]] = "Ranged",
	[Enum.TransmogCollectionType["Warglaives"]] = "OneHanded",
	[Enum.TransmogCollectionType["Paired"]] = "Artifact",
}

mog.relevantCategories = {}

function mog:TRANSMOG_SEARCH_UPDATED()
	-- local t = debugprofilestop()
	
	local ARMOR_CLASSES = {
		WARRIOR = "Plate",
		DEATHKNIGHT = "Plate",
		PALADIN = "Plate",
		MONK = "Leather",
		PRIEST = "Cloth",
		SHAMAN = "Mail",
		DRUID = "Leather",
		ROGUE = "Leather",
		MAGE = "Cloth",
		WARLOCK = "Cloth",
		HUNTER = "Mail",
		DEMONHUNTER = "Leather",
	}
	
	local FACTIONS = {
		["Alliance"] = 1,
		["Horde"] = 2,
		-- hack for neutral pandaren, the items they can see are for both factions
		["Neutral"] = 3,
	}
	
	local _, playerClass = UnitClass("player")
	local faction = UnitFactionGroup("player")
	
	local armorClass = ARMOR_CLASSES[playerClass]
	
	mog.relevantCategories[armorClass] = true
	
	LoadAddOn("MogIt_"..armorClass)
	LoadAddOn("MogIt_Other")
	LoadAddOn("MogIt_OneHanded")
	LoadAddOn("MogIt_TwoHanded")
	LoadAddOn("MogIt_Ranged")
	LoadAddOn("MogIt_Artifact")
	
	local ArmorDB = _G["MogIt_"..armorClass.."DB"] or {}
	MogIt_OtherDB = MogIt_OtherDB or {}
	MogIt_OneHandedDB = MogIt_OneHandedDB or {}
	MogIt_TwoHandedDB = MogIt_TwoHandedDB or {}
	MogIt_RangedDB = MogIt_RangedDB or {}
	MogIt_ArtifactDB = MogIt_ArtifactDB or {}
	
	_G["MogIt_"..armorClass.."DB"] = ArmorDB
	
	local GetAppearanceSources = C_TransmogCollection.GetAppearanceSources
	local GetAppearanceSourceDrops = C_TransmogCollection.GetAppearanceSourceDrops
	local bor = bit.bor

	for categoryType = Enum.TransmogCollectionTypeMeta.MinValue, Enum.TransmogCollectionTypeMeta.MaxValue do
		local name, isWeapon, canEnchant, canMainHand, canOffHand = C_TransmogCollection.GetCategoryInfo(categoryType)
		if name then
			name = SLOTS[categoryType]
			local db = db
			if isWeapon then
				mog.relevantCategories[name] = true
			end
			if SLOT_MODULES[categoryType] then
				db = _G["MogIt_"..SLOT_MODULES[categoryType].."DB"]
			else
				db = ArmorDB
			end
			db[name] = db[name] or {}
			local transmogLocation = TransmogUtil.GetTransmogLocation(1, Enum.TransmogType.Appearance, Enum.TransmogModification.Main)
			for i, appearance in ipairs(C_TransmogCollection.GetCategoryAppearances(categoryType, transmogLocation)) do
				if not appearance.isHideVisual then
					local v = db[name][appearance.visualID] or {}
					db[name][appearance.visualID] = v
					if v[1] and v[1].sourceID then
						db[name][appearance.visualID] = {}
					end
					for i, source in ipairs(GetAppearanceSources(appearance.visualID, categoryType, transmogLocation)) do
						local s = v[source.sourceID] or {}
						v[source.sourceID] = s
						s.sourceType = source.sourceType
						s.drops = GetAppearanceSourceDrops(source.sourceID)
						s.classes = bor(s.classes or 0, L.classBits[playerClass])
						s.faction = bor(s.faction or 0, FACTIONS[faction])
					end
				end
			end
		end
	end
	
	self:LoadDB("MogIt_"..armorClass)
	self:LoadDB("MogIt_Other")
	self:LoadDB("MogIt_OneHanded")
	self:LoadDB("MogIt_TwoHanded")
	self:LoadDB("MogIt_Ranged")
	self:LoadDB("MogIt_Artifact")
	
	self.frame:UnregisterEvent("TRANSMOG_SEARCH_UPDATED")
	
	-- print(format("MogIt modules loaded in %d ms.", debugprofilestop() - t))
end


function mog:LoadDB(addon)
	if not IsAddOnLoaded(addon) then return end
	local SOURCE_TYPES = {
		[1] = 1,
		[2] = 3,
		[3] = 4,
		[4] = 1,
		[5] = 6,
		[6] = 5,
	}
	
	local module = mog:GetModule(addon)
	local moduleDB = _G[addon.."DB"]
	
	-- won't exist if module was never loaded
	if not moduleDB then return end
	
	for slot, appearances in pairs(moduleDB) do
		local list = {}
		module.slots[slot] = {
			label = slot,
			list = list,
		}
		wipe(module.slotList)
		for visualID, appearance in pairs(appearances) do
			for sourceID, source in pairs(appearance) do
				local id = source.sourceID or sourceID
				tinsert(list, id)
				mog:AddData("item", id, "display", visualID)
				-- mog:AddData("item", id, "level", lvl)
				mog:AddData("item", id, "faction", source.faction)
				mog:AddData("item", id, "class", source.classes)
				mog:AddData("item", id, "source", SOURCE_TYPES[source.sourceType])
				-- mog:AddData("item", id, "sourceid", sourceid)
				mog:AddData("item", id, "sourceinfo", source.drops)
				-- mog:AddData("item", id, "zone", zone)
			end
		end
	end
	
	for i = 1, Enum.TransmogCollectionTypeMeta.NumValues do
		local slotID = SLOTS[i]
		if moduleDB[slotID] then
			tinsert(module.slotList, slotID)
		end
	end
end


function mog:TRANSMOG_COLLECTION_SOURCE_ADDED(sourceID)
end


function mog:PLAYER_LOGIN()
	--[[
	C_Timer.After(1, function()
		-- this function doesn't yield correct results immediately, so we delay it
		for slot, v in pairs(mog.mogSlots) do
			local isTransmogrified, _, _, _, _, _, _, visibleItemID = C_Transmog.GetSlotInfo(slot, Enum.TransmogType.Appearance);
			if isTransmogrified then
				-- we need an item ID here if we still need to cache these at all
				-- mog:GetItemInfo(visibleItemID);
			end
		end
	end)
	]]
	
	for k, slot in pairs(SLOTS) do
		local name = C_TransmogCollection.GetCategoryInfo(k)
		if name then
			mog.db.profile.slotLabels[slot] = name
		end
	end
	
	mog:LoadSettings();
	self.frame:SetScript("OnSizeChanged", function(self, width, height)
		mog.db.profile.gridWidth = width;
		mog.db.profile.gridHeight = height;
		mog:UpdateGUI(true);
	end)
end

function mog:PLAYER_EQUIPMENT_CHANGED(slot)
	local slotName = mog.mogSlots[slot];
	local item = GetInventoryItemLink("player", slot);
	if slotName then
		local transmogLocation = TransmogUtil.GetTransmogLocation(slot, Enum.TransmogType.Appearance, Enum.TransmogModification.Main);
		local baseSourceID, baseVisualID, appliedSourceID, appliedVisualID = C_Transmog.GetSlotVisualInfo(transmogLocation);
		local isTransmogrified, _, _, _, _, _, isHideVisual, texture = C_Transmog.GetSlotInfo(transmogLocation);
		if isTransmogrified then
			-- we need an item ID here if we still need to cache these at all
			-- mog:GetItemInfo(visibleItemID);
			item = appliedSourceID;
			itemAppearanceModID = visibleItemAppearanceModID;
		end
	end
	-- don't do anything if the slot is not visible (necklace, ring, trinket)
	if mog.db.profile.gridDress == "equipped" then
		for i, frame in ipairs(mog.models) do
			if frame.data.item then
				if item then
					frame:TryOn(item, slotName, itemAppearanceModID);
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
mog.itemStringLong = "item:%d:0::::::::::%d:1:%d";

function mog:ToStringItem(id, bonus, diff)
	-- itemID, enchantID, instanceDifficulty, numBonusIDs, bonusID1
	if (bonus and bonus ~= 0) or (diff and diff ~= 0) then
		return format(mog.itemStringLong, id, diff or 0, bonus or 0);
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
	[1798] = true, -- ???
	[1799] = true, -- ???
	[1805] = true, -- raid-heroic
	[1806] = true, -- raid-mythic
	[3379] = true, -- ???
	[3444] = true, -- ???
	[3445] = true, -- ???
	[3446] = true, -- Raid Finder
	[3452] = true, -- Mythic
	[3453] = true, -- Mythic
	[3454] = true, -- Mythic
	[3468] = true, -- Heroic
	[3469] = true, -- Mythic
	[3470] = true, -- Raid Finder
	[3504] = true, -- Heroic
	[3505] = true, -- Raid Finder
	[3507] = true, -- Heroic
	[3508] = true, -- Mythic
	[3516] = true, -- Heroic
	[3517] = true, -- Heroic
	[3518] = true, -- Mythic
	[3519] = true, -- Mythic
	[3520] = true, -- Raid Finder
	[3521] = true, -- Raid Finder
	[3562] = true, -- Heroic
	[3563] = true, -- Mythic
	[3564] = true, -- Raid Finder
	[3611] = true, -- Heroic
	[3612] = true, -- Mythic
	[3613] = true, -- Raid Finder
	[4194] = true, -- Heroic
	[4196] = true, -- Heroic
	[4198] = true, -- Heroic
	[4200] = true, -- Heroic
	[4201] = true, -- Heroic
	[4202] = true, -- Heroic
	[4204] = true, -- Mythic
	[4236] = true, -- Heroic
	[4237] = true, -- Heroic
	[4536] = true, -- Heroic
	[4739] = true, -- Heroic
	[4740] = true, -- Heroic
	[4752] = true, -- Heroic
	[4753] = true, -- Heroic
	[4778] = true, -- Heroic
	[4779] = true, -- Mythic
	[4799] = true, -- Heroic
	[4800] = true, -- Mythic
	[4801] = true, -- Raid Finder
	[4818] = true, -- Heroic
	[4819] = true, -- Mythic
	[4823] = true, -- Heroic
	[4824] = true, -- Mythic
	[4825] = true, -- Raid Finder
	[4988] = true, -- Duelist
	[4989] = true, -- Elite
	[5000] = true, -- Duelist
	[5001] = true, -- Duelist
	[5003] = true, -- Elite
	[5004] = true, -- Elite
	[5077] = true, -- Duelist
	[5078] = true, -- Duelist
	[5079] = true, -- Duelist
	[5080] = true, -- Elite
	[5081] = true, -- Elite
	[5082] = true, -- Elite
	[5084] = true, -- Elite
	[5085] = true, -- Duelist
	[5090] = true, -- Elite
	[5091] = true, -- Duelist
	[5096] = true, -- Elite
	[5097] = true, -- Duelist
	[5102] = true, -- Elite
	[5103] = true, -- Duelist
	[5119] = true, -- Heroic
	[5120] = true, -- Heroic
	[5193] = true, -- Duelist
	[5194] = true, -- Duelist
	[5198] = true, -- Elite
	[5199] = true, -- Elite
	[5223] = true, -- Duelist
	[5228] = true, -- Elite
	[5272] = true, -- Duelist
	[5273] = true, -- Duelist
	[5274] = true, -- Duelist
	[5275] = true, -- Elite
	[5276] = true, -- Elite
	[5277] = true, -- Elite
	[5281] = true, -- Duelist
	[5282] = true, -- Elite
	[5295] = true, -- Duelist
	[5296] = true, -- Duelist
	[5297] = true, -- Duelist
	[5298] = true, -- Duelist
	[5299] = true, -- Elite
	[5300] = true, -- Elite
	[5301] = true, -- Elite
	[5302] = true, -- Elite
	[5322] = true, -- Duelist
	[5323] = true, -- Duelist
	[5324] = true, -- Duelist
	[5325] = true, -- Duelist
	[5326] = true, -- Elite
	[5327] = true, -- Elite
	[5328] = true, -- Elite
	[5329] = true, -- Elite
	[5352] = true, -- Duelist
	[5353] = true, -- Elite
	[5370] = true, -- Duelist
	[5371] = true, -- Elite
	[5456] = true, -- Duelist
	[5457] = true, -- Elite
	[5461] = true, -- Duelist
	[5462] = true, -- Elite
	[5478] = true, -- Heroic
	[5479] = true, -- Heroic
	[5835] = true, -- Duelist
	[5838] = true, -- Duelist
	[5839] = true, -- Elite
	[5842] = true, -- Elite
	[5844] = true, -- Heroic
	[5845] = true, -- Heroic
	[6337] = true, -- Duelist
	[6338] = true, -- Duelist
	[6341] = true, -- Elite
	[6344] = true, -- Elite
	[6374] = true, -- Duelist
	[6375] = true, -- Duelist
	[6376] = true, -- Elite
	[6378] = true, -- Elite
	[6379] = true, -- Duelist
	[6380] = true, -- Duelist
	[6381] = true, -- Elite
	[6382] = true, -- Elite
	[6522] = true, -- Duelist
	[6523] = true, -- Elite
	[6621] = true, -- Duelist
	[6622] = true, -- Elite
	[6623] = true, -- Duelist
	[6624] = true, -- Elite
	[6634] = true, -- Duelist
	[6635] = true, -- Elite
	[6642] = true, -- Duelist
	[6643] = true, -- Elite
	[7135] = true, -- Duelist
	[7136] = true, -- Elite
	[7142] = true, -- Duelist
	[7143] = true, -- Elite
	[7229] = true, -- Duelist
	[7230] = true, -- Elite
	[7309] = true, -- Duelist
	[7310] = true, -- Elite
	[7315] = true, -- Duelist
	[7316] = true, -- Elite
	[7321] = true, -- Duelist
	[7322] = true, -- Elite
	[7327] = true, -- Duelist
	[7328] = true, -- Elite
	[7333] = true, -- Duelist
	[7334] = true, -- Elite
	[7339] = true, -- Duelist
	[7340] = true, -- Elite
	[7345] = true, -- Duelist
	[7346] = true, -- Elite
	[7459] = true, -- Mythic
	[7532] = true, -- Elite
	[7533] = true, -- Duelist
	[7538] = true, -- Elite
	[7539] = true, -- Duelist
	[7544] = true, -- Elite
	[7545] = true, -- Duelist
	[7550] = true, -- Elite
	[7551] = true, -- Duelist
	[7556] = true, -- Elite
	[7557] = true, -- Duelist
	[7562] = true, -- Elite
	[7563] = true, -- Duelist
	[7568] = true, -- Elite
	[7569] = true, -- Duelist
	[7749] = true, -- Mythic
	[7897] = true, -- Challenger I
	[8343] = true, -- Elite
	[8344] = true, -- Duelist
	[8349] = true, -- Elite
	[8350] = true, -- Duelist
	[8355] = true, -- Elite
	[8356] = true, -- Duelist
	[8361] = true, -- Elite
	[8362] = true, -- Duelist
	[8367] = true, -- Elite
	[8368] = true, -- Duelist
	[8373] = true, -- Elite
	[8374] = true, -- Duelist
	[8379] = true, -- Elite
	[8380] = true, -- Duelist
	
	[3524] = true, -- magical bonus ID for items that instead use the instance difficulty ID parameter
};

mog.itemStringPattern = "item:(%d+):%d*:%d*:%d*:%d*:%d*:%d*:%d*:%d*:%d*:%d*:(%d*):%d*:([%d:]+)";

function mog:ToNumberItem(item)
	if type(item) == "string" then
		local id, diff, bonus = item:match(mog.itemStringPattern);
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
		return tonumber(id), tonumber(bonus), tonumber(diff);
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
	[INVSLOT_BODY] = "ShirtSlot",
	[INVSLOT_TABARD] = "TabardSlot",
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
