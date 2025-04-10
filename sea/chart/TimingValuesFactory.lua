local class = require("class")
local TimingValues = require("sea.chart.TimingValues")

local OsuManiaV1Timings = require("sea.timings.osumania.OsuManiaV1Timings_v4")
local OsuManiaV2Timings = require("sea.timings.osumania.OsuManiaV2Timings_v2")
local SoundsphereTimings = require("sea.timings.sphere.SoundsphereTimings_v1")
local QuaverTimings = require("sea.timings.quaver.QuaverTimings_v1")
local LunaticRaveTimings = require("sea.timings.bmsrank.LunaticRaveTimings_v1")
local EtternaTimings = require("sea.timings.stepmania.EtternaTimings_v2")

---@class sea.TimingValuesFactory
---@operator call: sea.TimingValuesFactory
local TimingValuesFactory = class()

local err_msg = "invalid timings-subtimings pair"

---@param t sea.Timings
---@param st sea.Subtimings
---@return sea.TimingValues?
---@return string?
function TimingValuesFactory:get(t, st)
	local tn, tv = t.name, t.data
	local stn, stv = st.name, st.data

	if tn == "arbitrary" then
		if stn == "none" then
			return nil, "undefined for arbitrary timings"
		end
		return nil, err_msg
	elseif tn == "sphere" then
		if stn == "none" then
			return SoundsphereTimings:getTimingValues()
		end
		return nil, err_msg
	elseif tn == "simple" then
		if stn == "window" then
			return TimingValues():setSimple(stv)
		end
		return nil, err_msg
	elseif tn == "osumania" then
		if stn == "scorev" then
			if stv == 1 then
				return OsuManiaV1Timings:getTimingValues(tv)
			elseif stv == 2 then
				return OsuManiaV2Timings:getTimingValues(tv)
			end
		end
		return nil, err_msg
	elseif tn == "stepmania" then
		if stn == "etternaj" then
			return EtternaTimings:getTimingValues(stv)
		end
		return nil, err_msg
	elseif tn == "quaver" then
		if stn == "none" then
			return QuaverTimings:getTimingValues()
		end
		return nil, err_msg
	elseif tn == "bmsrank" then
		if stn == "lunatic" then
			return LunaticRaveTimings:getTimingValues()
		end
		return nil, err_msg
	elseif tn == "unknown" then
		if stn == "none" then
			return TimingValues():setSimple(0, 0)
		end
		return nil, err_msg
	end

	error("invalid timings object")
end

return TimingValuesFactory
