local class = require("class")
local table_util = require("table_util")
local sql_util = require("rdb.sql_util")
local UserRole = require("sea.access.UserRole")

---@class sea.ActivityRepo
---@operator call: sea.ActivityRepo
local ActivityRepo = class()

---@param models rdb.Models
function ActivityRepo:new(models)
	self.models = models
end

return ActivityRepo
