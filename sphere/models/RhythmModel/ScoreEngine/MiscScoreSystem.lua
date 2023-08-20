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

	local counters = self.container.judgement.counters

	self.ratio = (counters.soundsphere.perfect or 0) / (counters.all.count or 1)
	self.earlylate = (counters.earlylate.early or 0) / (counters.earlylate.late or 1)
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
