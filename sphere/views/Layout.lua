local gfx_util = require("gfx_util")
local class = require("class")

---@class sphere.Layout
---@operator call: sphere.Layout
local Layout = class()

Layout.transform = {{1 / 2, -16 / 9 / 2}, 0, 0, {0, 1 / 1080}, {0, 1 / 1080}, 0, 0, 0, 0}

---@param rect_x string
---@param rect_y string?
---@return number
---@return number
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

---@param key string
---@param ... any?
function Layout:pack(key, ...)
	self[key] = self[key] or {}
	local t = self[key]
	for i = 1, select("#", ...) do
		t[i] = select(i, ...)
	end
end

---@param key string
---@param grid table
---@param i number
---@param j number
function Layout:packgrid(key, grid, i, j)
	local x, y, w, h = unpack(grid)
	self:pack(key, x[i], y[j], w[i], h[j])
end

return Layout
