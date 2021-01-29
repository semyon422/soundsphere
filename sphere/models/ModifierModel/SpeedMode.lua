local Modifier = require("sphere.models.ModifierModel.Modifier")

local SpeedMode = Modifier:new()

SpeedMode.type = "NoteChartModifier"

SpeedMode.name = "SpeedMode"

SpeedMode.defaultValue = 1
SpeedMode.format = "%s"
SpeedMode.range = {1, 5}
SpeedMode.values = {"avg", "x", "const", "min", "max"}

SpeedMode.modeNames = {"AMod", "XMod", "CMod", "MinMod", "MaxMod"}

SpeedMode.getString = function(self, config)
	config = config or self.config
	return self.modeNames[config.value]
end

SpeedMode.applySpeed = function(self, speed)
	local noteChart = self.noteChartModel.noteChart

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
	local noteChart = self.noteChartModel.noteChart

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
	local noteChart = self.noteChartModel.noteChart

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
	local average, minimum, maximum = 1, 1, 1

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

	local mode = self.config.value
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
