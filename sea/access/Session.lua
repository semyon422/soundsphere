local class = require("class")

---@class sea.Session
---@operator call: sea.Session
---@field id integer
---@field user_id integer
---@field active boolean
---@field created_at integer
---@field updated_at integer
local Session = class()

---@return boolean
function Session:isAnon()
	return not self.id
end

return Session
