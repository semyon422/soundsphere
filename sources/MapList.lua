MapList = createClass(soul.SoulObject)

MapList.buttonCount = 17
MapList.offset = 0
MapList.subOffset = 0
MapList.targetOffset = 0
MapList.targetSubOffset = 0
MapList.scrollDelta = 0
MapList.scrollSubDelta = 0

MapList.selectedItemIndex = 1
MapList.selectedFileIndex = 1

MapList.currentDirectoryPathFileCount = 1
MapList.currentDirectoryPathFileIndex = 1

MapList.load = function(self)
	self:transformCache()
	
	self:updateItems()
	self:updateSubItems()
	
	self.offset = 1 - self:getMiddleOffset()
	self.subOffset = 1 - self:getMiddleOffset()
	self.targetOffset = self.offset
	self.targetSubOffset = self.subOffset
	
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
				self.targetSubOffset = 1 - self:getMiddleOffset()
				self.subOffset = 1 - self:getMiddleOffset()
				
				self.targetOffset = button.itemIndex - self:getMiddleOffset()
				self:updateScrollDelta()
				
				self.currentDirectoryPathFileCount = #self.transformedCache[directoryPath]
				self.currentDirectoryPathFileIndex = 1
				self:updateSubItems()
			end,
			onSelect = function(button)
				self.currentDirectoryPathFileCount = #self.transformedCache[directoryPath]
				self.currentDirectoryPathFileIndex = 1
				self:updateSubItems()
			end,
			directoryPath = directoryPath
		})
	end
end

MapList.updateSubItems = function(self)
	self.subItems = {}
	local directoryPath = self.items[self.selectedItemIndex].directoryPath
	for fileIndex, cacheData in pairs(self.transformedCache[directoryPath]) do
		self:addSubItem({
			text = utf8validate(cacheData.title),
			onClick = function(button)
				if button.fileIndex == self.selectedFileIndex then
					currentCacheData = cacheData
					stateManager:switchState("playing")
				else
					self.targetSubOffset = button.fileIndex - self:getMiddleOffset()
					self.currentDirectoryPathFileIndex = fileIndex
					self:updateScrollSubDelta()
				end
			end,
			onSelect = function(button)
				self.currentDirectoryPathFileCount = #self.transformedCache[directoryPath]
				self.currentDirectoryPathFileIndex = fileIndex
			end,
			directoryPath = directoryPath
		})
	end
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
	
	if self.targetSubOffset < 1 - self:getMiddleOffset() then
		self.targetSubOffset = 1 - self:getMiddleOffset()
	elseif self.targetSubOffset > #self.subItems - self:getMiddleOffset() then
		self.targetSubOffset = #self.subItems - self:getMiddleOffset()
	end
	if (self.scrollSubDelta > 0 and self.subOffset + self.scrollSubDelta > self.targetSubOffset)
	or (self.scrollSubDelta < 0 and self.subOffset + self.scrollSubDelta < self.targetSubOffset)
	then
		self.subOffset = self.targetSubOffset
		self.scrollSubDelta = 0
	else
		self.subOffset = self.subOffset + self.scrollSubDelta
	end
	
	self:calculateButtons()
end

