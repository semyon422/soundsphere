local SkinInfo = require("sphere.models.NoteSkinModel.SkinInfo")
local OsuNoteSkin = require("sphere.models.NoteSkinModel.OsuNoteSkin")
local utf8validate = require("utf8validate")
local InputMode = require("ncdk.InputMode")

---@class sphere.OsuSkinInfo: sphere.SkinInfo
---@operator call: sphere.OsuSkinInfo
local OsuSkinInfo = SkinInfo + {}

function OsuSkinInfo:load()
	local content = love.filesystem.read(self:getPath())
	content = utf8validate(content)
	local skinini = OsuNoteSkin:parseSkinIni(content)

	self.name = skinini.General.Name
end

---@param inputMode string
---@return boolean
function OsuSkinInfo:matchInput(inputMode)  -- allow only Xkey input mode
	local _inputMode = InputMode(inputMode)

	local keys = _inputMode.key
	if not keys or next(_inputMode, "key") then
		return false
	end

	return true
end

---@param inputMode string
---@return sphere.OsuNoteSkin?
function OsuSkinInfo:loadSkin(inputMode)
	local _inputMode = InputMode(inputMode)
	local keys = _inputMode.key

	local path = self:getPath()
	print("load " .. path)

	local content = love.filesystem.read(path)
	content = utf8validate(content)
	local skinini = OsuNoteSkin:parseSkinIni(content)

	local files = OsuNoteSkin:processFiles(self.files)

	local noteSkin = OsuNoteSkin()
	noteSkin.files = files
	noteSkin.path = path
	noteSkin.directoryPath = self.dir
	noteSkin.fileName = self.file_name
	noteSkin.skinini = skinini
	noteSkin:setKeys(keys)
	noteSkin.inputMode = _inputMode
	local ok, err = xpcall(noteSkin.load, debug.traceback, noteSkin)
	if not ok then
		print(err)
		return
	end

	return noteSkin
end

return OsuSkinInfo
