local gfx_util = require("gfx_util")
local class = require("class")

local Layout = class()

Layout.transform = {{1 / 2, -16 / 9 / 2}, 0, 0, {0, 1 / 1080}, {0, 1 / 1080}, 0, 0, 0, 0}

function Layout:move(rect_x, rect_y)
	local _
	local x, y, w, h = unpack(self[rect_x])
	if rect_y then
		_, y, _, h = unpack(self[rect_y])
	end

	local tf = gfx_util.transform(self.transform)
	love.graphics.replaceTransform(tf)
	love.graphics.translate(x, y)

	return w, h
end

function Layout:pack(key, ...)
	self[key] = self[key] or {}
	local t = self[key]
	for i = 1, select("#", ...) do
		t[i] = select(i, ...)
	end
end

function Layout:packgrid(key, grid, i, j)
	local x, y, w, h = unpack(grid)
	self:pack(key, x[i], y[j], w[i], h[j])
end

return Layout
