local class = require("class")

---@class sphere.SortModel
---@operator call: sphere.SortModel
local SortModel = class()

---@param name string
---@return table
---@return boolean
function SortModel:getOrder(name)
	local order = self.orders[name] or self.orders.id
	return unpack(order)
end

-- 2nd value = isCollapseAllowed (group by chartfile_set_id)
SortModel.orders = {
	id = {{}, true},
	title = {{"title", "artist"}, true},
	artist = {{"artist", "title"}, true},
	difficulty = {{"difficulty", "name"}, false},
	level = {{"level"}, false},
	length = {{"length"}, false},
	bpm = {{"bpm"}, false},
	["played top"] = {{"score_id"}, false},
}

SortModel.name = "title"
SortModel.names = {
	"id",
	"title",
	"artist",
	"difficulty",
	"level",
	"length",
	"bpm",
	"played top",
}

return SortModel
