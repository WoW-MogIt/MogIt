local MogIt,mog = ...;
_G["MogIt"] = mog;
local L = mog.L;

local GetSpellName = C_Spell.GetSpellName


--// Useful Lists
L.source = { }

for i = 1, C_TransmogCollection.GetNumTransmogSources() do
	L.source[i] = _G["TRANSMOG_SOURCE_"..i]
end

L.diffs = {
	[1] = PLAYER_DIFFICULTY1,
	[2] = PLAYER_DIFFICULTY2,

	[3] = L["10N"],
	[4] = L["25N"],
	[5] = L["10H"],
	[6] = L["25H"],

	[7] = PLAYER_DIFFICULTY3, -- Raid Finder
	[8] = PLAYER_DIFFICULTY1, -- Normal
	[9] = PLAYER_DIFFICULTY2, -- Heroic
	[10] = PLAYER_DIFFICULTY6, -- Mythic
};

L.difficulties = {
	[1] = DUNGEON_DIFFICULTY_5PLAYER;
	[2] = DUNGEON_DIFFICULTY_5PLAYER_HEROIC;

	[3] = RAID_DIFFICULTY_10PLAYER;
	[4] = RAID_DIFFICULTY_25PLAYER;
	[5] = RAID_DIFFICULTY_10PLAYER_HEROIC;
	[6] = RAID_DIFFICULTY_25PLAYER_HEROIC;

	[7] = PLAYER_DIFFICULTY3, -- Raid Finder
	[8] = PLAYER_DIFFICULTY1, -- Normal
	[9] = PLAYER_DIFFICULTY2, -- Heroic
	[10] = PLAYER_DIFFICULTY6, -- Mythic
};

L.slots = {
	[1] = INVTYPE_WEAPON,
	[2] = INVTYPE_WEAPONMAINHAND,
	[3] = INVTYPE_WEAPONOFFHAND,
};

L.professions = {
	[1] = GetSpellName(2259), -- Alchemy
	[2] = GetSpellName(2018), -- Blacksmithing
	[3] = GetSpellName(7411), -- Enchanting
	[4] = GetSpellName(4036), -- Engineering
	[5] = GetSpellName(45357), -- Inscription
	[6] = GetSpellName(25229), -- Jewelcrafting
	[7] = GetSpellName(2108), -- Leatherworking
	[8] = GetSpellName(3908), -- Tailoring

	[9] = GetSpellName(2366), -- Herbalism
	[10] = GetSpellName(2575), -- Mining
	[11] = GetSpellName(8613), -- Skinning

	[12] = GetSpellName(78670), -- Archaeology
	[13] = GetSpellName(2550), -- Cooking
	[14] = GetSpellName(3273), -- First Aid
	[15] = GetSpellName(7620), -- Fishing
};

L.quality = {
	Enum.ItemQuality.Poor,
	Enum.ItemQuality.Common,
	Enum.ItemQuality.Uncommon,
	Enum.ItemQuality.Rare,
	Enum.ItemQuality.Epic,
	Enum.ItemQuality.Legendary,
	Enum.ItemQuality.Artifact,
	Enum.ItemQuality.Heirloom,
};

L.classBits = {
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
	MONK = 512,
	DEMONHUNTER = 2048,
	EVOKER = 4096,
};

L.bind = {
	[Enum.ItemBind.None] = NONE,
	[Enum.ItemBind.OnEquip] = ITEM_BIND_ON_EQUIP,
	[Enum.ItemBind.OnAcquire] = ITEM_BIND_ON_PICKUP,
	-- [4] = ITEM_BIND_TO_BNETACCOUNT,
};
--//