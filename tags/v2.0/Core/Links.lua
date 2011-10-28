local MogIt,mog = ...;
local L = mog.L;

local charset = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
local base = #charset;
local maxlen = 3;

local function toBase(num)
	local str = "";
	while num > 0 do
		str = charset:sub((num%base)+1,(num%base)+1)..str;
		num = math.floor(num/base);
	end
	return str;
end

local function fromBase(str)
	local num = 0;
	for i=1,#str do
		num = num + ((charset:find(str:sub(i,i))-1) * base^(#str-i));
	end
	return num;
end

function mog:SetToLink(set)
	local link = "[MogIt:";
	for k,v in pairs(set) do
		link = link..("%0"..maxlen.."s"):format(toBase(v));
	end
	link = link.."]";
	return link;
end

function mog:LinkToSet(link)
	local set = {};
	local items = link:match("MogIt:([^%]:]+)");
	if items then
		for i=1,#items/maxlen do
			table.insert(set,fromBase(items:sub((i-1)*maxlen+1,i*maxlen)));
		end
	end
	return set;
end

local function filter(self,event,msg,...)
	msg = msg:gsub("%[(MogIt[^%]]+)%]","|cFFCC99FF|H%1|h[MogIt]|h|r");
	return false, msg, ...;
end
ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY",filter);
ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL",filter);
ChatFrame_AddMessageEventFilter("CHAT_MSG_GUILD",filter);
ChatFrame_AddMessageEventFilter("CHAT_MSG_EMOTE",filter);
ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY",filter);
ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID",filter);
ChatFrame_AddMessageEventFilter("CHAT_MSG_BATTLEGROUND",filter);
ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER",filter);
ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL",filter);
ChatFrame_AddMessageEventFilter("CHAT_MSG_BATTLEGROUND_LEADER",filter);
ChatFrame_AddMessageEventFilter("CHAT_MSG_OFFICER",filter);
ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_LEADER",filter);
ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_WARNING",filter);
ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM",filter);
ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER",filter);
ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER_INFORM",filter);
ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_CONVERSATION",filter);
ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_INLINE_TOAST_BROADCAST",filter);
ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_INLINE_TOAST_BROADCAST_INFORM",filter);

local old_SetItemRef = SetItemRef;
function SetItemRef(link,...)
	if link:find("^MogIt") then
		mog:AddToPreview(mog:LinkToSet(link));
	else
		return old_SetItemRef(link,...);
	end
end