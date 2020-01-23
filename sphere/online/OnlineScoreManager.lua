local json			= require("json")
local http			= require("aqua.http")
local Observable	= require("aqua.util.Observable")
local OnlineClient	= require("sphere.online.OnlineClient")
local ThreadPool	= require("aqua.thread.ThreadPool")

local OnlineScoreManager = {}

OnlineScoreManager.init = function(self)
	self.observable = Observable:new()

	ThreadPool.observable:add(self)
end

OnlineScoreManager.receive = function(self, event)
	if event.name == "ScoreSubmit" then
		print(event.body)
	end
end

OnlineScoreManager.submit = function(self, playCase)
	return ThreadPool:execute(
		[[
			local http = require("aqua.http")

			local data = {...}

			local status, body = http.post("http://s.touhou.one:8080/score/add", {
				userId			= data[1],
				sessionId		= data[2],
				noteChartHash	= data[3],
				score			= data[4],
				accuracy		= data[5],
				mods			= data[6],
				maxCombo		= data[7],
				time			= data[8]
			})

			thread:push({
				name = "ScoreSubmit",
				status = status,
				body = body
			})
		]],
		{
			OnlineClient:getUserId(),
			OnlineClient:getSessionId(),
			playCase.noteChartHash,
			playCase.score,
			playCase.accuracy,
			playCase.mods,
			playCase.maxCombo,
			playCase.time
		}
	)
end

return OnlineScoreManager
