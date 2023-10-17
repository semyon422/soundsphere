local Modifier = require("sphere.models.ModifierModel.Modifier")

---@class sphere.MinLnLength: sphere.Modifier
---@operator call: sphere.MinLnLength
local MinLnLength = Modifier + {}

MinLnLength.name = "MinLnLength"

MinLnLength.defaultValue = 0.4
MinLnLength.values = {}

for i = 0, 39 do
	table.insert(MinLnLength.values, i * 0.025)  -- [0, 1)
end
for i = 0, 40 do
	table.insert(MinLnLength.values, 1 + i * 0.1)
end

MinLnLength.description = "Convert long notes to short notes if they are shorter than this length"

---@param config table
---@return string
---@return string
function MinLnLength:getString(config)
	return "MLL", tostring(config.value * 1000)
end

---@param config table
function MinLnLength:apply(config)
	local duration = config.value
	local noteChart = self.noteChart

	for noteDatas in noteChart:getInputIterator() do
		for _, noteData in ipairs(noteDatas) do
			if noteData.noteType == "LongNoteStart" or noteData.noteType == "LaserNoteStart" then
				if (noteData.endNoteData.timePoint.absoluteTime - noteData.timePoint.absoluteTime) <= duration then
					noteData.noteType = "ShortNote"
					noteData.endNoteData.noteType = "Ignore"
				end
			end
		end
	end
end

return MinLnLength
