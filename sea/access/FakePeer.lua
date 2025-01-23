local IPeer = require("sea.access.IPeer")

---@class sea.FakePeer: sea.IPeer
---@operator call: sea.FakePeer
---@operator unm: sea.FakePeer
---@field [string] sea.FakePeer
local FakePeer = IPeer + {}

---@param no_return boolean?
function FakePeer:new(no_return)
	self.__no_return = no_return or false
end

---@return sea.FakePeer
function FakePeer:__unm()
	return FakePeer(not self.__no_return)
end

---@param k any
---@return sea.FakePeer
function FakePeer:__index(k)
	return self
end

---@param self sea.FakePeer
---@param ... any
---@return any ...
local function call(self, ...)
	if self.__no_return then
		return
	end
	return coroutine.yield(...)
end

---@param ... any
---@return any ...
function FakePeer:__call(...)
	local is_method = getmetatable(...) == FakePeer
	return call(self, select(is_method and 2 or 1, ...))
end

return FakePeer
