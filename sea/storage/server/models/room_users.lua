local RoomUser = require("sea.multi.RoomUser")
local ChartplayComputed = require("sea.chart.ChartplayComputed")
local ChartmetaKey = require("sea.chart.ChartmetaKey")
local ReplayBase = require("sea.replays.ReplayBase")
local stbl = require("stbl")

---@type rdb.ModelOptions
local room_users = {}

room_users.metatable = RoomUser

room_users.types = {
	chart_found = "boolean",
	is_ready = "boolean",
	is_playing = "boolean",
	chartmeta_key = stbl,
	replay_base = stbl,
	chartplay_computed = stbl,
}

---@param room sea.Room
function room_users.from_db(room)
	setmetatable(room.chartmeta_key, ChartmetaKey)
	setmetatable(room.replay_base, ReplayBase)
	setmetatable(room.chartplay_computed, ChartplayComputed)
end

return room_users
