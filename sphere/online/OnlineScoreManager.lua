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

OnlineScoreManager.convertToOnlineScore = function(self, score)
	return {
		hash = score.hash,
		time = os.time(),
		score = score.score,
		accuracy = score.accuracy,
		maxCombo = score.maxcombo,
		mods = "None"
	}
end

OnlineScoreManager.submit = function(self, score)
	local onlineScore = self:convertToOnlineScore(score)

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
					score			= tostring(data[4]),
					accuracy		= tostring(data[5]),
					mods			= tostring(data[6]),
					maxCombo		= tostring(data[7]),
					time			= tostring(data[8])
				}
			})

			thread:push({
				name = "ScoreSubmit",
				status = response.code == 200,
				body = response.body
			})
		]],
		{
			OnlineClient:getUserId(),
			OnlineClient:getSessionId(),
			onlineScore.hash,
			onlineScore.score,
			onlineScore.accuracy,
			onlineScore.mods,
			onlineScore.maxCombo,
			onlineScore.time
		}
	)
end

return OnlineScoreManager
