
local transform = require("gfx_util").transform
local map = require("math_util").map
local gfx_util = require("gfx_util")
local Class = require("Class")

local PointGraphView = Class:new()

PointGraphView.startTime = 0
PointGraphView.endTime = 0

local vertexformat = {
    {"VertexPosition", "float", 2},
    {"VertexColor", "byte", 4}
}

PointGraphView.load = function(self)
	local noteChart = self.game.noteChartModel.noteChart
	if noteChart then
		self.startTime = noteChart.metaData:get("minTime")
		self.endTime = noteChart.metaData:get("maxTime")
	end

	self.drawnPoints = 0
	self.vertices = {}
	self.mesh = nil
	self:chechMesh(1)
end

PointGraphView.chechMesh = function(self, i)
	if not self.mesh then
		self.mesh = love.graphics.newMesh(vertexformat, 1, "points", "dynamic")
		return
	end
	local po2 = 2 ^ math.ceil(math.log(i) / math.log(2))
	if po2 > self.mesh:getVertexCount() then
		self.mesh = love.graphics.newMesh(vertexformat, po2, "points", "dynamic")
		self.mesh:setVertices(self.vertices)
	end
end

PointGraphView.draw = function(self)
	if self.show and not self.show(self) then
		return
	end

	self:drawPoints(self.color)

	local tf = transform(self.transform):translate(self.x, self.y)
	love.graphics.replaceTransform(tf)

	self.mesh:setDrawRange(1, self.drawnPoints)
	if self.backgroundRadius then
		local shader = love.graphics.getShader()
		gfx_util.setPixelColor(self.backgroundColor)
		love.graphics.setPointSize(self.backgroundRadius)
		love.graphics.draw(self.mesh)
		love.graphics.setShader(shader)
	end

	love.graphics.setPointSize(self.radius)
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.draw(self.mesh)

	love.graphics.setPointSize(1)
end

PointGraphView.receive = function(self, event)
	if event.name == "resize" then
		self:load()
	end
end

PointGraphView.getPoints = function(self) return {} end

PointGraphView.drawPoints = function(self, color)
	local points = self:getPoints()
	if points then
		for i = self.drawnPoints + 1, #points do
			self:drawPoint(i, points[i], color)
		end
	end
	self.drawnPoints = #points
end

PointGraphView.getTime = function(self, point) return 0 end
PointGraphView.getValue = function(self, point) return 0 end

PointGraphView.drawPoint = function(self, i, point, color)
	local time = self:getTime(point)
	local value = self:getValue(point)
	if not value then
		return
	end

	if type(color) == "function" then
		color = color(time, self.startTime, self.endTime, value)
	end

	local x, y = self.point(time, self.startTime, self.endTime, value)
	if not x then
		return
	end

	x = math.min(math.max(x, 0), 1)
	y = math.min(math.max(y, 0), 1)
	local _x = map(x, 0, 1, 0, self.w)
	local _y = map(y, 0, 1, 0, self.h)

	self:chechMesh(i)
	local vertex = {_x, _y, unpack(color)}
	self.mesh:setVertex(i, vertex)
	table.insert(self.vertices, vertex)
end

return PointGraphView
