MapList = createClass(soul.SoulObject)

MapList.buttonCount = 17
MapList.visualItemIndex = 1
MapList.visualSubItemIndex = 1
MapList.selectedItemIndex = 1
MapList.selectedSubItemIndex = 1
MapList.scrollCurrentDelta = 0
MapList.scrollSubCurrentDelta = 0

MapList.x = -7/9
MapList.y = 0
MapList.w = 7/9
MapList.h = 1
MapList.layer = 2
MapList.rectangleColor = {255, 255, 255, 0}
MapList.textColor = {255, 255, 255, 255}
MapList.selectedRectangleColor = {255, 255, 255, 31}
MapList.mode = "fill"
MapList.limit = 7/9
MapList.textAlign = {
	x = "left", y = "center"
}
MapList.buttonCount = 17
MapList.upScrollKey = "up"
MapList.downScrollKey = "down"

MapList.load = function(self)
	self.cs = soul.CS:new(nil, 1, 0, 0, 0, "h", 768)
	self.font = mainFont20

	self:transformCache()
	
	self:updateItems()
	self:updateSubItems()
	
	self:calculateButtons()
	self:loadCallbacks()
	
	self.loaded = true
end

MapList.updateItems = function(self)
	self.items = {}
	for directoryPath, cacheDatas in pairs(self.transformedCache) do
		self:addItem({
			text = utf8validate(cacheDatas[1].title),
			onClick = function(button)
				self:scroolToItemIndex(button.itemIndex)
			end,
			onSelect = function(button)
				self:updateSubItems()
			end,
			directoryPath = directoryPath
		})
	end
end

MapList.updateSubItems = function(self)
	self.subItems = {}
	local directoryPath = self.items[self.selectedItemIndex].directoryPath
	for subItemIndex, cacheData in pairs(self.transformedCache[directoryPath]) do
		self:addSubItem({
			text = utf8validate(cacheData.title),
			onClick = function(button)
				if button.subItemIndex == self.selectedSubItemIndex then
					currentCacheData = cacheData
					stateManager:switchState("playing")
				else
					self.selectedSubItemIndex = subItemIndex
					self:updateScrollSubDelta()
				end
			end,
			onSelect = function(button) end,
			directoryPath = directoryPath
		})
	end
end

MapList.getItemCount = function(self)
	return #self.items
end

MapList.getSubItemCount = function(self)
	return #self.subItems
end

MapList.unload = function(self)
	self:unloadButtons()
	self:unloadCallbacks()
	
	self.loaded = false
end

MapList.transformCache = function(self)
	self.transformedCache = {}
	
	for cacheData in cache:getCacheDataIterator() do
		self.transformedCache[cacheData.directoryPath] = self.transformedCache[cacheData.directoryPath] or {}
		table.insert(self.transformedCache[cacheData.directoryPath], cacheData)
	end
end

MapList.getMiddleOffset = function(self)
	return math.ceil(self.buttonCount / 2)
end

MapList.update = function(self)
	if self.selectedItemIndex < 1 then
		self.selectedItemIndex = 1
	elseif self.selectedItemIndex > self:getItemCount() then
		self.selectedItemIndex = self:getItemCount()
	end
	if (self.scrollCurrentDelta > 0 and self.visualItemIndex + self.scrollCurrentDelta > self.selectedItemIndex)
	or (self.scrollCurrentDelta < 0 and self.visualItemIndex + self.scrollCurrentDelta < self.selectedItemIndex)
	then
		self.visualItemIndex = self.selectedItemIndex
		self.scrollCurrentDelta = 0
	else
		self.visualItemIndex = self.visualItemIndex + self.scrollCurrentDelta
	end
	
	if self.selectedSubItemIndex < 1 then
		self.selectedSubItemIndex = 1
	elseif self.selectedSubItemIndex > self:getSubItemCount() then
		self.selectedSubItemIndex = self:getSubItemCount()
	end
	if (self.scrollSubCurrentDelta > 0 and self.visualSubItemIndex + self.scrollSubCurrentDelta > self.selectedSubItemIndex)
	or (self.scrollSubCurrentDelta < 0 and self.visualSubItemIndex + self.scrollSubCurrentDelta < self.selectedSubItemIndex)
	then
		self.visualSubItemIndex = self.selectedSubItemIndex
		self.scrollSubCurrentDelta = 0
	else
		self.visualSubItemIndex = self.visualSubItemIndex + self.scrollSubCurrentDelta
	end
	
	self:calculateButtons()
