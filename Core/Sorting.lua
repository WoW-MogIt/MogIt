local MogIt,mog = ...;
local L = mog.L;

mog.sorting.sorts = {};

function mog:CreateSort(name,data)
	data = data or {};
	data.name = name;
	mog.sorting.sorts[name] = data;
end

function mog:GetSort(name)
	return mog.sorting.sorts[name];
end

function mog:GetActiveSort()
	return mog.sorting.active;
end

function mog:SortList(new,update)
	if mog.active and mog.active.sorting and #mog.active.sorting > 0 then
		UIDropDownMenu_EnableDropDown(mog.sorting);
		new = new or (mog.active.sorts[mog.sorting.active] and mog.sorting.active) or mog.active.sorting[1];
		if mog.sorting.active and (mog.sorting.active ~= new) and mog.sorting.sorts[mog.sorting.active].Unlist then
			mog.sorting.sorts[mog.sorting.active].Unlist();
		end
		mog.sorting.active = new;
		mog.sorting.sorts[new].Sort(mog.active.sorts[new]);
		UIDropDownMenu_SetText(mog.sorting,mog.sorting.sorts[new].label);
		if not update then
			mog.scroll:update();
		end
	else
		UIDropDownMenu_SetText(mog.sorting,NONE);
		UIDropDownMenu_DisableDropDown(mog.sorting);
	end
end

do
	local colourCache = {};
	local cR,cG,cB = 255,255,255;
	local function colourScore(id,args)
		if not colourCache[id] then
			local distance = 195075;
			local colours = args and args(id);
			if colours then
				for k,v in pairs(colours) do
					local r,g,b = v:match("^(..)(..)(..)$");
					r = tonumber(r,16);
					g = tonumber(g,16);
					b = tonumber(b,16);
					local dist = ((cR-r)^2)+((cG-g)^2)+((cB-b)^2);
					if dist < distance then
						distance = dist;
					end
				end
			end
			colourCache[id] = distance;
		end
		return colourCache[id];
	end
	
	local function dropdownTier1(self)
		mog:SortList("colour");
	end
	
	local function swatchFunc()
		if not ColorPickerFrame:IsShown() then
			local r,g,b = ColorPickerFrame:GetColorRGB();
			cR,cG,cB = r*255,g*255,b*255;
			mog:SortList("colour");
		end
	end
	
	mog:CreateSort("colour",{
		label = L["Approximate Colour"],
		Dropdown = function(module,tier)
			local info;
			if tier == 1 then
				info = UIDropDownMenu_CreateInfo();
				info.text =	L["Approximate Colour"];
				info.value = "colour";
				info.func = dropdownTier1;
				info.checked = mog.sorting.active == "colour";
				info.hasColorSwatch = true;
				info.r = cR/255;
				info.g = cG/255;
				info.b = cB/255;
				info.swatchFunc = swatchFunc;
				UIDropDownMenu_AddButton(info);
			end
		end,
		Sort = function(args)
			wipe(colourCache);
			table.sort(mog.list,function(a,b)
				return colourScore(a,args) < colourScore(b,args);
			end);
		end,
		Unlist = function()
			wipe(colourCache);
		end,
	});
end

do
	local itemCache = {};
	local function minItem(id,args)
		if not itemCache[display] then
			local levels = args and args(id);
			if type(levels) == "table" then
				for k,v in pairs(levels) do
					if (not itemCache[id]) or (v and (v < itemCache[id])) then
						itemCache[id] = v;
					end
				end
				itemCache[id] = itemCache[id] or 0;
			else
				itemCache[id] = levels or 0;
			end
		end
		return itemCache[id];
	end
	
	local function dropdownTier1(self)
		mog:SortList("level");
	end
	
	mog:CreateSort("level",{
		label = LEVEL,
		Dropdown = function(module,tier)
			local info;
			info = UIDropDownMenu_CreateInfo();
			info.text = LEVEL;
			info.value = "level";
			info.func = dropdownTier1;
			info.checked = mog.sorting.active == "level";
			UIDropDownMenu_AddButton(info);
		end,
		Sort = function(args)
			wipe(itemCache);
			table.sort(mog.list,function(a,b)
				return minItem(a,args) > minItem(b,args);
			end);
		end,
		Unlist = function()
			wipe(itemCache);
		end,
	});
end