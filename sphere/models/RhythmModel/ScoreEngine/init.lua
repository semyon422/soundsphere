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

local IAccuracySource = require("sphere.models.RhythmModel.ScoreEngine.IAccuracySource")
local IComboSource = require("sphere.models.RhythmModel.ScoreEngine.IComboSource")
local IHealthsSource = require("sphere.models.RhythmModel.ScoreEngine.IHealthsSource")
local IJudgesSource = require("sphere.models.RhythmModel.ScoreEngine.IJudgesSource")
local IScoreSource = require("sphere.models.RhythmModel.ScoreEngine.IScoreSource")

local ScoreEngineFactory = require("sphere.models.RhythmModel.ScoreEngine.ScoreEngineFactory")

---@class sphere.ScoreEngine
---@operator call: sphere.ScoreEngine
---@field judgement string
---@field accuracySource sphere.IAccuracySource
---@field comboSource sphere.IComboSource
---@field healthsSource sphere.IHealthsSource
---@field judgesSource sphere.IJudgesSource
---@field scoreSource sphere.IScoreSource
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

	self:selectDefault()

	---@type {[string]: sphere.ScoreSystem}
	self.scoreSystemsByName = by_name

	for _, v in pairs(by_name) do
		table.insert(self.scoreSystems, v)
	end

	self:select(self.judgement)

	self.sequence = {}
end

function ScoreEngine:selectDefault()
	local scores = self.scores
	self.accuracySource = scores.normalscore
	self.comboSource = scores.base
	self.healthsSource = scores.hp
	self.judgesSource = scores.soundsphere
	self.scoreSource = scores.normalscore
end

---@param t sea.Timings
---@param st sea.Subtimings
---@return sphere.ScoreSystem?
function ScoreEngine:createAndSelectByTimings(t, st)
	local systems, err = ScoreEngineFactory:get(t, st)
	if not systems then
		self:selectDefault()
		return
	end

	for _, sys in ipairs(systems) do
		self:addScoreSystem(sys)
		self:select(sys:getKey())
	end
end

---@param key string
function ScoreEngine:select(key)
	local score = self:getScoreSystem(key)
	if not score then
		self:selectDefault()
		return
	end
	---@cast score any

	self.accuracySource = IAccuracySource * score and score or self.accuracySource
	self.comboSource = IComboSource * score and score or self.comboSource
	self.healthsSource = IHealthsSource * score and score or self.healthsSource
	self.judgesSource = IJudgesSource * score and score or self.judgesSource
	self.scoreSource = IScoreSource * score and score or self.scoreSource
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

return ScoreEngine
