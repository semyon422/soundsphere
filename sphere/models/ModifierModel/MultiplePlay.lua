local NoteData = require("ncdk.NoteData")
local Modifier = require("sphere.models.ModifierModel.Modifier")
local MultiOverPlay = require("sphere.models.ModifierModel.MultiOverPlay")

---@class sphere.MultiplePlay: sphere.Modifier
---@operator call: sphere.MultiplePlay
local MultiplePlay = Modifier + {}

MultiplePlay.name = "MultiplePlay"

MultiplePlay.defaultValue = 2
MultiplePlay.values = {2, 3, 4}

MultiplePlay.description = "1 2 1 2 -> 13 24 13 24, doubles the input mode"

---@param config table
---@return string
---@return string
function MultiplePlay:getString(config)
	return tostring(config.value), "P"
end

MultiplePlay.applyMeta = MultiOverPlay.applyMeta

---@param config table
function MultiplePlay:apply(config)
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
							local newInputIndex = inputIndex + inputCount * (i - 1)
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

return MultiplePlay
