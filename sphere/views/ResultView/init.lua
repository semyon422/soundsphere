local ScreenView = require("sphere.views.ScreenView")
local thread = require("thread")
local just = require("just")
local table_util = require("table_util")

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
		self.game.resultController:replayNoteChartAsync("result", self.game.selectModel.scoreItem)
	end

	self:updateJudgements()

	local config = self.game.configModel.configs.select
	local selectedJudgement = config.judgements

	if not self.judgements[selectedJudgement] then
		local k, _ = next(self.judgements)
		config.judgements = k
	end

	loading = false
end)

function ResultView:updateJudgements()
	local scoreSystems = self.game.rhythmModel.scoreEngine.scoreSystem
	self.selectors = {
		scoreSystems["soundsphere"].metadata,
		scoreSystems["quaver"].metadata,
		scoreSystems["osuMania"].metadata,
		scoreSystems["osuLegacy"].metadata,
		scoreSystems["etterna"].metadata,
		scoreSystems["lr2"].metadata,
	}

	self.judgements = {}

	for _, scoreSystem in pairs(scoreSystems) do
		table_util.copy(scoreSystem.judges, self.judgements)
	end

	local judgementScoreSystem = scoreSystems["judgement"]
	for _, judge in ipairs(judgementScoreSystem.judgementList) do
		table.insert(self.selectors, judge)
		table_util.copy(judgementScoreSystem.judges[judge.name], self.judgements)
	end
end

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
	local scoreEntry = self.game.selectModel.scoreItem
	if itemIndex then
		scoreEntry = self.game.selectModel.scoreLibrary.items[itemIndex]
	end
	self.game.resultController:replayNoteChartAsync("result", scoreEntry)
	if itemIndex then
		self.game.selectModel:scrollScore(nil, itemIndex)
		self:updateJudgements()
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
