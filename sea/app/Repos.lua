local class = require("class")
local UsersRepo = require("sea.access.repos.UsersRepo")

---@class sea.Repos
---@operator call: sea.Repos
local Repos = class()

---@param models rdb.Models
function Repos:new(models)
	self.users_repo = UsersRepo(models)
end

return Repos
