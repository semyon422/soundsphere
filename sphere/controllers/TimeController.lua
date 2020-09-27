local Class = require("aqua.util.Class")

local TimeController = Class:new()

TimeController.receive = function(self, event)
	local configModel = self.configModel
	local rhythmModel = self.rhythmModel
	local notificationModel = self.notificationModel

	local timeEngine = rhythmModel.timeEngine
	local graphicEngine = rhythmModel.graphicEngine
	local noteSkin = graphicEngine.noteSkin

	if event.name == "keypressed" then
		local key = event.args[1]
		local delta = 0.05

		if key == configModel:get("gameplay.decreaseTimeRate") then
			timeEngine:increaseTimeRate(-delta)
			notificationModel:notify("timeRate: " .. timeEngine.timeRate)
			rhythmModel.prohibitSavingScore = true
		elseif key == configModel:get("gameplay.increaseTimeRate") then
			timeEngine:increaseTimeRate(delta)
			notificationModel:notify("timeRate: " .. timeEngine.timeRate)
			rhythmModel.prohibitSavingScore = true
		elseif key == configModel:get("gameplay.invertTimeRate") then
			timeEngine:setTimeRate(-timeEngine.timeRate)
			notificationModel:notify("timeRate: " .. timeEngine.timeRate)
			rhythmModel.prohibitSavingScore = true
		elseif key == configModel:get("gameplay.skipIntro") then
			timeEngine:skipIntro()
		elseif key == configModel:get("gameplay.invertPlaySpeed") then
			noteSkin.targetVisualTimeRate = -noteSkin.targetVisualTimeRate
			noteSkin:setVisualTimeRate(noteSkin.targetVisualTimeRate)
			notificationModel:notify("visualTimeRate: " .. noteSkin.targetVisualTimeRate)
		elseif key == configModel:get("gameplay.decreasePlaySpeed") then
			noteSkin:increaseVisualTimeRate(-delta)
			configModel:set("speed", noteSkin.targetVisualTimeRate)
			notificationModel:notify("visualTimeRate: " .. noteSkin.targetVisualTimeRate)
		elseif key == configModel:get("gameplay.increasePlaySpeed") then
			noteSkin:increaseVisualTimeRate(delta)
			configModel:set("speed", noteSkin.targetVisualTimeRate)
			notificationModel:notify("visualTimeRate: " .. noteSkin.targetVisualTimeRate)
		end
	end
end

return TimeController
