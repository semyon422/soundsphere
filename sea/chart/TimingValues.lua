local class = require("class")
local osuMania = require("sphere.models.RhythmModel.ScoreEngine.OsuManiaScoring")
local osuLegacy = require("sphere.models.RhythmModel.ScoreEngine.OsuLegacyScoring")
local etterna = require("sphere.models.RhythmModel.ScoreEngine.EtternaScoring")
local quaver = require("sphere.models.RhythmModel.ScoreEngine.QuaverScoring")
local lr2 = require("sphere.models.RhythmModel.ScoreEngine.LunaticRaveScoring")

---@alias sea.TimingObjectValues {hit: {[1]: number, [2]: number}, miss: {[1]: number, [2]: number}}

-- TODO: user NoteType+weight as key

---@class sea.TimingValues
---@operator call: sea.TimingValues
---@field ShortNote sea.TimingObjectValues
---@field LongNoteStart sea.TimingObjectValues
---@field LongNoteEnd sea.TimingObjectValues
local TimingValues = class()

function TimingValues:new()
	self:setSimple(0, 0)
end

---@param h number
---@param m number?
---@return sea.TimingValues
function TimingValues:setSimple(h, m)
	m = m or h
	self.ShortNote = {hit = {-h, h}, miss = {-m, m}}
	self.LongNoteStart = {hit = {-h, h}, miss = {-m, m}}
	self.LongNoteEnd = {hit = {-h, h}, miss = {-m, m}}
	return self
end

local err_msg = "invalid timings-subtimings pair"

---@param values sea.TimingValues
function TimingValues:copyFrom(values)
	self.ShortNote = values.ShortNote
	self.LongNoteStart = values.LongNoteStart
	self.LongNoteEnd = values.LongNoteEnd
	return self
end

---@param t sea.Timings
---@param st sea.Subtimings
---@return sea.TimingValues?
---@return string?
function TimingValues:fromTimings(t, st)
	local tn, tv = t.name, t.data
	local stn, stv = st.name, st.data

	if tn == "simple" then
		if stn ~= "window" then
			return nil, err_msg
		end
		return self:setSimple(stv)
	elseif tn == "osumania" then
		if stn ~= "scorev" then
			return nil, err_msg
		end
		if stv == 1 then
			return self:copyFrom(osuLegacy:getTimings(tv))
		elseif stv == 2 then
			return self:copyFrom(osuMania:getTimings(tv))
		end
	elseif tn == "stepmania" then
		if stn ~= "etternaj" then
			return nil, err_msg
		end
		return self:copyFrom(etterna:getTimings())
	elseif tn == "quaver" then
		if stn ~= "none" then
			return nil, err_msg
		end
		return self:copyFrom(quaver:getTimings())
	elseif tn == "bmsrank" then
		if stn ~= "none" then
			return nil, err_msg
		end
		return self:copyFrom(lr2:getTimings())
	end

	return self:setSimple(0, 0)
end

return TimingValues
