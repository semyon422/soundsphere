local ScoreSystem = require("sphere.models.RhythmModel.ScoreEngine.ScoreSystem")

---@class sphere.MiscScore: sphere.ScoreSystem
---@operator call: sphere.MiscScore
local MiscScore = ScoreSystem + {}

function MiscScore:new()
	self.maxDeltaTime = 0
	self.deltaTime = 0

	self.earlyLate = {
		early = 0,
		late = 0,
	}
end

---@return string
function MiscScore:getKey()
	return "misc"
end

---@param event rizu.LogicNoteChange
function MiscScore:hit(event)
	---@type number
	local deltaTime = event.delta_time
	self.deltaTime = deltaTime
	if math.abs(deltaTime) > math.abs(self.maxDeltaTime) then
		self.maxDeltaTime = deltaTime
	end

	if deltaTime < 0 then
		self.earlyLate.early = self.earlyLate.early + 1
	else
		self.earlyLate.late = self.earlyLate.late + 1
	end
end

---@param event rizu.LogicNoteChange
function MiscScore:miss(event)
	self.deltaTime = event.delta_time
end

---@param event rizu.LogicNoteChange
function MiscScore:early(event)
	self.deltaTime = -math.huge
end

function MiscScore:getSlice()
	return {
		maxDeltaTime = self.maxDeltaTime,
		deltaTime = self.deltaTime,
	}
end

MiscScore.events = {
	tap = {
		clear = {
			passed = "hit",
			missed = "miss",
			clear = "early",
		},
	},
	hold = {
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

return MiscScore
