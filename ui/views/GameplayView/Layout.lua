local gfx_util = require("gfx_util")

local Layout = require("sphere.views.Layout")

local _Layout = Layout()

function _Layout:draw()
	local width, height = love.graphics.getDimensions()

	love.graphics.replaceTransform(gfx_util.transform(self.transform))

	local _x, _y = love.graphics.inverseTransformPoint(0, 0)
	local _xw, _yh = love.graphics.inverseTransformPoint(width, height)
	local _w, _h = _xw - _x, _yh - _y

	self:pack("base", _x, _y, _w, _h)


	local x0, w0 = gfx_util.layout(_x, _w, {-1})

	local y0, h0 = gfx_util.layout(0, 1080, {89, -1, 89})

	self:pack("header", x0[1], y0[1], w0[1], h0[1])
	self:pack("footer", x0[1], y0[3], w0[1], h0[3])
end

return _Layout
