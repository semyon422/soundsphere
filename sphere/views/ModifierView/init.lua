local viewspackage = (...):match("^(.-%.views%.)")

local Class = require("aqua.util.Class")

local SequenceView = require(viewspackage .. "SequenceView")
local ModifierViewConfig = require(viewspackage .. "ModifierView.ModifierViewConfig")
local ModifierNavigator = require(viewspackage .. "ModifierView.ModifierNavigator")
local AvailableModifierListView = require(viewspackage .. "ModifierView.AvailableModifierListView")
local ModifierListView = require(viewspackage .. "ModifierView.ModifierListView")
local BackgroundView = require(viewspackage .. "BackgroundView")

local ModifierView = Class:new()

ModifierView.construct = function(self)
	self.modifierViewConfig = ModifierViewConfig
	self.sequenceView = SequenceView:new()
	self.navigator = ModifierNavigator:new()
	self.availableModifierListView = AvailableModifierListView:new()
	self.modifierListView = ModifierListView:new()
	self.backgroundView = BackgroundView:new()
end

ModifierView.load = function(self)
	local navigator = self.navigator
	local availableModifierListView = self.availableModifierListView
	local modifierListView = self.modifierListView
	local backgroundView = self.backgroundView

	local config = self.configModel:getConfig("modifier")
	self.config = config

	navigator.config = config
	navigator.view = self
	navigator.modifierModel = self.modifierModel

	availableModifierListView.navigator = navigator
	availableModifierListView.config = config
	availableModifierListView.modifierModel = self.modifierModel
	availableModifierListView.view = self

	modifierListView.navigator = navigator
	modifierListView.config = config
	modifierListView.modifierModel = self.modifierModel
	modifierListView.view = self

	backgroundView.view = self
	backgroundView.backgroundModel = self.backgroundModel

	local sequenceView = self.sequenceView
	sequenceView:setSequenceConfig(self.modifierViewConfig)
	sequenceView:setView("AvailableModifierListView", availableModifierListView)
	sequenceView:setView("ModifierListView", modifierListView)
	sequenceView:setView("BackgroundView", backgroundView)
	sequenceView:load()

	navigator:load()
end

ModifierView.unload = function(self)
	self.navigator:unload()
	self.sequenceView:unload()
end

ModifierView.receive = function(self, event)
	self.navigator:receive(event)
	self.sequenceView:receive(event)
end

ModifierView.update = function(self, dt)
	self.navigator:update()
	self.sequenceView:update(dt)
end

ModifierView.draw = function(self)
	self.sequenceView:draw()
end

return ModifierView
