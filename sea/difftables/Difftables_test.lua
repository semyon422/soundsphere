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

	local difftable_chart, err = difftables:setDifftableChart(user, difftable.id, 1, 12)
	if not t:assert(difftable_chart, err) then
		return
	end

	---@cast difftable_chart -?
	t:eq(difftable_chart.level, 12)

	local difftable_chart, err = difftables:setDifftableChart(user, difftable.id, 1, 10)
	if not t:assert(difftable_chart, err) then
		return
	end

	---@cast difftable_chart -?
	t:eq(difftable_chart.level, 10)
end

return test
