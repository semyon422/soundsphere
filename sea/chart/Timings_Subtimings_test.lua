local Timings = require("sea.chart.Timings")
local Subtimings = require("sea.chart.Subtimings")
local TimingValuesFactory = require("sea.chart.TimingValuesFactory")

local test = {}

---@param t testing.T
function test.timings(t)
	for i = -1, 2000 do
		t:eq(Timings.encode(Timings.decode(i)), i)
	end

	local unknown = Timings.decode(2000)
	t:eq(unknown.name, "unknown")
	t:eq(unknown.data, 2000)

	Timings("unknown", 1)
	Timings("arbitrary")
	Timings("sphere")
	Timings("simple")
	Timings("osumania", 8.1)
	Timings("stepmania")
	Timings("quaver")
	Timings("bmsrank")

	t:eq(t:has_error(Timings, "unknown", 0.1), "invalid")
	t:eq(t:has_error(Timings, "arbitrary", 1), "invalid")
	t:eq(t:has_error(Timings, "sphere", 1), "invalid")
	t:eq(t:has_error(Timings, "simple", 1), "invalid")
	t:eq(t:has_error(Timings, "osumania", 8.15), "invalid")
	t:eq(t:has_error(Timings, "stepmania", 1), "invalid")
	t:eq(t:has_error(Timings, "quaver", 1), "invalid")
	t:eq(t:has_error(Timings, "bmsrank", 4), "invalid")
end

---@param t testing.T
function test.subtimings(t)
	for i = -1, 3000 do
		t:eq(Subtimings.encode(Subtimings.decode(i)), i)
	end

	local unknown = Subtimings.decode(3000)
	t:eq(unknown.name, "unknown")
	t:eq(unknown.data, 3000)

	Subtimings("window", 0.100)
	Subtimings("scorev", 1)
	Subtimings("etternaj", 4)
	Subtimings("lunatic")
	Subtimings("none")

	t:eq(t:has_error(Subtimings, "window", -1), "invalid")
	t:eq(t:has_error(Subtimings, "scorev", 3), "invalid")
	t:eq(t:has_error(Subtimings, "etternaj", 10), "invalid")
	t:eq(t:has_error(Subtimings, "lunatic", 1), "invalid")
	t:eq(t:has_error(Subtimings, "none", 1), "invalid")
end

---@param t testing.T
function test.values(t)
	local factory = TimingValuesFactory()

	t:assert(factory:get(Timings("unknown"), Subtimings("none")))
	t:tdeq({factory:get(Timings("arbitrary"), Subtimings("none"))}, {nil, "undefined for arbitrary timings"})

	t:assert(factory:get(Timings("sphere"), Subtimings("none")))
	t:assert(factory:get(Timings("simple"), Subtimings("window", 0.100)))
	t:assert(factory:get(Timings("osumania", 8), Subtimings("scorev", 1)))
	t:assert(factory:get(Timings("stepmania"), Subtimings("etternaj", 4)))
	t:assert(factory:get(Timings("quaver"), Subtimings("none")))
	t:assert(factory:get(Timings("bmsrank", 3), Subtimings("lunatic")))

	t:assert(not factory:get(Timings("sphere"), Subtimings("scorev", 1)))
	t:assert(not factory:get(Timings("simple"), Subtimings("scorev", 1)))
	t:assert(not factory:get(Timings("osumania", 8), Subtimings("etternaj", 4)))
	t:assert(not factory:get(Timings("stepmania"), Subtimings("none")))
	t:assert(not factory:get(Timings("quaver"), Subtimings("scorev", 1)))
	t:assert(not factory:get(Timings("bmsrank"), Subtimings("none")))
end

return test
