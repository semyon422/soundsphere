local Modifier = require("sphere.models.ModifierModel.Modifier")

---@class sphere.NoScratch: sphere.Modifier
---@operator call: sphere.NoScratch
local NoScratch = Modifier + {}

NoScratch.type = "NoteChartModifier"
NoScratch.interfaceType = "toggle"

NoScratch.defaultValue = true
NoScratch.name = "NoScratch"
NoScratch.shortName = "NSC"

NoScratch.description = "Remove scratch notes"

---@param config table
---@return string?
function NoScratch:getString(config)
	if not config.value then
		return
	end
	return Modifier.getString(self, config)
end

---@param config table
---@param state table
function NoScratch:applyMeta(config, state)
	if not config.value then
		return
	end
	state.inputMode.scratch = nil
end

---@param config table
function NoScratch:apply(config)
	if not config.value then
		return
	end

	local noteChart = self.noteChart

	noteChart.inputMode.scratch = nil

	for _, layerData in noteChart:getLayerDataIterator() do
		if layerData.noteDatas.scratch then
			for _, noteDatas in ipairs(layerData.noteDatas.scratch) do
				for _, noteData in ipairs(noteDatas) do
					noteData.noteType = "SoundNote"
					layerData:addNoteData(noteData, "auto", 0)
				end
			end
			layerData.noteDatas.scratch = nil
		end
	end
end

return NoScratch
