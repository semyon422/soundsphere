local View = require("yi.views.View")
local Label = require("yi.views.Label")
local Screen = require("yi.views.Screen")
local ChartSetList = require("yi.views.select.ChartSetList")
local BottomButton = require("yi.views.select.Button")
local Image = require("yi.views.Image")
local Cell = require("yi.views.select.Cell")
local Tag = require("yi.views.select.Tag")
local Colors = require("yi.Colors")
local ChartGrid = require("yi.views.select.ChartGrid")
local TabContainer = require("yi.views.components.TabContainer")
local Textbox = require("yi.views.components.Textbox")
local Button = require("yi.views.components.Button")
local h = require("yi.h")

local ImGuiSettings = require("ui.views.SettingsView")
local ImGuiModifiers = require("ui.views.ModifierView.ModifierView")
local ImGuiInputs = require("ui.views.InputView")
local ImGuiSkins = require("ui.views.NoteSkinView")
local ImGuiGameplayConfig = require("ui.views.SelectView.PlayConfigView")
local ImGuiFilters = require("ui.views.SelectView.FiltersView")

---@class yi.Select : yi.Screen
---@overload fun(): yi.Select
local Select = Screen + {}

local FOOTER_HEIGHT = 50

local info_side = {
	w = "70%",
	h = "100%",
	arrange = "flex_col",
	justify_content = "space_between",
}

local outline = {outline = {color = Colors.outline, thickness = 2}}

---@return yi.View
function Select:newContent()
	local res = self:getResources()
	local modals = self:getContext().modals
	local function open_filters() modals:setImguiModal(ImGuiFilters) end

	self.ranked_tag = Tag()
	self.chart_format_tag = Tag()
	self.title = Label(res:getFont("black", 72), "LOADING...")
	self.artist = Label(res:getFont("bold", 58), "LOADING...")
	self.mode_cell = Cell("Mode")
	self.bpm_cell = Cell("BPM")
	self.duration_cell = Cell("Duration")
	self.notes_cell = Cell("Notes")
	self.chart_set_list = ChartSetList()
	self.chart_grid = ChartGrid()
	self.tags = View()

	return h(View(), {w = "100%", h = "100%", padding = {10, 10, 10 + FOOTER_HEIGHT, 10}}, {
		h(View(), info_side, {
			h(View(), {arrange = "flex_col", gap = 20}, {
				h(View(), {arrange = "flex_row", gap = 10}, {
					self.ranked_tag,
					self.chart_format_tag
				}),
				h(View(), {arrange = "flex_col", w = 999999}, {
					h(self.title),
					h(self.artist, {y = -5, color = Colors.lines}),
				}),
				h(View(), {arrange = "wrap_row", gap = 10, line_gap = 10}, {
					self.mode_cell,
					self.bpm_cell,
					self.duration_cell,
					self.notes_cell
				}),
				h(self.chart_grid, {w = "100%", h = 70}),
			}),
			h(View(), {arrange = "wrap_row"}, {
				h(View(), {arrange = "wrap_col", w = 150}, {
					h(Label(res:getFont("bold", 24), "MSD")),
					h(Label(res:getFont("bold", 58), "29.5"), {color = {1, 0.1, 0.1, 1}}),
					h(Label(res:getFont("bold", 36), "1.00x")),
				}),
				h(View(), {arrange = "wrap_col", justify_content = "space_between"}, {
					h(View(), {arrange = "wrap_col"}, {
						h(Label(res:getFont("bold", 24), "16% LN")),
						h(Label(res:getFont("bold", 24), "Technical\nStamina")),
					}),
					h(Label(res:getFont("bold", 24), "Const AltK AM10 BS AM14 NLN"), {y = -6}),
				}),
			})
		}),
		h(View(), {w = "30%", h = "100%", arrange = "flex_col", align_self = "end", gap = 10}, {
			h(View(), {arrange = "flex_col", gap = 10, padding = {10, 10, 10, 10}, background_color = Colors.panels, outline}, {
				h(Textbox("", "Search songs...", function() end), {w = "100%"}),
				h(View(), {arrange = "flex_row", gap = 5}, {
					h(Button("Filters", open_filters), {grow = 1}),
					h(Button("Collections", function() end), {grow = 1}),
				}),
			}),
			h(View(), {arrange = "flex_col", grow = 1, outline}, {
				h(self.chart_set_list, {grow = 1, stencil = true, background_color = Colors.panels}),
				h(View(), {padding = {10, 10, 10, 10}, background_color = Colors.panels, align_items = "center"}, {
					h(Label(res:getFont("regular", 16), "Directory name")),
				})
			}),
		}),
	})
