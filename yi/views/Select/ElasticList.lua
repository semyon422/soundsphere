local View = require("yi.views.View")

---@class yi.ElasticList : yi.View
---@operator call: yi.ElasticList
---@field flex_values number[]
local ElasticList = View + {}

ElasticList.SelectedWidth = 150
ElasticList.UnselectedWidth = 50
ElasticList.Gap = 10

function ElasticList:new()
	View.new(self)
	self.flex_values = {}
	self.scroll_offset = 0
	self.total_content_width = 0
	self.handles_mouse_input = true
end

---@param total_width number
---@param num_items number
---@param target_px number
---@return number
local function get_target_flex_for_selected(total_width, num_items, target_px)
	if total_width <= target_px then
		return 1
	end
	return (target_px * (num_items - 1)) / (total_width - target_px)
end


---@return any[]
--- Returns items from the source
function ElasticList:getItems()
	return {}
end

--- Returns an index from the source
function ElasticList:getSelectedIndex()
	return 1
end

---@param index integer
--- Sets the index in the source
function ElasticList:selectItem(index) end

function ElasticList:reloadItems()
	local items = assert(self:getItems(), "Items is nil")
	local selected_index = assert(self:getSelectedIndex(), "Selected index is nil")
	self.flex_values = {}
	self.scroll_offset = 0
	self.total_content_width = (#items - 1) * self.UnselectedWidth + self.SelectedWidth

	-- Copypasted from update(). Pls fix
	local item_count = #items
	local target_flex = get_target_flex_for_selected(self.total_content_width, item_count, self.SelectedWidth)

	for i = 1, item_count do
		if i == selected_index then
			table.insert(self.flex_values, target_flex)
		else
			table.insert(self.flex_values, 1)
		end
	end

	local width = self:getCalculatedWidth()

	local final_unselected_width = (self.total_content_width - self.SelectedWidth) / (item_count - 1)
	local final_selected_center = ((selected_index - 1) * final_unselected_width) + (self.SelectedWidth / 2)
	local target_scroll = math.max(0, final_selected_center - width / 2)

	self.scroll_offset = target_scroll
end

---@param e ui.ScrollEvent
function ElasticList:onScroll(e)
	local items = self:getItems()
	local selected_index = self:getSelectedIndex()

	if e.direction_y < 0 then
		self:selectItem(math.min(#items, selected_index + 1))
	elseif e.direction_y > 0 then
		self:selectItem(math.max(1, selected_index - 1))
	end
end

---@param e ui.MouseClickEvent
function ElasticList:onMouseClick(e)
	local imx, imy = self.transform:inverseTransformPoint(e.x, e.y)

	if e.button == 1 then
		local items = self:getItems()
		local item_count = #items

		-- Copypasted from draw(). Pls fix
		if item_count == 0 then
			return
		end

		local total_flex = 0
		for i = 1, item_count do
			total_flex = total_flex + self.flex_values[i]
		end

		if total_flex == 0 then return end

		local current_x = -self.scroll_offset

		for i = 1, item_count do
			local flex = self.flex_values[i]
			local cell_width = (flex / total_flex) * self.total_content_width

			if imx >= current_x and imx < current_x + cell_width then
				self:selectItem(i)
				return
			end

			current_x = current_x + cell_width
		end
	end
end

---@param _ number
function ElasticList:update(_)
	local width = self:getCalculatedWidth()
	local item_count = #self:getItems()
	local selected_index = self:getSelectedIndex()

	if item_count == 0 then
		return
	end

	if item_count <= 1 then
		self.scroll_offset = 0
		return
	end

	local selected_width = self.SelectedWidth

	local target_flex = get_target_flex_for_selected(self.total_content_width, item_count, selected_width)

	for i = 1, item_count do
		local target = (selected_index == i) and target_flex or 1
		local current = self.flex_values[i]
		local diff = target - current

		if math.abs(diff) > 0.001 then
			self.flex_values[i] = current + diff * 0.04
		else
			self.flex_values[i] = target
		end
	end

	local final_unselected_width = (self.total_content_width - selected_width) / (item_count - 1)
	local final_selected_center = ((selected_index - 1) * final_unselected_width) + (selected_width / 2)

	local target_scroll = math.max(0, final_selected_center - width / 2)

	local diff = target_scroll - self.scroll_offset
	self.scroll_offset = self.scroll_offset + diff * 0.05
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
	local selected_index = self:getSelectedIndex()
	local gap = self.Gap

	if item_count == 0 then
		return
	end

	local total_flex = 0
	for i = 1, item_count do
		total_flex = total_flex + self.flex_values[i]
	end
	---@cast total_flex number

	local current_x = -self.scroll_offset

	for i = 1, item_count do
		local flex = self.flex_values[i]
		local cell_width = (flex / total_flex) * self.total_content_width

		if current_x + cell_width > 0 and current_x < width then
			local is_selected = (i == selected_index)
			local w = cell_width - gap

			love.graphics.push()
			love.graphics.translate(current_x + gap / 2 - gap, 0)
			self:drawItem(items[i], w, height, is_selected)
			love.graphics.pop()
		end

		current_x = current_x + cell_width
	end
end

return ElasticList
