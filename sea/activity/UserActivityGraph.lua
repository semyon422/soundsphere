local class = require("class")
local 

---@class sea.UserActivityGraph
---@operator call: sea.UserActivityGraph
local UserActivityGraph = class()

---@param activity_repo sea.ActivityRepo
function UserActivityGraph:new(activity_repo)
	self.activity_repo = activity_repo
end

return UserActivityGraph
