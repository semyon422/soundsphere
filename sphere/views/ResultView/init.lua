local ScreenView = require("sphere.views.ScreenView")
local aquathread = require("aqua.thread")

local ResultNavigator = require("sphere.views.ResultView.ResultNavigator")
local ResultViewConfig = require("sphere.views.ResultView.ResultViewConfig")

local ResultView = ScreenView:new({construct = false})

ResultView.construct = function(self)
	ScreenView.construct(self)
	self.viewConfig = ResultViewConfig
	self.navigator = ResultNavigator:new()
end

local loading
ResultView.load = aquathread.coro(function(self)
	if loading then
		return
	end
	loading = true
	ScreenView.load(self)
	if self.prevView == self.game.selectView then
		self.game.resultController:load()
		local selectModel = self.game.selectModel
		local scoreItem = selectModel.scoreItem
		if scoreItem then
			self.game.resultController:replayNoteChartAsync("result", scoreItem)
			self:reload()
		end
	end
	self.subscreen = ""
	loading = false
end)

ResultView.unload = function(self)
	ScreenView.unload(self)
end

ResultView.reload = function(self)
	ScreenView.unload(self)
	ScreenView.load(self)
	self.sequenceView.abortIterating = false
end

ResultView.loadScore = aquathread.coro(function(self, itemIndex)
	if loading then
		return
	end
	loading = true
	local scoreEntry = self.game.selectModel.scoreItem
	if itemIndex then
		scoreEntry = self.game.scoreLibraryModel.items[itemIndex]
	end
	self.game.resultController:replayNoteChartAsync("result", scoreEntry)
	self:reload()
	if itemIndex then
		self.game.selectModel:scrollScore(nil, itemIndex)
	end
	loading = false
end)

local playing = false
ResultView.play = aquathread.coro(function(self, mode)
	if playing then
		return
	end
	playing = true
	local scoreEntry = self.game.selectModel.scoreItem
	local isResult = self.game.resultController:replayNoteChartAsync(mode, scoreEntry)
	if isResult then
		return self.view:reload()
	end
	self:changeScreen("gameplayView")
	playing = false
end)

ResultView.quit = function(self)
	if self.game.multiplayerModel.room then
		return self:changeScreen("multiplayerView")
	end
	self:changeScreen("selectView")
end

return ResultView
