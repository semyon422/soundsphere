local Class = require("aqua.util.Class")
local Container = require("aqua.graphics.Container")
local GUI = require("sphere.ui.GUI")
local BackgroundManager	= require("sphere.ui.BackgroundManager")

local ResultView = Class:new()

ResultView.construct = function(self)
	self.container = Container:new()
	self.gui = GUI:new()
end

ResultView.load = function(self)
	local container = self.container
	local gui = self.gui
	local noteChartModel = self.noteChartModel
	local configModel = self.configModel

	gui.container = container
	gui.modifierModel = self.modifierModel

	gui.scoreSystem = self.scoreSystem
	gui.noteChartModel = noteChartModel

	gui:load("userdata/interface/result.json")
	gui:receive({
		action = "updateMetaData"
	})

	local dim = 255 * (1 - (configModel:get("dim.result") or 0))
	BackgroundManager:setColor({dim, dim, dim})
end

ResultView.unload = function(self)
end

ResultView.receive = function(self, event)
	self.gui:receive(event)

	if event.name == "keypressed" and event.args[1] == "escape" then
		self.controller:receive({
			name = "setScreen",
			screenName = "SelectScreen"
		})
	end
end

ResultView.update = function(self, dt)
	self.container:update()
	self.gui:update()
end

ResultView.draw = function(self)
	self.container:draw()
end

return ResultView
