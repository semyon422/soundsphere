
local screen = {
	unit = 1080,
	cs = {0.5, 0, 0.5 * 16 / 9, 0, "h"}
}

local SectionsList = {
	class = "SectionsListView",
	screen = screen,
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

local SettingsList = {
	class = "SettingsListView",
	screen = screen,
	x = 733,
	y = 144,
	w = 681,
	h = 792,
	rows = 11,
	scroll = {
		x = 0,
		y = 0,
		w = 454,
		h = 792
	},
	name = {
		x = 44,
		baseline = 45,
		limit = 410,
		align = "left",
		fontSize = 24,
		fontFamily = "Noto Sans"
	},
	slider = {
		x = 454,
		y = 0,
		w = 227,
		h = 72,
		value = {
			x = 0,
			baseline = 45,
			limit = 454,
			align = "right",
			fontSize = 24,
			fontFamily = "Noto Sans"
		}
	},
	stepper = {
		x = 454,
		y = 0,
		w = 227,
		h = 72,
		value = {
			x = 454,
			baseline = 45,
			limit = 227,
			align = "center",
			fontSize = 24,
			fontFamily = "Noto Sans"
		}
	},
	switch = {
		x = 531,
		y = 0,
		w = 72,
		h = 72
	},
	input = {
		x = 454,
		y = 0,
		w = 227,
		h = 72,
		value = {
			x = 454,
			baseline = 45,
			limit = 227,
			align = "center",
			fontSize = 24,
			fontFamily = "Noto Sans"
		}
	},
}

local SectionsScrollBar = {
	class = "ScrollBarView",
	screen = screen,
	list = SectionsList,
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

local SettingsViewConfig = {
	Background,
	BottomScreenMenu,
	SectionsList,
	SettingsList,
	SectionsScrollBar,
	Rectangle
}

return SettingsViewConfig
