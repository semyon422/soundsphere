local class = require("class")

---@class native.IMidiInput
---@operator call: native.IMidiInput
local IMidiInput = class()

---@return number
function IMidiInput:getPorts()
	return 0
end

---@return function
---@return table
function IMidiInput:events()
	return next, self
end

return IMidiInput
