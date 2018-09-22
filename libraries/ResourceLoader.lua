local threadFile = [[
require("libraries.packagePath")

ffi = require("ffi")
require("bass_ffi")
require("love.filesystem")
require("love.image")

loadAudio = function(event)
	local file = love.filesystem.newFile(event.filePath)
	file:open("r")
	event.resource = bass.BASS_SampleLoad(true, file:read(), 0, file:getSize(), 65535, 0)
	file:close()
end

unloadAudio = function(event)
	bass.BASS_SampleFree(event.resource)
end

loadImageData = function(event)
	if love.filesystem.exists(event.filePath) then
		event.resource = love.image.newImageData(event.filePath)
	end
end

receiveMessageCallback = function(event)
	if event.dataType == "audio" and event.action == "load" then
		loadAudio(event)
		sendMessage(event)
	elseif event.dataType == "audio" and event.action == "unload" then
		unloadAudio(event)
	elseif event.dataType == "imageData" and event.action == "load" then
		loadImageData(event)
		sendMessage(event)
	end
end
]]

ResourceLoader = createClass(soul.SoulObject)

ResourceLoader.load = function(self)
	self.resources = {}
	
	self.thread = soul.Thread:new()
	self.thread.threadName = "ResourceLoader"
	self.thread.messageReceived = function(thread, event)
		self:messageReceived(event)
	end
	self.thread.threadFunction = threadFile
	self.thread:activate()
	
	self.observable = Observable:new()
end

ResourceLoader.getGlobal = function(self)
	if not ResourceLoader.global then
		ResourceLoader.global = ResourceLoader:new()
	end
	return ResourceLoader.global
end

ResourceLoader.messageReceived = function(self, event)
	self.resources[event.index] = event.resource
	self.observable:sendEvent(event)
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

ResourceLoader.unloadData = function(self, event)
	if self.resources[event.index] then
		self.thread:send(event)
		self.observable:sendEvent(event)
		self.resources[event.index] = nil
	end
end