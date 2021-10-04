local viewspackage = (...):match("^(.-%.views%.)")

local Navigator = require(viewspackage .. "Navigator")

local SelectNavigator = Navigator:new({construct = false})

SelectNavigator.load = function(self)
	Navigator.load(self)
	self:addSubscreen("score")
	self:addSubscreen("notecharts")
end

SelectNavigator.receive = function(self, event)
	if event.name ~= "keypressed" then
		return
	end

	local notecharts = self:getSubscreen("notecharts")
	local collections = self:getSubscreen("collections")

	local scancode = event.args[2]
	print(scancode)
	if notecharts then
		if scancode == "up" then self:scrollNoteChart("up")
		elseif scancode == "down" then self:scrollNoteChart("down")
		elseif scancode == "left" then self:scrollNoteChartSet("up")
		elseif scancode == "right" then self:scrollNoteChartSet("down")
		elseif scancode == "pageup" then self:scrollNoteChartSet("up", 10)
		elseif scancode == "pagedown" then self:scrollNoteChartSet("down", 10)
		elseif scancode == "home" then self:scrollNoteChartSet("up", math.huge)
		elseif scancode == "end" then self:scrollNoteChartSet("down", math.huge)
		elseif scancode == "return" then self:play()
		elseif scancode == "lctrl" then self:changeSearchMode()
		elseif scancode == "lshift" then self:changeCollapse()
		elseif scancode == "tab" then self:addSubscreen("collections")
		elseif scancode == "lalt" then self:changeScreen("Result")
		elseif scancode == "f1" then self:changeScreen("Modifier")
		elseif scancode == "f2" then self:changeScreen("NoteSkin")
		elseif scancode == "f3" then self:changeScreen("Input")
		elseif scancode == "f4" then self:changeScreen("Settings")
		end
	elseif collections then
		if scancode == "up" or scancode == "left" then self:scrollCollection("up")
		elseif scancode == "down" or scancode == "right" then self:scrollCollection("down")
		elseif scancode == "pageup" then self:scrollCollection("up", 10)
		elseif scancode == "pagedown" then self:scrollCollection("down", 10)
		elseif scancode == "home" then self:scrollCollection("up", math.huge)
		elseif scancode == "end" then self:scrollCollection("down", math.huge)
		elseif scancode == "return" or scancode == "tab" then self:addSubscreen("notecharts")
		end
	end
end

SelectNavigator.update = function(self)
	self:removeLessSubscreens("score", "options")
	self:removeLessSubscreens("notecharts", "collections")
end

SelectNavigator.openDirectory = function(self)
	self:send({name = "openDirectory"})
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

return SelectNavigator
