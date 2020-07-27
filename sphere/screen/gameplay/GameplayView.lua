local Class = require("aqua.util.Class")
local Container = require("aqua.graphics.Container")
local RhythmView = require("sphere.views.RhythmView")
local GameplayGUI = require("sphere.screen.gameplay.GameplayGUI")

local GameplayView = Class:new()

GameplayView.load = function(self)
	local rhythmView = RhythmView:new()
	rhythmView.rhythmModel = self.rhythmModel
	rhythmView:load()
	self.rhythmView = rhythmView

	self.container = Container:new()

	local gui = GameplayGUI:new()
	self.gui = gui
	gui.root = self.rhythmModel.noteSkinMetaData.directoryPath
	gui.jsonData = self.rhythmModel.graphicEngine.noteSkin.playField
	gui.noteSkin = self.rhythmModel.graphicEngine.noteSkin
	gui.container = self.container
	gui.logicEngine = self.rhythmModel.logicEngine
	gui.scoreSystem = self.rhythmModel.scoreEngine.scoreSystem
	gui.noteChart = self.rhythmModel.noteChart
	self.rhythmModel.timeEngine.observable:add(gui)
	self.rhythmModel.scoreEngine.observable:add(gui)
	gui:loadTable(self.rhythmModel.graphicEngine.noteSkin.playField)

	self.rhythmModel.logicEngine.observable:add(gui)
	self.rhythmModel.inputManager.observable:add(gui)
end

GameplayView.unload = function(self)
	self.rhythmView:unload()
end

GameplayView.receive = function(self, event)
	self.rhythmView:receive(event)
	self.gui:receive(event)
end

GameplayView.update = function(self, dt)
	self.rhythmView:update(dt)
	self.container:update()
	self.gui:update()
end

GameplayView.draw = function(self)
	self.rhythmView:draw()
	self.container:draw()
end

return GameplayView
