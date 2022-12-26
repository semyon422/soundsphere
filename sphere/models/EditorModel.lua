local Class = require("Class")
local DynamicLayerData = require("ncdk.DynamicLayerData")
local Fraction = require("ncdk.Fraction")

local EditorModel = Class:new()

EditorModel.load1 = function(self)
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
	self.speed = 1

	self:scrollSeconds(0)
end

EditorModel.load = function(self)
	local ld = DynamicLayerData:new()
	self.layerData = ld

	ld:setTimeMode("interval")
	ld:setSignatureMode("short")
	ld:setRange(0, 30)

	local id1 = ld:getIntervalData(0, 10)
	local id2 = ld:getIntervalData(1, 1)

	-- ld:getVelocityData(id1, Fraction(0), -1, 0.5)
	-- ld:getVelocityData(id2, Fraction(3), -1, 2)
	-- ld:getVelocityData(id3, Fraction(1), -1, 1)

	ld:getNoteData(ld:getTimePoint(id1, Fraction(0)), "key", 1)
	ld:getNoteData(ld:getTimePoint(id1, Fraction(1)), "key", 2)
	ld:getNoteData(ld:getTimePoint(id1, Fraction(2)), "key", 3)
	ld:getNoteData(ld:getTimePoint(id1, Fraction(3)), "key", 4)

	self.beatTime = 0
	self.absoluteTime = 0
	self.visualTime = 0
	self.side = -1
	self.visualSide = -1

	self.snap = 1
	self.speed = 1

	self:scrollSeconds(0)
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
	if ld.mode == "interval" then
		local delta = 1 / self.speed
		if ld.startTime ~= self.absoluteTime - delta then
			ld:setRange(self.absoluteTime - delta, self.absoluteTime + delta)
		end
		return
	end

	local dtp = ld:getDynamicTimePointAbsolute(192, self.absoluteTime)
	local measureOffset = dtp.measureTime:floor()

	local delta = 2
	if ld.startTime:tonumber() ~= measureOffset - delta then
		ld:setRange(Fraction(measureOffset - delta), Fraction(measureOffset + delta))
	end
end

EditorModel.getDynamicTimePoint = function(self)
	local ld = self.layerData
	return ld:getDynamicTimePointAbsolute(192, self.absoluteTime, self.side, self.visualSide)
end

EditorModel.addNote = function(self, absoluteTime, inputType, inputIndex)
	local ld = self.layerData
	local dtp = ld:getDynamicTimePointAbsolute(self.snap, absoluteTime)
	ld:getNoteData(dtp, inputType, inputIndex)
end

EditorModel.scrollTimePoint = function(self, timePoint)
	self.absoluteTime = timePoint.absoluteTime
	self.visualTime = timePoint.visualTime
	self.beatTime = timePoint.beatTime
	self.side = timePoint.side
	self.visualSide = timePoint.visualSide

	self:updateRange()
end

EditorModel.scrollSeconds = function(self, delta)
	local ld = self.layerData
	local dtp = ld:getDynamicTimePointAbsolute(192, self.absoluteTime + delta)
	self:scrollTimePoint(dtp)
end

EditorModel.scrollSnaps = function(self, delta)
	local ld = self.layerData
	if ld.mode == "interval" then
		self:scrollTimePoint(ld:getDynamicTimePoint(self:scrollSnapsInterval(delta)))
	elseif ld.mode == "measure" then
		self:scrollTimePoint(ld:getDynamicTimePoint(self:scrollSnapsMeasure(delta)))
	end
end

EditorModel.scrollSnapsInterval = function(self, delta)
	local ld = self.layerData
	local dtp = ld:getDynamicTimePointAbsolute(192, self.absoluteTime)

	local snap = self.snap
	local snapTime = dtp.time * snap

	local targetSnapTime
	if delta == -1 then
		targetSnapTime = snapTime:ceil() - 1
	else
		targetSnapTime = snapTime:floor() + 1
	end

	local intervalData = dtp.intervalData
	if intervalData.next and targetSnapTime >= intervalData.intervals * snap then
		intervalData = intervalData.next
		targetSnapTime = 0
	elseif intervalData.prev and targetSnapTime < 0 then
		intervalData = intervalData.prev
		targetSnapTime = intervalData.intervals * snap - 1
	end

	return intervalData, Fraction(targetSnapTime, snap)
end

EditorModel.scrollSnapsMeasure = function(self, delta)
	local ld = self.layerData
	local dtp = ld:getDynamicTimePointAbsolute(192, self.absoluteTime)

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

	if measureOffset ~= targetMeasureOffset then
		if delta == -1 then
			return Fraction(sigSnap:ceil() - 1) / sigSnap + targetMeasureOffset
		end
		return Fraction(targetMeasureOffset)
	end

	local snapTime = (dtp.measureTime - measureOffset) * sigSnap

	local targetSnapTime
	if delta == -1 then
		targetSnapTime = snapTime:ceil() - 1
	else
		targetSnapTime = snapTime:floor() + 1
	end

	return Fraction(targetSnapTime) / sigSnap + measureOffset
end

return EditorModel
