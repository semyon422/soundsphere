local class = require("class")
local UsersRepo = require("sea.access.repos.UsersRepo")
local LeaderboardsRepo = require("sea.leaderboards.repos.LeaderboardsRepo")
local TeamsRepo = require("sea.teams.repos.TeamsRepo")
local DifftablesRepo = require("sea.difftables.repos.DifftablesRepo")
local ChartsRepo = require("sea.chart.repos.ChartsRepo")

---@class sea.Repos
---@operator call: sea.Repos
local Repos = class()

---@param models rdb.Models
function Repos:new(models)
	self.users_repo = UsersRepo(models)
	self.leaderboards_repo = LeaderboardsRepo(models)
	self.teams_repo = TeamsRepo(models)
	self.difftables_repo = DifftablesRepo(models)
	self.charts_repo = ChartsRepo(models)
end

return Repos
