local View = require("yi.views.View")

---@class yi.ElasticList : yi.View
---@operator call: yi.ElasticList
---@field flex_values number[]
local ElasticList = View + {}

ElasticList.id = "ElasticList"
ElasticList.SelectedWidth = 150
ElasticList.UnselectedWidth = 50
ElasticList.Gap = 10
ElasticList.FlexAnimationAlpha = 0.12
ElasticList.ScrollAnimationAlpha = 0.2

function ElasticList:new()
	View.new(self)
	self.flex_values = {}
	self.scroll_offset = 0
	self.total_content_width = 0
	self.handles_mouse_input = true
end

---@param total_width number
---@param num_items integer
---@param target_px number
---@return number
local function get_target_flex_for_selected(total_width, num_items, target_px)
	if num_items <= 1 or total_width <= target_px then
		return 1
	end
	return (target_px * (num_items - 1)) / (total_width - target_px)
end

---@param frame_alpha number
---@param dt number
---@return number
local function get_time_based_alpha(frame_alpha, dt)
	if dt <= 0 then
		return 0
	end
	return 1 - (1 - frame_alpha) ^ (dt * 60)
end

---@param item_count integer
---@param selected_index integer?
---@return integer
local function clamp_selected_index(item_count, selected_index)
	if item_count <= 0 then
		return 0
	end
	return math.max(1, math.min(item_count, selected_index or 1))
end

---@return any[]
function ElasticList:getItems()
	return {}
end

---@return integer
function ElasticList:getSelectedIndex()
	return 1
end

---@param index integer
function ElasticList:selectItem(index) end

---@param item_count integer
---@return number
function ElasticList:getContentWidth(item_count)
	if item_count <= 0 then
		return 0
	end
	return (item_count - 1) * self.UnselectedWidth + self.SelectedWidth
end

---@param item_count integer
---@param selected_index integer
---@return number
function ElasticList:getTargetScroll(item_count, selected_index)
	if item_count <= 1 then
		return 0
	end

	local width = self:getCalculatedWidth()
	local selected_width = self.SelectedWidth
	local unselected_width = (self.total_content_width - selected_width) / (item_count - 1)
	local selected_center = ((selected_index - 1) * unselected_width) + (selected_width / 2)
	local target_scroll = math.max(0, selected_center - width / 2)
	local max_scroll = math.max(0, self.total_content_width - width)

	return math.min(target_scroll, max_scroll)
end

---@param item_count integer
---@param selected_index integer
function ElasticList:resetLayoutState(item_count, selected_index)
	self.total_content_width = self:getContentWidth(item_count)
	self.flex_values = {}

	if item_count <= 0 then
		self.scroll_offset = 0
		return
	end

	local selected_flex = get_target_flex_for_selected(self.total_content_width, item_count, self.SelectedWidth)
	for i = 1, item_count do
		self.flex_values[i] = (i == selected_index) and selected_flex or 1
	end

	self.scroll_offset = self:getTargetScroll(item_count, selected_index)
end

---@param item_count integer
---@param selected_index integer?
---@return integer
function ElasticList:ensureLayoutState(item_count, selected_index)
	selected_index = clamp_selected_index(item_count, selected_index)

	if item_count <= 0 then
		if self.total_content_width ~= 0 or self.scroll_offset ~= 0 or #self.flex_values ~= 0 then
			self:resetLayoutState(0, 0)
		end
		return 0
	end

	local content_width = self:getContentWidth(item_count)
	if self.total_content_width ~= content_width or #self.flex_values ~= item_count then
		self:resetLayoutState(item_count, selected_index)
		return selected_index
	end

	for i = 1, item_count do
		if self.flex_values[i] == nil then
			self:resetLayoutState(item_count, selected_index)
			return selected_index
		end
	end

	local max_scroll = math.max(0, self.total_content_width - self:getCalculatedWidth())
	self.scroll_offset = math.max(0, math.min(self.scroll_offset, max_scroll))

	return selected_index
