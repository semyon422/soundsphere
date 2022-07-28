local ffi = require("ffi")

local Navigator = require("sphere.views.Navigator")

local SelectNavigator = Navigator:new({construct = false})

SelectNavigator.osudirectItemIndex = 1
SelectNavigator.osudirectDifficultyItemIndex = 1
SelectNavigator.searchMode = "filter"

SelectNavigator.load = function(self)
	Navigator.load(self)
	self:addSubscreen("score")
	self:addSubscreen("notecharts")
	self.isNoteSkinsOpen = ffi.new("bool[1]", false)
	self.isInputOpen = ffi.new("bool[1]", false)
	self.isSettingsOpen = ffi.new("bool[1]", false)
	self.isOnlineOpen = ffi.new("bool[1]", false)
	self.isMountsOpen = ffi.new("bool[1]", false)
	self.isModifiersOpen = ffi.new("bool[1]", false)

	self.activeList = "modifierList"
end

SelectNavigator.receive = function(self, event)
	if event.name ~= "keypressed" then
		return
	end

	local scancode = event[2]

	if self.isModifiersOpen[0] then
		if self.activeList == "modifierList" then
			if scancode == "up" then self:scrollModifier("up")
			elseif scancode == "down" then self:scrollModifier("down")
			elseif scancode == "tab" then self.activeList = "availableModifierList"
			elseif scancode == "return" then
			elseif scancode == "backspace" then self:removeModifier()
			elseif scancode == "right" then self:increaseModifierValue(nil, 1)
			elseif scancode == "left" then self:increaseModifierValue(nil, -1)
			end
		elseif self.activeList == "availableModifierList" then
			if scancode == "up" then self:scrollAvailableModifier("up")
			elseif scancode == "down" then self:scrollAvailableModifier("down")
			elseif scancode == "tab" then self.activeList = "modifierList"
			elseif scancode == "return" then self:addModifier()
			end
		end
		if scancode == "escape" or scancode == "f1" then self:openModifiers() end
		return
	end

	if scancode == "f1" then self:openModifiers()
	elseif scancode == "f2" then self:scrollRandom()
	elseif scancode == "lctrl" then self:changeSearchMode()
	elseif scancode == "lshift" then self:changeCollapse()
	end
	if self:getSubscreen("notecharts") then
		if scancode == "up" then self:scrollNoteChart("up")
		elseif scancode == "down" then self:scrollNoteChart("down")
		elseif scancode == "left" then self:scrollNoteChartSet("up")
		elseif scancode == "right" then self:scrollNoteChartSet("down")
		elseif scancode == "pageup" then self:scrollNoteChartSet("up", 10)
		elseif scancode == "pagedown" then self:scrollNoteChartSet("down", 10)
		elseif scancode == "home" then self:scrollNoteChartSet("up", math.huge)
		elseif scancode == "end" then self:scrollNoteChartSet("down", math.huge)
		elseif scancode == "return" then self:play()
		elseif scancode == "tab" then self:switchToCollections()
		elseif scancode == "lalt" then self:result()
		end
	elseif self:getSubscreen("collections") then
		if scancode == "up" or scancode == "left" then self:scrollCollection("up")
		elseif scancode == "down" or scancode == "right" then self:scrollCollection("down")
		elseif scancode == "pageup" then self:scrollCollection("up", 10)
		elseif scancode == "pagedown" then self:scrollCollection("down", 10)
		elseif scancode == "home" then self:scrollCollection("up", math.huge)
		elseif scancode == "end" then self:scrollCollection("down", math.huge)
		elseif scancode == "return" or scancode == "tab" then self:switchToNoteCharts()
		end
	elseif self:getSubscreen("osudirect") then
		if scancode == "up" or scancode == "left" then self:scrollOsudirect("up")
		elseif scancode == "down" or scancode == "right" then self:scrollOsudirect("down")
		elseif scancode == "pageup" then self:scrollOsudirect("up", 10)
		elseif scancode == "pagedown" then self:scrollOsudirect("down", 10)
		elseif scancode == "home" then self:scrollOsudirect("up", math.huge)
		elseif scancode == "end" then self:scrollOsudirect("down", math.huge)
		elseif scancode == "escape" or scancode == "tab" then self:switchToCollections()
		end
	end
