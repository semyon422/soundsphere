local Class = require("aqua.util.Class")

local OnlineController = Class:new()

OnlineController.receive = function(self, event)
	if event.name == "ScoreSubmitResponse" then
		print(event.response.message)
		if event.response.needNoteChartSubmit then
			print("Server requested to upload the notchart")
			print("Uploading...")
			self:submitNoteChart(event.response.score.noteChartHash)
		end
		if event.response.needReplaySubmit then
			print("Server requested to upload the replay")
			print("Uploading...")
			self:submitReplay(event.response.score.replayHash)
		end
	elseif event.name == "NoteChartSubmitResponse" then
		print(event.response.message)
		print("Server received the notechart")
	end
end

OnlineController.submitNoteChart = function(self, noteChartHash)
	local noteChartsAtHash = self.cacheModel.cacheManager:getNoteChartsAtHash(noteChartHash)
	if noteChartsAtHash then
		self.onlineModel:submitNoteChart(noteChartsAtHash[1])
	end
end

OnlineController.submitReplay = function(self, replayHash)
	self.onlineModel:submitReplay(replayHash)
end

return OnlineController
