local class = require("class")

---@class sea.TeamsRepo
---@operator call: sea.TeamsRepo
local TeamsRepo = class()

---@param models rdb.Models
function TeamsRepo:new(models)
	self.models = models
end

---@return sea.Team[]
function TeamsRepo:getTeams()
	return self.models.teams:select()
end

---@param id integer
---@return sea.Team?
function TeamsRepo:getTeam(id)
	return self.models.teams:find({id = assert(id)})
end

---@param name string
---@return sea.Team?
function TeamsRepo:findByName(name)
	return self.models.teams:find({name = assert(name)})
end

---@param alias string
---@return sea.Team?
function TeamsRepo:findByAlias(alias)
	return self.models.teams:find({alias = assert(alias)})
end

---@param team sea.Team
---@return sea.Team
function TeamsRepo:createTeam(team)
	return self.models.teams:create(team)
end

---@param team sea.Team
---@return sea.Team
function TeamsRepo:updateTeam(team)
	return self.models.teams:update(team, {id = assert(team.id)})[1]
end

---@param id integer
---@return sea.Team?
function TeamsRepo:deleteTeam(id)
	return self.models.teams:delete({id = assert(id)})
end

--------------------------------------------------------------------------------

---@param team_users sea.TeamUser[]
---@return sea.TeamUser[]
function TeamsRepo:preloadUsers(team_users)
	self.models.team_users:preload(team_users, "user")
	return team_users
end

---@param team_id integer
---@return sea.TeamUser[]
function TeamsRepo:getTeamUsers(team_id)
	return self.models.team_users:select({
		team_id = assert(team_id),
		is_accepted = true,
	})
end

---@param team_id integer
---@return sea.TeamUser[]
function TeamsRepo:getRequestTeamUsers(team_id)
	return self.models.team_users:select({
		team_id = assert(team_id),
		is_accepted = false,
		is_invitation = false,
	})
end

---@param team_id integer
---@return sea.TeamUser[]
function TeamsRepo:getInviteTeamUsers(team_id)
	return self.models.team_users:select({
		team_id = assert(team_id),
		is_accepted = false,
		is_invitation = true,
	})
end

---@param user_id integer
---@return sea.TeamUser[]
function TeamsRepo:getUserAcceptedTeamUsers(user_id)
	return self.models.team_users:select({
		user_id = assert(user_id),
		is_accepted = true,
	})
end

---@param user_id integer
---@return sea.TeamUser[]
function TeamsRepo:getUserUnacceptedTeamUsers(user_id)
	return self.models.team_users:select({
		user_id = assert(user_id),
		is_accepted = false,
	})
end

---@param team_id integer
---@param user_id integer
---@return sea.TeamUser?
function TeamsRepo:getTeamUser(team_id, user_id)
	return self.models.team_users:find({
		team_id = assert(team_id),
		user_id = assert(user_id),
	})
end

---@param user_id integer
---@return sea.TeamUser[]
function TeamsRepo:getTeamUsersByUserId(user_id)
	return self.models.team_users:select({
		user_id = assert(user_id),
		is_accepted = true,
	})
end

---@param team_user sea.TeamUser
---@return sea.TeamUser
function TeamsRepo:createTeamUser(team_user)
	return self.models.team_users:create(team_user)
end

---@param team_user sea.TeamUser
---@return sea.TeamUser
function TeamsRepo:updateTeamUser(team_user)
	return self.models.team_users:update(team_user, {id = assert(team_user.id)})
end

---@param team_user sea.TeamUser
---@return sea.TeamUser
function TeamsRepo:deleteTeamUser(team_user)
	return self.models.team_users:delete({id = assert(team_user.id)})
end

return TeamsRepo
