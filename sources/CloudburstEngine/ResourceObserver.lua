CloudburstEngine.ResourceObserver = createClass()
local ResourceObserver = CloudburstEngine.ResourceObserver

ResourceObserver.receiveEvent = function(self, event)
	if event.type == "Group" and event.name == "engine" then
		print(event.value)
	end
	if event.type == "Group" and event.name == "engine" and event.value == 0 then
		self.engine.timeManager:play()
	end
end