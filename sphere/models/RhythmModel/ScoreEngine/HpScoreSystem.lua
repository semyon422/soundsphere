local ScoreSystem = require("sphere.models.RhythmModel.ScoreEngine.ScoreSystem")

local HpScoreSystem = ScoreSystem:new()

HpScoreSystem.name = "hp"

HpScoreSystem.construct = function(self)
	self.hp = 0.5
	self.failed = false
end

HpScoreSystem.increaseHp = function(self)
	if self.failed then
		return
	end
	self.hp = math.min(self.hp + 0.001, 1)
end

HpScoreSystem.decreaseHp = function(self)
	self.hp = math.max(self.hp - 0.05, 0)
	if self.hp < 1e-6 then
		self.failed = true
	end
end

HpScoreSystem.notes = {
	ShortScoreNote = {
		clear = {
			passed = HpScoreSystem.increaseHp,
			missed = HpScoreSystem.decreaseHp,
		},
	},
	LongScoreNote = {
		clear = {
			startPassedPressed = nil,
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
