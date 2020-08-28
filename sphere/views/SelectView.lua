local Class = require("aqua.util.Class")
local Container = require("aqua.graphics.Container")
local AliasManager		= require("sphere.database.AliasManager")

local ModifierMenu		= require("sphere.ui.ModifierMenu")
local NoteSkinMenu		= require("sphere.ui.NoteSkinMenu")
local KeyBindMenu		= require("sphere.ui.KeyBindMenu")
local NoteChartMenu		= require("sphere.ui.NoteChartMenu")

local ScoreList			= require("sphere.ui.ScoreList")
local NoteChartList		= require("sphere.ui.NoteChartList")
local NoteChartSetList	= require("sphere.ui.NoteChartSetList")
local PreviewManager	= require("sphere.ui.PreviewManager")

local BackgroundManager	= require("sphere.ui.BackgroundManager")

local NoteChartStateManager	= require("sphere.ui.NoteChartStateManager")
local GUI = require("sphere.ui.GUI")

local SelectView = Class:new()

SelectView.construct = function(self)
    self.container = Container:new()
	self.gui = GUI:new()
end

SelectView.load = function(self)
    local container = self.container
	local gui = self.gui
	local noteChartModel = self.noteChartModel
	local configModel = self.configModel

	PreviewManager.configModel = configModel
	configModel.observable:add(PreviewManager)

	gui.container = container
	gui.modifierModel = self.modifierModel
	gui.noteChartModel = self.noteChartModel
	gui.cacheModel = self.cacheModel

	NoteChartStateManager.observable:add(gui)
	NoteChartStateManager.observable:add(self.controller)
	NoteChartStateManager.noteChartModel = noteChartModel
	NoteChartStateManager.configModel = configModel

	gui:load("userdata/interface/select.json")
	gui.observable:add(self)
	gui:reload()

	KeyBindMenu.noteChartModel = noteChartModel
	NoteSkinMenu.noteChartModel = noteChartModel

	NoteSkinMenu.noteSkinModel = self.noteSkinModel
	NoteSkinMenu.observable:add(self.controller)
	KeyBindMenu.observable:add(self.controller)
	ModifierMenu.observable:add(self.controller)

	KeyBindMenu.inputModel = self.inputModel

	KeyBindMenu.modifierModel = self.modifierModel
	NoteSkinMenu.modifierModel = self.modifierModel
	ModifierMenu.modifierModel = self.modifierModel
	ModifierMenu.modifierModel = self.modifierModel

	AliasManager:load()
	ModifierMenu:reloadItems()

	NoteChartList.cacheModel = self.cacheModel
	NoteChartSetList.cacheModel = self.cacheModel
	NoteChartStateManager.cacheModel = self.cacheModel
	NoteChartMenu.cacheModel = self.cacheModel
	NoteChartMenu.mountModel = self.mountModel

	ScoreList:load()
	NoteChartList:load()
	NoteChartSetList:load()

	NoteChartStateManager:load()

	NoteChartSetList:sendState()

	local dim = 255 * (1 - (configModel:get("dim.select") or 0))
	BackgroundManager:setColor({dim, dim, dim})
end

SelectView.unload = function(self)
	self.configModel.observable:remove(PreviewManager)
	NoteChartStateManager.observable:remove(self.gui)
	NoteChartStateManager.observable:remove(self.controller)
	self.gui.observable:remove(self)
	NoteSkinMenu.observable:remove(self.controller)
	KeyBindMenu.observable:remove(self.controller)
	ModifierMenu.observable:remove(self.controller)

	self.gui:unload()
	PreviewManager:stop()
	NoteChartStateManager:unload()
end

SelectView.receive = function(self, event)
	local modifierMenuHidden = ModifierMenu.hidden
	local noteSkinMenuHidden = NoteSkinMenu.hidden
	local keyBindMenuMenuHidden = KeyBindMenu.hidden
	local noteChartMenuMenuHidden = NoteChartMenu.hidden
	ModifierMenu:receive(event)
	NoteSkinMenu:receive(event)
	KeyBindMenu:receive(event)
	NoteChartMenu:receive(event)
	if (
		not modifierMenuHidden or
		not noteSkinMenuHidden or
		not keyBindMenuMenuHidden or
		not noteChartMenuMenuHidden
		) and event.name ~= "resize" then
		return
	end

	if event.name == "resize" then
		NoteChartSetList:reload()
		NoteChartList:reload()
		ScoreList:reload()
		self.gui:reload()
		return
	elseif event.backgroundPath then
		return BackgroundManager:loadDrawableBackground(event.backgroundPath)
	elseif event.name == "keypressed" then
		local key = event.args[1]
		if key == (self.configModel:get("screen.browser") or "tab") then
			return self.controller:receive({
				name = "setScreen",
				screenName = "BrowserScreen"
			})
		elseif key == (self.configModel:get("screen.settings") or "f1") then
			return self.controller:receive({
				name = "setScreen",
				screenName = "SettingsScreen"
			})
		end
	end

	NoteChartSetList:receive(event)
	NoteChartList:receive(event)
	ScoreList:receive(event)
	self.gui:receive(event)
	NoteChartStateManager:receive(event)
end

SelectView.update = function(self, dt)
    self.container:update()

	ScoreList:update()
	NoteChartSetList:update()
	NoteChartList:update()
	PreviewManager:update()

	ModifierMenu:update()
	NoteSkinMenu:update()
	KeyBindMenu:update()
	NoteChartMenu:update()

	self.gui:update()
end

SelectView.draw = function(self)
	NoteChartSetList:draw()
	NoteChartList:draw()
	ScoreList:draw()

	self.container:draw()

	ModifierMenu:draw()
	NoteSkinMenu:draw()
	KeyBindMenu:draw()
	NoteChartMenu:draw()
end

return SelectView