end

SelectNavigator.update = function(self)
	self:removeLessSubscreens("score", "options")
	self:removeLessSubscreens("notecharts", "collections", "osudirect")

	local multiplayerModel = self.game.multiplayerModel
	if multiplayerModel.room and multiplayerModel.isPlaying then
		self:play()
	end

	Navigator.update(self)
end

SelectNavigator.switchToNoteCharts = function(self)
	self:addSubscreen("notecharts")
	self.searchMode = "filter"
	self.game.selectModel:noDebouncePullNoteChartSet()
end

SelectNavigator.switchToCollections = function(self)
	self:addSubscreen("collections")
end

SelectNavigator.switchToOsudirect = function(self)
	self.searchMode = "osudirect"
	self:addSubscreen("osudirect")
	self.game.osudirectModel:searchNoDebounce()
end

SelectNavigator.openDirectory = function(self)
	self.game.selectController:openDirectory()
end

SelectNavigator.pullNoteChartSet = function(self)
	self.game.selectModel:debouncePullNoteChartSet()
end

SelectNavigator.scrollRandom = function(self)
	self.game.selectModel:scrollRandom()
end

SelectNavigator.calculateTopScores = function(self)
	self.game.scoreModel:asyncCalculateTopScores()
end

SelectNavigator.updateCache = function(self, force)
	self.game.selectController:updateCache(force)
end

SelectNavigator.updateCacheCollection = function(self)
	self.game.selectController:updateCacheCollection(
		self.game.selectModel.collectionItem.path,
		love.keyboard.isDown("lshift")
	)
end

SelectNavigator.deleteNoteChart = function(self)
	self:send({name = "deleteNoteChart"})
end

SelectNavigator.deleteNoteChartSet = function(self)
	self:send({name = "deleteNoteChartSet"})
end

SelectNavigator.setSearchMode = function(self, searchMode)
	self.searchMode = searchMode
end

SelectNavigator.changeSearchMode = function(self)
	if self.searchMode == "filter" then
		self:setSearchMode("lamp")
	else
		self:setSearchMode("filter")
	end
end

SelectNavigator.changeCollapse = function(self)
	self.game.selectModel:changeCollapse()
end

