local gfx_util = require("gfx_util")

local Layout = require("sphere.views.Layout")

local _Layout = Layout:new()

function _Layout:draw()
	local width, height = love.graphics.getDimensions()

	love.graphics.replaceTransform(gfx_util.transform(self.transform))

	local _x, _y = love.graphics.inverseTransformPoint(0, 0)
	local _xw, _yh = love.graphics.inverseTransformPoint(width, height)
	local _w, _h = _xw - _x, _yh - _y

	self:pack("base", _x, _y, _w, _h)

	local x_int = 55
	local y_int = 55

	local x11, w11 = gfx_util.layout(_x, _w, {y_int, -0.2, -0.8, 72, y_int})
	local x12, w12 = gfx_util.layout(_x, _w, {y_int, -1, y_int})
	local x1, w1 = gfx_util.layout(_x, _w, {y_int, -1/3, x_int, -1/3, x_int, -1/3, y_int})

	local y0, h0 = gfx_util.layout(0, 1080, {y_int, -1, y_int})
	local y1, h1 = gfx_util.layout(y0[2], h0[2], {72 * 2, x_int, -1, x_int, 55, 72 * 3})
	local y2, h2 = gfx_util.layout(0, 1080, {-1/2, 72*6, -1/2})
	local y3, h3 = gfx_util.layout(y1[3], h1[3], {72, -1})

	love.graphics.setColor(0, 0, 0, 0.8)

	self:pack("title", x12[2], y1[1], w12[2], h1[1])
	self:pack("title_middle", x11[3], y1[1], w11[3], h1[1])
	self:pack("middle", x1[4], y2[2], w1[4], h2[2])
	self:pack("graphs", x12[2], y1[6], w12[2], h1[6])
	self:pack("graphs_sup_left", x1[2], y1[5], w1[2], h1[5])
	self:pack("graphs_sup_right", x1[6], y1[5], w1[6], h1[5])
	self:pack("column1", x1[2], y1[3], w1[2], h1[3])
	self:pack("column1row2", x1[2], y3[2], w1[2], h3[2])
	self:pack("column3row2", x1[6], y3[2], w1[6], h3[2])
	self:pack("column2", x1[4], y1[3], w1[4], h1[3])
	self:pack("column3", x1[6], y1[3], w1[6], h1[3])
	self:pack("column1row1", x1[2], y3[1], w1[2], h3[1])
	self:pack("column3row1", x1[6], y3[1], w1[6], h3[1])
	self:pack("title_left", x11[2], y1[1], w11[2], h1[1])
	self:pack("title_sub", x1[4], y1[2], w1[4], 72)
	self:pack("title_right", x11[4], y1[1], w11[4], h1[1])
	self:pack("middle_sub", x1[4], y2[3] - 72, w1[4], 72)
end

return _Layout
