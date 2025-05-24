local AuthCodeType = require("sea.access.AuthCodeType")
local AuthCode = require("sea.access.AuthCode")

---@type rdb.ModelOptions
local auth_codes = {}

auth_codes.metatable = AuthCode

auth_codes.types = {
	type = AuthCodeType,
	used = "boolean",
}

return auth_codes
