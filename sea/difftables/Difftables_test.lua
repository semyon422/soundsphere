local User = require("sea.access.User")
local Difftables = require("sea.difftables.Difftables")
local FakeDifftablesRepo = require("sea.difftables.repos.FakeDifftablesRepo")

local test = {}

---@param t testing.T
function test.basic(t)
	local difftablesRepo = FakeDifftablesRepo()
	local difftables = Difftables(difftablesRepo)

	local user = User()
	user.id = 1

	local difftable, err = difftables:create(user, "Difftable")
	if not t:assert(difftable, err) then
		return
	end

	---@cast difftable -?
	t:eq(difftable.name, "Difftable")

	local dt_cm, err = difftables:setDifftableChartmeta(user, difftable.id, "", 1, 12)
	if not t:assert(dt_cm, err) then
		return
	end

	---@cast dt_cm -?
	t:eq(dt_cm.level, 12)

	local dt_cm, err = difftables:setDifftableChartmeta(user, difftable.id, "", 1, 10)
	if not t:assert(dt_cm, err) then
		return
	end

	---@cast dt_cm -?
	t:eq(dt_cm.level, 10)

	local dt_cm, err = difftables:setDifftableChartmeta(user, difftable.id, "", 1, nil)
	t:assert(not dt_cm)
end

return test
