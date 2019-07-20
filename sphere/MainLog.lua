local Log = require("aqua.util.Log")

local MainLog = Log:new()

MainLog.console = true
MainLog.path = "userdata/main.log"

return MainLog
