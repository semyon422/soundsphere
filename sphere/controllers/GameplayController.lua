local Class = require("aqua.util.Class")
local ScreenManager = require("sphere.screen.ScreenManager")

local GameplayController = Class:new()

GameplayController.load = function(self)
	local gui = self.view.gui
	local rhythmModel = self.rhythmModel

	rhythmModel.timeEngine.observable:add(gui)
	rhythmModel.scoreEngine.observable:add(gui)
	rhythmModel.logicEngine.observable:add(gui)
	rhythmModel.inputManager.observable:add(gui)

	rhythmModel.graphicEngine.observable:add(self.view)
end

GameplayController.unload = function(self)
	local gui = self.gui
	local rhythmModel = self.rhythmModel

	rhythmModel.timeEngine.observable:remove(gui)
	rhythmModel.scoreEngine.observable:remove(gui)
	rhythmModel.logicEngine.observable:remove(gui)
	rhythmModel.inputManager.observable:remove(gui)

	rhythmModel.graphicEngine.observable:remove(self.view)
end

GameplayController.receive = function(self, event)
	if event.name == "keypressed" then
		if event.args[1] == "1" then
			self:pause()
		elseif event.args[1] == "2" then
			self:play()
		elseif event.args[1] == "escape" then
			ScreenManager:set(require("sphere.screen.ResultScreen"),
				function()
					ScreenManager:receive({
						name = "scoreSystem",
						scoreSystem = self.rhythmModel.scoreEngine.scoreSystem,
						noteChart = self.noteChart,
						noteChartEntry = self.noteChartModel.noteChartEntry,
						noteChartDataEntry = self.noteChartModel.noteChartDataEntry,
						autoplay = self.rhythmModel.logicEngine.autoplay
					})
				end
			)
		end
	end
end

GameplayController.pause = function(self)
	self.rhythmModel.timeEngine:setTimeRate(0)
end

GameplayController.play = function(self)
	self.rhythmModel.timeEngine:setTimeRate(self.rhythmModel.timeEngine:getBaseTimeRate())
end

return GameplayController
