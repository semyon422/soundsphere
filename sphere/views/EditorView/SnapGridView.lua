local Class = require("Class")
local gfx_util = require("gfx_util")
local math_util = require("math_util")
local spherefonts = require("sphere.assets.fonts")
local just = require("just")
local Fraction = require("ncdk.Fraction")
local imgui = require("imgui")

local Layout = require("sphere.views.EditorView.Layout")

local SnapGridView = Class:new()

local function getTimingText(timePoint)
	local out = {}
	if timePoint._tempoData then
		table.insert(out, timePoint._tempoData.tempo .. " bpm")
	elseif timePoint._signatureData then
		table.insert(out, "signature " .. tostring(timePoint._signatureData.signature) .. " beats")
	elseif timePoint._stopData then
		table.insert(out, "stop " .. tostring(timePoint._stopData.duration) .. " beats")
	elseif timePoint._intervalData then
		table.insert(out, timePoint.absoluteTime)
	end
	return table.concat(out, ", ")
end

local function getVelocityText(timePoint)
	local out = {}
	if timePoint._velocityData then
		table.insert(out, timePoint._velocityData.currentSpeed .. "x")
	elseif timePoint._expandData then
		table.insert(out, "expand " .. tostring(timePoint._expandData.duration) .. " beats")
	end
	return table.concat(out, ", ")
end

SnapGridView.drawTimingObjects = function(self, field, currentTime, w, h, align, getText)
	local editorModel = self.game.editorModel
	local rangeTracker = editorModel.layerData.ranges.timePoint
	local noteSkin = self.game.noteSkinModel.noteSkin
	local editor = self.game.configModel.configs.settings.editor
	local timePoint = rangeTracker.head
	if not timePoint or not currentTime then
		return
	end

	local endTimePoint = rangeTracker.tail
	local t
	while timePoint and timePoint <= endTimePoint do
		local text = getText(timePoint)
		if text and not t or timePoint.absoluteTime - t >= 0.01 then
			local y = noteSkin:getTimePosition((currentTime - timePoint[field]) * editor.speed)
			gfx_util.printFrame(text, 0, y - h / 2, w, h, align, "center")
			t = timePoint.absoluteTime
		end

		timePoint = timePoint.next
	end
end

local colors = {
	white = {1, 1, 1},
	red = {1, 0, 0},
	blue = {0, 0, 1},
	green = {0, 1, 0},
	yellow = {1, 1, 0},
	violet = {1, 0, 1},
}

local snaps = {
	[1] = colors.white,
	[2] = colors.red,
	[3] = colors.violet,
	[4] = colors.blue,
	[5] = colors.yellow,
	[6] = colors.violet,
	[7] = colors.yellow,
	[8] = colors.green,
}

SnapGridView.drawSnap = function(self, timePoint, field, currentTime, width)
	local editorModel = self.game.editorModel
	local noteSkin = self.game.noteSkinModel.noteSkin
	local editor = self.game.configModel.configs.settings.editor

	local y = noteSkin:getTimePosition((currentTime - timePoint[field]) * editor.speed)

	love.graphics.push("all")
	love.graphics.translate(0, y)

	local size = 20
	local changed, active, hovered = just.button(
		tostring(timePoint) .. "scroll",
		just.is_over(size, size, -size / 2, -size / 2) or just.is_over(size, size, -size / 2 + width, -size / 2)
	)
	if hovered then
		love.graphics.setLineWidth(4)
	end
	if changed then
		editorModel.scroller:scrollTimePoint(timePoint)
	end

	love.graphics.line(0, 0, width, 0)
	love.graphics.pop()
end

SnapGridView.drawComputedGrid = function(self, field, currentTime, width)
	local editorModel = self.game.editorModel
	local editor = self.game.configModel.configs.settings.editor
	local ld = editorModel.layerData
	local snap = editor.snap

	if not currentTime then
		return
	end

	love.graphics.setLineWidth(1)

	local range = 1 / editor.speed
	local timePoint = ld:getDynamicTimePointAbsolute(1, currentTime - range)
	local measureData

	local intervalData = timePoint.intervalData
	local time = timePoint.time
	intervalData, time = timePoint:add(Fraction((time * snap):ceil() + 1, snap) - time)

	timePoint = ld:getDynamicTimePointAbsolute(1, currentTime + range)
	local endIntervalData = timePoint.intervalData
	local endTime = timePoint.time
	endTime = Fraction((endTime * snap):floor(), snap)

	timePoint = ld:getDynamicTimePoint(intervalData, time)

	while intervalData and intervalData < endIntervalData or intervalData == endIntervalData and time <= endTime do
		timePoint = timePoint or ld:getDynamicTimePoint(intervalData, time)
		if not timePoint or not timePoint[field] then break end

		local drawNothing, skipInterval

		if measureData ~= timePoint.measureData then
			measureData = timePoint.measureData
			local delta = -(time % 1) + measureData.timePoint.time % 1 - measureData.start
			while delta[1] < 0 do
				delta = delta + Fraction(1, snap)
			end
			intervalData, time = timePoint:add(delta)
			timePoint = ld:getDynamicTimePoint(intervalData, time)
			if not timePoint or not timePoint[field] then break end
		end

		if not drawNothing and intervalData.prev then
			local dt = intervalData.timePoint.absoluteTime - intervalData.prev.timePoint.absoluteTime
			if dt < 0.01 then
				drawNothing = true
				skipInterval = true
			end
		end

		if not drawNothing then
			local j = snap * timePoint:getBeatModulo()
			love.graphics.setColor(snaps[editorModel:getSnap(j)] or colors.white)
			self:drawSnap(timePoint, field, currentTime, width)
		end

		if skipInterval then
			intervalData, time = intervalData.next, intervalData:start()
			timePoint = intervalData.timePoint
		else
			intervalData, time = timePoint:add(Fraction(1, snap))
			timePoint = nil
		end
	end

	love.graphics.setColor(1, 1, 1, 1)
