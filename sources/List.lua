List = createClass(soul.ui.UIObject)

List.buttonCount = 1
List.offset = 0
List.targetOffset = 0
List.scrollDelta = 0
List.selectedItemIndex = List.offset + 6

List.load = function(self)
	self.items = self.items or {}
	
	self.offset = 1 - self:getMiddleOffset()
	self.targetOffset = self.offset
	
	self:calculateButtons()
	self:loadCallbacks()
	
	self.loaded = true
end

List.unload = function(self)
	self:unloadButtons()
	self:unloadCallbacks()
	
	self.loaded = false
end

List.getMiddleOffset = function(self)
	return math.ceil(self.buttonCount / 2)
end

List.update = function(self)
	if self.targetOffset < 1 - self:getMiddleOffset() then
		self.targetOffset = 1 - self:getMiddleOffset()
	elseif self.targetOffset > #self.items - self:getMiddleOffset() then
		self.targetOffset = #self.items - self:getMiddleOffset()
	end
	if (self.scrollDelta > 0 and self.offset + self.scrollDelta > self.targetOffset)
	or (self.scrollDelta < 0 and self.offset + self.scrollDelta < self.targetOffset)
	then
		self.offset = self.targetOffset
		self.scrollDelta = 0
	else
		self.offset = self.offset + self.scrollDelta
	end
	self:calculateButtons()
end

List.calculateButtons = function(self)
	self.buttons = self.buttons or {}
	
	self.selectedItemIndex = self.offset + self:getMiddleOffset()
	
	local itemIndexKeys = {}
	for buttonIndex, button in pairs(self.buttons) do
		itemIndexKeys[button.itemIndex] = button
		button:update()
	end
	
	for itemIndex = 1 + math.floor(self.offset), self.buttonCount + math.ceil(self.offset) do
		local item = self.items[itemIndex]
		if item and not itemIndexKeys[itemIndex] then
			local button = self.Button:new({
				x = self.x, y = self.y + (itemIndex - self.offset - 1) * (self.h / self.buttonCount),
				w = self.w, h = self.h / (self.buttonCount),
				layer = self.layer,
				cs = self.cs,
				rectangleColor = self.rectangleColor,
				mode = self.mode,
				limit = self.limit,
				textAlign = self.textAlign,
				rectangleColor = (itemIndex == self.selectedItemIndex) and self.selectedRectangleColor or self.rectangleColor,
				font = self.font,
				
				list = self,
				item = item,
				itemIndex = itemIndex,
				
				text = item.title,
				action = item.action
			})
			button:activate()
			
			self.buttons[button] = button
		end
	end
end

List.unloadButtons = function(self)
	for buttonIndex, button in pairs(self.buttons) do
		button:deactivate()
	end
	
	self.buttons = nil
end

List.updateScrollDelta = function(self)
	local dt =  math.min(1/60, love.timer.getDelta())
	self.scrollDelta = (self.targetOffset - self.offset) * dt * 16
end

List.loadCallbacks = function(self)
	soul.setCallback("wheelmoved", self, function(_, direction)
		self.targetOffset = self.targetOffset + direction
		self:updateScrollDelta()
	end)
	soul.setCallback("keypressed", self, function(key)
		if key == "up" then
			self.targetOffset = self.targetOffset - 1
			self:updateScrollDelta()
		elseif key == "down" then
			self.targetOffset = self.targetOffset + 1
			self:updateScrollDelta()
		elseif key == "left" then
			self.targetOffset = self.targetOffset - 10
			self:updateScrollDelta()
		elseif key == "right" then
			self.targetOffset = self.targetOffset + 10
			self:updateScrollDelta()
		elseif key == "return" then
			for button in pairs(self.buttons) do
				if button.itemIndex == self.selectedItemIndex then
					button.item.action()
					break
				end
			end
		end
	end)
end

List.unloadCallbacks = function(self)
	soul.unsetCallback("keypressed", self)
end

List.addItem = function(self, title, action)
	if not self.items then
		self.items = {}
	end
	
	table.insert(self.items, {
		title = title,
		action = action
	})
end

List.Button = createClass(soul.ui.RectangleTextButton)

List.Button.update = function(self)
	local dt =  math.min(1/60, love.timer.getDelta())
	
	self.y = self.list.y + (self.itemIndex - self.list.offset - 1) * (self.list.h / self.list.buttonCount)
	
	self.rectangleColor = (self.itemIndex == self.list.selectedItemIndex) and self.list.selectedRectangleColor or self.list.rectangleColor
	
	if self.y < self.list.y - self.h or self.y > self.list.y + self.list.h then
		self.list.buttons[self] = nil
		self:deactivate()
	else
		self:reload()
	end
end