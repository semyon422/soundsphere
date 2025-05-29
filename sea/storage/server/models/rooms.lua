local Room = require("sea.multi.Room")
local RoomRules = require("sea.multi.RoomRules")
local ChartmetaKey = require("sea.chart.ChartmetaKey")
local ReplayBase = require("sea.replays.ReplayBase")
local stbl = require("stbl")

---@type rdb.ModelOptions
local rooms = {}

rooms.metatable = Room

rooms.types = {
	rules = stbl,
	chartmeta_key = stbl,
	replay_base = stbl,
}

---@param room sea.Room
function rooms.from_db(room)
	setmetatable(room.rules, RoomRules)
	setmetatable(room.chartmeta_key, ChartmetaKey)
	setmetatable(room.replay_base, ReplayBase)
end

return rooms
