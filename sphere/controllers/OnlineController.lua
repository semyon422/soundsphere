local Class = require("aqua.util.Class")

local OnlineController = Class:new()

OnlineController.receive = function(self, event)
	if event.name == "ScoreSubmitResponse" then
		print(event.response.message)
		local noteChartUploadUrl = event.response.notechart
		local replayUploadUrl = event.response.replay
		if noteChartUploadUrl then
			print("Server requested to upload the notchart")
			print("Uploading: " .. noteChartUploadUrl)
			self:submitNoteChart(event.response.notechart_hash, noteChartUploadUrl)
		end
		if replayUploadUrl then
			print("Server requested to upload the replay")
			print("Uploading: " .. replayUploadUrl)
			self:submitReplay(event.response.replay_hash, replayUploadUrl)
		end
	elseif event.name == "NoteChartSubmitResponse" then
		print(event.response.message)
		print("Server received the notechart")
	end
end

OnlineController.submitNoteChart = function(self, noteChartHash, url)
	local noteChartsAtHash = self.cacheModel.cacheManager:getNoteChartsAtHash(noteChartHash)
	if noteChartsAtHash then
		self.onlineModel:submitNoteChart(noteChartsAtHash[1], url)
	end
end

OnlineController.submitReplay = function(self, replayHash, url)
	self.onlineModel:submitReplay(replayHash, url)
end

return OnlineController
