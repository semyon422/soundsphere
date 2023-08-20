local class = require("class")
local erfunc = require("libchart.erfunc")
local thread = require("thread")
local ScoreDatabase = require("sphere.models.ScoreModel.ScoreDatabase")

---@class sphere.ScoreModel
---@operator call: sphere.ScoreModel
local ScoreModel = class()

function ScoreModel:load()
	ScoreDatabase:load()
end

function ScoreModel:unload()
	ScoreDatabase:unload()
end

---@param score table
function ScoreModel:transformScoreEntry(score)
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

---@param hash string
---@param index number
---@return table
function ScoreModel:getScoreEntries(hash, index)
	local scores = ScoreDatabase:getScoreEntries(hash, index)
	for i = 1, #scores do
		self:transformScoreEntry(scores[i])
	end
	return scores
end

---@param id number
---@return table
function ScoreModel:getScoreEntryById(id)
	local score = ScoreDatabase:selectScore(id)
	self:transformScoreEntry(score)
	return score
end

---@param scoreSystemEntry table
---@param noteChartDataEntry table
---@param replayHash string
---@param modifiers string
---@return table
function ScoreModel:insertScore(scoreSystemEntry, noteChartDataEntry, replayHash, modifiers)
	local score = ScoreDatabase:insertScore({
		noteChartHash = noteChartDataEntry.hash,
		noteChartIndex = noteChartDataEntry.index,
		playerName = "Player",
		time = os.time(),
		accuracy = scoreSystemEntry.accuracy,
		maxCombo = scoreSystemEntry.maxCombo,
		modifiers = modifiers,
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

---@param a table
---@param b table
---@return boolean
local function sortScores(a, b)
	if a.rating == b.rating then
		return a.time < b.time
	else
		return a.rating > b.rating
	end
end

---@param scores table
---@return number
function ScoreModel:calculateTopScore(scores)
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

function ScoreModel:calculateTopScores()
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

local calculateTopScores = thread.async(function()
	local game = {}

	local ConfigModel = require("sphere.models.ConfigModel")
	game.configModel = ConfigModel()
	game.configModel:read("settings")

	local ScoreModel = require("sphere.models.ScoreModel")
	local scoreModel = ScoreModel()
	scoreModel.game = game
	game.scoreModel = scoreModel

	scoreModel:load()
	scoreModel:calculateTopScores()
	scoreModel:unload()
end)

ScoreModel.asyncCalculateTopScores = thread.coro(function(self)
	if self.calculating then
		return
	end
	self.calculating = true
	calculateTopScores()
	self.calculating = false
end)

return ScoreModel
