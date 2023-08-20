local ListView = require("sphere.views.ListView")
local TextCellImView = require("sphere.imviews.TextCellImView")
local just = require("just")

local OsudirectProcessingListView = ListView()

OsudirectProcessingListView.rows = 11

function OsudirectProcessingListView:reloadItems()
	self.items = self.game.osudirectModel.processing
end

---@param i number
---@param w number
---@param h number
function OsudirectProcessingListView:drawItem(i, w, h)
	local item = self.items[i]

	just.row(true)
	just.indent(44)
	TextCellImView(w - 88, h, "right", item.status, "")
	just.indent(88 - w)
	TextCellImView(math.huge, h, "left", item.artist, item.title)
	just.row()
end

return OsudirectProcessingListView
