local MogIt,mog = ...;
_G["MogIt"] = mog;
local L = mog.L;

function mog.toggle()
	if mog.container:IsShown() then
		HideUIPanel(mog.container);
	else
		ShowUIPanel(mog.container);
	end
end

mog.LBB = LibStub("LibBabble-Boss-3.0"):GetUnstrictLookupTable();
mog.LBI = LibStub("LibBabble-Inventory-3.0"):GetUnstrictLookupTable();
mog.LDB = LibStub("LibDataBroker-1.1");
mog.LDBI = LibStub("LibDBIcon-1.0");
mog.mmb = mog.LDB:NewDataObject(MogIt,{
	type = "launcher",
	icon = "Interface\\Icons\\INV_Enchant_EssenceCosmicGreater",
	OnClick = mog.toggle,
	OnTooltipShow = function(self)
		if not self or not self.AddLine then return end
		self:AddLine("MogIt");
		self:AddLine(mog.container:IsShown() and L["Click to close MogIt"] or L["Click to open MogIt"],1,1,1);
	end
});

mog.db = {};
mog.filters = {
	display = {},
	quality = {},
	lvl = {},
	faction = {},
	class = {},
	slot = {},
	
	source = {},
	sourceid = {},
	sourceinfo = {},
	zone = {},
	
	colours = {
		[1] = {},
		[2] = {},
		[3] = {},
	},
};
mog.bosses = {};

function mog.register(label,addon)
	if type(mog.db[addon]) ~= "table" then
		local _,title = GetAddOnInfo(addon);
		mog.db[addon] = {name = title and title:match("^MogIt_(.+)") or title,slots = {}};
	end
	local items = {};
	table.insert(mog.db[addon].slots,{label = mog.LBI[label] or label,items = items});
	return items;
end

function mog.addItem(tbl,id,display,quality,lvl,faction,class,slot,source,sourceid,zone,sourceinfo)
	table.insert(tbl,id);
	mog.filters.display[id] = display;
	mog.filters.quality[id] = quality;
	mog.filters.lvl[id] = lvl;
	mog.filters.faction[id] = faction;
	mog.filters.class[id] = class;
	mog.filters.slot[id] = slot;
	mog.filters.source[id] = source;
	mog.filters.sourceid[id] = sourceid;
	mog.filters.sourceinfo[id] = sourceinfo;
	mog.filters.zone[id] = zone;
end

function mog.addBoss(id,name)
	if not mog.bosses[id] then
		mog.bosses[id] = mog.LBB[name] or name;
	end
end

function mog.addColours(id,c1,c2,c3)
	if c1 and (not mog.filters.colours[1][id]) then
		mog.filters.colours[1][id] = c1;
		mog.filters.colours[2][id] = c2;
		mog.filters.colours[3][id] = c3;
	end
end

