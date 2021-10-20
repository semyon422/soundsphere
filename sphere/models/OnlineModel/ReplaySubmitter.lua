local ThreadPool	= require("aqua.thread.ThreadPool")
local Observable	= require("aqua.util.Observable")
local Class			= require("aqua.util.Class")
local inspect = require("inspect")

local ReplaySubmitter = Class:new()

ReplaySubmitter.submitReplay = function(self, replayHash, url)
    print("submit replay", replayHash)
	return ThreadPool:execute({
		f = function(params)
            local replayFile = love.filesystem.newFile("userdata/replays/" .. params.hash, "r")
            local content = replayFile:read()
            local tempName = "rp" .. os.time()
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
                    replay = tempName
                }
            })
            os.remove(tempName)

			return json.decode(response.body)
		end,
		params = {
			host = self.config.host,
			url = url,
			hash = replayHash
        },
		result = function(response)
			print(inspect(response))
		end,
		error = print
	})
end

return ReplaySubmitter
