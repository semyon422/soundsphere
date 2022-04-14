local Class = require("aqua.util.Class")
local erfunc = require("libchart.erfunc")
local aquathread = require("aqua.thread")
local ScoreDatabase = require("sphere.models.ScoreModel.ScoreDatabase")

local ScoreModel = Class:new()

ScoreModel.load = function(self)
	ScoreDatabase:load()
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
	local score = ScoreDatabase:insertScore({
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

	local scoreEntries = self:getScoreEntries(
		noteChartDataEntry.hash,
		noteChartDataEntry.index
	)
	self:calculateTopScore(scoreEntries)

	return score
end

local sortScores = function(a, b)
	if a.rating == b.rating then
		return a.time < b.time
	else
		return a.rating > b.rating
	end
end
ScoreModel.calculateTopScore = function(self, scores)
	local counter = 0
	table.sort(scores, sortScores)
	for i, score in ipairs(scores) do
		if i == 1 and not score.isTop then
			ScoreDatabase:updateScore({
				id = score.id,
				isTop = true,
			})
		elseif i > 1 and score.isTop then
			ScoreDatabase:updateScore({
				id = score.id,
				isTop = false,
			})
		end
		counter = counter + 1
	end
	return counter
end
ScoreModel.calculateTopScores = function(self)
	local time = love.timer.getTime()
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
			counter = counter + self:calculateTopScore(scores)
		end
	end
	print("processed " .. counter .. " scores in " .. math.floor((love.timer.getTime() - time) * 1000) .. "ms")
end

local calculateTopScores = aquathread.async(function()
	local ConfigModel = require("sphere.models.ConfigModel")
	local configModel = ConfigModel:new()
	configModel:addConfig("settings", "userdata/settings.lua", "sphere/models/ConfigModel/settings.lua", "lua")
	configModel:readConfig("settings")

	local ScoreModel = require("sphere.models.ScoreModel")
	local scoreModel = ScoreModel:new()
	scoreModel.configModel = configModel
	scoreModel:load()
	scoreModel:calculateTopScores()
	scoreModel:unload()
end)

ScoreModel.asyncCalculateTopScores = aquathread.coro(function(self)
	if self.calculating then
		return
	end
	self.calculating = true
	calculateTopScores()
	self.calculating = false
end)

return ScoreModel
