local viewspackage = (...):match("^(.-%.views%.)")
local ffi = require("ffi")

local Navigator = require(viewspackage .. "Navigator")

local SelectNavigator = Navigator:new({construct = false})

SelectNavigator.load = function(self)
	Navigator.load(self)
	self:addSubscreen("score")
	self:addSubscreen("notecharts")
	self.isNoteSkinsOpen = ffi.new("bool[1]", false)
	self.isInputOpen = ffi.new("bool[1]", false)
	self.osudirectItemIndex = 1
end

SelectNavigator.receive = function(self, event)
	if event.name ~= "keypressed" then
		return
	end

	local scancode = event[2]

	if scancode == "f1" then self:changeScreen("Modifier")
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
		elseif scancode == "lalt" then self:changeScreen("Result")
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
	Navigator.update(self)
end

SelectNavigator.switchToNoteCharts = function(self)
	self:addSubscreen("notecharts")
	self:pullNoteChartSet()
end

SelectNavigator.switchToCollections = function(self)
	self:addSubscreen("collections")
end

SelectNavigator.switchToOsudirect = function(self)
	self:addSubscreen("osudirect")
	self:send({name = "searchOsudirect"})
end

SelectNavigator.openDirectory = function(self)
	self:send({name = "openDirectory"})
end

SelectNavigator.pullNoteChartSet = function(self)
	self:send({name = "pullNoteChartSet"})
end

SelectNavigator.scrollRandom = function(self)
	self:send({name = "scrollRandom"})
end

SelectNavigator.calculateTopScores = function(self)
	self:send({name = "calculateTopScores"})
end

SelectNavigator.updateCache = function(self, force)
	self:send({
		name = "updateCache",
		force = force
	})
end

SelectNavigator.updateCacheCollection = function(self)
	self:send({
		name = "updateCacheCollection",
		collection = self.gameController.selectModel.collectionItem,
		force = love.keyboard.isDown("lshift")
	})
end

SelectNavigator.deleteNoteChart = function(self)
	self:send({name = "deleteNoteChart"})
end

SelectNavigator.deleteNoteChartSet = function(self)
	self:send({name = "deleteNoteChartSet"})
end

SelectNavigator.changeSearchMode = function(self)
	self:send({name = "changeSearchMode"})
end

SelectNavigator.changeCollapse = function(self)
	self:send({name = "changeCollapse"})
end

SelectNavigator.scrollOsudirect = function(self, direction, count)
	count = count or 1
	direction = direction == "up" and -count or count
	local items = self.gameController.osudirectModel.items

	local itemIndex = math.min(math.max(self.osudirectItemIndex + direction, 1), #items)
	if not items[itemIndex] then
		return
	end

	self.osudirectItemIndex = itemIndex

	self:send({
		name = "osudirectBeatmap",
		itemIndex = self.osudirectItemIndex,
		beatmap = items[itemIndex],
	})
end

SelectNavigator.scrollCollection = function(self, direction, count)
	count = count or 1
	self:send({
		name = "scrollCollection",
		direction = direction == "up" and -count or count
	})
end

SelectNavigator.scrollNoteChartSet = function(self, direction, count)
	count = count or 1
	self:send({
		name = "scrollNoteChartSet",
		direction = direction == "up" and -count or count
	})
end

SelectNavigator.scrollNoteChart = function(self, direction, count)
	count = count or 1
	self:send({
		name = "scrollNoteChart",
		direction = direction == "up" and -count or count
	})
end

SelectNavigator.play = function(self)
	self:send({name = "playNoteChart"})
end

SelectNavigator.setSortFunction = function(self, sortFunction)
	self:send({
		name = "setSortFunction",
		sortFunction = sortFunction
	})
end

SelectNavigator.scrollSortFunction = function(self, delta)
	self:send({
		name = "scrollSortFunction",
		delta = delta
	})
end

SelectNavigator.setSearchString = function(self, text)
	self:send({
		name = "setSearchString",
		text = text
	})
end

SelectNavigator.quickLogin = function(self)
	self:send({name = "quickLogin"})
end

SelectNavigator.openNoteSkins = function(self)
	local isOpen = self.isNoteSkinsOpen
	isOpen[0] = not isOpen[0]
	if isOpen[0] then
		self:send({name = "resetModifiedNoteChart"})
	end
end

SelectNavigator.openInput = function(self)
	local isOpen = self.isInputOpen
	isOpen[0] = not isOpen[0]
	if isOpen[0] then
		self:send({name = "resetModifiedNoteChart"})
	end
end

SelectNavigator.setNoteSkin = function(self, itemIndex)
	local noteChart = self.gameController.noteChartModel.noteChart
	local noteSkins = self.gameController.noteSkinModel:getNoteSkins(noteChart.inputMode)
	self:send({
		name = "setNoteSkin",
		noteSkin = noteSkins[itemIndex or self.noteSkinItemIndex]
	})
end

SelectNavigator.setInputBinding = function(self, inputMode, virtualKey, key, type)
	self:send({
		name = "setInputBinding",
		virtualKey = virtualKey,
		value = key,
		type = type,
		inputMode = inputMode,
	})
end

return SelectNavigator
