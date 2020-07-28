local Class = require("aqua.util.Class")
local Container = require("aqua.graphics.Container")
local GUI = require("sphere.ui.GUI")

local ResultView = Class:new()

ResultView.load = function(self)
	self.container = Container:new()

	local gui = GUI:new()
	self.gui = gui

	gui.container = self.container
	gui.modifierModel = self.modifierModel

	gui.scoreSystem = self.scoreSystem
	gui.noteChart = self.noteChart
	gui.noteChartEntry = self.noteChartEntry
	gui.noteChartDataEntry = self.noteChartDataEntry

	gui:load("userdata/interface/result.json")
	gui:receive({
		action = "updateMetaData",
		noteChartEntry = self.noteChartEntry,
		noteChartDataEntry = self.noteChartDataEntry
	})
end

ResultView.unload = function(self)
end

ResultView.receive = function(self, event)
	self.gui:receive(event)
end

ResultView.update = function(self, dt)
	self.container:update()
	self.gui:update()
end

ResultView.draw = function(self)
	self.container:draw()
end

return ResultView
