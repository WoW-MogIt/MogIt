local MogIt,mog = ...;
local L = mog.L;

local sites = {};

function mog:ShowURL(id,sub,url)
	url = url or mog.db.profile.url;
	sub = sub or "item";
	if sites[url] and sites[url][sub] then
		StaticPopup_Show("MOGIT_URL",sites[url].fav and "\124TInterface\\AddOns\\MogIt\\Images\\"..sites[url].fav..":18:18\124t " or "",url,sites[url][sub]:format(id));
		return true;
	end
end

StaticPopupDialogs["MOGIT_URL"] = {
	text = "%s%s "..L["URL"],
	button1 = CLOSE,
	hasEditBox = 1,
	maxLetters = 512,
	editBoxWidth = 260,
	OnShow = function(self,url)
		self.editBox:SetText(url);
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

sites["Battle.net"] = {
	fav = "fav_wow",
	--url = L["http://eu.battle.net/wow/en/"],
	item = L["http://eu.battle.net/wow/en/"].."item/%d",
};

sites["Wowhead"] = {
	fav = "fav_wh",
	--url = L["http://www.wowhead.com/"],
	item = L["http://www.wowhead.com/"].."item=%d",
	set = L["http://www.wowhead.com/"].."itemset=%d",
	npc = L["http://www.wowhead.com/"].."npc=%d",
	spell = L["http://www.wowhead.com/"].."spell=%d",
};

sites["MMO-Champion"] = {
	fav = "fav_mmo",
	--url = "http://db.mmo-champion.com/",
	item = "http://db.mmo-champion.com/i/%d/",
	set = "http://db.mmo-champion.com/is/%d/",
	npc = "http://db.mmo-champion.com/c/%d/",
	spell = "http://db.mmo-champion.com/s/%d/",
};

sites["Wowpedia"] = {
	fav = "fav_wp",
	--url = "http://www.wowpedia.org/"
	item = "http://www.wowpedia.org/index.php?search=\"{{elinks-item|%d}}\"",
	set = "http://www.wowpedia.org/index.php?search=\"{{elinks-set|%d}}\"",
	npc = "http://www.wowpedia.org/index.php?search=\"{{elinks-NPC|%d}}\"",
	spell = "http://www.wowpedia.org/index.php?search=\"{{elinks-spell|%d}}\"",
};

sites["Thottbot"] = {
	fav = "fav_tb",
	--url = "http://thottbot.com/"
	item = "http://thottbot.com/item=%d",
	set = "http://thottbot.com/itemset=%d",
	npc = "http://thottbot.com/npc=%d",
	spell = "http://thottbot.com/spell=%d",
};

sites["Buffed.de"] = {
	fav = "fav_buff",
	--url = "http://wowdata.buffed.de/"
	item = "http://wowdata.buffed.de/?i=%d",
	set = "http://wowdata.buffed.de/?set=%d",
	npc = "http://wowdata.buffed.de/?n=%d",
	spell = "http://wowdata.buffed.de/?s=%d",
};

sites["JudgeHype"] = {
	fav = "fav_jh",
	--url = "http://worldofwarcraft.judgehype.com/"
	item = "http://worldofwarcraft.judgehype.com/?page=objet&w=%d",
	npc = "http://worldofwarcraft.judgehype.com/index.php?page=pnj&w=%d",
	spell = "http://worldofwarcraft.judgehype.com/index.php?page=spell&w=%d",
};