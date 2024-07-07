local table_util = require("table_util")
local Modifier = require("sphere.models.ModifierModel.Modifier")

---@class sphere.SwapModifier: sphere.Modifier
---@operator call: sphere.SwapModifier
local SwapModifier = Modifier + {}

SwapModifier.name = "SwapModifier"

---@param config table
---@return {[ncdk2.Column]: ncdk2.Column}
function SwapModifier:getMap(config)
	return {}
end

---@param config table
---@param chart ncdk2.Chart
function SwapModifier:apply(config, chart)
	self.chart = chart
	local map = self:getMap(config)

	for _, layer in pairs(chart.layers) do
		local column_notes = layer.notes.column_notes
		local new_column_notes = table_util.copy(column_notes)
		for old, new in pairs(map) do
			new_column_notes[new] = column_notes[old]
		end
		layer.notes.column_notes = new_column_notes
	end
end

return SwapModifier
