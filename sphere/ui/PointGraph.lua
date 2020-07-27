local Circle			= require("aqua.graphics.Circle")
local CoordinateManager	= require("aqua.graphics.CoordinateManager")
local Image				= require("aqua.graphics.Image")
local Line				= require("aqua.graphics.Line")
local map				= require("aqua.math").map
local Class				= require("aqua.util.Class")

local PointGraph = Class:new()

PointGraph.loadGui = function(self)
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
	self.counterPath = self.data.counterPath

	self.scoreSystem = self.gui.scoreSystem
	self.noteChart = self.gui.noteChart
	self.container = self.gui.container
	
	self:load()
end

PointGraph.load = function(self)
	self.counter = self.scoreSystem:getCounter(self.counterPath)

	self.allcs = CoordinateManager:getCS(0, 0, 0, 0, "all")

	self.scoreSystem.observable:add(self)

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
	
	local hits = self.scoreSystem.scoreTable[self.counter.env.config.tableName] or {}
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

PointGraph.addPoint = function(self, x, y)
	love.graphics.setCanvas(self.canvas)
	local circle = self.circle
	
	circle.x = map(x, 0, 1, self.x, self.x + self.w)
	circle.y = map(y, 0, 1, self.y, self.y + self.h)
	circle:reload()
	circle:draw()
	
	love.graphics.setCanvas()
end

PointGraph.reload = function(self)
	self:unload()
	self:load()
end

PointGraph.unload = function(self)
	self.container:remove(self.image)
end

PointGraph.update = function(self) end

PointGraph.receive = function(self, event)
	if event.name == "resize" then
		self:reload()
	end

	if event.name ~= "ScoreNoteState" then
		return
	end

	local point = self.counter.env.getPoint(event)
	if point then
		self:addPoint(unpack(point))
	end
end

PointGraph.draw = function(self)
	self.image:draw()
end

return PointGraph
