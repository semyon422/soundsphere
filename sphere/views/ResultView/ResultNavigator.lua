local viewspackage = (...):match("^(.-%.views%.)")

local Navigator = require(viewspackage .. "Navigator")

local ResultNavigator = Navigator:new({construct = false})

ResultNavigator.receive = function(self, event)
	if event.name ~= "keypressed" then
		return
	end

	local scancode = event.args[2]
	if scancode == "up" then self:scrollScore("up")
	elseif scancode == "down" then self:scrollScore("down")
	elseif scancode == "escape" then self:changeScreen("Select")
	elseif scancode == "return" then self:loadScore()
	elseif scancode == "f1" then self:showDebug()
	end
end

ResultNavigator.scrollScore = function(self, direction)
	self:send({
		name = "scrollScore",
		direction = direction == "down" and 1 or -1
	})
end

ResultNavigator.loadScore = function(self, itemIndex)
	local scoreEntry = self.selectModel.scoreItem.scoreEntry
	if itemIndex then
		scoreEntry = self.scoreLibraryModel.items[itemIndex].scoreEntry
	end
	self:send({
		name = "loadScore",
		mode = "result",
		scoreEntry = scoreEntry,
		itemIndex = itemIndex
	})
end

ResultNavigator.play = function(self, mode)
	local scoreEntry = self.selectModel.scoreItem.scoreEntry
	self:send({
		name = "loadScore",
		mode = mode,
		scoreEntry = scoreEntry
	})
end

return ResultNavigator
