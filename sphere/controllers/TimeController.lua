local Class = require("aqua.util.Class")

local TimeController = Class:new()

TimeController.receive = function(self, event)
	local configModel = self.configModel
	local rhythmModel = self.rhythmModel
	local notificationModel = self.notificationModel

	local timeEngine = rhythmModel.timeEngine
	local graphicEngine = rhythmModel.graphicEngine

	local config = configModel:getConfig("settings")
	local input = config.input
	local gameplay = config.general

	if event.name == "keypressed" then
		local key = event.args[1]
		local delta = 0.05

		if key == input.timeRate.decrease then
			timeEngine:increaseTimeRate(-delta)
			notificationModel:notify("timeRate: " .. timeEngine.timeRate)
			rhythmModel.prohibitSavingScore = true
		elseif key == input.timeRate.increase then
			timeEngine:increaseTimeRate(delta)
			notificationModel:notify("timeRate: " .. timeEngine.timeRate)
			rhythmModel.prohibitSavingScore = true
		elseif key == input.timeRate.invert then
			timeEngine:setTimeRate(-timeEngine.timeRate)
			notificationModel:notify("timeRate: " .. timeEngine.timeRate)
			rhythmModel.prohibitSavingScore = true
		elseif key == input.skipIntro then
			timeEngine:skipIntro()
		elseif key == input.playSpeed.invert then
			graphicEngine.targetVisualTimeRate = -graphicEngine.targetVisualTimeRate
			graphicEngine:setVisualTimeRate(graphicEngine.targetVisualTimeRate)
			notificationModel:notify("visualTimeRate: " .. graphicEngine.targetVisualTimeRate)
		elseif key == input.playSpeed.decrease then
			graphicEngine:increaseVisualTimeRate(-delta)
			gameplay.speed = graphicEngine.targetVisualTimeRate
			notificationModel:notify("visualTimeRate: " .. graphicEngine.targetVisualTimeRate)
		elseif key == input.playSpeed.increase then
			graphicEngine:increaseVisualTimeRate(delta)
			gameplay.speed = graphicEngine.targetVisualTimeRate
			notificationModel:notify("visualTimeRate: " .. graphicEngine.targetVisualTimeRate)
		end
	end
end

return TimeController
