MapList = createClass(soul.SoulObject)

MapList.visualItemIndex = 1
MapList.selectedItemIndex = 1

MapList.x = 0
MapList.y = 0
MapList.w = 1
MapList.h = 1
MapList.layer = 2
MapList.rectangleColor = {255, 255, 255, 0}
MapList.textColor = {255, 255, 255, 255}
-- MapList.selectedRectangleColor = {255, 255, 255, 31}
MapList.selectedRectangleColor = {255, 255, 255, 0}
MapList.mode = "fill"
MapList.limit = 2
MapList.textAlign = {
	x = "left", y = "center"
}
MapList.buttonCount = 17
MapList.upScrollKey = "up"
MapList.downScrollKey = "down"

MapList.focus = "MapList"

MapList.load = function(self)
	soul.focus[self.focus] = true
	
	self.cs = soul.CS:new(nil, 0, 0, 0, 0, "all", 576)
	self.squarecs = soul.CS:new(nil, 0, 0, 0, 0, "h", 576)
	self.font = self.core.fonts.main20
	
	self.scrollCurrentDelta = 0

	self:loadCache()
	self:sortCache()
	self:selectRandomCacheData()
	self:updateSelectionList()
	
	self:loadOverlay()
	self:updateItems()
	self.visualItemIndex = self.selectedItemIndex
	
	self:calculateButtons()
end

MapList.getSelectionKeyString = function(self, cacheData)
	local selectionKey
	
	if cacheData.container == "directory" or cacheData.container == "file-single" then
		selectionKey = cacheData.directoryPath .. "/" .. cacheData.fileName
	elseif cacheData.container == "file-multiple" then
		selectionKey = cacheData.directoryPath .. "/" .. cacheData.fileName .. "/" .. cacheData.index
	end
	
	return selectionKey
end

MapList.getSelectionKey = function(self, cacheData)
	return self:getSelectionKeyString(cacheData):split("/")
end

