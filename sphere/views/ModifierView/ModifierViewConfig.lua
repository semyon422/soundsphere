
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
	text = {
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
	text = {
		x = 0,
		y = 16,
		w = 190,
		h = 31,
		align = "left",
		fontSize = 24,
		fontFamily = "Noto Sans"
	}
}

local ModifierViewConfig = {
	AvailableModifierList,
	ModifierList
}

return ModifierViewConfig
