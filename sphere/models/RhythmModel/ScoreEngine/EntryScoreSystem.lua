local ScoreSystem = require("sphere.models.RhythmModel.ScoreEngine.ScoreSystem")

local EntryScoreSystem = ScoreSystem:new()

EntryScoreSystem.name = "entry"
EntryScoreSystem.score = 0
EntryScoreSystem.accuracy = 0
EntryScoreSystem.rating = 0
EntryScoreSystem.maxCombo = 0

EntryScoreSystem.after = function(self, event)
	local container = self.container

	self.score = container.normalscore.scoreAdjusted
	self.accuracy = container.normalscore.accuracyAdjusted
	self.rating = container.normalscore.performance
	self.maxCombo = container.base.maxCombo
	self.pauses = container.base.pauses
	self.ratio = container.judgement.ratio
	self.perfect = container.judgement.perfect
	self.notPerfect = container.judgement["not perfect"]
	self.missCount = container.base.missCount
	self.mean = container.normalscore.normalscore.mean
	self.earlylate = container.judgement.earlylate
end

return EntryScoreSystem
