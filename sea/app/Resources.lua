local class = require("class")

local IndexResource = require("sea.shared.http.IndexResource")
local StyleResource = require("sea.shared.http.StyleResource")

local LoginResource = require("sea.access.http.LoginResource")
local RegisterResource = require("sea.access.http.RegisterResource")

local UsersResource = require("sea.access.http.UsersResource")
local UserResource = require("sea.access.http.UserResource")
local UserSessionsResource = require("sea.access.http.UserSessionsResource")
local UsersSettingsResource = require("sea.access.http.UsersSettingsResource")
local UserTeamsResource = require("sea.access.http.UserTeamsResource")

local LeaderboardsResource = require("sea.leaderboards.http.LeaderboardsResource")
local LeaderboardsCreateResource = require("sea.leaderboards.http.LeaderboardsCreateResource")
local LeaderboardResource = require("sea.leaderboards.http.LeaderboardResource")
local LeaderboardEditResource = require("sea.leaderboards.http.LeaderboardEditResource")

local TeamsResource = require("sea.teams.http.TeamsResource")
local TeamsCreateResource = require("sea.teams.http.TeamsCreateResource")
local TeamResource = require("sea.teams.http.TeamResource")
local TeamEditResource = require("sea.teams.http.TeamEditResource")

local DifftablesResource = require("sea.difftables.http.DifftablesResource")
local DifftablesCreateResource = require("sea.difftables.http.DifftablesCreateResource")
local DifftableResource = require("sea.difftables.http.DifftableResource")
local DifftableEditResource = require("sea.difftables.http.DifftableEditResource")

local ChartsResource = require("sea.chart.http.ChartsResource")
local ChartmetaResource = require("sea.chart.http.ChartmetaResource")
local ChartdiffResource = require("sea.chart.http.ChartdiffResource")
local ChartplayResource = require("sea.chart.http.ChartplayResource")

local WebsocketClientResource = require("sea.shared.http.WebsocketClientResource")
local WebsocketServerResource = require("sea.shared.http.WebsocketServerResource")

---@class sea.Resources
---@operator call: sea.Resources
local Resources = class()

---@param domain sea.Domain
---@param views web.Views
---@param sessions web.Sessions
function Resources:new(domain, views, sessions)
	self.index = IndexResource(views)
	self.style = StyleResource()

	self.login = LoginResource(sessions, domain.users, views)
	self.register = RegisterResource(sessions, domain.users, views)

	self.users = UsersResource(domain.users, views)
	self.user = UserResource(domain.users, views)
	self.user_sessions = UserSessionsResource(domain.users, views)
	self.user_settings = UsersSettingsResource(domain.users, views)
	self.user_teams = UserTeamsResource(domain.users, views)

	self.leaderboards = LeaderboardsResource(domain.leaderboards, views)
	self.leaderboards_create = LeaderboardsCreateResource(domain.leaderboards, views)
	self.leaderboard = LeaderboardResource(domain.leaderboards, views)
	self.leaderboard_edit = LeaderboardEditResource(domain.leaderboards, views)

	self.teams = TeamsResource(domain.teams, views)
	self.teams_create = TeamsCreateResource(domain.teams, views)
	self.team = TeamResource(domain.teams, views)
	self.team_edit = TeamEditResource(domain.teams, views)

	self.difftables = DifftablesResource(domain.difftables, views)
	self.difftables_create = DifftablesCreateResource(domain.difftables, views)
	self.difftable = DifftableResource(domain.difftables, views)
	self.difftable_edit = DifftableEditResource(domain.difftables, views)

	self.charts = ChartsResource(nil, views)
	self.chartmeta = ChartmetaResource(nil, views)
	self.chartdiff = ChartdiffResource(nil, views)
	self.chartplay = ChartplayResource(nil, views)

	self.ws_client = WebsocketClientResource(views)
	self.ws_server = WebsocketServerResource()
end

function Resources:getList()
	return {
		self.index,
		self.style,

		self.login,
		self.register,

		self.users,
		self.user,
		self.user_sessions,
		self.user_settings,
		self.user_teams,

		self.leaderboards,
		self.leaderboards_create,
		self.leaderboard,
		self.leaderboard_edit,

		self.teams,
		self.teams_create,
		self.team,
		self.team_edit,

		self.difftables,
		self.difftables_create,
		self.difftable,
		self.difftable_edit,

		self.charts,
		self.chartmeta,
		self.chartdiff,
		self.chartplay,

		self.ws_client,
		self.ws_server,
	}
end

return Resources
