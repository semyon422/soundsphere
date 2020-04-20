local Circle			= require("aqua.graphics.Circle")
local CoordinateManager	= require("aqua.graphics.CoordinateManager")
local Image				= require("aqua.graphics.Image")
local Line				= require("aqua.graphics.Line")
local map				= require("aqua.math").map
local Class				= require("aqua.util.Class")

local AccuracyGraph = Class:new()

AccuracyGraph.loadGui = function(self)
	self.cs = CoordinateManager:getCS(unpack(self.data.cs))
	self.x = self.data.x
	self.y = self.data.y
	self.w = self.data.w
	self.h = self.data.h
	self.r = self.data.r
	self.layer = self.data.layer
	self.lineColor = self.data.lineColor
	self.color = self.data.color
	self.blendMode = self.data.blendMode
	self.blendAlphaMode = self.data.blendAlphaMode

	self.score = self.gui.score
	self.container = self.gui.container
	
	self:load()
end

AccuracyGraph.load = function(self)
	self.allcs = CoordinateManager:getCS(0, 0, 0, 0, "all")

	self.score.observable:add(self)

	self.canvas = love.graphics.newCanvas()
	
	love.graphics.setCanvas(self.canvas)
	local line = Line:new({
		points = {self.x, self.y + self.h / 2, self.x + self.w, self.y + self.h / 2},
		cs = self.cs,
		color = self.lineColor,
		lineStyle = "smooth",
		lineWidth = 4
	})
	line:reload()
	line:draw()
	love.graphics.setCanvas()
	
	self.circle = Circle:new({
		x = 0, y = 0, r = self.r,
		color = self.color,
		mode = "fill",
		cs = self.cs
	})
	
	self.minTime = self.score.noteChart.metaData:get("minTime")
	self.maxTime = self.score.noteChart.metaData:get("maxTime")
	local hits = self.score.scoreTable.hits or {}
	for _, point in ipairs(hits) do
		self:addPoint(point[1], point[2])
	end
	
	self.image = Image:new({
		x = 0, y = 0,
		cs = self.allcs,
		layer = self.layer,
		blendMode = self.blendMode,
		blendAlphaMode = self.blendAlphaMode,
		image = self.canvas
	})
	self.image:reload()
	
	self.container:add(self.image)
end

AccuracyGraph.addPoint = function(self, time, deltaTime)
	love.graphics.setCanvas(self.canvas)
	local circle = self.circle
	
	circle.x = map(time, self.minTime, self.maxTime, self.x, self.x + self.w)
	circle.y = map(0.5 + deltaTime * 3, 0, 1, self.y, self.y + self.h)
	circle:reload()
	circle:draw()
	
	love.graphics.setCanvas()
end

AccuracyGraph.reload = function(self)
	self:unload()
	self:load()
end

AccuracyGraph.unload = function(self)
	self.container:remove(self.image)
end

AccuracyGraph.update = function(self) end

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
