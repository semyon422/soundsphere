local just = require("just")

local function _draw(f, ...)
	just.keyboard_over()
	if f(...) then
		return true
	end
	if just.keypressed("escape") then
		return true
	end
end

return function(draw, close)
	return function(...)
		just.container("ModalImView", true)
		local ret = _draw(draw, ...)
		just.container()
		if ret and close then
			close(...)
		end
		return ret
	end
end
