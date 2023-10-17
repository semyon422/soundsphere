local Layout = require("sphere.views.GameplayView.Layout")
local gfx_util = require("gfx_util")
local just = require("just")
local spherefonts = require("sphere.assets.fonts")
local imgui = require("imgui")

local RectangleProgressView = require("sphere.views.GameplayView.RectangleProgressView")

local transformFull = {0, 0, 0, {1 / 1920, 0}, {0, 1 / 1080}, 0, 0, 0, 0}

local PauseProgressBar = RectangleProgressView({
	x = 0, y = 0, w = 1920, h = 20,
	color = {1, 1, 1, 1},
	transform = transformFull,
	direction = "left-right",
	mode = "+",
	getCurrent = function(self) return self.game.pauseModel.progress end,
})

---@param self table
local function Notification(self)
	local w, h = Layout:move("header")

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.setFont(spherefonts.get("Noto Sans", 24))
	gfx_util.printFrame(self.game.notificationModel.message, 0, 0, w, h, "center", "center")
end

---@param t number
---@return string
local function to_ms(t)
	return math.floor(t * 1000) .. "ms"
end

---@param self table
local function DebugMenu(self)
	if not self.game.configModel.configs.settings.miscellaneous.showDebugMenu then
		return
	end

	local w, h = Layout:move("header")

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.setFont(spherefonts.get("Noto Sans", 24))
	love.graphics.setLineStyle("smooth")

	local lineHeight = 55
	imgui.setSize(400, h, 200, lineHeight)
	love.graphics.setColor(1, 1, 1, 1)

	local rhythmModel = self.game.rhythmModel
	local offsync, minOffsync, maxOffsync = rhythmModel.timeEngine.timer:getAudioOffsync()
	if offsync then
		imgui.text("Offsync:")
		love.graphics.setFont(spherefonts.get("Noto Sans Mono", 24))
		just.sameline()
		imgui.text(("%5s (%5s %5s)"):format(to_ms(offsync), to_ms(minOffsync - offsync), to_ms(maxOffsync - offsync)))
		love.graphics.setFont(spherefonts.get("Noto Sans", 24))
	end
end

return function(self)
	PauseProgressBar.game = self.game
	PauseProgressBar:draw()
	Notification(self)
	DebugMenu(self)
end
