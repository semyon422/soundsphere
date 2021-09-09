local viewspackage = (...):match("^(.-%.views%.)")

local Navigator = require(viewspackage .. "Navigator")

local SelectNavigator = Navigator:new({construct = false})

SelectNavigator.receive = function(self, event)
	if event.name ~= "keypressed" then
		return
	end

	local scancode = event.args[2]
	if scancode == "up" then self:scrollNoteChart("up")
	elseif scancode == "down" then self:scrollNoteChart("down")
	elseif scancode == "left" then self:scrollNoteChartSet("up")
	elseif scancode == "right" then self:scrollNoteChartSet("down")
	elseif scancode == "f5" then self:updateCache()
	elseif scancode == "return" then self:play()
	elseif scancode == "lctrl" then self:changeSearchMode()
	elseif scancode == "lshift" then self:changeCollapse()
	elseif scancode == "f1" then self:changeScreen("Modifier")
	elseif scancode == "f2" then self:changeScreen("NoteSkin")
	elseif scancode == "f3" then self:changeScreen("Input")
	elseif scancode == "f4" then self:changeScreen("Settings")
	elseif scancode == "tab" then self:changeScreen("Result")
	end
end

SelectNavigator.changeSearchMode = function(self)
	self:send({
		name = "changeSearchMode"
	})
end

SelectNavigator.changeCollapse = function(self)
	self:send({
		name = "changeCollapse"
	})
end

SelectNavigator.updateCache = function(self)
	local cacheUpdater = self.view.cacheModel.cacheUpdater
	if cacheUpdater.state == 0 or cacheUpdater.state == 3 then
		self:send({
			name = "startCacheUpdate"
		})
	else
		self:send({
			name = "stopCacheUpdate"
		})
	end
end

SelectNavigator.scrollNoteChartSet = function(self, direction)
	self:send({
		name = "scrollNoteChartSet",
		direction = direction == "up" and -1 or 1
	})
end

SelectNavigator.scrollNoteChart = function(self, direction)
	self:send({
		name = "scrollNoteChart",
		direction = direction == "down" and 1 or -1
	})
end

SelectNavigator.play = function(self)
	self:send({
		action = "playNoteChart"
	})
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

return SelectNavigator
