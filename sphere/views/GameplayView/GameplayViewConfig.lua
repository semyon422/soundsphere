local transform = {{1 / 2, -16 / 9 / 2}, 0, 0, {0, 1 / 1080}, {0, 1 / 1080}, 0, 0, 0, 0}
local transformFull = {0, 0, 0, {1 / 1920, 0}, {0, 1 / 1080}, 0, 0, 0, 0}

local PlayfieldView = {
	class = "PlayfieldView"
}

local BackgroundBlurSwitch = {
	class = "GaussianBlurView",
	blur = {key = "settings.graphics.blur.gameplay"}
}

local Background = {
	class = "BackgroundView",
	transform = transform,
	x = 0,
	y = 0,
	w = 1920,
	h = 1080,
	parallax = 0.01,
	dim = {key = "settings.graphics.dim.gameplay"},
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

local PauseProgressBar = {
	class = "ProgressView",
	current = {
		key = "rhythmModel.pauseManager.progress",
	},
	x = 0, y = 0, w = 1920, h = 20,
	color = {1, 1, 1, 1},
	transform = transformFull,
	direction = "left-right",
	mode = "+"
}

local PauseText = {
	class = "ValueView",
	subscreen = "pause",
	transform = transformFull,
	value = "pause",
	color = {1, 1, 1, 1},
	x = 64,
	baseline = 64,
	limit = 1920,
	align = "left",
	fontSize = 40,
	fontFamily = "Noto Sans",
}

local GameplayViewConfig = {
	BackgroundBlurSwitch,
	Background,
	BackgroundBlurSwitch,
	PlayfieldView,
	BottomScreenMenu,
	PauseProgressBar,
	PauseText,
}

return GameplayViewConfig
