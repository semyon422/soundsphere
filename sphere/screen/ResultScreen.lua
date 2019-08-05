local CoordinateManager = require("aqua.graphics.CoordinateManager")
local Screen = require("sphere.screen.Screen")
local ScreenManager = require("sphere.screen.ScreenManager")
local AccuracyGraph = require("sphere.ui.AccuracyGraph")
local JudgeTable = require("sphere.ui.JudgeTable")
local MetaDataTable = require("sphere.ui.MetaDataTable")
local ScoreManager = require("sphere.game.ScoreManager")

local ResultScreen = Screen:new()

Screen.construct(ResultScreen)

ResultScreen.load = function(self)
	self.cs = CoordinateManager:getCS(0, 0, 0, 0, "all")
	
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
		
		if not score.autoplay and score.score > 0 then
			ScoreManager:insertScore(score)
		end
	end
	
	if event.name == "metadata" then
		MetaDataTable:setData(event.data)
	end
end

return ResultScreen
