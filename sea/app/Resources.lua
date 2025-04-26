local class = require("class")

local IndexResource = require("sea.shared.http.IndexResource")
local StyleResource = require("sea.shared.http.StyleResource")
local DownloadResource = require("sea.shared.http.DownloadResource")
local PolicyResource = require("sea.shared.http.PolicyResource")
local WikiResource = require("sea.shared.http.WikiResource")

local AuthResource = require("sea.access.http.AuthResource")

local UsersResource = require("sea.access.http.UsersResource")
local UserResource = require("sea.access.http.UserResource")

local RankingsResource = require("sea.leaderboards.http.RankingsResource")

local LeaderboardsResource = require("sea.leaderboards.http.LeaderboardsResource")
local LeaderboardResource = require("sea.leaderboards.http.LeaderboardResource")

local TeamsResource = require("sea.teams.http.TeamsResource")
local TeamResource = require("sea.teams.http.TeamResource")

local DifftablesResource = require("sea.difftables.http.DifftablesResource")
local DifftableResource = require("sea.difftables.http.DifftableResource")

local ChartsResource = require("sea.chart.http.ChartsResource")
local ChartmetaResource = require("sea.chart.http.ChartmetaResource")
local ChartdiffResource = require("sea.chart.http.ChartdiffResource")
local ChartplayResource = require("sea.chart.http.ChartplayResource")

local WebsocketResource = require("sea.shared.http.WebsocketResource")

local ServerRemote = require("sea.app.remotes.ServerRemote")

---@class sea.Resources
---@operator call: sea.Resources
local Resources = class()

---@param domain sea.Domain
---@param views web.Views
---@param sessions web.Sessions
function Resources:new(domain, views, sessions)
	local server_remote_handler = ServerRemote(domain)

	self.index = IndexResource(views)
	self.style = StyleResource()
	self.download = DownloadResource(views)
	self.policy = PolicyResource(views)
	self.wiki = WikiResource(views)

	self.auth = AuthResource(sessions, domain.users, views)

	self.users = UsersResource(domain.users, views)
	self.user = UserResource(domain.users, views)

	self.rankings = RankingsResource(views)

	self.leaderboards = LeaderboardsResource(domain.leaderboards, views)
	self.leaderboard = LeaderboardResource(domain.leaderboards, domain.difftables, views)

	self.teams = TeamsResource(domain.teams, views)
	self.team = TeamResource(domain.teams, views)

	self.difftables = DifftablesResource(domain.difftables, views)
	self.difftable = DifftableResource(domain.difftables, views)

	self.charts = ChartsResource(nil, views)
	self.chartmeta = ChartmetaResource(nil, views)
	self.chartdiff = ChartdiffResource(nil, views)
	self.chartplay = ChartplayResource(nil, views)

	self.websocket = WebsocketResource(server_remote_handler, views)
end

function Resources:getList()
	return {
		self.index,
		self.style,
		self.download,
		self.policy,
		self.wiki,

		self.auth,

		self.users,
		self.user,

		self.rankings,

		self.leaderboards,
		self.leaderboard,

		self.teams,
		self.team,

		self.difftables,
		self.difftable,

		self.charts,
		self.chartmeta,
		self.chartdiff,
		self.chartplay,

		self.websocket,
	}
end

return Resources
