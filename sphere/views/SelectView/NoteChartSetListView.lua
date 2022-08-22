local ListView = require("sphere.views.ListView")
local just = require("just")
local TextCellImView = require("sphere.imviews.TextCellImView")

local NoteChartSetListView = ListView:new({construct = false})

NoteChartSetListView.reloadItems = function(self)
	self.stateCounter = self.game.selectModel.noteChartSetStateCounter
	self.items = self.game.noteChartSetLibraryModel.items
end

NoteChartSetListView.getItemIndex = function(self)
	return self.game.selectModel.noteChartSetItemIndex
end

NoteChartSetListView.scroll = function(self, count)
	self.game.selectModel:scrollNoteChartSet(count)
end

NoteChartSetListView.drawItem = function(self, i, w, h)
	local item = self.items[i]

	if item.lamp then
		love.graphics.circle("fill", 22, 36, 7)
		love.graphics.circle("line", 22, 36, 7)
	end

	just.indent(44)
	TextCellImView(math.huge, h, "left", item.artist, item.title)
end

return NoteChartSetListView
