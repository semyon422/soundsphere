
---@type icc.RemoteHandlerWhitelist
local whitelist = {
	mp_user = {
		setChartplayComputed = true,
		switchReady = true,
		setChartFound = true,
		setPlaying = true,
		setReplayBase = true,
		setChartview = true,
		sendMessage = true,
	},
	mp_room = {
		updateRoom = true,
		kickUser = true,
		startMatch = true,
		stopMatch = true,
	},
	getRooms = true,
	getUsers = true,
	getUser = true,
	getRoomId = true,
	login = true,
	loginOffline = true,
	createRoom = true,
	joinRoom = true,
	leaveRoom = true,
	getCurrentRoom = true,
}

return whitelist
