local class = require("class")
local sql_util = require("rdb.sql_util")
local random = require("web.random")

---@class sea.AuthCode
---@operator call: sea.AuthCode
---@field id integer
---@field user_id integer?
---@field type sea.AuthCodeType
---@field created_at integer
---@field expires_at integer
---@field used boolean
---@field ip string
---@field code string
local AuthCode = class()

function AuthCode:new()
	self.used = false
	self.code = sql_util.tohex(random.bytes(8))
end

return AuthCode