mog.container = CreateFrame("Frame","MogItContainer",UIParent);
mog.container:Hide();
mog.container:SetAllPoints(UIParent);
table.insert(UISpecialFrames,"MogItContainer");
mog.container:SetToplevel(true);
mog.container:SetScript("OnEvent",function(self,event,arg1,...)
	if event == "PLAYER_LOGIN" then
		if not MogIt_Global then
			MogIt_Global = {
				tooltip = true,
				tooltipMouse = false,
				tooltipDress = false,
				tooltipRotate = true,
				tooltipMog = true,
				--tooltipAnchor = false,
				gridDress = true,
			};
		end
		mog.global = MogIt_Global;
		mog.global.wishlist = mog.global.wishlist or {};
		mog.global.minimap = mog.global.minimap or {};
		mog.global.url = mog.global.url or "Battle.net";
		mog.global.tooltipWidth = mog.global.tooltipWidth or 300;
		mog.global.tooltipHeight = mog.global.tooltipHeight or 300;
		--mog.global.tooltipMod;
		mog.global.gridWidth = mog.global.gridWidth or 200;
		mog.global.gridHeight = mog.global.gridHeight or 200;
		mog.global.rows = mog.global.rows or 2;
		mog.global.columns = mog.global.columns or 3;
		if not mog.global.version then
			DEFAULT_CHAT_FRAME:AddMessage(L["MogIt has loaded! Type \"/mog\" to open it."]);
		end
		mog.global.version = GetAddOnMetadata(MogIt,"Version");
		
		if not MogIt_Character then
			MogIt_Character = {};
		end
		mog.char = MogIt_Character;
		mog.char.wishlist = mog.char.wishlist or {};
		mog.char.wishlist.display = mog.char.wishlist.display or {};
		mog.char.wishlist.time = mog.char.wishlist.time or {};
		mog.char.version = GetAddOnMetadata(MogIt,"Version");
		
		mog.view.model:SetUnit("PLAYER");
		mog.updateGrid();
		mog.updateModels();
		
		mog.tooltip.model:SetUnit("PLAYER");
		mog.tooltip:SetSize(mog.global.tooltipWidth,mog.global.tooltipHeight);
		if mog.global.tooltipRotate then
			mog.tooltip.rotate:Show();
		end
		
		for i=1,GetNumAddOns() do
			local name,title,_,_,loadable = GetAddOnInfo(i);
			title = title and title:match("^MogIt_(.+)");
			if title and loadable then
				mog.db[name] = mog.db[name] or title;
			end
		end
		
		mog.LDBI:Register(MogIt,mog.mmb,mog.global.minimap);
		mog.frame:UnregisterEvent("PLAYER_LOGIN");
	elseif event == "GET_ITEM_INFO_RECEIVED" then
		local now = time();
		for k,v in pairs(mog.view.waitList) do
			if select(9,GetItemInfo(k)) then
				mog.view.waitList[k] = nil;
				for i=1,mog.view.waitCount[k] do
					mog.view.addItem(k);
				end
				mog.view.waitCount[k] = nil;
			elseif (now-v) > 10 then
				mog.view.waitList[k] = nil;
				mog.view.waitCount[k] = nil;
			end
		end
	elseif event == "ADDON_LOADED" then
		if arg1 == "AtlasLoot" then
			mog.tooltip.hookAtlasLoot();
		else
			local _,title = GetAddOnInfo(arg1);
			if title and title:match("^MogIt_(.+)") and mog.frame:IsShown() then
				ToggleDropDownMenu(1,arg1,mog.frame.dd);
			end
		end
	end
end);
mog.container:RegisterEvent("PLAYER_LOGIN");
mog.container:RegisterEvent("GET_ITEM_INFO_RECEIVED");
mog.container:RegisterEvent("ADDON_LOADED");

SLASH_MOGIT1 = "/mog";
SLASH_MOGIT2 = "/mogit";
SlashCmdList["MOGIT"] = mog.toggle;

BINDING_HEADER_MogIt = "MogIt";
BINDING_NAME_MogIt = "Toggle Mogit";

mog.frame = CreateFrame("Frame","MogItFrame",mog.container,"PortraitFrameTemplate");
mog.frame:SetPoint("CENTER",UIParent,"CENTER");
mog.frame:SetSize(252,130);
mog.frame:SetFrameLevel(15);
mog.frame:SetToplevel(true);
mog.frame:SetClampedToScreen(true);
mog.frame:EnableMouse(true);
mog.frame:SetMovable(true);
mog.frame:SetUserPlaced(true);
mog.frame:SetScript("OnMouseDown",mog.frame.StartMoving);
mog.frame:SetScript("OnMouseUp",mog.frame.StopMovingOrSizing);

mog.frame.TitleText:SetText("MogIt");
mog.frame.TitleText:SetPoint("RIGHT",mog.frame,"RIGHT",-28,0);
mog.frame.portrait:SetTexture("Interface\\AddOns\\MogIt\\Images\\MogIt");
mog.frame.portrait:SetTexCoord(0,106/128,0,105/128);
MogItFrameCloseButton:SetScript("OnClick",function(self)
	HideUIPanel(mog.container);
end);