end

MapList.calculateButtons = function(self)
	self.buttons = self.buttons or {}
	
	local itemIndexKeys = {}
	local subItemIndexKeys = {}
	for button in pairs(self.buttons) do
		button:update()
		if button.loaded then
			itemIndexKeys[button.itemIndex] = button
			if button.itemIndex == self.selectedItemIndex then
				subItemIndexKeys[button.subItemIndex] = button
			end
		end
	end
	
	for itemIndex = math.floor(self.visualItemIndex) - self:getMiddleOffset(), self.buttonCount + math.ceil(self.visualItemIndex) + self:getMiddleOffset() do
		local item = self.items[itemIndex]
		local reSelected = itemIndex == self.selectedItemIndex
		if item and (not itemIndexKeys[itemIndex] or reSelected) then
			local limit = reSelected and self:getSubItemCount() or 1
			for subItemIndex = 1, limit do
				if not subItemIndexKeys[subItemIndex] and reSelected or not reSelected then
					item = reSelected and self.subItems[subItemIndex] or self.items[itemIndex]
					local button = self.Button:new({
						reSelected = reSelected,
						item = item,
						itemIndex = itemIndex,
						text = item.text,
						action = item.onClick,
						subItemIndex = subItemIndex,
						rectangleColor = reSelected and self.selectedRectangleColor or self.rectangleColor,
						
						x = self.x, y = self.y,
						w = self.w, h = self.h / (self.buttonCount),
						layer = self.layer,
						cs = self.cs,
						rectangleColor = self.rectangleColor,
						mode = self.mode,
						limit = self.limit,
						textAlign = self.textAlign,
						textColor = self.textColor,
						font = self.font,
						list = self,
					})
					button:activate()
					button:update()
					
					self.buttons[button] = button
				end
			end
		end
	end
end

MapList.unloadButtons = function(self)
	for button in pairs(self.buttons) do
		button:deactivate()
	end
	
	self.buttons = nil
end

MapList.updateScrollCurrentDelta = function(self)
	local dt =  math.min(1/60, love.timer.getDelta())
	self.scrollCurrentDelta = (self.selectedItemIndex - self.visualItemIndex) * dt * 8
end

MapList.updateScrollSubDelta = function(self)
	local dt =  math.min(1/60, love.timer.getDelta())
	self.scrollSubCurrentDelta = (self.selectedSubItemIndex - self.visualSubItemIndex) * dt * 8
end

MapList.getButtonByItemIndex = function(self, itemIndex)
	for button in pairs(self.buttons) do
		if button.itemIndex == itemIndex then
			return button
		end
	end
end

MapList.scroolToItemIndex = function(self, itemIndex)
		local isAtEnd = self.selectedSubItemIndex == self:getSubItemCount()
		
		local oldSelectedItemIndex = self.selectedItemIndex
		
		if self.items[itemIndex] then
			self.selectedItemIndex = itemIndex
			self.items[self.selectedItemIndex].onSelect(self:getButtonByItemIndex(itemIndex))
		end
		local scrollDelta = self.selectedItemIndex - oldSelectedItemIndex
		
		self:updateScrollCurrentDelta()
		
		self.selectedSubItemIndex = 1
		if scrollDelta > 0 and isAtEnd then
			self.selectedSubItemIndex = self:getSubItemCount()
		end
		
		if oldSelectedItemIndex ~= self.selectedItemIndex then
			self.visualSubItemIndex = self.selectedSubItemIndex - scrollDelta
			self.visualItemIndex = self.visualItemIndex + scrollDelta
			self.scrollSubCurrentDelta = self.scrollCurrentDelta
		end
end

