local Class			= require("aqua.util.Class")
local Observable	= require("aqua.util.Observable")
local math			= math

local safeload = function(chunk, env)
	if chunk:byte(1) == 27 then
		error("bytecode is not allowed")
	end
	local f, message = loadstring(chunk)
	if not f then
		error(message)
	end
	setfenv(f, env)
	return f
end

local Counter = Class:new()

Counter.construct = function(self)
	self.env = {}
	self.env.math = math
	self.env.print = print
end

Counter.loadFile = function(self, path)
	local file = io.open(path, "r")
	safeload(file:read("*all"), self.env)()
	file:close()
end

Counter.load = function(self, score)
	self.env.load(score)
end

Counter.receive = function(self, event)
	self.env.receive(event)
end

return Counter
