local MogIt,mog = ...;
local L = mog.L;

local L = {
	default = "Default",
	reset = "Reset profile",
	choose_desc = "You can either create a new profile by entering a name in the editbox, or choose one of the already existing profiles.",
	new = "New",
	choose = "Existing profiles",
	copy_desc = "Copy the settings from one existing profile into the currently active profile.",
	copy = "Copy From",
	delete_desc = "Delete existing and unused profiles from the database to save space, and cleanup the SavedVariables file.",
	delete = "Delete a profile",
	delete_confirm = "Are you sure you want to delete the selected profile?",
	profiles = "Profiles",
	current = "Current profile:",
}

local LOCALE = GetLocale()
if LOCALE == "deDE" then
	L["default"] = "Standard"
	L["reset"] = "Profil zur\195\188cksetzen"
	L["choose_desc"] = "Du kannst ein neues Profil erstellen, indem du einen neuen Namen in der Eingabebox 'Neu' eingibst, oder w\195\164hle eines der vorhandenen Profile aus."
	L["new"] = "Neu"
	L["choose"] = "Vorhandene Profile"
	L["copy_desc"] = "Kopiere die Einstellungen von einem vorhandenen Profil in das aktive Profil."
	L["copy"] = "Kopieren von..."
	L["delete_desc"] = "L\195\182sche vorhandene oder unbenutzte Profile aus der Datenbank um Platz zu sparen und um die SavedVariables Datei 'sauber' zu halten."
	L["delete"] = "Profil l\195\182schen"
	L["delete_confirm"] = "Willst du das ausgew\195\164hlte Profil wirklich l\195\182schen?"
	L["profiles"] = "Profile"
	--L["current"] = "Current Profile:"
elseif LOCALE == "frFR" then
	L["default"] = "D\195\169faut"
	L["reset"] = "R\195\169initialiser le profil"
	L["choose_desc"] = "Vous pouvez cr\195\169er un nouveau profil en entrant un nouveau nom dans la bo\195\174te de saisie, ou en choississant un des profils d\195\169j\195\160 existants."
	L["new"] = "Nouveau"
	L["choose"] = "Profils existants"
	L["copy_desc"] = "Copie les param\195\168tres d'un profil d\195\169j\195\160 existant dans le profil actuellement actif."
	L["copy"] = "Copier \195\160 partir de"
	L["delete_desc"] = "Supprime les profils existants inutilis\195\169s de la base de donn\195\169es afin de gagner de la place et de nettoyer le fichier SavedVariables."
	L["delete"] = "Supprimer un profil"
	L["delete_confirm"] = "Etes-vous s\195\187r de vouloir supprimer le profil s\195\169lectionn\195\169 ?"
	L["profiles"] = "Profils"
elseif LOCALE == "koKR" then
	L["default"] = "기본값"
	L["reset"] = "프로필 초기화"
	L["choose_desc"] = "새로운 이름을 입력하거나, 이미 있는 프로필중 하나를 선택하여 새로운 프로필을 만들 수 있습니다."
	L["new"] = "새로운 프로필"
	L["choose"] = "프로필 선택"
	L["copy_desc"] = "현재 사용중인 프로필에, 선택한 프로필의 설정을 복사합니다."
	L["copy"] = "복사"
	L["delete_desc"] = "데이터베이스에 사용중이거나 저장된 프로파일 삭제로 SavedVariables 파일의 정리와 공간 절약이 됩니다."
	L["delete"] = "프로필 삭제"
	L["delete_confirm"] = "정말로 선택한 프로필의 삭제를 원하십니까?"
	L["profiles"] = "프로필"
	-- L["current"] = "Current Profile:"
elseif LOCALE == "esES" or LOCALE == "esMX" then
	L["default"] = "Por defecto"
	L["reset"] = "Reiniciar Perfil"
	L["choose_desc"] = "Puedes crear un nuevo perfil introduciendo un nombre en el recuadro o puedes seleccionar un perfil de los ya existentes."
	L["new"] = "Nuevo"
	L["choose"] = "Perfiles existentes"
	L["copy_desc"] = "Copia los ajustes de un perfil existente al perfil actual."
	L["copy"] = "Copiar de"
	L["delete_desc"] = "Borra los perfiles existentes y sin uso de la base de datos para ganar espacio y limpiar el archivo SavedVariables."
	L["delete"] = "Borrar un Perfil"
	L["delete_confirm"] = "¿Estas seguro que quieres borrar el perfil seleccionado?"
	L["profiles"] = "Perfiles"
	--L["current"] = "Current Profile:"
