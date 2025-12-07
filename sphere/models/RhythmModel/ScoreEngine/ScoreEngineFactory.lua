local class = require("class")

local BaseScore = require("sphere.models.RhythmModel.ScoreEngine.scores.BaseScore")
local HpScore = require("sphere.models.RhythmModel.ScoreEngine.scores.HpScore")
local NormalscoreScore = require("sphere.models.RhythmModel.ScoreEngine.scores.NormalscoreScore")
local MiscScore = require("sphere.models.RhythmModel.ScoreEngine.scores.MiscScore")
local SoundsphereScore = require("sphere.models.RhythmModel.ScoreEngine.scores.SoundsphereScore")
local OsuManiaV1Score = require("sphere.models.RhythmModel.ScoreEngine.scores.OsuManiaV1Score")
local OsuManiaV2Score = require("sphere.models.RhythmModel.ScoreEngine.scores.OsuManiaV2Score")
local QuaverScore = require("sphere.models.RhythmModel.ScoreEngine.scores.QuaverScore")
local EtternaAccuracy = require("sphere.models.RhythmModel.ScoreEngine.scores.EtternaAccuracy")
local EtternaJudges = require("sphere.models.RhythmModel.ScoreEngine.scores.EtternaJudges")
local LunaticRaveScore = require("sphere.models.RhythmModel.ScoreEngine.scores.LunaticRaveScore")

---@class sphere.ScoreEngineFactory
---@operator call: sphere.ScoreEngineFactory
local ScoreEngineFactory = class()

local err_msg = "invalid timings-subtimings pair"

---@see sea.TimingValuesFactory
---@param t sea.Timings
---@param st sea.Subtimings?
---@return sphere.ScoreSystem[]?
---@return string?
function ScoreEngineFactory:get(t, st)
	local tn, tv = t.name, t.data

	if tn == "arbitrary" then
		if not st then
			return nil, "undefined for arbitrary timings"
		end
		return nil, err_msg
	elseif tn == "sphere" then
		if not st then
			return {SoundsphereScore()}
		end
		return nil, err_msg
	elseif tn == "simple" then
		if not st then
			return nil, "not implemented"
		end
		return nil, err_msg
	elseif tn == "osuod" then
		local stn, stv = "scorev", 1
		if st then
			stn, stv = st.name, st.data
		end
		if stn == "scorev" then
			if stv == 1 then
				return {OsuManiaV1Score(tv)}
			elseif stv == 2 then
				return {OsuManiaV2Score(tv)}
			end
		end
		return nil, err_msg
	elseif tn == "etternaj" then
		if not st then
			return {EtternaJudges(tv), EtternaAccuracy(tv)}
		end
		return nil, err_msg
	elseif tn == "quaver" then
		if not st then
			return {QuaverScore()}
		end
		return nil, err_msg
	elseif tn == "bmsrank" then
		if not st then
			return {LunaticRaveScore(tv)}
		end
		return nil, err_msg
	elseif tn == "unknown" then
		if not st then
			return nil, "not implemented"
		end
		return nil, err_msg
	end

	error("invalid timings object")
end

return ScoreEngineFactory
