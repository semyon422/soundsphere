local ScoreSystem = require("sphere.models.RhythmModel.ScoreEngine.ScoreSystem")

local EntryScoreSystem = ScoreSystem:new()

EntryScoreSystem.name = "entry"

EntryScoreSystem.getSlice = function(self) end

EntryScoreSystem.after = function(self, event)
	local container = self.container

	self.score = container.normalscore.scoreAdjusted
	self.accuracy = container.normalscore.accuracyAdjusted
	self.rating = container.normalscore.performance
	self.mean = container.normalscore.normalscore.mean
	self.maxCombo = container.base.maxCombo
	self.pauses = container.base.pauses
	self.missCount = container.base.missCount
	self.ratio = container.misc.ratio
	self.earlylate = container.misc.earlylate
	self.perfect = container.judgement.counters.soundsphere.perfect
	self.notPerfect = container.judgement.counters.soundsphere["not perfect"]
	self.inputMode = self.scoreEngine.inputMode
	self.timeRate = self.scoreEngine.baseTimeRate
	self.difficulty = self.scoreEngine.enps
end

return EntryScoreSystem
