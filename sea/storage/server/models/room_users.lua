local RoomUser = require("sea.multi.RoomUser")

---@type rdb.ModelOptions
local room_users = {}

room_users.metatable = RoomUser

return room_users
