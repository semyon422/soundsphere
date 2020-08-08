local Class = require("aqua.util.Class")
local Container = require("aqua.graphics.Container")
local RhythmView = require("sphere.views.RhythmView")
local NoteSkinView = require("sphere.views.NoteSkinView")
local GUI = require("sphere.ui.GUI")

local GameplayView = Class:new()

GameplayView.construct = function(self)
	self.container = Container:new()
	self.noteSkinView = NoteSkinView:new()
	self.rhythmView = RhythmView:new()
	self.gui = GUI:new()
end

GameplayView.load = function(self)
	local container = self.container
	local noteSkinView = self.noteSkinView
	local rhythmView = self.rhythmView
	local gui = self.gui

	noteSkinView.noteSkin = self.noteSkin
	noteSkinView:load()

	rhythmView.noteSkinView = noteSkinView
	rhythmView.container = container
	rhythmView:load()

	gui.container = container
	gui.root = self.noteSkin.directoryPath
	gui.scoreSystem = self.scoreSystem
	gui.noteChart = self.noteChart
	gui:loadTable(self.noteSkin.playField)
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
