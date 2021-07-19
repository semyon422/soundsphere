local json			= require("json")
local Class			= require("aqua.util.Class")
local Observable	= require("aqua.util.Observable")
local Counter		= require("sphere.models.RhythmModel.ScoreEngine.Counter")

local ScoreSystem = Class:new()

ScoreSystem.basePath = "userdata/counters"

ScoreSystem.send = function(self, event)
	return self.observable:send(event)
end

ScoreSystem.construct = function(self)
	self.observable = Observable:new()
end

ScoreSystem.setBasePath = function(self, path)
	self.basePath = path
end

ScoreSystem.loadConfig = function(self, path)
	local contents = love.filesystem.read(self.basePath .. "/" .. path)
	self.scoreConfig = json.decode(contents)

	self.scoreTable = {
		timeRate = 1
	}

	self:loadCounters()
end

ScoreSystem.loadCounters = function(self)
	self.counters = {}
	local counters = self.counters

	for _, counterConfig in ipairs(self.scoreConfig.counters) do
		local counter = Counter:new()
		counter.config = counterConfig
		counter.scoreTable = self.scoreTable
		counter:loadFile(self.basePath .. "/" .. counterConfig.path)
		counter:load()
		counters[#counters + 1] = counter
	end
end

ScoreSystem.getCounter = function(self, path)
	local counters = self.counters
	for i = 1, #counters do
		local counter = counters[i]
		if counter.config.path == path then
			return counter
		end
	end
end

ScoreSystem.receive = function(self, event)
	local counters = self.counters
	for i = 1, #counters do
		counters[i]:receive(event)
	end
end

ScoreSystem.set = function(self, key, value)
	self.scoreTable[key] = value
end

ScoreSystem.get = function(self, key)
	return self.scoreTable[key]
end

return ScoreSystem
