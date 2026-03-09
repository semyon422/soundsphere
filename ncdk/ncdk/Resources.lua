local class = require("class")

---@alias ncdk.ResourceType "sound"|"image"|"ojm"

---@class ncdk.Resources
---@operator call: ncdk.Resources
local Resources = class()

---@param _type ncdk.ResourceType
---@param name string
---@param ... string fallbacks
function Resources:add(_type, name, ...)
	self[_type] = self[_type] or {}
	self[_type][name] = {name, ...}
end

---@return fun(): ncdk.ResourceType, string[]
function Resources:iter()
	return coroutine.wrap(function()
		for _type, data in pairs(self) do
			for name, paths in pairs(data) do
				coroutine.yield(_type, paths)
			end
		end
	end)
end

return Resources
