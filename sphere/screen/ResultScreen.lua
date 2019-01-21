local aquafonts = require("aqua.assets.fonts")
local CS = require("aqua.graphics.CS")
local TextFrame = require("aqua.graphics.TextFrame")
local AudioManager = require("aqua.audio.AudioManager")

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
		baseOne = 768
	})
	self.cs:reload()
	
	self.resultText = TextFrame:new({
		text = "Result",
		x = 0, y = 0.05,
		w = 1, h = 0.1,
		cs = self.cs,
		limit = 1,
		align = {x = "center", "center"},
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
end

ResultScreen.unload = function(self)
	AudioManager:stop()
end

ResultScreen.update = function(self)
	Screen.update(self)
	
	self.resultText:update()
end

ResultScreen.draw = function(self)
	Screen.draw(self)
	
	self.resultText:draw()
		
	self.accuracyGraph:draw()
	self.judgeTable:draw()
end

ResultScreen.receive = function(self, event)
	if event.name == "resize" then
		self.cs:reload()
		
		self.resultText:reload()
		
		self.accuracyGraph:reload()
		self.judgeTable:reload()
	elseif event.name == "keypressed" and event.args[1] == "escape" then
		ScreenManager:set(require("sphere.screen.SelectionScreen"))
	end
	
	-- self.textTable:receive(event)
	
	if event.name == "score" then
		-- self.textTable:setTable({
			-- {"maxcombo", event.score.maxcombo}
		-- })
		self.accuracyGraph.score = event.score
		self.accuracyGraph:load()
		
		self.judgeTable.score = event.score
		self.judgeTable:load()
	end
end

return ResultScreen
