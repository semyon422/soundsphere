local ScoreSystem = require("sphere.models.RhythmModel.ScoreEngine.ScoreSystem")

local MiscScoreSystem = ScoreSystem:new()

MiscScoreSystem.name = "misc"

MiscScoreSystem.construct = function(self)
	self.ratio = 0
	self.maxDeltaTime = 0
	self.deltaTime = 0
	self.earlylate = 0
end

MiscScoreSystem.processPassed = function(self, event)
	local noteStartTime = event.noteStartTime or event.noteTime
	local deltaTime = (event.currentTime - noteStartTime) / math.abs(event.timeRate)
	self.deltaTime = deltaTime
	if math.abs(deltaTime) > math.abs(self.maxDeltaTime) then
		self.maxDeltaTime = deltaTime
	end

	local counters = self.container.judgement.counters

	self.ratio = (counters.soundsphere.perfect or 0) / (counters.all.count or 1)
	self.earlylate = (counters.earlylate.early or 0) / (counters.earlylate.late or 1)
end

MiscScoreSystem.processMiss = function(self, event)
	local noteStartTime = event.noteStartTime or event.noteTime
	local deltaTime = (event.currentTime - noteStartTime) / math.abs(event.timeRate)
	self.deltaTime = deltaTime
end

MiscScoreSystem.notes = {
	ShortScoreNote = {
		clear = {
			passed = MiscScoreSystem.processPassed,
			missed = MiscScoreSystem.processMiss,
		},
	},
	LongScoreNote = {
		clear = {
			startPassedPressed = MiscScoreSystem.processPassed,
			startMissed = MiscScoreSystem.processMiss,
			startMissedPressed = MiscScoreSystem.processMiss,
		},
		startPassedPressed = {
			startMissed = nil,
			endMissed = nil,
			endPassed = nil,
		},
		startMissedPressed = {
			endMissedPassed = nil,
			startMissed = nil,
			endMissed = nil,
		},
		startMissed = {
			startMissedPressed = nil,
			endMissed = nil,
		},
	},
}

return MiscScoreSystem
