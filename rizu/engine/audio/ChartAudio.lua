local class = require("class")
local table_util = require("table_util")

---@class rizu.ChartAudioSound
---@field time number
---@field name string
---@field volume number?
---@field pan number?

---@class rizu.ChartAudio
---@operator call: rizu.ChartAudio
local ChartAudio = class()

local playable_types = table_util.invert({
	"tap",
	"hold",
})

function ChartAudio:new()
	---@type rizu.ChartAudioSound[]
	self.sounds = {}
end

function ChartAudio:sort()
	table.sort(self.sounds, function(a, b)
		if a.time ~= a.time then
			return a.time < b.time
		end
		return a.name < b.name
	end)
end

---@param chart ncdk2.Chart
---@param with_playable boolean?
function ChartAudio:load(chart, with_playable)
	local sounds = self.sounds

	for _, note in chart.notes:iter() do
		---@cast note notechart.Note
		if note.data.sounds and (with_playable or not playable_types[note.type]) then
			for _, sound in ipairs(note.data.sounds) do
				table.insert(sounds, {
					time = note.visualPoint.point.absoluteTime,
					name = sound[1],
					volume = sound[2],
				})
			end
		end
	end

	self:sort()
end

return ChartAudio
