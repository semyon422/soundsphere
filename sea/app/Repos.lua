local class = require("class")
local UsersRepo = require("sea.access.repos.UsersRepo")
local LeaderboardsRepo = require("sea.leaderboards.repos.LeaderboardsRepo")
local TeamsRepo = require("sea.teams.repos.TeamsRepo")
local DifftablesRepo = require("sea.difftables.repos.DifftablesRepo")
local ChartsRepo = require("sea.chart.repos.ChartsRepo")
local ChartfilesRepo = require("sea.chart.repos.ChartfilesRepo")
local ComputeTasksRepo = require("sea.compute.repos.ComputeTasksRepo")
local DanClearsRepo = require("sea.dan.repos.DanClearsRepo")

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
	self.chartfiles_repo = ChartfilesRepo(models)
	self.compute_tasks_repo = ComputeTasksRepo(models)
	self.dan_clears_repo = DanClearsRepo(models)
end

return Repos
