local ScoreDatabase	= require("sphere.models.ScoreModel.ScoreDatabase")
local Log			= require("aqua.util.Log")
local Class			= require("aqua.util.Class")

local ScoreManager = Class:new()

ScoreManager.init = function(self)
	self.log = Log:new()
	self.log.console = true
	self.log.path = "userdata/scores.log"
end

local sortByScore = function(a, b)
	return a.score < b.score
end

ScoreManager.select = function(self)
	local loaded = ScoreDatabase.loaded
	if not loaded then
		ScoreDatabase:load()
	end

	local scores = {}
	self.scores = scores

	local selectScoresStatement = ScoreDatabase.selectScoresStatement

	local stmt = selectScoresStatement:reset()
	local row = stmt:step()
	while row do
		local entry = ScoreDatabase:transformScoreEntry(row)
		scores[#scores + 1] = entry

		row = stmt:step()
	end

	local scoresId = {}
	self.scoresId = scoresId

	for i = 1, #scores do
		local entry = scores[i]
		scoresId[entry.id] = entry
	end

	local scoresReplayHash = {}
	self.scoresReplayHash = scoresReplayHash

	for i = 1, #scores do
		local entry = scores[i]
		scoresReplayHash[entry.replayHash] = entry
	end

	local scoresHashIndex = {}
	self.scoresHashIndex = scoresHashIndex

	for i = 1, #scores do
		local entry = scores[i]
		local hash = entry.noteChartHash
		local index = entry.noteChartIndex
		scoresHashIndex[hash] = scoresHashIndex[hash] or {}
		scoresHashIndex[hash][index] = scoresHashIndex[hash][index] or {}
		local list = scoresHashIndex[hash][index]
		list[#list + 1] = entry
	end
	for _, list in pairs(scoresHashIndex) do
		for _, sublist in pairs(list) do
			table.sort(sublist, sortByScore)
		end
	end

	if not loaded then
		ScoreDatabase:unload()
	end
end

ScoreManager.insertScore = function(self, scoreSystemEntry, noteChartDataEntry, replayHash, modifierModel)
	local scoreEntry = {
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
	}
	ScoreDatabase:load()
	ScoreDatabase:insertScore(scoreEntry)
	ScoreDatabase:unload()
	self:select()
	return self:getScoreEntryByReplayHash(replayHash)
end

ScoreManager.getScores = function(self)
	return self.scores
end

ScoreManager.getScoreEntryById = function(self, id)
	return self.scoresId[id]
end

ScoreManager.getScoreEntryByReplayHash = function(self, replayHash)
	return self.scoresReplayHash[replayHash]
end

ScoreManager.getScoreEntries = function(self, hash, index)
	local t = self.scoresHashIndex
	return t[hash] and t[hash][index]
end

ScoreManager:init()

return ScoreManager
