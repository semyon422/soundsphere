
local transform = require("aqua.graphics.transform")
local map				= require("aqua.math").map
local Class				= require("aqua.util.Class")
local inside = require("aqua.util.inside")

local PointGraphView = Class:new()

PointGraphView.load = function(self)
	local state = self.state

	state.drawnPoints = 0

	state.startTime = self.noteChartModel.noteChart.metaData:get("minTime")
	state.endTime = self.noteChartModel.noteChart.metaData:get("maxTime")

	state.canvas = love.graphics.newCanvas()
end

PointGraphView.draw = function(self)
	local state = self.state
	local config = self.config

	if config.show and not config.show(self) then
		return
	end

	self:drawLine()
	self:drawPoints()

	love.graphics.origin()
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.draw(state.canvas, 0, 0)
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

PointGraphView.drawLine = function(self)
	local config = self.config

	love.graphics.replaceTransform(transform(config.transform))
	love.graphics.translate(config.x, config.y)

	love.graphics.setColor(config.lineColor)
	love.graphics.setLineWidth(config.lineWidth)
	love.graphics.setLineStyle("smooth")
	love.graphics.line(0, config.h / 2, config.w, config.h / 2)
end

PointGraphView.drawPoints = function(self)
	local config = self.config
	local state = self.state

	local shader = love.graphics.getShader()
	love.graphics.setShader()
	love.graphics.setCanvas(state.canvas)

	love.graphics.setColor(config.color)
	love.graphics.setLineWidth(config.pointLineWidth)
	love.graphics.setLineStyle("smooth")

	love.graphics.replaceTransform(transform(config.transform))
	love.graphics.translate(config.x, config.y)

	local points = inside(self, config.field)
	for i = state.drawnPoints + 1, #points do
		self:drawPoint(points[i])
	end
	state.drawnPoints = #points

	love.graphics.setCanvas()
	love.graphics.setShader(shader)
end

PointGraphView.drawPoint = function(self, point)
	local config = self.config
	local state = self.state

	local time = inside(point, config.time)
	local value = inside(point, config.value)
	local unit = inside(point, config.unit)

	local x, y = config.point(time, state.startTime, state.endTime, value, unit)

	local _x, _y = map(x, 0, 1, 0, config.w), map(y, 0, 1, 0, config.h)
	love.graphics.circle("fill", _x, _y, config.r)
	love.graphics.circle("line", _x, _y, config.r)
end

return PointGraphView
