--local _data = true;
--local _images = true;
--local _zones = true;
--local _babble = true;
local _make = true;

local addons = loadfile("addons.lua")();
local data;
local zones;
local images;
local displays = loadfile("display.lua")();

local titlesFile = io.open("titles.lua","r");
local titlesText = titlesFile:read("*all");
local titles = {};
for x,y in titlesText:gmatch("%[\"(.-)\"%] = %[%[(.-)%]%],") do
	titles[x] = y;
end
titlesText = nil;
titlesFile:close();

local templateFile = io.open("toc.txt","r");
local templateText = templateFile:read("*all");
templateFile:close();

local babbleFile = io.open("LibBabble-Boss-3.0\\LibBabble-Boss-3.0.lua","r");
local babble = loadstring("return "..babbleFile:read("*all"):match("local GAME_LOCALE = GetLocale%(%)\n\nlib:SetBaseTranslations ({.-})"))();
babbleFile:close();

local function removeCode(str)
	if str then
		str = loadstring("return \""..str.."\"")();
		str = str:gsub("&quot;","\"");
		str = str:gsub("&amp;","&");
		str = str:gsub("&lt;","<");
		str = str:gsub("&gt;",">");
		return str;
	end
end

local function addCode(str)
	if str then
		str = str:gsub("\"","\\\"");
		return str;
	end
end

if _data then
	data = loadfile("wowhead.lua")(addons);
else
	data = {};
	for addon,info in pairs(addons) do
		data[addon] = {};
		for index,tbl in ipairs(info) do
			data[addon][index] = loadfile("wowhead\\"..addon.."_"..tbl[1]..".lua")();
		end
	end
end

if _zones then
	zones = loadfile("zones.lua")();
else
	zones = loadfile("map.lua")();
end

if _images then
	images = loadfile("images.lua")(addons,data);
else
	images = {};
	for addon,info in pairs(addons) do
		images[addon] = {};
		for index,tbl in ipairs(info) do
			images[addon][index] = loadfile("colours\\"..addon.."_"..tbl[1]..".lua")();
		end
	end
end

if not _make then return end

local oneHands = {
	["13"] = 1,	-- 1H
	["21"] = 2,	-- MH
	["22"] = 3,	-- OH
};
local sources = {
	["2"] = 1,	-- Drop
	["3"] = 2,	-- PvP
	["4"] = 3,	-- Quest
	["5"] = 4,	-- Vendor
	["1"] = 5,	-- Spell/Crafted
	["12"] = 6,	-- Achievement
	["8"] = 7,	-- Code Redemption
};
local diffs = {
	["-2"] = 2, -- 5H
	["-1"] = 1, -- 5N
	["1"] = 3, -- 10N
	["2"] = 4, -- 25N
	["3"] = 5, -- 10H
	["4"] = 6, -- 25H
	-- 7, -- Heroic
};
local proffs = {
	["171"] = 1, -- Alchemy
	["164"] = 2, -- Blacksmithing
	["333"] = 3, -- Enchanting
	["202"] = 4, -- Engineering
	["773"] = 5, -- Inscription
	["755"] = 6, -- Jewelcrafting
	["165"] = 7, -- Leatherworking
	["197"] = 8, -- Tailoring

	["182"] = 9, -- Herbalism
	["186"] = 10, -- Mining
	["393"] = 11, -- Skinning

	["794"] = 12, -- Archaeology
	["185"] = 13, -- Cooking
	["129"] = 14, -- First Aid
	["356"] = 15, -- Fishing
};
local qual = {
	["5"] = 2, -- Uncommon
	["4"] = 3, -- Rare
	["3"] = 4, -- Epic
	["0"] = 7, -- Heirloom
};
local replace = {
	--["OneHanded"] = "One-Hand",
	--["TwoHanded"] = "Two-Hand",
	["Shoulders"] = "Shoulder",
	["Wrists"] = "Wrist",
	["Cloak"] = "Back",
	["Shirts"] = "Shirt",
	["Tabards"] = "Tabard",
};

