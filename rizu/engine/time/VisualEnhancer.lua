local class = require("class")

---@class rizu.VisualEnhancer
---@operator call: rizu.VisualEnhancer
local VisualEnhancer = class()

function VisualEnhancer:new()

end

---@param time number
---@return number
function VisualEnhancer:get(time)
	return time
end

return VisualEnhancer
