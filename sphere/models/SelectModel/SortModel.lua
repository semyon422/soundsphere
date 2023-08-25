local class = require("class")

---@class sphere.SortModel
---@operator call: sphere.SortModel
local SortModel = class()

-- 2nd value = isCollapseAllowed (group by setId)
SortModel.orders = {
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
