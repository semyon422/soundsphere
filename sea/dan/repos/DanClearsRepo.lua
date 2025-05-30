local class = require("class")

---@class sea.DanClearsRepo
---@operator call: sea.DanClearsRepo
local DanClearsRepo = class()

---@param models rdb.Models
function DanClearsRepo:new(models)
	self.models = models
end

---@param user_id number
---@param dan_id number
---@return sea.DanClear?
function DanClearsRepo:getUserDanClear(user_id, dan_id)
	return self.models.dan_clears:find({ user_id = assert(user_id), dan_id = assert(dan_id)})
end

---@param dan_clear sea.DanClear
---@return sea.DanClear
function DanClearsRepo:createDanClear(dan_clear)
	return self.models.dan_clears:create(dan_clear)
end

return DanClearsRepo
