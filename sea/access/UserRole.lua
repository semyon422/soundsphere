local class = require("class")

---@class sea.UserRole
---@operator call: sea.UserRole
---@field id integer
---@field user_id integer
---@field role sea.Role
---@field expires_at integer
---@field total_time integer
local UserRole = class()

---@param role sea.Role
---@param time integer
function UserRole:new(role, time)
	self.role = role
	self.expires_at = time
	self.total_time = 0
end

---@param time integer
---@return boolean
function UserRole:isExpired(time)
	return self.expires_at < time
end

---@param time integer
---@param duration integer
function UserRole:addTime(duration, time)
	duration = math.max(duration, time - self.expires_at)
	self.expires_at = self.expires_at + duration
	self.total_time = self.total_time + duration
end

---@param time integer
function UserRole:expire(time)
	self:addTime(time - self.expires_at, time)
end

return UserRole
