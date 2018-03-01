ncdk.TimingData = {}
local TimingData = ncdk.TimingData

ncdk.TimingData_metatable = {}
local TimingData_metatable = ncdk.TimingData_metatable
TimingData_metatable.__index = TimingData

TimingData.new = function(self)
	local timingData = {}
	
	timingData.signatureTable = ncdk.SignatureTable:new(ncdk.Fraction:new(4))
	timingData.tempoDataSequence = ncdk.TempoDataSequence:new()
	timingData.stopDataSequence = ncdk.StopDataSequence:new()
	
	setmetatable(timingData, TimingData_metatable)
	
	return timingData
end

TimingData.getTempoDataDuration = function(self, tempoDataIndex, startEdgeM_Time, endEdgeM_Time)
	local currentTempoData = self:getTempoData(tempoDataIndex)
	local nextTempoData = self:getTempoData(tempoDataIndex + 1)
	
	local mainStartM_Time = currentTempoData.measureTime
	local mainEndM_Time
	if nextTempoData then
		mainEndM_Time = nextTempoData.measureTime
	end
	
	if (startEdgeM_Time and nextTempoData and (startEdgeM_Time >= mainEndM_Time)) or
	   (endEdgeM_Time and tempoDataIndex > 1 and (endEdgeM_Time <= mainStartM_Time)) then
		return 0
	end
	
	if tempoDataIndex == 1 or (startEdgeM_Time and (startEdgeM_Time > mainStartM_Time)) then
		mainStartM_Time = startEdgeM_Time
	end
	if not nextTempoData or (endEdgeM_Time and (endEdgeM_Time < mainEndM_Time)) then
		mainEndM_Time = endEdgeM_Time
	end
	
	local startM_Index = math.min(mainStartM_Time:floor(), mainEndM_Time:floor())
	local endM_Index = math.max(mainStartM_Time:floor(), mainEndM_Time:floor())
	
	local time = 0
	for _M_Index = startM_Index, endM_Index do
		local startTime = ((_M_Index == startM_Index) and mainStartM_Time:tonumber()) or _M_Index
		local endTime = ((_M_Index == endM_Index) and mainEndM_Time:tonumber()) or _M_Index + 1
		local dedicatedDuration = self:getTempoData(tempoDataIndex):getBeatDuration() * self:getSignature(_M_Index):tonumber()
		
		time = time + (endTime - startTime) * dedicatedDuration
	end
	
	return time
end

TimingData.getStopDataDuration  = function(self, stopDataIndex, startEdgeM_Time, endEdgeM_Time)
	local currentStopData = self:getStopData(stopDataIndex)
	
	if currentStopData.measureTime >= startEdgeM_Time and currentStopData.measureTime < endEdgeM_Time then
		return currentStopData.duration
	else
		return 0
	end
end

TimingData.getAbsoluteTime = function(self, measureTime)
	local time = 0
	
	if measureTime == ncdk.Fraction:new(0) then
		return time
	end
	for currentTempoDataIndex = 1, self.tempoDataSequence:getTempoDataCount() do
		if measureTime > ncdk.Fraction:new(0) then
			time = time + self:getTempoDataDuration(currentTempoDataIndex, ncdk.Fraction:new(0), measureTime)
		elseif measureTime < ncdk.Fraction:new(0) then
			time = time - self:getTempoDataDuration(currentTempoDataIndex, measureTime, ncdk.Fraction:new(0))
		end
	end
	for currentStopDataIndex = 1, self.stopDataSequence:getStopDataCount() do
		if measureTime > ncdk.Fraction:new(0) then
			time = time + self:getStopDataDuration(currentStopDataIndex, ncdk.Fraction:new(0), measureTime)
		elseif measureTime < ncdk.Fraction:new(0) then
			time = time - self:getStopDataDuration(currentStopDataIndex, measureTime, ncdk.Fraction:new(0))
		end
	end
	
	return time
end

TimingData.getTimePoint = function(self, measureTime, side)
	return ncdk.TimePoint:new(self, measureTime, side)
end

TimingData.setSignature = function(self, measureIndex, signature) self.signatureTable:setSignature(measureIndex, signature) end
TimingData.getSignature = function(self, measureIndex) return self.signatureTable:getSignature(measureIndex) end
TimingData.setSignatureTable = function(self, signatureTable) self.signatureTable = signatureTable end
TimingData.addTempoData = function(self, tempoData) self.tempoDataSequence:addTempoData(tempoData) end
TimingData.getTempoData = function(self, tempoDataIndex) return self.tempoDataSequence:getTempoData(tempoDataIndex) end
TimingData.addStopData = function(self, stopData) self.stopDataSequence:addStopData(stopData) end
TimingData.getStopData = function(self, stopDataIndex) return self.stopDataSequence:getStopData(stopDataIndex) end
