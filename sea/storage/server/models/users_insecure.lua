local UserInsecure = require("sea.access.UserInsecure")

---@type rdb.ModelOptions
local users_insecure = {}

users_insecure.table_name = "users"

users_insecure.metatable = UserInsecure

return users_insecure
