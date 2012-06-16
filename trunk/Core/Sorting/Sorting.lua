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
		--UIDropDownMenu_EnableDropDown(mog.sorting);
		new = new or (mog.active.sorts[mog.sorting.active] and mog.sorting.active) or mog.active.sorting[1];
		if mog.sorting.active and (mog.sorting.active ~= new) and mog.sorting.sorts[mog.sorting.active].Unlist then
			mog.sorting.sorts[mog.sorting.active].Unlist();
		end
		mog.sorting.active = new;
		mog.sorting.sorts[new].Sort(mog.active.sorts[new]);
		--UIDropDownMenu_SetText(mog.sorting,mog.sorting.sorts[new].label);
		if not update then
			mog.scroll:update();
		end
	else
		--UIDropDownMenu_SetText(mog.sorting,NONE);
		--UIDropDownMenu_DisableDropDown(mog.sorting);
	end
end