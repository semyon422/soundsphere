local aquafonts = require("aqua.assets.fonts")
local CS = require("aqua.graphics.CS")
local TextFrame = require("aqua.graphics.TextFrame")

local Screen = require("sphere.screen.Screen")
local ScreenManager = require("sphere.screen.ScreenManager")
local TextTable = require("sphere.game.TextTable")
local AccuracyGraph = require("sphere.game.AccuracyGraph")
local JudgeTable = require("sphere.game.JudgeTable")
local spherefonts = require("sphere.assets.fonts")

local ResultScreen = Screen:new()

Screen.construct(ResultScreen)

ResultScreen.load = function(self)
	self.cs = CS:new({
		bx = 0,
		by = 0,
		rx = 0,
		ry = 0,
		binding = "all",
		576
	})
	self.cs:reload()
	
	self.title = TextFrame:new({
		text = "Result screen",
		x = 0, y = 0.1,
		w = 1, h = 0.1,
		cs = self.cs,
		limit = 1,
		align = {x = "center", "center"},
		color = {255, 255, 255, 255},
		font = aquafonts.getFont(spherefonts.NotoSansRegular, 22)
	})
	self.title:reload()
	
	self.textTable = TextTable:new({
		text = "",
		x = 0.1, y = 0.2,
		w = 0.8, h = 0.8,
		cs = self.cs,
		rectangleColor = {0, 0, 0, 0},
		mode = "fill",
		limit = 1,
		textAlign = {x = "left", y = "top"},
		textColor = {255, 255, 255, 255},
		font = aquafonts.getFont(spherefonts.NotoSansRegular, 16)
	})
	self.textTable:reload()
	
	self.accuracyGraph = AccuracyGraph:new({
		cs = self.cs
	})
	self.accuracyGraph:load()
	
	self.judgeTable = JudgeTable:new({
		cs = self.cs
	})
end

ResultScreen.unload = function(self)
end

ResultScreen.update = function(self)
	Screen.update(self)
	
	self.title:update()
	self.textTable:update()
end

ResultScreen.draw = function(self)
	Screen.draw(self)
	
	self.title:draw()
	self.textTable:draw()
	self.accuracyGraph:draw()
	self.judgeTable:draw()
end

ResultScreen.receive = function(self, event)
	if event.name == "resize" then
		self.cs:reload()
		self.title:reload()
		self.textTable:reload()
		self.accuracyGraph:reload()
	elseif event.name == "keypressed" and event.args[1] == "escape" then
		ScreenManager:set(require("sphere.screen.SelectionScreen"))
	end
	
	self.textTable:receive(event)
	
	if event.name == "score" then
		self.textTable:setTable({
			{"maxcombo", event.score.maxcombo}
		})
		self.accuracyGraph.score = event.score
		self.accuracyGraph:compute()
		
		self.judgeTable.score = event.score
		self.judgeTable:load()
	end
end

return ResultScreen
