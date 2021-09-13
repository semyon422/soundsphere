local transform = {{1 / 2, -16 / 9 / 2}, 0, 0, {0, 1 / 1080}, {0, 1 / 1080}, 0, 0, 0, 0}

local InputList = {
	class = "InputListView",
	transform = transform,
	x = 733,
	y = 144,
	w = 454,
	h = 792,
	rows = 11,
	name = {
		x = 44,
		baseline = 45,
		limit = 1920,
		align = "left",
		fontSize = 24,
		fontFamily = "Noto Sans",
		addedColor = {1, 1, 1, 0.5}
	},
	point = {
		x = 22,
		y = 36,
		r = 7
	},
	input = {
		value = {
			x = 227,
			baseline = 45,
			limit = 227,
			align = "center",
			fontSize = 24,
			fontFamily = "Noto Sans"
		}
	},
}

local InputScrollBar = {
	class = "ScrollBarView",
	transform = transform,
	list = InputList,
	x = 1187,
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
		}
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

local InputViewConfig = {
	Background,
	BottomScreenMenu,
	InputList,
	InputScrollBar,
	Rectangle
}

return InputViewConfig
