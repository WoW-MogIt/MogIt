require "gd"

local addons,data = ...;

local function toHex(r,g,b)
	r = string.format("%X",r);
	r = r:len() == 1 and "0"..r or r;
	g = string.format("%X",g);
	g = g:len() == 1 and "0"..g or g;
	b = string.format("%X",b);
	b = b:len() == 1 and "0"..b or b;
	return r..g..b;
end

local function fromHex(hex)
	return tonumber(hex:sub(1,2),16),tonumber(hex:sub(3,4),16),tonumber(hex:sub(5,6),16);
end

local function similar(r1,g1,b1,c2)
	local r2,g2,b2 = fromHex(c2);
	local distance = ((r1-r2)^2)+((g1-g2)^2)+((b1-b2)^2);
	return distance <= 5000;
end

local function different(colour,colours,results)
	local r1,g1,b1 = fromHex(colour);
	for k,v in ipairs(results) do
		if similar(r1,g1,b1,v) then
			colours[v] = colours[v] + colours[colour];
			return false;
		end
	end
	return true;
end

local function getColours(display)
	local original = gd.createFromPng("images\\"..display..".png");
	local im = gd.createFromPng("images\\"..display..".png");

	if not im then return end

	local width,height = im:sizeXY();
	local list = {};
	local colours = {};

	im:trueColorToPalette(false,128);
	for x=0,(width-1) do
		for y=0,(height-1) do
			local p = original:getPixel(x,y);
			local a = original:alpha(p);
			if a ~= 127 then
				local c = im:getPixel(x,y);
				local r = im:red(c);
				local g = im:green(c);
				local b = im:blue(c);
				local hex = toHex(r,g,b);
				if not colours[hex] then
					colours[hex] = 1;
					table.insert(list,hex);
				else
					colours[hex] = colours[hex] + 1;
				end
			end
		end
	end

	if #list == 0 then return end

	table.sort(list,function(a,b)
		return colours[a] > colours[b];
	end);

	local results = {};
	for k,v in ipairs(list) do
		if different(v,colours,results) then
			table.insert(results,v);
		end
	end

	local top = {};
	for i=1,3 do
		if results[i] then
			top[results[i]] = colours[results[i]];
		end
	end
	return top;
end

local colours = {};
local displays = {};
os.execute("mkdir colours");
for addon,info in pairs(addons) do
	colours[addon] = {};
	for index,tbl in ipairs(info) do
		colours[addon][index] = {};
		local outputText = "return {";
		for _,item in ipairs(data[addon][index]) do
			local display = item:match("\"displayid\":(%d+),");
			if display and (not colours[addon][index][display]) then
				local c;
				if not displays[display] then
					c = getColours(display);
					displays[display] = c or true;
				elseif displays[display] ~= true then
					c = displays[display];
				end
				if c then
					colours[addon][index][display] = c;
					outputText = outputText.."\n\t[\""..display.."\"] = {";
					for k,v in pairs(c) do
						outputText = outputText.."\n\t\t[\""..k.."\"] = "..v..",";
					end
					outputText = outputText.."\n\t},";
				end
			end
		end
		outputText = outputText.."\n};";
		local outputFile = io.open("colours\\"..addon.."_"..tbl[1]..".lua","w");
		outputFile:write(outputText);
		outputFile:close();
		outputText = nil;
	end
end
displays = nil;
return colours;

