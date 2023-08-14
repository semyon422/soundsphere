local class = require("class")

local function sort(...)
	local fields = {...}
	for i, field in ipairs(fields) do
		fields[i] = "noteChartDatas." .. field .. " ASC"
	end
	return table.concat(fields, ",")
end

local SortModel = class()

function SortModel:getOrderBy()
	local f = self.sortItemsFunctions[self.name]
	return f[1], f[2]
end

-- 2nd value = isCollapseAllowed (group by setId)
SortModel.sortItemsFunctions = {
	id = {sort("id"), true},
	title = {sort("title", "artist", "creator", "inputMode", "difficulty", "name", "id"), true},
	artist = {sort("artist", "title", "creator", "inputMode", "difficulty", "name", "id"), true},
	difficulty = {sort("difficulty", "name", "id"), false},
	level = {sort("level", "id"), false},
	length = {sort("length", "id"), false},
	bpm = {sort("bpm", "id"), false},
}

SortModel.name = "title"
SortModel.names = {"id", "title", "artist", "difficulty", "level", "length", "bpm"}

return SortModel
