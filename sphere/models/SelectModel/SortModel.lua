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
	["notes count"] = {{"notes_count"}, false},
	duration = {{"duration"}, false},
	tempo = {{"tempo"}, false},
	modtime = {{"modified_at"}, false},
	["set modtime"] = {{"set_modified_at"}, true},
	["last played"] = {{"score_time"}, false},
}

SortModel.name = "title"
SortModel.names = {
	"id",
	"title",
	"artist",
	"difficulty",
	"level",
	"notes count",
	"duration",
	"tempo",
	"modtime",
	"set modtime",
	"last played",
}

return SortModel
