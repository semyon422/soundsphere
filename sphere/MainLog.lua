local Log = require("Log")

local MainLog = Log:new()

MainLog.console = true
MainLog.path = "userdata/main.log"

MainLog.receive = function(self, event)
	if event.name == "threadError" then
		self:write("error", event.error)
	end
end

return MainLog
