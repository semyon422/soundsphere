local Observable	= require("aqua.util.Observable")
local Class			= require("aqua.util.Class")
local ThreadPool	= require("aqua.thread.ThreadPool")

local OnlineScoreManager = Class:new()

OnlineScoreManager.construct = function(self)
	self.observable = Observable:new()
end

OnlineScoreManager.load = function(self)
	ThreadPool.observable:add(self)
end

OnlineScoreManager.unload = function(self)
	ThreadPool.observable:remove(self)
end

OnlineScoreManager.receive = function(self, event)
	if event.name == "ScoreSubmitResponse" then
		self.onlineModel:receive(event)
	end
end

OnlineScoreManager.submit = function(self, noteChartEntry, noteChartDataEntry, replayHash)
	return ThreadPool:execute(
		[[
			local http = require("aqua.http")
			local request = require("luajit-request")

			local data = ({...})[1]
			for k, v in pairs(data) do
				data[k] = tostring(v)
			end

			local response = request.send(data.host .. "/score", {
				method = "POST",
				data = {
					session = data.session,
					replay_hash = data.replayHash,
					notechart_hash = data.hash,
					notechart_index = data.index,
					notechart_filename = data.fileName
				}
			})

			thread:push({
				name = "ScoreSubmitResponse",
				status = response.code == 200,
				body = response.body
			})
		]],
		{
			{
				host = self.host,
				session = self.session,
				replayHash = replayHash,
				hash = noteChartDataEntry.hash,
				index = noteChartDataEntry.index,
				fileName = noteChartEntry.path:match("^.+/(.-)$")
			}
		}
	)
end

return OnlineScoreManager
