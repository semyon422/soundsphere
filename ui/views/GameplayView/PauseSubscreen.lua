local Layout = require("ui.views.GameplayView.Layout")

local gfx_util = require("gfx_util")
local just = require("just")
local spherefonts = require("sphere.assets.fonts")
local imgui = require("imgui")

---@param self table
local function BottomScreenMenu(self)
	---@type rizu.RhythmEngine
	local rhythm_engine = self.game.rhythm_engine

	love.graphics.setFont(spherefonts.get("Noto Sans", 24))

	local w, h = Layout:move("footer")
	w = 279

	just.row(true)
	if imgui.TextOnlyButton("continue", "continue", w, h) then
		self.game.gameplayController:play()
	end
	if imgui.TextOnlyButton("retry", "retry", w, h) then
		self:retry()
	end
	if imgui.TextOnlyButton("quit", "quit", w, h) then
		self:quit()
	end

	just.row()

	w, h = Layout:move("header")
	love.graphics.translate(2 / 3 * w, 0)

	just.row(true)

	-- if imgui.TextOnlyButton("step_l", "left", h, h) then
	-- 	self.game.rhythmModel.timeEngine:stepTimePoint(true)
	-- end
	-- if imgui.TextOnlyButton("step_r", "right", h, h) then
	-- 	self.game.rhythmModel.timeEngine:stepTimePoint()
	-- end

	-- local ms = 1
	-- if love.keyboard.isDown("lshift") then
	-- 	ms = 10
	-- elseif love.keyboard.isDown("lctrl") then
	-- 	ms = 0.1
	-- end
	-- if imgui.TextOnlyButton("step_-", "-" .. ms .. "ms", h, h) then
	-- 	self.game.rhythmModel.timeEngine:stepTime(-ms / 1000)
	-- end
	-- if imgui.TextOnlyButton("step_+", "+" .. ms .. "ms", h, h) then
	-- 	self.game.rhythmModel.timeEngine:stepTime(ms / 1000)
	-- end

	just.row(true)

	imgui.Label("ctime", rhythm_engine.time_engine.time, h)
	just.next(h / 2)
	imgui.Label("vtime", rhythm_engine.time_engine.enh_time, h)
	-- just.next(h / 2)
	-- imgui.Label("cindex", self.game.rhythmModel.timeEngine.nearestTime.currentIndex, h)

	just.row()
end

---@param self table
local function FailedText(self)
	if not self.game.rhythm_engine.score_engine.healthsSource:isFailed() then
		return
	end
	local w, h = Layout:move("base")
	love.graphics.setColor(1, 1, 1, 0.25)
	love.graphics.setFont(spherefonts.get("Noto Sans", 240))
	gfx_util.printFrame("failed", 0, 0, w, h, "center", "center")
end

return function(self)
	BottomScreenMenu(self)
	FailedText(self)
end
