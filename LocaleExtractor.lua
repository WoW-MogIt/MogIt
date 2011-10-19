local strings;
local output;

function getStrings(name)
	output = output.."\n\n\t--[[ "..name.." ]]--";
	local file = io.open(name,"r"):read("*all");
	for str in file:gmatch("L%[\"(.-[^\\])\"%]") do
		if not strings[str] then
			output = output.."\nL[\""..str.."\"] = true"
			strings[str] = true;
		end
	end
	if name:match(".xml$") then
		local dir = name:match("^(.+\\).-%.xml$");
		for lua in file:gmatch("<%s*Script %s*file%s*=%s*\"(.-%.lua)\"%s*/>") do
			getStrings(dir..lua);
		end
		for xml in file:gmatch("<%s*Include %s*file%s*=%s*\"(.-%.xml)\"%s*/>") do
			getStrings(dir..xml);
		end
	end
end

function getLocale(file,files)
	strings = {};
	output = "";
	for k,v in ipairs(files) do
		output = output.."\n\n";
		getStrings(v);
	end
	local list = io.open(file..".lua","w");
	list:write(output);
end

getLocale("LocaleList",{
	"Core\\Core.xml",
	"Filters\\Filters.xml",
	"Modules\\Modules.xml",
});
