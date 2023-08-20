local ScoreSystem = require("sphere.models.RhythmModel.ScoreEngine.ScoreSystem")

---@class sphere.EntryScoreSystem: sphere.ScoreSystem
---@operator call: sphere.EntryScoreSystem
local EntryScoreSystem = ScoreSystem + {}

EntryScoreSystem.name = "entry"

function EntryScoreSystem:getSlice() end

---@param event table
function EntryScoreSystem:after(event)
	local container = self.container

	self.accuracy = container.normalscore.accuracyAdjusted
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
	self.pausesCount = self.scoreEngine.pausesCount
end

return EntryScoreSystem