for addon,info in pairs(addons) do
	os.execute("mkdir MogIt_"..addon);
	local tocText = templateText:format(titles[addon]);
	local bossNames = {};
	local bossText = "local b=MogIt.addBoss";
	local colourDisplays = {};
	local colourText = "local c=MogIt.addColours";
	for index,tbl in ipairs(info) do
		local output = "local a,t=MogIt.addItem,MogIt.register(\""..(replace[tbl[1]] or tbl[1]).."\",...)";
		for _,item in ipairs(data[addon][index]) do
			local source = item:match("\"source\":%[(.-)%],");
			if source and source ~= "11" and source ~= "0" then
				local id = item:match("\"id\":(%d+),");
				local display = item:match("\"displayid\":(%d+),");
				local lvl = item:match("\"reqlevel\":(%d+),");
				--local ilvl = item:match("\"level\":(%d+),");
				local faction = item:match("\"side\":(%d+),");
				local class = item:match("\"reqclass\":(%d+),");
				local slot = item:match("\"slot\":(%d+),");
				local heroic = item:match("\"heroic\":1,");
				local quality = item:match("\"name\":\"(%d).-\",");
				--local name = item:match("\"name\":\"%d(.-)\",");
				local sourceMore = item:match("\"sourcemore\":%[{(.-)}%],");

				while displays[tonumber(display)] do
					display = ""..displays[tonumber(display)];
				end

				if (not colourDisplays[display]) and images[addon][index][display] then
					colourText = colourText.."\nc("..display;
					for k,v in pairs(images[addon][index][display]) do
						--colourText = colourText..",\""..k.."\","..v;
						colourText = colourText..",\""..k.."\"";
					end
					colourText = colourText..")";
					colourDisplays[display] = true;
				end

				output = output.."\na(t";
				output = output..","..id;
				output = output..","..display;
				output = output..","..(qual[quality] or "nil");
				output = output..","..(qual[quality] == 7 and "1" or lvl or "nil");
				output = output..","..(faction or "nil");
				output = output..","..(class or "nil");
				output = output..","..(addon == "OneHanded" and oneHands[slot] or "nil");
				output = output..","..(sources[source] or "nil");
				local sourceArg1 = ",nil"; -- ID
				local sourceArg2 = ",nil"; -- Zone
				local sourceArg3 = ",nil"; -- Profession / Difficulty
				if sourceMore then
					sourceMore = sourceMore..",";
					local sourceType = sourceMore:match("\"t\":(%d+),");
					local sourceID = sourceMore:match("\"ti\":(%d+),");
					local sourceZone = sourceMore:match("\"z\":(%d+),");
					local sourceCategory = sourceMore:match("\"c\":(%d+),");
					if source == "2" then -- Drop
						if (sourceType == "1" or sourceType == "2") and sourceID then
							local sourceName = removeCode(sourceMore:match("\"n\":\"(.-)\","));
							if babble[sourceName] then
								sourceID = (sourceType == "1" and "" or "-")..sourceID;
								if not bossNames[sourceID] then
									bossNames[sourceID] = sourceName;
									bossText = bossText.."\nb("..sourceID..",\""..addCode(sourceName).."\")";
								end
								sourceArg1 = ","..sourceID.."";
							end
						end
						local sourceDiff = sourceMore:match("\"dd\":(.-),");
						if diffs[sourceDiff] then
							-- source = source + diffs[sourceDiff];
							sourceArg3 = ","..diffs[sourceDiff];
						elseif heroic then
							sourceArg3 = ",7";
						end
					elseif source == "4" then -- Quest
						--||if sourceType == "5" then
						--||	sourceArg1 = ","..(sourceID or "nil");
						--||end
						if zones[sourceCategory] then
							sourceArg2 = ","..zones[sourceCategory];
						end
					elseif source == "1" then -- Crafted
						--||if sourceType == "6" then
						--||	sourceArg1 = ","..(sourceID or "nil");
						--||end
						if sourceCategory == "11" then
							local sourceProff = sourceMore:match("\"s\":(%d+),");
							if proffs[sourceProff] then
								sourceArg3 = ","..proffs[sourceProff];
							end
						end
					elseif source == "12" then -- Achievement
						if sourceType == "10" then
							sourceArg1 = ","..(sourceID or "nil");
						end
					end
					if zones[sourceZone] then
						sourceArg2 = ","..zones[sourceZone];
					end
				end
				output = output..sourceArg1..sourceArg2..sourceArg3;
				output = output..")";
			end
		end
		local file = io.open("MogIt_"..addon.."\\"..tbl[1]..".lua","w");
		file:write(output);
		file:close();
		output = nil;
		tocText = tocText.."\n"..tbl[1]..".lua";
	end
	local bossFile = io.open("MogIt_"..addon.."\\Bosses.lua","w");
	bossFile:write(bossText);
	bossFile:close();
	bossText = nil;
	bossNames = nil;
	local colourFile = io.open("MogIt_"..addon.."\\Colours.lua","w");
	colourFile:write(colourText);
	colourFile:close();
	colourText = nil;
	colourDisplays = nil;
	local tocFile = io.open("MogIt_"..addon.."\\MogIt_"..addon..".toc","w");
	tocFile:write(tocText);
	tocFile:close();
	tocText = nil;
end
