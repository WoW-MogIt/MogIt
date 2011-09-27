local http = require("socket.http");

local ingame = loadfile("zonesIngame.lua")();
local manual = loadfile("zonesManual.lua")();
local wowhead = {};
local wowheadUrls = {
	"http://www.wowhead.com/zones=1",
	"http://www.wowhead.com/zones=0",
	"http://www.wowhead.com/zones=8",
	"http://www.wowhead.com/zones=10",
	"http://www.wowhead.com/zones=11",
	"http://www.wowhead.com/zones=9",
	"http://www.wowhead.com/zones=6",
	"http://www.wowhead.com/zones=2",
	"http://www.wowhead.com/zones=3",
};

for _,url in ipairs(wowheadUrls) do
	local page = http.request(url);
	if page then
		local list = page:match("new Listview%({.-data: %[({.-})%]}%);");
		if list then
			list = list..",";
			for unit in list:gmatch("{(.-)},") do
				unit = unit..",";
				local name = unit:match("\"name\":\"(.-)\",");
				local id = unit:match("\"id\":(.-),");
				wowhead[name] = id;
			end
		end
	end
end

local output = "return {";
local outputFile = io.open("map.lua","w");
local outputData = {};
for name,id in pairs(wowhead) do
	if ingame[name] then
		output = output.."\n\t[\""..id.."\"] = "..ingame[name]..",\t\t-- "..name;
		outputData[id] = ingame[name];
	elseif manual[id] then
		output = output.."\n\t[\""..id.."\"] = "..manual[id]..",\t\t-- "..name;
		outputData[id] = manual[id];
	end
end
output = output.."\n};";
outputFile:write(output);
outputFile:close();
output = nil;
return outputData;
