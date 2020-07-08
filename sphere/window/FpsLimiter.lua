local aquaevent = require("aqua.event")

local FpsLimiter = {}

FpsLimiter.receive = function(self, event)
	if event.name == "Config.set" and event.key == "fps" then
		aquaevent.fpslimit = event.value
	end
end

return FpsLimiter
