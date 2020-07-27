local Modifier = require("sphere.models.ModifierModel.Modifier")

local SpeedMode = Modifier:new()

SpeedMode.inconsequential = true
SpeedMode.type = "NoteChartModifier"

SpeedMode.name = "SpeedMode"
SpeedMode.shortName = "SpeedMode"

SpeedMode.variableType = "number"
SpeedMode.variableName = "value"
SpeedMode.variableFormat = "%s"
SpeedMode.variableRange = {1, 1, 5}
SpeedMode.variableValues = {"avg", "x", "const", "min", "max"}
SpeedMode.value = 1

SpeedMode.modeNames = {"AMod", "XMod", "CMod", "MinMod", "MaxMod"}

SpeedMode.tostring = function(self)
	return self.modeNames[self.value]
end

SpeedMode.tojson = function(self)
	return ([[{"name":"%s","value":%s}]]):format(self.name, self.value)
end

SpeedMode.applySpeed = function(self, speed)
	local noteChart = self.model.noteChart

	for layerIndex in noteChart:getLayerDataIndexIterator() do
		local layerData = noteChart:requireLayerData(layerIndex)
		
		local velocityDataSequence = layerData.spaceData.velocityDataSequence
		for velocityDataIndex = 1, velocityDataSequence:getVelocityDataCount() do
			local velocityData = velocityDataSequence:getVelocityData(velocityDataIndex)
			
			velocityData.currentSpeed = velocityData.currentSpeed / speed
		end
	end
	
	noteChart:compute()
end

SpeedMode.applyConstant = function(self)
	local noteChart = self.model.noteChart

	for layerIndex in noteChart:getLayerDataIndexIterator() do
		local layerData = noteChart:requireLayerData(layerIndex)
		
		local velocityDataSequence = layerData.spaceData.velocityDataSequence
		for velocityDataIndex = 1, velocityDataSequence:getVelocityDataCount() do
			local velocityData = velocityDataSequence:getVelocityData(velocityDataIndex)
			
			velocityData.currentSpeed = 1
			velocityData.localSpeed = 1
			velocityData.globalSpeed = 1
		end
	end
	
	noteChart:compute()
end

SpeedMode.apply = function(self)
	local noteChart = self.model.noteChart
	
	local minTime = noteChart.metaData:get("minTime")
	local maxTime = noteChart.metaData:get("maxTime")

	local lastTime = minTime
	local durations = {}

	for layerIndex in noteChart:getLayerDataIndexIterator() do
		local layerData = noteChart:requireLayerData(layerIndex)
		
		local velocityDataSequence = layerData.spaceData.velocityDataSequence
		for velocityDataIndex = 1, velocityDataSequence:getVelocityDataCount() do
			local velocityData = velocityDataSequence:getVelocityData(velocityDataIndex)
			local nextVelocityData = velocityDataSequence:getVelocityData(velocityDataIndex + 1)

			local startTime = lastTime
			local endTime
			if not nextVelocityData then
				endTime = maxTime
			else
				endTime = math.min(maxTime, nextVelocityData.timePoint.absoluteTime)
			end
			lastTime = endTime

			local speed = velocityData.currentSpeed
			if speed ~= 0 then
				durations[speed] = (durations[speed] or 0) + endTime - startTime
			end
		end
	end
	
	local longestDuration = 0
	local average, minimum, maximum
	
	for speed, duration in pairs(durations) do
		if duration > longestDuration then
			longestDuration = duration
			average = speed
		end
		if not minimum or speed < minimum then
			minimum = speed
		end
		if not maximum or speed > maximum then
			maximum = speed
		end
	end

	local mode = self.value
	if mode == 1 then
		self:applySpeed(average)
	elseif mode == 2 then
		return
	elseif mode == 3 then
		self:applyConstant()
	elseif mode == 4 then
		self:applySpeed(minimum)
	elseif mode == 5 then
		self:applySpeed(maximum)
	end
end

return SpeedMode
