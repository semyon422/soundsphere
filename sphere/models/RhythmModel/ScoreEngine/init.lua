local class = require("class")

local BaseScore = require("sphere.models.RhythmModel.ScoreEngine.scores.BaseScore")
local HpScore = require("sphere.models.RhythmModel.ScoreEngine.scores.HpScore")
local NormalscoreScore = require("sphere.models.RhythmModel.ScoreEngine.scores.NormalscoreScore")
local MiscScore = require("sphere.models.RhythmModel.ScoreEngine.scores.MiscScore")
local SoundsphereScore = require("sphere.models.RhythmModel.ScoreEngine.scores.SoundsphereScore")
local OsuManiaV1Score = require("sphere.models.RhythmModel.ScoreEngine.scores.OsuManiaV1Score")
local OsuManiaV2Score = require("sphere.models.RhythmModel.ScoreEngine.scores.OsuManiaV2Score")
local QuaverScore = require("sphere.models.RhythmModel.ScoreEngine.scores.QuaverScore")
local EtternaAccuracy = require("sphere.models.RhythmModel.ScoreEngine.scores.EtternaAccuracy")
local EtternaJudges = require("sphere.models.RhythmModel.ScoreEngine.scores.EtternaJudges")
local LunaticRaveScore = require("sphere.models.RhythmModel.ScoreEngine.scores.LunaticRaveScore")

local ScoreEngineFactory = require("sphere.models.RhythmModel.ScoreEngine.ScoreEngineFactory")

---@class sphere.ScoreEngine
---@operator call: sphere.ScoreEngine
---@field judgement string
---@field ratingHitWindow number
---@field selectedScoring sphere.ScoreSystem
---@field accuracySource sphere.ScoreSystem
---@field scoreSource sphere.ScoreSystem
---@field judgesSource sphere.ScoreSystem
local ScoreEngine = class()

function ScoreEngine:new()
	self.events = {}
	self.scores = {}
	self.sequence = {}
end

function ScoreEngine:load()
	self.events = {}
	---@type sphere.ScoreSystem[]
	self.scoreSystems = {}

	local by_name = {
		base = BaseScore(),
		hp = HpScore(),
		misc = MiscScore(),
		normalscore = NormalscoreScore(),
		soundsphere = SoundsphereScore(),
	}
	self.scores = by_name

	---@type {[string]: sphere.ScoreSystem}
	self.scoreSystemsByName = {}

	for k, v in pairs(by_name) do
		self:addScoreSystem(v)
	end

	---@type {[string]: sphere.ScoreSystem}
	self.scoreSystemsByName = by_name

	-- self:addScoreSystem(QuaverScore())
	-- for i = 0, 10 do
	-- 	self:addScoreSystem(OsuManiaV1Score(i))
	-- end
	-- for i = 0, 10 do
	-- 	self:addScoreSystem(OsuManiaV2Score(i))
	-- end
	-- for i = 1, 9 do
	-- 	self:addScoreSystem(EtternaAccuracy(i))
	-- 	self:addScoreSystem(EtternaJudges(i))
	-- end
	-- for i = 0, 3 do
	-- 	self:addScoreSystem(LunaticRaveScore(i))
	-- end

	self:select(self.judgement)

	self.sequence = {}
end

---@param t sea.Timings
---@param st sea.Subtimings
---@return sphere.ScoreSystem?
function ScoreEngine:createAndSelectByTimings(t, st)
	local systems, err = ScoreEngineFactory:get(t, st)
	if not systems then
		print("createAndSelectByTimings error", t, st, err)
		return
	end

	for _, sys in ipairs(systems) do
		self:addScoreSystem(sys)
		self:select(sys:getKey())
	end
end

---@param key string
function ScoreEngine:select(key)
	local soundsphere = assert(self:getScoreSystem("soundsphere"))
	local normalscore = assert(self:getScoreSystem("normalscore"))

	local score = self:getScoreSystem(key) or soundsphere
	self.selectedScoring = score
	self.accuracySource = score.hasAccuracy and score or self.accuracySource or normalscore
	self.scoreSource = score.hasScore and score or self.scoreSource or normalscore
	self.judgesSource = score.hasJudges and score or self.judgesSource or soundsphere
end

---@param key string
---@return sphere.ScoreSystem?
function ScoreEngine:getScoreSystem(key)
	return self.scoreSystemsByName[key]
end

---@param score_system sphere.ScoreSystem
---@return sphere.ScoreSystem
function ScoreEngine:addScoreSystem(score_system)
	local key = score_system:getKey()

	local by_name = self.scoreSystemsByName
	if by_name[key] then
		return by_name[key]
	end

	table.insert(self.scoreSystems, score_system)
	by_name[key] = score_system

	for _, event in ipairs(self.events) do
		score_system:receive(event)
	end

	return score_system
end

---@return {[string]: table}
function ScoreEngine:getSlice()
	---@type {[string]: table}
	local slice = {}
	for _, scoreSystem in ipairs(self.scoreSystems) do
		slice[scoreSystem:getKey()] = scoreSystem:getSlice()
	end
	return slice
end

---@param event table
function ScoreEngine:receive(event)
	if event.name ~= "NoteState" or not event.currentTime then
		return
	end

	for _, scoreSystem in ipairs(self.scoreSystems) do
		scoreSystem:receive(event)
	end

	table.insert(self.events, event)

	local slice = self:getSlice()
	self.slice = slice
	table.insert(self.sequence, slice)
end

---@return number
function ScoreEngine:getAccuracy()
	return self.accuracySource:getAccuracy()
end

---@return string
function ScoreEngine:getAccuracyString()
	return self.accuracySource:getAccuracyString()
end

---@return number
function ScoreEngine:getScore()
	return self.scoreSource:getScore()
end

---@return string
function ScoreEngine:getScoreString()
	return self.scoreSource:getScoreString()
end

---@return sphere.JudgeCounter
function ScoreEngine:getJudgeCounter()
	return assert(self.judgesSource.judge_counter)
end

return ScoreEngine
