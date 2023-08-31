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

-- 2nd value = isCollapseAllowed (group by setId)
SortModel.orders = {
	id = {{}, true},
	title = {{"noteChartDatas.title", "noteChartDatas.artist"}, true},
	artist = {{"noteChartDatas.artist", "noteChartDatas.title"}, true},
	difficulty = {{"noteChartDatas.difficulty", "noteChartDatas.name"}, false},
	level = {{"noteChartDatas.level"}, false},
	length = {{"noteChartDatas.length"}, false},
	bpm = {{"noteChartDatas.bpm"}, false},
	["played top"] = {{"scores.id"}, false},
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
