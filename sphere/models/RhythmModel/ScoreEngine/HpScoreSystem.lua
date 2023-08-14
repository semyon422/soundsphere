local ScoreSystem = require("sphere.models.RhythmModel.ScoreEngine.ScoreSystem")

local HpScoreSystem = ScoreSystem + {}

HpScoreSystem.name = "hp"

HpScoreSystem.max = 1000

function HpScoreSystem:insertCounter(notes)
	table.insert(self, {
		notes = notes,
		value = self.max / 2,
	})
end

function HpScoreSystem:load()
	for i in ipairs(self) do
		self[i] = nil
	end

	local config = self.scoreEngine.hp
	if not config.shift then
		self:insertCounter(config.notes)
		return
	end

	for i = 0, math.min(config.notes, 9) do
		self:insertCounter(i)
	end
	for i = 10, config.notes, 5 do
		self:insertCounter(i)
	end
end

function HpScoreSystem:getSlice()
	local slice = {}
	for _, v in ipairs(self) do
		table.insert(slice, {
			notes = v.notes,
			value = v.value,
		})
	end
	return slice
end

function HpScoreSystem:getCurrent()
	for _, h in ipairs(self) do
		if h.value > 0 then
			return h.value, h.notes
		end
	end
	return 0, 1
end

function HpScoreSystem:isFailed()
	local _h
	for _, h in ipairs(self) do
		if h.value > 0 then
			_h = h
			break
		end
	end
	return not _h
end

function HpScoreSystem:increase()
	for _, h in ipairs(self) do
		if h.value > 0 then
			h.value = math.min(h.value + 1, self.max)
		end
	end
end

function HpScoreSystem:decrease()
	for _, h in ipairs(self) do
		if h.value > 0 then
			h.value = math.min(h.value - self.max / h.notes, self.max)
		end
		if h.value < 1e-3 then
			h.value = 0
		end
	end
end

HpScoreSystem.notes = {
	ShortNote = {
		clear = {
			passed = "increase",
			missed = "decrease",
			clear = nil,
		},
	},
	LongNote = {
		clear = {
			startPassedPressed = "increase",
			startMissed = "decrease",
			startMissedPressed = "decrease",
			clear = nil,
		},
		startPassedPressed = {
			startMissed = nil,
			endMissed = "decrease",
			endPassed = "increase",
		},
		startMissedPressed = {
			endMissedPassed = "increase",
			startMissed = nil,
			endMissed = "decrease",
		},
		startMissed = {
			startMissedPressed = nil,
			endMissed = "decrease",
		},
	},
}

return HpScoreSystem
