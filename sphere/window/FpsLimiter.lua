local aquaevent = require("aqua.event")

local FpsLimiter = {}

FpsLimiter.receive = function(self, event)
	if event.name == "ConfigModel.set" and event.key == "fps" then
		aquaevent.fpslimit = event.value
	end
end

return FpsLimiter
