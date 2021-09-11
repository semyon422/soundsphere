
local transform = require("aqua.graphics.transform")
local map				= require("aqua.math").map
local Class				= require("aqua.util.Class")
local inside = require("aqua.util.inside")

local PointGraphView = Class:new()

PointGraphView.load = function(self)
	local state = self.state

	state.drawnPoints = 0
	state.drawnBackgroundPoints = 0

	state.startTime = self.noteChartModel.noteChart.metaData:get("minTime")
	state.endTime = self.noteChartModel.noteChart.metaData:get("maxTime")

	state.canvas = love.graphics.newCanvas()
	state.backgroundCanvas = love.graphics.newCanvas()
end

PointGraphView.draw = function(self)
	local state = self.state
	local config = self.config

	if config.show and not config.show(self) then
		return
	end

	if config.background then
		self:drawPoints("drawnBackgroundPoints", state.backgroundCanvas, config.backgroundColor, config.backgroundRadius)
	end
	self:drawPoints("drawnPoints", state.canvas, config.color, config.radius)

	love.graphics.origin()
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.draw(state.backgroundCanvas, 0, 0)
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

PointGraphView.drawPoints = function(self, counter, canvas, color, radius)
	local config = self.config
	local state = self.state

	local shader = love.graphics.getShader()
	love.graphics.setShader()
	love.graphics.setCanvas(canvas)

	love.graphics.replaceTransform(transform(config.transform))
	love.graphics.translate(config.x, config.y)

	local points = inside(self, config.key)
	for i = state[counter] + 1, #points do
		self:drawPoint(points[i], color, radius)
	end
	state[counter] = #points

	love.graphics.setCanvas()
	love.graphics.setShader(shader)
end

PointGraphView.drawPoint = function(self, point, color, radius)
	local config = self.config
	local state = self.state

	local time = inside(point, config.time)
	local value = inside(point, config.value)
	local unit = inside(point, config.unit)
	if type(time) == "nil" then
		time = tonumber(config.time) or 0
	end
	if type(value) == "nil" then
		value = tonumber(config.value) or 0
	end
	if type(unit) == "nil" then
		unit = tonumber(config.unit) or 1
	end

	if type(color) == "function" then
		color = color(time, state.startTime, state.endTime, value, unit)
	end
	love.graphics.setColor(color)

	if config.point then
		local x, y = config.point(time, state.startTime, state.endTime, value, unit)
		if not x then
			return
		end
		local _x, _y = map(x, 0, 1, 0, config.w), map(y, 0, 1, 0, config.h)
		love.graphics.rectangle("fill", _x - radius, _y - radius, radius * 2, radius * 2)
	elseif config.line then
		local x = config.line(time, state.startTime, state.endTime, value, unit)
		if not x then
			return
		end
		local _x = map(x, 0, 1, 0, config.w)
		love.graphics.rectangle("fill", _x - radius, 0, radius * 2, config.h)
	end
end

return PointGraphView
