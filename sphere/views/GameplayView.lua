local Class = require("aqua.util.Class")
local Container = require("aqua.graphics.Container")
local RhythmView = require("sphere.views.RhythmView")
local NoteSkinView = require("sphere.views.NoteSkinView")
local GUI = require("sphere.ui.GUI")

local GameplayView = Class:new()

GameplayView.load = function(self)
	local rhythmModel = self.rhythmModel

	self.container = Container:new()

	local noteSkinView = NoteSkinView:new()
	noteSkinView.noteSkinData = rhythmModel.graphicEngine.noteSkin.noteSkinData
	noteSkinView.metaData = rhythmModel.graphicEngine.noteSkin.metaData
	noteSkinView.env = rhythmModel.graphicEngine.noteSkin.env
	noteSkinView:load()
	self.noteSkinView = noteSkinView

	local rhythmView = RhythmView:new()
	rhythmView.noteSkinView = noteSkinView
	rhythmView.container = self.container
	rhythmView:load()
	self.rhythmView = rhythmView

	local gui = GUI:new()
	self.gui = gui
	gui.container = self.container
	gui.root = rhythmModel.noteSkinMetaData.directoryPath
	gui.scoreSystem = rhythmModel.scoreEngine.scoreSystem
	gui.noteChart = rhythmModel.noteChart
	gui:loadTable(rhythmModel.graphicEngine.noteSkin.playField)
end

GameplayView.unload = function(self)
	self.rhythmView:unload()
	self.noteSkinView:unload()
end

GameplayView.receive = function(self, event)
	self.noteSkinView:receive(event)
	self.rhythmView:receive(event)
	self.gui:receive(event)
end

GameplayView.update = function(self, dt)
	self.container:update()
	self.noteSkinView:update(dt)
	self.rhythmView:update(dt)
	self.gui:update()
end

GameplayView.draw = function(self)
	self.container:draw()
end

return GameplayView
