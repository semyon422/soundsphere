local UserRole = require("sea.access.UserRole")

---@type rdb.ModelOptions
local user_roles = {}

user_roles.metatable = UserRole

user_roles.types = {}

return user_roles
