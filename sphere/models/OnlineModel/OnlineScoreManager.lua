local Observable	= require("aqua.util.Observable")
local Class			= require("aqua.util.Class")
local ThreadPool	= require("aqua.thread.ThreadPool")
local inspect = require("inspect")

local OnlineScoreManager = Class:new()

OnlineScoreManager.submit = function(self, noteChartEntry, noteChartDataEntry, replayHash)
	return ThreadPool:execute({
		f = function(params)
			local json = require("json")
			local http = require("aqua.http")
			local request = require("luajit-request")

			local response = request.send(params.host .. "/score", {
				method = "POST",
				data = {
					session = params.session,
					replay_hash = params.replayHash,
					notechart_hash = params.hash,
					notechart_index = tostring(params.index),
					notechart_filename = params.fileName
				}
			})
			return json.decode(response.body)
		end,
		params = {
			host = self.config.host,
			session = self.config.session,
			replayHash = replayHash,
			hash = noteChartDataEntry.hash,
			index = noteChartDataEntry.index,
			fileName = noteChartEntry.path:match("^.+/(.-)$")
		},
		result = function(response)
			print(inspect(response))
			local noteChartUploadUrl = response.notechart
			local replayUploadUrl = response.replay
			if noteChartUploadUrl and noteChartEntry.hash == response.notechart_hash then
				self.noteChartSubmitter:submitNoteChart(noteChartEntry, noteChartUploadUrl)
			end
			if replayUploadUrl then
				self.replaySubmitter:submitReplay(response.replay_hash, replayUploadUrl)
			end
		end,
		error = print
	})
end

return OnlineScoreManager
