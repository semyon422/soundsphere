local class = require("class")
local Users = require("sea.access.Users")
local UserRoles = require("sea.access.UserRoles")
local IEmailSender = require("sea.access.IEmailSender")
local Leaderboards = require("sea.leaderboards.Leaderboards")
local Teams = require("sea.teams.Teams")
local Difftables = require("sea.difftables.Difftables")
local Chartplays = require("sea.chart.Chartplays")
local BcryptPasswordHasher = require("sea.access.BcryptPasswordHasher")
local FolderStorage = require("sea.chart.storage.FolderStorage")
local ComputeDataProvider = require("sea.compute.ComputeDataProvider")
local ComputeDataLoader = require("sea.compute.ComputeDataLoader")
local ComputeTasks = require("sea.compute.ComputeTasks")
local ChartsComputer = require("sea.compute.ChartsComputer")

---@class sea.Domain
---@operator call: sea.Domain
local Domain = class()

---@param repos sea.Repos
function Domain:new(repos)
	self.charts_storage = FolderStorage("storages/charts")
	self.replays_storage = FolderStorage("storages/replays")
	self.compute_data_provider = ComputeDataProvider(repos.chartfiles_repo, self.charts_storage, self.replays_storage)
	self.compute_data_loader = ComputeDataLoader(self.compute_data_provider)

	self.users = Users(repos.users_repo, BcryptPasswordHasher(), IEmailSender())
	self.user_roles = UserRoles(repos.users_repo)
	self.leaderboards = Leaderboards(repos.leaderboards_repo)
	self.teams = Teams(repos.teams_repo)
	self.difftables = Difftables(repos.difftables_repo)
	self.chartplays = Chartplays(
		repos.charts_repo,
		repos.chartfiles_repo,
		self.compute_data_loader,
		self.charts_storage,
		self.replays_storage
	)

	self.charts_computer = ChartsComputer(self.compute_data_loader, repos.charts_repo)
	self.compute_tasks = ComputeTasks(repos.compute_tasks_repo)
end

---@param user sea.User
---@param time integer
---@param compute_data_loader sea.ComputeDataLoader
---@param chartplay_values sea.Chartplay
---@param chartdiff_values sea.Chartdiff
---@return sea.Chartplay?
---@return string?
function Domain:submitChartplay(user, time, compute_data_loader, chartplay_values, chartdiff_values)
	local chartplay, err = self.chartplays:submit(user, time, compute_data_loader, chartplay_values, chartdiff_values)
	if not chartplay then
		return nil, err
	end

	if not chartplay.custom then
		self.leaderboards:addChartplay(chartplay)
	end

	self.users:updateSubmit(user, time, chartplay_values, chartdiff_values)

	return chartplay
end

return Domain
