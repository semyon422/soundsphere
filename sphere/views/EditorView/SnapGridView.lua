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

	self.currentTime = 0
end

local pixelsPerBeat = 40
SnapGridView.drawRangeTracker = function(self, rangeTracker, format)
	local object = rangeTracker.startObject
	if not object then
		return
	end

	local ld = self.layerData
	local measureOffsets = self.measureOffsets

	local endObject = rangeTracker.endObject
	while object and object <= endObject do
		local time = rangeTracker:getObjectTime(object)
		local measureOffset = time:floor()
		local offset = measureOffsets[measureOffset]
		if offset then
			local signature = ld:getSignature(measureOffset):tonumber()
			local y = offset + (time:tonumber() - measureOffset) * pixelsPerBeat * signature
			love.graphics.line(0, y, 10, y)
			gfx_util.printFrame(format(object), -500, y - 25, 490, 50, "right", "center")
		end

		object = object.next
	end
end

SnapGridView.drawComputedGrid = function(self, field)
	local ld = self.layerData
	for time = ld.startTime:ceil(), ld.endTime:floor() do
		local timePoint = ld:getDynamicTimePoint(Fraction(time), -1)
		if not timePoint then break end
		local y = timePoint[field] * pixelsPerBeat

		love.graphics.line(0, y, 40, y)

		local signature = ld:getSignature(time):floor()
		for i = 2, signature do
			timePoint = ld:getDynamicTimePoint(Fraction(time * signature + i - 1, signature), -1)
			if not timePoint then break end
			local _y = timePoint[field] * pixelsPerBeat
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

	local ld = self.layerData

	local measureOffsets = {}
	self.measureOffsets = measureOffsets

	local offset = 0
	for time = ld.startTime:floor(), ld.endTime:ceil() do
		measureOffsets[time] = offset
		offset = offset + pixelsPerBeat * ld:getSignature(time):tonumber()
	end

	local _, my = love.graphics.inverseTransformPoint(love.mouse.getPosition())
	my = 1080 - my

	local _, active = just.button("scale drag", true)
	if active then
		self.currentTime = self.currentTime + (my - prevMouseY) / pixelsPerBeat
	end
	prevMouseY = my

	local t = self.currentTime
	local dtp = ld:getDynamicTimePointAbsolute(t, -1, 192)

	local measureOffset = dtp.measureTime:floor()
	local offset = measureOffsets[measureOffset]
	if offset then
		local signature = ld:getSignature(measureOffset):tonumber()
		local y = offset + (dtp.measureTime:tonumber() - measureOffset) * pixelsPerBeat * signature
		love.graphics.circle("fill", 0, h / 2, 4)

		love.graphics.push()
		love.graphics.translate(0, h / 2 - y)
		for time = ld.startTime:floor(), ld.endTime:ceil() do
			local _y = measureOffsets[time]
			local signature = ld:getSignature(time):tonumber()

			love.graphics.line(0, _y, 40, _y)

			for i = 2, signature do
				local __y = _y + (i - 1) * pixelsPerBeat
				love.graphics.line(0, __y, 10, __y)
			end
		end

		love.graphics.translate(-40, 0)
		self:drawRangeTracker(ld.tempoDatasRange, function(object)
			return object.tempo .. " bpm"
		end)
		self:drawRangeTracker(ld.stopDatasRange, function(object)
			return "stop " .. object.duration:tonumber() .. " beats"
		end)
		self:drawRangeTracker(ld.velocityDatasRange, function(object)
			return object.currentSpeed .. "x"
		end)
		self:drawRangeTracker(ld.expandDatasRange, function(object)
			return "expand into " .. object.duration:tonumber() .. " beats"
		end)
		love.graphics.translate(40, 0)

		love.graphics.pop()
	end

	love.graphics.translate(80, 0)
	love.graphics.push()
	love.graphics.translate(0, h / 2 - self.currentTime * pixelsPerBeat)
	self:drawComputedGrid("absoluteTime")
	love.graphics.pop()
	love.graphics.circle("fill", 0, h / 2, 4)

	local dtp = ld:getDynamicTimePointAbsolute(t, -1, 192)
	local y = dtp.visualTime * pixelsPerBeat

	love.graphics.translate(80, 0)
	love.graphics.push()
	love.graphics.translate(0, h / 2 - y)
	self:drawComputedGrid("visualTime")
	love.graphics.pop()
	love.graphics.circle("fill", 0, h / 2, 4)

	if ld.startTime:tonumber() ~= measureOffset - 5 then
		ld:setRange(Fraction(measureOffset - 5), Fraction(measureOffset + 5))
	end
end

return SnapGridView
