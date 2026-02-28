local class = require("class")
local ResourceFinder = require("rizu.files.ResourceFinder")
local path_util = require("path_util")

---@class rizu.ChartVisual
---@operator call: rizu.ChartVisual
local ChartVisual = class()

function ChartVisual:new()
	---@type string[]
	self.image_names = {}
	---@type string[]
	self.video_names = {}
end

---@param chart ncdk2.Chart
function ChartVisual:load(chart)
	---@type {[string]: boolean}
	local image_names_map = {}
	---@type {[string]: boolean}
	local video_names_map = {}

	for _, note in chart.notes:iter() do
		---@cast note notechart.Note
		if note.data.images then
			for _, image in ipairs(note.data.images) do
				---@type string
				local name = image[1]
				if not (image_names_map[name] or video_names_map[name]) then
					local _, ext = path_util.name_ext(name)
					local format = ResourceFinder:getFormat(ext)
					if format == "video" then
						video_names_map[name] = true
					else
						image_names_map[name] = true
					end
				end
			end
		end
	end

	for name in pairs(image_names_map) do
		table.insert(self.image_names, name)
	end
	for name in pairs(video_names_map) do
		table.insert(self.video_names, name)
	end
end

return ChartVisual
