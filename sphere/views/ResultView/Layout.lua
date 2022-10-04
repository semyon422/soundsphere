local transform = require("gfx_util").transform
local just_layout = require("just.layout")
local RoundedRectangle = require("sphere.views.RoundedRectangle")

local function setRect(t, x, y, w, h)
	t.x = assert(x)
	t.y = assert(y)
	t.w = assert(w)
	t.h = assert(h)
end

local function getRect(out, r)
	if not out then
		return r.x, r.y, r.w, r.h
	end
	out.x = r.x
	out.y = r.y
	out.w = r.w
	out.h = r.h
end

local function drawFrame(rect)
	local x, y, w, h = getRect(nil, rect)
	love.graphics.rectangle("fill", x, y, w, h, 36)
end

return {
	title = {},
	title_middle = {},
	title_left = {},
	title_right = {},
	title_sub = {},
	graphs = {},
	graphs_sup_left = {},
	graphs_sup_right = {},
	middle = {},
	middle_sub = {},
	column1 = {},
	column1row1 = {},
	column1row2 = {},
	column2 = {},
	column3 = {},
	column3row1 = {},
	column3row2 = {},
	transform = {{1 / 2, -16 / 9 / 2}, 0, 0, {0, 1 / 1080}, {0, 1 / 1080}, 0, 0, 0, 0},
	draw = function(self)
		local width, height = love.graphics.getDimensions()
		love.graphics.origin()

		love.graphics.setColor(1, 1, 1, 0.2)
		love.graphics.rectangle("fill", 0, 0, width, height)

		love.graphics.replaceTransform(transform(self.transform))

		local _x, _y = love.graphics.inverseTransformPoint(0, 0)
		local _xw, _yh = love.graphics.inverseTransformPoint(width, height)
		local _w, _h = _xw - _x, _yh - _y

		self.x, self.x = _x, _y
		self.w, self.h = _w, _h

		local x_int = 55
		-- local x_int = 24
		local y_int = 55

		local x0, w0 = just_layout(0, 1920, {1920})
		local x11, w11 = just_layout(_x, _w, {y_int, -0.2, -0.8, 72, y_int})
		local x12, w12 = just_layout(_x, _w, {y_int, -1, y_int})
		local x1, w1 = just_layout(_x, _w, {y_int, -1/3, x_int, -1/3, x_int, -1/3, y_int})

		local y0, h0 = just_layout(0, 1080, {y_int, -1, y_int})
		-- local y0, h0 = just_layout(0, 1080, {89, y_int, -1, y_int, 89})
		local y1, h1 = just_layout(y0[2], h0[2], {72 * 2, x_int, -1, x_int, 55, 72 * 3})
		-- local y1, h1 = just_layout(y0[2], h0[2], {72 * 2, x_int, -1, x_int, 72 * 3})
		local y2, h2 = just_layout(0, 1080, {-1/2, 72*6, -1/2})
		local y3, h3 = just_layout(y1[3], h1[3], {72, -1})

		love.graphics.setColor(0, 0, 0, 0.8)

		-- setRect(self.title, x11[2], y1[1], w11[2], h1[1])
		setRect(self.title, x12[2], y1[1], w12[2], h1[1])
		-- drawFrame(self.title)

		setRect(self.title_middle, x11[3], y1[1], w11[3], h1[1])
		drawFrame(self.title_middle)

		setRect(self.middle, x1[4], y2[2], w1[4], h2[2])
		drawFrame(self.middle)

		setRect(self.graphs, x12[2], y1[6], w12[2], h1[6])
		drawFrame(self.graphs)

		setRect(self.graphs_sup_left, x1[2], y1[5], w1[2], h1[5])
		RoundedRectangle("fill", x1[2], y1[5], w1[2], h1[5], {36, h1[5] / 2, 36, h1[5] / 2}, false, true)

		setRect(self.graphs_sup_right, x1[6], y1[5], w1[6], h1[5])
		RoundedRectangle("fill", x1[6], y1[5], w1[6], h1[5], {h1[5] / 2, 36, h1[5] / 2, 36}, true, false)

		setRect(self.column1, x1[2], y1[3], w1[2], h1[3])
		drawFrame(self.column1)

		setRect(self.column1row2, x1[2], y3[2], w1[2], h3[2])
		setRect(self.column3row2, x1[6], y3[2], w1[6], h3[2])
		-- drawFrame(self.column1row2)

		setRect(self.column2, x1[4], y1[3], w1[4], h1[3])
		-- drawFrame(self.column2)

		setRect(self.column3, x1[6], y1[3], w1[6], h1[3])
		drawFrame(self.column3)

		love.graphics.setColor(0.4, 0.4, 0.4, 0.7)

		setRect(self.column1row1, x1[2], y3[1], w1[2], h3[1])
		local x, y, w, h = getRect(nil, self.column1row1)
		RoundedRectangle("fill", x, y, w, h, 36)

		setRect(self.column3row1, x1[6], y3[1], w1[6], h3[1])
		local x, y, w, h = getRect(nil, self.column3row1)
		RoundedRectangle("fill", x, y, w, h, 36)

		love.graphics.setColor(0.1, 0.1, 0.1, 0.8)

		setRect(self.title_left, x11[2], y1[1], w11[2], h1[1])
		RoundedRectangle("fill", x11[2], y1[1], w11[2], h1[1], 36, false, false, 3)

		setRect(self.title_sub, x1[4], y1[2], w1[4], 72)
		RoundedRectangle("fill", x1[4], y1[2], w1[4], 72, 36, true, true, 2)

		setRect(self.title_right, x11[4], y1[1], w11[4], h1[1])
		RoundedRectangle("fill", x11[4], y1[1], w11[4], h1[1], 36, false, false, 1)

		love.graphics.setColor(0.4, 0.4, 0.4, 0.3)
		-- love.graphics.setColor(0.4, 0.4, 0.4, 0.7)

		setRect(self.middle_sub, x1[4], y2[3] - 72, w1[4], 72)
		RoundedRectangle("fill", x1[4], y2[3] - 72, w1[4], 72, 36, false, false, 2)
	end,
}
