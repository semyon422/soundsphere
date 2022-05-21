local ScoreSystem = require("sphere.models.RhythmModel.ScoreEngine.ScoreSystem")

local HpScoreSystem = ScoreSystem:new()

HpScoreSystem.name = "hp"

HpScoreSystem.construct = function(self)
	self.failed = false
end

HpScoreSystem.load = function(self)
	self.config = self.scoreEngine.hp
	self.hp = self.config.start
end

HpScoreSystem.increaseHp = function(self)
	if self.failed then
		return
	end
	self.hp = math.min(self.hp + self.config.increase, self.config.max)
end

HpScoreSystem.decreaseHp = function(self)
	self.hp = math.max(self.hp - self.config.decrease, self.config.min)
	if self.hp < 1e-6 then
		self.failed = true
	end
end

HpScoreSystem.notes = {
	ShortNote = {
		clear = {
			passed = HpScoreSystem.increaseHp,
			missed = HpScoreSystem.decreaseHp,
		},
	},
	LongNote = {
		clear = {
			startPassedPressed = HpScoreSystem.increaseHp,
			startMissed = HpScoreSystem.decreaseHp,
			startMissedPressed = HpScoreSystem.decreaseHp,
		},
		startPassedPressed = {
			startMissed = HpScoreSystem.decreaseHp,
			endMissed = HpScoreSystem.decreaseHp,
			endPassed = HpScoreSystem.increaseHp,
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

return HpScoreSystem
