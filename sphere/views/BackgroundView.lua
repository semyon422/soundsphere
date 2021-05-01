
local Node = require("aqua.util.Node")
local frame_draw = require("aqua.graphics.frame_draw")
local map = require("aqua.math").map
local CoordinateManager = require("aqua.graphics.CoordinateManager")

local BackgroundView = Node:new()

BackgroundView.parallax = 0.0125

BackgroundView.load = function(self)
	self:on("draw", self.draw)

	self.cs = CoordinateManager:getCS(0, 0, 0, 0, "all")
end

BackgroundView.draw = function(self)
	local cs = self.cs

	local images = self.view.backgroundModel.images
	local alpha = self.view.backgroundModel.alpha

	local r, g, b = 0.4, 0.4, 0.4

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

		local mx = self.cs:x(love.mouse.getX(), true)
		local my = self.cs:y(love.mouse.getY(), true)
		frame_draw(
			images[i],
			cs:X(0 - map(mx, 0, 1, self.parallax, 0), true),
			cs:Y(0 - map(my, 0, 1, self.parallax, 0), true),
			cs:X(1 + 2 * self.parallax),
			cs:Y(1 + 2 * self.parallax),
			"out"
		)
	end
end

return BackgroundView
