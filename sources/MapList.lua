MapList = createClass(soul.SoulObject)

MapList.buttonCount = 17
MapList.visualItemIndex = 1
MapList.visualSubItemIndex = 1
MapList.selectedItemIndex = 1
MapList.selectedSubItemIndex = 1

MapList.x = 0
MapList.y = 0
MapList.w = 1
MapList.h = 1
MapList.layer = 2
MapList.rectangleColor = {255, 255, 255, 0}
MapList.textColor = {255, 255, 255, 255}
MapList.selectedRectangleColor = {255, 255, 255, 31}
MapList.mode = "fill"
MapList.limit = 2
MapList.textAlign = {
	x = "left", y = "center"
}
MapList.buttonCount = 17
MapList.upScrollKey = "up"
MapList.downScrollKey = "down"

MapList.load = function(self)
	self.cs = soul.CS:new(nil, 0.5, 0, 0, 0, "h", 576)
	self.font = self.core.fonts.main20
	
	self.scrollCurrentDelta = 0

	self:loadCache()
	self:sortCache()
	self:selectRandomCacheData()
	self:updateSelectionList()
	
	self:updateItems()
	self.visualItemIndex = self.selectedItemIndex
	
	self:calculateButtons()
end

MapList.loadCache = function(self)
	self.cacheDatas = {}
	self.cacheDatasByPath = {}
	
	for cacheData in self.core.cache:getCacheDataIterator() do
		table.insert(self.cacheDatas, cacheData)
		self.cacheDatasByPath[cacheData.directoryPath .. "/" .. cacheData.fileName] = cacheData
	end
end

MapList.sortCache = function(self) end

