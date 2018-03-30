MapList = createClass(soul.SoulObject)

MapList.load = function(self)
	self.directoryList = List:new({
		x = -7/9, y = 0, w = 7/9, h = 1,
		layer = 2,
		cs = soul.CS:new(nil, 1, 0, 0, 0, "h", 768),
		rectangleColor = {255, 255, 255, 0},
		selectedRectangleColor = {255, 255, 255, 31},
		mode = "fill",
		limit = 7/9,
		textAlign = {
			x = "left", y = "center"
		},
		buttonCount = 17,
		font = mainFont20,
		upScrollKey = "left",
		downScrollKey = "right"
	})
	self.fileList = List:new({
		x = -1, y = 0, w = 1/9, h = 1,
		layer = 2,
		cs = soul.CS:new(nil, 1, 0, 0, 0, "h", 768),
		rectangleColor = {255, 255, 255, 0},
		selectedRectangleColor = {255, 255, 255, 31},
		mode = "fill",
		limit = 1/9,
		textAlign = {
			x = "center", y = "center"
		},
		buttonCount = 17,
		font = mainFont20,
		upScrollKey = "up",
		downScrollKey = "down"
	})
	
	local paths = {}
	for cacheData in cache:getCacheDataIterator() do
		if not paths[cacheData.directoryPath] then
			self.directoryList:addItem({
				text = utf8validate(cacheData.title),
				onClick = function(button)
					self.directoryList.targetOffset = button.itemIndex - self.directoryList:getMiddleOffset()
					self.directoryList:updateScrollDelta()
				end,
				onSelect = function(button)
					self:updateFileList(cacheData.directoryPath, button)
				end,
			})
			paths[cacheData.directoryPath] = true
		end
	end

	self.directoryList:activate()
	self.fileList:activate()
	
	self:loadCallbacks()
	
	self.loaded = true
end

MapList.updateFileList = function(self, directoryPath, button)
	self.fileList:clear()
	
	for cacheData in cache:getCacheDataIterator() do
		if cacheData.directoryPath == directoryPath then
			self.fileList:addItem({
				text = utf8validate(cacheData.playlevel),
				onClick = function()
					currentCacheData = cacheData
					stateManager:switchState("playing")
				end,
				onSelect = function()
					button.text = utf8validate(cacheData.title)
				end
			})
		end
	end
	
	self.fileList:reload()
end

MapList.unload = function(self)
	self.directoryList:deactivate()
	self.fileList:deactivate()
	
	self:unloadCallbacks()
	
	self.loaded = false
end


MapList.update = function(self)
end

MapList.loadCallbacks = function(self)
	soul.setCallback("keypressed", self, function(key)
		
	end)
end

MapList.unloadCallbacks = function(self)
	soul.unsetCallback("keypressed", self)
end