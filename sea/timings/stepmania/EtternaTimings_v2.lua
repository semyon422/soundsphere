local ITimingValuesPreset = require("sea.timings.ITimingValuesPreset")
local TimingValues = require("sea.chart.TimingValues")
local Timings = require("sea.chart.Timings")
local Subtimings = require("sea.chart.Subtimings")

---@class sea.EtternaTimings_v2: sea.ITimingValuesPreset
---@operator call: sea.EtternaTimings_v2
local EtternaTimings = ITimingValuesPreset + {}

---@param judge integer unused in this version
---@return sea.TimingValues
function EtternaTimings:getTimingValues(judge)
	local w = 0.18
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
function EtternaTimings:match(tvs)
	local _tvs = self:getTimingValues(4)
	if not _tvs:equals(tvs) then
		return
	end

	return Timings("etternaj", 4)
end

return EtternaTimings
