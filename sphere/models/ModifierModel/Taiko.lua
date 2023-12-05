local Modifier = require("sphere.models.ModifierModel.Modifier")

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

local function sort_notes(a, b)
	return a.timePoint.absoluteTime < b.timePoint.absoluteTime
end

---@param config table
function Taiko:apply(config)
	local noteChart = self.noteChart

	local inputMode = noteChart.inputMode
	local keys = inputMode.key

	if keys ~= 4 then
		return
	end

	for _, layerData in noteChart:getLayerDataIterator() do
		if layerData.noteDatas.key then
			local notes = {}
			for inputIndex, noteDatas in pairs(layerData.noteDatas.key) do
				local i = getKey(inputIndex)
				notes[i] = notes[i] or {}
				for _, nd in ipairs(noteDatas) do
					table.insert(notes[i], nd)
				end
			end
			layerData.noteDatas.key = notes

			local t, n
			for _, noteDatas in ipairs(notes) do
				table.sort(noteDatas, sort_notes)
				for _, noteData in ipairs(noteDatas) do
					local _t = noteData.timePoint.absoluteTime
					if _t ~= t then
						t = _t
						n = noteData
					else
						n.isDouble = true
						noteData.noteType = "Ignore"
					end
				end
			end
		end
	end

	inputMode.key = 2

	noteChart:compute()
end

return Taiko
