local just = require("just")
local ScreenView = require("sphere.views.ScreenView")

local Layout = require("sphere.views.SelectView.Layout")
local SelectViewConfig = require("sphere.views.SelectView.SelectViewConfig")
local NotechartsSubscreen = require("sphere.views.SelectView.NotechartsSubscreen")
local CollectionsSubscreen = require("sphere.views.SelectView.CollectionsSubscreen")
local OsudirectSubscreen = require("sphere.views.SelectView.OsudirectSubscreen")

---@class sphere.SelectView: sphere.ScreenView
---@operator call: sphere.SelectView
local SelectView = ScreenView + {}

SelectView.subscreen = "notecharts"
SelectView.searchMode = "filter"

function SelectView:load()
	self.game.selectController:load()
end

function SelectView:beginUnload()
	self.game.selectController:beginUnload()
end

function SelectView:unload()
	self.game.selectController:unload()
end

---@param dt number
function SelectView:update(dt)
	self.game.selectController:update()
end

---@param event table
function SelectView:receive(event)
	self.game.selectController:receive(event)
end

function SelectView:draw()
	just.container("select container", true)

	Layout:draw()
	SelectViewConfig(self)

	local kp = just.keypressed
	if kp("f1") then self.gameView:setModal(require("sphere.views.ModifierView"))
	elseif kp("f2") then self.game.selectModel:scrollRandom()
	elseif kp("lctrl") then self:changeSearchMode()
	end
	if self.subscreen == "notecharts" then
		if kp("return") then self:play()
		elseif kp("tab") then self:switchToCollections()
		end
		NotechartsSubscreen(self)
	elseif self.subscreen == "collections" then
		if kp("return") or kp("tab") then self:switchToNoteCharts()
		end
		CollectionsSubscreen(self)
	elseif self.subscreen == "osudirect" then
		if kp("escape") or kp("tab") then self:switchToCollections()
		end
		OsudirectSubscreen(self)
	end

	just.container()
end

function SelectView:play()
	if not self.game.selectModel:notechartExists() then
		return
	end

	local multiplayerModel = self.game.multiplayerModel
	if multiplayerModel.room and not multiplayerModel.isPlaying then
		multiplayerModel:pushNotechart()
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
