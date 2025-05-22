local class = require("class")
local valid = require("valid")
local types = require("sea.shared.types")
local Roles = require("sea.access.Roles")

---@class sea.UserRole
---@operator call: sea.UserRole
---@field id integer
---@field user_id integer
---@field role sea.Role
---@field started_at integer private
---@field expires_at integer?
---@field total_time integer private
local UserRole = class()

UserRole.struct = {
	user_id = types.integer,
	role = types.new_enum(Roles.enum),
	started_at = types.integer,
	expires_at = valid.optional(types.integer),
	total_time = types.integer,
}

local validate_user_role = valid.struct(UserRole.struct)

---@return true?
---@return string?
function UserRole:validate()
	return valid.format(validate_user_role(self))
end

---@param role sea.Role
---@param time integer
function UserRole:new(role, time)
	self.role = assert(role)
	self.started_at = assert(time)
	self.total_time = 0
end

---@param time integer
---@return boolean
function UserRole:isExpired(time)
	return self.expires_at and self.expires_at < time or false
end

---@return boolean
function UserRole:isExpirable()
	return not not self.expires_at
end

---@param time integer
function UserRole:makeUnexpirable(time)
	self:addTime(0, time)
	self.expires_at = nil
end

---@param time integer
---@param duration integer
function UserRole:addTime(duration, time)
	assert(time >= self.started_at)
	self.expires_at = self.expires_at or time
	self.total_time = self:getTotalTime(time)
	self.started_at = time
	self.expires_at = math.max(duration + math.max(self.expires_at, time), time)
end

function UserRole:getTotalTime(time)
	local sa, ea = self.started_at, self.expires_at or math.huge
	return self.total_time + math.min(math.max(time - sa, 0), ea - sa)
end

---@param time integer
function UserRole:expire(time)
	self:addTime(time - (self.expires_at or time), time)
end

return UserRole
