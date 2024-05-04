local serpent = require("serpent")

local opts = {
	indent = "\t",
	comment = false,
	sortkeys = true,
	numformat = "%.16g",
	custom = function(tag, head, body, tail)
		local out = head .. body .. tail
		if #tag > 0 then
			out = out:gsub("\n%s+", ""):gsub(",", ", ")
		end
		return tag .. out
	end,
}

local timings = {}

---@param a number
---@param b number
---@param c number
---@param d number
---@return table
local function get(a, b, c, d)
	return {
		nearest = false,
		ShortNote = { hit = { b, c }, miss = { a, d } },
		LongNoteStart = { hit = { b, c }, miss = { a, d } },
		LongNoteEnd = { hit = { b, c }, miss = { a, d } },
	}
end

timings.soundsphere = get(-0.16, -0.12, 0.12, 0.16)

local osuMania = require("sphere.models.RhythmModel.ScoreEngine.OsuManiaScoring")
local osuLegacy = require("sphere.models.RhythmModel.ScoreEngine.OsuLegacyScoring")
local etterna = require("sphere.models.RhythmModel.ScoreEngine.EtternaScoring")
local quaver = require("sphere.models.RhythmModel.ScoreEngine.QuaverScoring")
local lr2 = require("sphere.models.RhythmModel.ScoreEngine.LunaticRaveScoring")

timings.quaver = quaver:getTimings()
timings.etterna = etterna:getTimings()
timings.lr2 = lr2:getTimings()

local cachedOsuMania = {}

---@param od number
---@return table
function timings.osuMania(od)
	if cachedOsuMania[od] then
		return cachedOsuMania[od]
	end
	cachedOsuMania[od] = osuMania:getTimings(od)
	return cachedOsuMania[od]
end

local cachedOsuLegacy = {}

---@param od number
---@return table
function timings.osuLegacy(od)
	if cachedOsuLegacy[od] then
		return cachedOsuLegacy[od]
	end
	cachedOsuLegacy[od] = osuLegacy:getTimings(od)
	return cachedOsuLegacy[od]
end

---@param t table
---@return string
local function ser(t)
	return serpent.block(t, opts)
end

---@param t table
---@return string
function timings.getName(t)
	local s = ser(t)
	if s == ser(timings.soundsphere) then
		return "soundsphere"
	elseif s == ser(timings.lr2) then
		return "LR2"
	elseif s == ser(timings.quaver) then
		return "Quaver"
	end
	for od = 0, 10 do
		if s == ser(timings.osuMania(od)) then
			return "osu!mania OD" .. od
		end
	end
	for od = 0, 10 do
		if s == ser(timings.osuLegacy(od)) then
			return "osu!legacy OD" .. od
		end
	end
	for judge = 4, 9 do
		if s == ser(timings.etterna) then
			return "Etterna"
		end
	end
	return "custom"
end

return timings
