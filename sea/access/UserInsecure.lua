local User = require("sea.access.User")

---@class sea.UserInsecure: sea.User
---@operator call: sea.UserInsecure
---@field email string
---@field password string
local UserInsecure = User + {}

---@return sea.User
function UserInsecure:hideCredentials()
	self.email = nil
	self.password = nil
	return setmetatable(self, User)
end

---@return true?
---@return string[]?
function UserInsecure:validateLogin()
	local errs = {}

	local email = self.email
	if type(email) ~= "string" or not email:find("@") then
		table.insert(errs, "invalid email")
	end

	local password = self.password
	if type(password) ~= "string" or #password == 0 then
		table.insert(errs, "invalid password")
	end

	if #errs > 0 then
		return nil, errs
	end

	return true
end

---@return true?
---@return string[]?
function UserInsecure:validateRegister()
	local _, errs = self:validateLogin()

	errs = errs or {}

	local name = self.name
	if type(name) ~= "string" or #name == 0 then
		table.insert(errs, "invalid name")
	end

	if #errs > 0 then
		return nil, errs
	end

	return true
end

return UserInsecure
