local viewspackage = (...):match("^(.-%.views%.)")

local Navigator = require(viewspackage .. "Navigator")

local SelectNavigator = Navigator:new()

SelectNavigator.receive = function(self, event)
	if event.name == "keypressed" then
		local scancode = event.args[2]
		if scancode == "up" then self:scrollNoteChartUp()
		elseif scancode == "down" then self:scrollNoteChartDown()
		elseif scancode == "left" then self:scrollNoteChartSetUp()
		elseif scancode == "right" then self:scrollNoteChartSetDown()
		elseif scancode == "f5" then self:updateCache()
		end
	end
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

SelectNavigator.scrollNoteChartSetUp = function(self)
	self:send({
		name = "scrollNoteChartSet",
		direction = -1
	})
end

SelectNavigator.scrollNoteChartSetDown = function(self)
	self:send({
		name = "scrollNoteChartSet",
		direction = 1
	})
end

SelectNavigator.scrollNoteChartDown = function(self)
	self:send({
		name = "scrollNoteChart",
		direction = 1
	})
end

SelectNavigator.scrollNoteChartUp = function(self)
	self:send({
		name = "scrollNoteChart",
		direction = -1
	})
end

SelectNavigator.play = function(self)
	self:send({
		action = "playNoteChart"
	})
end

return SelectNavigator
