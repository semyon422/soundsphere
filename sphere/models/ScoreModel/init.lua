local Class = require("aqua.util.Class")
local ScoreDatabase = require("sphere.models.ScoreModel.ScoreDatabase")

local ScoreModel = Class:new()

ScoreModel.load = function(self)
	ScoreDatabase:load()
end

ScoreModel.getScoreEntries = function(self, hash, index)
    return ScoreDatabase:getScoreEntries(hash, index)
end

ScoreModel.getScoreEntryById = function(self, id)
    return ScoreDatabase:selectScore(id)
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
