local SwapModifier = require("sphere.models.ModifierModel.SwapModifier")

local Shift = SwapModifier:new()

Shift.sequential = true
Shift.type = "NoteChartModifier"

Shift.name = "Shift"
Shift.shortName = "Shift"

Shift.defaultValue = 0
Shift.range = {-5, 5}

Shift.getString = function(self)
    return self.shortName .. self:getRealValue()
end

Shift.getRealValue = function(self, config)
	config = config or self.config
    if config.value > 0 then
        return "+" .. config.value
    elseif config.value < 0 then
        return "-" .. -config.value
    else
        return config.value
    end
end

Shift.getMap = function(self)
	local noteChart = self.noteChartModel.noteChart

	local inputCounts = {}
	for inputType, inputIndex in noteChart:getInputIteraator() do
		if not inputCounts[inputType] then
			local inputCount = noteChart.inputMode:getInputCount(inputType)
			if inputCount > 0 then
				inputCounts[inputType] = inputCount
			end
		end
	end

	local map = {}

	local value = self.value
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
