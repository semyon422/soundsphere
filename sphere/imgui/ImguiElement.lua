local ffi = require("ffi")
local Class = require("aqua.util.Class")

local ImguiElement = Class:new()

ImguiElement.getPointer = function(self, ctype)
	local key = self.key
	local key_ptr = key .. "_ptr"
	local ptr = self[key_ptr]
	if not ptr then
		ptr = ffi.new(ctype)
		self[key_ptr] = ptr
	end
	return ptr
end

ImguiElement.render = function(self) end

return ImguiElement
