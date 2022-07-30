local Class = require("aqua.util.Class")
local SequenceView = require("sphere.views.SequenceView")

local ModifierViewConfig = require("sphere.views.ModifierView.ModifierViewConfig")

local ModifierView = Class:new()

ModifierView.construct = function(self)
	self.sequenceView = SequenceView:new()
	self.viewConfig = ModifierViewConfig

	self.isOpen = false
end

ModifierView.toggle = function(self, state)
	if state == nil then
		self.isOpen = not self.isOpen
	else
		self.isOpen = state
	end
	if self.isOpen then
		self.game.multiplayerModel:pushModifiers()
		self.game.selectController:applyTimeRate()
	end
end

ModifierView.draw = function(self)
	if not self.isOpen then
		return
	end

	self.sequenceView:draw()
end

ModifierView.load = function(self)
	local sequenceView = self.sequenceView

	sequenceView.game = self.game
	sequenceView.screenView = self.screenView
	sequenceView:setSequenceConfig(self.viewConfig)
	sequenceView:load()
end

ModifierView.unload = function(self)
	self.sequenceView:unload()
end

ModifierView.receive = function(self, event)
	self.sequenceView:receive(event)
end

ModifierView.update = function(self, dt)
	self.sequenceView:update(dt)
end

return ModifierView