mog.frame.dd = CreateFrame("Frame","MogItDropdown",mog.frame,"UIDropDownMenuTemplate");
mog.frame.dd:SetPoint("TOPLEFT",mog.frame,"TOPLEFT",44,-27);
UIDropDownMenu_SetWidth(mog.frame.dd,mog.frame:GetWidth()-85);
UIDropDownMenu_SetButtonWidth(mog.frame.dd,mog.frame:GetWidth()-85+15);
UIDropDownMenu_JustifyText(mog.frame.dd,"LEFT");
UIDropDownMenu_SetText(mog.frame.dd,L["Select a category"]);
function mog.frame.dd:initialize(tier)
	local info;
	if tier == 1 then
		info = UIDropDownMenu_CreateInfo();
		info.text = L["Wishlist"];
		info.value = "wl";
		info.colorCode = "\124cFFFFFF00";
		info.notCheckable = true;
		info.func = function(self)
			UIDropDownMenu_SetText(mog.frame.dd,L["Wishlist"]);
			mog.selected = self.value;
			mog.buildList(true,true);
		end
		UIDropDownMenu_AddButton(info,tier);
		for k,v in pairs(mog.db) do
			info = UIDropDownMenu_CreateInfo();
			local d = type(v) == "table";
			info.text = d and v.name or v.." \124cFFFFFFFF("..L["Click to load addon"]..")";
			info.value = k;
			info.colorCode = "\124cFF"..(d and "00FF00" or "FF0000");
			info.hasArrow = d;
			info.keepShownOnClick = d;
			info.notCheckable = true;
			info.func = function(self)
				if type(mog.db[self.value]) ~= "table" then
					LoadAddOn(self.value);
				end
			end
			UIDropDownMenu_AddButton(info,tier);
		end
	elseif tier == 2 then
		for k,v in ipairs(mog.db[UIDROPDOWNMENU_MENU_VALUE].slots) do
			info = UIDropDownMenu_CreateInfo();
			info.text = v.label;
			info.value = v;
			info.notCheckable = true;
			info.func = function(self)
				UIDropDownMenu_SetText(mog.frame.dd,mog.db[self.arg1].name.." - "..self.value.label);
				mog.selected = self.value;
				mog.buildList(true,true);
				CloseDropDownMenus();
			end
			info.arg1 = UIDROPDOWNMENU_MENU_VALUE;
			UIDropDownMenu_AddButton(info,tier);
		end
	end
end

mog.frame.btnGrid = CreateFrame("Button","MogItBtnGrid",mog.frame,"UIPanelButtonTemplate2");
mog.frame.btnGrid:SetPoint("TOPLEFT",mog.frame,"TOPLEFT",5,-58);
mog.frame.btnGrid:SetText("Catalogue");
mog.frame.btnGrid:SetSize(120,22);
mog.frame.btnGrid:SetScript("OnClick",function(self)
	if mog.grid:IsShown() then
		mog.grid:Hide();
	else
		mog.grid:Show();
	end
end);
mog.frame.btnGrid.tooltipText = "Show/Hide the Catalogue window";

mog.frame.btnFilters = CreateFrame("Button","MogItBtnFilters",mog.frame,"UIPanelButtonTemplate2");
mog.frame.btnFilters:SetPoint("LEFT",mog.frame.btnGrid,"RIGHT");
mog.frame.btnFilters:SetText("Filters");
mog.frame.btnFilters:SetSize(120,22);
mog.frame.btnFilters:SetScript("OnClick",function(self)
	if mog.filt:IsShown() then
		mog.filt:Hide();
	else
		mog.filt:Show();
	end
end);
mog.frame.btnFilters.tooltipText = "Show/Hide the Filters window";

mog.frame.btnPreview = CreateFrame("Button","MogItBtnPreview",mog.frame,"UIPanelButtonTemplate2");
mog.frame.btnPreview:SetPoint("TOP",mog.frame.btnGrid,"BOTTOM");
mog.frame.btnPreview:SetText("Preview");
mog.frame.btnPreview:SetSize(120,22);
mog.frame.btnPreview:SetScript("OnClick",function(self)
	if mog.view:IsShown() then
		mog.view:Hide();
	else
		mog.view:Show();
	end
end);
mog.frame.btnPreview.tooltipText = "Show/Hide the Preview window";

