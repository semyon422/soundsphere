local View = require("yi.views.View")
local Label = require("yi.views.Label")
local Screen = require("yi.views.Screen")
local ChartSetList = require("yi.views.Select.ChartSetList")
local Button = require("yi.views.Select.Button")
local Image = require("yi.views.Image")
local Cell = require("yi.views.Select.Cell")
local Tag = require("yi.views.Select.Tag")
local Colors = require("yi.Colors")
local h = require("yi.h")

local ImGuiSettings = require("ui.views.SettingsView")
local ImGuiModifiers = require("ui.views.ModifierView")
local ImGuiInputs = require("ui.views.InputView")
local ImGuiSkins = require("ui.views.NoteSkinView")
local ImGuiGameplayConfig = require("ui.views.SelectView.PlayConfigView")

---@class yi.Select : yi.Screen
---@overload fun(): yi.Select
local Select = Screen + {}

local info_side = {
	w = "70%",
	h = "100%",
	padding = {20, 20, 20, 20},
	justify_content = "space_between",
	arrange = "flex_col",
	align_items = "stretch",
	gap = 20,
	stencil = true
}

local small_button = {
	arrange = "flex_col",
	align_items = "center",
	padding = {5, 10, 5, 10},
	min_w = 102,
}

local play_button = {
	arrange = "flex_row",
	justify_content = "center",
	align_items = "center",
	padding = {5, 10, 5, 10},
	gap = 10,
	grow = 1
}

function Select:load()
	Screen.load(self)
	local game = self:getGame()
	self.select_controller = game.selectController
	self.select_model = game.selectModel

	self.id = "select"
	self.handles_keyboard_input = true

	self:setWidth("100%")
	self:setHeight("100%")

	local modals = self:getContext().modals
	local function open_config() modals:setImguiModal(ImGuiSettings) end
	local function open_mods() modals:setImguiModal(ImGuiModifiers) end
	local function open_inputs() modals:setImguiModal(ImGuiInputs) end
	local function open_skins() modals:setImguiModal(ImGuiSkins) end
	local function open_gameplay() modals:setImguiModal(ImGuiGameplayConfig) end
	local function play() self.parent:set("gameplay") end

	local res = self:getResources()
	self.ranked_tag = Tag()
	self.chart_format_tag = Tag()
	self.title = Label(res:getFont("black", 72), "LOADING...")
	self.artist = Label(res:getFont("bold", 58), "LOADING...")
	self.difficilty_cell = Cell("Difficulty")
	self.mode_cell = Cell("Mode")
	self.bpm_cell = Cell("BPM")
	self.duration_cell = Cell("Duration")
	self.notes_cell = Cell("Notes")
	self.chart_set_list = ChartSetList()

	local gradient = love.graphics.newImage("yi/assets/gradient.png")

	self:addArray({
		h(Image(gradient), {w = "100%", h = "100%", color = {0, 0, 0, 0.7}}),
		h(View(), info_side, {
			h(View(), {arrange = "flex_col", gap = 15}, {
				h(View(), {arrange = "flex_row", gap = 10}, {
					self.ranked_tag,
					self.chart_format_tag
				}),
				h(View(), {arrange = "flex_col"}, {
					self.title,
					h(self.artist, {y = -5, color = Colors.lines}),
				}),
				h(View(), {arrange = "flex_row", gap = 10}, {
					self.difficilty_cell,
					self.mode_cell,
					self.bpm_cell,
					self.duration_cell,
					self.notes_cell
				}),
			}),
			h(View(), {arrange = "flex_row", align_items = "stretch", gap = 10}, {
				h(Button(open_config), small_button, {
					Label(res:getFont("icons", 24), ""),
					Label(res:getFont("bold", 16), "CONFIG"),
				}),
				h(Button(open_mods), small_button, {
					Label(res:getFont("icons", 24), ""),
					Label(res:getFont("bold", 16), "MODS"),
				}),
				h(Button(open_inputs), small_button, {
					Label(res:getFont("icons", 24), ""),
					Label(res:getFont("bold", 16), "INPUTS"),
				}),
				h(Button(open_skins), small_button, {
					Label(res:getFont("icons", 24), ""),
					Label(res:getFont("bold", 16), "SKINS"),
				}),
				h(Button(open_gameplay), small_button, {
					Label(res:getFont("icons", 24), ""),
					Label(res:getFont("bold", 16), "GAMEPLAY"),
				}),
				h(Button(play), play_button, {
					Label(res:getFont("icons", 24), ""),
					Label(res:getFont("bold", 16), "PLAY"),
				})
			})
		}),
		h(self.chart_set_list, {w = "30%", h = "100%", pivot = "top_right"})
	})
end

function Select:enter()
	self.select_controller:load()
	love.mouse.setVisible(true)
end

function Select:exit()
	self.select_controller:unload()
	self:kill()
end

function Select:update(_)
	self.select_controller:update()
	self:observeSelectModelMutations()
end

function Select:onKeyDown(e)
	local k = e.key

	if k == "j" then
		self.select_model:scrollNoteChartSet(1)
	elseif k == "k" then
		self.select_model:scrollNoteChartSet(-1)
	elseif k == "return" then
		self.parent:set("gameplay")
	end
end

---@param chartview {[string]: any}?
function Select:setChartview(chartview)
	if not chartview then
		return
	end

	if chartview.hash == self.prev_chart_hash then
		return
	end

	self.prev_chart_hash = chartview.hash

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
	self.difficilty_cell:setValueText(("%0.02f"):format(chartview.difficulty))

	local input_mode = chartview.inputmode:gsub("key", "K"):gsub("scratch", "S")
	self.mode_cell:setValueText(input_mode)
	self.bpm_cell:setValueText(("%i"):format(chartview.tempo))

	local minutes = chartview.duration / 60
	local seconds = chartview.duration % 60
	self.duration_cell:setValueText(("%i:%02i"):format(minutes, seconds))

	self.notes_cell:setValueText(tostring(chartview.notes_count))
end

function Select:onChartChanged()
	self:setChartview(self.select_model.chartview)
end

function Select:onChartSetChanged()
	self:setChartview(self.select_model.chartview)
end

function Select:onLibraryReloaded()
	self.chart_set_list:reloadItems()
end

function Select:observeSelectModelMutations()
	local chartview_i = self.select_model.chartview_index
	local chartview_set_i = self.select_model.chartview_set_index
	local sets_count = self.select_model.noteChartSetLibrary.itemsCount

	local chart_changed = chartview_i ~= self.prev_chart_view_index
	local chart_set_changed = chartview_set_i ~= self.prev_chart_view_set_index
	local sets_reloaded = sets_count ~= self.prev_sets_count

	if chart_changed then
		self.prev_chart_view_index = chartview_i
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
end


function Select:receive(event)
	self.select_controller:receive(event)
end

return Select
