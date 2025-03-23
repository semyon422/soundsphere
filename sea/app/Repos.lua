local class = require("class")
local UsersRepo = require("sea.access.repos.UsersRepo")
local LeaderboardsRepo = require("sea.leaderboards.repos.LeaderboardsRepo")
local TeamsRepo = require("sea.teams.repos.TeamsRepo")
local DifftablesRepo = require("sea.difftables.repos.DifftablesRepo")

---@class sea.Repos
---@operator call: sea.Repos
local Repos = class()

---@param models rdb.Models
function Repos:new(models)
	self.users_repo = UsersRepo(models)
	self.leaderboards_repo = LeaderboardsRepo(models)
	self.teams_repo = TeamsRepo(models)
	self.difftables_repo = DifftablesRepo(models)
end

return Repos
