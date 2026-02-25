local ScrollList = require("yi.views.List.ScrollList")
local Colors = require("yi.Colors")

---@class yi.ChartSetList : yi.ScrollList
---@overload fun(): yi.ChartSetList
local ChartSetList = ScrollList + {}

function ChartSetList:load()
	ScrollList.load(self)
	local res = self:getResources()
	local game = self:getGame()
	self.title_font = res:getFont("bold", 24)
	self.artist_font = res:getFont("regular", 16)
	self.select_model = game.selectModel

	local title_h = self.title_font:getHeight()
	local artist_h = self.artist_font:getHeight()
	local gap = 2
	local padding = 25
	self.item_height = title_h + artist_h + gap + padding * 2
end

function ChartSetList:reloadItems()
	self.camera.position = self.select_model.chartview_set_index
end

---@return number
function ChartSetList:getItemCount()
	return #self.select_model.noteChartSetLibrary.items
end

---@return number
function ChartSetList:getSelectedIndex()
	return self.select_model.chartview_set_index
end

---@param index number
function ChartSetList:setSelectedIndex(index)
	self.select_model:scrollNoteChartSet(nil, index)
end

local x_indent = 15

function ChartSetList:drawItem(index, y, is_selected)
	local items = self.select_model.noteChartSetLibrary.items
	local item = items[index]
	if not item then
		return
	end

	local w = self:getCalculatedWidth()

	love.graphics.setColor((index % 2) == 0 and Colors.panels or Colors.panels_alt)
	love.graphics.rectangle("fill", 0, y, w, self.item_height)

	if is_selected then
		love.graphics.setColor(Colors.accent[1], Colors.accent[2], Colors.accent[3], 0.2)
		love.graphics.rectangle("fill", 0, y, w, self.item_height)
	end

	local title_h = self.title_font:getHeight()
	local gap = 2
	local padding = 25

	love.graphics.setColor(Colors.text)
	love.graphics.setFont(self.title_font)
	love.graphics.print(item.title or "Nil Title", x_indent, y + padding)

	love.graphics.setColor(Colors.lines)
	love.graphics.setFont(self.artist_font)
	love.graphics.print(item.artist or "Nil Artist", x_indent, y + padding + title_h + gap)
end

return ChartSetList
