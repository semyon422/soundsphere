local Class = require("aqua.util.Class")

local TimeController = Class:new()

TimeController.receive = function(self, event)
	local configModel = self.configModel
	local rhythmModel = self.rhythmModel

	local timeEngine = rhythmModel.timeEngine

	if event.name == "keypressed" then
		local key = event.args[1]

		if key == configModel:get("gameplay.decreaseTimeRate") then
			timeEngine:increaseTimeRate(-0.05)
		elseif key == configModel:get("gameplay.increaseTimeRate") then
			timeEngine:increaseTimeRate(0.05)
		elseif key == configModel:get("gameplay.invertTimeRate") then
			timeEngine:setTimeRate(-timeEngine.timeRate)
		elseif key == configModel:get("gameplay.skipIntro") then
			timeEngine:skipIntro()
		end
	end
end

return TimeController
