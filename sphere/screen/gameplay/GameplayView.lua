local Class = require("aqua.util.Class")
local RhythmView = require("sphere.views.RhythmView")

local GameplayView = Class:new()

GameplayView.load = function(self)
	local rhythmView = RhythmView:new()
	rhythmView.rhythmModel = self.rhythmModel
	rhythmView:load()
	self.rhythmView = rhythmView
end

GameplayView.unload = function(self)
	self.rhythmView:unload()
end

GameplayView.receive = function(self, event)
	self.rhythmView:receive(event)
end

GameplayView.update = function(self, dt)
	self.rhythmView:update(dt)
end

GameplayView.draw = function(self)
	self.rhythmView:draw()
end

return GameplayView
