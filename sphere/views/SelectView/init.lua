local just = require("just")
local ScreenView = require("sphere.views.ScreenView")

local Layout = require("sphere.views.SelectView.Layout")
local SelectViewConfig = require("sphere.views.SelectView.SelectViewConfig")
local NotechartsSubscreen = require("sphere.views.SelectView.NotechartsSubscreen")
local CollectionsSubscreen = require("sphere.views.SelectView.CollectionsSubscreen")
local OsudirectSubscreen = require("sphere.views.SelectView.OsudirectSubscreen")

local SelectView = ScreenView:new()

SelectView.subscreen = "notecharts"
SelectView.searchMode = "filter"

SelectView.load = function(self)
	self.game.selectController:load()
end

SelectView.draw = function(self)
	just.container("select container", true)

	Layout:draw()
	SelectViewConfig(self)

	local kp = just.keypressed
	if kp("f1") then self.gameView:setModal(require("sphere.views.ModifierView"))
	elseif kp("f2") then self.game.selectModel:scrollRandom()
	elseif kp("lctrl") then self:changeSearchMode()
	elseif kp("lshift") then self.game.selectModel:changeCollapse()
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

SelectView.unload = function(self)
	self.game.selectController:unload()
end

SelectView.update = function(self, dt)
	self.game.selectController:update(dt)
end

SelectView.play = function(self)
	if not self.game.selectModel:notechartExists() then
		return
	end

	local multiplayerModel = self.game.multiplayerModel
	if multiplayerModel.room and not multiplayerModel.isPlaying then
		multiplayerModel:pushNotechart()
		return self:changeScreen("multiplayerView")
	end

	self:changeScreen("gameplayView")
end

SelectView.result = function(self)
	if self.game.selectModel:isPlayed() then
		self:changeScreen("resultView")
	end
end

SelectView.switchToNoteCharts = function(self)
	self.subscreen = "notecharts"
	self.searchMode = "filter"
	self.game.selectModel:noDebouncePullNoteChartSet()
	just.focus()
end

SelectView.switchToCollections = function(self)
	self.subscreen = "collections"
	just.focus()
end

SelectView.switchToOsudirect = function(self)
	self.searchMode = "osudirect"
	self.subscreen = "osudirect"
	self.game.osudirectModel:searchNoDebounce()
	just.focus()
end

SelectView.setSearchMode = function(self, searchMode)
	self.searchMode = searchMode
end

SelectView.changeSearchMode = function(self)
	if self.searchMode == "filter" then
		self:setSearchMode("lamp")
	else
		self:setSearchMode("filter")
	end
end

return SelectView
