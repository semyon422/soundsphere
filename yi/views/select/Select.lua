local View = require("yi.views.View")
local Label = require("yi.views.Label")
local Screen = require("yi.views.Screen")
local ChartSetList = require("yi.views.select.ChartSetList")
local ArtistTitle = require("yi.views.shared.ArtistTitle")
local Image = require("yi.views.Image")
local Tag = require("yi.views.shared.Tag")
local Colors = require("yi.Colors")
local ChartGrid = require("yi.views.select.ChartGrid")
local Textbox = require("yi.views.components.Textbox")
local SelectButton = require("yi.views.select.SelectButton")
local h = require("yi.h")

local ImGuiSettings = require("ui.views.SettingsView")
local ImGuiModifiers = require("ui.views.ModifierView.ModifierView")
local ImGuiInputs = require("ui.views.InputView")
local ImGuiSkins = require("ui.views.NoteSkinView")
local ImGuiGameplayConfig = require("ui.views.SelectView.PlayConfigView")
local ImGuiFilters = require("ui.views.SelectView.FiltersView")

local ModifierEncoder = require("sphere.models.ModifierEncoder")
local ModifierModel = require("sphere.models.ModifierModel")
local ChartPreviewView = require("sphere.views.SelectView.ChartPreviewView")

---@class yi.Select : yi.Screen
---@overload fun(): yi.Select
local Select = Screen + {}

Select.id = "Select"

local cell = {
	min_w = 180,
	arrange = "flow_row",
	gap = 10,
	align_items = "center"
}

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

