local Class = require("aqua.util.Class")
local erfunc = require("libchart.erfunc")
local ScoreDatabase = require("sphere.models.ScoreModel.ScoreDatabase")

local ScoreModel = Class:new()

ScoreModel.load = function(self)
	ScoreDatabase:load()
	-- self:calculateTopScores()
end

ScoreModel.unload = function(self)
	ScoreDatabase:unload()
end

ScoreModel.transformScoreEntry = function(self, score)
	local window = self.configModel.configs.settings.gameplay.ratingHitTimingWindow
	local s = erfunc.erf(window / (score.accuracy * math.sqrt(2)))
	score.rating = score.difficulty * s
	score.score = s * 10000
	if tonumber(score.isTop) == 1 then
		score.isTop = true
	else
		score.isTop = false
	end
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
		accuracy = scoreSystemEntry.accuracy,
		maxCombo = scoreSystemEntry.maxCombo,
		modifiers = modifierModel:encode(),
		replayHash = replayHash,
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

local sortScores = function(a, b)
	if a.rating == b.rating then
		return a.time < b.time
	else
		return a.rating > b.rating
	end
end
ScoreModel.calculateTopScores = function(self)
	print("calculating top scores")
	local map = {}
	for _, score in ipairs(ScoreDatabase:selectAllScores()) do
		self:transformScoreEntry(score)
		map[score.noteChartHash] = map[score.noteChartHash] or {}
		map[score.noteChartHash][score.noteChartIndex] = map[score.noteChartHash][score.noteChartIndex] or {}
		table.insert(map[score.noteChartHash][score.noteChartIndex], score)
	end

	local counter = 0
	for _, c in pairs(map) do
		for _, scores in pairs(c) do
			table.sort(scores, sortScores)
			for i, score in ipairs(scores) do
				if i == 1 and not score.isTop then
					score.isTop = true
					ScoreDatabase:updateScore(score)
				elseif i > 1 and score.isTop then
					score.isTop = false
					ScoreDatabase:updateScore(score)
				end
				counter = counter + 1
			end
		end
	end
	print("calculated top scores: " .. counter)
end

return ScoreModel
