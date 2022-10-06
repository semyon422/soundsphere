local ListView = require("sphere.views.ListView")
local TextCellImView = require("sphere.imviews.TextCellImView")
local just = require("just")

local OsudirectProcessingListView = ListView:new()

OsudirectProcessingListView.rows = 11

OsudirectProcessingListView.reloadItems = function(self)
	self.items = self.game.osudirectModel.processing
end

OsudirectProcessingListView.drawItem = function(self, i, w, h)
	local item = self.items[i]

	just.row(true)
	just.indent(44)
	TextCellImView(w - 88, h, "right", item.status, "")
	just.indent(88 - w)
	TextCellImView(math.huge, h, "left", item.artist, item.title)
	just.row(false)
end

return OsudirectProcessingListView
