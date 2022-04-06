local Class = require("aqua.util.Class")
local erfunc = require("libchart.erfunc")
local ScoreDatabase = require("sphere.models.ScoreModel.ScoreDatabase")

local ScoreModel = Class:new()

ScoreModel.load = function(self)
	ScoreDatabase:load()
end

ScoreModel.transformScoreEntry = function(self, scoreEntry)
	local window = self.configModel.configs.settings.gameplay.ratingHitTimingWindow
	scoreEntry.rating = scoreEntry.difficulty * erfunc.erf(window / (scoreEntry.accuracy * math.sqrt(2)))
end

ScoreModel.getScoreEntries = function(self, hash, index)
	local scores = ScoreDatabase:getScoreEntries(hash, index)
	for i = 1, #scores do
		self:transformScoreEntry(scores[i])
	end
	return scores
end

ScoreModel.getScoreEntryById = function(self, id)
	local score = ScoreDatabase:selectScore(id)
	self:transformScoreEntry(score)
	return score
end

ScoreModel.insertScore = function(self, scoreSystemEntry, noteChartDataEntry, replayHash, modifierModel)
	return ScoreDatabase:insertScore({
		noteChartHash = noteChartDataEntry.hash,
		noteChartIndex = noteChartDataEntry.index,
		playerName = "Player",
		time = os.time(),
		score = scoreSystemEntry.score,
		accuracy = scoreSystemEntry.accuracy,
		maxCombo = scoreSystemEntry.maxCombo,
		modifiers = modifierModel:encode(),
		replayHash = replayHash,
		rating = scoreSystemEntry.rating,
		ratio = scoreSystemEntry.ratio,
		perfect = scoreSystemEntry.perfect,
		notPerfect = scoreSystemEntry.notPerfect,
		missCount = scoreSystemEntry.missCount,
		mean = scoreSystemEntry.mean,
		earlylate = scoreSystemEntry.earlylate,
		inputMode = scoreSystemEntry.inputMode,
		timeRate = scoreSystemEntry.timeRate,
		difficulty = scoreSystemEntry.difficulty,
		pausesCount = scoreSystemEntry.pausesCount,
	})
end

return ScoreModel
