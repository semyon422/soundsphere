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
		for inputType, r in pairs(layerData.noteDatas) do
			local submap = map[inputType]
			if submap then
				local _r = {}
				for old, new in pairs(submap) do
					_r[new] = r[old]
				end
				layerData.noteDatas[inputType] = _r
			end
		end
	end
end

return SwapModifier
