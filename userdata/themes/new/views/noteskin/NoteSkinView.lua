local viewspackage = (...):match("^(.-%.views%.)")

local Class = require("aqua.util.Class")
local Node = require("aqua.util.Node")
local NoteSkinNavigator = require(viewspackage .. "noteskin.NoteSkinNavigator")
local NoteSkinListView = require(viewspackage .. "noteskin.NoteSkinListView")
local BackgroundView = require(viewspackage .. "BackgroundView")

local NoteSkinView = Class:new()

NoteSkinView.construct = function(self)
	self.node = Node:new()
end

NoteSkinView.load = function(self)
	local node = self.node
	local config = self.configModel:getConfig("noteskin")

	local navigator = NoteSkinNavigator:new()
	self.navigator = navigator
	navigator.config = config
	navigator.view = self

	local noteSkinListView = NoteSkinListView:new()
	noteSkinListView.navigator = navigator
	noteSkinListView.config = config
	noteSkinListView.view = self

	local backgroundView = BackgroundView:new()
	backgroundView.view = self

	node:node(backgroundView)
	node:node(noteSkinListView)

	navigator:load()
end

NoteSkinView.unload = function(self)
	self.navigator:unload()
end

NoteSkinView.receive = function(self, event)
	self.node:callnext(event.name, event)
	self.navigator:receive(event)
end

NoteSkinView.update = function(self, dt)
	self.node:callnext("update")
	self.navigator:update()
end

NoteSkinView.draw = function(self)
	self.node:callnext("draw")
end

return NoteSkinView
