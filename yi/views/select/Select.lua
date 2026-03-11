local View = require("yi.views.View")
local Label = require("yi.views.Label")
local Screen = require("yi.views.Screen")
local ChartSetList = require("yi.views.select.ChartSetList")
local ArtistTitle = require("yi.views.shared.ArtistTitle")
local Image = require("yi.views.Image")
local Tags = require("yi.views.shared.Tags")
local Colors = require("yi.Colors")
local ChartGrid = require("yi.views.select.ChartGrid")
local Textbox = require("yi.views.components.Textbox")
local SelectButton = require("yi.views.select.SelectButton")
local Player = require("yi.views.shared.Player")
local ChartInfo = require("yi.views.shared.ChartInfo")
local PreviewSeekBar = require("yi.views.select.PreviewSeekBar")
local h = require("yi.h")

local ImGuiSettings = require("ui.views.SettingsView")
local ImGuiModifiers = require("ui.views.ModifierView.ModifierView")
local ImGuiInputs = require("ui.views.InputView")
local ImGuiSkins = require("ui.views.NoteSkinView")
local ImGuiGameplayConfig = require("ui.views.SelectView.PlayConfigView")
local ImGuiFilters = require("ui.views.SelectView.FiltersView")
local ImGuiDlc = require("ui.views.DlcModalView")

local ChartPreviewView = require("sphere.views.SelectView.ChartPreviewView")

---@class yi.Select : yi.Screen
---@overload fun(): yi.Select
local Select = Screen + {}

Select.id = "Select"

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
	self.chart_selector = game.chartSelector

	self.chart_preview_view = ChartPreviewView(self:getGame())
	self.chart_preview_view:load()

	self:setup({
		keyboard = true,
		w = "100%",
		h = "100%",
	})

	local gradient = love.graphics.newImage("resources/yi/select_bg_gradient.png")

	local modals = self:getContext().modals
	local function open_filters() modals:setImguiModal(ImGuiFilters) end
	local function open_config() modals:setImguiModal(ImGuiSettings) end
	local function open_mods() modals:setImguiModal(ImGuiModifiers) end
	local function open_inputs() modals:setImguiModal(ImGuiInputs) end
	local function open_skins() modals:setImguiModal(ImGuiSkins) end
	local function open_dlc() modals:setImguiModal(ImGuiDlc) end
	local function play() self.parent:set("gameplay") end

	self.tags = Tags()
	self.artist_title = ArtistTitle()
	self.chart_grid = ChartGrid()

	self.chart_set_list = ChartSetList()
	self.player = Player()
	self.chart_info = ChartInfo()
	self.preview_seek_bar = PreviewSeekBar(game.previewModel)

	self:addArray({
		h(Image(gradient), {w = "100%", h = "100%", color = Colors.panels}),

		h(View(), buttons, {
			h(View(), {arrange = "flow_col", align_items = "center", gap = 15}, {
				h(SelectButton(), {w = 45, h = 45, icon = "", active = true}),
				h(SelectButton(), {w = 45, h = 45, icon = ""}),
				h(SelectButton(), {w = 45, h = 45, callback = open_dlc, icon = ""}),

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

		h(View(), {w = "70%", h = "100%", arrange = "flow_col", gap = 20, padding = {20, 20, 20, 20}}, {
			h(self.tags),
			h(self.artist_title, {w = "999999%"}),
			h(self.chart_grid, {w = "100%", h = 70}),
		}),

		h(self.chart_info, {justify_self = "end", margin = {0, 0, 20, 20}}),
		h(self.preview_seek_bar, {align_self = "end", justify_self = "end", margin = {0, 64 + 20, 100, 0}}),
		h(self.player, {align_self = "end", justify_self = "end", margin = {0, 64 + 20, 20, 0}})
	})
end

function Select:enter()
	self:attachObservers()
	love.mouse.setVisible(true)

	local config = self:getConfig()
	local bg = self:getContext().background
	bg:setDim(config.settings.graphics.dim.select)
	self.prevRate = self:getGame().timeRateModel:get()

	local cv = self.chart_selector.chartview

	if cv and cv.location_id then
		self:updateChartview(cv)
	end
end

function Select:exit()
	self:detachObservers()
end

function Select:update(dt)
	self.chart_preview_view:update(dt)
end

function Select:draw()
	self.chart_preview_view:draw()
end

function Select:onKeyDown(e)
	local k = e.key
	local modals = self:getContext().modals
	local game = self:getGame()

	if k == "j" then
		self.chart_selector:scrollLevel(1, 1)
		return true
	elseif k == "k" then
		self.chart_selector:scrollLevel(1, -1)
		return true
	elseif k == "h" then
		self.chart_selector:scrollLevel(2, -1)
		return true
	elseif k == "l" then
		self.chart_selector:scrollLevel(2, 1)
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
		return true
	elseif k == "]" then
		game.timeRateModel:increase(1)
		game.modifierSelectModel:change()
		return true
	elseif k == "return" then
		self.parent:set("gameplay")
		return true
	end
end

---@param chartview rizu.library.LocatedChartview
function Select:updateChartview(chartview)
	self.tags:setChartview(chartview)
	self.artist_title:setChartview(chartview)
	self.chart_info:setChartview(chartview)
end

function Select:attachObservers()
	if self.observersAttached then
		return
	end

	self.chartviewObserver = self.chartviewObserver or {
		receive = function(_, event)
			if event.type == "chartview" then
				local cv = event.chartview ---@type rizu.library.LocatedChartview
				if cv.location_id then
					self:updateChartview(cv)
				end
			end
		end
	}

	self.chart_selector.onChanged:add(self.chartviewObserver)
	self.observersAttached = true
end

function Select:detachObservers()
	if not self.observersAttached then
		return
	end

	self.chart_selector.onChanged:remove(self.chartviewObserver)
	self.observersAttached = false
end

function Select:receive(event)
	self.chart_preview_view:receive(event)
end

return Select
