local SwapModifier = require("sphere.models.ModifierModel.SwapModifier")

local Shift = SwapModifier:new()

Shift.type = "NoteChartModifier"
Shift.interfaceType = "slider"

Shift.name = "Shift"

Shift.defaultValue = 0
Shift.range = {-5, 5}

Shift.description = "Shift the note chart"

Shift.getString = function(self, config)
    if config.value > 0 then
        return "S+"
    elseif config.value < 0 then
        return "S-"
    end
end

Shift.getSubString = function(self, config)
    return math.abs(config.value)
end

Shift.getMap = function(self, config)
	local noteChart = self.game.noteChartModel.noteChart

	local inputCounts = {}
	for inputType, inputIndex in noteChart:getInputIterator() do
		if not inputCounts[inputType] then
			local inputCount = noteChart.inputMode[inputType]
			if inputCount then
				inputCounts[inputType] = inputCount
			end
		end
	end

	local map = {}

	local value = config.value
	for inputType, inputCount in pairs(inputCounts) do
		map[inputType] = {}
		local submap = map[inputType]
		for i = 1, inputCount do
			submap[i] = (i + value - 1) % inputCount + 1
		end
	end

	return map
end

return Shift
