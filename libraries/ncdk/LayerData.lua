ncdk.LayerData = {}
local LayerData = ncdk.LayerData

ncdk.LayerData_metatable = {}
local LayerData_metatable = ncdk.LayerData_metatable
LayerData_metatable.__index = LayerData

LayerData.new = function(self)
	local layerData = {}
	
	layerData.timingData = ncdk.TimingData:new()
	layerData.velocityDataSequence = ncdk.VelocityDataSequence:new()
	layerData.noteDataSequence = ncdk.NoteDataSequence:new()
	
	layerData.timingData.layerData = layerData
	layerData.velocityDataSequence.layerData = layerData
	layerData.noteDataSequence.layerData = layerData
	
	setmetatable(layerData, LayerData_metatable)
	
	return layerData
end

LayerData.getVelocityDataVisualMeasureDuration = function(self, velocityDataIndex, startEdgeTimePoint, endEdgeTimePoint)
	local currentVelocityData = self.velocityDataSequence:getVelocityData(velocityDataIndex)
	local nextVelocityData = self.velocityDataSequence:getVelocityData(velocityDataIndex + 1)
	
	local mainStartTimePoint = currentVelocityData.timePoint
	local mainEndTimePoint
	if nextVelocityData then
		mainEndTimePoint = nextVelocityData.timePoint
	end
	
	if (startEdgeTimePoint and nextVelocityData and (startEdgeTimePoint >= mainEndTimePoint)) or
	   (endEdgeTimePoint and velocityDataIndex > 1 and (endEdgeTimePoint <= mainStartTimePoint)) then
		return ncdk.Fraction:new(0)
	end
	
	if velocityDataIndex == 1 or (startEdgeTimePoint and (startEdgeTimePoint > mainStartTimePoint)) then
		mainStartTimePoint = startEdgeTimePoint
	end
	if not nextVelocityData or (endEdgeTimePoint and (endEdgeTimePoint < mainEndTimePoint)) then
		mainEndTimePoint = endEdgeTimePoint
	end
	
	local visualMeasureDuration = (mainEndTimePoint.measureTime - mainStartTimePoint.measureTime) * currentVelocityData.currentSpeed
	if visualMeasureDuration ~= ncdk.Fraction:new(0) or not currentVelocityData.visualEndTimePoint then
		return visualMeasureDuration
	else
		return currentVelocityData.visualEndTimePoint.measureTime - currentVelocityData.timePoint.measureTime
	end
end

LayerData.getVisualMeasureTime = function(self, targetMeasureTimePoint, currentMeasureTimePoint)
	local deltaTime = ncdk.Fraction:new(0)
	
	if targetMeasureTimePoint == currentMeasureTimePoint then
		return currentMeasureTimePoint.measureTime
	end
	
	local targetVelocityData = targetMeasureTimePoint.velocityData or self:getVelocityDataByTimePoint(targetMeasureTimePoint)
	local currentVelocityData = currentMeasureTimePoint.velocityData or self:getVelocityDataByTimePoint(currentMeasureTimePoint)
	
	local localSpeed = targetVelocityData.localSpeed
	local globalSpeed = currentVelocityData.globalSpeed
	
	for currentVelocityDataIndex = 1, self.velocityDataSequence:getVelocityDataCount() do
		if targetMeasureTimePoint > currentMeasureTimePoint then
			deltaTime = deltaTime + self:getVelocityDataVisualMeasureDuration(currentVelocityDataIndex, currentMeasureTimePoint, targetMeasureTimePoint)
		elseif targetMeasureTimePoint < currentMeasureTimePoint then
			deltaTime = deltaTime - self:getVelocityDataVisualMeasureDuration(currentVelocityDataIndex, targetMeasureTimePoint, currentMeasureTimePoint)
		end
	end
	
	return currentMeasureTimePoint.measureTime + deltaTime * localSpeed * globalSpeed
end

LayerData.getVelocityDataByTimePoint = function(self, timePoint)
	return self.velocityDataSequence:getVelocityDataByTimePoint(timePoint)
end

LayerData.getVelocityDataVisualDuration = function(self, velocityDataIndex, startEdgeTimePoint, endEdgeTimePoint)
	local currentVelocityData = self.velocityDataSequence:getVelocityData(velocityDataIndex)
	local nextVelocityData = self.velocityDataSequence:getVelocityData(velocityDataIndex + 1)
	
	local mainStartTimePoint = currentVelocityData.timePoint
	local mainEndTimePoint
	if nextVelocityData then
		mainEndTimePoint = nextVelocityData.timePoint
	end
	
	if (startEdgeTimePoint and nextVelocityData and (startEdgeTimePoint >= mainEndTimePoint)) or
	   (endEdgeTimePoint and velocityDataIndex > 1 and (endEdgeTimePoint <= mainStartTimePoint)) then
		return 0
	end
	
	if velocityDataIndex == 1 or (startEdgeTimePoint and (startEdgeTimePoint > mainStartTimePoint)) then
		mainStartTimePoint = startEdgeTimePoint
	end
	if not nextVelocityData or (endEdgeTimePoint and (endEdgeTimePoint < mainEndTimePoint)) then
		mainEndTimePoint = endEdgeTimePoint
	end
	
	local visualDuration = (mainEndTimePoint:getAbsoluteTime() - mainStartTimePoint:getAbsoluteTime()) * currentVelocityData.currentSpeed:tonumber()
	if visualDuration ~= 0 or not currentVelocityData.visualEndTimePoint then
		return visualDuration
	else
		return currentVelocityData.visualEndTimePoint:getAbsoluteTime() - currentVelocityData.timePoint:getAbsoluteTime()
	end
