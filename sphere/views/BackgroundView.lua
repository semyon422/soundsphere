
local Node = require("aqua.util.Node")
local frame_draw = require("aqua.graphics.frame_draw")
local map = require("aqua.math").map
local CoordinateManager = require("aqua.graphics.CoordinateManager")

local BackgroundView = Node:new()

BackgroundView.parallax = 0.0125

BackgroundView.init = function(self)
	self:on("draw", self.draw)

	self.cs = CoordinateManager:getCS(0, 0, 0, 0, "all")
end

BackgroundView.draw = function(self)
	local cs = self.cs

	local image = self.view.backgroundModel:getImage()

	if not image then
		return
	end

	love.graphics.setColor(0.4, 0.4, 0.4, 1)

	local mx = self.cs:x(love.mouse.getX(), true)
	local my = self.cs:y(love.mouse.getY(), true)
	frame_draw(
		image,
		cs:X(0 - map(mx, 0, 1, self.parallax, 0), true),
		cs:Y(0 - map(my, 0, 1, self.parallax, 0), true),
		cs:X(1 + 2 * self.parallax),
		cs:Y(1 + 2 * self.parallax),
		"out"
	)
end

return BackgroundView
