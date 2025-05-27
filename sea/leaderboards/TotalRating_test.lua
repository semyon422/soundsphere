local TotalRating = require("sea.leaderboards.TotalRating")

local test = {}

---@param t testing.T
function test.accuracy(t)
	local tr = TotalRating()

	tr:calc({})

	t:eq(tr.accuracy, 0.032)
end

return test
