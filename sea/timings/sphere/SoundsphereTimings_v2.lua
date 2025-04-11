local ITimingValuesPreset = require("sea.timings.ITimingValuesPreset")
local TimingValues = require("sea.chart.TimingValues")
local Timings = require("sea.chart.Timings")
local Subtimings = require("sea.chart.Subtimings")

---@class sea.SoundsphereTimings_v2: sea.ITimingValuesPreset
---@operator call: sea.SoundsphereTimings_v2
local SoundsphereTimings = ITimingValuesPreset + {}

---@return sea.TimingValues
function SoundsphereTimings:getTimingValues()
	local a, b, c, d = -0.16, -0.12, 0.12, 0.16

	local tvs = TimingValues()
	tvs.ShortNote = {hit = {b, c}, miss = {a, d}}
	tvs.LongNoteStart = {hit = {b, c}, miss = {a, d}}
	tvs.LongNoteEnd = {hit = {b, c}, miss = {a, d}}

	return tvs
end

---@param tvs sea.TimingValues
---@return sea.Timings?
---@return sea.Subtimings?
function SoundsphereTimings:match(tvs)
	local _tvs = self:getTimingValues()
	if not _tvs:equals(tvs) then
		return
	end
	return Timings("sphere"), Subtimings("none")
end

return SoundsphereTimings
