local ListView = require("sphere.views.ListView")
local just = require("just")
local TextCellImView = require("sphere.imviews.TextCellImView")
local Format = require("sphere.views.Format")

local NoteChartListView = ListView()

NoteChartListView.rows = 5

function NoteChartListView:reloadItems()
	self.stateCounter = self.game.selectModel.noteChartStateCounter
	self.items = self.game.selectModel.noteChartLibrary.items
end

---@return number
function NoteChartListView:getItemIndex()
	return self.game.selectModel.chartview_index
end

---@param count number
function NoteChartListView:scroll(count)
	self.game.selectModel:scrollNoteChart(count)
end

---@param ... any?
function NoteChartListView:draw(...)
	ListView.draw(self, ...)

	if just.keypressed("up") then self:scroll(-1)
	elseif just.keypressed("down") then self:scroll(1)
	end
end

---@param i number
---@param w number
---@param h number
function NoteChartListView:drawItem(i, w, h)
	local items = self.items
	local item = items[i]

	just.indent(18)

	local baseTimeRate = self.game.playContext.rate
	if self.game.configModel.configs.settings.select.chartdiffs_list then
		baseTimeRate = 1
	end

	local difficulty = item.difficulty and Format.difficulty(item.difficulty * baseTimeRate) or ""

	local inputmode = item.chartdiff_inputmode and Format.inputMode(item.chartdiff_inputmode) or ""
	local creator = item.creator or ""
	local name = item.name or item.chartfile_name

	if items[i - 1] and items[i - 1].chartdiff_inputmode == item.chartdiff_inputmode then
		inputmode = ""
	end
	if items[i - 1] and items[i - 1].creator == item.creator then
		creator = ""
	end

	love.graphics.setColor(1, 1, 1, 1)

	TextCellImView(72, h, "right", inputmode, difficulty, true)
	just.sameline()

	if item.lamp then
		love.graphics.circle("fill", 22, 36, 7)
		love.graphics.circle("line", 22, 36, 7)
	end
	just.indent(44)

	if not item.chartmeta_id then
		love.graphics.setColor(1, 1, 1, 0.5)
	end
	TextCellImView(math.huge, h, "left", creator, name)
end

return NoteChartListView
