local CoordinateManager	= require("aqua.graphics.CoordinateManager")
local map				= require("aqua.math").map
local Class				= require("aqua.util.Class")

local PointGraphView = Class:new()

PointGraphView.load = function(self)
	local config = self.config
	local state = self.state

	state.cs = CoordinateManager:getCS(unpack(config.cs))
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

	love.graphics.setColor(config.color)
	local points = self.scoreSystem[config.field]
	for i = state.drawnPoints + 1, #points do
		self:drawPoint(points[i])
	end
	state.drawnPoints = #points

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
	local state = self.state

	local cs = state.cs

	love.graphics.setLineWidth(4)
	love.graphics.setLineStyle("smooth")
	love.graphics.line(
		cs:X(config.x, true),
		cs:Y(config.y + config.h / 2, true),
		cs:X(config.x + config.w, true),
		cs:Y(config.y + config.h / 2, true)
	)
end

PointGraphView.drawPoint = function(self, point)
	local config = self.config
	local state = self.state

	local x = point[config.time] / (state.endTime - state.startTime)
	local y = (point[config.value] + (config.offset or 0)) / (config.unit or 1)

	local cs = state.cs

	love.graphics.setCanvas(state.canvas)
	love.graphics.setLineWidth(4)
	love.graphics.setLineStyle("smooth")
	love.graphics.circle(
		"fill",
		cs:X(map(x, 0, 1, config.x, config.x + config.w), true),
		cs:Y(map(y, 0, 1, config.y, config.y + config.h), true),
		cs:X(config.r)
	)
	love.graphics.setCanvas()
end

return PointGraphView
