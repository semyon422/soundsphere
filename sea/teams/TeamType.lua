local Enum = require("rdb.Enum")

---@enum (key) sea.TeamType
local TeamType = {
	open = 0, -- anyone can join
	request = 1, -- anyone can request for join
	invite = 2, -- no join, no request, only invites
}

return Enum(TeamType)
