local class = require("class")

---@class sea.UserRole
---@operator call: sea.UserRole
---@field id integer
---@field user_id integer
---@field role sea.Role
---@field expires_at integer
---@field total_time integer
local UserRole = class()

-- TODO: inject clock here instead of direct usage of os.time

function UserRole:new()
	self.expires_at = os.time()
	self.total_time = 0
end

---@return boolean
function UserRole:isExpired()
	return self.expires_at < os.time()
end

---@param duration integer
function UserRole:addTime(duration)
	duration = math.max(duration, os.time() - self.expires_at)
	self.expires_at = self.expires_at + duration
	self.total_time = self.total_time + duration
end

function UserRole:expire()
	self:addTime(os.time() - self.expires_at)
end

return UserRole
