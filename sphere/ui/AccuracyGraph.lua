local Class = require("aqua.util.Class")
local Line = require("aqua.graphics.Line")
local Circle = require("aqua.graphics.Circle")
local Image = require("aqua.graphics.Image")
local map = require("aqua.math").map
local CoordinateManager = require("aqua.graphics.CoordinateManager")

local AccuracyGraph = Class:new()

AccuracyGraph.cs = CoordinateManager:getCS(0, 0, 0, 0, "all")

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
	
	local circle = Circle:new({
		x = 0, y = 0, r = 1/360,
		color = {63, 255, 127, 255},
		mode = "fill",
		cs = self.cs
	})
	
	local minTime = self.score.noteChart:hashGet("minTime")
	local maxTime = self.score.noteChart:hashGet("maxTime")
	for _, point in ipairs(self.score.hits) do
		circle.x = map(point[1], minTime, maxTime, 0, 1)
		circle.y = 0.5 + point[2] * 3
		circle:reload()
		circle:draw()
	end
	
	love.graphics.setCanvas()
	
	self.image = Image:new({
		x = 0, y = 0,
		cs = self.cs,
		image = self.canvas
	})
	self.image:reload()
end

AccuracyGraph.reload = function(self)
	self:load()
end

AccuracyGraph.draw = function(self)
	self.image:draw()
end

return AccuracyGraph
