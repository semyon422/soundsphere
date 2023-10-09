local class = require("class")
local InputMode = require("ncdk.InputMode")

local PlayContext = class()

---@param modifierModel sphere.ModifierModel
function PlayContext:new(modifierModel)
	self.state = {
		timeRate = 1,
		inputMode = InputMode(),
	}
	self.modifierModel = modifierModel
end

---@param chartItem table
function PlayContext:setChartItem(chartItem)
	self.chartItem = chartItem

	local state = self.state
	state.timeRate = 1
	state.inputMode = InputMode(chartItem.inputMode)

	self.modifierModel:applyMeta(state)
end

return PlayContext