mog.frame.btnInfo = CreateFrame("Button","MogItBtnInfo",mog.frame,"UIPanelButtonTemplate2");
mog.frame.btnInfo:SetPoint("LEFT",mog.frame.btnPreview,"RIGHT");
mog.frame.btnInfo:SetText("Item Info");
mog.frame.btnInfo:SetSize(120,22);
mog.frame.btnInfo:SetScript("OnClick",function(self)
	if mog.info:IsShown() then
		mog.info:Hide();
	else
		mog.info:Show();
	end
end);
mog.frame.btnInfo.tooltipText = "Show/Hide the Item Info window";

mog.frame.btnOptions = CreateFrame("Button","MogItBtnOptions",mog.frame,"UIPanelButtonTemplate2");
mog.frame.btnOptions:SetPoint("TOP",mog.frame.btnPreview,"BOTTOM");
mog.frame.btnOptions:SetText("Options");
mog.frame.btnOptions:SetSize(120,22);
mog.frame.btnOptions:SetScript("OnClick",function(self)
	if mog.opt:IsShown() then
		mog.opt:Hide();
	else
		mog.opt:Show();
	end
end);
mog.frame.btnOptions.tooltipText = "Show/Hide the Options window";

mog.frame.btnHelp = CreateFrame("Button","MogItBtnHelp",mog.frame,"UIPanelButtonTemplate2");
mog.frame.btnHelp:SetPoint("LEFT",mog.frame.btnOptions,"RIGHT");
mog.frame.btnHelp:SetText("Help");
mog.frame.btnHelp:SetSize(120,22);
mog.frame.btnHelp:SetScript("OnClick",function(self)
	if mog.help:IsShown() then
		mog.help:Hide();
	else
		mog.help:Show();
	end
end);
mog.frame.btnHelp.tooltipText = "Show/Hide the Help window";

mog.interface = CreateFrame("Frame");
mog.interface.title = mog.interface:CreateFontString(nil,"ARTWORK","GameFontNormalLarge");
mog.interface.title:SetPoint("TOPLEFT",16,-16);
mog.interface.title:SetText("MogIt");
mog.interface.launch = CreateFrame("Button","MogItInterfaceLaunch",mog.interface,"UIPanelButtonTemplate2");
mog.interface.launch:SetWidth(175);
mog.interface.launch:SetHeight(22);
mog.interface.launch:SetPoint("TOPLEFT",mog.interface.title,"BOTTOMLEFT",0,-8);
mog.interface.launch:SetText(L["Click to open MogIt"]);
mog.interface.launch:SetScript("OnClick",function(self,btn)
	InterfaceOptionsFrame.lastFrame = nil;
	HideUIPanel(InterfaceOptionsFrame);
	ShowUIPanel(mog.container);
end);
mog.interface.name = "MogIt";
InterfaceOptions_AddCategory(mog.interface);

--[[local animG = mog.frame.portrait:CreateAnimationGroup();
animG:SetLooping("BOUNCE");
local anim = animG:CreateAnimation("Rotation");
anim:SetDuration(5);
anim:SetSmoothing("IN_OUT");
anim:SetDegrees(360);
animG:Play();--]]

mog.source = {
	[1] = L["Drop"],
	[2] = PVP,
	[3] = L["Quest"],
	[4] = L["Vendor"],
	[5] = L["Crafted"],
	[6] = L["Achievement"],
	[7] = L["Code Redemption"],
};

mog.diffs = {
	--[1] = "5N",
	[2] = ITEM_HEROIC,
	[3] = L["10N"],
	[4] = L["25N"],
	[5] = L["10H"],
	[6] = L["25H"],
	[7] = ITEM_HEROIC,
};

mog.slots = {
	[1] = INVTYPE_WEAPON,
	[2] = INVTYPE_WEAPONMAINHAND,
	[3] = INVTYPE_WEAPONOFFHAND,
};

