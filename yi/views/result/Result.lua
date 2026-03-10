local Screen = require("yi.views.Screen")
local View = require("yi.views.View")
local Label = require("yi.views.Label")
local Image = require("yi.views.Image")
local ArtistTitle = require("yi.views.shared.ArtistTitle")
local Tags = require("yi.views.shared.Tags")
local Player = require("yi.views.shared.Player")
local ChartInfo = require("yi.views.shared.ChartInfo")
local JudgeCell = require("yi.views.result.JudgeCell")
local HitGraph = require("yi.views.result.HitGraph")
local Colors = require("yi.Colors")
local h = require("yi.h")

---@class yi.Result : yi.Screen
---@operator call: yi.Result
local Result = Screen + {}

local buttons = {
	id = "buttons",
	w = 64,
	h = "100%",
	align_self = "end",
	align_items = "center",
	justify_content = "space_between",
	arrange = "flow_col",
	padding = {15, 0, 20, 0},
	background_color = Colors.header_footer
}

local hit_graph = {
	w = 900,
	h = 260,
	background_color = Colors.panels,
	outline = {color = Colors.outline, thickness = 2}
}

---@param label yi.Label
---@param acc number?
local function setAccuracyColor(label, acc)
	acc = acc or 0

	if acc > 0.995000001 then
		label:setColor({0.45, 0.91, 1, 1})
	elseif acc > 0.95 then
		label:setColor({1, 0.93, 0.21, 1})
	elseif acc > 0.9 then
		label:setColor({0.4, 0.96, 0.4, 1})
	elseif acc > 0.8 then
		label:setColor({0.88, 0.74, 1, 1})
	elseif acc > 0.7 then
		label:setColor({1, 0.53, 0.81, 1})
	else
		label:setColor({1, 0.25, 0.25, 1})
	end
end

---@param acc number?
---@return string
local function formatAccuracy(acc)
	if type(acc) ~= "number" then
		return "??.??%"
	end

	return ("%0.02f%%"):format(acc * 100)
end

function Result:load()
	self:setup({
		id = "result",
		w = "100%",
		h = "100%",
		keyboard = true
	})

	local res = self:getResources()
	local gradient = love.graphics.newImage("resources/yi/select_bg_gradient.png")

	self.artist_title = ArtistTitle()
	self.tags = Tags()
	self.score_system_name = Label(res:getFont("bold", 24), "Loading...")
	self.accuracy = Label(res:getFont("black", 128), "??.??%")
	self.chart_info = ChartInfo()
	self.judges = View()
	self.hit_graph = HitGraph()

	self:addArray({
		h(Image(gradient), {w = "100%", h = "100%", color = Colors.panels}),

		h(View(), buttons),
		h(View(), {w = 2, h = "100%", align_self = "end", margin = {0, 64, 0, 0}, background_color = Colors.br}),

		h(View(), {w = "70%", h = "100%", arrange = "flow_col", gap = 20, padding = {20, 20, 20, 20}}, {
			h(self.tags),
			h(self.artist_title, {w = "99999%"}),
			h(View(), {arrange = "flow_col"}, {
				h(self.score_system_name, {color = Colors.lines, y = 20}),
				h(self.accuracy, {color = Colors.text})
			}),
			h(self.judges, {arrange = "flow_row", gap = 10, line_gap = 10, w = 500}),
			h(self.hit_graph, hit_graph)
		}),

		h(self.chart_info, {justify_self = "end", margin = {0, 0, 20, 20}}),

		h(Player(), {align_self = "end", justify_self = "end", margin = {0, 64 + 20, 20, 0}})
	})

	self.loaded = false
end

---@param chartview {[string]: any}
function Result:setChartview(chartview)
	self.tags:setChartview(chartview)
	self.artist_title:setChartview(chartview)
	self.chart_info:setChartview(chartview)
end

function Result:updateInformation()
	local game = self:getGame()
	local chartplay = game.computeContext.chartplay

	if not chartplay then
		return
	end

	local score_engine = game.rhythm_engine.score_engine
	local acc = chartplay.accuracy
	local acc_string = formatAccuracy(acc)
	local judges = chartplay.judges or {}
	local miss_count = chartplay.miss_count or 0

	acc = score_engine.accuracySource:getAccuracy()
	acc_string = score_engine.accuracySource:getAccuracyString()

	judges = score_engine.judgesSource:getJudges() or judges

	miss_count = score_engine.scores.base.missCount or miss_count

	self.accuracy:setText(acc_string)
	setAccuracyColor(self.accuracy, acc)

	self.score_system_name:setText("osu!mania V1 OD9")

	for _, v in ipairs(self.judges.children) do
		v:kill()
	end

	if judges[1] then self.judges:add(JudgeCell({0, 0.69, 1, 1}, judges[1])) end
	if judges[2] then self.judges:add(JudgeCell({0.93, 1, 0, 1}, judges[2])) end
	if judges[3] then self.judges:add(JudgeCell({0.27, 0.86, 0.27, 1}, judges[3])) end
	if judges[4] then self.judges:add(JudgeCell({0.29, 0.3, 1, 1}, judges[4])) end
	if judges[5] then self.judges:add(JudgeCell({0.9, 0.09, 0.63, 1}, judges[5])) end

	self.judges:add(JudgeCell({0.9, 0.09, 0.1, 1}, miss_count))

	local judges_source = score_engine.judgesSource
	local hp_source = score_engine.healthsSource
	self.hit_graph:reset()
	self.hit_graph:addHp(score_engine.sequence, hp_source:getMaxHealths())
	self.hit_graph:addHits(chartplay.timings, chartplay.subtimings, judges_source, score_engine.sequence)
end

function Result:update()
	if not self.loaded then
		local game = self:getGame()
		local chart_selector = game.chartSelector
		local chartview = chart_selector.chartview
		local chartplay = game.computeContext.chartplay

		if chartview and chartplay then
			self:setChartview(chartview)
			self:updateInformation()
			self.loaded = true
			return
		end
	end
end

function Result:enter()
	love.mouse.setVisible(true)
	love.keyboard.setTextInput(true)
	local config = self:getConfig()
	local bg = self:getContext().background
	bg:setDim(config.settings.graphics.dim.result)
	self.loaded = false
end

function Result:onKeyDown(e)
	local k = e.key

	if k == "escape" then
		self.parent:set("select")
	end
end

return Result