function Select:load()
	Screen.load(self)
	local game = self:getGame()
	self.select_controller = game.selectController
	self.select_model = game.selectModel

	self.chart_preview_view = ChartPreviewView(self:getGame())
	self.chart_preview_view:load()

	self:setup({
		keyboard = true,
		w = "100%",
		h = "100%",
	})

	local gradient = love.graphics.newImage("resources/yi/select_bg_gradient.png")
	local res = self:getResources()

	local modals = self:getContext().modals
	local function open_filters() modals:setImguiModal(ImGuiFilters) end
	local function open_config() modals:setImguiModal(ImGuiSettings) end
	local function open_mods() modals:setImguiModal(ImGuiModifiers) end
	local function open_inputs() modals:setImguiModal(ImGuiInputs) end
	local function open_skins() modals:setImguiModal(ImGuiSkins) end
	local function play() self.parent:set("gameplay") end

	self.ranked_tag = Tag()
	self.chart_format_tag = Tag()
	self.artist_title = ArtistTitle()
	self.chart_grid = ChartGrid()

	self.patterns = Label(res:getFont("bold", 24), "Loading...\nLoading...")
	self.rate_const = Label(res:getFont("bold", 24), "1.00x")
	self.difficulty_calc = Label(res:getFont("regular", 16), "Loading...")
	self.difficulty = Label(res:getFont("black", 72), "??.?")
	self.mods = Label(res:getFont("black", 36), "Loading...")
	self.score_system = Label(res:getFont("bold", 24), "Loading...")
	self.gamemode = Label(res:getFont("bold", 24), "Loading...")
	self.bpm = Label(res:getFont("bold", 24), "Loading...")
	self.duration = Label(res:getFont("bold", 24), "Loading...")
	self.notes = Label(res:getFont("bold", 24), "Loading...")
	self.ln_percent = Label(res:getFont("bold", 24), "Loading...")

	local avatar_frame = love.graphics.newImage("resources/yi/avatar_frame.png")
	local player_info_h = 64
	self.chart_set_list = ChartSetList()

	self:addArray({
		h(Image(gradient), {w = "100%", h = "100%", color = Colors.panels}),

		h(View(), buttons, {
			h(View(), {arrange = "flow_col", align_items = "center", gap = 15}, {
				h(SelectButton(), {w = 45, h = 45, icon = "", active = true}),
				h(SelectButton(), {w = 45, h = 45, icon = ""}),
				h(SelectButton(), {w = 45, h = 45, icon = ""}),

				h(View(), {w = "60%", h = 2, background_color = Colors.br}),

				h(SelectButton(), {w = 45, h = 45, callback = open_config, icon = ""}),
				h(SelectButton(), {w = 45, h = 45, callback = open_mods, icon = ""}),
				h(SelectButton(), {w = 45, h = 45, callback = open_inputs, icon = ""}),
				h(SelectButton(), {w = 45, h = 45, callback = open_skins, icon = ""}),
				h(SelectButton(), {w = 45, h = 45, callback = open_filters, icon = ""}),
			}),

			h(SelectButton(), {w = 45, h = 45, callback = play, icon = ""}),
		}),

		h(View(), {w = 2, h = "100%", align_self = "end", margin = {0, 64, 0, 0}, background_color = Colors.br}),

		h(self.chart_set_list, {w = "100%", h = "100%", margin = {0, 64, 0, 0}}),
		h(Textbox("", "Search songs...", function() end), {margin = {20, 20, 0, 0}, x = -64, w = 500, align_self = "end"}),

		h(View(), {w = "100%", padding = {20, 20, 20, 20}}, {
			h(View(), {arrange = "flow_row", gap = 10}, {
				self.ranked_tag,
				self.chart_format_tag
			}),
		}),

		h(View(), {id = "top_left", w = "70%", h = "100%", padding = {20, 20, 20, 20}}, {
			h(View(), {arrange = "flow_col", gap = 20, y = 50}, {
				h(self.artist_title, {w = "100%"}),
				h(self.chart_grid, {w = "100%", h = 70}),
			}),
		}),

		h(View(), {id = "bottom_left", arrange = "flow_col", gap = 20, justify_self = "end", padding = {20, 20, 20, 20}}, {
			h(View(), {arrange = "flow_row", gap = 20, line_gap = 20}, {
				h(View(), {w = 180, arrange = "flow_col"}, {
					h(self.difficulty_calc, {color = Colors.lines}),
					h(self.difficulty, {color = Colors.text}),
				}),
				h(self.patterns, {w = 180, align = "right", align_self = "end", y = -12}),
				h(View(), {w = 2, height = 80, background_color = Colors.br, align_self = "end", y = -12}),
				h(View(), {arrange = "flow_col", justify_content = "end"}, {
					h(Label(res:getFont("regular", 16), "MODIFIERS"), {color = Colors.lines, y = -8}),
					h(View(), {arrange = "flow_row", gap = 10, align_items = "end"}, {
						h(self.mods, {y = -8}),
						h(self.rate_const, {y = -12, color = Colors.accent}),
						h(self.score_system, {y = -12, color = Colors.lines}),
					})
				})
			}),

			h(View(), {w = 900, h = 2, background_color = Colors.br}),

			h(View(), {arrange = "flow_row", gap = 20}, {
				h(View(), cell, {
					h(Label(res:getFont("regular", 16), "DURATION"), {color = Colors.lines}),
					self.duration,
				}),
				h(View(), cell, {
					h(Label(res:getFont("regular", 16), "NOTES"), {color = Colors.lines}),
					self.notes,
				}),
				h(View(), cell, {
					h(Label(res:getFont("regular", 16), "MODE"), {color = Colors.lines}),
					self.gamemode,
				}),
				h(View(), cell, {
					h(Label(res:getFont("regular", 16), "TEMPO"), {color = Colors.lines}),
					self.bpm,
				}),
				h(View(), cell, {
					h(Label(res:getFont("regular", 16), "LN"), {color = Colors.lines}),
					self.ln_percent,
				}),
			})
		}),

		h(View(), {id = "bottom_right", arrange = "flow_col", align_self = "end", justify_self = "end", align_items = "end", gap = 10, padding = {0, 20, 20, 0}, x = -64}, {
			h(View(), {arrange = "flow_row", gap = 20, align_items = "center"}, {
				h(View(), {arrange = "flow_col"}, {
					h(Label(res:getFont("black", 24), "Guest"), {align = "right"}),
					h(Label(res:getFont("bold", 16), "#5 • 93.56%"), {align = "right"})
				}),
				h(Label(res:getFont("black", 46), "6.769pp"), {color = Colors.accent, align = "right"}),
				h(Image(avatar_frame), {w = player_info_h, h = player_info_h}),
			})
		}),
	})
