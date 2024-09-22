local strings = { }
local files = { }

function getStrings(filePath)
	local content = io.open(filePath, "r"):read("*all")

	if filePath:match(".xml$") then
		local dir = filePath:match("^(.+\\).-%.xml$")
		for fileName in content:gmatch("<%s*Script %s*file%s*=%s*\"(.-%.lua)\"%s*/>") do
			getStrings(dir..fileName)
		end
		for fileName in content:gmatch("<%s*Include %s*file%s*=%s*\"(.-%.xml)\"%s*/>") do
			getStrings(dir..fileName)
		end
		return
	end

	local file = {
		path = filePath,
		strings = { },
	}

	table.insert(files, file)

	for str in content:gmatch("L%[\"(.-[^\\])\"%]") do
		if not strings[str] then
			table.insert(file.strings, "L[\""..str.."\"] = true")
			strings[str] = true
		end
	end
end

function getLocale(file, indexFiles)
	local output = { }

	for i, filePath in ipairs(indexFiles) do
		getStrings(filePath)
	end

	table.sort(files, function(a, b) return a.path:lower() < b.path:lower() end)

	for i, file in ipairs(files) do
		table.sort(file.strings, function(a, b) return a:lower() < b:lower() end)
		if #file.strings > 0 then
			table.insert(output, string.format("--[[ %s ]]--\n%s", file.path, table.concat(file.strings, "\n")))
		end
	end

	local list = io.open(file..".lua", "w")
	list:write(table.concat(output, "\n\n"))
end

getLocale("LocaleList", {
	"Core\\Core.xml",
	"Modules\\Modules.xml",
})
