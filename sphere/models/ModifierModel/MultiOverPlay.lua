local NoteData = require("ncdk.NoteData")
local Modifier = require("sphere.models.ModifierModel.Modifier")

---@class sphere.MultiOverPlay: sphere.Modifier
---@operator call: sphere.MultiOverPlay
local MultiOverPlay = Modifier + {}

MultiOverPlay.interfaceType = "stepper"

MultiOverPlay.name = "MultiOverPlay"

MultiOverPlay.defaultValue = 2
MultiOverPlay.values = {2, 3, 4}

MultiOverPlay.description = "1 2 1 2 -> 12 34 12 34, doubles the input mode"

---@param config table
---@return string
---@return string
function MultiOverPlay:getString(config)
	return tostring(config.value), "OP"
end

---@param config table
---@param state table
function MultiOverPlay:applyMeta(config, state)
	local inputMode = state.inputMode

	local value = config.value
	for inputType, inputCount in pairs(inputMode) do
		inputMode[inputType] = inputCount * value
	end
end

---@param config table
function MultiOverPlay:apply(config)
	local noteChart = self.noteChart
	local value = config.value

	local inputMode = noteChart.inputMode

	for _, layerData in noteChart:getLayerDataIterator() do
		for inputType, r in pairs(layerData.noteDatas) do
			local inputCount = inputMode[inputType]
			if inputCount then
				local _r = {}
				for inputIndex, noteDatas in pairs(r) do
					for _, noteData in ipairs(noteDatas) do
						for i = 1, value do
							local newInputIndex = (inputIndex - 1) * value + i
							_r[newInputIndex] = _r[newInputIndex] or {}

							local newNoteData = NoteData(noteData.timePoint)

							newNoteData.endNoteData = noteData.endNoteData  -- fix wrong reference
							newNoteData.noteType = noteData.noteType
							newNoteData.sounds = noteData.sounds

							table.insert(_r[newInputIndex], newNoteData)
						end
					end
				end
				layerData.noteDatas[inputType] = _r
			end
		end
	end

	for inputType, inputCount in pairs(inputMode) do
		inputMode[inputType] = inputCount * value
	end

	noteChart:compute()
end

return MultiOverPlay
