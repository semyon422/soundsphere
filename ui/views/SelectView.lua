local just = require("just")
local ScreenView = require("ui.views.ScreenView")

local Layout = require("ui.views.SelectView.Layout")
local SelectViewConfig = require("ui.views.SelectView.SelectViewConfig")
local NotechartsSubscreen = require("ui.views.SelectView.NotechartsSubscreen")
local CollectionsSubscreen = require("ui.views.SelectView.CollectionsSubscreen")
local OsudirectSubscreen = require("ui.views.SelectView.OsudirectSubscreen")
local Background = require("ui.views.SelectView.Background")
local ChartPreviewView = require("sphere.views.SelectView.ChartPreviewView")

local ChartmetaKey = require("sea.chart.ChartmetaKey")

---@class ui.SelectView: ui.ScreenView
---@operator call: ui.SelectView
local SelectView = ScreenView + {}

SelectView.subscreen = "notecharts"
SelectView.searchMode = "filter"

function SelectView:load()
	self.game.selectController:load()
	self.chartPreviewView = ChartPreviewView(self.game, self.ui)
	self.chartPreviewView:load()
end

function SelectView:beginUnload()
	self.game.selectController:beginUnload()
end

function SelectView:unload()
	self.game.selectController:unload()
	self.chartPreviewView:unload()
end

---@param dt number
function SelectView:update(dt)
	self.game.selectController:update()
	self.chartPreviewView:update(dt)
end

---@param event table
function SelectView:receive(event)
	self.game.selectController:receive(event)
	self.chartPreviewView:receive(event)
end

function SelectView:draw()
	just.container("select container", true)

	Layout:draw()
	Background(self)
	self.chartPreviewView:draw()
	SelectViewConfig(self)

	local cacheModel = self.game.cacheModel

	local kp = just.keypressed
	if kp("f1") then self.gameView:setModal(require("ui.views.ModifierView.ModifierView"))
	elseif kp("f2") then self.game.selectModel:scrollRandom()
	elseif kp("lctrl") then self:changeSearchMode()
	end
	if self.subscreen == "notecharts" then
		if kp("return") then self:play()
		elseif kp("tab") then self:switchToCollections()
		end
		NotechartsSubscreen(self)
	elseif self.subscreen == "collections" then
		if kp("tab") then self:switchToNoteCharts()
		end
		CollectionsSubscreen(self)
	elseif self.subscreen == "osudirect" then
		if kp("escape") or kp("tab") then
			self:switchToCollections()
		end
		OsudirectSubscreen(self)
	end

	just.container()
end

function SelectView:play()
	local selectModel = self.game.selectModel
	if not selectModel:notechartExists() then
		return
	end

	local multiplayerModel = self.game.multiplayerModel
	if multiplayerModel.client:isInRoom() and not multiplayerModel.client.is_playing then
		local chartmeta_key = ChartmetaKey()
		chartmeta_key.hash = selectModel.chartview.hash
		chartmeta_key.index = selectModel.chartview.index

		multiplayerModel.client:updateChartmetaKey(chartmeta_key)
		self:changeScreen("multiplayerView")
		return
	end

	self:changeScreen("gameplayView")
end

function SelectView:result()
	if self.game.selectModel:isPlayed() then
		self:changeScreen("resultView")
	end
end

function SelectView:edit()
	if not self.game.selectModel:notechartExists() then
		return
	end
	self:changeScreen("editorView")
end

function SelectView:switchToNoteCharts()
	self.subscreen = "notecharts"
	self.searchMode = "filter"
	self.game.selectModel:noDebouncePullNoteChartSet()
	just.focus()
end

function SelectView:switchToCollections()
	self.subscreen = "collections"
	just.focus()
end

function SelectView:switchToOsudirect()
	self.searchMode = "osudirect"
	self.subscreen = "osudirect"
	self.game.osudirectModel:searchNoDebounce()
	just.focus()
end

---@param searchMode string
function SelectView:setSearchMode(searchMode)
	self.searchMode = searchMode
end

function SelectView:changeSearchMode()
	if self.searchMode == "filter" then
		self:setSearchMode("lamp")
	else
		self:setSearchMode("filter")
	end
end

return SelectView
