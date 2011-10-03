local MogIt,mog = ...;
mog.L = setmetatable({},{__index = function(tbl,key)
	return key;
end});

--[[
if GetLocale() ~= "enUS" and GetLocale() ~= "enGB" then return end;
local L = mog.L;
--]]