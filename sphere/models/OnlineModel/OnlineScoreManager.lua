local thread	= require("aqua.thread")
local Class			= require("aqua.util.Class")
local inspect = require("inspect")

local OnlineScoreManager = Class:new()

OnlineScoreManager.submit = thread.coro(function(self, noteChartEntry, noteChartDataEntry, replayHash)
	local api = self.webApi.api
	local host = self.config.host

	print("POST " .. host .. "/scores")
	local response = api.scores:_post({
		notechart_filename = noteChartEntry.path:match("^.+/(.-)$"),
		notechart_filesize = 0,
		notechart_hash = noteChartDataEntry.hash,
		notechart_index = noteChartDataEntry.index,
		replay_hash = replayHash,
		replay_size = 0,
	})
	print(inspect(response))

	-- local noteChartUploadUrl = response.notechart
	-- local replayUploadUrl = response.replay
	-- if noteChartUploadUrl and noteChartEntry.hash == response.notechart_hash then
	-- 	self:submitNoteChart(noteChartEntry, noteChartUploadUrl)
	-- end
	-- if replayUploadUrl then
	-- 	self:submitReplay(response.replay_hash, replayUploadUrl)
	-- end
end)

OnlineScoreManager.submitNoteChart = thread.coro(function(self, noteChartEntry, url)
    print("submit notechart", noteChartEntry.path)
	local api = self.webApi.api
	local host = self.config.host

    local file = love.filesystem.newFile(noteChartEntry.path, "r")
    local content = file:read()
    print("POST " .. host .. "/" .. url)
    local response = api[url]:_post({}, {notechart = content})
    print(inspect(response))
end)

OnlineScoreManager.submitReplay = thread.coro(function(self, replayHash, url)
	print("submit replay", replayHash)
	local api = self.webApi.api
	local host = self.config.host

	local file = love.filesystem.newFile("userdata/replays/" .. replayHash, "r")
	local content = file:read()
	print("POST " .. host .. "/" .. url)
	local response = api[url]:_post({}, {replay = content})
	print(inspect(response))
end)

return OnlineScoreManager
