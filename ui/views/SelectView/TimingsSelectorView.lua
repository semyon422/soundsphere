local imgui = require("imgui")
local Timings = require("sea.chart.Timings")
local Subtimings = require("sea.chart.Subtimings")
local TimingValuesFactory = require("sea.chart.TimingValuesFactory")

---@param game sphere.GameController
local function TimingsSelectorView(game)
	local replayBase = game.replayBase

	local timings_config = game.configModel.configs.settings.timings
	local subtimings_config = game.configModel.configs.settings.subtimings

	local timings_name = replayBase.timings.name
	local timings_data = replayBase.timings.data

	timings_name = imgui.combo("timings_name", timings_name, Timings.names)
	if timings_name ~= replayBase.timings.name then
		timings_data = timings_config[timings_name]
		replayBase.timings = Timings(timings_name, timings_data)

		local st_config = subtimings_config[timings_name]
		replayBase.subtimings = st_config and Subtimings(st_config[1], st_config[st_config[1]]) or nil

		if timings_name ~= "arbitrary" then
			replayBase.timing_values = assert(TimingValuesFactory:get(replayBase.timings, replayBase.subtimings))
		end
	end

	if timings_name == "simple" then
		timings_data = math.floor(imgui.slider1("timings_data", timings_data, "%0.3f", 0, 0.5, 0.001) * 1000 + 0.5) / 1000
	elseif timings_name == "osuod" then
		timings_data = math.floor(imgui.slider1("timings_data", timings_data, "%0.1f", 0, 10, 0.1) * 10 + 0.5) / 10
	elseif timings_name == "etternaj" then
		timings_data = imgui.slider1("timings_data", timings_data, "%d", 1, 9, 1)
	elseif timings_name == "bmsrank" then
		timings_data = imgui.slider1("timings_data", timings_data, "%d", 0, 3, 1)
	else
		timings_data = 0
	end

	if timings_data ~= replayBase.timings.data then
		replayBase.timings = Timings(timings_name, timings_data)
		replayBase.timing_values = assert(TimingValuesFactory:get(replayBase.timings, replayBase.subtimings))
		timings_config[timings_name] = timings_data
	end

	if replayBase.subtimings then
		local subtimings_name = replayBase.subtimings.name
		local subtimings_data = replayBase.subtimings.data
		imgui.text("Subtimings")

		if timings_name == "osuod" then
			subtimings_data = imgui.combo("subtimings_data", subtimings_data, {1, 2}, function(v) return "score v" .. v end)
		end

		if subtimings_data ~= replayBase.subtimings.data then
			replayBase.subtimings = Subtimings(subtimings_name, subtimings_data)
			replayBase.timing_values = assert(TimingValuesFactory:get(replayBase.timings, replayBase.subtimings))
			subtimings_config[timings_name][subtimings_name] = subtimings_data
		end
	end

	if imgui.button("open timings", "timings") then
		game.ui.gameView:setModal(require("ui.views.TimingsModalView"))
	end
end

return TimingsSelectorView
