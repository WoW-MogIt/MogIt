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


AddonCompartmentFrame:RegisterAddon({
	text = "MogIt",
	icon = "Interface\\Icons\\INV_Enchant_EssenceCosmicGreater",
	notCheckable = true,
	func = function()
		mog:ToggleFrame();
	end,
})

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

		mog.createOptions();

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
					local itemsCollectionFrame = self:GetParent()
					if not itemsCollectionFrame.transmogLocation:IsIllusion() then
						local sources = CollectionWardrobeUtil.GetSortedAppearanceSources(self.visualInfo.visualID, itemsCollectionFrame:GetActiveCategory(), itemsCollectionFrame.transmogLocation)
						if WardrobeCollectionFrame.tooltipSourceIndex then
							local index = CollectionWardrobeUtil.GetValidIndexForNumSources(WardrobeCollectionFrame.tooltipSourceIndex, #sources)
							local link = select(6, C_TransmogCollection.GetAppearanceSourceInfo(sources[index].sourceID))
							mog:AddToPreview(link)
							return
						end
					else
						mog:SetPreviewEnchant(mog:GetPreview(mog.activePreview), self.visualInfo.sourceID);
					end
				end
				self:OnMouseDown(button)
			end)
		end
		ScrollUtil.AddInitializedFrameCallback(WardrobeCollectionFrame.SetsCollectionFrame.ListContainer.ScrollBox, function(self, button, elementData)
			if not button.mogitInit then
				local orig_OnClick = button:GetScript("OnClick");
				button:SetScript("OnClick", function(self, button2)
					if IsControlKeyDown() and button2 == "RightButton" then
						local preview = mog:GetPreview();
						local primaryAppearances = C_TransmogSets.GetSetPrimaryAppearances(self.setID);
						for _, primaryAppearance in ipairs(primaryAppearances) do
							local sourceID = primaryAppearance.appearanceID;
							mog:AddToPreview(select(6, C_TransmogCollection.GetAppearanceSourceInfo(sourceID)), preview);
						end
						return
					end
					orig_OnClick(self, button2);
				end);
				button.mogitInit = true;
			end
		end, self, true);
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
		EVOKER = "Mail",
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
	[569] = true, -- Mythic
	[570] = true, -- Heroic
	[580] = true, -- Elite
	[581] = true, -- Mythic
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
	[1726] = true, -- dungeon-heroic
	[1727] = true, -- dungeon-mythic
	[1798] = true, -- raid-heroic
	[1799] = true, -- raid-mythic
	[1805] = true, -- raid-heroic
	[1806] = true, -- raid-mythic
	[3379] = true, -- Raid Finder
	[3439] = true, -- Heroic
	[3440] = true, -- Mythic
	[3444] = true, -- raid-heroic
	[3445] = true, -- raid-mythic
	[3446] = true, -- Raid Finder
	[3452] = true, -- Mythic
	[3453] = true, -- Mythic
	[3454] = true, -- Mythic
	[3468] = true, -- raid-heroic
	[3469] = true, -- raid-mythic
	[3470] = true, -- Raid Finder
	[3504] = true, -- Heroic
	[3505] = true, -- Raid Finder
	[3507] = true, -- raid-heroic
	[3508] = true, -- raid-mythic
	[3516] = true, -- raid-heroic
	[3517] = true, -- raid-heroic
	[3518] = true, -- raid-mythic
	[3519] = true, -- raid-mythic
	[3520] = true, -- Raid Finder
	[3521] = true, -- Raid Finder
	[3562] = true, -- raid-heroic
	[3563] = true, -- raid-mythic
	[3564] = true, -- Raid Finder
	[3575] = true, -- Mythic
	[3576] = true, -- Heroic
	[3611] = true, -- raid-heroic
	[3612] = true, -- raid-mythic
	[3613] = true, -- Raid Finder
	[4194] = true, -- Heroic
	[4196] = true, -- Heroic
	[4198] = true, -- Heroic
	[4200] = true, -- Heroic
	[4201] = true, -- Heroic
	[4202] = true, -- dungeon-heroic
	[4204] = true, -- dungeon-mythic
	[4236] = true, -- Heroic
	[4237] = true, -- Heroic
	[4536] = true, -- Heroic
	[4739] = true, -- Heroic
	[4740] = true, -- Heroic
	[4752] = true, -- Heroic
	[4753] = true, -- Heroic
	[4778] = true, -- dungeon-heroic
	[4779] = true, -- dungeon-mythic
	[4799] = true, -- raid-heroic
	[4800] = true, -- raid-mythic
	[4801] = true, -- Raid Finder
	[4818] = true, -- dungeon-heroic
	[4819] = true, -- dungeon-mythic
	[4823] = true, -- raid-heroic
	[4824] = true, -- raid-mythic
	[4825] = true, -- Raid Finder
	[4985] = true, -- Combatant I
	[4986] = true, -- Challenger I
	[4987] = true, -- Rival I
	[4988] = true, -- Duelist
	[4989] = true, -- Elite
	[4994] = true, -- Combatant I
	[4995] = true, -- Combatant I
	[4996] = true, -- Challenger I
	[4997] = true, -- Challenger I
	[4998] = true, -- Rival I
	[4999] = true, -- Rival I
	[5000] = true, -- Duelist
	[5001] = true, -- Duelist
	[5003] = true, -- Elite
	[5004] = true, -- Elite
	[5068] = true, -- Combatant I
	[5069] = true, -- Combatant I
	[5070] = true, -- Combatant I
	[5071] = true, -- Challenger I
	[5072] = true, -- Challenger I
	[5073] = true, -- Challenger I
	[5074] = true, -- Rival I
	[5075] = true, -- Rival I
	[5076] = true, -- Rival I
	[5077] = true, -- Duelist
	[5078] = true, -- Duelist
	[5079] = true, -- Duelist
	[5080] = true, -- Elite
	[5081] = true, -- Elite
	[5082] = true, -- Elite
	[5084] = true, -- Elite
	[5085] = true, -- Duelist
	[5086] = true, -- Rival I
	[5087] = true, -- Challenger I
	[5088] = true, -- Combatant I
	[5090] = true, -- Elite
	[5091] = true, -- Duelist
	[5092] = true, -- Rival I
	[5093] = true, -- Combatant I
	[5094] = true, -- Challenger I
	[5096] = true, -- Elite
	[5097] = true, -- Duelist
	[5098] = true, -- Rival I
	[5099] = true, -- Challenger I
	[5101] = true, -- Combatant I
	[5102] = true, -- Elite
	[5103] = true, -- Duelist
	[5104] = true, -- Rival I
	[5105] = true, -- Combatant I
	[5106] = true, -- Challenger I
	[5119] = true, -- Heroic
	[5120] = true, -- Heroic
	[5178] = true, -- Combatant I
	[5179] = true, -- Combatant I
	[5183] = true, -- Challenger I
	[5184] = true, -- Challenger I
	[5188] = true, -- Rival I
	[5189] = true, -- Rival I
	[5193] = true, -- Duelist
	[5194] = true, -- Duelist
	[5198] = true, -- Elite
	[5199] = true, -- Elite
	[5208] = true, -- Combatant I
	[5213] = true, -- Challenger I
	[5218] = true, -- Rival I
	[5223] = true, -- Duelist
	[5228] = true, -- Elite
	[5263] = true, -- Combatant I
	[5264] = true, -- Combatant I
	[5265] = true, -- Combatant I
	[5266] = true, -- Challenger I
	[5267] = true, -- Challenger I
	[5268] = true, -- Challenger I
	[5269] = true, -- Rival I
	[5270] = true, -- Rival I
	[5271] = true, -- Rival I
	[5272] = true, -- Duelist
	[5273] = true, -- Duelist
	[5274] = true, -- Duelist
	[5275] = true, -- Elite
	[5276] = true, -- Elite
	[5277] = true, -- Elite
	[5278] = true, -- Combatant I
	[5279] = true, -- Challenger I
	[5280] = true, -- Rival I
	[5281] = true, -- Duelist
	[5282] = true, -- Elite
	[5283] = true, -- Combatant I
	[5284] = true, -- Combatant I
	[5285] = true, -- Combatant I
	[5286] = true, -- Combatant I
	[5287] = true, -- Challenger I
	[5288] = true, -- Challenger I
	[5289] = true, -- Challenger I
	[5290] = true, -- Challenger I
	[5291] = true, -- Rival I
	[5292] = true, -- Rival I
	[5293] = true, -- Rival I
	[5294] = true, -- Rival I
	[5295] = true, -- Duelist
	[5296] = true, -- Duelist
	[5297] = true, -- Duelist
	[5298] = true, -- Duelist
	[5299] = true, -- Elite
	[5300] = true, -- Elite
	[5301] = true, -- Elite
	[5302] = true, -- Elite
	[5310] = true, -- Combatant I
	[5311] = true, -- Combatant I
	[5312] = true, -- Combatant I
	[5313] = true, -- Combatant I
	[5314] = true, -- Challenger I
	[5315] = true, -- Challenger I
	[5316] = true, -- Challenger I
	[5317] = true, -- Challenger I
	[5318] = true, -- Rival I
	[5319] = true, -- Rival I
	[5320] = true, -- Rival I
	[5321] = true, -- Rival I
	[5322] = true, -- Duelist
	[5323] = true, -- Duelist
	[5324] = true, -- Duelist
	[5325] = true, -- Duelist
	[5326] = true, -- Elite
	[5327] = true, -- Elite
	[5328] = true, -- Elite
	[5329] = true, -- Elite
	[5331] = true, -- Combatant I
	[5332] = true, -- Challenger I
	[5333] = true, -- Rival I
	[5334] = true, -- Duelist
	[5335] = true, -- Elite
	[5337] = true, -- Combatant I
	[5338] = true, -- Challenger I
	[5339] = true, -- Rival I
	[5340] = true, -- Duelist
	[5341] = true, -- Elite
	[5343] = true, -- Combatant I
	[5344] = true, -- Challenger I
	[5345] = true, -- Rival I
	[5346] = true, -- Duelist
	[5347] = true, -- Elite
	[5349] = true, -- Combatant I
	[5350] = true, -- Challenger I
	[5351] = true, -- Rival I
	[5352] = true, -- Duelist
	[5353] = true, -- Elite
	[5367] = true, -- Combatant I
	[5368] = true, -- Challenger I
	[5369] = true, -- Rival I
	[5370] = true, -- Duelist
	[5371] = true, -- Elite
	[5453] = true, -- Combatant I
	[5454] = true, -- Challenger I
	[5455] = true, -- Rival I
	[5456] = true, -- Duelist
	[5457] = true, -- Elite
	[5458] = true, -- Combatant I
	[5459] = true, -- Challenger I
	[5460] = true, -- Rival I
	[5461] = true, -- Duelist
	[5462] = true, -- Elite
	[5478] = true, -- Heroic
	[5479] = true, -- Heroic
	[5822] = true, -- Combatant I
	[5825] = true, -- Combatant I
	[5826] = true, -- Challenger I
	[5830] = true, -- Challenger I
	[5831] = true, -- Rival I
	[5834] = true, -- Rival I
	[5835] = true, -- Duelist
	[5838] = true, -- Duelist
	[5839] = true, -- Elite
	[5842] = true, -- Elite
	[5844] = true, -- Heroic
	[5845] = true, -- Heroic
	[6325] = true, -- Combatant I
	[6328] = true, -- Combatant I
	[6329] = true, -- Challenger I
	[6332] = true, -- Challenger I
	[6333] = true, -- Rival I
	[6336] = true, -- Rival I
	[6337] = true, -- Duelist
	[6338] = true, -- Duelist
	[6341] = true, -- Elite
	[6344] = true, -- Elite
	[6361] = true, -- Combatant I
	[6364] = true, -- Combatant I
	[6365] = true, -- Challenger I
	[6366] = true, -- Challenger I
	[6367] = true, -- Combatant I
	[6368] = true, -- Rival I
	[6369] = true, -- Combatant I
	[6370] = true, -- Challenger I
	[6371] = true, -- Challenger I
	[6372] = true, -- Rival I
	[6373] = true, -- Rival I
	[6374] = true, -- Duelist
	[6375] = true, -- Duelist
	[6376] = true, -- Elite
	[6377] = true, -- Rival I
	[6378] = true, -- Elite
	[6379] = true, -- Duelist
	[6380] = true, -- Duelist
	[6381] = true, -- Elite
	[6382] = true, -- Elite
	[6517] = true, -- Challenger I
	[6518] = true, -- Rival I
	[6519] = true, -- Duelist
	[6520] = true, -- Elite
	[6521] = true, -- Rival I
	[6522] = true, -- Duelist
	[6523] = true, -- Elite
	[6605] = true, -- Heroic
	[6606] = true, -- Mythic
	[6607] = true, -- Raid Finder
	[6617] = true, -- Unranked
	[6618] = true, -- Combatant I
	[6619] = true, -- Challenger I
	[6620] = true, -- Rival I
	[6621] = true, -- Duelist
	[6622] = true, -- Elite
	[6623] = true, -- Duelist
	[6624] = true, -- Elite
	[6625] = true, -- Rival I
	[6626] = true, -- Challenger I
	[6627] = true, -- Combatant I
	[6628] = true, -- Unranked
	[6630] = true, -- Unranked
	[6631] = true, -- Combatant I
	[6632] = true, -- Challenger I
	[6633] = true, -- Rival I
	[6634] = true, -- Duelist
	[6635] = true, -- Elite
	[6638] = true, -- Unranked
	[6639] = true, -- Combatant I
	[6640] = true, -- Challenger I
	[6641] = true, -- Rival I
	[6642] = true, -- Duelist
	[6643] = true, -- Elite
	[6806] = true, -- raid-heroic
	[6807] = true, -- raid-mythic
	[7021] = true, -- Raid Finder
	[7022] = true, -- Heroic
	[7024] = true, -- Mythic
	[7131] = true, -- Unranked
	[7132] = true, -- Combatant I
	[7133] = true, -- Challenger I
	[7134] = true, -- Rival I
	[7135] = true, -- Duelist
	[7136] = true, -- Elite
	[7139] = true, -- Combatant I
	[7140] = true, -- Challenger I
	[7141] = true, -- Rival I
	[7142] = true, -- Duelist
	[7143] = true, -- Elite
	[7186] = true, -- Raid Finder
	[7187] = true, -- Mythic
	[7188] = true, -- Heroic
	[7202] = true, -- Heroic
	[7225] = true, -- Unranked
	[7226] = true, -- Combatant I
	[7227] = true, -- Challenger I
	[7228] = true, -- Rival I
	[7229] = true, -- Duelist
	[7230] = true, -- Elite
	[7305] = true, -- Unranked
	[7306] = true, -- Combatant I
	[7307] = true, -- Challenger I
	[7308] = true, -- Rival I
	[7309] = true, -- Duelist
	[7310] = true, -- Elite
	[7311] = true, -- Unranked
	[7312] = true, -- Combatant I
	[7313] = true, -- Challenger I
	[7314] = true, -- Rival I
	[7315] = true, -- Duelist
	[7316] = true, -- Elite
	[7317] = true, -- Unranked
	[7318] = true, -- Combatant I
	[7319] = true, -- Challenger I
	[7320] = true, -- Rival I
	[7321] = true, -- Duelist
	[7322] = true, -- Elite
	[7323] = true, -- Unranked
	[7324] = true, -- Combatant I
	[7325] = true, -- Challenger I
	[7326] = true, -- Rival I
	[7327] = true, -- Duelist
	[7328] = true, -- Elite
	[7329] = true, -- Unranked
	[7330] = true, -- Combatant I
	[7331] = true, -- Challenger I
	[7332] = true, -- Rival I
	[7333] = true, -- Duelist
	[7334] = true, -- Elite
	[7335] = true, -- Unranked
	[7336] = true, -- Combatant I
	[7337] = true, -- Challenger I
	[7338] = true, -- Rival I
	[7339] = true, -- Duelist
	[7340] = true, -- Elite
	[7341] = true, -- Unranked
	[7342] = true, -- Combatant I
	[7343] = true, -- Challenger I
	[7344] = true, -- Rival I
	[7345] = true, -- Duelist
	[7346] = true, -- Elite
	[7359] = true, -- Mythic
	[7528] = true, -- Unranked
	[7529] = true, -- Combatant II
	[7530] = true, -- Challenger II
	[7531] = true, -- Rival II
	[7532] = true, -- Elite
	[7533] = true, -- Duelist
	[7534] = true, -- Unranked
	[7535] = true, -- Combatant II
	[7536] = true, -- Challenger II
	[7537] = true, -- Rival II
	[7538] = true, -- Elite
	[7539] = true, -- Duelist
	[7540] = true, -- Unranked
	[7541] = true, -- Combatant II
	[7542] = true, -- Challenger II
	[7543] = true, -- Rival II
	[7544] = true, -- Elite
	[7545] = true, -- Duelist
	[7546] = true, -- Unranked
	[7547] = true, -- Combatant II
	[7548] = true, -- Challenger II
	[7549] = true, -- Rival II
	[7550] = true, -- Elite
	[7551] = true, -- Duelist
	[7552] = true, -- Unranked
	[7553] = true, -- Combatant II
	[7554] = true, -- Challenger II
	[7555] = true, -- Rival II
	[7556] = true, -- Elite
	[7557] = true, -- Duelist
	[7558] = true, -- Unranked
	[7559] = true, -- Combatant II
	[7560] = true, -- Challenger II
	[7561] = true, -- Rival II
	[7562] = true, -- Elite
	[7563] = true, -- Duelist
	[7564] = true, -- Unranked
	[7565] = true, -- Combatant II
	[7566] = true, -- Challenger II
	[7567] = true, -- Rival II
	[7568] = true, -- Elite
	[7569] = true, -- Duelist
	[7749] = true, -- Mythic
	[7756] = true, -- Timewarped
	[7859] = true, -- Combatant II
	[7860] = true, -- Challenger II
	[7861] = true, -- Rival II
	[7862] = true, -- Combatant II
	[7863] = true, -- Challenger II
	[7864] = true, -- Rival II
	[7865] = true, -- Combatant II
	[7866] = true, -- Challenger II
	[7867] = true, -- Rival II
	[7868] = true, -- Combatant II
	[7869] = true, -- Challenger II
	[7870] = true, -- Rival II
	[7871] = true, -- Combatant II
	[7872] = true, -- Challenger II
	[7873] = true, -- Rival II
	[7874] = true, -- Combatant II
	[7875] = true, -- Challenger II
	[7876] = true, -- Rival II
	[7877] = true, -- Combatant II
	[7878] = true, -- Challenger II
	[7879] = true, -- Rival II
	[7893] = true, -- Combatant I
	[7894] = true, -- Challenger I
	[7895] = true, -- Rival I
	[7896] = true, -- Combatant I
	[7897] = true, -- Challenger I
	[7898] = true, -- Rival I
	[7899] = true, -- Combatant I
	[7900] = true, -- Challenger I
	[7901] = true, -- Rival I
	[7902] = true, -- Combatant I
	[7903] = true, -- Challenger I
	[7904] = true, -- Rival I
	[7905] = true, -- Combatant I
	[7906] = true, -- Challenger I
	[7907] = true, -- Rival I
	[7908] = true, -- Combatant I
	[7909] = true, -- Challenger I
	[7910] = true, -- Rival I
	[7911] = true, -- Combatant I
	[7912] = true, -- Challenger I
	[7913] = true, -- Rival I
	[7976] = true, -- Heroic
	[7977] = true, -- Mythic
	[7980] = true, -- Heroic
	[7981] = true, -- Mythic
	[7982] = true, -- Raid Finder
	[8339] = true, -- Unranked
	[8340] = true, -- Combatant II
	[8341] = true, -- Challenger II
	[8342] = true, -- Rival II
	[8343] = true, -- Elite
	[8344] = true, -- Duelist
	[8345] = true, -- Unranked
	[8346] = true, -- Combatant II
	[8347] = true, -- Challenger II
	[8348] = true, -- Rival II
	[8349] = true, -- Elite
	[8350] = true, -- Duelist
	[8351] = true, -- Unranked
	[8352] = true, -- Combatant II
	[8353] = true, -- Challenger II
	[8354] = true, -- Rival II
	[8355] = true, -- Elite
	[8356] = true, -- Duelist
	[8357] = true, -- Unranked
	[8358] = true, -- Combatant II
	[8359] = true, -- Challenger II
	[8360] = true, -- Rival II
	[8361] = true, -- Elite
	[8362] = true, -- Duelist
	[8363] = true, -- Unranked
	[8364] = true, -- Combatant II
	[8365] = true, -- Challenger II
	[8366] = true, -- Rival II
	[8367] = true, -- Elite
	[8368] = true, -- Duelist
	[8369] = true, -- Unranked
	[8370] = true, -- Combatant II
	[8371] = true, -- Challenger II
	[8372] = true, -- Rival II
	[8373] = true, -- Elite
	[8374] = true, -- Duelist
	[8375] = true, -- Unranked
	[8376] = true, -- Combatant II
	[8377] = true, -- Challenger II
	[8378] = true, -- Rival II
	[8379] = true, -- Elite
	[8380] = true, -- Duelist
	[8381] = true, -- Combatant I
	[8382] = true, -- Challenger I
	[8383] = true, -- Rival I
	[8384] = true, -- Combatant I
	[8385] = true, -- Challenger I
	[8386] = true, -- Rival I
	[8387] = true, -- Combatant I
	[8388] = true, -- Challenger I
	[8389] = true, -- Rival I
	[8390] = true, -- Combatant I
	[8391] = true, -- Challenger I
	[8392] = true, -- Rival I
	[8393] = true, -- Combatant I
	[8394] = true, -- Challenger I
	[8395] = true, -- Rival I
	[8396] = true, -- Combatant I
	[8397] = true, -- Challenger I
	[8398] = true, -- Rival I
	[8399] = true, -- Combatant I
	[8400] = true, -- Challenger I
	[8401] = true, -- Rival I
	
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
