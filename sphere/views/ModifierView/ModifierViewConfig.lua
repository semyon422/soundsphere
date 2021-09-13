local transform = {{1 / 2, -16 / 9 / 2}, 0, 0, {0, 1 / 1080}, {0, 1 / 1080}, 0, 0, 0, 0}

local AvailableModifierList = {
	class = "AvailableModifierListView",
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
		fontSize = 24,
		fontFamily = "Noto Sans",
		addedColor = {1, 1, 1, 0.5}
	},
	section = {
		x = 0,
		baseline = 19,
		limit = 409,
		align = "right",
		fontSize = 16,
		fontFamily = "Noto Sans"
	}
}

local ModifierList = {
	class = "ModifierListView",
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
		fontSize = 24,
		fontFamily = "Noto Sans"
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
			fontSize = 24,
			fontFamily = "Noto Sans"
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
			fontSize = 24,
			fontFamily = "Noto Sans"
		}
	},
	switch = {
		x = 305,
		y = 0,
		w = 72,
		h = 72
	},
}

local AvailableModifierScrollBar = {
	class = "ScrollBarView",
	transform = transform,
	list = AvailableModifierList,
	x = 263,
	y = 144,
	w = 16,
	h = 792,
	rows = 11,
	backgroundColor = {1, 1, 1, 0.33},
	color = {1, 1, 1, 0.66}
}

local Background = {
	class = "BackgroundView",
	transform = transform,
	x = 0,
	y = 0,
	w = 1920,
	h = 1080,
	parallax = 0.01,
	dim = {key = "settings.graphics.dim.select"},
	blur = {key = "settings.graphics.blur.select"}
}

local Rectangle = {
	class = "RectangleView",
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
}

local Circle = {
	class = "CircleView",
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
}

local BottomScreenMenu = {
	class = "ScreenMenuView",
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
		fontSize = 24,
		fontFamily = "Noto Sans"
	},
	items = {
		{
			{
				method = "changeScreen",
				value = "Select",
				displayName = "back"
			}
		}
	}
}

local ModifierViewConfig = {
	Background,
	BottomScreenMenu,
	AvailableModifierList,
	ModifierList,
	AvailableModifierScrollBar,
	Rectangle,
	Circle
}

return ModifierViewConfig
