local UserRole = require("sea.access.UserRole")

local test = {}

---@param t testing.T
function test.no_expire_time(t)
	local time = 100

	local user_role = UserRole("owner", time)

	t:assert(not user_role.expires_at)
	t:eq(user_role:getTotalTime(time - 10), 0)
	t:eq(user_role:getTotalTime(time), 0)
	t:eq(user_role:getTotalTime(time + 10), 10)
	t:eq(user_role:getTotalTime(time + 20), 20)
end

---@param t testing.T
function test.add_1(t)
	local time = 100

	local user_role = UserRole("owner", time)
	user_role:addTime(10, time)

	t:eq(user_role.expires_at, 110)
	t:eq(user_role:getTotalTime(time), 0)
	t:eq(user_role:getTotalTime(time + 10), 10)
	t:eq(user_role:getTotalTime(time + 20), 10)
end

---@param t testing.T
function test.add_2(t)
	local time = 100

	local user_role = UserRole("owner", time)
	user_role:addTime(20, time)

	time = 110
	user_role:addTime(-5, time)

	t:eq(user_role.expires_at, 115)
	t:eq(user_role:getTotalTime(time), 10)
	t:eq(user_role:getTotalTime(time + 10), 15)
end

---@param t testing.T
function test.add_3(t)
	local time = 100

	local user_role = UserRole("owner", time)
	user_role:addTime(20, time)

	time = 110
	user_role:addTime(-15, time)

	t:eq(user_role.expires_at, 110)
	t:eq(user_role:getTotalTime(time), 10)
	t:eq(user_role:getTotalTime(time + 10), 10)
end

---@param t testing.T
function test.add_4(t)
	local time = 100

	local user_role = UserRole("owner", time)
	user_role:addTime(10, time)

	time = 120
	user_role:addTime(5, time)

	t:eq(user_role.expires_at, 125)
	t:eq(user_role:getTotalTime(time), 10)
	t:eq(user_role:getTotalTime(time + 10), 15)
end

---@param t testing.T
function test.add_5(t)
	local time = 100

	local user_role = UserRole("owner", time)
	user_role:addTime(10, time)

	time = 120
	user_role:addTime(-5, time)

	t:eq(user_role.expires_at, 120)
	t:eq(user_role:getTotalTime(time), 10)
	t:eq(user_role:getTotalTime(time + 10), 10)
end

---@param t testing.T
function test.add_6(t)
	local time = 100

	local user_role = UserRole("owner", time)
	user_role:addTime(10, time)

	time = 120
	user_role:addTime(-15, time)

	t:eq(user_role.expires_at, 120)
	t:eq(user_role:getTotalTime(time), 10)
	t:eq(user_role:getTotalTime(time + 10), 10)
end

return test
