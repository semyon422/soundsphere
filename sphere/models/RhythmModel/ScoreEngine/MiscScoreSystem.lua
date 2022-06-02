local ScoreSystem = require("sphere.models.RhythmModel.ScoreEngine.ScoreSystem")

local MiscScoreSystem = ScoreSystem:new()

MiscScoreSystem.name = "misc"

MiscScoreSystem.construct = function(self)
	self.ratio = 0
	self.maxDeltaTime = 0
	self.deltaTime = 0
	self.earlylate = 0
end

MiscScoreSystem.hit = function(self, event)
	local deltaTime = event.deltaTime
	self.deltaTime = deltaTime
	if math.abs(deltaTime) > math.abs(self.maxDeltaTime) then
		self.maxDeltaTime = deltaTime
	end

	local counters = self.container.judgement.counters

	self.ratio = (counters.soundsphere.perfect or 0) / (counters.all.count or 1)
	self.earlylate = (counters.earlylate.early or 0) / (counters.earlylate.late or 1)
end

MiscScoreSystem.miss = function(self, event)
	self.deltaTime = event.deltaTime
end

MiscScoreSystem.early = function(self)
	self.deltaTime = -math.huge
end

MiscScoreSystem.notes = {
	ShortNote = {
		clear = {
			passed = function(self, event) self:hit(event) end,
			missed = function(self, event) self:miss(event) end,
			clear = MiscScoreSystem.early,
		},
	},
	LongNote = {
		clear = {
			startPassedPressed = function(self, event) self:hit(event) end,
			startMissed = function(self, event) self:miss(event) end,
			startMissedPressed = function(self, event) self:miss(event) end,
			clear = MiscScoreSystem.early,
		},
		startPassedPressed = {
			startMissed = nil,
			endMissed = function(self, event) self:miss(event) end,
			endPassed = function(self, event) self:hit(event) end,
		},
		startMissedPressed = {
			endMissedPassed = function(self, event) self:hit(event) end,
			startMissed = nil,
			endMissed = function(self, event) self:miss(event) end,
		},
		startMissed = {
			startMissedPressed = nil,
			endMissed = function(self, event) self:miss(event) end,
		},
	},
}

return MiscScoreSystem
