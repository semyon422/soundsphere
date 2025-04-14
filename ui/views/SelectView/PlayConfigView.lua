local just = require("just")
local imgui = require("imgui")
local ModalImView = require("ui.imviews.ModalImView")
local _transform = require("gfx_util").transform
local spherefonts = require("sphere.assets.fonts")
local Timings = require("sea.chart.Timings")
local Subtimings = require("sea.chart.Subtimings")
local TimingValues = require("sea.chart.TimingValues")

local transform = {{1 / 2, -16 / 9 / 2}, 0, 0, {0, 1 / 1080}, {0, 1 / 1080}, 0, 0, 0, 0}

local scrollY = 0

local w, h = 792, 792
local _w, _h = w / 2, 55
local r = 8
local window_id = "PlayConfigView"

return ModalImView(function(self, quit)
	if quit then
		return true
	end

	---@type sphere.GameController
	local game = self.game

	imgui.setSize(w, h, _w, _h)

	love.graphics.setFont(spherefonts.get("Noto Sans", 24))

	love.graphics.replaceTransform(_transform(transform))
	love.graphics.translate((1920 - w) / 2, (1080 - h) / 2)

	love.graphics.setColor(0, 0, 0, 0.8)
	love.graphics.rectangle("fill", 0, 0, w, h, r)
	love.graphics.setColor(1, 1, 1, 1)

	just.push()

	imgui.Container(window_id, w, h, _h / 3, _h * 2, scrollY)

	local replay_base = game.configModel.configs.settings.replay_base

	imgui.text("Auto:")
	just.row(true)
	replay_base.auto_timings = imgui.checkbox("auto_timings", replay_base.auto_timings, "timings")
	-- replay_base.auto_healths = imgui.checkbox("auto_healths", replay_base.auto_healths, "healths")
	-- replay_base.auto_const = imgui.checkbox("auto_const", replay_base.auto_const, "const")
	-- replay_base.auto_tap_only = imgui.checkbox("auto_tap_only", replay_base.auto_tap_only, "tap only")
	just.row(false)

	imgui.separator()

	local replayBase = game.replayBase

	imgui.text(("Mode: %s"):format(replayBase.mode))
	imgui.text(("Modifiers: %d"):format(#replayBase.modifiers))
	imgui.text(("Rate: %0.3f"):format(replayBase.rate))

	local timeRateModel = game.timeRateModel
	local range = timeRateModel.range[replayBase.rate_type]
	local format = timeRateModel.format[replayBase.rate_type]
	local newRate = imgui.slider1("rate", timeRateModel:get(), format, range[1], range[2], range[3], "play rate")

	if newRate ~= timeRateModel:get() then
		game.modifierSelectModel:change()
	end
	timeRateModel:set(newRate)

	replayBase.rate_type = imgui.combo("rate_type", replayBase.rate_type, timeRateModel.types, nil, "rate type")

	just.row(true)
	replayBase.nearest = imgui.checkbox("nearest", replayBase.nearest, "nearest")
	replayBase.tap_only = imgui.checkbox("tap_only", replayBase.tap_only, "tap only")
	replayBase.const = imgui.checkbox("const", replayBase.const, "const")
	replayBase.custom = imgui.checkbox("custom", replayBase.custom, "custom")
	just.row(false)

	imgui.separator()

	local timings_config = game.configModel.configs.settings.timings
	local subtimings_config = game.configModel.configs.settings.subtimings

	local timings_name = replayBase.timings.name
	local timings_data = replayBase.timings.data
	imgui.text("Timings")

	timings_name = imgui.combo("timings_name", timings_name, Timings.names)
	if timings_name ~= replayBase.timings.name then
		timings_data = timings_config[timings_name]
		replayBase.timings = Timings(timings_name, timings_data)
		replayBase.subtimings = Subtimings(next(subtimings_config[timings_name]))
		replayBase.timing_values = TimingValues(replayBase.timings, replayBase.subtimings)
	end

	if timings_name == "osumania" then
		timings_data = math.floor(imgui.slider1("timings_data", timings_data, "%0.1f", 0, 10, 0.1) * 10 + 0.5) / 10
	elseif timings_name == "bmsrank" then
		timings_data = imgui.slider1("timings_data", timings_data, "%d", 0, 3, 1)
	else
		timings_data = 0
	end

	if timings_data ~= replayBase.timings.data then
		replayBase.timings = Timings(timings_name, timings_data)
		replayBase.timing_values = TimingValues(replayBase.timings, replayBase.subtimings)
		timings_config[timings_name] = timings_data
	end

	local subtimings_name = replayBase.subtimings.name
	local subtimings_data = replayBase.subtimings.data
	imgui.text("Subtimings")

	if timings_name == "simple" then
		subtimings_data = math.floor(imgui.slider1("subtimings_data", subtimings_data, "%0.3f", 0, 0.5, 0.001) * 1000 + 0.5) / 1000
	elseif timings_name == "osumania" then
		subtimings_data = imgui.combo("subtimings_data", subtimings_data, {1, 2}, function(v) return "score v" .. v end)
	elseif timings_name == "stepmania" then
		subtimings_data = imgui.slider1("subtimings_data", subtimings_data, "%d", 1, 9, 1, "Etterna judge")
	end

	if subtimings_data ~= replayBase.subtimings.data then
		replayBase.subtimings = Subtimings(subtimings_name, subtimings_data)
		replayBase.timing_values = TimingValues(replayBase.timings, replayBase.subtimings)
		subtimings_config[timings_name][subtimings_name] = subtimings_data
	end

	-- healths = Healths("simple", 20),
	-- columns_order = nil,

	scrollY = imgui.Container()
	just.pop()

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.rectangle("line", 0, 0, w, h, r)
end)