mog.professions = {
	[1] = GetSpellInfo(2259), -- Alchemy
	[2] = GetSpellInfo(2018), -- Blacksmithing
	[3] = GetSpellInfo(7411), -- Enchanting
	[4] = GetSpellInfo(4036), -- Engineering
	[5] = GetSpellInfo(45357), -- Inscription
	[6] = GetSpellInfo(25229), -- Jewelcrafting
	[7] = GetSpellInfo(2108), -- Leatherworking
	[8] = GetSpellInfo(3908), -- Tailoring

	[9] = GetSpellInfo(2366), -- Herbalism
	[10] = GetSpellInfo(2575), -- Mining
	[11] = GetSpellInfo(8613), -- Skinning

	[12] = GetSpellInfo(78670), -- Archaeology
	[13] = GetSpellInfo(2550), -- Cooking
	[14] = GetSpellInfo(3273), -- First Aid
	[15] = GetSpellInfo(7620), -- Fishing
};

mog.quality = {
	2, -- Uncommon
	3, -- Rare
	4, -- Epic
	7, -- Heirloom
};

mog.classes = {};
FillLocalizedClassList(mog.classes,UnitSex("PLAYER")==3);
mog.classBits = {
	DEATHKNIGHT = 32,
	DRUID = 1024,
	HUNTER = 4,
	MAGE = 128,
	PALADIN = 2,
	PRIEST = 16,
	ROGUE = 8,
	SHAMAN = 64,
	WARLOCK = 256,
	WARRIOR = 1,
};

mog.urlList = {};
mog.urlFav = {};
mog.urlItem = {};
mog.urlSet = {};
mog.urlNPC = {};
mog.urlSpell = {};

function mog.addURL(name,fav,item,set,npc,spell)
	table.insert(mog.urlList,name);
	mog.urlFav[name] = fav;
	mog.urlItem[name] = item;
	mog.urlSet[name] = set;
	mog.urlNPC[name] = npc;
	mog.urlSpell[name] = spell;
end

mog.addURL("Battle.net","fav_wow",L["http://eu.battle.net/wow/en/item/%d"],nil,nil,nil);
mog.addURL("Wowhead","fav_wh",L["http://www.wowhead.com/item=%d"],L["http://www.wowhead.com/itemset=%d"],L["http://www.wowhead.com/npc=%d"],L["http://www.wowhead.com/spell=%d"]);
mog.addURL("MMO-Champion","fav_mmo","http://db.mmo-champion.com/i/%d/","http://db.mmo-champion.com/is/%d/","http://db.mmo-champion.com/c/%d/","http://db.mmo-champion.com/s/%d/");
mog.addURL("Wowpedia","fav_wp","http://www.wowpedia.org/index.php?search=\"{{elinks-item|%d}}\"","http://www.wowpedia.org/index.php?search=\"{{elinks-set|%d}}\"","http://www.wowpedia.org/index.php?search=\"{{elinks-NPC|%d}}\"","http://www.wowpedia.org/index.php?search=\"{{elinks-spell|%d}}\"");
mog.addURL("Thottbot","fav_tb","http://thottbot.com/item=%d","http://thottbot.com/itemset=%d","http://thottbot.com/npc=%d","http://thottbot.com/spell=%d");
mog.addURL("Buffed.de","fav_buff","http://wowdata.buffed.de/?i=%d","http://wowdata.buffed.de/?set=%d","http://wowdata.buffed.de/?n=%d","http://wowdata.buffed.de/?s=%d");
mog.addURL("JudgeHype","fav_jh","http://worldofwarcraft.judgehype.com/?page=objet&w=%d",nil,"http://worldofwarcraft.judgehype.com/index.php?page=pnj&w=%d","http://worldofwarcraft.judgehype.com/index.php?page=spell&w=%d");

StaticPopupDialogs["MOGIT_URL"] = {
	text = L["%s Item URL"],
	button1 = CLOSE,
	hasEditBox = 1,
	maxLetters = 512,
	editBoxWidth = 260,
	OnShow = function(self,item)
		self.editBox:SetText(mog.urlItem[mog.global.url]:format(item));
		self.editBox:SetFocus();
		self.editBox:HighlightText();
	end,
	EditBoxOnEnterPressed = function(self)
		self:GetParent():Hide();
	end,
	EditBoxOnEscapePressed = function(self)
		self:GetParent():Hide();
	end,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1
};