MapList.calculateButtons = function(self)
	self.buttons = self.buttons or {}
	
	self.selectedItemIndex = self.targetOffset + self:getMiddleOffset()
	self.selectedFileIndex = self.targetSubOffset + self:getMiddleOffset()
	self.selectedItem = self:getSelectedItem()
	
	local itemIndexKeys = {}
	local fileIndexKeys = {}
	for buttonIndex, button in pairs(self.buttons) do
		itemIndexKeys[button.itemIndex] = button
		if button.itemIndex == self.selectedItemIndex then
			fileIndexKeys[button.fileIndex] = button
		end
		button:update()
	end
	
	for itemIndex = 1 + math.floor(self.offset), self.buttonCount + math.ceil(self.offset) do
		local item = self.items[itemIndex]
		if item and not itemIndexKeys[itemIndex] or item and itemIndex == self.selectedItemIndex then
			local limit = itemIndex == self.selectedItemIndex and self.currentDirectoryPathFileCount or 1
			for fileIndex = 1, limit do
				if not fileIndexKeys[fileIndex] and itemIndex == self.selectedItemIndex or itemIndex ~= self.selectedItemIndex then
					item = (itemIndex == self.selectedItemIndex) and self.subItems[fileIndex] or self.items[itemIndex]
					local button = self.Button:new({
						x = self.x, y = self.y,
						w = self.w, h = self.h / (self.buttonCount),
						layer = self.layer,
						cs = self.cs,
						rectangleColor = self.rectangleColor,
						mode = self.mode,
						limit = self.limit,
						textAlign = self.textAlign,
						rectangleColor = (itemIndex == self.selectedItemIndex) and self.selectedRectangleColor or self.rectangleColor,
						textColor = self.textColor,
						font = self.font,
						
						list = self,
						item = item,
						itemIndex = itemIndex,
						
						text = item.text,
						action = item.onClick,
						fileIndex = fileIndex
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
	for buttonIndex, button in pairs(self.buttons) do
		button:deactivate()
	end
	
	self.buttons = nil
end

MapList.updateScrollDelta = function(self)
	local dt =  math.min(1/60, love.timer.getDelta())
	self.scrollDelta = (self.targetOffset - self.offset) * dt * 16
end

MapList.updateScrollSubDelta = function(self)
	local dt =  math.min(1/60, love.timer.getDelta())
	self.scrollSubDelta = (self.targetSubOffset - self.subOffset) * dt * 16
end

MapList.scrollTo = function(self, targetOffset)
	self.targetOffset = targetOffset
	self:updateScrollDelta()
end

MapList.scrollBy = function(self, targetOffsetDelta)
	if self.currentDirectoryPathFileIndex + targetOffsetDelta <= self.currentDirectoryPathFileCount and
		self.currentDirectoryPathFileIndex + targetOffsetDelta >= 1
	then
		self.currentDirectoryPathFileIndex = self.currentDirectoryPathFileIndex + targetOffsetDelta
		self.targetSubOffset = self.targetSubOffset + targetOffsetDelta
		
		self:updateScrollSubDelta()
		self.selectedSubItemIndex = self.targetSubOffset + self:getMiddleOffset()
		self.selectedSubItem = self:getSelectedSubItem()
		if self.selectedSubItem then self.selectedSubItem.onSelect() end
	else
		self.targetSubOffset = 1 - self:getMiddleOffset()
		self.subOffset = 1 - self:getMiddleOffset()
		self.targetOffset = self.targetOffset + targetOffsetDelta
		
		self:updateScrollDelta()
		self.selectedItemIndex = self.targetOffset + self:getMiddleOffset()
		self.selectedItem = self:getSelectedItem()
		if self.selectedItem then self.selectedItem.onSelect() end
	end
end

MapList.getOffset = function(self)
	return self.targetOffset
end

MapList.getSelectedItem = function(self)
	return self.items[self.selectedItemIndex]
end

MapList.getSelectedSubItem = function(self)
	return self.subItems[self.selectedSubItemIndex]
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
			self:scrollBy(direction)
		end
	end)
	soul.setCallback("keypressed", self, function(key)
		if key == self.upScrollKey then
			self:scrollBy(-1)
		elseif key == self.downScrollKey then
			self:scrollBy(1)
		elseif key == "return" then
			for button in pairs(self.buttons) do
				if button.itemIndex == self.selectedItemIndex and button.fileIndex == self.selectedSubItemIndex then
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
	if not self.items then
		self.items = {}
	end
	
	table.insert(self.items, item)
end

MapList.addSubItem = function(self, item)
	if not self.subItems then
		self.subItems = {}
	end
	
	table.insert(self.subItems, item)
end

MapList.Button = createClass(soul.ui.RectangleTextButton)

MapList.Button.updateY = function(self)
	self.y = self.list.y + (self.itemIndex - self.list.offset - 1) * (self.list.h / self.list.buttonCount)
	if self.itemIndex < self.list.selectedItemIndex then
		self.y = self.y - (self.list.currentDirectoryPathFileIndex - 1 - self.list.targetSubOffset + self.list.subOffset) * (self.list.h / self.list.buttonCount)
	elseif self.itemIndex > self.list.selectedItemIndex then
		self.y = self.y + (self.list.currentDirectoryPathFileCount - self.list.currentDirectoryPathFileIndex + self.list.targetSubOffset - self.list.subOffset) * (self.list.h / self.list.buttonCount)
	else
		self.y = self.list.y + (self.fileIndex - self.list.subOffset - 1) * (self.list.h / self.list.buttonCount)
		-- self.y = self.y + (self.fileIndex - 1 - self.list.currentDirectoryPathFileIndex + 1) * (self.list.h / self.list.buttonCount)
	end
end

MapList.Button.updateX = function(self)
	if self.itemIndex == self.list.selectedItemIndex then
		self.x = self.list.x - (self.list.h / self.list.buttonCount) / 2
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
		if not self.selected and self.item.onSelect and self.fileIndex == self.list.currentDirectoryPathFileIndex then
			self.item.onSelect(self)
			self.selected = true
		end
	else
		self.selected = false
		self.rectangleColor = self.list.rectangleColor
	end
	
	if self.y < self.list.y - self.h or self.y > self.list.y + self.list.h or self.fileIndex ~= 1 and self.itemIndex ~= self.list.selectedItemIndex then
		self.list.buttons[self] = nil
		self:deactivate()
	else
		self:reload()
	end
end