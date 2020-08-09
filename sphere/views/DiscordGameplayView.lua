local Class = require("aqua.util.Class")
local DiscordPresence = require("sphere.discord.DiscordPresence")

local DiscordGameplayView = Class:new()

DiscordGameplayView.receive = function(self, event)
	local rhythmModel = self.rhythmModel
	local noteChartModel = self.noteChartModel

	if event.name == "pause" then
		DiscordPresence:setPresence({
			state = "Playing (paused)",
			details = ("%s - %s [%s]"):format(
				noteChartModel.noteChartDataEntry.artist,
				noteChartModel.noteChartDataEntry.title,
				noteChartModel.noteChartDataEntry.name
			)
		})
	elseif event.name == "play" then
		local length = math.min(noteChartModel.noteChartDataEntry.length, 3600 * 24)
		DiscordPresence:setPresence({
			state = "Playing",
			details = ("%s - %s [%s]"):format(
				noteChartModel.noteChartDataEntry.artist,
				noteChartModel.noteChartDataEntry.title,
				noteChartModel.noteChartDataEntry.name
			),
			endTimestamp = math.floor(os.time() + (length - rhythmModel.timeEngine.currentTime) / rhythmModel.timeEngine:getBaseTimeRate())
		})
	elseif event.name == "quit" then
		DiscordPresence:setPresence({})
	end
end

return DiscordGameplayView
