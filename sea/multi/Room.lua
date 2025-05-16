local class = require("class")

---@class sea.Room
---@operator call: sea.Room
---@field id integer
---@field name string
---@field password string
---@field host_user_id integer
---@field rules sea.RoomRules
---@field chartmeta_key sea.ChartmetaKey
---@field replay_base sea.ReplayBase
local Room = class()

Room.isPlaying = false

return Room
