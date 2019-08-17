local Circle			= require("aqua.graphics.Circle")
local CoordinateManager	= require("aqua.graphics.CoordinateManager")
local Image				= require("aqua.graphics.Image")
local Line				= require("aqua.graphics.Line")
local map				= require("aqua.math").map
local Class				= require("aqua.util.Class")
local Score				= require("sphere.screen.gameplay.CloudburstEngine.Score")

local AccuracyGraph = Class:new()

AccuracyGraph.init = function(self)
	Score.observable:add(AccuracyGraph)
	self.cs = CoordinateManager:getCS(0, 0, 0, 0, "all")
end

AccuracyGraph.load = function(self)
	self.canvas = love.graphics.newCanvas()
	
	love.graphics.setCanvas(self.canvas)
	local line = Line:new({
		points = {0, 0.5, 1, 0.5},
		cs = self.cs,
		color = {255, 255, 255, 127},
		lineStyle = "smooth",
		lineWidth = 4
	})
	line:reload()
	line:draw()
	love.graphics.setCanvas()
	
	self.circle = Circle:new({
		x = 0, y = 0, r = 1/360,
		color = {0, 127, 63, 255},
		mode = "fill",
		cs = self.cs
	})
	
	self.minTime = self.score.noteChart:hashGet("minTime")
	self.maxTime = self.score.noteChart:hashGet("maxTime")
	for _, point in ipairs(self.score.hits) do
		self:addPoint(point[1], point[2])
	end
	
	self.image = Image:new({
		x = 0, y = 0,
		cs = self.cs,
		image = self.canvas
	})
	self.image:reload()
end

AccuracyGraph.addPoint = function(self, time, deltaTime)
	love.graphics.setCanvas(self.canvas)
	local circle = self.circle
	
	circle.x = map(time, self.minTime, self.maxTime, 0, 1)
	circle.y = 0.5 + deltaTime * 3
	circle:reload()
	circle:draw()
	
	love.graphics.setCanvas()
end

AccuracyGraph.reload = function(self)
	self:load()
end

AccuracyGraph.receive = function(self, event)
	if event.name == "resize" then
		self:reload()
	elseif event.name == "hit" then
		self:addPoint(event.time, event.deltaTime)
	end
end

AccuracyGraph.draw = function(self)
	self.image:draw()
end

return AccuracyGraph
