local ITimingValuesPreset = require("sea.timings.ITimingValuesPreset")
local TimingValues = require("sea.chart.TimingValues")
local Timings = require("sea.chart.Timings")
local Subtimings = require("sea.chart.Subtimings")

---@class sea.QuaverTimings_v1: sea.ITimingValuesPreset
---@operator call: sea.QuaverTimings_v1
local QuaverTimings = ITimingValuesPreset + {}

local windows = {
	marvelous = 0.018,
	perfect = 0.043,
	great = 0.076,
	good = 0.106,
	okay = 0.127,
	miss = 0.164,
}

---@return sea.TimingValues
function QuaverTimings:getTimingValues()
	local a, b, c, d = -windows.miss, -windows.okay, windows.okay, windows.miss

	local tvs = TimingValues()
	tvs.ShortNote = {hit = {b, c}, miss = {a, d}}
	tvs.LongNoteStart = {hit = {b, c}, miss = {a, d}}
	tvs.LongNoteEnd = {hit = {b, c}, miss = {a, d}}

	return tvs
end

---@param tvs sea.TimingValues
---@return sea.Timings?
---@return sea.Subtimings?
function QuaverTimings:match(tvs)
	local _tvs = self:getTimingValues()
	if not _tvs:equals(tvs) then
		return
	end
	return Timings("quaver"), Subtimings("none")
end

return QuaverTimings
