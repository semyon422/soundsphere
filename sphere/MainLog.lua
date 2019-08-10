local Log = require("aqua.util.Log")
local ThreadPool = require("aqua.thread.ThreadPool")

local MainLog = Log:new()

MainLog.console = true
MainLog.path = "userdata/main.log"

MainLog.receive = function(self, event)
	if event.name == "threadError" then
		self:write("error", event.error)
	end
end

ThreadPool.observable:add(MainLog)

return MainLog
