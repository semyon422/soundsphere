local viewspackage = (...):match("^(.-%.views%.)")

local Class = require("aqua.util.Class")
local Node = require("aqua.util.Node")
local InputNavigator = require(viewspackage .. "InputView.InputNavigator")
local InputListView = require(viewspackage .. "InputView.InputListView")
local BackgroundView = require(viewspackage .. "BackgroundView")

local InputView = Class:new()

InputView.construct = function(self)
	self.node = Node:new()
end

InputView.load = function(self)
	local node = self.node
	local config = self.configModel:getConfig("input")

	local navigator = InputNavigator:new()
	self.navigator = navigator
	navigator.config = config
	navigator.view = self

	local inputListView = InputListView:new()
	inputListView.navigator = navigator
	inputListView.config = config
	inputListView.view = self

	local backgroundView = BackgroundView:new()
	backgroundView.view = self

	node:node(backgroundView)
	node:node(inputListView)

	navigator:load()
end

InputView.unload = function(self)
	self.navigator:unload()
end

InputView.receive = function(self, event)
	self.node:callnext(event.name, event)
	self.navigator:receive(event)
end

InputView.update = function(self, dt)
	self.node:callnext("update")
	self.navigator:update()
end

InputView.draw = function(self)
	self.node:callnext("draw")
end

return InputView
