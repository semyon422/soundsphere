local class = require("class")

---@class sea.AuthState
---@operator call: sea.AuthState
---@field id integer
---@field server_id integer
---@field user sea.User
---@field session sea.Session
---@field token string
local AuthState = class()

return AuthState
