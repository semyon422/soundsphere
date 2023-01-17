local Class = require("Class")
local DynamicLayerData = require("ncdk.DynamicLayerData")
local Fraction = require("ncdk.Fraction")

local EditorModel = Class:new()

EditorModel.load = function(self)
	local noteChartModel = self.game.noteChartModel
	local nc = noteChartModel.noteChart

	local ld = nc:getLayerData(1)
	ld = DynamicLayerData:new(ld)
	self.layerData = ld

	self.columns = nc.inputMode:getColumns()
	self.inputMap = nc.inputMode:getInputMap()

	local directory = noteChartModel.noteChartEntry.path:match("^(.+)/.-$")
	self.soundData = love.sound.newSoundData(directory .. "/" .. nc.metaData.audioPath)

	self.timePoint = ld:newTimePoint()
	self.timePoint:setTime(ld:getDynamicTimePointAbsolute(192, 0))
	self.timePoint.absoluteTime = 0

	self.snap = 1
	self.speed = 1

	self:scrollSeconds(0)
end

EditorModel.save = function(self)
	local nc = self.game.noteChartModel.noteChart
	self.layerData:save(nc:getLayerData(1))
end

EditorModel.getLogSpeed = function(self)
	return math.floor(10 * math.log(self.speed) / math.log(2) + 0.5)
end

EditorModel.setLogSpeed = function(self, logSpeed)
	self.speed = 2 ^ (logSpeed / 10)
end

EditorModel.grabIntervalData = function(self)
	local dtp = self:getDynamicTimePoint()
	local intervalData = dtp._intervalData
	if not intervalData then
		return
	end
	self.grabbedIntervalData = intervalData
end

EditorModel.dropIntervalData = function(self)
	self.grabbedIntervalData = nil
end

EditorModel.update = function(self)
	local dtp = self:getDynamicTimePoint()
	if self.grabbedIntervalData then
		self.layerData:moveInterval(self.grabbedIntervalData, dtp.absoluteTime)
	end
end

EditorModel.getSnap = function(self, j)
	local snap = self.snap
	local k
	for i = 1, 16 do
		if snap % i == 0 and j % (snap / i) == 0 then
			k = i
			break
		end
	end
	return k
end

EditorModel.updateRange = function(self)
	local absoluteTime = self.timePoint.absoluteTime

	local ld = self.layerData
	if ld.mode == "interval" then
		local delta = 1 / self.speed
		if ld.startTime ~= absoluteTime - delta then
			ld:setRange(absoluteTime - delta, absoluteTime + delta)
		end
		return
	end

	local dtp = ld:getDynamicTimePointAbsolute(192, absoluteTime)
	local measureOffset = dtp.measureTime:floor()

	local delta = 2
	if ld.startTime:tonumber() ~= measureOffset - delta then
		ld:setRange(Fraction(measureOffset - delta), Fraction(measureOffset + delta))
	end
end

EditorModel.getDynamicTimePoint = function(self)
	local ld = self.layerData
	return ld:getDynamicTimePointAbsolute(192, self.timePoint.absoluteTime, self.timePoint.visualSide)
end

EditorModel.addNote = function(self, absoluteTime, inputType, inputIndex)
	local ld = self.layerData
	local dtp = ld:getDynamicTimePointAbsolute(self.snap, absoluteTime)
	local noteData = ld:getNoteData(dtp, inputType, inputIndex)
	if noteData then
		noteData.noteType = "ShortNote"
	end
end

EditorModel.scrollTimePoint = function(self, timePoint)
	if not timePoint then
		return
	end

	local t = self.timePoint
	t.absoluteTime = timePoint.absoluteTime
	t.visualTime = timePoint.visualTime
	t.beatTime = timePoint.beatTime
	t:setTime(timePoint:getTime())

	self:updateRange()
end

EditorModel.scrollSeconds = function(self, delta)
	local ld = self.layerData
	local dtp = ld:getDynamicTimePointAbsolute(192, self.timePoint.absoluteTime + delta)
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
	local dtp = ld:getDynamicTimePointAbsolute(192, self.timePoint.absoluteTime)

	local snap = self.snap
	local snapTime = dtp.time * snap

	local targetSnapTime
	if delta == -1 then
		targetSnapTime = snapTime:ceil() - 1
	else
		targetSnapTime = snapTime:floor() + 1
	end

	local intervalData = dtp.intervalData
	-- if intervalData.next and targetSnapTime >= snap * intervalData:_end() then
	-- 	intervalData = intervalData.next
	-- 	targetSnapTime = intervalData.start * snap
	-- elseif intervalData.prev and dtp.time > intervalData.start and targetSnapTime < snap * intervalData.start then
	-- 	targetSnapTime = intervalData.start * snap
	-- elseif intervalData.prev and dtp.time == intervalData.start and targetSnapTime < snap * intervalData.start then
	-- 	intervalData = intervalData.prev
	-- 	targetSnapTime = (intervalData:_end() * snap):ceil() - 1
	-- end

	if intervalData.next and targetSnapTime == snap * intervalData:_end() then
		intervalData = intervalData.next
		targetSnapTime = intervalData.start * snap
	elseif intervalData.next and targetSnapTime > snap * intervalData:_end() then
		intervalData = intervalData.next
		targetSnapTime = (intervalData.start * snap):floor() + 1
	elseif intervalData.prev and targetSnapTime < snap * intervalData.start then
		intervalData = intervalData.prev
		targetSnapTime = (intervalData:_end() * snap):ceil() - 1
	end

	return intervalData, Fraction(targetSnapTime, snap)
end

EditorModel.scrollSnapsMeasure = function(self, delta)
	local ld = self.layerData
	local dtp = ld:getDynamicTimePointAbsolute(192, self.timePoint.absoluteTime)

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
