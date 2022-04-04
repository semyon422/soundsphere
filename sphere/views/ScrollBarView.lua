local Class = require("aqua.util.Class")
local transform = require("aqua.graphics.transform")

local ScrollBarView = Class:new()

ScrollBarView.draw = function(self)
	local config = self.config

	local tf = transform(config.transform):translate(config.x, config.y)
	love.graphics.replaceTransform(tf)
	tf:release()

	love.graphics.setColor(config.backgroundColor)
	love.graphics.rectangle(
		"fill",
		0,
		0,
		config.w,
		config.h,
		config.w / 2,
		config.w / 2
	)

	local listViewConfig = config.list
	local listViewState = self.sequenceView:getState(listViewConfig)

	local itemCount = #listViewState.items
	local rows = listViewConfig.rows
	local h = config.w + (config.h - config.w) * rows / (itemCount + rows)

	love.graphics.setColor(config.color)
	love.graphics.rectangle(
		"fill",
		0,
		(config.h - h) * (listViewState.selectedVisualItem - 1) / (itemCount - 1),
		config.w,
		h,
		config.w / 2,
		config.w / 2
	)
end

return ScrollBarView
