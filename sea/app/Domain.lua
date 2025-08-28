local class = require("class")

local Users = require("sea.access.Users")
local UserRoles = require("sea.access.UserRoles")
local UserBadges = require("sea.access.UserBadges")
local IEmailSender = require("sea.access.IEmailSender")
local BcryptPasswordHasher = require("sea.access.BcryptPasswordHasher")

local Leaderboards = require("sea.leaderboards.Leaderboards")

local Teams = require("sea.teams.Teams")
local Dans = require("sea.dan.Dans")

local Difftables = require("sea.difftables.Difftables")

local Chartplays = require("sea.chart.Chartplays")
local ChartplaySubmission = require("sea.chart.ChartplaySubmission")
local FolderStorage = require("sea.chart.storage.FolderStorage")

local ComputeDataProvider = require("sea.compute.ComputeDataProvider")
local ComputeDataLoader = require("sea.compute.ComputeDataLoader")
local ComputeTasks = require("sea.compute.ComputeTasks")
local ChartsComputer = require("sea.compute.ChartsComputer")

local UserActivityGraph = require("sea.activity.UserActivityGraph")

local OsuApi = require("sea.osu.api.OsuApi")
local OsuBeatmaps = require("sea.osu.OsuBeatmaps")
local ExternalRanked = require("sea.difftables.ExternalRanked")

---@class sea.Domain
---@operator call: sea.Domain
local Domain = class()

---@param repos sea.Repos
---@param app_config sea.AppConfig
function Domain:new(repos, app_config)
	self.users_repo = repos.users_repo
	self.charts_repo = repos.charts_repo

	self.charts_storage = FolderStorage("storages/charts")
	self.replays_storage = FolderStorage("storages/replays")
	self.compute_data_provider = ComputeDataProvider(repos.chartfiles_repo, self.charts_storage, self.replays_storage)
	self.compute_data_loader = ComputeDataLoader(self.compute_data_provider)

	self.users = Users(repos.users_repo, BcryptPasswordHasher(), IEmailSender())
	self.user_roles = UserRoles(repos.users_repo)
	self.user_badges = UserBadges(repos.users_repo)
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
	self.dans = Dans(repos.charts_repo, repos.dan_clears_repo)
	self.user_activity_graph = UserActivityGraph(repos.activity_repo)

	self.osu_api = OsuApi(app_config.osu_api, "client_credentials")
	self.osu_beatmaps = OsuBeatmaps(self.osu_api, repos.osu_repo)
	self.external_ranked = ExternalRanked(self.osu_beatmaps, repos.difftables_repo)
	self.chartplay_submission = ChartplaySubmission(
		self.chartplays,
		self.leaderboards,
		self.users,
		self.dans,
		self.user_activity_graph,
		self.external_ranked
	)

	self.charts_computer = ChartsComputer(self.compute_data_loader, repos.charts_repo)
	self.compute_tasks = ComputeTasks(repos.compute_tasks_repo)
end

return Domain
