local Class = require("Class")

local AudioManager = Class:new()

AudioManager.time = 0

AudioManager.construct = function(self)
	self.sources = {}
	self.intervals = {}
end

AudioManager.setTime = function(self, time)
	self.time = time
end

AudioManager.getCurrentSources = function(self)
	local time = self.time
	local interval = self.intervals[math.floor(time)]

	local sources = {}
	if not interval then
		return sources
	end
	for source in pairs(interval) do
		if source.offset <= time and source.offset + source.duration > time then
			table.insert(sources, source)
		end
	end

	return sources
end

AudioManager.insert = function(self, source)
	local intervals = self.intervals
	for i = math.floor(source.offset), math.ceil(source.offset + source.duration) - 1 do
		intervals[i] = intervals[i] or {}
		intervals[i][source] = true
	end
end

AudioManager.remove = function(self, source)
	local intervals = self.intervals
	for i = math.floor(source.offset), math.ceil(source.offset + source.duration) - 1 do
		intervals[i] = intervals[i] or {}
		intervals[i][source] = nil
	end
end

return AudioManager
