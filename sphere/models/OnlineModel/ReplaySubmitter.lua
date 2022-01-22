local thread	= require("aqua.thread")
local Class			= require("aqua.util.Class")
local inspect = require("inspect")

local ReplaySubmitter = Class:new()

ReplaySubmitter.submitReplay = thread.coro(function(self, replayHash, url)
	print("submit replay", replayHash)
	local api = self.webApi.api
	local host = self.config.host

	local file = love.filesystem.newFile("userdata/replays/" .. replayHash, "r")
	local content = file:read()
	print("POST " .. host .. "/" .. url)
	local response = api[url]:_post({}, {replay = content})
	print(inspect(response))
end)

return ReplaySubmitter
