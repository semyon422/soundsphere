
local class = require("class")
local gfx_util = require("gfx_util")
local map = require("math_util").map

---@class sphere.BackgroundView
---@operator call: sphere.BackgroundView
local BackgroundView = class()

---@param w number
---@param h number
---@param dim number
---@param parallax number
function BackgroundView:draw(w, h, dim, parallax)
	if dim == 1 then
		return
	end

	local backgroundModel = self.ui.backgroundModel

	local images = backgroundModel.images
	local alpha = backgroundModel.alpha

	dim = 1 - dim
	local r, g, b = dim, dim, dim

	local mx, my = love.mouse.getPosition()
	for i = 1, 3 do
		if not images[i] then
			return
		end

		if i == 1 then
			love.graphics.setColor(r, g, b, 1)
		elseif i == 2 then
			love.graphics.setColor(r, g, b, alpha)
		elseif i == 3 then
			love.graphics.setColor(r, g, b, 0)
		end

		gfx_util.drawFrame(
			images[i],
			-map(mx, 0, w, parallax, 0) * w,
			-map(my, 0, h, parallax, 0) * h,
			(1 + 2 * parallax) * w,
			(1 + 2 * parallax) * h,
			"out"
		)
	end
end

return BackgroundView
