local Layout = require("sphere.views.GameplayView.Layout")

local gfx_util = require("gfx_util")
local just = require("just")
local spherefonts = require("sphere.assets.fonts")
local imgui = require("imgui")

local function BottomScreenMenu(self)
	love.graphics.setFont(spherefonts.get("Noto Sans", 24))

	local w, h = Layout:move("footer")
	w = 279

	just.row(true)
	if imgui.TextOnlyButton("continue", "continue", w, h) then
		self.game.gameplayController:play()
	end
	if imgui.TextOnlyButton("retry", "retry", w, h) then
		self:retry()
	end
	if imgui.TextOnlyButton("quit", "quit", w, h) then
		self:quit()
	end
	just.row()
end

local function FailedText(self)
	if not self.game.rhythmModel.scoreEngine.scoreSystem.hp:isFailed() then
		return
	end
	local w, h = Layout:move("base")
	love.graphics.setColor(1, 1, 1, 0.25)
	love.graphics.setFont(spherefonts.get("Noto Sans", 240))
	gfx_util.printFrame("failed", 0, 0, w, h, "center", "center")
end

return function(self)
	BottomScreenMenu(self)
	FailedText(self)
end
