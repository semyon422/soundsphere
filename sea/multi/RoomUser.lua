local class = require("class")
local ChartplayComputed = require("sea.chart.ChartplayComputed")
local ChartmetaKey = require("sea.chart.ChartmetaKey")
local ReplayBase = require("sea.replays.ReplayBase")

---@class sea.RoomUser
---@operator call: sea.RoomUser
---@field id integer
---@field room_id integer
---@field user_id integer
---@field chart_found boolean
---@field is_ready boolean
---@field is_playing boolean
---@field chartmeta_key sea.ChartmetaKey
---@field replay_base sea.ReplayBase
---@field chartplay_computed sea.ChartplayComputed
---@field user sea.User?
local RoomUser = class()

---@param room_id integer
---@param user_id integer
function RoomUser:new(room_id, user_id)
	self.room_id = assert(room_id)
	self.user_id = assert(user_id)
	self.chart_found = false
	self.is_ready = false
	self.is_playing = false
	self.chartmeta_key = ChartmetaKey()
	self.replay_base = ReplayBase()
	self.chartplay_computed = ChartplayComputed()
end

return RoomUser
