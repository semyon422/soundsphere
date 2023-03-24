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
	local timePoint = rangeTracker.head
	if not timePoint or not currentTime then
		return
	end

	local endTimePoint = rangeTracker.tail
	while timePoint and timePoint <= endTimePoint do
		local text = getText(timePoint)
		if text then
			local y = noteSkin:getTimePosition((currentTime - timePoint[field]) * editorModel.speed)
			gfx_util.printFrame(text, 0, y - h / 2, w, h, align, "center")
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

SnapGridView.drawComputedGrid = function(self, field, currentTime, width)
	local editorModel = self.game.editorModel
	local ld = editorModel.layerData
	local snap = editorModel.snap
	local noteSkin = self.game.noteSkinModel.noteSkin

	if not currentTime then
		return
	end

	if ld.mode == "measure" then
		for time = ld.startTime:ceil(), ld.endTime:floor() do
			local signature = ld:getSignature(time)
			local _signature = signature:ceil()
			for i = 0, _signature - 1 do
				for j = 0, snap - 1 do
					local f = Fraction(i * snap + j, signature * snap)
					if f:tonumber() < 1 then
						local timePoint = ld:getDynamicTimePoint(f + time, -1)
						if not timePoint then break end
						local y = noteSkin:getTimePosition((currentTime - timePoint[field]) * editorModel.speed)
						love.graphics.setColor(snaps[editorModel:getSnap(j)] or colors.white)
						love.graphics.line(0, y, width, y)
					end
				end
			end
		end
	elseif ld.mode == "interval" then
		local timePoint = ld:getDynamicTimePointAbsolute(192, ld.startTime)
		local measureData = timePoint.measureData

		local intervalData = timePoint.intervalData
		local time = timePoint.time
		intervalData, time = timePoint:add(Fraction((time * snap):ceil() + 1, snap) - time)

		timePoint = ld:getDynamicTimePointAbsolute(192, ld.endTime)
		local endIntervalData = timePoint.intervalData
		local endTime = timePoint.time
		endTime = Fraction((endTime * snap):floor(), snap)

		while intervalData and intervalData < endIntervalData or intervalData == endIntervalData and time <= endTime do
			timePoint = ld:getDynamicTimePoint(intervalData, time)
			if not timePoint or not timePoint[field] then break end

			local drawNothing
			if measureData ~= timePoint.measureData then
				measureData = timePoint.measureData
				intervalData, time = measureData.timePoint:add(-measureData.start + Fraction(1, snap))
				timePoint = ld:getDynamicTimePoint(intervalData, time)
				if not timePoint or not timePoint[field] then break end
				drawNothing = timePoint.measureData ~= measureData
			end

			if not drawNothing then
				local y = noteSkin:getTimePosition((currentTime - timePoint[field]) * editorModel.speed)

				local j = snap * timePoint:getBeatModulo()
				love.graphics.setColor(snaps[editorModel:getSnap(j)] or colors.white)
				love.graphics.line(0, y, width, y)
			end

			intervalData, time = timePoint:add(Fraction(1, snap))
		end
	end
	love.graphics.setColor(1, 1, 1, 1)
end

SnapGridView.drawTimings = function(self, _w, _h)
	local editorModel = self.game.editorModel
	local ld = editorModel.layerData
	local editorTimePoint = editorModel.timePoint
	local noteSkin = self.game.noteSkinModel.noteSkin

	if ld.mode ~= "interval" then
		return
	end

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
			local y = noteSkin:getTimePosition((editorTimePoint.absoluteTime - timePoint.absoluteTime) * editorModel.speed)
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

local prevMouseY = 0
SnapGridView.draw = function(self)
	local editorModel = self.game.editorModel
	local ld = editorModel.layerData
	local noteSkin = self.game.noteSkinModel.noteSkin

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
	self:drawTimings(width, h)

	love.graphics.translate(width + 40, 0)
	self:drawTimingObjects("absoluteTime", editorTimePoint.absoluteTime, 500, 50, "left", getVelocityText)
	love.graphics.pop()

	if love.keyboard.isDown("lalt") and drag("drag1", width, h) then
		local a = noteSkin:getInverseTimePosition(_my)
		local b = noteSkin:getInverseTimePosition(prevMouseY)
		editorModel:scrollSecondsDelta((a - b) / editorModel.speed)
		if editorModel.timer.isPlaying then
			editorModel:pause()
			self.dragging = true
		end
	elseif self.dragging then
		editorModel:play()
		self.dragging = false
	end
	prevMouseY = _my

	local scroll = just.wheel_over("scale scroll", just.is_over(width, h))
	if just.keypressed("right") then
		scroll = 1
	elseif just.keypressed("left") then
		scroll = -1
	end

	if scroll then
		if love.keyboard.isDown("lshift") then
			editorModel.snap = math.min(math.max(editorModel.snap + scroll, 1), 16)
		elseif love.keyboard.isDown("lctrl") then
			editorModel:setLogSpeed(editorModel:getLogSpeed() + scroll)
			editorModel:updateRange()
		else
			editorModel:scrollSnaps(scroll)
		end
	end
end

return SnapGridView
