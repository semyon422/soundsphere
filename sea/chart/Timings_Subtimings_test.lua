local Timings = require("sea.chart.Timings")
local Subtimings = require("sea.chart.Subtimings")
local TimingValues = require("sea.chart.TimingValues")

local test = {}

---@param t testing.T
function test.timings(t)
	for i = -1, 2000 do
		t:eq(Timings.encode(Timings.decode(i)), i)
	end

	Timings("simple")
	Timings("osumania", 8.1)
	Timings("stepmania")
	Timings("quaver")
	Timings("bmsrank")

	t:has_error(Timings, "simple", 1)
	t:has_error(Timings, "osumania", 8.15)
	t:has_error(Timings, "stepmania", 1)
	t:has_error(Timings, "quaver", 1)
	t:has_error(Timings, "bmsrank", 4)
end

---@param t testing.T
function test.subtimings(t)
	t:eq(Subtimings.encode(Subtimings.decode(100, "simple")), 100)
	t:eq(Subtimings.encode(Subtimings.decode(2, "osumania")), 2)
	t:eq(Subtimings.encode(Subtimings.decode(4, "stepmania")), 4)
	t:eq(Subtimings.encode(Subtimings.decode(0, "quaver")), 0)
	t:eq(Subtimings.encode(Subtimings.decode(0, "bmsrank")), 0)

	Subtimings("window", 0.100)
	Subtimings("scorev", 1)
	Subtimings("etternaj", 4)

	t:has_error(Subtimings, "window", -1)
	t:has_error(Subtimings, "scorev", 3)
	t:has_error(Subtimings, "etternaj", 10)
end

---@param t testing.T
function test.values(t)
	t:assert(TimingValues():fromTimings(Timings("simple"), Subtimings("window", 0.100)))
	t:assert(TimingValues():fromTimings(Timings("osumania", 8), Subtimings("scorev", 1)))
	t:assert(TimingValues():fromTimings(Timings("stepmania"), Subtimings("etternaj", 4)))
	t:assert(TimingValues():fromTimings(Timings("quaver"), Subtimings("none")))
	t:assert(TimingValues():fromTimings(Timings("bmsrank", 3), Subtimings("none")))

	t:assert(not TimingValues():fromTimings(Timings("simple"), Subtimings("scorev", 1)))
	t:assert(not TimingValues():fromTimings(Timings("osumania", 8), Subtimings("etternaj", 4)))
	t:assert(not TimingValues():fromTimings(Timings("stepmania"), Subtimings("none")))
	t:assert(not TimingValues():fromTimings(Timings("quaver"), Subtimings("scorev", 1)))
	t:assert(not TimingValues():fromTimings(Timings("bmsrank"), Subtimings("scorev", 1)))
end

return test