MapList.loadCache = function(self)
	self.cacheDatas = {}
	self.cacheDatasKey = {}
	self.cacheDatasContainer = {}
	
	for cacheData in self.core.cache:getCacheDataIterator() do
		table.insert(self.cacheDatas, cacheData)
		self.cacheDatasKey[self:getSelectionKeyString(cacheData)] = cacheData
		
		local selectionKey = self:getSelectionKey(cacheData)
		selectionKey[#selectionKey] = nil
		local container = table.concat(selectionKey, "/")
		
		if cacheData.container ~= "file-single" then
			self.cacheDatasContainer[container] = self.cacheDatasContainer[container] or {}
			table.insert(self.cacheDatasContainer[container], cacheData)
		end
	end
end

MapList.sortCache = function(self)
	table.sort(self.cacheDatas, function(a, b)
		return
			self:getSelectionKeyString(a)
			<
			self:getSelectionKeyString(b)
	end)
end

MapList.selectRandomCacheData = function(self)
	math.randomseed(os.time())
	local cacheData = self.cacheDatas[math.random(#self.cacheDatas)]
	self.currentCacheData = cacheData
	self.core.currentCacheData = self.currentCacheData
	
	self.selectionKey = self:getSelectionKey(cacheData)
	while #self.selectionKey > 2 do
		self.selectionKey[#self.selectionKey] = nil
	end
end

MapList.updateCurrentCacheData = function(self)
	if self.cacheDatasKey[table.concat(self.selectionKey, "/")] then
		self.currentCacheData = self.cacheDatasKey[table.concat(self.selectionKey, "/")]
		self.core.currentCacheData = self.currentCacheData
	end
end

MapList.updateSelectionList = function(self)
	self.selectionList = {}
	
	for _, cacheData in ipairs(self.cacheDatas) do
		local selectionKey = self:getSelectionKey(cacheData)
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
	
	for selectionKeyIndex, selectionKey in ipairs(self.selectionList) do
		if table.leftequal(self.selectionKey, selectionKey) then
			self.selectedItemIndex = selectionKeyIndex
			self.visualItemIndex = selectionKeyIndex
			break
		end
	end
	
	if not self.cacheDatasContainer[table.concat(self.selectionKey, "/")] then
		self.core.backgroundManager:setBackground(table.concat(self.selectionKey, "/") .. "/background.jpg")
	end
end

MapList.updateItems = function(self)
	self.items = {}
	
	for _, selectionKey in ipairs(self.selectionList) do
		self:addItem({
			text = ("    "):rep(#selectionKey) .. utf8validate(self:getItemName(selectionKey)),
			-- text = utf8validate(self:getItemName(selectionKey)),
			onClick = function(button)
				if button.itemIndex == self.selectedItemIndex then
					self.selectionKey = selectionKey
					self:updateSelectionList()
					self:updateCurrentCacheData()
					self:updateItems()
					self:unloadButtons()
					self:calculateButtons()
					if self.cacheDatasKey[table.concat(selectionKey, "/")] then
						self.core.stateManager:switchState("playing")
					end
				else
					self:scrollToItemIndex(button.itemIndex)
				end
			end,
			onSelect = function(button)
				local path = table.concat(selectionKey, "/")
				if self.cacheDatasKey[path] then
					self.selectionKey = selectionKey
					self:updateCurrentCacheData()
				end
			end,
			selectionKey = selectionKey
		})
	end
	
	if self.selectedItemIndex > #self.items then
		self.selectedItemIndex = #self.items
		self.visualItemIndex = #self.items
	end
end

MapList.getItemName = function(self, selectionKey)
	local cacheDataKey = table.concat(selectionKey, "/")
	
	local cacheDatasContainer = self.cacheDatasContainer[cacheDataKey]
	if cacheDatasContainer then
		local artist, title = cacheDatasContainer[1].artist, cacheDatasContainer[1].title
		if artist and title then
			return artist .. " - " .. title
		else
			return title or ""
		end
	end
	
	local cacheData = self.cacheDatasKey[cacheDataKey]
	if cacheData then
		local artist, title = cacheData.artist, cacheData.title
		if artist and title then
			return artist .. " - " .. title
		else
			return title or ""
		end
	end
	
	return selectionKey[#selectionKey]
end

MapList.addItem = function(self, item)
	table.insert(self.items, item)
end

MapList.getItemCount = function(self)
	return #self.items
end

MapList.unload = function(self)
	self:unloadButtons()
	self:unloadOverlay()
	soul.focus[self.focus] = false
end

MapList.getMiddleOffset = function(self)
	return math.ceil(self.buttonCount / 2)
end

MapList.update = function(self)
	local dt =  math.min(1/60, love.timer.getDelta())
	local sign = math.sign(self.scrollCurrentDelta)
	local scrollCurrentDelta = sign * math.max(math.abs(self.scrollCurrentDelta), 1) * 8 * dt
	
	if self.selectedItemIndex < 1 then
		self.selectedItemIndex = 1
	elseif self.selectedItemIndex > self:getItemCount() then
		self.selectedItemIndex = self:getItemCount()
	end
	if (scrollCurrentDelta > 0 and self.visualItemIndex + scrollCurrentDelta > self.selectedItemIndex)
	or (scrollCurrentDelta < 0 and self.visualItemIndex + scrollCurrentDelta < self.selectedItemIndex)
	then
		self.visualItemIndex = self.selectedItemIndex
		self.scrollCurrentDelta = 0
	else
		self.visualItemIndex = self.visualItemIndex + scrollCurrentDelta
	end
	
	self:calculateButtons()
end

MapList.receiveEvent = function(self, event)
	if soul.focus[self.focus] and event.name == "love.update" then
		self:update()
	elseif soul.focus[self.focus] and event.name == "love.wheelmoved" then
		local direction = event.data[2]
		self:scrollBy(-direction)
	elseif soul.focus[self.focus] and event.name == "love.keypressed" then
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
			if self.cacheDatasKey[table.concat(self.selectionKey, "/")] then
				self.selectionKey[#self.selectionKey] = nil
			end
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

MapList.loadOverlay = function(self)
	self.selectionFrame = soul.graphics.Rectangle:new({
		x = self.x, y = self.y + (self:getMiddleOffset() - 1) * (self.h / self.buttonCount),
		w = 0.03, h = self.h / self.buttonCount,
		layer = self.layer + 1,
		cs = self.squarecs,
		color = {255, 255, 255, 255},
		mode = "fill"
	})
	self.selectionFrame:activate()
	self.selectionBackground = soul.graphics.Rectangle:new({
		x = self.x, y = self.y,
		w = self.w, h = self.h,
		layer = self.layer - 1,
		cs = self.cs,
		color = {0, 0, 0, 127},
		color = {0, 0, 0, 127},
		mode = "fill"
	})
	self.selectionBackground:activate()
end

MapList.unloadOverlay = function(self)
	self.selectionFrame:deactivate()
	self.selectionBackground:deactivate()
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
	-- local dt =  math.min(1/60, love.timer.getDelta())
	-- self.scrollCurrentDelta = (self.selectedItemIndex - self.visualItemIndex) * dt * 8
	self.scrollCurrentDelta = (self.selectedItemIndex - self.visualItemIndex)
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

MapList.Button.focus = "MapList"

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