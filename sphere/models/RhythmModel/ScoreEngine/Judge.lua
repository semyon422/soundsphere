local class = require("class")

---@class sphere.Judge
---@operator call: sphere.Judge
local Judge = class()

Judge.scoreSystemName = ""

Judge.accuracy = 1
Judge.notes = 0

---@type string?
Judge.lastCounter = nil
Judge.lastUpdateTime = 0

Judge.orderedCounters = {}
Judge.weights = {}
Judge.windows = {}
Judge.counters = {}

Judge.earlyHitWindow = -120
Judge.lateHitWindow = 120
Judge.earlyMissWindow = 160
Judge.lateMissWindow = 160
Judge.windowReleaseMultiplier = 1.5

function Judge:calculateAccuracy() end

---@param key string
---@param currentTime number
function Judge:addCounter(key, currentTime)
	self.notes = self.notes + 1
	self.counters[key] = self.counters[key] + 1
	self.lastCounter = key
	self.lastUpdateTime = currentTime
end

---@param event table
function Judge:processEvent(event) end

---@return table
function Judge:getTimings()
	local early_hit = self.earlyHitWindow
	local late_hit = self.lateHitWindow
	local early_miss = self.earlyMissWindow
	local late_miss = self.lateMissWindow
	local release_multi = self.windowReleaseMultiplier

	return {
		nearest = true,
		ShortNote = { hit = { early_hit, late_hit }, miss = { early_miss, late_miss } },
		LongNoteStart = { hit = { early_hit, late_hit }, miss = { early_miss, late_miss } },
		LongNoteEnd = {
			hit = { early_hit * release_multi, late_hit * release_multi },
			miss = { early_miss * release_multi, late_miss * release_multi },
		},
	}
end

return Judge
