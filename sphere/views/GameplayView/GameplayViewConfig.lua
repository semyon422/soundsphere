local ScreenMenuView = require("sphere.views.ScreenMenuView")
local BackgroundView = require("sphere.views.BackgroundView")
local ValueView = require("sphere.views.ValueView")
local GaussianBlurView = require("sphere.views.GaussianBlurView")

local ProgressView	= require("sphere.views.GameplayView.ProgressView")

local transform = {{1 / 2, -16 / 9 / 2}, 0, 0, {0, 1 / 1080}, {0, 1 / 1080}, 0, 0, 0, 0}
local transformFull = {0, 0, 0, {1 / 1920, 0}, {0, 1 / 1080}, 0, 0, 0, 0}
local topCenter = {{1 / 2, 0}, 0, 0, {0, 1 / 1080}, {0, 1 / 1080}, 0, 0, 0, 0}

local PlayfieldView = {
	class = "PlayfieldView"
}

local BackgroundBlurSwitch = GaussianBlurView:new({
	blur = {key = "game.configModel.configs.settings.graphics.blur.gameplay"}
})

local Background = BackgroundView:new({
	transform = transform,
	x = 0,
	y = 0,
	w = 1920,
	h = 1080,
	parallax = 0.01,
	dim = {key = "game.configModel.configs.settings.graphics.dim.gameplay"},
})

local BottomScreenMenu = ScreenMenuView:new({
	subscreen = "pause",
	transform = transform,
	x = 279,
	y = 991,
	w = 227 * 6,
	h = 89,
	rows = 1,
	columns = 6,
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
				method = "play",
				displayName = "continue"
			},
			{},
			{},
			{},
			{
				method = "retry",
				displayName = "retry"
			},
			{
				method = "quit",
				displayName = "quit"
			},
		}
	}
})

local PauseProgressBar = ProgressView:new({
	current = {
		key = "game.rhythmModel.pauseManager.progress",
	},
	x = 0, y = 0, w = 1920, h = 20,
	color = {1, 1, 1, 1},
	transform = transformFull,
	direction = "left-right",
	mode = "+"
})

local PauseText = ValueView:new({
	subscreen = "pause",
	transform = transformFull,
	value = "pause",
	color = {1, 1, 1, 1},
	x = 64,
	baseline = 64,
	limit = 1920,
	align = "left",
	font = {
		filename = "Noto Sans",
		size = 40,
	},
})

local Notification = ValueView:new({
	transform = transform,
	key = "game.notificationModel.message",
	color = {1, 1, 1, 1},
	x = 733,
	baseline = 53,
	limit = 454,
	align = "center",
	font = {
		filename = "Noto Sans",
		size = 24,
	},
})

local Failed = ValueView:new({
	subscreen = "pause",
	value = function(self)
		if self.game.rhythmModel.scoreEngine.scoreSystem.hp.failed then
			return "failed"
		end
		return ""
	end,
	x = -1080, baseline = 540, limit = 2160,
	align = "center",
	color = {1, 1, 1, 0.25},
	font = {
		filename = "Noto Sans",
		size = 240
	},
	transform = topCenter
})

local GameplayViewConfig = {
	BackgroundBlurSwitch,
	Background,
	BackgroundBlurSwitch,
	PlayfieldView,
	BottomScreenMenu,
	PauseProgressBar,
	PauseText,
	Notification,
	Failed,
	require("sphere.views.DebugInfoViewConfig"),
}

return GameplayViewConfig
