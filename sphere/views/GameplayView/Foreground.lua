local Layout = require("sphere.views.GameplayView.Layout")
local gfx_util = require("gfx_util")

local ProgressView	= require("sphere.views.GameplayView.ProgressView")

local transformFull = {0, 0, 0, {1 / 1920, 0}, {0, 1 / 1080}, 0, 0, 0, 0}
local spherefonts		= require("sphere.assets.fonts")

local PauseProgressBar = ProgressView:new({
	x = 0, y = 0, w = 1920, h = 20,
	color = {1, 1, 1, 1},
	transform = transformFull,
	direction = "left-right",
	mode = "+",
	getCurrent = function(self) return self.game.rhythmModel.pauseManager.progress end,
})

local function Notification(self)
	local w, h = Layout:move("header")

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.setFont(spherefonts.get("Noto Sans", 24))
	gfx_util.printFrame(self.game.notificationModel.message, 0, 0, w, h, "center", "center")
end

return function(self)
	PauseProgressBar.game = self.game
	PauseProgressBar:draw()
	Notification(self)
end
