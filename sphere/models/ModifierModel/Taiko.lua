local Modifier = require("sphere.models.ModifierModel.Modifier")
local InputMode = require("ncdk.InputMode")
local Notes = require("ncdk2.notes.Notes")

---@class sphere.Taiko: sphere.Modifier
---@operator call: sphere.Taiko
local Taiko = Modifier + {}

Taiko.name = "Taiko"
Taiko.shortName = "TK"

Taiko.description = "Converts mania 4K to taiko 2K (experimental)"

function Taiko:applyMeta(config, state)
	if state.inputMode.key ~= 4 then
		return
	end
	state.inputMode.key = 2
end

local function getKey(i)
	if i == 1 or i == 4 then
		return 2
	end
	return 1
end

---@param config table
---@param chart ncdk2.Chart
function Taiko:apply(config, chart)
	local inputMode = chart.inputMode

	if tostring(inputMode) ~= "4key" then
		return
	end

	for _, layer in pairs(chart.layers) do
		local new_notes = Notes()
		for column, notes in layer.notes:iter() do
			local inputType, inputIndex = InputMode:splitInput(column)
			local new_column = column
			if inputType == "key" then
				new_column = inputType .. getKey(inputIndex)
			end
			for _, note in ipairs(notes) do
				new_notes:insert(note, new_column)
			end
		end
		layer.notes = new_notes
		new_notes:sort()

		local t, n
		for _, notes in new_notes:iter() do
			for _, note in ipairs(notes) do
				local _t = note.visualPoint.point.absoluteTime
				if _t ~= t then
					t = _t
					n = note
				else
					n.isDouble = true
					note.noteType = "Ignore"
				end
			end
		end
	end

	inputMode.key = 2

	chart:compute()
end

return Taiko
