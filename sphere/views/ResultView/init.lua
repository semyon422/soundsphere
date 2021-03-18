local viewspackage = (...):match("^(.-%.views%.)")

local Class = require("aqua.util.Class")
local Node = require("aqua.util.Node")
local ResultNavigator = require(viewspackage .. "ResultView.ResultNavigator")
local BackgroundView = require(viewspackage .. "BackgroundView")

local ResultView = Class:new()

ResultView.construct = function(self)
	self.node = Node:new()
end

ResultView.load = function(self)
	local node = self.node
	local config = self.configModel:getConfig("settings")

	local navigator = ResultNavigator:new()
	self.navigator = navigator
	navigator.config = config
	navigator.view = self

	local backgroundView = BackgroundView:new()
	backgroundView.view = self

	node:node(backgroundView)

	navigator:load()
end

ResultView.unload = function(self)
	self.navigator:unload()
end

ResultView.receive = function(self, event)
	self.node:callnext(event.name, event)
	self.navigator:receive(event)
end

ResultView.update = function(self, dt)
	self.node:callnext("update")
	self.navigator:update()
end

ResultView.draw = function(self)
	self.node:callnext("draw")
end

return ResultView