MapList.selectRandomCacheData = function(self)
	-- self.currentCacheData = self.cacheDatas[math.random(#self.cacheDatas)]
	self.currentCacheData = self.cacheDatas[1]
	self.core.currentCacheData = self.currentCacheData
	self.selectionKey = (self.currentCacheData.directoryPath .. "/" .. self.currentCacheData.fileName):split("/")
	-- self.selectionKey = (self.currentCacheData.directoryPath):split("/")
end

MapList.updateCurrentCacheData = function(self)
	if self.cacheDatasByPath[table.concat(self.selectionKey, "/")] then
		self.currentCacheData = self.cacheDatasByPath[table.concat(self.selectionKey, "/")]
		self.core.currentCacheData = self.currentCacheData
	end
end

MapList.updateSelectionList = function(self)
	self.selectionList = {}
	
	for _, cacheData in ipairs(self.cacheDatas) do
		local selectionKey = (cacheData.directoryPath .. "/" .. cacheData.fileName):split("/")
		local newSelectionKey = {}
		
		for i = 1, #self.selectionKey do
			table.insert(newSelectionKey, selectionKey[i])
			if self.selectionKey[i] ~= newSelectionKey[i] or i == #self.selectionKey then
				if i == #self.selectionKey and self.selectionKey[i] == newSelectionKey[i] and selectionKey[i + 1] then
					table.insert(newSelectionKey, selectionKey[i + 1])
				end
				if not table.equal(newSelectionKey, self.selectionList[#self.selectionList]) then
					table.insert(self.selectionList, newSelectionKey)
				end
				break
			end
		end
	end
end

MapList.updateItems = function(self)
	self.items = {}
	
	for _, selectionKey in ipairs(self.selectionList) do
		self:addItem({
			text = ("/"):rep(#selectionKey - 1) .. utf8validate(selectionKey[#selectionKey]),
			onClick = function(button)
				if button.itemIndex == self.selectedItemIndex then
					self.selectionKey = selectionKey
					self:updateSelectionList()
					self:updateCurrentCacheData()
					self:updateItems()
					self:unloadButtons()
					self:calculateButtons()
					if self.cacheDatasByPath[table.concat(selectionKey, "/")] then
						self.core.stateManager:switchState("playing")
					end
				else
					self:scrollToItemIndex(button.itemIndex)
				end
			end,
			onSelect = function(button)
				-- self.selectionKey = selectionKey
				-- self:updateSelectionList()
				-- self:updateCurrentCacheData()
			end,
			selectionKey = selectionKey
		})
	end
	
	if self.selectedItemIndex > #self.items then
		self.selectedItemIndex = #self.items
		self.visualItemIndex = #self.items
	end
end

MapList.addItem = function(self, item)
	table.insert(self.items, item)
end

MapList.getItemCount = function(self)
	return #self.items
end

MapList.unload = function(self)
	self:unloadButtons()
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
	
	self:calculateButtons()
end

MapList.receiveEvent = function(self, event)
	if event.name == "love.update" then
		self:update()
	elseif event.name == "love.wheelmoved" then
		local direction = event.data[2]
		local x, y, w, h = self.x, self.y, self.w, self.h
		local mx, my = self.cs:x(love.mouse.getX(), true), self.cs:y(love.mouse.getY(), true)
		if belong(mx, x, x + w, my, y, y + h) then
			self:scrollBy(-direction)
		end
	elseif event.name == "love.keypressed" then
		local key = event.data[2]
		if key == self.upScrollKey then
			self:scrollBy(-1)
		elseif key == self.downScrollKey then
			self:scrollBy(1)
		elseif key == "return" then
			for button in pairs(self.buttons) do
				if button.itemIndex == self.selectedItemIndex then
					button.item.onClick(button)
					break
				end
			end
		elseif key == "escape" and #self.selectionKey > 1 then
			self.selectionKey[#self.selectionKey] = nil
			self:updateSelectionList()
			self:updateItems()
			self:unloadButtons()
		end
	end
end

MapList.getStartItemIndex = function(self)
	return math.floor(self.visualItemIndex) - self:getMiddleOffset()
end

MapList.getEndItemIndex = function(self)
	return math.ceil(self.visualItemIndex) + self:getMiddleOffset()
end

MapList.calculateButtons = function(self)
	self.buttons = self.buttons or {}
	
	local itemIndexKeys = {}
	for button in pairs(self.buttons) do
		button:update()
		if button.loaded then
			itemIndexKeys[button.itemIndex] = button
		end
	end
	
	for itemIndex = self:getStartItemIndex(), self:getEndItemIndex() do
		local item = self.items[itemIndex]
		if item and not itemIndexKeys[itemIndex] then
			local button = self.Button:new({
				item = item,
				itemIndex = itemIndex,
				text = item.text,
				action = item.onClick,
				
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

MapList.getButtonByItemIndex = function(self, itemIndex)
	for button in pairs(self.buttons) do
		if button.itemIndex == itemIndex then
			return button
		end
	end
end

MapList.scrollToItemIndex = function(self, itemIndex)
	if self.items[itemIndex] then
		self.selectedItemIndex = itemIndex
		self.items[self.selectedItemIndex].onSelect(self:getButtonByItemIndex(itemIndex))
	end
	
	self:updateScrollCurrentDelta()
end

MapList.scrollBy = function(self, scrollDelta)
	self:scrollToItemIndex(self.selectedItemIndex + scrollDelta)
end

MapList.getItemIndex = function(self, item)
	for itemIndex, currentItem in ipairs(self.items) do
		if item == currentItem then
			return itemIndex
		end
	end
	
	return 1
end

MapList.Button = createClass(soul.ui.RectangleTextButton)

MapList.Button.updateY = function(self)
	self.y = self.list.y + (self.list:getMiddleOffset() - 1 + self.itemIndex - self.list.visualItemIndex) * (self.list.h / self.list.buttonCount)
end

MapList.Button.updateX = function(self)
	self.x = self.list.x
end

MapList.Button.update = function(self)
	local dt =  math.min(1/60, love.timer.getDelta())
	
	self:updateX()
	self:updateY()
	
	if self.itemIndex == self.list.selectedItemIndex then
		self.rectangleColor = self.list.selectedRectangleColor
		if not self.selected and self.item.onSelect then
			self.item.onSelect(self)
			self.selected = true
		end
	else
		self.selected = false
		self.rectangleColor = self.list.rectangleColor
	end
	
	if self.itemIndex < self.list:getStartItemIndex() or
		self.itemIndex > self.list:getEndItemIndex()
	then
		self.list.buttons[self] = nil
		self:deactivate()
	else
		self:reload()
	end
end