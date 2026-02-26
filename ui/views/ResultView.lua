local ScreenView = require("ui.views.ScreenView")
local thread = require("thread")
local just = require("just")
local table_util = require("table_util")

local Layout = require("ui.views.ResultView.Layout")
local ResultViewConfig = require("ui.views.ResultView.ResultViewConfig")

---@class ui.ResultView: ui.ScreenView
---@operator call: ui.ResultView
local ResultView = ScreenView + {}

local loading
ResultView.load = thread.coro(function(self)
	if loading then
		return
	end
	loading = true
	self.game.resultController:load()
	if self.prevView == self.ui.selectView then
		self.game.resultController:replayNoteChartAsync("result", self.game.selectModel.scoreItem)
	end

	loading = false
end)

function ResultView:draw()
	just.container("screen container", true)

	local kp = just.keypressed
	if kp("up") then
		self.game.selectModel:scrollScore(-1)
	elseif kp("down") then
		self.game.selectModel:scrollScore(1)
	elseif kp("escape") then
		self:quit()
	elseif kp("return") then
		self:loadScore()
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
	self.game.gameInteractor:loadScoreAsync(itemIndex)
	loading = false
end)

local playing = false
ResultView.play = thread.coro(function(self, mode)
	if playing then
		return
	end
	playing = true
	self.game.resultController:replayNoteChartAsync(mode, self.game.selectModel.scoreItem)
	if mode == "result" then
		return self.view:reload()
	end
	self:changeScreen("gameplayView")
	playing = false
end)

function ResultView:quit()
	self.game.resultController:unload()
	if self.game.multiplayerModel.client:isInRoom() then
		self:changeScreen("multiplayerView")
		return
	end
	self:changeScreen("selectView")
end

return ResultView