SelectNavigator.scrollOsudirect = function(self, direction, count)
	count = count or 1
	direction = direction == "up" and -count or count
	local items = self.game.osudirectModel.items

	local itemIndex = math.min(math.max(self.osudirectItemIndex + direction, 1), #items)
	if not items[itemIndex] then
		return
	end

	self.osudirectItemIndex = itemIndex

	self.game.osudirectModel:setBeatmap(items[itemIndex])
end

SelectNavigator.scrollOsudirectDifficulty = function(self, direction, count)
	count = count or 1
	direction = direction == "up" and -count or count
	local items = self.game.osudirectModel:getDifficulties()

	local itemIndex = math.min(math.max(self.osudirectDifficultyItemIndex + direction, 1), #items)
	if not items[itemIndex] then
		return
	end

	self.osudirectDifficultyItemIndex = itemIndex
end

SelectNavigator.scrollCollection = function(self, direction, count)
	count = count or 1
	self.game.selectModel:scrollCollection(direction == "up" and -count or count)
end

SelectNavigator.scrollNoteChartSet = function(self, direction, count)
	count = count or 1
	self.game.selectModel:scrollNoteChartSet(direction == "up" and -count or count)
end

SelectNavigator.scrollNoteChart = function(self, direction, count)
	count = count or 1
	self.game.selectModel:scrollNoteChart(direction == "up" and -count or count)
end

SelectNavigator.scrollScore = function(self, direction)
	self.game.selectModel:scrollScore(direction == "down" and 1 or -1)
end

SelectNavigator.loadScore = function(self, itemIndex)
	if itemIndex then
		self.game.selectModel:scrollScore(nil, itemIndex)
	end
end

SelectNavigator.downloadBeatmapSet = function(self)
	self.game.osudirectModel:downloadBeatmapSet(self.game.osudirectModel.beatmap)
end

SelectNavigator.play = function(self)
	if self.game.selectModel:notechartExists() then
		self:changeScreen("gameplayView")
	end
end

SelectNavigator.result = function(self)
	if self.game.selectModel:isPlayed() then
		self:changeScreen("resultView")
	end
end

SelectNavigator.setSortFunction = function(self, sortFunction)
	self.game.selectModel:setSortFunction(sortFunction)
end

SelectNavigator.scrollSortFunction = function(self, delta)
	self.game.selectModel:scrollSortFunction(delta)
end

SelectNavigator.setSearchString = function(self, text)
	if self:getSubscreen("notecharts") then
		self.game.searchModel:setSearchString(self.searchMode, text)
	elseif self:getSubscreen("osudirect") then
		self.game.osudirectModel:setSearchString(text)
	end
end

SelectNavigator.quickLogin = function(self)
	self.game.onlineModel.authManager:quickLogin()
end

SelectNavigator.login = function(self, email, password)
	self.game.onlineModel.authManager:login(email, password)
end

SelectNavigator.openNoteSkins = function(self)
	local isOpen = self.isNoteSkinsOpen
	isOpen[0] = not isOpen[0]
	if isOpen[0] then
		self.game.selectController:resetModifiedNoteChart()
	end
end

SelectNavigator.openInput = function(self)
	local isOpen = self.isInputOpen
	isOpen[0] = not isOpen[0]
	if isOpen[0] then
		self.game.selectController:resetModifiedNoteChart()
	end
end

SelectNavigator.openSettings = function(self)
	local isOpen = self.isSettingsOpen
	isOpen[0] = not isOpen[0]
end

SelectNavigator.openOnline = function(self)
	local isOpen = self.isOnlineOpen
	isOpen[0] = not isOpen[0]
end

SelectNavigator.openMounts = function(self)
	local isOpen = self.isMountsOpen
	isOpen[0] = not isOpen[0]
end

SelectNavigator.openModifiers = function(self)
	local isOpen = self.isModifiersOpen
	isOpen[0] = not isOpen[0]
	self.game.multiplayerModel:pushModifiers()
end

SelectNavigator.setNoteSkin = function(self, itemIndex)
	local noteChart = self.game.noteChartModel.noteChart
	local noteSkins = self.game.noteSkinModel:getNoteSkins(noteChart.inputMode)
	self.game.noteSkinModel:setDefaultNoteSkin(noteSkins[itemIndex or self.noteSkinItemIndex])
end

SelectNavigator.setInputBinding = function(self, inputMode, virtualKey, key, type)
	self.game.inputModel:setKey(inputMode, virtualKey, key, type)
end

SelectNavigator.scrollModifier = function(self, direction)
	self.game.modifierModel:scrollModifier(direction == "up" and -1 or 1)
end

SelectNavigator.scrollAvailableModifier = function(self, direction)
	self.game.modifierModel:scrollAvailableModifier(direction == "up" and -1 or 1)
end

SelectNavigator.removeModifier = function(self, itemIndex)
	local modifierConfig = self.game.modifierModel.config[itemIndex or self.game.modifierModel.modifierItemIndex]
	if not modifierConfig then
		return
	end
	self.game.modifierModel:remove(modifierConfig)
end

SelectNavigator.increaseModifierValue = function(self, itemIndex, delta)
	local modifierConfig = self.game.modifierModel.config[itemIndex or self.game.modifierModel.modifierItemIndex]
	if not modifierConfig then
		return
	end
	self.game.modifierModel:increaseModifierValue(modifierConfig, delta)
end

SelectNavigator.addModifier = function(self, itemIndex)
	local modifier = self.game.modifierModel.modifiers[itemIndex or self.game.modifierModel.availableModifierItemIndex]
	self.game.modifierModel:add(modifier)
end

SelectNavigator.setModifierValue = function(self, modifierConfig, value)
	self.game.modifierModel:setModifierValue(modifierConfig, value)
end


return SelectNavigator
