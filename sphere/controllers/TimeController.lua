local Class = require("Class")
local CacheDatabase = require("sphere.models.CacheModel.CacheDatabase")

local TimeController = Class:new()

TimeController.skipIntro = function(self)
	local rhythmModel = self.rhythmModel
	local timeEngine = rhythmModel.timeEngine
	if not timeEngine.timer.isPlaying then
		return
	end
	timeEngine:skipIntro()
end

TimeController.updateOffsets = function(self)
	local rhythmModel = self.rhythmModel
	local noteChartDataEntry = self.noteChartModel.noteChartDataEntry
	local config = self.configModel.configs.settings

	local localOffset = noteChartDataEntry.localOffset or 0
	local baseTimeRate = rhythmModel.timeEngine:getBaseTimeRate()
	local inputOffset = config.gameplay.offset.input + localOffset
	local visualOffset = config.gameplay.offset.visual + localOffset
	if config.gameplay.offsetScale.input then
		inputOffset = inputOffset * baseTimeRate
	end
	if config.gameplay.offsetScale.visual then
		visualOffset = visualOffset * baseTimeRate
	end
	rhythmModel:setInputOffset(inputOffset)
	rhythmModel:setVisualOffset(visualOffset)
end

TimeController.increaseTimeRate = function(self, delta)
	if self.multiplayerModel.isPlaying then return end
	local rhythmModel = self.rhythmModel
	local timeEngine = rhythmModel.timeEngine
	timeEngine:increaseTimeRate(delta)
	rhythmModel.prohibitSavingScore = true
	self.notificationModel:notify("rate: " .. timeEngine.timeRate)
end

TimeController.increasePlaySpeed = function(self, delta)
	local speedModel = self.speedModel
	speedModel:increase(delta)

	local gameplay = self.configModel.configs.settings.gameplay
	self.rhythmModel.graphicEngine:setVisualTimeRate(gameplay.speed)
	self.notificationModel:notify("scroll speed: " .. speedModel.format[gameplay.speedType]:format(speedModel:get()))
end

TimeController.increaseLocalOffset = function(self, delta)
	local noteChartDataEntry = self.noteChartModel.noteChartDataEntry
	noteChartDataEntry.localOffset = (noteChartDataEntry.localOffset or 0) + delta
	CacheDatabase:updateNoteChartDataEntry(noteChartDataEntry)
	self.notificationModel:notify("local offset: " .. noteChartDataEntry.localOffset * 1000 .. "ms")
	self:updateOffsets()
end

return TimeController
