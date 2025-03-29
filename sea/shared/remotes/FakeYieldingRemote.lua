local class = require("class")

---@class sea.FakeYieldingRemote
---@operator call: table
---@field [string] function
local FakeYieldingRemote = class()

---@param ... any
---@return any ...
local function yielding_method(_, ...)
	return coroutine.yield(...)
end

---@param k string
function FakeYieldingRemote:__index(k)
	return yielding_method
end

return FakeYieldingRemote
