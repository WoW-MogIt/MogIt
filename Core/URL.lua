local MogIt, mog = ...
local L = mog.L

function mog:SetURLProvider(tbl)
	mog.urlProvider = tbl
end

function mog:ShowURL(id, sub)
	if not id then return end
	sub = sub or "item"
	local pathFormat = self.urlProvider and self.urlProvider[sub]
	if pathFormat then
		local path, bonusID
		if sub == "item" then
			id, bonusID = mog:ToNumberItem(id)
		end
		if type(pathFormat) == "function" then
			path = pathFormat(id, bonusID)
		else
			path = pathFormat:format(id, bonusID)
		end
		if path then
			StaticPopup_Show("MOGIT_URL", nil, nil, self.urlProvider.baseURL..path)
			return true
		end
	end
end

StaticPopupDialogs["MOGIT_URL"] = {
	text = L["URL"],
	button1 = CLOSE,
	hasEditBox = 1,
	maxLetters = 512,
	editBoxWidth = 260,
	OnShow = function(self,url)
		local editbox = self:GetEditBox()
		editbox:SetText(url)
		editbox:SetFocus()
		editbox:HighlightText()
	end,
	EditBoxOnEnterPressed = function(self)
		self:GetParent():Hide()
	end,
	EditBoxOnEscapePressed = function(self)
		self:GetParent():Hide()
	end,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1
}

mog:SetURLProvider({
	baseURL = L["http://www.wowhead.com/"],
	item = function(item, bonusID)
		return "item="..item..(bonusID and "&bonus="..bonusID or "")
	end,
	set = "itemset=%d",
	npc = "npc=%d",
	spell = "spell=%d",
	compare = function(tbl)
		local str
		for k, v in pairs(tbl) do
			local id, bonusID = mog:ToNumberItem(v)
			str = (str and str..":" or "compare?items=")..id..(bonusID and ".0.0.0.0.0.0.0.0.0."..bonusID or "")
		end
		return str
	end,
})
