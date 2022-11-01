local Modifier = require("sphere.models.ModifierModel.Modifier")

local SwapModifier = Modifier:new()

SwapModifier.type = "NoteChartModifier"
SwapModifier.interfaceType = "toggle"

SwapModifier.name = "SwapModifier"

SwapModifier.apply = function(self, config)
	if not config.value then
		return
	end

	local map = self:getMap(config)

	local noteChart = self.game.noteChartModel.noteChart

	for _, layerData in noteChart:getLayerDataIterator() do
		for noteDataIndex = 1, layerData:getNoteDataCount() do
			local noteData = layerData:getNoteData(noteDataIndex)
			local submap = map[noteData.inputType]
			if submap and submap[noteData.inputIndex] then
				noteChart:increaseInputCount(noteData.inputType, noteData.inputIndex, -1)
				noteData.inputIndex = submap[noteData.inputIndex]
				noteChart:increaseInputCount(noteData.inputType, noteData.inputIndex, 1)
			end
		end
	end
end

return SwapModifier
