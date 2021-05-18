local SwapModifier = require("sphere.models.ModifierModel.SwapModifier")

local BracketSwap = SwapModifier:new()

BracketSwap.type = "NoteChartModifier"
BracketSwap.interfaceType = "toggle"

BracketSwap.defaultValue = true
BracketSwap.name = "BracketSwap"
BracketSwap.shortName = "BS"

BracketSwap.hardcodedMaps = {
	[4] = {1, 3, 2, 4},
	[5] = {2, 1, 3, 5, 4}
}

BracketSwap.getMap = function(self, config)
	local noteChart = self.noteChartModel.noteChart

	local keyCount = noteChart.inputMode:getInputCount("key")

	if keyCount <= 5 then
		return {key = self.hardcodedMaps[keyCount]}
	end

	local map = {
		key = {}
	}
	local keymap = map.key

	local half = math.floor(keyCount / 2)
	for i = 1, half do
		keymap[i] = (2 * (i - 1)) % half + 1
		keymap[keyCount - i + 1] = keyCount - (2 * (i - 1)) % half
	end

	return map
end

return BracketSwap
