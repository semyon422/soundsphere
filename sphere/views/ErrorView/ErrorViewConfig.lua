local transform = {{1 / 2, -16 / 9 / 2}, 0, 0, {0, 1 / 1080}, {0, 1 / 1080}, 0, 0, 0, 0}
local transformFull = {0, 0, 0, {1, 0}, {0, 1}, 0, 0, 0, 0}

local ErrorText = {
	class = "ValueView",
	key = "gameController.errorController.error",
	format = "%s",
	color = {1, 1, 1, 1},
	x = 89,
	baseline = 144,
	limit = math.huge,
	align = "left",
	font = {
		filename = "Noto Sans",
		size = 20,
	},
	transform = transform
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
		font = {
			filename = "Noto Sans",
			size = 24,
		},
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

local Title = {
	class = "ValueView",
	transform = transform,
	value = "Error",
	color = {1, 1, 1, 1},
	x = 89,
	baseline = 64,
	limit = 1920,
	align = "left",
	font = {
		filename = "Noto Sans",
		size = 36,
	},
}

local Rectangle = {
	class = "RectangleView",
	transform = transformFull,
	rectangles = {
		{
			color = {0.12, 0.12, 0.12, 1},
			mode = "fill",
			lineStyle = "smooth",
			lineWidth = 1,
			x = 0,
			y = 0,
			w = 1,
			h = 1,
			rx = 0,
			ry = 0
		}
	}
}

local GameplayViewConfig = {
	Rectangle,
	BottomScreenMenu,
	Title,
	ErrorText,
	require("sphere.views.DebugInfoViewConfig"),
}

return GameplayViewConfig
