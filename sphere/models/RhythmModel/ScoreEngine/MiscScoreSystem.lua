local ScoreSystem = require("sphere.models.RhythmModel.ScoreEngine.ScoreSystem")

---@class sphere.MiscScoreSystem: sphere.ScoreSystem
---@operator call: sphere.MiscScoreSystem
local MiscScoreSystem = ScoreSystem + {}

MiscScoreSystem.name = "misc"

function MiscScoreSystem:new()
	self.ratio = 0
	self.maxDeltaTime = 0
	self.deltaTime = 0
	self.earlylate = 0
end

---@param event table
function MiscScoreSystem:hit(event)
	local deltaTime = event.deltaTime
	self.deltaTime = deltaTime
	if math.abs(deltaTime) > math.abs(self.maxDeltaTime) then
		self.maxDeltaTime = deltaTime
	end

	local soundsphereJudge = self.container.soundsphere.judges["soundsphere"]
	local earlyLate = soundsphereJudge.earlyLate
	local counters = soundsphereJudge.counters
	local notes = soundsphereJudge.notes

	self.ratio = (counters.perfect or 0) / (notes or 1)
	self.earlylate = (earlyLate.early or 0) / (earlyLate.late or 1)
end

---@param event any
function MiscScoreSystem:miss(event)
	self.deltaTime = event.deltaTime
end

---@param event any
function MiscScoreSystem:early(event)
	self.deltaTime = -math.huge
end

MiscScoreSystem.notes = {
	ShortNote = {
		clear = {
			passed = "hit",
			missed = "miss",
			clear = "early",
		},
	},
	LongNote = {
		clear = {
			startPassedPressed = "hit",
			startMissed = "miss",
			startMissedPressed = "miss",
			clear = "early",
		},
		startPassedPressed = {
			startMissed = nil,
			endMissed = "miss",
			endPassed = "hit",
		},
		startMissedPressed = {
			endMissedPassed = "hit",
			startMissed = nil,
			endMissed = "miss",
		},
		startMissed = {
			startMissedPressed = nil,
			endMissed = "miss",
		},
	},
}

return MiscScoreSystem
