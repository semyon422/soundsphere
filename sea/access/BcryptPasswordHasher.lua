local IPasswordHasher = require("sea.access.IPasswordHasher")
local bcrypt = require("bcrypt")

---@class sea.BcryptPasswordHasher: sea.IPasswordHasher
---@operator call: sea.BcryptPasswordHasher
local BcryptPasswordHasher = IPasswordHasher + {}

---@param password string
---@return string
function BcryptPasswordHasher:digest(password)
	return bcrypt.digest(password, 10)
end

---@param password string
---@param password_hash string
---@return boolean
function BcryptPasswordHasher:verify(password, password_hash)
	return bcrypt.verify(password, password_hash)
end

return BcryptPasswordHasher
