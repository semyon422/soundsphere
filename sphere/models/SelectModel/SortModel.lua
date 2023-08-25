local class = require("class")

---@class sphere.SortModel
---@operator call: sphere.SortModel
local SortModel = class()

---@return table
---@return boolean
function SortModel:getOrderBy()
	local f = self.sortItemsFunctions[self.name]
	return f[1], f[2]
end

-- 2nd value = isCollapseAllowed (group by setId)
SortModel.sortItemsFunctions = {
	id = {{"id"}, true},
	title = {{"title", "artist", "id"}, true},
	artist = {{"artist", "title", "id"}, true},
	difficulty = {{"difficulty", "name", "id"}, false},
	level = {{"level", "id"}, false},
	length = {{"length", "id"}, false},
	bpm = {{"bpm", "id"}, false},
}

SortModel.name = "title"
SortModel.names = {"id", "title", "artist", "difficulty", "level", "length", "bpm"}

return SortModel
