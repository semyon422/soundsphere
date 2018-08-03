ResourceLoader = createClass(soul.SoulObject)

ResourceLoader.load = function(self)
	self.resources = {}
	
	self.thread = soul.Thread:new()
	self.thread.threadName = "ResourceLoader"
	self.thread.messageReceived = function(thread, event)
		self.observable:sendEvent(event)
	end
	self.thread.threadFunction = io.open("sources/ResourceLoader/thread.lua", "r"):read("*a")
	self.thread:activate()
	
	self.observable = Observable:new()
end

ResourceLoader.getGlobal = function(self)
	if not ResourceLoader.global then
		ResourceLoader.global = ResourceLoader:new()
	end
	return ResourceLoader.global
end

ResourceLoader.messageReceived = function(self, message)
	self.resources[message.info.index] = message.resource
	self.observable:sendEvent(message)
end

ResourceLoader.addObserver = function(self, observer)
	self.observable:addObserver(observer)
end

ResourceLoader.removeObserver = function(self, observer)
	self.observable:removeObserver(observer)
end

ResourceLoader.loadData = function(self, event)
	if self.resources[event.index] then
		event.resource = self.resources[event.index]
		self.observable:sendEvent(event)
	else
		self.thread:send(event)
	end
end

ResourceLoader.unloadData = function(self, info)
	if self.resources[info.index] then
		self.observable:sendEvent({
			info = info,
			resource = self.resources[info.index]
		})
	end
end