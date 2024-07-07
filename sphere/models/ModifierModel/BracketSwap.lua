local SwapModifier = require("sphere.models.ModifierModel.SwapModifier")

---@class sphere.BracketSwap: sphere.SwapModifier
---@operator call: sphere.BracketSwap
local BracketSwap = SwapModifier + {}

BracketSwap.name = "BracketSwap"
BracketSwap.shortName = "BS"

BracketSwap.description = "Brackets to connected chords"

local hardcodedMaps = {
	[4] = {1, 3, 2, 4},
	[5] = {2, 1, 3, 5, 4}
}

for _, t in pairs(hardcodedMaps) do
	for i, v in ipairs(t) do
		t[i] = nil
		t["key" .. i] = "key" .. v
	end
end

---@param config table
---@return table
function BracketSwap:getMap(config)
	local keyCount = self.chart.inputMode.key

	if keyCount <= 5 then
		return hardcodedMaps[keyCount] or {}
	end

	local map = {}

	local half = math.floor(keyCount / 2)
	for i = 1, half do
		map["key" .. i] = "key" .. ((2 * (i - 1)) % half + 1)
		map["key" .. (keyCount - i + 1)] = "key" .. (keyCount - (2 * (i - 1)) % half)
	end

	return map
end

return BracketSwap
