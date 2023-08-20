local ListView = require("sphere.views.ListView")
local just = require("just")
local TextCellImView = require("sphere.imviews.TextCellImView")

local NoteChartSetListView = ListView()

NoteChartSetListView.rows = 11

function NoteChartSetListView:reloadItems()
	self.stateCounter = self.game.selectModel.noteChartSetStateCounter
	self.items = self.game.noteChartSetLibraryModel.items
end

---@return number
function NoteChartSetListView:getItemIndex()
	return self.game.selectModel.noteChartSetItemIndex
end

---@param count number
function NoteChartSetListView:scroll(count)
	self.game.selectModel:scrollNoteChartSet(count)
end

---@param ... any?
function NoteChartSetListView:draw(...)
	ListView.draw(self, ...)

	local kp = just.keypressed
	if kp("left") then self:scroll(-1)
	elseif kp("right") then self:scroll(1)
	elseif kp("pageup") then self:scroll(-10)
	elseif kp("pagedown") then self:scroll(10)
	elseif kp("home") then self:scroll(-math.huge)
	elseif kp("end") then self:scroll(math.huge)
	end
end

---@param i number
---@param w number
---@param h number
function NoteChartSetListView:drawItem(i, w, h)
	local item = self.items[i]

	if item.lamp then
		love.graphics.circle("fill", 22, 36, 7)
		love.graphics.circle("line", 22, 36, 7)
	end

	just.indent(44)
	TextCellImView(math.huge, h, "left", item.artist, item.title)
end

return NoteChartSetListView
