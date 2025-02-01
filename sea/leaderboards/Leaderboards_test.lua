local Leaderboards = require("sea.leaderboards.Leaderboards")
local Leaderboard = require("sea.leaderboards.Leaderboard")
local User = require("sea.access.User")
local FakeLeaderboardsRepo = require("sea.leaderboards.repos.FakeLeaderboardsRepo")

local test = {}

---@param t testing.T
function test.basic(t)
	local leaderboards_repo = FakeLeaderboardsRepo()
	local leaderboards = Leaderboards(leaderboards_repo)

	local leaderboard_values = Leaderboard()
	leaderboard_values.name = "New leaderboard"

	local leaderboard, err = leaderboards:create(User({id = 1}), leaderboard_values)

	if t:assert(leaderboard, err) then
		---@cast leaderboard -?
		t:eq(leaderboard.name, "New leaderboard")
	end
end

return test
