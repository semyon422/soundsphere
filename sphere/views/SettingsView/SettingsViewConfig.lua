local transform = {{1 / 2, -16 / 9 / 2}, 0, 0, {0, 1 / 1080}, {0, 1 / 1080}, 0, 0, 0, 0}

local SectionsList = {
	class = "SectionsListView",
	transform = transform,
	x = 279,
	y = 144,
	w = 454,
	h = 792,
	rows = 11,
	elements = {
		{
			type = "text",
			key = "section",
			onNew = false,
			x = 44,
			baseline = 45,
			limit = 410,
			align = "left",
			font = {
				filename = "Noto Sans",
				size = 24,
			},
		}
	},
}

local SettingsList = {
	class = "SettingsListView",
	transform = transform,
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
		font = {
			filename = "Noto Sans",
			size = 24,
		},
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
			font = {
				filename = "Noto Sans",
				size = 24,
			},
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
			font = {
				filename = "Noto Sans",
				size = 24,
			},
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
			font = {
				filename = "Noto Sans",
				size = 24,
			},
		}
	},
}

local SectionsScrollBar = {
	class = "ScrollBarView",
	transform = transform,
	list = SectionsList,
	x = 263,
	y = 144,
	w = 16,
	h = 792,
	rows = 11,
	backgroundColor = {1, 1, 1, 0.33},
	color = {1, 1, 1, 0.66}
}

local BackgroundBlurSwitch = {
	class = "GaussianBlurView",
	blur = {key = "gameController.configModel.configs.settings.graphics.blur.select"}
}

local Background = {
	class = "BackgroundView",
	transform = transform,
	x = 0,
	y = 0,
	w = 1920,
	h = 1080,
	parallax = 0.01,
	dim = {key = "gameController.configModel.configs.settings.graphics.dim.select"},
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

local SettingsViewConfig = {
	BackgroundBlurSwitch,
	Background,
	BackgroundBlurSwitch,
	BottomScreenMenu,
	SectionsList,
	SettingsList,
	SectionsScrollBar,
	Rectangle,
	require("sphere.views.DebugInfoViewConfig"),
}

return SettingsViewConfig
