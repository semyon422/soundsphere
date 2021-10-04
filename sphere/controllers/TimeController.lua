local Class = require("aqua.util.Class")
local CacheDatabase = require("sphere.models.CacheModel.CacheDatabase")

local TimeController = Class:new()

TimeController.receive = function(self, event)
	local configModel = self.gameController.configModel
	local rhythmModel = self.gameController.rhythmModel
	local notificationModel = self.gameController.notificationModel

	local timeEngine = rhythmModel.timeEngine
	local graphicEngine = rhythmModel.graphicEngine

	local config = configModel.configs.settings
	local input = config.input
	local gameplay = config.gameplay

	if event.name == "keypressed" then
		local key = event.args[1]
		local delta = 0.05

		if key == input.timeRate.decrease then
			timeEngine:increaseTimeRate(-delta)
			notificationModel:notify("rate: " .. timeEngine.timeRate)
			rhythmModel.prohibitSavingScore = true
		elseif key == input.timeRate.increase then
			timeEngine:increaseTimeRate(delta)
			notificationModel:notify("rate: " .. timeEngine.timeRate)
			rhythmModel.prohibitSavingScore = true
		elseif key == input.timeRate.invert then
			timeEngine:setTimeRate(-timeEngine.timeRate)
			notificationModel:notify("rate: " .. timeEngine.timeRate)
			rhythmModel.prohibitSavingScore = true
		elseif key == input.skipIntro then
			timeEngine:skipIntro()
		elseif key == input.playSpeed.invert then
			graphicEngine.targetVisualTimeRate = -graphicEngine.targetVisualTimeRate
			graphicEngine:setVisualTimeRate(graphicEngine.targetVisualTimeRate)
			notificationModel:notify("scroll speed: " .. graphicEngine.targetVisualTimeRate)
		elseif key == input.playSpeed.decrease then
			graphicEngine:increaseVisualTimeRate(-delta)
			gameplay.speed = graphicEngine.targetVisualTimeRate
			notificationModel:notify("scroll speed: " .. graphicEngine.targetVisualTimeRate)
		elseif key == input.playSpeed.increase then
			graphicEngine:increaseVisualTimeRate(delta)
			gameplay.speed = graphicEngine.targetVisualTimeRate
			notificationModel:notify("scroll speed: " .. graphicEngine.targetVisualTimeRate)
		end
	elseif event.name == "increaseLocalOffset" then
		CacheDatabase:load()
		local noteChartDataEntry = self.gameController.noteChartModel.noteChartDataEntry
		noteChartDataEntry.localOffset = noteChartDataEntry.localOffset + event.delta
		CacheDatabase:setNoteChartDataEntry(noteChartDataEntry)
		notificationModel:notify("local offset: " .. noteChartDataEntry.localOffset)
		CacheDatabase:unload()
	end
end

return TimeController
