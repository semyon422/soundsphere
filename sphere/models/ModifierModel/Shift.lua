local SwapModifier = require("sphere.models.ModifierModel.SwapModifier")

local Shift = SwapModifier:new()

Shift.sequential = true
Shift.type = "NoteChartModifier"

Shift.name = "Shift"
Shift.shortName = "Shift"

Shift.variableType = "number"
Shift.variableName = "value"

Shift.variableFormat = "%3s"
Shift.variableRange = {-5, 1, 5}

Shift.value = 0

Shift.tostring = function(self)
    if self.value > 0 then
        return self.shortName .. "+" .. self.value
    elseif self.value < 0 then
        return self.shortName .. "-" .. -self.value
    else
        return self.shortName .. self.value
    end
end

Shift.tojson = function(self)
	return ([[{"name":"%s","value":%s}]]):format(self.name, self.value)
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
