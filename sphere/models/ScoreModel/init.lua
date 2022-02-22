local Class = require("aqua.util.Class")
local Observable = require("aqua.util.Observable")
local ScoreManager = require("sphere.models.ScoreModel.ScoreManager")

local ScoreModel = Class:new()

ScoreModel.construct = function(self)
	self.observable = Observable:new()
	self.scoreManager = ScoreManager:new()
end

ScoreModel.load = function(self)
	self:select()
end

ScoreModel.unload = function(self)
end

ScoreModel.select = function(self)
	local config = self.configModel.configs.settings.gameplay
	self.scoreManager.ratingHitTimingWindow = config.ratingHitTimingWindow
    self.scoreManager:select()
end

ScoreModel.getScoreEntries = function(self, hash, index)
    return self.scoreManager:getScoreEntries(hash, index)
end

ScoreModel.insertScore = function(self, scoreTable, noteChartDataEntry, replayHash, modifierModel)
    return self.scoreManager:insertScore(scoreTable, noteChartDataEntry, replayHash, modifierModel)
end

ScoreModel.receive = function(self, event)
	self.observable:send(event)
end

return ScoreModel
