local class = require("class")
local Users = require("sea.access.Users")
local IPasswordHasher = require("sea.access.IPasswordHasher")

---@class sea.Domain
---@operator call: sea.Domain
local Domain = class()

---@param repos sea.Repos
function Domain:new(repos)
	self.users = Users(repos.users_repo, IPasswordHasher())
end

return Domain