end

local small_button = {
	arrange = "flex_col",
	justify_content = "center",
	align_items = "center",
	padding = {5, 0, 5, 0},
	width = 110,
	shrink = 1
}

---@return yi.View
function Select:newFooter()
	local res = self:getResources()
	local modals = self:getContext().modals
	local function open_config() modals:setImguiModal(ImGuiSettings) end
	local function open_mods() modals:setImguiModal(ImGuiModifiers) end
	local function open_inputs() modals:setImguiModal(ImGuiInputs) end
	local function open_skins() modals:setImguiModal(ImGuiSkins) end
	local function open_gameplay() modals:setImguiModal(ImGuiGameplayConfig) end
	local function play() self.parent:set("gameplay") end

	return h(View(), {h = FOOTER_HEIGHT, arrange = "wrap_row", justify_self = "end", background_color= Colors.header_footer}, {
		h(BottomButton(open_config), small_button, {
			Label(res:getFont("icons", 24), ""),
			h(Label(res:getFont("bold", 16), "CONFIG"), {align = "center"}),
		}),
		h(BottomButton(open_mods), small_button, {
			Label(res:getFont("icons", 24), ""),
			h(Label(res:getFont("bold", 16), "MODS"), {align = "center"}),
		}),
		h(BottomButton(open_inputs), small_button, {
			Label(res:getFont("icons", 24), ""),
			h(Label(res:getFont("bold", 16), "INPUTS"), {align = "center"}),
		}),
		h(BottomButton(open_skins), small_button, {
			Label(res:getFont("icons", 24), ""),
			h(Label(res:getFont("bold", 16), "SKINS"), {align = "center"}),
		}),
		h(BottomButton(open_gameplay), small_button, {
			Label(res:getFont("icons", 24), ""),
			h(Label(res:getFont("bold", 16), "GAMEPLAY"), {align = "center"}),
		}),
		h(BottomButton(play), small_button, {
			Label(res:getFont("icons", 24), ""),
			Label(res:getFont("bold", 16), "PLAY"),
		})
	})
end

function Select:load()
	Screen.load(self)
	local game = self:getGame()
	self.select_controller = game.selectController
	self.select_model = game.selectModel

	self:setup({
		id = "select",
		keyboard = true,
		w = "100%",
		h = "100%"
	})

	local gradient = love.graphics.newImage("resources/yi/select_bg_gradient.png")

	self:addArray({
		h(Image(gradient), {w = "100%", h = "100%", color = {0, 0, 0, 1}}),
		h(View(), {w = "100%", h = "100%"}, {
			self:newContent(),
			self:newFooter()
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
	self:observeGameMutations()
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
		self.ranked_tag:setTextColor(Colors.text)
	end

	self.chart_format_tag:setText((chartview.format or "unknown"):upper())

	self.title:setText(chartview.title)
	self.artist:setText(chartview.artist)

	local input_mode = chartview.inputmode:gsub("key", "K"):gsub("scratch", "S")
	self.mode_cell:setValueText(input_mode)
	self.bpm_cell:setValueText(("%i"):format(chartview.tempo * rate))

	local duration = chartview.duration * rate
	local minutes = duration / 60
	local seconds = duration % 60
	self.duration_cell:setValueText(("%i:%02i"):format(minutes, seconds))

	self.notes_cell:setValueText(tostring(chartview.notes_count))
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
end

return Select
