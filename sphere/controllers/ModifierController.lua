local Class = require("aqua.util.Class")

local ModifierController = Class:new()

ModifierController.load = function(self)
	self.game.noteChartModel:load()
end

ModifierController.unload = function(self)
	self.game.multiplayerModel:pushModifiers()
end

return ModifierController
