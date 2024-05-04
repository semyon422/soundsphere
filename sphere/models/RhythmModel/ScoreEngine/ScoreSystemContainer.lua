local class = require("class")
local table_util = require("table_util")

local ScoreSystems = {
	require("sphere.models.RhythmModel.ScoreEngine.BaseScoreSystem"),
	require("sphere.models.RhythmModel.ScoreEngine.HpScoreSystem"),
	require("sphere.models.RhythmModel.ScoreEngine.NormalscoreScoreSystem"),
	require("sphere.models.RhythmModel.ScoreEngine.MiscScoreSystem"),
	require("sphere.models.RhythmModel.ScoreEngine.SoundsphereScoring"),
	require("sphere.models.RhythmModel.ScoreEngine.OsuManiaScoring"),
	require("sphere.models.RhythmModel.ScoreEngine.OsuLegacyScoring"),
	require("sphere.models.RhythmModel.ScoreEngine.QuaverScoring"),
	require("sphere.models.RhythmModel.ScoreEngine.EtternaScoring"),
	require("sphere.models.RhythmModel.ScoreEngine.LunaticRaveScoring"),
	require("sphere.models.RhythmModel.ScoreEngine.JudgementScoreSystem"),
}

---@class sphere.ScoreSystemContainer
---@operator call: sphere.ScoreSystemContainer
local ScoreSystemContainer = class()

function ScoreSystemContainer:load()
	self.scoreSystems = {}
	self.sequence = {}
	self.judgements = {}

	local scoreSystems = self.scoreSystems
	for _, ScoreSystem in ipairs(ScoreSystems) do
		local scoreSystem = ScoreSystem()
		scoreSystem.container = self
		scoreSystem.scoreEngine = self.scoreEngine

		table.insert(scoreSystems, scoreSystem)
		self[ScoreSystem.name] = scoreSystem

		scoreSystem:load()

		local judges = scoreSystem.judges

		if judges then
			table_util.copy(judges, self.judgements)
		end
	end
end

---@return table
function ScoreSystemContainer:getSlice()
	local slice = {}
	for _, scoreSystem in ipairs(self.scoreSystems) do
		slice[scoreSystem.name] = scoreSystem:getSlice()
	end
	return slice
end

---@param event table
function ScoreSystemContainer:receive(event)
	if event.name ~= "NoteState" or not event.currentTime then
		return
	end

	for _, scoreSystem in ipairs(self.scoreSystems) do
		scoreSystem.scoreEngine = self.scoreEngine
		scoreSystem:receive(event)
	end

	local slice = self:getSlice()
	self.slice = slice
	table.insert(self.sequence, slice)
end

return ScoreSystemContainer
