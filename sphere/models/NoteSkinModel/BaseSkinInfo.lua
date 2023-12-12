local SkinInfo = require("sphere.models.NoteSkinModel.SkinInfo")
local BaseNoteSkin = require("sphere.models.NoteSkinModel.BaseNoteSkin")

---@class sphere.BaseSkinInfo: sphere.SkinInfo
---@operator call: sphere.BaseSkinInfo
local BaseSkinInfo = SkinInfo + {}

BaseSkinInfo.name = "base skin"

---@return string
function BaseSkinInfo:getPath()
	return "base"
end

---@param inputMode string
---@return boolean
function BaseSkinInfo:matchInput(inputMode)
	return true
end

---@param inputMode string
---@return sphere.BaseNoteSkin?
function BaseSkinInfo:loadSkin(inputMode)
	print("load base skin")
	local noteSkin = BaseNoteSkin()
	noteSkin.directoryPath = "resources"
	noteSkin.path = self:getPath()
	noteSkin:load(inputMode)
	return noteSkin
end

return BaseSkinInfo
