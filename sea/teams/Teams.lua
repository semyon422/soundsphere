local class = require("class")
local TeamsAccess = require("sea.teams.access.TeamsAccess")
local Team = require("sea.teams.Team")
local TeamUser = require("sea.teams.TeamUser")

---@class sea.Teams
---@operator call: sea.Teams
local Teams = class()

---@param teams_repo sea.ITeamsRepo
function Teams:new(teams_repo)
	self.teams_repo = teams_repo
	self.teams_access = TeamsAccess()
end

---@param user sea.User
---@param name string
---@param alias string
---@return sea.Team?
---@return string?
function Teams:create(user, name, alias)
	local can, err = self.teams_access:canCreate(user)
	if not can then
		return nil, err
	end

	local team = Team()
	team.name = name
	team.alias = alias
	team.description = ""
	team.users_count = 0
	team.owner_id = user.id
	team.type = "invite"
	team.created_at = os.time()

	team = self.teams_repo:createTeam(team)

	local team_user = TeamUser()
	team_user.is_accepted = true
	team_user.is_invitation = false
	team_user.team_id = team.id
	team_user.user_id = user.id
	team_user.created_at = os.time()

	team_user = self.teams_repo:createTeamUser(team_user)

	return team
end

---@param user sea.User
---@param team_values sea.Team
---@return sea.Team?
---@return string?
function Teams:update(user, team_values)
	local team = self.teams_repo:getTeam(team_values.id)
	if not team then
		return nil, "not found"
	end

	local can, err = self.teams_access:canUpdate(user, team)
	if not can then
		return nil, err
	end

	team.name = team_values.name
	team.alias = team_values.alias
	team.description = team_values.description
	team.type = team_values.type
	team.owner_id = team_values.owner_id

	return self.teams_repo:updateTeam(team)
end

---@param user sea.User
---@param team sea.Team
---@return sea.TeamUser?
---@return string?
function Teams:join(user, team)
	local can, err = self.teams_access:canJoin(user, team)
	if not can then
		return nil, err
	end

	local team_user = self.teams_repo:getTeamUser(team.id, user.id)
	if team_user then
		if team_user.is_accepted then
			return nil, "already joined"
		end
		team_user.is_accepted = true
		team_user = self.teams_repo:updateTeamUser(team_user)
		return team_user
	end

	team_user = TeamUser()
	team_user.is_accepted = team.type == "open"
	team_user.is_invitation = false
	team_user.team_id = team.id
	team_user.user_id = user.id
	team_user.created_at = os.time()

	team_user = self.teams_repo:createTeamUser(team_user)

	return team_user
end

---@param user sea.User
---@param team sea.Team
---@param user_id integer
---@return sea.TeamUser[]?
---@return string?
function Teams:acceptJoinRequest(user, team, user_id)
	local can, err = self.teams_access:canUpdate(user, team)
	if not can then
		return nil, err
	end

	local team_user = self.teams_repo:getTeamUser(team.id, user_id)
	if not team_user then
		return nil, "missing request"
	end

	team_user.is_accepted = true
	team_user = self.teams_repo:updateTeamUser(team_user)

	return team_user
end

---@param user sea.User
---@param team sea.Team
---@param user_id integer
---@return sea.TeamUser[]?
---@return string?
function Teams:inviteUser(user, team, user_id)
	local can, err = self.teams_access:canUpdate(user, team)
	if not can then
		return nil, err
	end

	local team_user = self.teams_repo:getTeamUser(team.id, user_id)
	if team_user then
		if team_user.is_accepted then
			return nil, "already joined"
		end
		return nil, "already invited"
	end

	team_user = TeamUser()
	team_user.is_accepted = false
	team_user.is_invitation = true
	team_user.team_id = team.id
	team_user.user_id = user_id
	team_user.created_at = os.time()

	team_user = self.teams_repo:createTeamUser(team_user)

	return team_user
end

---@param user sea.User
---@param team sea.Team
---@return sea.TeamUser[]?
---@return string?
function Teams:acceptJoinInvite(user, team)
	local team_user = self.teams_repo:getTeamUser(team.id, user.id)
	if not team_user then
		return nil, "missing invite"
	end

	if team_user.is_accepted then
		return nil, "already accepted"
	end

	team_user.is_accepted = true
	team_user = self.teams_repo:updateTeamUser(team_user)

	return team_user
end

---@param user sea.User
---@param team sea.Team
---@param user_id integer
---@return sea.TeamUser?
---@return string?
function Teams:revokeJoinInvite(user, team, user_id)
	local can, err = self.teams_access:canUpdate(user, team)
	if not can then
		return nil, err
	end

	local team_user = self.teams_repo:getTeamUser(team.id, user_id)
	if not team_user then
		return nil, "missing invite"
	end

	if team_user.is_accepted then
		return nil, "already accepted"
	end

	if not team_user.is_invitation then
		return nil, "is not invitation"
	end

	team_user = self.teams_repo:deleteTeamUser(team_user)

	return team_user
end

---@param user sea.User
---@param team sea.Team
---@return sea.TeamUser?
---@return string?
function Teams:revokeJoinRequest(user, team)
	local team_user = self.teams_repo:getTeamUser(team.id, user.id)
	if not team_user then
		return nil, "missing request"
	end

	if team_user.is_accepted then
		return nil, "already accepted"
	end

	if team_user.is_invitation then
		return nil, "is not request"
	end

	team_user = self.teams_repo:deleteTeamUser(team_user)

	return team_user
end

---@param team_id integer
---@return sea.TeamUser[]
function Teams:getTeamUsers(team_id)
	return self.teams_repo:getTeamUsers(team_id)
end

---@param user sea.User
---@param team sea.Team
---@return sea.TeamUser[]?
---@return string?
function Teams:getRequestTeamUsers(user, team)
	local can, err = self.teams_access:canUpdate(user, team)
	if not can then
		return nil, err
	end
	return self.teams_repo:getRequestTeamUsers(team.id)
end

---@param user sea.User
---@param team sea.Team
---@return sea.TeamUser[]?
---@return string?
function Teams:getInviteTeamUsers(user, team)
	local can, err = self.teams_access:canUpdate(user, team)
	if not can then
		return nil, err
	end
	return self.teams_repo:getInviteTeamUsers(team.id)
end

---@param user_id integer
---@return sea.TeamUser[]?
---@return string?
function Teams:getUserAcceptedTeamUsers(user_id)
	return self.teams_repo:getUserAcceptedTeamUsers(user_id)
end

---@param user sea.User
---@return sea.TeamUser[]?
---@return string?
function Teams:getUserUnacceptedTeamUsers(user)
	return self.teams_repo:getUserUnacceptedTeamUsers(user.id)
end

return Teams
