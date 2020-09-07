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

OnlineScoreManager.submit = function(self, scoreTable, noteChartDataEntry, replayHash, modifierModel)
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
					userId = data.userId,
					sessionId = data.sessionId,
					hash = data.hash,
					index = data.index,
					score = data.score,
					accuracy = data.accuracy,
					maxCombo = data.maxCombo,
					replayHash = data.replayHash,
					modifiers = data.modifiers,
					time = data.time
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
				userId = self.userId,
				sessionId = self.sessionId,
				hash = noteChartDataEntry.hash,
				index = noteChartDataEntry.index,
				time = os.time(),
				score = scoreTable.score,
				accuracy = scoreTable.accuracy,
				maxCombo = scoreTable.maxcombo,
				modifiers = modifierModel:getString(),
				replayHash = replayHash
			}
		}
	)
end

return OnlineScoreManager
