local Class = require("aqua.util.Class")

local TimeController = Class:new()

TimeController.receive = function(self, event)
	local configModel = self.configModel
	local rhythmModel = self.rhythmModel
	local notificationModel = self.notificationModel

	local timeEngine = rhythmModel.timeEngine
	local graphicEngine = rhythmModel.graphicEngine
	local noteSkin = graphicEngine.noteSkin

	local config = configModel:getConfig("settings")

	if event.name == "keypressed" then
		local key = event.args[1]
		local delta = 0.05

		if key == config.general.decreaseTimeRate then
			timeEngine:increaseTimeRate(-delta)
			notificationModel:notify("timeRate: " .. timeEngine.timeRate)
			rhythmModel.prohibitSavingScore = true
		elseif key == config.general.increaseTimeRate then
			timeEngine:increaseTimeRate(delta)
			notificationModel:notify("timeRate: " .. timeEngine.timeRate)
			rhythmModel.prohibitSavingScore = true
		elseif key == config.general.invertTimeRate then
			timeEngine:setTimeRate(-timeEngine.timeRate)
			notificationModel:notify("timeRate: " .. timeEngine.timeRate)
			rhythmModel.prohibitSavingScore = true
		elseif key == config.general.skipIntro then
			timeEngine:skipIntro()
		elseif key == config.general.invertPlaySpeed then
			noteSkin.targetVisualTimeRate = -noteSkin.targetVisualTimeRate
			noteSkin:setVisualTimeRate(noteSkin.targetVisualTimeRate)
			notificationModel:notify("visualTimeRate: " .. noteSkin.targetVisualTimeRate)
		elseif key == config.general.decreasePlaySpeed then
			noteSkin:increaseVisualTimeRate(-delta)
			config.general.speed = noteSkin.targetVisualTimeRate
			notificationModel:notify("visualTimeRate: " .. noteSkin.targetVisualTimeRate)
		elseif key == config.general.increasePlaySpeed then
			noteSkin:increaseVisualTimeRate(delta)
			config.general.speed = noteSkin.targetVisualTimeRate
			notificationModel:notify("visualTimeRate: " .. noteSkin.targetVisualTimeRate)
		end
	end
end

return TimeController
