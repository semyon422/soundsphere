
local transform = require("gfx_util").transform
local map				= require("math_util").map
local Class				= require("Class")
local inside = require("table_util").inside

local PointGraphView = Class:new()

PointGraphView.startTime = 0
PointGraphView.endTime = 0

PointGraphView.load = function(self)
	self.drawnPoints = 0
	self.drawnBackgroundPoints = 0

	local noteChart = self.game.noteChartModel.noteChart
	if noteChart then
		self.startTime = noteChart.metaData:get("minTime")
		self.endTime = noteChart.metaData:get("maxTime")
	end

	self.canvas = love.graphics.newCanvas()
	self.backgroundCanvas = love.graphics.newCanvas()
end

PointGraphView.draw = function(self)
	if self.show and not self.show(self) then
		return
	end

	if self.background then
		self:drawPoints("drawnBackgroundPoints", self.backgroundCanvas, self.backgroundColor, self.backgroundRadius)
	end
	self:drawPoints("drawnPoints", self.canvas, self.color, self.radius)

	love.graphics.origin()
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.draw(self.backgroundCanvas, 0, 0)
	love.graphics.draw(self.canvas, 0, 0)
end

PointGraphView.update = function(self, dt) end
PointGraphView.unload = function(self) end

PointGraphView.receive = function(self, event)
	if event.name == "resize" then
		self:reload()
	end
end

PointGraphView.reload = function(self)
	self:unload()
	self:load()
end

PointGraphView.getPoints = function(self) return {} end

PointGraphView.drawPoints = function(self, counter, canvas, color, radius)
	local shader = love.graphics.getShader()
	love.graphics.setShader()
	love.graphics.setCanvas(canvas)

	local tf = transform(self.transform):translate(self.x, self.y)
	love.graphics.replaceTransform(tf)

	local points = self:getPoints()
	if points then
		for i = self[counter] + 1, #points do
			self:drawPoint(points[i], color, radius)
		end
	end
	self[counter] = #points

	love.graphics.setCanvas()
	love.graphics.setShader(shader)
end

PointGraphView.getTime = function(self, point) return 0 end
PointGraphView.getValue = function(self, point) return 0 end

PointGraphView.drawPoint = function(self, point, color, radius)
	local time = self:getTime(point)
	local value = self:getValue(point)

	if type(color) == "function" then
		color = color(time, self.startTime, self.endTime, value)
	end
	love.graphics.setColor(color)

	if self.point then
		local x, y = self.point(time, self.startTime, self.endTime, value)
		if not x then
			return
		end
		x = math.min(math.max(x, 0), 1)
		y = math.min(math.max(y, 0), 1)
		local _x, _y = map(x, 0, 1, 0, self.w), map(y, 0, 1, 0, self.h)
		love.graphics.rectangle("fill", _x - radius, _y - radius, radius * 2, radius * 2)
	elseif self.line then
		local x = self.line(time, self.startTime, self.endTime, value)
		if not x then
			return
		end
		x = math.min(math.max(x, 0), 1)
		local _x = map(x, 0, 1, 0, self.w)
		love.graphics.rectangle("fill", _x - radius, 0, radius * 2, self.h)
	end
end

return PointGraphView
