local class = require("class")

local IndexResource = require("sea.shared.http.IndexResource")
local StyleResource = require("sea.shared.http.StyleResource")
local DownloadResource = require("sea.shared.http.DownloadResource")
local PolicyResource = require("sea.shared.http.PolicyResource")
local WikiResource = require("sea.shared.http.WikiResource")
local DonateResource = require("sea.shared.http.DonateResource")

local AuthResource = require("sea.access.http.AuthResource")

local UsersResource = require("sea.access.http.UsersResource")
local UserResource = require("sea.access.http.UserResource")

local RankingsResource = require("sea.leaderboards.http.RankingsResource")

local LeaderboardsResource = require("sea.leaderboards.http.LeaderboardsResource")
local LeaderboardResource = require("sea.leaderboards.http.LeaderboardResource")

local TeamsResource = require("sea.teams.http.TeamsResource")
local TeamResource = require("sea.teams.http.TeamResource")
local TeamEditResource = require("sea.teams.http.TeamEditResource")

local DifftablesResource = require("sea.difftables.http.DifftablesResource")
local DifftableResource = require("sea.difftables.http.DifftableResource")

local ChartResource = require("sea.chart.http.ChartResource")
local ChartsResource = require("sea.chart.http.ChartsResource")
local ChartmetaResource = require("sea.chart.http.ChartmetaResource")
local ChartdiffResource = require("sea.chart.http.ChartdiffResource")
local ChartplayResource = require("sea.chart.http.ChartplayResource")

local WebsocketResource = require("sea.shared.http.WebsocketResource")

---@class sea.Resources
---@operator call: sea.Resources
local Resources = class()

---@param domain sea.Domain
---@param server_remote sea.ServerRemote
---@param views web.Views
---@param sessions web.Sessions
---@param app_config sea.AppConfig
function Resources:new(domain, server_remote, views, sessions, app_config)
	self.index = IndexResource(views)
	self.style = StyleResource()
	self.download = DownloadResource(views)
	self.policy = PolicyResource(views, app_config.responsible_person)
	self.wiki = WikiResource(views)
	self.donate = DonateResource(views)

	self.auth = AuthResource(sessions, domain.users, views)

	self.users = UsersResource(domain.users, views)
	self.user = UserResource(domain.users, domain.user_roles, domain.user_badges, domain.leaderboards, domain.dans, domain.user_activity_graph, views)

	self.rankings = RankingsResource(domain.users, domain.leaderboards, views)

	self.leaderboards = LeaderboardsResource(domain.leaderboards, views)
	self.leaderboard = LeaderboardResource(domain.leaderboards, domain.difftables, views)

	self.teams = TeamsResource(domain.teams, views)
	self.team = TeamResource(domain.teams, views)
	self.team_edit = TeamEditResource(domain.teams, domain.users, views)

	self.difftables = DifftablesResource(domain.difftables, views)
	self.difftable = DifftableResource(domain.difftables, views)

	self.chart = ChartResource(views)
	self.charts = ChartsResource(nil, views)
	self.chartmeta = ChartmetaResource(nil, views)
	self.chartdiff = ChartdiffResource(nil, views)
	self.chartplay = ChartplayResource(nil, views)

	self.websocket = WebsocketResource(server_remote, views)
end

function Resources:getList()
	return {
		self.index,
		self.style,
		self.download,
		self.policy,
		self.wiki,
		self.donate,

		self.auth,

		self.users,
		self.user,

		self.rankings,

		self.leaderboards,
		self.leaderboard,

		self.teams,
		self.team,
		self.team_edit,

		self.difftables,
		self.difftable,

		self.chart,
		self.charts,
		self.chartmeta,
		self.chartdiff,
		self.chartplay,

		self.websocket,
	}
end

return Resources