end

function Select:enter()
	self.select_controller:load()
	love.mouse.setVisible(true)

	local config = self:getConfig()
	local bg = self:getContext().background
	bg:setDim(config.settings.graphics.dim.select)
end

function Select:exit()
	self.select_controller:unload()
end

function Select:update(_)
	self.select_controller:update()
	self.chart_preview_view:update(dt)
	self:observeGameMutations()
end

function Select:draw()
	self.chart_preview_view:draw()
end

function Select:onKeyDown(e)
	local k = e.key
	local modals = self:getContext().modals
	local game = self:getGame()

	if k == "j" then
		self.select_model:scrollNoteChartSet(1)
		return true
	elseif k == "k" then
		self.select_model:scrollNoteChartSet(-1)
		return true
	elseif k == "h" then
		self.select_model:scrollNoteChart(-1)
		return true
	elseif k == "l" then
		self.select_model:scrollNoteChart(1)
		return true
	elseif k == "m" then
		modals:setImguiModal(ImGuiModifiers)
		return true
	elseif k == "i" then
		modals:setImguiModal(ImGuiInputs)
		return true
	elseif k == "s" then
		modals:setImguiModal(ImGuiSkins)
		return true
	elseif k == "c" then
		modals:setImguiModal(ImGuiSettings)
		return true
	elseif k == "g" then
		modals:setImguiModal(ImGuiGameplayConfig)
		return true
	elseif k == "f" then
		modals:setImguiModal(ImGuiFilters)
		return true
	elseif k == "[" then
		game.timeRateModel:increase(-1)
		game.modifierSelectModel:change()
		self:updateChartview()
		return true
	elseif k == "]" then
		game.timeRateModel:increase(1)
		game.modifierSelectModel:change()
		self:updateChartview()
		return true
	elseif k == "return" then
		self.parent:set("gameplay")
		return true
	end
end

local format_difficulty_calc = {
	enps_diff = "ENPS",
	osu_diff = "Star Rating",
	msd_diff = "MSD",
	user_diff = "USER"
}

---@param data {[string]: number}
---@return string
---@return string?
local function getTopSkills(data)
	local max_v = -math.huge
	local max_k ---@type string

	for k, v in pairs(data) do
		if k ~= "overall" then
			if v > max_v then
				max_v = v
				max_k = k
			end
		end
	end

	local second_v = -math.huge
	local second_k ---@type string?

	for k, v in pairs(data) do
		if k ~= "overall" and k ~= max_k then
			if v > max_v * 0.93 and v > second_v then
				second_v = v
				second_k = k
			end
		end
	end

	return max_k, second_k
end

---@param mods sea.Modifier[] | string
---@return string
local function getModifierString(mods)
	if type(mods) == "string" then
		mods = ModifierEncoder:decode(mods)
	end

	local results = {}
	for _, mod in pairs(mods) do
		local modifier = ModifierModel:getModifier(mod.id)

		if modifier then
			local modifierString, modifierSubString = modifier:getString(mod)
			local fullMod = modifierString .. (modifierSubString or "")
			table.insert(results, fullMod)
		end
	end

	return table.concat(results, " ")
end

