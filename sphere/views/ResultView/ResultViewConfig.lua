
local screen = {
	unit = 1080,
	cs = {0.5, 0, 0.5 * 16 / 9, 0, "h"}
}

local Logo = {
	class = "LogoView",
	screen = screen,
	x = 279,
	y = 0,
	w = 454,
	h = 89,
	image = {
		x = 21,
		y = 20,
		w = 48,
		h = 48
	},
	text = {
		x = 89,
		baseline = 56,
		limit = 365,
		align = "left",
		fontSize = 32,
		fontFamily = "Noto Sans"
	}
}

local UserInfo = {
	class = "UserInfoView",
	screen = screen,
	x = 1187,
	y = 0,
	w = 454,
	h = 89,
	image = {
		x = 386,
		y = 20,
		w = 48,
		h = 48
	},
	text = {
		x = 0,
		baseline = 54,
		limit = 365,
		align = "right",
		fontSize = 26,
		fontFamily = "Noto Sans"
	}
}

local Background = {
	class = "BackgroundView",
	screen = screen,
	x = 0,
	y = 0,
	w = 1920,
	h = 1080,
	parallax = 0.01,
	dim = 0.5
}

local Rectangle = {
	class = "RectangleView",
	screen = screen,
	rectangles = {}
}

local BottomScreenMenu = {
	class = "ScreenMenuView",
	screen = screen,
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
	screens = {
		{
			{
				name = "Select",
				displayName = "back"
			}
		}
	}
}

local NoteSkinViewConfig = {
	Background,
	BottomScreenMenu,
	Rectangle,
	Logo,
	UserInfo,
}

return NoteSkinViewConfig
