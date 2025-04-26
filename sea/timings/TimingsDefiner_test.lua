local TimingsDefiner = require("sea.timings.TimingsDefiner")
local Timings = require("sea.chart.Timings")
local Subtimings = require("sea.chart.Subtimings")
local TimingValues = require("sea.chart.TimingValues")

local test = {}

local function match(...)
	return TimingsDefiner:match(...)
end

---@param a number
---@param b number
---@param c number
---@param d number
---@return sea.TimingValues
local function from_abcd(a, b, c, d)
	local tvs = TimingValues()
	tvs.ShortNote = {hit = {b, c}, miss = {a, d}}
	tvs.LongNoteStart = {hit = {b, c}, miss = {a, d}}
	tvs.LongNoteEnd = {hit = {b, c}, miss = {a, d}}
	return tvs
end

---@param t testing.T
function test.not_matched(t)
	local tvs = from_abcd(-0.188, -0.151, 0.151, 0.150)
	t:assert(not match(tvs))
end

--- osumania_v1 ----------------------------------------------------------------

---@param t testing.T
function test.osumania_v1_v1(t)
	local tvs = from_abcd(-0.188, -0.151, 0.151, 0.151)
	t:tdeq({match(tvs)}, {Timings("osuod", 0), Subtimings("scorev", 1)})

	tvs = from_abcd(-0.185, -0.148, 0.148, 0.148) -- (t - 0.003)
	t:tdeq({match(tvs)}, {Timings("osuod", 1), Subtimings("scorev", 1)})
end

---@param t testing.T
function test.osumania_v1_v2(t)
	local tvs = from_abcd(-0.188, -0.151, 0.151, 0.188)
	tvs.LongNoteEnd = {hit = {-0.2265, 0.2265}, miss = {-0.282, 0.282}}
	t:tdeq({match(tvs)}, {Timings("osuod", 0), Subtimings("scorev", 1)})

	tvs = from_abcd(-0.185, -0.148, 0.148, 0.185)
	tvs.LongNoteEnd = {hit = {-0.222, 0.222}, miss = {-0.2775, 0.2775}} -- (t - 0.003) * 1.5
	t:tdeq({match(tvs)}, {Timings("osuod", 1), Subtimings("scorev", 1)})
end

---@param t testing.T
function test.osumania_v1_v3(t)
	local tvs = from_abcd(-0.188, -0.151, 0.127, 0.127)
	t:tdeq({match(tvs)}, {Timings("osuod", 0), Subtimings("scorev", 1)})

	tvs = from_abcd(-0.185, -0.148, 0.124, 0.124) -- (t - 0.003)
	t:tdeq({match(tvs)}, {Timings("osuod", 1), Subtimings("scorev", 1)})
end

---@param t testing.T
function test.osumania_v1_v4(t)
	local tvs = from_abcd(-0.188, -0.151, 0.127, 0.127)
	t:tdeq({match(tvs)}, {Timings("osuod", 0), Subtimings("scorev", 1)})

	tvs = from_abcd(-0.187, -0.150, 0.126, 0.126) -- (t - 0.001)
	t:tdeq({match(tvs)}, {Timings("osuod", 0.4), Subtimings("scorev", 1)})

	tvs = from_abcd(-0.186, -0.149, 0.125, 0.125) -- (t - 0.002)
	t:tdeq({match(tvs)}, {Timings("osuod", 0.7), Subtimings("scorev", 1)})
end

--- osumania_v2 ----------------------------------------------------------------

---@param t testing.T
function test.osumania_v2_v1(t)
	local tvs = from_abcd(-0.188, -0.151, 0.127, 0.127)
	tvs.LongNoteEnd = {hit = {-0.2265, 0.1905}, miss = {-0.282, 0.1905}}
	t:tdeq({match(tvs)}, {Timings("osuod", 0), Subtimings("scorev", 2)})

	tvs = from_abcd(-0.185, -0.148, 0.124, 0.124) -- (t - 0.003)
	tvs.LongNoteEnd = {hit = {-0.222, 0.186}, miss = {-0.2775, 0.186}}
	t:tdeq({match(tvs)}, {Timings("osuod", 1), Subtimings("scorev", 2)})
end

---@param t testing.T
function test.osumania_v2_v2(t)
	local tvs = from_abcd(-0.188, -0.151, 0.127, 0.127)
	tvs.LongNoteEnd = {hit = {-0.2265, 0.1905}, miss = {-0.282, 0.1905}}
	t:tdeq({match(tvs)}, {Timings("osuod", 0), Subtimings("scorev", 2)})

	tvs = from_abcd(-0.187, -0.150, 0.126, 0.126)
	tvs.LongNoteEnd = {hit = {-0.225, 0.189}, miss = {-0.280, 0.189}} -- (t - 0.001) * 1.5
	t:tdeq({match(tvs)}, {Timings("osuod", 0.4), Subtimings("scorev", 2)})
end

--- soundsphere_v1 -------------------------------------------------------------

---@param t testing.T
function test.soundsphere_v1(t)
	local tvs = {
		ShortNote = {hit = {-0.12, 0.12}, miss = {-0.16, 0.12}},
		LongNoteStart = {hit = {-0.12, 0.12}, miss = {-0.16, 0.12}},
		LongNoteEnd = {hit = {-0.12, 0.12}, miss = {-0.16, 0.12}},
	}
	t:tdeq({match(tvs)}, {Timings("sphere"), nil})
end

return test