elseif LOCALE == "zhTW" then
	L["default"] = "預設"
	L["reset"] = "重置設定檔"
	L["choose_desc"] = "你可以通過在文本框內輸入一個名字創立一個新的設定檔，也可以選擇一個已經存在的設定檔。"
	L["new"] = "新建"
	L["choose"] = "現有的設定檔"
	L["copy_desc"] = "從當前某個已保存的設定檔複製到當前正使用的設定檔。"
	L["copy"] = "複製自"
	L["delete_desc"] = "從資料庫裏刪除不再使用的設定檔，以節省空間，並且清理SavedVariables檔。"
	L["delete"] = "刪除一個設定檔"
	L["delete_confirm"] = "你確定要刪除所選擇的設定檔嗎？"
	L["profiles"] = "設定檔"
	--L["current"] = "Current Profile:"
elseif LOCALE == "zhCN" then
	L["default"] = "默认"
	L["reset"] = "重置配置文件"
	L["choose_desc"] = "你可以通过在文本框内输入一个名字创立一个新的配置文件，也可以选择一个已经存在的配置文件。"
	L["new"] = "新建"
	L["choose"] = "现有的配置文件"
	L["copy_desc"] = "从当前某个已保存的配置文件复制到当前正使用的配置文件。"
	L["copy"] = "复制自"
	L["delete_desc"] = "从数据库里删除不再使用的配置文件，以节省空间，并且清理SavedVariables文件。"
	L["delete"] = "删除一个配置文件"
	L["delete_confirm"] = "你确定要删除所选择的配置文件么？"
	L["profiles"] = "配置文件"
	--L["current"] = "Current Profile:"
elseif LOCALE == "ruRU" then
	L["default"] = "По умолчанию"
	L["reset"] = "Сброс профиля"
	L["choose_desc"] = "Вы можете создать новый профиль, введя название в поле ввода, или выбрать один из уже существующих профилей."
	L["new"] = "Новый"
	L["choose"] = "Существующие профили"
	L["copy_desc"] = "Скопировать настройки из выбранного профиля в активный."
	L["copy"] = "Скопировать из"
	L["delete_desc"] = "Удалить существующий и неиспользуемый профиль из БД для сохранения места, и очистить SavedVariables файл."
	L["delete"] = "Удалить профиль"
	L["delete_confirm"] = "Вы уверены, что вы хотите удалить выбранный профиль?"
	L["profiles"] = "Профили"
	--L["current"] = "Current Profile:"
end


-- editbox
local function createEditBox(parent)
	local editbox = CreateFrame("EditBox", nil, parent)
	editbox:SetAutoFocus(false)
	editbox:SetHeight(20)
	editbox:SetFontObject("ChatFontNormal")
	editbox:SetTextInsets(5, 0, 0, 0)

	local left = editbox:CreateTexture("BACKGROUND")
	left:SetTexture("Interface\\Common\\Common-Input-Border")
	left:SetTexCoord(0, 0.0625, 0, 0.625)
	left:SetWidth(8)
	left:SetPoint("TOPLEFT")
	left:SetPoint("BOTTOMLEFT")

	local right = editbox:CreateTexture("BACKGROUND")
	right:SetTexture("Interface\\Common\\Common-Input-Border")
	right:SetTexCoord(0.9375, 1, 0, 0.625)
	right:SetWidth(8)
	right:SetPoint("TOPRIGHT")
	right:SetPoint("BOTTOMRIGHT")

	local mid = editbox:CreateTexture("BACKGROUND")
	mid:SetTexture("Interface\\Common\\Common-Input-Border")
	mid:SetTexCoord(0.0625, 0.9375, 0, 0.625)
	mid:SetPoint("TOPLEFT", left, "TOPRIGHT")
	mid:SetPoint("BOTTOMRIGHT", right, "BOTTOMLEFT")
	
	return editbox
end

-- dropdown menu frame
local function setSelectedValue(self, value)
	UIDropDownMenu_SetSelectedValue(self, value)
	UIDropDownMenu_SetText(self, self.menu and self.menu[value] or value)
end

local function setDisabled(self, disable)
	if disable then
		self:Disable()
	else
		self:Enable()
	end
end

local function initialize(self)
	local onClick = self.onClick
	for _, v in ipairs(self.menu) do
		local info = UIDropDownMenu_CreateInfo()
		info.text = v.text
		info.value = v.value
		info.func = onClick or v.func
		info.owner = self
		info.fontObject = v.fontObject
		UIDropDownMenu_AddButton(info)
	end
end

