local TeamType = require("sea.teams.TeamType")
local Team = require("sea.teams.Team")

---@type rdb.ModelOptions
local teams = {}

teams.metatable = Team

teams.types = {
	type = TeamType,
}

return teams
