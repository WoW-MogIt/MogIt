local MogIt, mog = ...;
local L = mog.L;

local charset = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
local base = #charset;
local maxlen = 3;

local function toBase(num)
	local str;
	if num <= 0 then
		str = "0";
	else
		str = "";
		while num > 0 do
			str = charset:sub((num%base)+1, (num%base)+1)..str;
			num = math.floor(num/base);
		end
	end
	return str;
end

local function fromBase(str)
	local num = 0;
	for i=1, #str do
		num = num + ((charset:find(str:sub(i, i))-1) * base^(#str-i));
	end
	return num;
end

function mog:SetToLink(set, race, gender, enchant)
	local items = {};
	for k, v in pairs(set) do
		local itemID, bonusID = mog:ToNumberItem(v);
		if bonusID then
			tinsert(items, format("%s.%s", toBase(itemID), toBase(bonusID)));
		else
			tinsert(items, toBase(itemID));
		end
	end
	return format("[MogIt:%s:%s%s:%s]", table.concat(items, ";"), toBase(race or mog.playerRace), (gender or mog.playerGender), toBase(enchant or 0));
end

function mog:LinkToSet(link)
	local set = {};
	-- local items, race, gender, enchant = strsplit(":", link:match("MogIt:(.+)"));
	local items, race, gender, enchant = link:match("MogIt:([^:]*):?(%w?)(%w?):?(%w*)");
	if items then
		if items:find("[.;]") then
			for item in gmatch(items, "[^;]+") do
				local itemID, bonusID = strsplit(".", item);
				table.insert(set, mog:ToStringItem(tonumber(fromBase(itemID)), bonusID and tonumber(fromBase(bonusID))));
			end
		else
			for i = 1, #items/maxlen do
				local itemID = items:sub((i-1)*maxlen+1, i*maxlen);
				table.insert(set, mog:ToStringItem(tonumber(fromBase(itemID))));
			end
		end
	end
	race = race and fromBase(race);
	gender = tonumber(gender);
	enchant = enchant ~= "" and fromBase(enchant) or nil;
	return set, race, gender, enchant;
end

local function filter(self, event, msg, ...)
	msg = msg:gsub("%[(MogIt[^%]]+)%]","|cffcc99ff|H%1|h[MogIt]|h|r");
	return false, msg, ...;
end

local events = {
	"CHAT_MSG_SAY",
	"CHAT_MSG_YELL",
	"CHAT_MSG_EMOTE",
	"CHAT_MSG_GUILD",
	"CHAT_MSG_OFFICER",
	"CHAT_MSG_PARTY",
	"CHAT_MSG_PARTY_LEADER",
	"CHAT_MSG_RAID",
	"CHAT_MSG_RAID_LEADER",
	"CHAT_MSG_RAID_WARNING",
	"CHAT_MSG_BATTLEGROUND",
	"CHAT_MSG_BATTLEGROUND_LEADER",
	"CHAT_MSG_WHISPER",
	"CHAT_MSG_WHISPER_INFORM",
	"CHAT_MSG_BN_WHISPER",
	"CHAT_MSG_BN_WHISPER_INFORM",
	"CHAT_MSG_BN_CONVERSATION",
	"CHAT_MSG_BN_INLINE_TOAST_BROADCAST",
	"CHAT_MSG_BN_INLINE_TOAST_BROADCAST_INFORM",
	"CHAT_MSG_CHANNEL",
};

for i, event in ipairs(events) do
	ChatFrame_AddMessageEventFilter(event, filter);
end

local SetHyperlink = ItemRefTooltip.SetHyperlink;
function ItemRefTooltip:SetHyperlink(link)
	if link:find("^MogIt") then
		if IsModifiedClick("CHATLINK") then
			ChatEdit_InsertLink("["..link.."]")
		else
			local preview = mog:GetPreview();
			local set, race, gender, enchant = mog:LinkToSet(link);
			if race and gender then
				preview.data.displayRace = race;
				preview.data.displayGender = gender;
				preview.data.weaponEnchant = enchant;
				preview.model:ResetModel();
				preview.model:Undress();
			end
			mog:AddToPreview(set, preview);
		end
	else
		SetHyperlink(self, link);
	end
end