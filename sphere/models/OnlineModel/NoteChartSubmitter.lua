local ThreadPool	= require("aqua.thread.ThreadPool")
local Observable	= require("aqua.util.Observable")
local Class			= require("aqua.util.Class")
local inspect = require("inspect")

local NoteChartSubmitter = Class:new()

NoteChartSubmitter.submitNoteChart = function(self, noteChartEntry, url)
    print("submit notechart", noteChartEntry.path)
	local api = self.webApi.api
	local host = self.config.host

	thread.call(function()
		local file = love.filesystem.newFile(noteChartEntry.path, "r")
		local content = file:read()
		print("POST " .. host .. "/" .. url)
		local response = api[url]:_post({}, {notechart = content})
		print(inspect(response))
	end)
end

return NoteChartSubmitter
