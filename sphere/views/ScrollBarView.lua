local Class = require("aqua.util.Class")
local transform = require("aqua.graphics.transform")

local ScrollBarView = Class:new()

ScrollBarView.draw = function(self)
	local tf = transform(self.transform):translate(self.x, self.y)
	love.graphics.replaceTransform(tf)

	love.graphics.setColor(self.backgroundColor)
	love.graphics.rectangle(
		"fill",
		0,
		0,
		self.w,
		self.h,
		self.w / 2,
		self.w / 2
	)

	local itemCount = #self.list.items
	local rows = self.list.rows
	local h = self.w + (self.h - self.w) * rows / (itemCount + rows)

	love.graphics.setColor(self.color)
	love.graphics.rectangle(
		"fill",
		0,
		(self.h - h) * (self.list.selectedVisualItem - 1) / (itemCount - 1),
		self.w,
		h,
		self.w / 2,
		self.w / 2
	)
end

return ScrollBarView
