local just = require("just")
local gfx_util = require("gfx_util")
local spherefonts = require("sphere.assets.fonts")

local Layout = require("sphere.views.EditorView.Layout")

local function Hotkeys(self)
	if just.keypressed("s") and love.keyboard.isDown("lctrl") then
		self.game.editorController:save()
		self.game.notificationModel:notify("saved")
	end
end

local function Notification(self)
	local w, h = Layout:move("header")

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.setFont(spherefonts.get("Noto Sans", 24))
	gfx_util.printFrame(self.game.notificationModel.message, 0, 0, w, h, "center", "center")
end

return function(self)
	Notification(self)
	Hotkeys(self)
end
