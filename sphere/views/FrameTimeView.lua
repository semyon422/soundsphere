local Class = require("aqua.util.Class")
local Profiler = require("aqua.util.Profiler")
local spherefonts = require("sphere.assets.fonts")
local aquaevent = require("aqua.event")
local just = require("just")
local TextButtonImView = require("sphere.views.TextButtonImView")

local FrameTimeView = Class:new()

FrameTimeView.visible = false
FrameTimeView.profiler = false
FrameTimeView.scale = 1

FrameTimeView.load = function(self)
	self.smallFont = spherefonts.get("Noto Sans Mono", 14)
	self.font = spherefonts.get("Noto Sans Mono", 20)
	self.largeFont = spherefonts.get("Noto Sans Mono", 40)
end

FrameTimeView.checkCanvas = function(self)
	local w, h = love.graphics.getDimensions()
	if self.width ~= w or self.height ~= h then
		self.width = w
		self.height = h
		self.canvas1 = love.graphics.newCanvas()
		self.canvas2 = love.graphics.newCanvas()
	end
end

local colors = {
	white = {1, 1, 1, 1},
	blue = {0.25, 0.25, 1, 1},
	gray = {0.25, 0.25, 0.25, 1},
	yellow = {1, 1, 0.25, 1}
}

FrameTimeView.drawSmall = function(self)
	local w, h = love.graphics.getDimensions()
	love.graphics.origin()

	love.graphics.setColor(colors.white)

	local dt = love.timer.getDelta()

	local font = self.smallFont
	love.graphics.setFont(font)

	local text = ("%4dfps\n%3.1fms"):format(math.floor(1 / dt + 0.5), dt * 1000)
	local twidth = font:getWidth(text)
	local theight = font:getHeight() * 2

	love.graphics.translate(w - twidth, h - theight)

	love.graphics.setColor(0, 0, 0, 0.5)
	love.graphics.rectangle("fill", 0, 0, twidth, theight)

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.printf(text, 0, 0, twidth, "right")

	if just.button(self, just.is_over(twidth, theight)) then
		self.visible = not self.visible
	end
end

FrameTimeView.draw = function(self)
	local settings = self.game.configModel.configs.settings
	local showFPS = settings.miscellaneous.showFPS

	if not showFPS then
		return
	end

	if not self.visible then
		return self:drawSmall()
	end

	self:checkCanvas()

	love.graphics.origin()

	love.graphics.setCanvas(self.canvas1)
	love.graphics.setLineStyle("rough")
	love.graphics.setLineWidth(1)

	local y = self.height - 0.5
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.line(0.5, y, 0.5, y - love.timer.getDelta() * 1000 * self.scale)

	love.graphics.setColor(colors.blue)
	love.graphics.line(0.5, y, 0.5, y - aquaevent.timings.event * 1000 * self.scale)

	y = y - aquaevent.timings.event * 1000 * self.scale
	love.graphics.setColor(colors.gray, 1)
	love.graphics.line(0.5, y, 0.5, y - aquaevent.timings.update * 1000 * self.scale)

	y = y - aquaevent.timings.update * 1000 * self.scale
	love.graphics.setColor(colors.yellow)
	love.graphics.line(0.5, y, 0.5, y - aquaevent.timings.draw * 1000 * self.scale)

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

	self:drawSmall()
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

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.setFont(self.font)
	love.graphics.origin()
	love.graphics.translate((self.width - 200) / 2, 0)

	local action = "enable"
	if self.profiler then
		action = "disable"
	end
	if TextButtonImView("switch profiler", action .. " profiler", 200, 60) then
		if self.profiler then
			Profiler:stop()
		else
			Profiler:start()
		end
		self.profiler = not self.profiler
	end
end

FrameTimeView.receive = function(self, event)
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
