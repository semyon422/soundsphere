local Class = require("aqua.util.Class")
local Profiler = require("aqua.util.Profiler")
local spherefonts = require("sphere.assets.fonts")

local FrameTimeView = Class:new()

FrameTimeView.visible = false
FrameTimeView.profiler = false
FrameTimeView.scale = 1
FrameTimeView.updateFrameTime = 0.001
FrameTimeView.drawFrameTime = 0.001
FrameTimeView.receiveFrameTime = 0.001

FrameTimeView.load = function(self)
	self.canvas1 = love.graphics.newCanvas()
	self.canvas2 = love.graphics.newCanvas()

	self.width = love.graphics.getWidth()
	self.height = love.graphics.getHeight()

	self.font = spherefonts.get("Noto Sans Mono", 20)
	self.largeFont = spherefonts.get("Noto Sans Mono", 40)
end

local colors = {
	white = {1, 1, 1, 1},
	blue = {0.25, 0.25, 1, 1},
	gray = {0.25, 0.25, 0.25, 1},
	yellow = {1, 1, 0.25, 1}
}

FrameTimeView.draw = function(self)
	if not self.visible then
		return
	end

	love.graphics.setCanvas(self.canvas1)
	love.graphics.setLineStyle("rough")
	love.graphics.setLineWidth(1)

	local y = self.height - 0.5
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.line(0.5, y, 0.5, y - love.timer.getDelta() * 1000 * self.scale)

	love.graphics.setColor(colors.blue)
	love.graphics.line(0.5, y, 0.5, y - self.receiveFrameTime * 1000 * self.scale)

	y = y - self.receiveFrameTime * 1000 * self.scale
	love.graphics.setColor(colors.gray, 1)
	love.graphics.line(0.5, y, 0.5, y - self.updateFrameTime * 1000 * self.scale)

	y = y - self.updateFrameTime * 1000 * self.scale
	love.graphics.setColor(colors.yellow)
	love.graphics.line(0.5, y, 0.5, y - self.drawFrameTime * 1000 * self.scale)

	love.graphics.setCanvas()

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.setCanvas(self.canvas2)
	love.graphics.clear()
	love.graphics.draw(self.canvas1, 1, 0)
	love.graphics.setCanvas()

	love.graphics.draw(self.canvas2, 1, 0)
	self:drawGrid()
	self:drawMouse()
	self:drawFPS()

	self.canvas1, self.canvas2 = self.canvas2, self.canvas1
end

local fps = {60, 120, 240, 480, 960}
FrameTimeView.drawGrid = function(self)
	love.graphics.setLineStyle("rough")
	love.graphics.setLineWidth(4)

	for i = 1, #fps do
		local y = self.height - 0.5 - 1 / fps[i] * 1000 * self.scale

		love.graphics.setColor(0, 0, 0, 0.75)
		love.graphics.rectangle("fill", self.width - 250, y, 250, 30)

		love.graphics.setColor(0.25, 1, 0.75, 1)
		love.graphics.setFont(self.font)
		love.graphics.printf(("%3.2fms (%dfps)"):format(1 / fps[i] * 1000, fps[i]), 0, y, self.width, "right")

		love.graphics.setColor(1, 0.25, 0.25, 1)
		love.graphics.line(0, y, self.width, y)
	end
end

FrameTimeView.drawMouse = function(self)
	local x, y = love.mouse.getPosition()
	local frameTime = -(y - self.height) / self.scale / 1000
	local fpsValue = 1 / frameTime

	love.graphics.setColor(0, 0, 0, 0.75)
	love.graphics.rectangle("fill", x - 250, y, 250, 30)

	love.graphics.setColor(0.25, 1, 0.75, 1)
	love.graphics.setFont(self.font)
	love.graphics.printf(("%3.2fms (%dfps)"):format(frameTime * 1000, fpsValue), x - 250, y, self.width, "left")
end

local colorText = {
	colors.white, "dt ",
	colors.blue, "receive ",
	colors.gray, "update ",
	colors.yellow, "draw "
}

FrameTimeView.drawFPS = function(self)
	local frameTime = love.timer.getDelta()

	love.graphics.setColor(0, 0, 0, 0.75)
	love.graphics.rectangle("fill", 0, 0, self.width, 60)

	love.graphics.setColor(0.25, 1, 0.75, 1)
	love.graphics.setFont(self.largeFont)
	love.graphics.printf(("%3.2fms (%dfps)"):format(frameTime * 1000, 1 / frameTime), 0, 0, self.width, "left")

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.setFont(self.font)
	love.graphics.printf(colorText, 0, 0, self.width, "right")

	if self.profiler then
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.setFont(self.largeFont)
		love.graphics.printf("Profiler enabled", 0, 0, self.width, "center")
	end
end

FrameTimeView.receive = function(self, event)
	if event.name == "keypressed" and event[1] == "rctrl" and love.keyboard.isDown("lctrl") then
		self.visible = not self.visible
		self:load()
	end
	if not self.visible then
		return
	end

	if event.name == "keypressed" then
		return self:keypressed(event[1])
	end
	if event.name == "wheelmoved" then
		return self:wheelmoved(event[2])
	end
end

FrameTimeView.keypressed = function(self, key)
	if key == "up" then
		self.scale = self.scale * 2
	elseif key == "down" then
		self.scale = self.scale / 2
	elseif key == "lshift" then
		if self.profiler then
			Profiler:stop()
		else
			Profiler:start()
		end
		self.profiler = not self.profiler
	end
end

FrameTimeView.wheelmoved = function(self, y)
	if y == 1 then
		self.scale = self.scale * 2
	elseif y == -1 then
		self.scale = self.scale / 2
	end
end

return FrameTimeView
