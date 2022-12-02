local just = require("just")
local spherefonts		= require("sphere.assets.fonts")
local gfx_util = require("gfx_util")
local math_util = require("math_util")

local BackgroundView = require("sphere.views.BackgroundView")
local UserInfoView = require("sphere.views.UserInfoView")
local LogoImView = require("sphere.imviews.LogoImView")

local TextCellImView = require("sphere.imviews.TextCellImView")
local BarCellImView = require("sphere.imviews.BarCellImView")
local IconButtonImView = require("sphere.imviews.IconButtonImView")
local TextButtonImView = require("sphere.imviews.TextButtonImView")
local CheckboxImView = require("sphere.imviews.CheckboxImView")
local SliderImView = require("sphere.imviews.SliderImView")
local LabelImView = require("sphere.imviews.LabelImView")
local RoundedRectangle = require("sphere.views.RoundedRectangle")

local time_util = require("time_util")

local Layout = require("sphere.views.EditorView.Layout")

local function drawFrameRect(w, h, _r)
	local r, g, b, a = love.graphics.getColor()
	love.graphics.setColor(0, 0, 0, 0.8)
	love.graphics.rectangle("fill", 0, 0, w, h, _r or 36)
	love.graphics.setColor(r, g, b, a)
end

local function Frames(self)
	local w, h = Layout:move("base")
	love.graphics.setColor(1, 1, 1, 0.2)
	love.graphics.rectangle("fill", 0, 0, w, h)

	local w, h = Layout:move("base", "header")
	drawFrameRect(w, h, 0)

	local w, h = Layout:move("base", "footer")
	drawFrameRect(w, h, 0)

	-- drawFrameRect(Layout:move("column3"))
	-- drawFrameRect(Layout:move("column1"))
	-- drawFrameRect(Layout:move("column2row1"))
end

local function ScreenMenu(self)
	local w, h = Layout:move("column3", "header")
	love.graphics.setFont(spherefonts.get("Noto Sans", 24))
	-- if TextButtonImView("Leave", "Leave", 120, h) then
	-- end
end

local function Background(self)
	local w, h = Layout:move("base")

	local dim = self.game.configModel.configs.settings.graphics.dim.select
	BackgroundView.game = self.game
	BackgroundView:draw(w, h, 0.8, 0.01)
end

local function Header(self)
	local w, h = Layout:move("column1", "header")

	just.row(true)

	LogoImView("logo", h, 0.5)
	if IconButtonImView("quit game", "clear", h, 0.5) then
		-- love.event.quit()
	end
	just.row()
end

local function Controls(self)
	local w, h = Layout:move("base", "header")
	love.graphics.translate(0, h)

	-- just.row(true)

	local timeEngine = self.game.rhythmModel.timeEngine

	local currentTime = timeEngine.currentTime
	local normTime = math_util.map(currentTime, timeEngine.minTime, timeEngine.maxTime, 0, 1)
	local value = SliderImView("playback scroll", normTime, w, h / 2, "qwe")
	if value then
		local time = math_util.map(value, 0, 1, timeEngine.minTime, timeEngine.maxTime)
		timeEngine:setPosition(time)
	end

	if TextButtonImView("play", "play", 100, 55, "center") then
		self.game.rhythmModel.timeEngine:play()
		self.game.rhythmModel.audioEngine:play()
	end
	if TextButtonImView("pause", "pause", 100, 55, "center") then
		self.game.rhythmModel.timeEngine:pause()
		self.game.rhythmModel.audioEngine:pause()
	end

	-- just.row()
end

return function(self)
	Background(self)
	-- Frames(self)
	-- ScreenMenu(self)
	-- Controls(self)
	-- Header(self)
end
