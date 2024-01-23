local class = require("class")
local enps = require("libchart.enps")

---@class sphere.DifficultyModel
---@operator call: sphere.DifficultyModel
local DifficultyModel = class()

---@param noteChart ncdk.NoteChart
---@param timeRate number?
---@return number
---@return number
---@return number
function DifficultyModel:getDifficulty(noteChart, timeRate)
	local notes = {}

	local longNoteCount = 0
	local minTime = math.huge
	local maxTime = -math.huge
	for noteDatas, inputType, inputIndex, layerDataIndex in noteChart:getInputIterator() do
		for _, noteData in ipairs(noteDatas) do
			local st = noteData.timePoint.absoluteTime
			if
				noteData.noteType == "ShortNote" or
				noteData.noteType == "LongNoteStart" or
				noteData.noteType == "LaserNoteStart"
			then
				notes[#notes + 1] = {
					time = st,
					input = inputType .. inputIndex,
				}

				minTime = math.min(minTime, st)
				maxTime = math.max(maxTime, st)
			end

			if noteData.noteType == "LongNoteStart" then
				local et = noteData.endNoteData.timePoint.absoluteTime
				longNoteCount = longNoteCount + 1
				minTime = math.min(minTime, et)
				maxTime = math.max(maxTime, et)
			end
		end
	end
	table.sort(notes, function(a, b) return a.time < b.time end)

	local enpsValue = enps.getEnps(notes)

	return enpsValue * (timeRate or 1), longNoteCount, #notes
end

return DifficultyModel
