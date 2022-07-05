local just = require("just")
local transform = require("aqua.graphics.transform")

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

local function addPoint(points, x, y)
	table.insert(points, x)
	table.insert(points, y)
end
local function rectangle2(mode, x, y, w, h, r)
	local points = {}
	addPoint(points, x + r, y)
	addPoint(points, x + w - r, y)
	for a = -math.pi / 2, 0, math.pi / 64 do
		addPoint(points, x + w - r + math.cos(a) * r, y + r + math.sin(a) * r)
	end
	addPoint(points, x + w, y + h)
	addPoint(points, x, y + h)
	addPoint(points, x, y + r)
	for a = -math.pi, -math.pi / 2, math.pi / 64 do
		addPoint(points, x + r + math.cos(a) * r, y + r + math.sin(a) * r)
	end
	love.graphics.polygon(mode, points)

	points = {}
	addPoint(points, x + w, y + h)
	addPoint(points, x + w, y + h + r)
	for a = 0, -math.pi / 2, -math.pi / 64 do
		addPoint(points, x + w - r + math.cos(a) * r, y + h + r + math.sin(a) * r)
	end
	addPoint(points, x + w - r, y + h)
	love.graphics.polygon(mode, points)

	points = {}
	addPoint(points, x, y + h)
	addPoint(points, x + r, y + h)
	for a = -math.pi / 2, -math.pi, -math.pi / 64 do
		addPoint(points, x + r + math.cos(a) * r, y + h + r + math.sin(a) * r)
	end
	addPoint(points, x, y + h + r)
	love.graphics.polygon(mode, points)
end

local function drawFrame(rect)
	local x, y, w, h = getRect(nil, rect)
	love.graphics.rectangle("fill", x, y, w, h, 36)
end

return {
	header = {},
	footer = {},
	subheader = {},
	column1 = {},
	column2 = {},
	column3 = {},
	column2row1 = {},
	column2row2 = {},
	column2row2row1 = {},
	column2row2row2 = {},
	column1row1 = {},
	column1row2 = {},
	column1row3 = {},
	column1row1row1 = {},
	column1row1row2 = {},
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

		local x_int = 24
		local y_int = 55

		local x0, w0 = just.layout(0, 1920, {1920})
		local x1, w1 = just.layout(_x, _w, {y_int, -1/3, x_int, -1/3, x_int, -1/3, y_int})

		local y0, h0 = just.layout(0, 1080, {89, y_int, -1, y_int, 89})

		self.x0, self.w0 = x0, w0
		self.x1, self.w1 = x1, w1
		self.y0, self.h0 = y0, h0

		setRect(self.header, x0[1], y0[1], w0[1], h0[1])
		setRect(self.footer, x0[1], y0[5], w0[1], h0[5])
		setRect(self.subheader, x1[4], y0[2], w1[4], h0[2])

		setRect(self.column1, x1[2], y0[3], w1[2], h0[3])
		setRect(self.column2, x1[4], y0[3], w1[4], h0[3])
		setRect(self.column3, x1[6], y0[3], w1[6], h0[3])

		local y1, h1 = just.layout(self.column2.y, self.column2.h, {-1, x_int, 72 * 6})

		setRect(self.column2row1, x1[4], y1[1], w1[4], h1[1])
		setRect(self.column2row2, x1[4], y1[3], w1[4], h1[3])

		local y2, h2 = just.layout(self.column2row2.y, self.column2row2.h, {72, 72 * 5})

		setRect(self.column2row2row1, x1[4], y2[1], w1[4], h2[1])
		setRect(self.column2row2row2, x1[4], y2[2], w1[4], h2[2])

		local y3, h3 = just.layout(self.column1.y, self.column1.h, {72 * 6, x_int, -1, x_int, 72 * 2})

		setRect(self.column1row1, x1[2], y3[1], w1[2], h3[1])
		setRect(self.column1row2, x1[2], y3[3], w1[2], h3[3])
		setRect(self.column1row3, x1[2], y3[5], w1[2], h3[5])

		local y4, h4 = just.layout(self.column1row1.y, self.column1row1.h, {72, -1})

		setRect(self.column1row1row1, x1[2], y4[1], w1[2], h4[1])
		setRect(self.column1row1row2, x1[2], y4[2], w1[2], h4[2])

		love.graphics.setColor(0, 0, 0, 0.8)

		drawFrame(self.column1row1)
		drawFrame(self.column1row2)
		drawFrame(self.column1row3)
		drawFrame(self.column2row1)
		drawFrame(self.column2row2)
		drawFrame(self.column3)

		love.graphics.setColor(0.4, 0.4, 0.4, 0.7)

		local x, y, w, h = getRect(nil, self.column2row2row1)
		rectangle2("fill", x, y, w, h, 36)

		x, y, w, h = getRect(nil, self.column1row1row1)
		rectangle2("fill", x, y, w, h, 36)

		love.graphics.setColor(0, 0, 0, 0.8)
		love.graphics.rectangle("fill", _x, _y, _w, h0[1])
		love.graphics.rectangle("fill", _x, _yh - h0[5], _w, h0[1])
	end
}
