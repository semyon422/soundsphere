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
	self:createEnv()
end

Counter.createEnv = function(self)
	self.env = {}

	local env = self.env

	env.math = math
	env.print = print
	env.pairs = pairs
	env.ipairs = ipairs
	env.table = table
end

Counter.loadFile = function(self, path)
	local contents = love.filesystem.read(path)
	safeload(contents, self.env)()
end

Counter.load = function(self)
	local env = self.env
	env.scoreTable = self.scoreTable
	env.config = self.config
	env.load()
end

Counter.receive = function(self, event)
	self.env.receive(event)
end

return Counter
