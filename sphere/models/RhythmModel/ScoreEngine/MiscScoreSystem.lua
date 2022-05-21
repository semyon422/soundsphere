local ScoreSystem = require("sphere.models.RhythmModel.ScoreEngine.ScoreSystem")

local MiscScoreSystem = ScoreSystem:new()

MiscScoreSystem.name = "misc"

MiscScoreSystem.construct = function(self)
	self.ratio = 0
	self.maxDeltaTime = 0
	self.deltaTime = 0
	self.earlylate = 0
end

MiscScoreSystem.hit = function(self, event, timeKey)
	local deltaTime = (event.currentTime - event[timeKey]) / math.abs(event.timeRate)
	self.deltaTime = deltaTime
	if math.abs(deltaTime) > math.abs(self.maxDeltaTime) then
		self.maxDeltaTime = deltaTime
	end

	local counters = self.container.judgement.counters

	self.ratio = (counters.soundsphere.perfect or 0) / (counters.all.count or 1)
	self.earlylate = (counters.earlylate.early or 0) / (counters.earlylate.late or 1)
end

MiscScoreSystem.miss = function(self, event, timeKey)
	self.deltaTime = (event.currentTime - event[timeKey]) / math.abs(event.timeRate)
end

MiscScoreSystem.notes = {
	ShortNote = {
		clear = {
			passed = function(self, event) self:hit(event, "noteTime") end,
			missed = function(self, event) self:miss(event, "noteTime") end,
		},
	},
	LongNote = {
		clear = {
			startPassedPressed = function(self, event) self:hit(event, "noteStartTime") end,
			startMissed = function(self, event) self:miss(event, "noteStartTime") end,
			startMissedPressed = function(self, event) self:miss(event, "noteStartTime") end,
		},
		startPassedPressed = {
			startMissed = nil,
			endMissed = function(self, event) self:miss(event, "noteEndTime") end,
			endPassed = function(self, event) self:hit(event, "noteEndTime") end,
		},
		startMissedPressed = {
			endMissedPassed = function(self, event) self:hit(event, "noteEndTime") end,
			startMissed = nil,
			endMissed = function(self, event) self:miss(event, "noteEndTime") end,
		},
		startMissed = {
			startMissedPressed = nil,
			endMissed = function(self, event) self:miss(event, "noteEndTime") end,
		},
	},
}

return MiscScoreSystem
