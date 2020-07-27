local Class = require("aqua.util.Class")
local ScreenManager = require("sphere.screen.ScreenManager")

local ResultController = Class:new()

ResultController.receive = function(self, event)
	if event.name == "keypressed" and event.args[1] == "escape" then
		return ScreenManager:set(require("sphere.screen.SelectScreen"))
	end

	if event.name == "scoreSystem" then
		local scoreSystem = event.scoreSystem

		local gui = self.view.gui
		gui.scoreSystem = scoreSystem
		gui.noteChart = event.noteChart
		gui:load("userdata/interface/result.json")
		gui:receive({
			action = "updateMetaData",
			noteChartEntry = event.noteChartEntry,
			noteChartDataEntry = event.noteChartDataEntry
		})

		-- if scoreSystem.scoreTable.score > 0 and ReplayManager.mode ~= "replay" and not event.autoplay then
		-- 	local modifierSequence = ModifierManager:getSequence()
		-- 	local replayHash = ReplayManager:saveReplay(event.noteChartDataEntry, modifierSequence)
		-- 	ScoreManager:insertScore(scoreSystem.scoreTable, event.noteChartDataEntry, replayHash, modifierSequence)
		-- end
		gui:load("userdata/interface/result.json")
	end
end

return ResultController
