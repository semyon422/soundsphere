local SwapModifier = require("sphere.models.ModifierModel.SwapModifier")

---@class sphere.BracketSwap: sphere.SwapModifier
---@operator call: sphere.BracketSwap
local BracketSwap = SwapModifier + {}

BracketSwap.interfaceType = "toggle"

BracketSwap.defaultValue = true
BracketSwap.name = "BracketSwap"
BracketSwap.shortName = "BS"

BracketSwap.description = "Brackets to connected chords"

---@param config table
---@return string?
function BracketSwap:getString(config)
	if not config.value then
		return
	end
	return SwapModifier.getString(self)
end

BracketSwap.hardcodedMaps = {
	[4] = {1, 3, 2, 4},
	[5] = {2, 1, 3, 5, 4}
}

---@param config table
---@return table
function BracketSwap:getMap(config)
	local keyCount = self.noteChart.inputMode.key

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
