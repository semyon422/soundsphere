local ModalImView = require("sphere.imviews.ModalImView")
local ContainerImView = require("sphere.imviews.ContainerImView")
local TextButtonImView = require("sphere.imviews.TextButtonImView")
local spherefonts = require("sphere.assets.fonts")
local _transform = require("gfx_util").transform
local just = require("just")

local transform = {{1 / 2, -16 / 9 / 2}, 0, 0, {0, 1 / 1080}, {0, 1 / 1080}, 0, 0, 0, 0}

local scrollY = 0
local w, h = 768, 1080 / 2
local _w, _h = w / 2, 55
local r = 8
local window_id = "AddTimingObjectView"

return ModalImView(function(self)
	if not self then
		return true
	end

	love.graphics.setFont(spherefonts.get("Noto Sans", 24))

	love.graphics.replaceTransform(_transform(transform))
	love.graphics.translate((1920 - w) / 2, (1080 - h) / 2)

	love.graphics.setColor(0, 0, 0, 0.8)
	love.graphics.rectangle("fill", 0, 0, w, h, r)
	love.graphics.setColor(1, 1, 1, 1)

	just.push()
	ContainerImView(window_id, w, h, _h * 2, scrollY)

	just.text("qweqwe")

	scrollY = ContainerImView()
	just.pop()

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.rectangle("line", 0, 0, w, h, r)
end)
