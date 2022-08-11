local just = require("just")
local ScreenView = require("sphere.views.ScreenView")

local SelectViewConfig = require("sphere.views.SelectView.SelectViewConfig")
local SelectNavigator = require("sphere.views.SelectView.SelectNavigator")

local SelectView = ScreenView:new({construct = false})

SelectView.subscreen = "notecharts"
SelectView.searchMode = "filter"

SelectView.construct = function(self)
	ScreenView.construct(self)
	self.viewConfig = SelectViewConfig
	self.navigator = SelectNavigator:new()
end

SelectView.load = function(self)
	self.game.selectController:load()
	ScreenView.load(self)
end

SelectView.draw = function(self)
	ScreenView.draw(self)
end

SelectView.unload = function(self)
	self.game.selectController:unload()
	ScreenView.unload(self)
end

SelectView.update = function(self, dt)
	self.game.selectController:update(dt)

	ScreenView.update(self, dt)
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
