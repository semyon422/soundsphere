local class = require("class")
local Users = require("sea.access.Users")
local Leaderboards = require("sea.leaderboards.Leaderboards")
local Teams = require("sea.teams.Teams")
local Difftables = require("sea.difftables.Difftables")
local Chartplays = require("sea.chart.Chartplays")
local IPasswordHasher = require("sea.access.IPasswordHasher")
local TableStorage = require("sea.chart.storage.TableStorage")
local ChartplayComputer = require("sea.chart.ChartplayComputer")

---@class sea.Domain
---@operator call: sea.Domain
local Domain = class()

---@param repos sea.Repos
function Domain:new(repos)
	self.charts_storage = TableStorage()
	self.replays_storage = TableStorage()

	self.users = Users(repos.users_repo, IPasswordHasher())
	self.leaderboards = Leaderboards(repos.leaderboards_repo)
	self.teams = Teams(repos.teams_repo)
	self.difftables = Difftables(repos.difftables_repo)
	self.chartplays = Chartplays(
		repos.charts_repo,
		ChartplayComputer(self.charts_storage, self.replays_storage),
		self.charts_storage,
		self.replays_storage,
		self.leaderboards
	)
end

return Domain
