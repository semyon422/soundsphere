local class = require("class")

---@class sea.ITeamsRepo
---@operator call: sea.ITeamsRepo
local ITeamsRepo = class()

---@return sea.Team[]
function ITeamsRepo:getTeams()
	return {}
end

---@param id integer
---@return sea.Team?
function ITeamsRepo:getTeam(id)
	return {}
end

---@param team sea.Team
---@return sea.Team
function ITeamsRepo:createTeam(team)
	return team
end

---@param team sea.Team
---@return sea.Team
function ITeamsRepo:updateTeam(team)
	return team
end

---@param id integer
---@return sea.Team?
function ITeamsRepo:deleteTeam(id)
end

--------------------------------------------------------------------------------

---@param team_id integer
---@return sea.TeamUser[]
function ITeamsRepo:getTeamUsers(team_id)
	return {}
end

---@param team_id integer
---@return sea.TeamUser[]
function ITeamsRepo:getRequestTeamUsers(team_id)
	return {}
end

---@param team_id integer
---@return sea.TeamUser[]
function ITeamsRepo:getTeamUsersFull(team_id)
	return {}
end

---@param team_id integer
---@return sea.TeamUser[]
function ITeamsRepo:getInviteTeamUsers(team_id)
	return {}
end

---@param user_id integer
---@return sea.TeamUser[]
function ITeamsRepo:getUserAcceptedTeamUsers(user_id)
	return {}
end

---@param user_id integer
---@return sea.TeamUser[]
function ITeamsRepo:getUserUnacceptedTeamUsers(user_id)
	return {}
end

---@param team_id integer
---@param user_id integer
---@return sea.TeamUser?
function ITeamsRepo:getTeamUser(team_id, user_id)
	return {}
end

---@param team_user sea.TeamUser
---@return sea.TeamUser
function ITeamsRepo:createTeamUser(team_user)
	return {}
end

---@param team_user sea.TeamUser
---@return sea.TeamUser
function ITeamsRepo:updateTeamUser(team_user)
	return team_user
end

---@param team_user sea.TeamUser
---@return sea.TeamUser
function ITeamsRepo:deleteTeamUser(team_user)
	return team_user
end

return ITeamsRepo
