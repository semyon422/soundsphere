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
	local general = config.general

	if event.name == "keypressed" then
		local key = event.args[1]
		local delta = 0.05

		if key == input.decreaseTimeRate then
			timeEngine:increaseTimeRate(-delta)
			notificationModel:notify("timeRate: " .. timeEngine.timeRate)
			rhythmModel.prohibitSavingScore = true
		elseif key == input.increaseTimeRate then
			timeEngine:increaseTimeRate(delta)
			notificationModel:notify("timeRate: " .. timeEngine.timeRate)
			rhythmModel.prohibitSavingScore = true
		elseif key == input.invertTimeRate then
			timeEngine:setTimeRate(-timeEngine.timeRate)
			notificationModel:notify("timeRate: " .. timeEngine.timeRate)
			rhythmModel.prohibitSavingScore = true
		elseif key == input.skipIntro then
			timeEngine:skipIntro()
		elseif key == input.invertPlaySpeed then
			graphicEngine.targetVisualTimeRate = -graphicEngine.targetVisualTimeRate
			graphicEngine:setVisualTimeRate(graphicEngine.targetVisualTimeRate)
			notificationModel:notify("visualTimeRate: " .. graphicEngine.targetVisualTimeRate)
		elseif key == input.decreasePlaySpeed then
			graphicEngine:increaseVisualTimeRate(-delta)
			general.speed = graphicEngine.targetVisualTimeRate
			notificationModel:notify("visualTimeRate: " .. graphicEngine.targetVisualTimeRate)
		elseif key == input.increasePlaySpeed then
			graphicEngine:increaseVisualTimeRate(delta)
			general.speed = graphicEngine.targetVisualTimeRate
			notificationModel:notify("visualTimeRate: " .. graphicEngine.targetVisualTimeRate)
		end
	end
end

return TimeController
