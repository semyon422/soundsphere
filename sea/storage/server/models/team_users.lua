local TeamUser = require("sea.teams.TeamUser")

---@type rdb.ModelOptions
local team_users = {}

team_users.metatable = TeamUser

team_users.types = {
	is_accepted = "boolean",
	is_invitation = "boolean",
}

return team_users
