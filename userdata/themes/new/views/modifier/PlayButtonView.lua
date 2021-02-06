
local Node = require("aqua.util.Node")
local CoordinateManager = require("aqua.graphics.CoordinateManager")

local aquafonts			= require("aqua.assets.fonts")
local spherefonts		= require("sphere.assets.fonts")

local PlayButtonView = Node:new()

PlayButtonView.init = function(self)
	self:on("draw", self.draw)

	self.fontName = aquafonts.getFont(spherefonts.NotoSansRegular, 36)

	self.cs = CoordinateManager:getCS(0.5, 0, 0, 0, "h")
	self.x = 16 / 9 / 3
	self.y = 1 / 2
	self.r = 16 / 9 / 3 / 4 * 1 / 2
end

PlayButtonView.draw = function(self)
	local cs = self.cs

	local x = cs:X(self.x, true)
	local y = cs:Y(self.y, true)
	local r = cs:X(self.r)

	local index = self.index

	love.graphics.setColor(0.25, 0.25, 0.25, 1)
	love.graphics.setLineWidth(1)
	love.graphics.circle(
		"fill",
		x,
		y,
		r
	)

    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(self.fontName)
    love.graphics.printf(
        "play",
        x - r,
        y,
        2 * r / cs.one * 1080,
        "center",
        0,
        cs.one / 1080,
        cs.one / 1080,
        -cs:X(0 / cs.one),
        -cs:Y(-30 / cs.one)
    )
end

return PlayButtonView
