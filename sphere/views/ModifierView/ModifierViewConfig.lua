
local screen = {
	w = 1920,
	h = 1080
}

local AvailableModifierList = {
	class = "AvailableModifierListView",
	screen = screen,
	x = 279,
	y = 144,
	w = 454,
	h = 792,
	rows = 11,
	name = {
		x = 0,
		y = 16,
		w = 190,
		h = 31,
		align = "left",
		fontSize = 24,
		fontFamily = "Noto Sans"
	}
}

local ModifierList = {
	class = "ModifierListView",
	screen = screen,
	x = 733,
	y = 144,
	w = 454,
	h = 792,
	rows = 11,
	scroll = {
		x = 0,
		y = 0,
		w = 277,
		h = 792
	},
	name = {
		x = 0,
		y = 16,
		w = 227,
		h = 31,
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
			y = 16,
			w = 227,
			h = 31,
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
			y = 16,
			w = 227,
			h = 31,
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

local ModifierViewConfig = {
	Background,
	AvailableModifierList,
	ModifierList
}

return ModifierViewConfig
