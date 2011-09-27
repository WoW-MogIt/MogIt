local addons = ...;
local http = require("socket.http");

local filters = "qu=2:3:4:7;cr=161;crs=1;crv=0;";
local filters2 = "cr=161;crs=1;crv=0;"
local levels = {
	{0,29},
	{30,59},
	{60,60},
	{61,69},
	{70,70},
	{71,79},
	{80,80},
	{81,84},
	{85,85},
};

local data = {};
os.execute("mkdir wowhead");
for addon,info in pairs(addons) do
	data[addon] = {};
	for index,tbl in ipairs(info) do
		data[addon][index] = {};
		local output = "return {";
		for i=2,#tbl do
			for _,lvl in ipairs(levels) do
				local page = http.request("http://www.wowhead.com/items="..tbl[i]..(addon ~= "Accessories" and filters or filters2).."minrl="..lvl[1]..";maxrl="..lvl[2]);
				if page then
					local list = page:match("new Listview%({.-data: %[({.-})%]}%);");
					if list then
						list = list..",";
						for unit in list:gmatch("{(.-)},") do
							unit = unit..",";
							output = output.."\n\t[["..unit.."]],";
							table.insert(data[addon][index],unit);
						end
					else
						print("noList",addon,tbl[1],tbl[i],lvl[1],lvl[2]);
					end
				else
					print("noPage",addon,tbl[1],tbl[i],lvl[1],lvl[2]);
				end
			end
		end
		output = output.."\n};";
		local file = io.open("wowhead\\"..addon.."_"..tbl[1]..".lua","w");
		file:write(output);
		file:close();
		output = nil;
	end
end
return data;