end

function ElasticList:reloadItems()
	local items = assert(self:getItems(), "Items is nil")
	local selected_index = assert(self:getSelectedIndex(), "Selected index is nil")
	self:resetLayoutState(#items, clamp_selected_index(#items, selected_index))
end

---@param e ui.ScrollEvent
function ElasticList:onScroll(e)
	local items = self:getItems()
	local item_count = #items
	local selected_index = clamp_selected_index(item_count, self:getSelectedIndex())

	if item_count == 0 then
		return
	end

	if e.direction_y < 0 then
		self:selectItem(math.min(item_count, selected_index + 1))
	elseif e.direction_y > 0 then
		self:selectItem(math.max(1, selected_index - 1))
	end
end

---@param e ui.MouseClickEvent
function ElasticList:onMouseClick(e)
	if e.button ~= 1 then
		return
	end

	local imx = select(1, self.transform:inverseTransformPoint(e.x, e.y))
	local items = self:getItems()
	local item_count = #items

	if item_count == 0 then
		return
	end

	self:ensureLayoutState(item_count, self:getSelectedIndex())

	local total_flex = 0
	for i = 1, item_count do
		total_flex = total_flex + self.flex_values[i]
	end

	---@cast total_flex number
	if total_flex == 0 then
		return
	end

	local current_x = -self.scroll_offset
	for i = 1, item_count do
		local cell_width = (self.flex_values[i] / total_flex) * self.total_content_width
		if imx >= current_x and imx < current_x + cell_width then
			self:selectItem(i)
			return
		end
		current_x = current_x + cell_width
	end
end

---@param dt number
function ElasticList:update(dt)
	local items = self:getItems()
	local item_count = #items
	local selected_index = self:ensureLayoutState(item_count, self:getSelectedIndex())

	if item_count <= 0 then
		return
	end

	if item_count == 1 then
		self.scroll_offset = 0
		self.flex_values[1] = 1
		return
	end

	local flex_alpha = get_time_based_alpha(self.FlexAnimationAlpha, dt)
	local scroll_alpha = get_time_based_alpha(self.ScrollAnimationAlpha, dt)
	local selected_flex = get_target_flex_for_selected(self.total_content_width, item_count, self.SelectedWidth)

	for i = 1, item_count do
		local target = (i == selected_index) and selected_flex or 1
		local current = self.flex_values[i] or target
		local diff = target - current

		if math.abs(diff) <= 0.001 then
			self.flex_values[i] = target
		else
			self.flex_values[i] = current + diff * flex_alpha
		end
	end

	local target_scroll = self:getTargetScroll(item_count, selected_index)
	local diff = target_scroll - self.scroll_offset
	self.scroll_offset = self.scroll_offset + diff * scroll_alpha
end

---@param item any
---@param width number
---@param height number
---@param is_selected boolean
function ElasticList:drawItem(item, width, height, is_selected) end

function ElasticList:draw()
	local width, height = self:getCalculatedWidth(), self:getCalculatedHeight()
	local items = self:getItems()
	local item_count = #items
	local selected_index = self:ensureLayoutState(item_count, self:getSelectedIndex())

	if item_count == 0 then
		return
	end

	local total_flex = 0
	for i = 1, item_count do
		total_flex = total_flex + self.flex_values[i]
	end

	if total_flex == 0 then
		return
	end

	local current_x = -self.scroll_offset
	local gap = self.Gap

	for i = 1, item_count do
		local cell_width = (self.flex_values[i] / total_flex) * self.total_content_width

		if current_x + cell_width > 0 and current_x < width then
			love.graphics.push()
			love.graphics.translate(current_x, 0)
			self:drawItem(items[i], cell_width - gap, height, i == selected_index)
			love.graphics.pop()
		end

		current_x = current_x + cell_width
	end
end

return ElasticList
