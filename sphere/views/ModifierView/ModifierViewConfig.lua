local just = require("just")
local _transform = require("aqua.graphics.transform")
local ScrollBarView = require("sphere.views.ScrollBarView")
local RectangleView = require("sphere.views.RectangleView")
local CircleView = require("sphere.views.CircleView")
local ScreenMenuView = require("sphere.views.ScreenMenuView")
local BackgroundView = require("sphere.views.BackgroundView")
local GaussianBlurView = require("sphere.views.GaussianBlurView")

local AvailableModifierListView = require("sphere.views.ModifierView.AvailableModifierListView")
local ModifierListView = require("sphere.views.ModifierView.ModifierListView")

local transform = {{1 / 2, -16 / 9 / 2}, 0, 0, {0, 1 / 1080}, {0, 1 / 1080}, 0, 0, 0, 0}

local Frames = {draw = function()
	local width, height = love.graphics.getDimensions()
	love.graphics.origin()

	love.graphics.setColor(1, 1, 1, 0.2)
	love.graphics.rectangle("fill", 0, 0, width, height)

	love.graphics.replaceTransform(_transform(transform))

	local _x, _y = love.graphics.inverseTransformPoint(0, 0)
	local _xw, _yh = love.graphics.inverseTransformPoint(width, height)
	local _w, _h = _xw - _x, _yh - _y

	local x_int = 24
	local y_int = 55

	-- local x1, w1 = just.layout(0, 1920, {24, -1/3, -1/3, -1/3, 24})

	local y0, h0 = just.layout(0, 1080, {89, y_int, -1, y_int, 89})



	love.graphics.setColor(0, 0, 0, 0.8)
	love.graphics.rectangle("fill", _x, y0[3], _w, h0[3])
	love.graphics.rectangle("fill", _x, _y, _w, h0[1])
	love.graphics.rectangle("fill", _x, _yh - h0[5], _w, h0[1])
end}

local AvailableModifierList = AvailableModifierListView:new({
	transform = transform,
	x = 279,
	y = 144,
	w = 454,
	h = 792,
	rows = 11,
	name = {
		x = 44,
		baseline = 45,
		limit = 410,
		align = "left",
		font = {"Noto Sans", 24},
		addedColor = {1, 1, 1, 0.5}
	},
	section = {
		x = 0,
		baseline = 19,
		limit = 409,
		align = "right",
		font = {"Noto Sans", 16},
	}
})

local ModifierList = ModifierListView:new({
	transform = transform,
	x = 733,
	y = 144,
	w = 454,
	h = 792,
	rows = 11,
	scroll = {
		x = 0,
		y = 0,
		w = 227,
		h = 792
	},
	name = {
		x = 44,
		baseline = 45,
		limit = 183,
		align = "left",
		font = {"Noto Sans", 24},
	},
	slider = {
		x = 227,
		y = 0,
		w = 227,
		h = 72,
		value = {
			x = 0,
			baseline = 45,
			limit = 227,
			align = "right",
			font = {"Noto Sans", 24},
		}
	},
	stepper = {
		x = 227,
		y = 0,
		w = 227,
		h = 72,
		value = {
			x = 227,
			baseline = 45,
			limit = 227,
			align = "center",
			font = {"Noto Sans", 24},
		}
	},
	switch = {
		x = 305,
		y = 0,
		w = 72,
		h = 72
	},
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

local BackgroundBlurSwitch = GaussianBlurView:new({
	blur = {key = "game.configModel.configs.settings.graphics.blur.select"}
})

local Background = BackgroundView:new({
	transform = transform,
	x = 0,
	y = 0,
	w = 1920,
	h = 1080,
	parallax = 0.01,
	dim = {key = "game.configModel.configs.settings.graphics.dim.select"},
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

local BottomScreenMenu = ScreenMenuView:new({
	transform = transform,
	x = 279,
	y = 991,
	w = 227,
	h = 89,
	rows = 1,
	columns = 1,
	text = {
		x = 0,
		baseline = 54,
		limit = 227,
		align = "center",
		font = {"Noto Sans", 24},
	},
	items = {
		{
			{
				method = "changeScreen",
				value = "selectView",
				displayName = "back"
			}
		}
	}
})

local ModifierViewConfig = {
	BackgroundBlurSwitch,
	Background,
	BackgroundBlurSwitch,
	Frames,
	BottomScreenMenu,
	AvailableModifierList,
	ModifierList,
	AvailableModifierScrollBar,
	Rectangle,
	Circle,
	require("sphere.views.DebugInfoViewConfig"),
}

return ModifierViewConfig
