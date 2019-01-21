local aquafonts = require("aqua.assets.fonts")
local CS = require("aqua.graphics.CS")
local TextFrame = require("aqua.graphics.TextFrame")
local AudioManager = require("aqua.audio.AudioManager")

local Screen = require("sphere.screen.Screen")
local ScreenManager = require("sphere.screen.ScreenManager")
local TextTable = require("sphere.game.TextTable")
local AccuracyGraph = require("sphere.game.AccuracyGraph")
local JudgeTable = require("sphere.game.JudgeTable")
local MetaDataTable = require("sphere.ui.MetaDataTable")
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
		baseOne = 768
	})
	self.cs:reload()
	
	self.resultText = TextFrame:new({
		text = "Result",
		x = 0.1, y = 0.15,
		w = 1, h = 0.1,
		cs = self.cs,
		limit = 1,
		align = {x = "left", "center"},
		color = {255, 255, 255, 255},
		font = aquafonts.getFont(spherefonts.NotoSansRegular, 48)
	})
	self.resultText:reload()
	
	self.accuracyGraph = AccuracyGraph:new({
		cs = self.cs
	})
	
	self.judgeTable = JudgeTable:new({
		cs = self.cs
	})
	
	self.metaDataTable = MetaDataTable:new({
		cs = self.cs
	})
end

ResultScreen.unload = function(self)
	AudioManager:stop()
end

ResultScreen.update = function(self)
	Screen.update(self)
end

ResultScreen.draw = function(self)
	Screen.draw(self)
	
	self.resultText:draw()
	self.metaDataTable:draw()
	self.accuracyGraph:draw()
	self.judgeTable:draw()
end

ResultScreen.receive = function(self, event)
	if event.name == "resize" then
		self.cs:reload()
		
		self.resultText:reload()
		self.metaDataTable:reload()
		self.accuracyGraph:reload()
		self.judgeTable:reload()
	elseif event.name == "keypressed" and event.args[1] == "escape" then
		ScreenManager:set(require("sphere.screen.SelectionScreen"))
	end
	
	if event.name == "score" then
		self.accuracyGraph.score = event.score
		self.accuracyGraph:load()
		
		self.judgeTable.score = event.score
		self.judgeTable:load()
	end
	
	if event.name == "metadata" then
		self.metaDataTable.data = event.data
		self.metaDataTable:load()
	end
end

return ResultScreen
