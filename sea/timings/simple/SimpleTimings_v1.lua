local ITimingValuesPreset = require("sea.timings.ITimingValuesPreset")
local TimingValues = require("sea.chart.TimingValues")
local Timings = require("sea.chart.Timings")
local Subtimings = require("sea.chart.Subtimings")

---@class sea.SimpleTimings_v1: sea.ITimingValuesPreset
---@operator call: sea.SimpleTimings_v1
local SimpleTimings = ITimingValuesPreset + {}

---@param w_ms integer
---@return sea.TimingValues
function SimpleTimings:getTimingValues(w_ms)
	local w = w_ms / 1000
	local a, b, c, d = -w, -w, w, w

	local tvs = TimingValues()
	tvs.ShortNote = {hit = {b, c}, miss = {a, d}}
	tvs.LongNoteStart = {hit = {b, c}, miss = {a, d}}
	tvs.LongNoteEnd = {hit = {b, c}, miss = {a, d}}

	return tvs
end

---@param tvs sea.TimingValues
---@return sea.Timings?
---@return sea.Subtimings?
function SimpleTimings:match(tvs)
	local w_ms = math.floor(-tvs.ShortNote.miss[1] * 1000 + 0.5)
	local _tvs = self:getTimingValues(w_ms)
	if not _tvs:equals(tvs) then
		return
	end
	return Timings("simple"), Subtimings("window", w_ms / 1000)
end

return SimpleTimings
