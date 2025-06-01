
---@type icc.RemoteHandlerWhitelist
local whitelist = {
	auth = {
		checkSession = true,
		updateSession = true,
		loginSession = true,
		login = true,
		logout = true,
	},
	submission = {
		submitChartplay = true,
		getBestChartplaysForChartmeta = true,
		getBestChartplaysForChartdiff = true,
		getReplayFile = true,
	},
	leaderboards = {
		getLeaderboards = true,
		getUserLeaderboardUsers = true,
	},
	getUser = true,
	getSession = true,
}

return whitelist
