local ScreenView = require("sphere.views.ScreenView")
local thread = require("thread")
local just = require("just")

local Layout = require("sphere.views.ResultView.Layout")
local ResultViewConfig = require("sphere.views.ResultView.ResultViewConfig")

---@class sphere.ResultView: sphere.ScreenView
---@operator call: sphere.ResultView
local ResultView = ScreenView + {}

local loading
ResultView.load = thread.coro(function(self)
	if loading then
		return
	end
	loading = true
	self.game.resultController:load()
	if self.prevView == self.game.selectView then
		local selectModel = self.game.selectModel
		local scoreItem = selectModel.scoreItem
		if scoreItem then
			self.game.resultController:replayNoteChartAsync("result", scoreItem)
		end
	end
	loading = false
end)

function ResultView:draw()
	just.container("screen container", true)

	local kp = just.keypressed
	if kp("up") then self.game.selectModel:scrollScore(-1)
	elseif kp("down") then self.game.selectModel:scrollScore(1)
	elseif kp("escape") then self:quit()
	elseif kp("return") then self:loadScore()
	end

	Layout:draw()
	ResultViewConfig(self)
	just.container()
end

ResultView.loadScore = thread.coro(function(self, itemIndex)
	if loading then
		return
	end
	loading = true
	local scoreEntry = self.game.selectModel.scoreItem
	if itemIndex then
		scoreEntry = self.game.scoreLibraryModel.items[itemIndex]
	end
	self.game.resultController:replayNoteChartAsync("result", scoreEntry)
	if itemIndex then
		self.game.selectModel:scrollScore(nil, itemIndex)
	end
	loading = false
end)

local playing = false
ResultView.play = thread.coro(function(self, mode)
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

function ResultView:quit()
	if self.game.multiplayerModel.room then
		self:changeScreen("multiplayerView")
		return
	end
	self:changeScreen("selectView")
end

return ResultView
