local just = require("just")

local function _draw(f, self)
	just.keyboard_over()
	if self and just.keypressed("escape") then
		return f()
	end
	return f(self)
end

return function(draw)
	return function(self)
		just.container("ModalImView", true)
		local ret = _draw(draw, self)
		just.container()
		return ret
	end
end
