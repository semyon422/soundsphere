local Class = require("Class")
local gfx_util = require("gfx_util")
local spherefonts = require("sphere.assets.fonts")
local just = require("just")
local DynamicLayerData = require("ncdk.DynamicLayerData")
local Fraction = require("ncdk.Fraction")

local Layout = require("sphere.views.EditorView.Layout")

local SnapGridView = Class:new()

SnapGridView.construct = function(self)
	local ld = DynamicLayerData:new()
	self.layerData = ld

	ld:setTimeMode("measure")
	ld:setSignatureMode("short")
	ld:setRange(Fraction(0), Fraction(10))

	ld:getSignatureData(2, Fraction(3))

	ld:getTempoData(Fraction(1), 60)
	ld:getTempoData(Fraction(3.5, 10, true), 120)

	ld:getStopData(Fraction(5), Fraction(4))

	ld:getVelocityData(Fraction(0.5, 10, true), -1, 1)
	ld:getVelocityData(Fraction(4.5, 10, true), -1, 2)
	ld:getVelocityData(Fraction(5, 4), -1, 0)
	ld:getVelocityData(Fraction(6, 4), -1, 1)

	ld:getExpandData(Fraction(2), -1, Fraction(1))

	self.beatTime = 0
	self.absoluteTime = 0
	self.visualTime = 0
end

local function getTimePointText(timePoint)
	if timePoint._tempoData then
		return timePoint._tempoData.tempo .. " bpm"
	elseif timePoint._stopData then
		return "stop " .. timePoint._stopData.duration:tonumber() .. " beats"
	elseif timePoint._velocityData then
		return timePoint._velocityData.currentSpeed .. "x"
	elseif timePoint._expandData then
		return "expand into " .. timePoint._expandData.duration:tonumber() .. " beats"
	end
end

local pixelsPerBeat = 40
SnapGridView.drawTimingObjects = function(self)
	local rangeTracker = self.layerData.timePointsRange
	local object = rangeTracker.startObject
	if not object then
		return
	end

	local endObject = rangeTracker.endObject
	while object and object <= endObject do
		local text = getTimePointText(object)
		if text then
			local y = (object.beatTime - self.beatTime) * pixelsPerBeat
			love.graphics.line(0, y, 10, y)
			gfx_util.printFrame(text, -500, y - 25, 490, 50, "right", "center")
		end

		object = object.next
	end
end

SnapGridView.drawComputedGrid = function(self, field, currentTime)
	local ld = self.layerData
	for time = ld.startTime:ceil(), ld.endTime:floor() do
		local timePoint = ld:getDynamicTimePoint(Fraction(time), -1)
		if not timePoint then break end
		local y = (timePoint[field] - currentTime) * pixelsPerBeat

		love.graphics.line(0, y, 40, y)

		local signature = ld:getSignature(time):floor()
		for i = 2, signature do
			timePoint = ld:getDynamicTimePoint(Fraction(time * signature + i - 1, signature), -1)
			if not timePoint then break end
			local _y = (timePoint[field] - currentTime) * pixelsPerBeat
			love.graphics.line(0, _y, 10, _y)
		end
	end
end

local prevMouseY = 0
SnapGridView.draw = function(self)
	local w, h = Layout:move("base")
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.setFont(spherefonts.get("Noto Sans", 24))

	love.graphics.translate(w / 5, 0)

	local _, my = love.graphics.inverseTransformPoint(love.mouse.getPosition())
	my = h - my

	just.button("scale drag", just.is_over(240, h))
	if just.active_id == "scale drag" then
		self.absoluteTime = self.absoluteTime + (my - prevMouseY) / pixelsPerBeat
	end
	prevMouseY = my

	local t = self.absoluteTime

	local ld = self.layerData
	local dtp = ld:getDynamicTimePointAbsolute(t, 192, -1)
	self.visualTime = dtp.visualTime
	self.beatTime = dtp.beatTime

	local measureOffset = dtp.measureTime:floor()

	love.graphics.push()
	love.graphics.translate(0, h / 2)
	love.graphics.line(0, 0, 240, 0)

	love.graphics.translate(-40, 0)
	self:drawTimingObjects()
	love.graphics.translate(40, 0)
	self:drawComputedGrid("beatTime", self.beatTime)

	love.graphics.translate(80, 0)
	self:drawComputedGrid("absoluteTime", self.absoluteTime)

	love.graphics.translate(80, 0)
	self:drawComputedGrid("visualTime", self.visualTime)

	love.graphics.pop()

	local delta = 2
	if ld.startTime:tonumber() ~= measureOffset - delta then
		ld:setRange(Fraction(measureOffset - delta), Fraction(measureOffset + delta))
	end
end

return SnapGridView
