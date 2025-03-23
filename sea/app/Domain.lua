local class = require("class")
local Users = require("sea.access.Users")
local Leaderboards = require("sea.leaderboards.Leaderboards")
local Teams = require("sea.teams.Teams")
local Difftables = require("sea.difftables.Difftables")
local IPasswordHasher = require("sea.access.IPasswordHasher")

---@class sea.Domain
---@operator call: sea.Domain
local Domain = class()

---@param repos sea.Repos
function Domain:new(repos)
	self.users = Users(repos.users_repo, IPasswordHasher())
	self.leaderboards = Leaderboards(repos.leaderboards_repo)
	self.teams = Teams(repos.teams_repo)
	self.difftables = Difftables(repos.difftables_repo)
end

return Domain
