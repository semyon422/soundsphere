local ContainerImView = require("sphere.imviews.ContainerImView")
local just = require("just")

local stack = {}

local size = 0.75
return function(id, w, h, _h, scrollY)
	if not id then
		w, h, _h = unpack(table.remove(stack))
		local r = _h * size / 2
		local x = _h * (1 - size) / 2

		scrollY = ContainerImView()
		just.pop()

		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.rectangle("line", x, x, w - x * 2, h - x * 2, r)

		just.next(w, h)

		return scrollY
	end

	local x = _h * (1 - size) / 2
	table.insert(stack, {w, h, _h})

	just.push()
	love.graphics.translate(x, x)
	ContainerImView(id, w - x * 2, h - x * 2, _h, scrollY)
end
