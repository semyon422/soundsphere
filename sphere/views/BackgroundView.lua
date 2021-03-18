
local Node = require("aqua.util.Node")
local CoordinateManager = require("aqua.graphics.CoordinateManager")

local BackgroundView = Node:new()

BackgroundView.init = function(self)
	self:on("draw", self.draw)

	self.cs = CoordinateManager:getCS(0, 0, 0, 0, "all")
	self.x = 0
	self.y = 0
	self.w = 1
	self.h = 1
end

BackgroundView.draw = function(self)
	local cs = self.cs

	local x = cs:X(self.x, true)
	local y = cs:Y(self.y, true)
	local w = cs:X(self.w)
	local h = cs:Y(self.h)

	local index = self.index

	love.graphics.setColor(0.125, 0.125, 0.125, 1)
	love.graphics.rectangle(
		"fill",
		x,
		y,
		w,
		h
	)
end

return BackgroundView
