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

	local x_int = 24
	local y_int = 55

	local x0, w0 = gfx_util.layout(_x, _w, {y_int, -1/3, x_int, -1/3, x_int, -1/3, y_int})
	local y0, h0 = gfx_util.layout(_y, _h, {89, y_int, -1, y_int, 89})
	local grid0 = {x0, y0, w0, h0}

	self:pack("header", _x, y0[1], _w, h0[1])
	self:pack("footer", _x, y0[5], _w, h0[5])

	self:packgrid("column1", grid0, 2, 3)
	self:packgrid("column2", grid0, 4, 3)
	self:packgrid("column3", grid0, 6, 3)

	local y1, h1 = gfx_util.layout(self.column2[2], self.column2[4], {-1, x_int, 72 * 6})

	self:pack("column2row1", x0[4], y1[1], w0[4], h1[1])
	self:pack("column2row2", x0[4], y1[3], w0[4], h1[3])

	local y2, h2 = gfx_util.layout(self.column2row2[2], self.column2row2[4], {72, 72 * 5})

	self:pack("column2row2row1", x0[4], y2[1], w0[4], h2[1])
	self:pack("column2row2row2", x0[4], y2[2], w0[4], h2[2])

	local y3, h3 = gfx_util.layout(self.column1[2], self.column1[4], {72 * 6, x_int, -1, x_int, 72 * 2})

	self:pack("column1row1", x0[2], y3[1], w0[2], h3[1])
	self:pack("column1row2", x0[2], y3[3], w0[2], h3[3])
	self:pack("column1row3", x0[2], y3[5], w0[2], h3[5])

	local y4, h4 = gfx_util.layout(self.column1row1[2], self.column1row1[4], {72, -1})

	self:pack("column1row1row1", x0[2], y4[1], w0[2], h4[1])
	self:pack("column1row1row2", x0[2], y4[2], w0[2], h4[2])
end

return _Layout
