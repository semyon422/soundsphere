local Class = require("aqua.util.Class")

local TimeController = Class:new()

TimeController.receive = function(self, event)
	local configModel = self.configModel
	local rhythmModel = self.rhythmModel

	local timeEngine = rhythmModel.timeEngine
	local graphicEngine = rhythmModel.graphicEngine
	local noteSkin = graphicEngine.noteSkin

	if event.name == "keypressed" then
		local key = event.args[1]
		local delta = 0.05

		if key == configModel:get("gameplay.decreaseTimeRate") then
			timeEngine:increaseTimeRate(-0.05)
		elseif key == configModel:get("gameplay.increaseTimeRate") then
			timeEngine:increaseTimeRate(0.05)
		elseif key == configModel:get("gameplay.invertTimeRate") then
			timeEngine:setTimeRate(-timeEngine.timeRate)
		elseif key == configModel:get("gameplay.skipIntro") then
			timeEngine:skipIntro()
		elseif key == configModel:get("gameplay.invertPlaySpeed") then
			noteSkin.targetVisualTimeRate = -noteSkin.targetVisualTimeRate
			noteSkin:setVisualTimeRate(noteSkin.targetVisualTimeRate)
		elseif key == configModel:get("gameplay.decreasePlaySpeed") then
			if math.abs(noteSkin.targetVisualTimeRate - delta) > 0.001 then
				noteSkin.targetVisualTimeRate = noteSkin.targetVisualTimeRate - delta
				noteSkin:setVisualTimeRate(noteSkin.targetVisualTimeRate)
			else
				noteSkin.targetVisualTimeRate = 0
				noteSkin:setVisualTimeRate(noteSkin.targetVisualTimeRate)
			end
			configModel:set("speed", noteSkin.targetVisualTimeRate)
		elseif key == configModel:get("gameplay.increasePlaySpeed") then
			if math.abs(noteSkin.targetVisualTimeRate + delta) > 0.001 then
				noteSkin.targetVisualTimeRate = noteSkin.targetVisualTimeRate + delta
				noteSkin:setVisualTimeRate(noteSkin.targetVisualTimeRate)
			else
				noteSkin.targetVisualTimeRate = 0
				noteSkin:setVisualTimeRate(noteSkin.targetVisualTimeRate)
			end
			configModel:set("speed", noteSkin.targetVisualTimeRate)
		end
	end
end

return TimeController
