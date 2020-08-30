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
	self.scoreTable = {
		timeRate = 1
	}
end

ScoreSystem.loadConfig = function(self, path)
	local file = io.open(self.basePath .. "/" .. path, "r")
	self.scoreConfig = json.decode(file:read("*all"))
	file:close()

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

return ScoreSystem
