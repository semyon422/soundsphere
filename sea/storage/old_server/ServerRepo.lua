local class = require("class")

---@class sea.old.ServerRepo
---@operator call: sea.old.ServerRepo
local ServerRepo = class()

---@param models rdb.Models
function ServerRepo:new(models)
	self.models = models
end

---@return sea.old.File[]
function ServerRepo:getFiles()
	return self.models.files:select()
end

---@return sea.old.File[]
function ServerRepo:getChartFiles()
	return self.models.files:select({format__ne = "undefined"})
end

---@return sea.old.Notechart[]
function ServerRepo:getNotecharts()
	return self.models.notecharts:select()
end

---@return sea.old.Score[]
function ServerRepo:getScores()
	return self.models.scores:select()
end

---@return sea.old.Session[]
function ServerRepo:getSessions()
	return self.models.sessions:select()
end

---@return sea.old.UserLocation[]
function ServerRepo:getUserLocations()
	return self.models.user_locations:select()
end

---@return sea.old.UserRole[]
function ServerRepo:getUserRoles()
	return self.models.user_roles:select()
end

---@return sea.old.User[]
function ServerRepo:getUsers()
	return self.models.users:select()
end

return ServerRepo
