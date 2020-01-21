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
			local http			= require("aqua.http")
			local OnlineClient	= require("sphere.online.OnlineClient")

			OnlineClient:init()
			OnlineClient:load()

			local score = ...

			local status, body = http.post("http://s.touhou.one:8080/score/add", {
				userId = OnlineClient:getUserId(),
				sessionId = OnlineClient:getSessionId(),
				score = score
			})

			thread:push({
				name = "ScoreSubmit",
				status = status,
				body = body
			})
		]],
		{playCase.score}
	)
end

return OnlineScoreManager
