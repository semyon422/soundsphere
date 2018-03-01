soul.Thread = createClass(soul.SoulObject)
local Thread = soul.Thread

Thread.load = function(self)
	self.thread = love.thread.newThread(self.threadFunctionHeader .. self.threadFunction)
	self.inputChannel = love.thread.getChannel("input")
	self.outputChannel = love.thread.getChannel("output")
	self.thread:start()
end

Thread.unload = function(self)

end

Thread.update = function(self)
	local message = self:receive()
	while message do
		self:messageReceived(message)
		message = self:receive()
	end
end

Thread.send = function(self, message)
	self.inputChannel:push(message)
end

Thread.receive = function(self)
	return self.outputChannel:pop()
end

Thread.messageReceived = function(self, message) end

Thread.threadFunctionHeader = [[
inputChannel = love.thread.getChannel("input")
outputChannel = love.thread.getChannel("output")
]]
Thread.threadFunction = [[]]