end

LayerData.getVisualTime = function(self, targetTimePoint, currentTimePoint, clear)
	local deltaTime = 0
	
	if targetTimePoint == currentTimePoint then
		return currentTimePoint:getAbsoluteTime()
	end
	
	local globalSpeed, localSpeed = 1, 1
	if not clear then
		local currentVelocityData = currentTimePoint.velocityData
		local targetVelocityData = targetTimePoint.velocityData
		
		globalSpeed = currentVelocityData.globalSpeed:tonumber()
		localSpeed = targetVelocityData.localSpeed:tonumber()
	end
	
	for currentVelocityDataIndex = 1, self.velocityDataSequence:getVelocityDataCount() do
		if targetTimePoint > currentTimePoint then
			deltaTime = deltaTime + self:getVelocityDataVisualDuration(currentVelocityDataIndex, currentTimePoint, targetTimePoint)
		elseif targetTimePoint < currentTimePoint then
			deltaTime = deltaTime - self:getVelocityDataVisualDuration(currentVelocityDataIndex, targetTimePoint, currentTimePoint)
		end
	end
	
	return currentTimePoint:getAbsoluteTime() + deltaTime * localSpeed * globalSpeed
end

LayerData.computeVisualTime = function(self, currentTimePoint)
	local currentClearVisualTime = self:getVisualTime(currentTimePoint, self.zeroTimePoint, true)
	local globalSpeed = currentTimePoint.velocityData.globalSpeed:tonumber()
	
	for noteDataIndex = 1, self.noteDataSequence:getNoteDataCount() do
		local noteData = self.noteDataSequence:getNoteData(noteDataIndex)
		
		local targetStartVelocityData = noteData.startTimePoint.velocityData
		local startLocalSpeed = targetStartVelocityData.localSpeed:tonumber()
		
		noteData.currentClearVisualDeltaStartTime = noteData.zeroClearVisualStartTime - currentClearVisualTime
		
		noteData.currentClearVisualStartTime = noteData.currentClearVisualDeltaStartTime + currentTimePoint:getAbsoluteTime()
		noteData.currentVisualStartTime = noteData.currentClearVisualDeltaStartTime * globalSpeed * startLocalSpeed + currentTimePoint:getAbsoluteTime()
		
		if noteData.endTimePoint then
			local targetEndVelocityData = noteData.endTimePoint.velocityData
			local endLocalSpeed = targetEndVelocityData.localSpeed:tonumber()
			
			noteData.currentClearVisualDeltaEndTime = noteData.zeroClearVisualEndTime - currentClearVisualTime
			
			noteData.currentClearVisualEndTime = noteData.currentClearVisualDeltaEndTime + currentTimePoint:getAbsoluteTime()
			noteData.currentVisualEndTime = noteData.currentClearVisualDeltaEndTime * globalSpeed * endLocalSpeed + currentTimePoint:getAbsoluteTime()
		end
	end
end

LayerData.updateZeroTimePoint = function(self)
	self.zeroTimePoint = self:getTimePoint(ncdk.Fraction:new(0, 1), 1)
	self.zeroTimePoint.velocityData = self:getVelocityDataByTimePoint(self.zeroTimePoint)
end

LayerData.getColumnCount = function(self) return self.noteDataSequence:getColumnCount() end
LayerData.setSignature = function(self, measureIndex, signature) self.timingData:setSignature(measureIndex, signature) end
LayerData.getSignature = function(self, measureIndex) return self.timingData:getSignature(measureIndex) end
LayerData.setSignatureTable = function(self, signatureTable) self.timingData:setSignatureTable(signatureTable) end
LayerData.addTempoData = function(self, tempoData) self.timingData:addTempoData(tempoData) end
LayerData.getTempoData = function(self, tempoDataIndex) return self.timingData:getTempoData(tempoDataIndex) end
LayerData.addStopData = function(self, stopData) self.timingData:addStopData(stopData) end
LayerData.getStopData = function(self, stopDataIndex) return self.timingData:getStopData(stopDataIndex) end
LayerData.getTimePoint = function(self, measureTime, side) return self.timingData:getTimePoint(measureTime, side) end
LayerData.addVelocityData = function(self, velocityData) self.velocityDataSequence:addVelocityData(velocityData) end
LayerData.getVelocityData = function(self, velocityDataIndex) return self.velocityDataSequence:getVelocityData(velocityDataIndex) end
LayerData.getVelocityDataCount = function(self) return self.velocityDataSequence:getVelocityDataCount() end
LayerData.addNoteData = function(self, noteData) return self.noteDataSequence:addNoteData(noteData) end
LayerData.getNoteData = function(self, noteDataIndex) return self.noteDataSequence:getNoteData(noteDataIndex) end
LayerData.getNoteDataCount = function(self) return self.noteDataSequence:getNoteDataCount() end
