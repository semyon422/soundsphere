local viewspackage = (...):match("^(.-%.views%.)")

local Class = require("aqua.util.Class")
local Node = require("aqua.util.Node")
local CollectionNavigator = require(viewspackage .. "CollectionView.CollectionNavigator")
local CollectionListView = require(viewspackage .. "CollectionView.CollectionListView")
local BackgroundView = require(viewspackage .. "BackgroundView")

local CollectionView = Class:new()

CollectionView.construct = function(self)
	self.node = Node:new()
end

CollectionView.load = function(self)
	local node = self.node
	local config = self.configModel:getConfig("select")

	local navigator = CollectionNavigator:new()
	self.navigator = navigator
	navigator.config = config
	navigator.view = self

	local inputListView = CollectionListView:new()
	inputListView.navigator = navigator
	inputListView.config = config
	inputListView.view = self

	local backgroundView = BackgroundView:new()
	backgroundView.view = self

	node:node(backgroundView)
	node:node(inputListView)

	navigator:load()
end

CollectionView.unload = function(self)
	self.navigator:unload()
end

CollectionView.receive = function(self, event)
	self.node:callnext(event.name, event)
	self.navigator:receive(event)
end

CollectionView.update = function(self, dt)
	self.node:callnext("update")
	self.navigator:update()
end

CollectionView.draw = function(self)
	self.node:callnext("draw")
end

return CollectionView
