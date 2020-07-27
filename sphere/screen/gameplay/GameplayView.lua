local Class = require("aqua.util.Class")
local Container = require("aqua.graphics.Container")
local RhythmView = require("sphere.views.RhythmView")
local GameplayGUI = require("sphere.screen.gameplay.GameplayGUI")

local GameplayView = Class:new()

GameplayView.load = function(self)
	local rhythmModel = self.rhythmModel

	self.container = Container:new()

	local rhythmView = RhythmView:new()
	rhythmView.rhythmModel = rhythmModel
	rhythmView.container = self.container
	rhythmView:load()
	self.rhythmView = rhythmView

	local gui = GameplayGUI:new()
	self.gui = gui
	gui.container = self.container
	gui.root = rhythmModel.noteSkinMetaData.directoryPath
	gui.jsonData = rhythmModel.graphicEngine.noteSkin.playField
	gui.noteSkin = rhythmModel.graphicEngine.noteSkin
	gui.logicEngine = rhythmModel.logicEngine
	gui.scoreSystem = rhythmModel.scoreEngine.scoreSystem
	gui.noteChart = rhythmModel.noteChart
	gui:loadTable(rhythmModel.graphicEngine.noteSkin.playField)

	rhythmModel.timeEngine.observable:add(gui)
	rhythmModel.scoreEngine.observable:add(gui)
	rhythmModel.logicEngine.observable:add(gui)
	rhythmModel.inputManager.observable:add(gui)
end

GameplayView.unload = function(self)
	self.rhythmView:unload()

	local gui = self.gui
	local rhythmModel = self.rhythmModel
	rhythmModel.timeEngine.observable:add(gui)
	rhythmModel.scoreEngine.observable:add(gui)
	rhythmModel.logicEngine.observable:add(gui)
	rhythmModel.inputManager.observable:add(gui)
end

GameplayView.receive = function(self, event)
	self.rhythmView:receive(event)
	self.gui:receive(event)
end

GameplayView.update = function(self, dt)
	self.container:update()
	self.rhythmView:update(dt)
	self.gui:update()
end

GameplayView.draw = function(self)
	self.container:draw()
end

return GameplayView
