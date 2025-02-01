local class = require("class")
local TestModel = require("rdb.TestModel")

---@class sea.FakeLeaderboardsRepo
---@operator call: sea.FakeLeaderboardsRepo
local FakeLeaderboardsRepo = class()

function FakeLeaderboardsRepo:new()
	self.leaderboards = TestModel()
end

---@return sea.Leaderboard[]
function FakeLeaderboardsRepo:getLeaderboards()
	return self.leaderboards:select()
end

---@param id integer
---@return sea.Leaderboard?
function FakeLeaderboardsRepo:getLeaderboard(id)
	return self.leaderboards:find({id = id})
end

---@param leaderboard sea.Leaderboard
---@return sea.Leaderboard
function FakeLeaderboardsRepo:createLeaderboard(leaderboard)
	return self.leaderboards:create(leaderboard)
end

---@param leaderboard sea.Leaderboard
---@return sea.Leaderboard
function FakeLeaderboardsRepo:updateLeaderboard(leaderboard)
	return self.leaderboards:update(leaderboard, {id = leaderboard.id})[1]
end

---@param id integer
---@return sea.Leaderboard?
function FakeLeaderboardsRepo:deleteLeaderboard(id)
	return self.leaderboards:remove({id = id})[1]
end

return FakeLeaderboardsRepo
