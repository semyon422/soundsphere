local Modifier = require("sphere.models.ModifierModel.Modifier")

---@class sphere.SpeedMode: sphere.Modifier
---@operator call: sphere.SpeedMode
local SpeedMode = Modifier + {}

SpeedMode.type = "NoteChartModifier"
SpeedMode.interfaceType = "stepper"

SpeedMode.name = "SpeedMode"

SpeedMode.defaultValue = "average"
SpeedMode.range = {1, 5}
SpeedMode.values = {"average", "x", "constant", "minimum", "maximum"}

SpeedMode.modeNames = {"A", "X", "C", "MIN", "MAX"}

SpeedMode.description = "AMod, XMod, CMod, MinMod, MaxMod"

---@param config table
---@return string
function SpeedMode:getString(config)
	local indexValue = self:toIndexValue(config.value)
	return self.modeNames[indexValue]
end

---@param config table
---@return string
function SpeedMode:getSubString(config)
	return "MOD"
end

---@param config table
---@param state table
function SpeedMode:applyMeta(config, state)
	local mode = config.value
	if mode == "constant" then
		state.constant = true
	end
end

---@param tempo number
function SpeedMode:applyTempo(tempo)
	local noteChart = self.noteChart

	for _, layerData in noteChart:getLayerDataIterator() do
		layerData:setPrimaryTempo(tempo)
	end

	noteChart:compute()
end

---@param config table
function SpeedMode:apply(config)
	local mode = config.value
	if mode == "x" or mode == "constant" then
		return
	end

	local noteChart = self.noteChart

	local minTime = noteChart.metaData.minTime
	local maxTime = noteChart.metaData.maxTime

	local lastTime = minTime
	local durations = {}

	for _, layerData in noteChart:getLayerDataIterator() do
		for tempoDataIndex = 1, layerData:getTempoDataCount() do
			local tempoData = layerData:getTempoData(tempoDataIndex)
			local nextTempoData = layerData:getTempoData(tempoDataIndex + 1)

			local startTime = lastTime
			local endTime
			if not nextTempoData then
				endTime = maxTime
			else
				endTime = math.min(maxTime, nextTempoData.timePoint.absoluteTime)
			end
			lastTime = endTime

			local tempo = tempoData.tempo
			durations[tempo] = (durations[tempo] or 0) + endTime - startTime
		end
	end

	local longestDuration = 0
	local average, minimum, maximum = 1, 1, 1

	for tempo, duration in pairs(durations) do
		if duration > longestDuration then
			longestDuration = duration
			average = tempo
		end
		if not minimum or tempo < minimum then
			minimum = tempo
		end
		if not maximum or tempo > maximum then
			maximum = tempo
		end
	end

	if mode == "average" then
		self:applyTempo(average)
	elseif mode == "minimum" then
		self:applyTempo(minimum)
	elseif mode == "maximum" then
		self:applyTempo(maximum)
	end
end

return SpeedMode
