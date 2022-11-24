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
	end
}

local timings = {}

local function get(a, b, c, d)
	return {
		nearest = false,
		ShortNote = {hit = {b, c}, miss = {a, d}},
		LongNoteStart = {hit = {b, c}, miss = {a, d}},
		LongNoteEnd = {hit = {b, c}, miss = {a, d}},
	}
end

timings.soundsphere = get(-0.16, -0.12, 0.12, 0.16)

timings.lr2 = get(-1, -0.2, 0.2, 0.2)

local etterna = require("sphere.models.RhythmModel.ScoreEngine.etterna")

local cachedEtterna = {}
function timings.etterna(judge)
	if cachedEtterna[judge] then
		return cachedEtterna[judge]
	end
	local d = etterna[judge]
	local hit, miss = d[4] / 1000, d[5] / 1000
	cachedEtterna[judge] = get(-miss, -hit, hit, miss)
	cachedEtterna[judge].nearest = true
	return cachedEtterna[judge]
end

local cachedOsu = {}
function timings.osu(od)
	if cachedOsu[od] then
		return cachedOsu[od]
	end
	local _3od = 3 * od
	local _50 = (151 - _3od) / 1000
	local _0 = (188 - _3od) / 1000
	cachedOsu[od] = get(-_0, -_50, _50, _50)
	return cachedOsu[od]
end

local function ser(t)
	return serpent.block(t, opts)
end

function timings.getName(t)
	local s = ser(t)
	if s == ser(timings.soundsphere) then
		return "soundsphere"
	elseif s == ser(timings.lr2) then
		return "LR2"
	end
	for od = 0, 10 do
		if s == ser(timings.osu(od)) then
			return "osu OD" .. od
		end
	end
	for judge = 1, #etterna do
		if s == ser(timings.etterna(judge)) then
			return "Etterna Judgement " .. judge
		end
	end
	return "custom"
end

return timings
