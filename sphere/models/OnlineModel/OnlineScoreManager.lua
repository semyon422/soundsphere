local thread	= require("aqua.thread")
local Class			= require("aqua.util.Class")
local inspect = require("inspect")

local OnlineScoreManager = Class:new()

local async_read = thread.async(function(...) return love.filesystem.read(...) end)

OnlineScoreManager.submit = thread.coro(function(self, noteChartEntry, noteChartDataEntry, replayHash)
	local webApi = self.webApi
	local api = webApi.api

	print("POST " .. api.scores)
	local notechart_filename = noteChartEntry.path:match("^.+/(.-)$")
	local response, code, headers = api.scores:post({
		notechart_filename = notechart_filename,
		notechart_filesize = 0,
		notechart_hash = noteChartDataEntry.hash,
		notechart_index = noteChartDataEntry.index,
		replay_hash = replayHash,
		replay_size = 0,
	})
	if code ~= 201 then
		print(code)
		print(inspect(response))
		return
	end

	local score = webApi:newResource(headers.location):get({
		notechart = true,
		notechart_file = true,
		file = true,
	})
	if not score or not score.file or not score.notechart or not score.notechart.file then
		print("not score")
		return
	end

	local notechart = score.notechart
	if not notechart.is_complete then
		local file = notechart.file
		if not file.uploaded then
			local content = async_read(noteChartEntry.path)
			api.files[file.id]:put(nil, {
				file = {content, filename = notechart_filename},
			})
		end
		api.notecharts[notechart.id]:patch()
	end
	if not score.is_complete then
		local file = score.file
		if not file.uploaded then
			local content = async_read("userdata/replays/" .. replayHash)
			api.files[file.id]:put(nil, {
				file = {content, filename = replayHash},
			})
		end
		api.scores[score.id]:patch()
	end
	api.scores[score.id].leaderboards:put()

	score = api.scores[score.id]:get()
	print(inspect(score))
end)

return OnlineScoreManager