local function createDropDownMenu(name, parent, menu, valueLookup)
	local frame = CreateFrame("Frame", name, parent, "UIDropDownMenuTemplate")
	
	frame.SetFrameWidth = UIDropDownMenu_SetWidth
	frame.SetSelectedValue = setSelectedValue
	frame.GetSelectedValue = UIDropDownMenu_GetSelectedValue
	frame.Refresh = UIDropDownMenu_Refresh
	frame.SetText = UIDropDownMenu_SetText
	frame.Enable = UIDropDownMenu_EnableDropDown
	frame.Disable = UIDropDownMenu_DisableDropDown
	frame.SetDisabled = setDisabled
	frame.JustifyText = UIDropDownMenu_JustifyText
	
	if menu then
		for _, v in ipairs(menu) do
			menu[v.value] = v.text
		end
	end
	frame.menu = menu or valueLookup
	
	frame.initialize = initialize
	
	local label = frame:CreateFontString(name.."Label", "BACKGROUND", "GameFontNormalSmall")
	label:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", 16, 3)
	frame.label = label
	
	return frame
end


local options = CreateFrame("Frame")
options.name = MogIt
InterfaceOptions_AddCategory(options)


local defaultProfiles = {}


local function profileSort(a, b)
	return a.value < b.value
end

local tempProfiles = {}

local function getProfiles(db, common, nocurrent)
	local profiles = {}
	
	-- copy existing profiles into the table
	local currentProfile = db:GetCurrentProfile()
	for _, v in ipairs(db:GetProfiles(tempProfiles)) do 
		if not (nocurrent and v == currentProfile) then 
			profiles[v] = v 
		end 
	end
	
	-- add our default profiles to choose from ( or rename existing profiles)
	for k, v in pairs(defaultProfiles) do
		if (common or profiles[k]) and not (nocurrent and k == currentProfile) then
			profiles[k] = v
		end
	end
	
	local sortProfiles = {}
	local n = 1
	
	for k, v in pairs(profiles) do
		sortProfiles[n] = {text = v, value = k}
		n = n + 1
	end
	
	sort(sortProfiles, profileSort)
	
	return sortProfiles
end


local function createFontString(parent)
	local text = parent:CreateFontString(nil, "BACKGROUND", "GameFontHighlightSmall")
	-- text:SetHeight(32)
	text:SetPoint("LEFT", 32, 0)
	text:SetPoint("RIGHT", -32, 0)
	text:SetJustifyH("LEFT")
	text:SetJustifyV("TOP")
	return text
end


local function profilesLoaded(self)
	if self.db then
		db = mog:GetModule(self.db).db
	else
		db = mog.db
	end
	self.db = db
	
	self:SetScript("OnShow", nil)
	
	for k, object in pairs(self.objects) do
		object.db = db
		self[k] = object
	end
	
	db.RegisterCallback(self, "OnProfileChanged")
	db.RegisterCallback(self, "OnNewProfile")
	db.RegisterCallback(self, "OnProfileDeleted")
	
	local keys = db.keys
	defaultProfiles["Default"] = L.default
	defaultProfiles[keys.char] = keys.char
	defaultProfiles[keys.realm] = keys.realm
	defaultProfiles[keys.class] = UnitClass("player")
	
	self.currProfile:SetFormattedText("Current profile: %s%s%s", NORMAL_FONT_COLOR_CODE, db:GetCurrentProfile(), FONT_COLOR_CODE_CLOSE)
	
	self.choose:SetSelectedValue(db:GetCurrentProfile())
	
	self:CheckProfiles()
end

local function onProfileChanged(self, event, db, profile)
	self.currProfile:SetFormattedText("Current profile: %s%s%s", NORMAL_FONT_COLOR_CODE, profile, FONT_COLOR_CODE_CLOSE)
	self.choose:SetSelectedValue(profile)
	self:CheckProfiles()
end

local function onNewProfile(self, event, db, profile)
	self:CheckProfiles()
end

local function onProfileDeleted(self, event, db, profile)
	self:CheckProfiles()
end

local function checkProfiles(self)
	local hasNoProfiles = self:HasNoProfiles()
	self.copy:SetDisabled(hasNoProfiles)
	self.delete:SetDisabled(hasNoProfiles)
end

local function hasNoProfiles(self)
	return next(getProfiles(self.db, nil, true)) == nil
end


local function initializeDropdown(self)
	for _, v in ipairs(getProfiles(self.db, self.common, self.nocurrent)) do
		local info = UIDropDownMenu_CreateInfo()
		info.text = v.text
		info.value = v.value
		info.func = self.func
		info.owner = self
		UIDropDownMenu_AddButton(info)
	end
end

local function newProfileOnEnterPressed(self)
	self.db:SetProfile(self:GetText())
	self:SetText("")
	self:ClearFocus()
end

local function chooseProfileOnClick(self)
	self.owner.db:SetProfile(self.value)
end

local function copyProfileOnClick(self)
	self.owner.db:CopyProfile(self.value)
end

local function deleteProfileOnClick(self)
	UIDropDownMenu_SetSelectedValue(self.owner, self.value)
	StaticPopup_Show("MOGIT_DELETE_PROFILE", nil, nil, {db = self.owner.db, obj = self.owner})
end


