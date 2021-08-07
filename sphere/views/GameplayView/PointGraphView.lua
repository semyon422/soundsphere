
local transform = require("aqua.graphics.transform")
local map				= require("aqua.math").map
local Class				= require("aqua.util.Class")

local PointGraphView = Class:new()

PointGraphView.load = function(self)
	local state = self.state

	state.drawnPoints = 0

	state.startTime = self.noteChartModel.noteChart.metaData:get("minTime")
	state.endTime = self.noteChartModel.noteChart.metaData:get("maxTime")

	-- self.scoreSystem.observable:add(self)

	state.canvas = love.graphics.newCanvas()
end

PointGraphView.draw = function(self)
	local config = self.config
	local state = self.state

	love.graphics.setColor(config.lineColor)
	self:drawLine()

	self:drawPoints()

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

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.setLineWidth(2)
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
	love.graphics.setLineWidth(1)
	love.graphics.setLineStyle("smooth")

	local points = self.scoreSystem[config.field]
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

	love.graphics.replaceTransform(transform(config.transform))
	love.graphics.translate(config.x, config.y)

	local x = point[config.time] / (state.endTime - state.startTime)
	local y = (point[config.value] + (config.offset or 0)) / (config.unit or 1)

	love.graphics.circle(
		"fill",
		map(x, 0, 1, 0, config.w),
		map(y, 0, 1, 0, config.h),
		config.r
	)
end

return PointGraphView
