local View = require("yi.views.View")
local ScrollCamera = require("yi.views.List.ScrollCamera")

---@class yi.ScrollList : yi.View
---@overload fun(): yi.ScrollList
---@field camera yi.ScrollCamera
---@field drag_start_y number Y position when drag started
---@field drag_start_scroll number Scroll position when drag started
---@field last_drag_y number Last drag Y position for velocity calculation
---@field last_drag_time number Last drag timestamp
---@field drag_velocity number Calculated drag velocity
---@field item_height number Height of each item (must be set by subclass)
local ScrollList = View + {}

ScrollList.item_height = 50

function ScrollList:new()
	View.new(self)
	self.handles_mouse_input = true
	self.camera = ScrollCamera()
end

---Get the number of items in the list (must be overridden)
---@return number
function ScrollList:getItemCount()
	return 0
end

---Get the currently selected index (must be overridden)
---@return number
function ScrollList:getSelectedIndex()
	return 1
end

---Set the selected index (must be overridden)
---@param index number
function ScrollList:setSelectedIndex(index) end

---Draw a single item (must be overridden)
---@param index number Item index (1-based)
---@param y number Y position to render at
---@param is_selected boolean Whether this item is selected
function ScrollList:drawItem(index, y, is_selected) end

---Called when selection changes via click
---@param index number
function ScrollList:onItemSelected(index)
	self:setSelectedIndex(index)
end

---Convert Y coordinate to item index (accounting for centering)
---@param y number Local Y coordinate
---@return number index Item index (can be fractional)
function ScrollList:yToIndex(y)
	local h = self:getCalculatedHeight()
	local center_offset = (h - self.item_height) / 2
	return self.camera.position + (y - center_offset) / self.item_height
end

---Convert item index to Y coordinate (centered in view)
---@param index number Item index
---@return number y Local Y coordinate
function ScrollList:indexToY(index)
	local h = self:getCalculatedHeight()
	local center_offset = (h - self.item_height) / 2
	return (index - self.camera.position) * self.item_height + center_offset
end

---Update item count bounds
function ScrollList:updateBounds()
	local count = self:getItemCount()
	self.camera:setBounds(1, count)
end

function ScrollList:onMouseDown(_)
	self.camera:interrupt()
	self.camera.state = "idle"
end

function ScrollList:onMouseClick(e)
	local _, imy = self.transform:inverseTransformPoint(e.x, e.y)
	local clicked_index = math.floor(self:yToIndex(imy))

	local count = self:getItemCount()
	if clicked_index >= 1 and clicked_index <= count then
		self:setSelectedIndex(clicked_index)
		-- Camera will tween to selection in update() when it detects the change
	end
end

function ScrollList:onDragStart(e)
	local _, imy = self.transform:inverseTransformPoint(e.x, e.y)

	self.drag_start_y = imy
	self.drag_start_scroll = self.camera.position
	self.last_drag_y = imy
	self.last_drag_time = love.timer.getTime()
	self.drag_velocity = 0

	self.camera:startDrag()
	self.camera:interrupt()
end

function ScrollList:onDrag(e)
	local _, imy = self.transform:inverseTransformPoint(e.x, e.y)
	local now = love.timer.getTime()
	local dt = now - self.last_drag_time
	self.last_drag_time = now

	-- Calculate velocity similar to the reference implementation
	if dt > 0 then
		local accumulated_time = dt * 1000 -- in ms

		if self.last_drag_y ~= imy then
			local velocity = (self.last_drag_y - imy) / accumulated_time

			-- Determine decay based on velocity direction change or speed increase
			local high_decay = (velocity > 0) ~= (self.drag_velocity > 0) or
				math.abs(velocity) > math.abs(self.drag_velocity)

			local decay = math.pow(high_decay and 0.90 or 0.95, accumulated_time)

			self.drag_velocity = self.drag_velocity * decay + (1 - decay) * velocity
			self.accumulated_time = 0
		else
			self.accumulated_time = (self.accumulated_time or 0) + accumulated_time
		end
	end

	self.last_drag_y = imy

	-- Move camera with soft clamping (50% clamp + 50% actual for elastic feel)
	local delta_y = imy - self.drag_start_y
	local target_position = self.drag_start_scroll - delta_y / self.item_height

	-- Soft clamp to bounds
	local min_pos = self.camera.min_position
	local max_pos = self.camera.max_position
	local clamped = math.max(min_pos, math.min(max_pos, target_position))
	self.camera.position = clamped * 0.5 + target_position * 0.5
end

function ScrollList:onDragEnd(_)
	-- Calculate time since last drag event (when mouse was actually moving)
	local now = love.timer.getTime()
	local time_since_last_drag = (now - self.last_drag_time) * 1000 -- in ms

	-- If mouse wasn't moving for more than 100ms, completely eliminate velocity
	if time_since_last_drag > 100 then
		self.drag_velocity = 0
	else
		-- Apply decay based on how long since last movement
		self.drag_velocity = self.drag_velocity * math.pow(0.95, math.max(0, time_since_last_drag - 66))
	end

	-- drag_velocity is in pixels/ms
	-- Convert to items per second: pixels/ms * 1000 = pixels/s, / item_height = items/s
	local velocity = self.drag_velocity * 1000 / self.item_height
	self.camera:endDrag(velocity)
end

function ScrollList:onScroll(e)
	-- Accumulate scroll delta (tweenBy accumulates if already tweening)
	self.camera:tweenBy(-e.direction_y)

	-- Immediately select the target item
	if self.camera.target then
		self:setSelectedIndex(math.floor(self.camera.target + 0.5))
	end
end

function ScrollList:update(dt)
	self:updateBounds()
	self.camera:update(dt)

	-- Check if selection changed and tween to it
	local selected = self:getSelectedIndex()
	if selected ~= self.last_selected_index then
		self.last_selected_index = selected
		self.camera:tweenTo(selected)
	end
end

function ScrollList:draw()
	local count = self:getItemCount()
	if count == 0 then
		return
	end

	local h = self:getCalculatedHeight()
	local selected = self:getSelectedIndex()

	-- Calculate visible range
	local items_per_screen = h / self.item_height
	local first_visible = math.floor(self.camera.position - items_per_screen / 2 - 1)
	local last_visible = math.ceil(self.camera.position + items_per_screen / 2 + 1)

	-- Clamp to valid range
	first_visible = math.max(1, first_visible)
	last_visible = math.min(count, last_visible)

	for i = first_visible, last_visible do
		local y = self:indexToY(i)
		local is_selected = (i == selected)
		self:drawItem(i, y, is_selected)
	end
end

return ScrollList