local function createProfileUI(name, module)
	local frame = CreateFrame("Frame")
	frame.name = name
	frame.parent = MogIt
	InterfaceOptions_AddCategory(frame)
	
	frame.db = module
	
	frame.ProfilesLoaded = profilesLoaded
	frame.OnProfileChanged = onProfileChanged
	frame.OnNewProfile = onNewProfile
	frame.OnProfileDeleted = onProfileDeleted
	
	-- addon.RegisterCallback(frame, "AddonLoaded", "ProfilesLoaded")
	frame:SetScript("OnShow", frame.ProfilesLoaded)
	
	frame.CheckProfiles = checkProfiles
	frame.HasNoProfiles = hasNoProfiles
	
	local objects = {}
	frame.objects = objects
	
	local reset = CreateFrame("Button", "MogItResetDBButton"..name, frame, "UIPanelButtonTemplate2")
	reset:SetSize(160, 22)
	reset:SetPoint("TOPLEFT", 32, -32)
	reset:SetScript("OnClick", function(self) self.db:ResetProfile() end)
	reset:SetText(L.reset)
	objects.reset = reset

	local currProfile = frame:CreateFontString(nil, "BACKGROUND", "GameFontHighlightSmall")
	currProfile:SetPoint("LEFT", reset, "RIGHT")
	currProfile:SetJustifyH("LEFT")
	currProfile:SetJustifyV("CENTER")
	objects.currProfile = currProfile

	-- local chooseDesc = createFontString(frame)
	-- chooseDesc:SetHeight(32)
	-- chooseDesc:SetPoint("TOP", reset, "BOTTOM", 0, -8)
	-- chooseDesc:SetWordWrap(true)
	-- chooseDesc:SetText(L.choose_desc)

	local newProfile = createEditBox(frame)
	newProfile:SetWidth(160)
	newProfile:SetPoint("TOPLEFT", reset, "BOTTOMLEFT", 0, -16)
	newProfile:SetScript("OnEscapePressed", newProfile.ClearFocus)
	newProfile:SetScript("OnEnterPressed", newProfileOnEnterPressed)
	objects.newProfile = newProfile

	local label = newProfile:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	label:SetPoint("BOTTOMLEFT", newProfile, "TOPLEFT", 0, -2)
	label:SetPoint("BOTTOMRIGHT", newProfile, "TOPRIGHT", 0, -2)
	label:SetJustifyH("LEFT")
	label:SetHeight(18)
	label:SetText(L.new)

	local choose = createDropDownMenu("MogItChooseProfile"..name, frame, nil, defaultProfiles)
	choose:SetFrameWidth(144)
	choose:SetPoint("LEFT", newProfile, "RIGHT", 0, -2)
	choose.label:SetText(L.choose)
	choose.initialize = initializeDropdown
	choose.func = chooseProfileOnClick
	choose.common = true
	objects.choose = choose

	-- local copyDesc = createFontString(frame)
	-- copyDesc:SetHeight(32)
	-- copyDesc:SetPoint("TOP", choose, "BOTTOM", 0, -8)
	-- copyDesc:SetWordWrap(true)
	-- copyDesc:SetText(L.copy_desc)

	local copy = createDropDownMenu("MogItCopyProfile"..name, frame, nil, defaultProfiles)
	copy:SetFrameWidth(144)
	copy:SetPoint("TOPLEFT", newProfile, "BOTTOMLEFT", 0, -16)
	copy.label:SetText(L.copy)
	copy.initialize = initializeDropdown
	copy.func = copyProfileOnClick
	copy.nocurrent = true
	objects.copy = copy

	-- local deleteDesc = createFontString(frame)
	-- deleteDesc:SetHeight(32)
	-- deleteDesc:SetPoint("TOP", copy, "BOTTOM", 0, -8)
	-- deleteDesc:SetWordWrap(true)
	-- deleteDesc:SetText(L.delete_desc)

	local delete = createDropDownMenu("MogItDeleteProfile"..name, frame, nil, defaultProfiles)
	delete:SetFrameWidth(144)
	delete:SetPoint("TOPLEFT", copy, "BOTTOMLEFT", 0, -16)
	delete.label:SetText(L.delete)
	delete.initialize = initializeDropdown
	delete.func = deleteProfileOnClick
	delete.nocurrent = true
	objects.delete = delete
	
	return frame
end

StaticPopupDialogs["MOGIT_DELETE_PROFILE"] = {
	text = L.delete_confirm,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(self, data)
		local delete = data.obj
		self.data.db:DeleteProfile(delete:GetSelectedValue())
		delete:SetSelectedValue(nil)
	end,
	OnCancel = function(self, data)
		data.obj:SetSelectedValue(nil)
	end,
	whileDead = true,
	timeout = 0,
}

createProfileUI("Profiles")
createProfileUI("Wishlist profiles", "Wishlist")