local Class = require("Class")
local UpdateModel = require("sphere.models.UpdateModel")
local ConfigModel = require("sphere.models.ConfigModel")
local WindowModel = require("sphere.models.WindowModel")
local thread = require("thread")
local delay = require("delay")

local UpdateController = Class:new()

UpdateController.construct = function(self)
	self.updateModel = UpdateModel:new()
	self.configModel = ConfigModel:new()
	self.windowModel = WindowModel:new()

	for k, v in pairs(self) do
		v.game = self
	end
end

UpdateController.updateAsync = function(self)
	local updateModel = self.updateModel
	local configModel = self.configModel

	configModel:read("settings", "urls", "files")

	local configs = configModel.configs

	if
		not configs.settings.miscellaneous.autoUpdate or
		configs.urls.update == "" or
		love.filesystem.getInfo(".git")
	then
		return
	end

	self.windowModel:load()

	function love.update()
		thread.update()
		delay.update()
		self.windowModel:update()
	end

	function love.draw()
		love.graphics.printf(updateModel.status, 0, 0, love.graphics.getWidth())
	end

	return updateModel:updateFilesAsync()
end

return UpdateController
