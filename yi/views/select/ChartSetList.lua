local ScrollList = require("yi.views.scroll_list.ScrollList")
local Colors = require("yi.Colors")

---@class yi.ChartSetList : yi.ScrollList
---@overload fun(): yi.ChartSetList
local ChartSetList = ScrollList + {}

ChartSetList.id = "ChartSetList"

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
	local padding = 20
	self.item_height = title_h + artist_h + gap + padding * 2
	self.selected_item_image = love.graphics.newImage("resources/yi/set_selected.png")
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

local x_indent = 20

function ChartSetList:drawItem(index, y, is_selected)
	local items = self.select_model.noteChartSetLibrary.items
	local item = items[index]
	if not item then
		return
	end

	local h = self:getCalculatedHeight()
	local dist = math.abs(index - self.camera.position)
	local items_per_screen = h / self.item_height
	local radius = items_per_screen / 2
	local deadzone = 2.5 -- Middle ~5 items stay fully opaque
	local alpha = math.max(0, 1 - math.pow(math.max(0, dist - deadzone) / math.max(0.1, radius - deadzone), 0.7))

	local w = self:getCalculatedWidth()

	if is_selected then
		local iw, ih = self.selected_item_image:getDimensions()
		love.graphics.setColor(Colors.accent[1], Colors.accent[2], Colors.accent[3], alpha)
		love.graphics.draw(self.selected_item_image, w, y, 0, 4, self.item_height / ih, self.selected_item_image:getWidth())
	end

	local title_h = self.title_font:getHeight()
	local gap = 2
	local padding = 20

	love.graphics.setColor(Colors.text[1], Colors.text[2], Colors.text[3], (Colors.text[4] or 1) * alpha)
	love.graphics.setFont(self.title_font)
	love.graphics.printf(item.title or "Nil Title", -x_indent, y + padding, w, "right")

	love.graphics.setColor(Colors.lines[1], Colors.lines[2], Colors.lines[3], (Colors.lines[4] or 1) * alpha)
	love.graphics.setFont(self.artist_font)
	love.graphics.printf(item.artist or "Nil Artist", -x_indent, y + padding + title_h + gap, w, "right")
end

return ChartSetList
