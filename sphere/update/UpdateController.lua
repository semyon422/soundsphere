local class = require("class")
local UpdateModel = require("sphere.update.UpdateModel")
local ConfigModel = require("sphere.app.ConfigModel")
local WindowModel = require("sphere.app.WindowModel")
local thread = require("thread")
local delay = require("delay")

---@class sphere.UpdateController
---@operator call: sphere.UpdateController
local UpdateController = class()

function UpdateController:new()
	self.updateModel = UpdateModel()
	self.configModel = ConfigModel()
	self.windowModel = WindowModel()
end

---@return boolean?
function UpdateController:updateAsync()
	local updateModel = self.updateModel
	local configModel = self.configModel

	configModel:open("settings")
	configModel:open("urls")
	configModel:open("files", true)
	configModel:read()


	local configs = configModel.configs

	if
		not configs.settings.miscellaneous.autoUpdate or
		configs.urls.update == "" or
		love.filesystem.getInfo(".git")
	then
		return
	end

	self.windowModel:load(configs.settings.graphics)

	function love.update()
		thread.update()
		delay.update()
		self.windowModel:update()
	end

	function love.draw()
		love.graphics.printf(updateModel.status, 0, 0, love.graphics.getWidth())
	end

	local updated = updateModel:updateFilesAsync(
		configs.urls,
		configs.files
	)
	configModel:write()

	return updated
end

return UpdateController
