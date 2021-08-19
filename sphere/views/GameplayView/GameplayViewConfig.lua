local transform = {{1 / 2, -16 / 9 / 2}, 0, 0, {0, 1 / 1080}, {0, 1 / 1080}, 0, 0, 0, 0}

local PlayfieldView = {
	class = "PlayfieldView"
}

local Background = {
	class = "BackgroundView",
	transform = transform,
	x = 0,
	y = 0,
	w = 1920,
	h = 1080,
	parallax = 0.01,
	dim = 0.5
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
	screens = {
		{
			{
				name = "Select",
				displayName = "back"
			}
		}
	}
}

local GameplayViewConfig = {
	Background,
	PlayfieldView,
	BottomScreenMenu,
}

return GameplayViewConfig