function Select:updateChartview()
	---@type {[string]: any}?
	local chartview = self.select_model.chartview

	if not chartview then
		return
	end

	local rate = self:getGame().timeRateModel:get()

	self.prev_chart_hash = chartview.hash
	self.prev_rate = rate

	local is_ranked = chartview.difftable_chartmetas and #chartview.difftable_chartmetas > 0

	if is_ranked then
		self.ranked_tag:setText("RANKED")
		self.ranked_tag:setBackgroundColor(Colors.accent)
		self.ranked_tag:setTextColor({0, 0, 0, 1})
	else
		self.ranked_tag:setText("UNRANKED")
		self.ranked_tag:setBackgroundColor(Colors.lines)
		self.ranked_tag:setTextColor({0, 0, 0, 1})
	end

	self.chart_format_tag:setText((chartview.format or "unknown"):upper())
	self.artist_title:setChartview(chartview)

	local input_mode = chartview.inputmode:gsub("key", "K"):gsub("scratch", "S")
	self.gamemode:setText(input_mode)
	self.bpm:setText(("%i"):format(chartview.tempo * rate))

	local duration = chartview.duration * rate
	local minutes = duration / 60
	local seconds = duration % 60
	self.duration:setText(("%i:%02i"):format(minutes, seconds))

	self.notes:setText(tostring(chartview.notes_count))

	local config = self:getConfig()
	local diff_column = config.settings.select.diff_column
	local difficulty = 0
	local hue = 0

	if diff_column == "msd_diff" then
		difficulty = chartview.msd_diff
		hue = Colors.convertDiffToHue((math.min(difficulty, 40) / 40) / 1.3)
	elseif diff_column == "osu_diff" then
		difficulty = chartview.osu_diff
		hue = Colors.convertDiffToHue((math.min(difficulty, 10) / 10))
	elseif diff_column == "enps_diff" then
		difficulty = chartview.enps_diff
		hue = Colors.convertDiffToHue((math.min(difficulty, 30) / 30))
	elseif diff_column == "user_diff" then
		difficulty = chartview.user_diff
		hue = 0
	end

	self.difficulty_calc:setText(format_difficulty_calc[diff_column])
	self.difficulty:setText(("%0.01f"):format(difficulty))
	self.difficulty:setColor(Colors.HSV(hue, 1, 1))

	local pattern_max, pattern_second = getTopSkills(chartview.msd_diff_data)

	if pattern_second then
		self.patterns:setText(("%s\n%s"):format(pattern_max:upper(), pattern_second:upper()))
	else
		self.patterns:setText(("\n%s"):format(pattern_max:upper()))
	end

	local note_count = chartview.notes_count
	local long_notes_count = (chartview.judges_count or 0) - note_count
	local ln_percent = long_notes_count / note_count
	self.ln_percent:setText(("%i%%"):format(ln_percent * 100))
	self.ln_percent:setColor(Colors.HSV(Colors.convertDiffToHue(math.min(ln_percent * 1.3)), ln_percent, 1))

	local game = self:getGame()
	local mods_str = getModifierString(game.replayBase.modifiers)
	self.mods:setText(mods_str == "" and "No mods" or mods_str)

	local const = game.replayBase.const

	if const then
		self.rate_const:setText(("%0.2fx CONST"):format(game.timeRateModel:get()))
	else
		self.rate_const:setText(("%0.2fx"):format(game.timeRateModel:get()))
	end

	self.score_system:setText("osu!mania V1 OD9")
end

function Select:onChartChanged()
	self:updateChartview()
end

function Select:onChartSetChanged()
	self.chart_grid:reloadItems()
end

function Select:onLibraryReloaded()
	self.chart_set_list:reloadItems()
end

function Select:onRateChanged()
	self:updateChartview()
end

function Select:observeGameMutations()
	local game = self:getGame()
	local chartview = self.select_model.chartview

	local chart_hash = chartview and chartview.hash or ""
	local chartview_set_i = self.select_model.chartview_set_index
	local sets_count = self.select_model.noteChartSetLibrary.itemsCount
	local rate = game.timeRateModel:get()

	local chart_hash_changed = chart_hash ~= self.prev_chart_hash
	local chart_set_changed = chartview_set_i ~= self.prev_chart_view_set_index
	local sets_reloaded = sets_count ~= self.prev_sets_count
	local rate_changed = rate ~= self.prev_rate

	if chart_hash_changed then
		self.prev_chart_hash = chart_hash
		self:onChartChanged()
	end

	if chart_set_changed then
		self.prev_chart_view_set_index = chartview_set_i
		self:onChartSetChanged()
	end

	if sets_reloaded then
		self.prev_sets_count = sets_count
		self:onLibraryReloaded()
	end

	if rate_changed then
		self.prev_rate = rate
		self:onRateChanged()
	end
end

function Select:receive(event)
	self.select_controller:receive(event)
	self.chart_preview_view:receive(event)
end

return Select
