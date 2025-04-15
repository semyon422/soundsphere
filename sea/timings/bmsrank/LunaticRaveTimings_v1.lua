local ITimingValuesPreset = require("sea.timings.ITimingValuesPreset")
local TimingValues = require("sea.chart.TimingValues")
local Timings = require("sea.chart.Timings")
local Subtimings = require("sea.chart.Subtimings")

---@class sea.LunaticRaveTimings_v1: sea.ITimingValuesPreset
---@operator call: sea.LunaticRaveTimings_v1
local LunaticRaveTimings = ITimingValuesPreset + {}

---@return sea.TimingValues
function LunaticRaveTimings:getTimingValues()
	local a, b, c, d = -1, -0.2, 0.2, 0.2

	local tvs = TimingValues()
	tvs.ShortNote = {hit = {b, c}, miss = {a, d}}
	tvs.LongNoteStart = {hit = {b, c}, miss = {a, d}}
	tvs.LongNoteEnd = {hit = {b, c}, miss = {a, d}}

	return tvs
end

---@param tvs sea.TimingValues
---@return sea.Timings?
---@return sea.Subtimings?
function LunaticRaveTimings:match(tvs)
	local _tvs = self:getTimingValues()
	if not _tvs:equals(tvs) then
		return
	end
	return Timings("bmsrank", 3)
end

return LunaticRaveTimings
