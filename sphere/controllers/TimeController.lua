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
	local gameplay = config.gameplay

	if event.name == "skipIntro" then
		if not timeEngine.timer.isPlaying then
			return
		end
		timeEngine:skipIntro()
	elseif event.name == "increaseTimeRate" then
		timeEngine:increaseTimeRate(event.delta)
		notificationModel:notify("rate: " .. timeEngine.timeRate)
		rhythmModel.prohibitSavingScore = true
	elseif event.name == "invertTimeRate" then
		timeEngine:setTimeRate(-timeEngine.timeRate)
		notificationModel:notify("rate: " .. timeEngine.timeRate)
		rhythmModel.prohibitSavingScore = true
	elseif event.name == "increasePlaySpeed" then
		graphicEngine:increaseVisualTimeRate(event.delta)
		gameplay.speed = graphicEngine.targetVisualTimeRate
		notificationModel:notify("scroll speed: " .. graphicEngine.targetVisualTimeRate)
	elseif event.name == "invertPlaySpeed" then
		graphicEngine.targetVisualTimeRate = -graphicEngine.targetVisualTimeRate
		graphicEngine:setVisualTimeRate(graphicEngine.targetVisualTimeRate)
		notificationModel:notify("scroll speed: " .. graphicEngine.targetVisualTimeRate)
	elseif event.name == "increaseLocalOffset" then
		local noteChartDataEntry = self.gameController.noteChartModel.noteChartDataEntry
		noteChartDataEntry.localOffset = (noteChartDataEntry.localOffset or 0) + event.delta
		CacheDatabase:updateNoteChartDataEntry(noteChartDataEntry)
		notificationModel:notify("local offset: " .. noteChartDataEntry.localOffset * 1000 .. "ms")
	end
end

return TimeController
