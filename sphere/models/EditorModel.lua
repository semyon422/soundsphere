local Class = require("Class")
local DynamicLayerData = require("ncdk.DynamicLayerData")
local Fraction = require("ncdk.Fraction")

local EditorModel = Class:new()

EditorModel.load = function(self)
	local ld = DynamicLayerData:new()
	self.layerData = ld

	ld:setTimeMode("measure")
	ld:setSignatureMode("short")
	-- ld:setPrimaryTempo(60)
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
	self.side = -1
	self.visualSide = -1

	self.snap = 1

	self:updateRange()
end

EditorModel.getSnap = function(self, j)
	local snap = self.snap
	local k
	for i = 1, 16 do
		if snap % i == 0 then
			if (j - 1) % (snap / i) == 0 then
				k = i
				break
			end
		end
	end
	return k
end

EditorModel.updateRange = function(self)
	local ld = self.layerData
	local dtp = ld:getDynamicTimePointAbsolute(self.absoluteTime, 192, -1)
	local measureOffset = dtp.measureTime:floor()

	local delta = 2
	if ld.startTime:tonumber() ~= measureOffset - delta then
		ld:setRange(Fraction(measureOffset - delta), Fraction(measureOffset + delta))
	end
end

EditorModel.getDynamicTimePoint = function(self)
	local ld = self.layerData
	return ld:getDynamicTimePointAbsolute(self.absoluteTime, 192, self.side, self.visualSide)
end

EditorModel.scrollSeconds = function(self, delta)
	self.absoluteTime = self.absoluteTime + delta

	local ld = self.layerData
	local dtp = ld:getDynamicTimePointAbsolute(self.absoluteTime, 192, -1)
	self.visualTime = dtp.visualTime
	self.beatTime = dtp.beatTime
	self.side = -1
	self.visualSide = -1

	self:updateRange()
end

EditorModel.scrollTimePoint = function(self, timePoint)
	self.absoluteTime = timePoint.absoluteTime
	self.visualTime = timePoint.visualTime
	self.beatTime = timePoint.beatTime
	self.side = timePoint.side
	self.visualSide = timePoint.visualSide

	self:updateRange()
end

EditorModel.scrollSnaps = function(self, delta)
	local ld = self.layerData
	local dtp = ld:getDynamicTimePointAbsolute(self.absoluteTime, 192, -1)

	local measureOffset = dtp.measureTime:floor()
	local signature = ld:getSignature(measureOffset)
	local sigSnap = signature * self.snap

	local targetMeasureOffset
	if delta == -1 then
		targetMeasureOffset = dtp.measureTime:ceil() - 1
	else
		targetMeasureOffset = (dtp.measureTime + Fraction(1) / sigSnap):floor()
	end
	signature = ld:getSignature(targetMeasureOffset)
	sigSnap = signature * self.snap

	local measureTime
	if measureOffset ~= targetMeasureOffset then
		if delta == -1 then
			measureTime = Fraction(sigSnap:ceil() - 1) / sigSnap + targetMeasureOffset
		else
			measureTime = Fraction(targetMeasureOffset)
		end
	else
		local snapTime = (dtp.measureTime - measureOffset) * sigSnap

		local targetSnapTime
		if delta == -1 then
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
	self.side = -1
	self.visualSide = -1

	self:updateRange()
end

return EditorModel
