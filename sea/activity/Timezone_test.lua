local Timezone = require("sea.activity.Timezone")

local test = {}

---@param t testing.T
function test.encode_zero(t)
	local tz = Timezone()

	t:eq(tostring(tz), "+00:00")
	t:eq(tz:seconds(), 0)
	t:eq(tz:encode(), 0000)
	t:eq(Timezone.decode(0), tz)
end

---@param t testing.T
function test.encode_pozitive(t)
	local tz = Timezone(5)

	t:eq(tostring(tz), "+05:00")
	t:eq(tz:seconds(), 5 * 3600)
	t:eq(tz:encode(), 0500)
	t:eq(Timezone.decode(0500), tz)
end

---@param t testing.T
function test.encode_negative(t)
	local tz = Timezone(10, 30, true)

	t:eq(tostring(tz), "-10:30")
	t:eq(tz:seconds(), -(10 * 3600 + 30 * 60))
	t:eq(tz:encode(), -1030)
	t:eq(Timezone.decode(-1030), tz)
end

return test
