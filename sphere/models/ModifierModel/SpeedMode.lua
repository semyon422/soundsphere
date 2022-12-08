local Modifier = require("sphere.models.ModifierModel.Modifier")

local SpeedMode = Modifier:new()

SpeedMode.type = "NoteChartModifier"
SpeedMode.interfaceType = "stepper"

SpeedMode.name = "SpeedMode"

SpeedMode.defaultValue = "average"
SpeedMode.range = {1, 5}
SpeedMode.values = {"average", "x", "constant", "minimum", "maximum"}

SpeedMode.modeNames = {"A", "X", "C", "MIN", "MAX"}

SpeedMode.description = "AMod, XMod, CMod, MinMod, MaxMod"

SpeedMode.getString = function(self, config)
	local indexValue = self:toIndexValue(config.value)
	return self.modeNames[indexValue]
end

SpeedMode.getSubString = function(self, config)
	return "MOD"
end

SpeedMode.applySpeed = function(self, speed)
	local noteChart = self.game.noteChartModel.noteChart

	for _, layerData in noteChart:getLayerDataIterator() do
		for velocityDataIndex = 1, layerData:getVelocityDataCount() do
			local velocityData = layerData:getVelocityData(velocityDataIndex)
			velocityData.currentSpeed = velocityData.currentSpeed / speed
		end
	end

	noteChart:compute()
end

SpeedMode.applyConstant = function(self)
	local noteChart = self.game.noteChartModel.noteChart

	for _, layerData in noteChart:getLayerDataIterator() do
		layerData:setPrimaryTempo(0)
		for velocityDataIndex = 1, layerData:getVelocityDataCount() do
			local velocityData = layerData:getVelocityData(velocityDataIndex)

			velocityData.currentSpeed = 1
			velocityData.localSpeed = 1
			velocityData.globalSpeed = 1
		end
	end

	noteChart:compute()
end

SpeedMode.apply = function(self, config)
	local noteChart = self.game.noteChartModel.noteChart

	local minTime = noteChart.metaData.minTime
	local maxTime = noteChart.metaData.maxTime

	local lastTime = minTime
	local durations = {}

	for _, layerData in noteChart:getLayerDataIterator() do
		for velocityDataIndex = 1, layerData:getVelocityDataCount() do
			local velocityData = layerData:getVelocityData(velocityDataIndex)
			local nextVelocityData = layerData:getVelocityData(velocityDataIndex + 1)

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

	local mode = config.value
	if mode == "average" then
		self:applySpeed(average)
	elseif mode == "x" then
		return
	elseif mode == "constant" then
		self:applyConstant()
	elseif mode == "minimum" then
		self:applySpeed(minimum)
	elseif mode == "maximum" then
		self:applySpeed(maximum)
	end
end

return SpeedMode
