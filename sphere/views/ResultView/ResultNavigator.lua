local viewspackage = (...):match("^(.-%.views%.)")

local Navigator = require(viewspackage .. "Navigator")

local ResultNavigator = Navigator:new({construct = false})

ResultNavigator.receive = function(self, event)
	if event.name ~= "keypressed" then
		return
	end

	local scancode = event[2]
	if scancode == "up" then self:scrollScore("up")
	elseif scancode == "down" then self:scrollScore("down")
	elseif scancode == "escape" then self:changeScreen("selectView")
	elseif scancode == "return" then self:loadScore()
	elseif scancode == "f1" then self:switchSubscreen("debug")
	elseif scancode == "f2" then self:switchSubscreen("scoreSystemDebug")
	elseif scancode == "f3" then self:switchSubscreen("countersDebug")
	elseif scancode == "f4" then self:switchSubscreen("scoreEntryDebug")
	end
end

ResultNavigator.scrollScore = function(self, direction)
	self.game.selectModel:scrollScore(direction == "down" and 1 or -1)
end

ResultNavigator.loadScore = function(self, itemIndex)
	local scoreEntry = self.game.selectModel.scoreItem
	if itemIndex then
		scoreEntry = self.game.scoreLibraryModel.items[itemIndex]
	end
	self.game:resetGameplayConfigs()
	self.game.resultController:replayNoteChart("result", scoreEntry, itemIndex)
	return self:changeScreen("resultView")
end

ResultNavigator.play = function(self, mode)
	local scoreEntry = self.game.selectModel.scoreItem
	local isResult = self.game.resultController:replayNoteChart(mode, scoreEntry)
	if isResult then
		return self:changeScreen("resultView")
	end
	self:changeScreen("gameplayView")
end

ResultNavigator.back = function(self)
	self.game:resetGameplayConfigs()
	self:changeScreen("selectView")
end

return ResultNavigator
