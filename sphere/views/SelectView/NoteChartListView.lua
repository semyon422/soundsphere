local ListView = require("sphere.views.ListView")
local just = require("just")
local TextCellImView = require("sphere.imviews.TextCellImView")
local Format = require("sphere.views.Format")

local NoteChartListView = ListView:new()

NoteChartListView.rows = 5

NoteChartListView.reloadItems = function(self)
	self.stateCounter = self.game.selectModel.noteChartStateCounter
	self.items = self.game.noteChartLibraryModel.items
end

NoteChartListView.getItemIndex = function(self)
	return self.game.selectModel.noteChartItemIndex
end

NoteChartListView.scroll = function(self, count)
	self.game.selectModel:scrollNoteChart(count)
end

NoteChartListView.draw = function(self, ...)
	ListView.draw(self, ...)

	if just.keypressed("up") then self:scroll(-1)
	elseif just.keypressed("down") then self:scroll(1)
	end
end

NoteChartListView.drawItem = function(self, i, w, h)
	local items = self.items
	local item = items[i]

	just.indent(18)

	local baseTimeRate = self.game.rhythmModel.timeEngine.baseTimeRate

	local difficulty = Format.difficulty((item.difficulty or 0) * baseTimeRate)
	local inputMode = item.inputMode
	local name = item.name
	local creator = item.creator
	if items[i - 1] and items[i - 1].inputMode == inputMode then
		inputMode = ""
	end
	if items[i - 1] and items[i - 1].creator == creator then
		creator = ""
	end

	TextCellImView(72, h, "right", Format.inputMode(inputMode), difficulty, true)
	just.sameline()

	if item.lamp then
		love.graphics.circle("fill", 22, 36, 7)
		love.graphics.circle("line", 22, 36, 7)
	end
	just.indent(44)

	TextCellImView(math.huge, h, "left", creator, name)
end

return NoteChartListView
