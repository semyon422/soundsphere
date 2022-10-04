local Class = require("Class")

local ScoreSystems = {
	require("sphere.models.RhythmModel.ScoreEngine.BaseScoreSystem"),
	require("sphere.models.RhythmModel.ScoreEngine.HpScoreSystem"),
	require("sphere.models.RhythmModel.ScoreEngine.JudgementScoreSystem"),
	require("sphere.models.RhythmModel.ScoreEngine.NormalscoreScoreSystem"),
	require("sphere.models.RhythmModel.ScoreEngine.MiscScoreSystem"),
	require("sphere.models.RhythmModel.ScoreEngine.EntryScoreSystem"),
}

local ScoreSystemContainer = Class:new()

ScoreSystemContainer.load = function(self)
	self.scoreSystems = {}
	self.sequence = {}

	local scoreSystems = self.scoreSystems
	for _, ScoreSystem in ipairs(ScoreSystems) do
		local scoreSystem = ScoreSystem:new()
		scoreSystem.container = self
		scoreSystem.scoreEngine = self.scoreEngine

		table.insert(scoreSystems, scoreSystem)
		self[ScoreSystem.name] = scoreSystem

		scoreSystem:load()
	end
end

ScoreSystemContainer.getSlice = function(self)
	local slice = {}
	for _, scoreSystem in ipairs(self.scoreSystems) do
		slice[scoreSystem.name] = scoreSystem:getSlice()
	end
	return slice
end

ScoreSystemContainer.receive = function(self, event)
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
