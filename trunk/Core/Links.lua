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
	local items = link:match("%[MogIt:(.-)%]");
	for i=1,#items/maxlen do
		table.insert(set,fromBase(items:sub((i-1)*maxlen+1,i*maxlen)));
	end
	return set;
end