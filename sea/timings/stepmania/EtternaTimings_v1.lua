local ITimingValuesPreset = require("sea.timings.ITimingValuesPreset")
local TimingValues = require("sea.chart.TimingValues")
local Timings = require("sea.chart.Timings")
local Subtimings = require("sea.chart.Subtimings")

---@class sea.EtternaTimings_v1: sea.ITimingValuesPreset
---@operator call: sea.EtternaTimings_v1
local EtternaTimings = ITimingValuesPreset + {}

local windows = {
	{33.75, 67.5, 135, 202.5, 270},
	{29.925, 59.85, 119.7, 179.55, 239.4},
	{26.1, 52.2, 104.4, 156.6, 208.8},
	{22.5, 45, 90, 135, 180},
	{18.9, 37.8, 75.6, 113.4, 180},
	{14.85, 29.7, 59.4, 89.1, 180},
	{11.25, 22.5, 45, 67.5, 180},
	{7.425, 14.85, 29.7, 44.55, 180},
	{4.5, 9, 18, 27, 180},
}

---@param judge integer
---@return sea.TimingValues
function EtternaTimings:getTimingValues(judge)
	local w = windows[judge]

	local hit, miss = w[4] / 1000, w[5] / 1000
	local a, b, c, d = -miss, -hit, hit, miss

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
	local hit = tvs.ShortNote.hit[2] * 1000

	---@type integer
	local judge
	for j, t in ipairs(windows) do
		if math.abs(t[4] - hit) < 1e-9 then
			judge = j
			break
		end
	end

	if not judge then
		return
	end

	local _tvs = self:getTimingValues(judge)
	if not _tvs:equals(tvs) then
		return
	end

	return Timings("etternaj", judge)
end

return EtternaTimings
