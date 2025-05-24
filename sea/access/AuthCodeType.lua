local Enum = require("rdb.Enum")

---@enum (key) sea.AuthCodeType
local AuthCodeType = {
	login_bypass = 0,
	register_bypass = 1,
	login_link = 2,
	password_reset = 3,
}

return Enum(AuthCodeType)
