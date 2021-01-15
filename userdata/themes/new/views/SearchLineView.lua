
local Node = require("aqua.util.Node")
local CoordinateManager = require("aqua.graphics.CoordinateManager")
local aquafonts			= require("aqua.assets.fonts")
local spherefonts		= require("sphere.assets.fonts")

local SearchLineView = Node:new()

SearchLineView.init = function(self)
	self:on("draw", self.draw)

	self.cs = CoordinateManager:getCS(0.5, 0, 0, 0, "h")
	self.x = 16 / 9 / 3 / 2 - 16 / 9 / 3 / 6
	self.w = 16 / 9 / 3
	self.h = 40 / 1080
	self.y = 1 / 15 - self.h / 2

	self.font = aquafonts.getFont(spherefonts.NotoSansRegular, 20)
end

SearchLineView.draw = function(self)
	local cs = self.cs

	local x = cs:X(self.x, true)
	local y = cs:Y(self.y, true)
	local w = cs:X(self.w)
	local h = cs:Y(self.h)

	local searchString = self.searchLineModel:getSearchString()
	if searchString == "" then
		love.graphics.setColor(1, 1, 1, 0.5)
		searchString = "Search..."
	else
		love.graphics.setColor(1, 1, 1, 1)
	end

	love.graphics.setFont(self.font)
	love.graphics.printf(
		searchString,
		x,
		y,
		w / cs.one * 1080,
		"left",
		0,
		cs.one / 1080,
		cs.one / 1080,
		-cs:X(20 / cs.one),
		-cs:Y(4 / cs.one)
	)

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.rectangle(
		"line",
		x,
		y,
		w,
		h,
		cs:X(20 / 1080),
		cs:Y(20 / 1080)
	)
end

return SearchLineView
