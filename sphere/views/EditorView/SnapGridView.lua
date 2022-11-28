local Class = require("Class")
local gfx_util = require("gfx_util")
local spherefonts = require("sphere.assets.fonts")
local just = require("just")
local DynamicLayerData = require("ncdk.DynamicLayerData")
local Fraction = require("ncdk.Fraction")
local SpoilerListImView = require("sphere.imviews.SpoilerListImView")

local Layout = require("sphere.views.EditorView.Layout")

local SnapGridView = Class:new()

SnapGridView.construct = function(self)
	local ld = DynamicLayerData:new()
	self.layerData = ld

	ld:setTimeMode("measure")
	ld:setSignatureMode("short")
	ld:setRange(Fraction(0), Fraction(10))

	ld:getSignatureData(2, Fraction(3))
	ld:getSignatureData(3, Fraction(34, 10))

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

	self.snap = 1
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
SnapGridView.drawTimingObjects = function(self, field, currentTime)
	local rangeTracker = self.layerData.timePointsRange
	local object = rangeTracker.startObject
	if not object then
		return
	end

	local endObject = rangeTracker.endObject
	while object and object <= endObject do
		local text = getTimePointText(object)
		if text then
			local y = (object[field] - currentTime) * pixelsPerBeat
			love.graphics.line(0, y, 10, y)
			gfx_util.printFrame(text, -500, y - 25, 490, 50, "right", "center")
		end

		object = object.next
	end
end

SnapGridView.drawComputedGrid = function(self, field, currentTime)
	local ld = self.layerData
	local snap = self.snap

	for time = ld.startTime:ceil(), ld.endTime:floor() do
		local signature = ld:getSignature(time)
		local _signature = signature:ceil()
		for i = 1, _signature do
			for j = 1, snap do
				local f = Fraction((i - 1) * snap + j - 1, signature * snap)
				if f:tonumber() < 1 then
					local timePoint = ld:getDynamicTimePoint(f + time, -1)
					if not timePoint then break end
					local y = (timePoint[field] - currentTime) * pixelsPerBeat
					local w
					if i == 1 and j == 1 then w = 40
					elseif j == 1 then w = 10
					else w = 2
					end
					love.graphics.line(0, y, w, y)
				end
			end
		end
	end
end

local snaps = {1, 2, 3, 4, 5, 6, 7, 8}
SnapGridView.drawUI = function(self)
	just.push()
	local _, snap = SpoilerListImView("snap select", 100, 55, snaps, self.snap)
	if snap then
		self.snap = snap
	end
	just.pop()
end

local prevMouseY = 0
SnapGridView.draw = function(self)
	local w, h = Layout:move("base")
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.setFont(spherefonts.get("Noto Sans", 24))

	self:drawUI()

	love.graphics.translate(w / 5, 0)

	local _, my = love.graphics.inverseTransformPoint(love.mouse.getPosition())
	my = h - my

	local over = just.is_over(240, h)
	just.button("scale drag", over)
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
	self:drawTimingObjects("beatTime", self.beatTime)
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

	local scroll = just.wheel_over("scale scroll", over)
	scroll = scroll and -scroll
	if just.keypressed("right") then
		scroll = 1
	elseif just.keypressed("left") then
		scroll = -1
	end

	if scroll then
		dtp = ld:getDynamicTimePointAbsolute(t, 192, -1)
		local signature = ld:getSignature(measureOffset)
		local sigSnap = signature * self.snap

		local targetMeasureOffset
		if scroll == -1 then
			targetMeasureOffset = dtp.measureTime:ceil() - 1
		else
			targetMeasureOffset = (dtp.measureTime + Fraction(1) / sigSnap):floor()
		end
		signature = ld:getSignature(targetMeasureOffset)
		sigSnap = signature * self.snap

		local measureTime
		if measureOffset ~= targetMeasureOffset then
			if scroll == -1 then
				measureTime = Fraction(sigSnap:ceil() - 1) / sigSnap + targetMeasureOffset
			else
				measureTime = Fraction(targetMeasureOffset)
			end
		else
			local snapTime = (dtp.measureTime - measureOffset) * sigSnap

			local targetSnapTime
			if scroll == -1 then
				targetSnapTime = snapTime:ceil() - 1
			else
				targetSnapTime = snapTime:floor() + 1
			end

			measureTime = Fraction(targetSnapTime) / sigSnap + measureOffset
		end

		dtp = ld:getDynamicTimePoint(measureTime)
		self.absoluteTime = dtp.absoluteTime
		self.visualTime = dtp.visualTime
		self.beatTime = dtp.beatTime
	end
end

return SnapGridView
