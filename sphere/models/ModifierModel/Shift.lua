local SwapModifier = require("sphere.models.ModifierModel.SwapModifier")

---@class sphere.Shift: sphere.SwapModifier
---@operator call: sphere.Shift
local Shift = SwapModifier + {}

Shift.type = "NoteChartModifier"
Shift.interfaceType = "slider"

Shift.name = "Shift"

Shift.defaultValue = 0
Shift.range = {-5, 5}

Shift.description = "Shift the note chart"

---@param config table
---@return string?
function Shift:getString(config)
    if config.value > 0 then
        return "S+"
    elseif config.value < 0 then
        return "S-"
    end
end

---@param config table
---@return number
function Shift:getSubString(config)
    return math.abs(config.value)
end

---@param config table
---@return table
function Shift:getMap(config)
	local noteChart = self.noteChart

	local map = {}

	local value = config.value
	for inputType, inputCount in pairs(noteChart.inputMode) do
		map[inputType] = {}
		local submap = map[inputType]
		for i = 1, inputCount do
			submap[i] = (i + value - 1) % inputCount + 1
		end
	end

	return map
end

return Shift
