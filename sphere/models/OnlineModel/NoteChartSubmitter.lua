local ThreadPool	= require("aqua.thread.ThreadPool")
local Observable	= require("aqua.util.Observable")
local Class			= require("aqua.util.Class")
local inspect = require("inspect")

local NoteChartSubmitter = Class:new()

NoteChartSubmitter.submitNoteChart = function(self, noteChartEntry, url)
    print("submit notechart", noteChartEntry.path)
	return ThreadPool:execute({
		f = function(params)
            local path = params.path

            local noteChartFile = love.filesystem.newFile(path, "r")
            local content = noteChartFile:read()
            local tempName = "nc" .. os.time()
            local tempFile, err = io.open(tempName, "wb")
            if not tempFile then
                print("Can't create temporary file " .. tempName)
                print(err)
            else
                print("Created temporary file " .. tempName)
            end
            tempFile:write(content)
            tempFile:close()

            local request = require("luajit-request")
			local json = require("json")

            print("POST " .. params.host .. "/" .. params.url)
            local response, err, message = request.send(params.host .. "/" .. params.url, {
                method = "POST",
                files = {
                    notechart = tempName
                }
            })
            os.remove(tempName)

			return json.decode(response.body)
		end,
        params = {
			host = self.config.host,
			url = url,
			path = noteChartEntry.path
        },
		result = function(response)
			print(inspect(response))
		end,
		error = print
	})
end

return NoteChartSubmitter
