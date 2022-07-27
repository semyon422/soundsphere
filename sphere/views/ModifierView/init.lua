local Class = require("aqua.util.Class")
local SequenceView = require("sphere.views.SequenceView")

local ModifierViewConfig = require("sphere.views.ModifierView.ModifierViewConfig")

local ModifierView = Class:new()

ModifierView.construct = function(self)
	self.sequenceView = SequenceView:new()
	self.viewConfig = ModifierViewConfig
end

ModifierView.draw = function(self)
	if not self.isOpen[0] then
		return
	end

	self.sequenceView:draw()
end

ModifierView.load = function(self)
	local sequenceView = self.sequenceView

	sequenceView.game = self.game
	sequenceView.navigator = self.navigator
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
