local _transform = require("aqua.graphics.transform")
local just = require("just")
local just_layout = require("just.layout")

local ScrollBarView = require("sphere.views.ScrollBarView")
local RectangleView = require("sphere.views.RectangleView")
local CircleView = require("sphere.views.CircleView")

local AvailableModifierListView = require("sphere.views.ModifierView.AvailableModifierListView")
local ModifierListView = require("sphere.views.ModifierView.ModifierListView")

local transform = {{1 / 2, -16 / 9 / 2}, 0, 0, {0, 1 / 1080}, {0, 1 / 1080}, 0, 0, 0, 0}

local Frames = {draw = function()
	local width, height = love.graphics.getDimensions()
	love.graphics.origin()

	love.graphics.replaceTransform(_transform(transform))

	local _x, _y = love.graphics.inverseTransformPoint(0, 0)
	local _xw, _yh = love.graphics.inverseTransformPoint(width, height)
	local _w, _h = _xw - _x, _yh - _y

	local x_int = 24
	local y_int = 55

	-- local x1, w1 = just_layout(0, 1920, {24, -1/3, -1/3, -1/3, 24})

	local y0, h0 = just_layout(0, 1080, {89, y_int, -1, y_int, 89})

	love.graphics.setColor(0, 0, 0, 0.8)
	local x, y, w, h = 279, 144, 1362, 792
	love.graphics.rectangle("fill", x, y, w, h, 36)
end}

local ContainerBegin = {draw = function(self)
	love.graphics.replaceTransform(_transform(transform))

	local x, y, w, h = 279, 144, 1362, 792
	love.graphics.translate(x, y)

	local over = just.is_over(w, h)
	just.container("modifiers window", over)
	just.wheel_over("modifiers window", over)
end}

local ContainerEnd = {draw = function(self)
	just.container()
end}

local AvailableModifierList = AvailableModifierListView:new({
	transform = transform,
	x = 279,
	y = 144,
	w = 454,
	h = 792,
	rows = 11,
})

local ModifierList = ModifierListView:new({
	transform = transform,
	x = 733,
	y = 144,
	w = 454,
	h = 792,
	rows = 11,
})

local AvailableModifierScrollBar = ScrollBarView:new({
	transform = transform,
	list = AvailableModifierList,
	x = 263,
	y = 144,
	w = 16,
	h = 792,
	rows = 11,
	backgroundColor = {1, 1, 1, 0.33},
	color = {1, 1, 1, 0.66}
})

local Rectangle = RectangleView:new({
	transform = transform,
	rectangles = {
		{
			color = {1, 1, 1, 1},
			mode = "fill",
			lineStyle = "smooth",
			lineWidth = 1,
			x = 733,
			y = 504,
			w = 4,
			h = 72,
			rx = 0,
			ry = 0
		},
		{
			color = {1, 1, 1, 1},
			mode = "fill",
			lineStyle = "smooth",
			lineWidth = 1,
			x = 279,
			y = 504,
			w = 4,
			h = 72,
			rx = 0,
			ry = 0
		}
	}
})

local Circle = CircleView:new({
	transform = transform,
	circles = {
		{
			color = {1, 1, 1, 1},
			mode = "fill",
			lineStyle = "smooth",
			lineWidth = 1,
			x = 755,
			y = 504,
			r = 4
		},
		{
			color = {1, 1, 1, 1},
			mode = "line",
			lineStyle = "smooth",
			lineWidth = 1,
			x = 755,
			y = 504,
			r = 4
		},
	}
})

local ModifierViewConfig = {
	Frames,
	ContainerBegin,
	AvailableModifierList,
	ModifierList,
	AvailableModifierScrollBar,
	Rectangle,
	Circle,
	ContainerEnd,
	require("sphere.views.DebugInfoViewConfig"),
}

return ModifierViewConfig
