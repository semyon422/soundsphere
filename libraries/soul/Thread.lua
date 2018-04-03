soul.Thread = createClass(soul.SoulObject)
local Thread = soul.Thread

Thread.load = function(self)
	self.thread = love.thread.newThread(
		"threadName = " .. self.threadName .. "\n" ..
		self:getThreadFunctionHeader() ..
		self.threadFunction ..
		self.threadFunctionFooter
	)
	self.inputChannel = love.thread.getChannel("input_" .. self.threadName)
	self.outputChannel = love.thread.getChannel("output_" .. self.threadName)
	self.thread:start()
end

Thread.unload = function(self)

end

Thread.update = function(self)
	local threadError = self.thread:getError()
	if threadError then
		error(threadError)
	end
	
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

Thread.getThreadFunctionHeader = function(self)
	return [[
		require("love.timer")
		inputChannel = love.thread.getChannel("input_]] .. self.threadName .. [[")
		outputChannel = love.thread.getChannel("output_]] .. self.threadName .. [[")
		
		sendMessage = function(message)
			outputChannel:push(message)
		end
		
		threaded = true
	]]
end

Thread.threadFunctionFooter = [[
	if receiveMessageCallback then
		while true do
			local startTime = love.timer.getTime()
			local message = inputChannel:pop()
			if message then
				receiveMessageCallback(message)
			end
			local deltaTime = love.timer.getTime() - startTime
			if deltaTime < 0.01 then
				love.timer.sleep(0.01 - deltaTime)
			end
		end
	end
]]

Thread.threadFunction = [[]]