MapList.scrollBy = function(self, scrollDelta)
	if self.selectedSubItemIndex + scrollDelta <= self:getSubItemCount() and
		self.selectedSubItemIndex + scrollDelta >= 1
	then
		self.selectedSubItemIndex = self.selectedSubItemIndex + scrollDelta
		
		self:updateScrollSubDelta()
		self.selectedSubItemIndex = self.selectedSubItemIndex
		if self.subItems[self.selectedSubItemIndex] then
			self.subItems[self.selectedSubItemIndex].onSelect()
		end
	else
		local isAtEnd = self.selectedSubItemIndex == self:getSubItemCount()
		
		local oldSelectedItemIndex = self.selectedItemIndex
		
		if self.items[self.selectedItemIndex + scrollDelta] then
			self.selectedItemIndex = self.selectedItemIndex + scrollDelta
			self.items[self.selectedItemIndex].onSelect()
		end
		
		self:updateScrollCurrentDelta()
		
		self.selectedSubItemIndex = 1
		if scrollDelta > 0 and isAtEnd then
			self.selectedSubItemIndex = self:getSubItemCount()
		end
		
		if oldSelectedItemIndex ~= self.selectedItemIndex then
			self.visualSubItemIndex = self.selectedSubItemIndex - scrollDelta
			self.visualItemIndex = self.visualItemIndex + scrollDelta
			self.scrollSubCurrentDelta = self.scrollCurrentDelta
		end
	end
end

MapList.getItemIndex = function(self, item)
	for itemIndex, currentItem in ipairs(self.items) do
		if item == currentItem then
			return itemIndex
		end
	end
	
	return 1
end

MapList.loadCallbacks = function(self)
	soul.setCallback("wheelmoved", self, function(_, direction)
		local x, y, w, h = self.x, self.y, self.w, self.h
		local mx, my = self.cs:x(love.mouse.getX(), true), self.cs:y(love.mouse.getY(), true)
		if belong(mx, x, x + w, my, y, y + h) then
			self:scrollBy(-direction)
		end
	end)
	soul.setCallback("keypressed", self, function(key)
		if key == self.upScrollKey then
			self:scrollBy(-1)
		elseif key == self.downScrollKey then
			self:scrollBy(1)
		elseif key == "return" then
			for button in pairs(self.buttons) do
				if button.itemIndex == self.selectedItemIndex and button.subItemIndex == self.selectedSubItemIndex then
					button.item.onClick(button)
					break
				end
			end
		end
	end)
end

MapList.unloadCallbacks = function(self)
	soul.unsetCallback("keypressed", self)
end

MapList.addItem = function(self, item)
	table.insert(self.items, item)
end

MapList.addSubItem = function(self, item)
	table.insert(self.subItems, item)
end

MapList.Button = createClass(soul.ui.RectangleTextButton)

MapList.Button.updateY = function(self)
	self.y = self.list.y + (self.list:getMiddleOffset() - self.list.visualSubItemIndex) * (self.list.h / self.list.buttonCount)
	if self.itemIndex < self.list.selectedItemIndex then
		self.y = self.y + (self.itemIndex - self.list.visualItemIndex) * (self.list.h / self.list.buttonCount)
	elseif self.itemIndex > self.list.selectedItemIndex then
		self.y = self.y + (self.itemIndex - self.list.visualItemIndex + self.list:getSubItemCount() - 1) * (self.list.h / self.list.buttonCount)
	else
		self.y = self.y + (self.subItemIndex - 1) * (self.list.h / self.list.buttonCount)
	end
end

MapList.Button.updateX = function(self)
	if self.itemIndex == self.list.selectedItemIndex and self.subItemIndex ~= self.list.selectedSubItemIndex then
		self.x = self.list.x + (self.list.h / self.list.buttonCount) / 2
	else
		self.x = self.list.x
	end
end

MapList.Button.update = function(self)
	local dt =  math.min(1/60, love.timer.getDelta())
	
	self:updateX()
	self:updateY()
	
	if self.itemIndex == self.list.selectedItemIndex then
		self.rectangleColor = self.list.selectedRectangleColor
		if not self.selected and self.item.onSelect and self.subItemIndex == self.list.selectedSubItemIndex then
			self.item.onSelect(self)
			self.selected = true
		end
	else
		self.selected = false
		self.rectangleColor = self.list.rectangleColor
	end
	
	if self.itemIndex < math.floor(self.list.visualItemIndex) - self.list:getMiddleOffset() and
		self.itemIndex > self.list.buttonCount + math.ceil(self.list.visualItemIndex) + self.list:getMiddleOffset() or
		self.subItemIndex ~= 1 and self.itemIndex ~= self.list.selectedItemIndex or
		not self.reSelected and self.itemIndex == self.list.selectedItemIndex or
		self.reSelected and self.itemIndex ~= self.list.selectedItemIndex
	then
		self.list.buttons[self] = nil
		self:deactivate()
	else
		self:reload()
	end
end