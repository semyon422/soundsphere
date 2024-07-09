local table_util = require("table_util")
local Modifier = require("sphere.models.ModifierModel.Modifier")
local Notes = require("ncdk2.notes.Notes")

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

	local new_notes = Notes()
	for _, note in chart.notes:iter() do
		note.column = map[note.column] or note.column
		new_notes:insert(note)
	end
	chart.notes = new_notes
end

return SwapModifier
