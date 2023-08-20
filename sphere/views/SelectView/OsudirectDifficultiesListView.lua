local ListView = require("sphere.views.ListView")
local TextCellImView = require("sphere.imviews.TextCellImView")
local just = require("just")

local OsudirectDifficultiesListView = ListView()

OsudirectDifficultiesListView.rows = 5

function OsudirectDifficultiesListView:reloadItems()
	self.items = self.game.osudirectModel:getDifficulties()
	if self.itemIndex > #self.items then
		self.targetItemIndex = 1
		self.stateCounter = (self.stateCounter or 0) + 1
	end
end

---@param i number
---@param w number
---@param h number
function OsudirectDifficultiesListView:drawItem(i, w, h)
	local item = self.items[i]

	just.indent(22)
	TextCellImView(math.huge, h, "left", item.beatmapset.creator, item.version)
end

return OsudirectDifficultiesListView
