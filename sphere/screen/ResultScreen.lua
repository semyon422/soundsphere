local CS = require("aqua.graphics.CS")
local Screen = require("sphere.screen.Screen")
local ScreenManager = require("sphere.screen.ScreenManager")
local AccuracyGraph = require("sphere.ui.AccuracyGraph")
local JudgeTable = require("sphere.ui.JudgeTable")
local MetaDataTable = require("sphere.ui.MetaDataTable")
local ScoreManager = require("sphere.game.ScoreManager")

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
	
	self.accuracyGraph = AccuracyGraph:new({
		cs = self.cs
	})
	
	self.judgeTable = JudgeTable:new({
		cs = self.cs
	})
end

ResultScreen.unload = function(self)
end

ResultScreen.update = function(self)
	Screen.update(self)
end

ResultScreen.draw = function(self)
	Screen.draw(self)
	
	MetaDataTable:draw()
	self.accuracyGraph:draw()
	self.judgeTable:draw()
end

ResultScreen.receive = function(self, event)
	if event.name == "resize" then
		self.cs:reload()
		
		MetaDataTable:reload()
		self.accuracyGraph:reload()
		self.judgeTable:reload()
	elseif event.name == "keypressed" and event.args[1] == "escape" then
		ScreenManager:set(require("sphere.screen.SelectionScreen"))
	end
	
	if event.name == "score" then
		local score = event.score
		
		self.accuracyGraph.score = score
		self.accuracyGraph:load()
		
		self.judgeTable.score = score
		self.judgeTable:load()
		
		ScoreManager:insertScore(score.noteChart.hash, score.score, score.accuracy)
	end
	
	if event.name == "metadata" then
		MetaDataTable:setData(event.data)
	end
end

return ResultScreen
