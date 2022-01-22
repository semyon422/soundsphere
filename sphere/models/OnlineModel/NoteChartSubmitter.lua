local thread	= require("aqua.thread")
local Class			= require("aqua.util.Class")
local inspect = require("inspect")

local NoteChartSubmitter = Class:new()

NoteChartSubmitter.submitNoteChart = thread.coro(function(self, noteChartEntry, url)
    print("submit notechart", noteChartEntry.path)
	local api = self.webApi.api
	local host = self.config.host

    local file = love.filesystem.newFile(noteChartEntry.path, "r")
    local content = file:read()
    print("POST " .. host .. "/" .. url)
    local response = api[url]:_post({}, {notechart = content})
    print(inspect(response))
end)

return NoteChartSubmitter
