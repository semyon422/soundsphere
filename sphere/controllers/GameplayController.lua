local Class = require("aqua.util.Class")

local GameplayController = Class:new()

GameplayController.receive = function(self, event)
	if event.name == "keypressed" then
		if event.args[1] == "1" then
			self:pause()
		elseif event.args[1] == "2" then
			self:play()
		end
	end
end

GameplayController.pause = function(self)
	self.rhythmModel.timeEngine:setTimeRate(0)
end

GameplayController.play = function(self)
	self.rhythmModel.timeEngine:setTimeRate(self.rhythmModel.timeEngine:getBaseTimeRate())
end

return GameplayController
