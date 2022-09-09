local BackgroundView = require("sphere.views.BackgroundView")
local ValueView = require("sphere.views.ValueView")
local GaussianBlurView = require("sphere.views.GaussianBlurView")

local _transform = require("aqua.graphics.transform")
local just = require("just")
local spherefonts		= require("sphere.assets.fonts")

local TextButtonImView = require("sphere.imviews.TextButtonImView")

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

local BottomScreenMenu = {
	subscreen = "pause",
	draw = function(self)
		love.graphics.setFont(spherefonts.get("Noto Sans", 24))

		local tf = _transform(transform):translate(279, 991)
		love.graphics.replaceTransform(tf)

		local w, h = 227, 89

		just.row(true)
		if TextButtonImView("continue", "continue", w, h) then
			self.game.gameplayController:play()
		end
		just.indent(w * 3)
		if TextButtonImView("retry", "retry", w, h) then
			self.screenView:retry()
		end
		if TextButtonImView("quit", "quit", w, h) then
			self.screenView:quit()
		end
		just.row(false)
	end,
}

local PauseProgressBar = ProgressView:new({
	x = 0, y = 0, w = 1920, h = 20,
	color = {1, 1, 1, 1},
	transform = transformFull,
	direction = "left-right",
	mode = "+",
	getCurrent = function(self) return self.game.rhythmModel.pauseManager.progress end,
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
	font = {"Noto Sans", 40},
})

local Notification = ValueView:new({
	transform = transform,
	key = "game.notificationModel.message",
	color = {1, 1, 1, 1},
	x = 733,
	baseline = 53,
	limit = 454,
	align = "center",
	font = {"Noto Sans", 24},
})

local Failed = ValueView:new({
	subscreen = "pause",
	value = function(self)
		if self.game.rhythmModel.scoreEngine.scoreSystem.hp:isFailed() then
			return "failed"
		end
		return ""
	end,
	x = -1080, baseline = 540, limit = 2160,
	align = "center",
	color = {1, 1, 1, 0.25},
	font = {"Noto Sans", 240},
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
