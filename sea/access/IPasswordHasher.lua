local class = require("class")

---@class sea.IPasswordHasher
---@operator call: sea.IPasswordHasher
local IPasswordHasher = class()

---@param password string
---@return string
function IPasswordHasher:digest(password)
	return password
end

---@param password string
---@param password_hash string
---@return boolean
function IPasswordHasher:verify(password, password_hash)
	return password == password_hash
end

return IPasswordHasher
