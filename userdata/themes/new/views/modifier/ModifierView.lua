local viewspackage = (...):match("^(.-%.views%.)")

local Class = require("aqua.util.Class")
local Node = require("aqua.util.Node")
local ModifierNavigator = require(viewspackage .. "modifier.ModifierNavigator")
local BackgroundView = require(viewspackage .. "BackgroundView")

local ModifierView = Class:new()

ModifierView.construct = function(self)
	self.node = Node:new()
	self.selectedNode = Node:new()
end

ModifierView.load = function(self)
	local node = self.node
	local config = self.configModel:getConfig("select")

	local modifierNavigator = ModifierNavigator:new()
	self.modifierNavigator = modifierNavigator
	modifierNavigator.config = config
	modifierNavigator.view = self

	local backgroundView = BackgroundView:new()
	backgroundView.view = self

	node:node(backgroundView)

	self.selectedNode = node

	modifierNavigator:load()
end

ModifierView.unload = function(self)
	self.modifierNavigator:unload()
end

ModifierView.receive = function(self, event)
	local selectedNode = self.selectedNode
	-- if event.name == "keypressed" and event.args[1] == "escape" then
	-- 	self.controller:receive({
	-- 		name = "setScreen",
	-- 		screenName = "SelectScreen"
	-- 	})
	-- end
	if event.name == "mousemoved" then
		self.node:callnext("mousemoved", event)
	end
	-- if event.name == "mousepressed" then
	-- 	selectedNode:call("mousepressed", event)
	-- end
	-- if event.name == "wheelmoved" then
	-- 	selectedNode:call("wheelmoved", event.args[2])
	-- end
	-- if event.name == "keypressed" then
	-- 	selectedNode:call("keypressed", event.args[1])
	-- end
	self.modifierNavigator:receive(event)
end

ModifierView.update = function(self, dt)
	self.node:callnext("update")
	self.modifierNavigator:update()
end

ModifierView.draw = function(self)
	self.node:callnext("draw")
end

return ModifierView
