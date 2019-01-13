local aquafonts = require("aqua.assets.fonts")
local CS = require("aqua.graphics.CS")

local Screen = require("sphere.screen.Screen")
local ScreenManager = require("sphere.screen.ScreenManager")
local TextTable = require("sphere.game.TextTable")
local spherefonts = require("sphere.assets.fonts")

local ResultScreen = Screen:new()

Screen.construct(ResultScreen)

ResultScreen.load = function(self)
	self.cs = self.cs or CS:new({
		bx = 0,
		by = 0,
		rx = 0,
		ry = 0,
		binding = "all",
		576
	})
	self.cs:reload()
	
	self.font = aquafonts.getFont(spherefonts.NotoSansRegular, 20)
	
	self.textTable = TextTable:new({
		text = "",
		x = 0.1, y = 0.1,
		w = 0.8, h = 0.8,
		cs = self.cs,
		rectangleColor = {0, 0, 0, 0},
		mode = "fill",
		limit = 1,
		textAlign = {x = "left", y = "top"},
		textColor = {255, 255, 255, 255},
		font = self.font
	})
	self.textTable:reload()
end

ResultScreen.unload = function(self)
end

ResultScreen.update = function(self)
	Screen.update(self)
	
	self.textTable:update()
end

ResultScreen.draw = function(self)
	Screen.draw(self)
	
	self.textTable:draw()
end

ResultScreen.receive = function(self, event)
	if event.name == "resize" then
		self.cs:reload()
	elseif event.name == "keypressed" and event.args[1] == "escape" then
		ScreenManager:set(require("sphere.screen.SelectionScreen"))
	end
	
	self.textTable:receive(event)
	
	if event.name == "score" then
		self.textTable:setTable({
			{"maxcombo", event.score.maxcombo}
		})
	end
end

return ResultScreen
