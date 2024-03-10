local just = require("just")

local quit = false

---@param f function
---@param self table?
---@return any?
local function _draw(f, self, _quit)
	just.key_over()
	if quit then
		quit = false
		return f(self, true)
	end
	local ret = f(self, _quit)
	quit = self and just.keypressed("escape")
	return ret
end

return function(draw)
	return function(self, _quit)
		just.container("ModalImView", true)
		local ret = _draw(draw, self, _quit)
		just.container()
		return ret
	end
end
