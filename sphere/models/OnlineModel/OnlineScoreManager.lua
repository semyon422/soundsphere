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
	if event.name == "ScoreSubmit" then
		print(event.body)
	end
end

OnlineScoreManager.convertToOnlineScore = function(self, scoreTable, noteChartDataEntry, replayHash, modifierModel)
	return {
		hash = noteChartDataEntry.hash,
		index = noteChartDataEntry.index,
		time = os.time(),
		score = scoreTable.score,
		accuracy = scoreTable.accuracy,
		maxCombo = scoreTable.maxcombo,
		modifiers = modifierModel:getString(),
		replayHash = replayHash
	}
end

OnlineScoreManager.submit = function(self, scoreTable, noteChartDataEntry, replayHash, modifierModel)
	local onlineScore = self:convertToOnlineScore(scoreTable, noteChartDataEntry, replayHash, modifierModel)

	return ThreadPool:execute(
		[[
			local http = require("aqua.http")
			local request = require("luajit-request")

			local data = {...}
			for i, v in ipairs(data) do
				data[i] = tostring(v)
			end

			local response = request.send("https://soundsphere.xyz/score", {
				method = "POST",
				data = {
					userId			= tostring(data[1]),
					sessionId		= tostring(data[2]),
					hash			= tostring(data[3]),
					index			= tostring(data[4]),
					score			= tostring(data[5]),
					accuracy		= tostring(data[6]),
					maxCombo		= tostring(data[7]),
					replayHash		= tostring(data[8]),
					modifiers		= tostring(data[9]),
					time			= tostring(data[10])
				}
			})

			thread:push({
				name = "ScoreSubmit",
				status = response.code == 200,
				body = response.body
			})
		]],
		{
			self.onlineClient:getUserId(),
			self.onlineClient:getSessionId(),
			onlineScore.hash,
			onlineScore.index,
			onlineScore.score,
			onlineScore.accuracy,
			onlineScore.maxCombo,
			onlineScore.replayHash,
			onlineScore.modifiers,
			onlineScore.time
		}
	)
end

return OnlineScoreManager
