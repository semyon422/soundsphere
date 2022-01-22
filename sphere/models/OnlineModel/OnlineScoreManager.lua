local thread	= require("aqua.thread")
local Class			= require("aqua.util.Class")
local inspect = require("inspect")

local OnlineScoreManager = Class:new()

OnlineScoreManager.submit = thread.coro(function(self, noteChartEntry, noteChartDataEntry, replayHash)
	local api = self.webApi.api
	local host = self.config.host

	print("POST " .. host .. "/score")
	local response = api.score:_post({
		session = self.config.session,
		replay_hash = replayHash,
		notechart_hash = noteChartDataEntry.hash,
		notechart_index = tostring(noteChartDataEntry.index),
		notechart_filename = noteChartEntry.path:match("^.+/(.-)$")
	})
	print(inspect(response))

	local noteChartUploadUrl = response.notechart
	local replayUploadUrl = response.replay
	if noteChartUploadUrl and noteChartEntry.hash == response.notechart_hash then
		self.noteChartSubmitter:submitNoteChart(noteChartEntry, noteChartUploadUrl)
	end
	if replayUploadUrl then
		self.replaySubmitter:submitReplay(response.replay_hash, replayUploadUrl)
	end
end)

return OnlineScoreManager
