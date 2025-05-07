local Enum = require("rdb.Enum")

---@enum (key) sea.old.Storages
local Storages = {
	undefined = 0,
	notecharts = 1,
	replays = 2,
}

return Enum(Storages)
