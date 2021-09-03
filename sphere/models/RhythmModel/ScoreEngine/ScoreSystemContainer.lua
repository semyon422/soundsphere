local Class = require("aqua.util.Class")

local ScoreSystems = {
	require("sphere.models.RhythmModel.ScoreEngine.BaseScoreSystem"),
	require("sphere.models.RhythmModel.ScoreEngine.HpScoreSystem"),
	require("sphere.models.RhythmModel.ScoreEngine.JudgementScoreSystem"),
	require("sphere.models.RhythmModel.ScoreEngine.NormalscoreScoreSystem"),
	require("sphere.models.RhythmModel.ScoreEngine.EntryScoreSystem"),
}

local ScoreSystemContainer = Class:new()

ScoreSystemContainer.construct = function(self)
	local scoreSystems = {}
	for _, ScoreSystem in ipairs(ScoreSystems) do
		local scoreSystem = ScoreSystem:new()
		scoreSystem.container = self

		table.insert(scoreSystems, scoreSystem)
		self[ScoreSystem.name] = scoreSystem

		if not self.timingWindows and scoreSystem.timingWindows then
			self.timingWindows = scoreSystem.timingWindows
		end
	end
	self.scoreSystems = scoreSystems
	self.sequence = {}
end

ScoreSystemContainer.getSlice = function(self)
	local slice = {}
	for _, scoreSystem in ipairs(self.scoreSystems) do
		slice[scoreSystem.name] = {}
		local sliceScoreSystem = slice[scoreSystem.name]
		for k, v in pairs(scoreSystem) do
			local t = type(v)
			if t == "number" or t == "string" or t == "boolean" then
				if v == math.huge then
					v = "inf"
				end
				sliceScoreSystem[k] = v
			end
		end
	end
	return slice
end

ScoreSystemContainer.receive = function(self, event)
	if event.name ~= "ScoreNoteState" or not event.currentTime then
		return
	end

	for _, scoreSystem in ipairs(self.scoreSystems) do
		scoreSystem.scoreEngine = self.scoreEngine
		scoreSystem:receive(event)
	end

	table.insert(self.sequence, self:getSlice())
end

return ScoreSystemContainer