end

SnapGridView.drawTimings = function(self, _w, _h)
	local editorModel = self.game.editorModel
	local editorTimePoint = editorModel.timePoint
	local noteSkin = self.game.noteSkinModel.noteSkin
	local editor = self.game.configModel.configs.settings.editor

	local rangeTracker = self.game.editorModel.layerData.ranges.timePoint
	local timePoint = rangeTracker.head
	if not timePoint then
		return
	end

	love.graphics.push("all")
	love.graphics.setColor(1, 0.8, 0.2)
	love.graphics.setLineWidth(4)
	local endTimePoint = rangeTracker.tail
	while timePoint and timePoint <= endTimePoint do
		local intervalData = timePoint._intervalData
		local measureData = timePoint._measureData

		if intervalData then
			love.graphics.setColor(1, 0.8, 0.2)
		elseif measureData then
			love.graphics.setColor(snaps[editorModel:getSnap(timePoint:getBeatModulo())] or colors.white)
		end

		if intervalData or measureData then
			local y = noteSkin:getTimePosition((editorTimePoint.absoluteTime - timePoint.absoluteTime) * editor.speed)
			love.graphics.line(0, y, _w, y)
		end

		timePoint = timePoint.next
	end
	love.graphics.pop()
end

local function drag(id, w, h)
	local over = just.is_over(w, h)
	local _, active, hovered = just.button(id, over)

	if hovered then
		local alpha = active and 0.2 or 0.1
		love.graphics.setColor(1, 1, 1, alpha)
		love.graphics.rectangle("fill", 0, 0, w, h)
	end
	love.graphics.setColor(1, 1, 1, 1)

	return just.active_id == id
end

local function drawMouse(self)
	local editorModel = self.game.editorModel
	local dt = editorModel:getMouseTime() - editorModel.timePoint.absoluteTime

	love.graphics.push()
	local w, h = Layout:move("base")

	local x, y = love.graphics.inverseTransformPoint(love.mouse.getPosition())

	local font = spherefonts.get("Noto Sans", 24)
	love.graphics.setFont(font)
	local text = ("%3.1fms"):format(dt * 1000)
	local width = font:getWidth(text)
	local height = font:getHeight() * font:getLineHeight()

	local padding = 20
	love.graphics.setColor(0, 0, 0, 0.75)
	love.graphics.rectangle("fill", x, y, width + padding * 2, height)

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.printf(("%3.1fms"):format(dt * 1000), x + padding, y, width, "left")
	love.graphics.pop()
end

local prevMouseY = 0
local speedOrig
SnapGridView.draw = function(self)
	local editorModel = self.game.editorModel
	local noteSkin = self.game.noteSkinModel.noteSkin
	local editor = self.game.configModel.configs.settings.editor

	local w, h = Layout:move("base")
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.setFont(spherefonts.get("Noto Sans", 24))
	love.graphics.setLineStyle("smooth")

	local lineHeight = 55
	imgui.setSize(w, h, 200, lineHeight)

	local editorTimePoint = editorModel.timePoint

	love.graphics.replaceTransform(gfx_util.transform(self.transform))
	love.graphics.translate(noteSkin.baseOffset, 0)
	local width = noteSkin.fullWidth
	local _mx, _my = love.graphics.inverseTransformPoint(love.mouse.getPosition())

	love.graphics.push()
	self:drawComputedGrid("absoluteTime", editorTimePoint.absoluteTime, width)

	if editor.showTimings then
		self:drawTimings(width, h)
	end

	love.graphics.translate(width + 40, 0)
	self:drawTimingObjects("absoluteTime", editorTimePoint.absoluteTime, 500, 50, "left", getVelocityText)
	love.graphics.pop()

	local lalt, lshift, lctrl = love.keyboard.isDown("lalt"), love.keyboard.isDown("lshift"), love.keyboard.isDown("lctrl")

	if lalt and not speedOrig then
		speedOrig = editor.speed
		editor.speed = 1000 / noteSkin.unit * 10
		editorModel.scroller:updateRange()
	elseif not lalt and speedOrig then
		editor.speed = speedOrig
		speedOrig = nil
		editorModel.scroller:updateRange()
	end
	if lalt or lshift or lctrl then
		drawMouse(self)
	end
	if (lalt or lshift) and drag("drag1", width, h) then
		local a = noteSkin:getInverseTimePosition(_my)
		local b = noteSkin:getInverseTimePosition(prevMouseY)
		editorModel.scroller:scrollSecondsDelta((a - b) / editor.speed)
		if editorModel.timer.isPlaying then
			editorModel:pause()
			self.dragging = true
		end
	elseif self.dragging then
		editorModel:play()
		self.dragging = false
	end
	prevMouseY = _my

	local scroll = just.wheel_over("scale scroll", true)
	if just.keypressed("right") then
		scroll = 1
	elseif just.keypressed("left") then
		scroll = -1
	end

	if scroll then
		if lshift then
			editor.snap = math.min(math.max(editor.snap + scroll, 1), 16)
		elseif lctrl then
			editorModel:setLogSpeed(editorModel:getLogSpeed() + scroll)
			editorModel.scroller:updateRange()
		else
			if editorModel.timer.isPlaying and scroll < 0 then
				editorModel.scroller:scrollSnaps(scroll)
			end
			editorModel.scroller:scrollSnaps(scroll)
		end
	end
end

return SnapGridView
