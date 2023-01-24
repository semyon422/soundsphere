local Class = require("Class")

local AudioManager = Class:new()

AudioManager.time = 0

AudioManager.construct = function(self)
	self.sources = {}
	self.intervals = {}
end

AudioManager.update = function(self)
	for _source in pairs(self.sources) do
		local source = _source.audio
		if not source:isPlaying() then
			self.sources[_source] = nil
		end
	end
end

AudioManager.unload = function(self)
	-- self.container:release()
end

AudioManager.getPosition = function(self)
	local position = 0
	local length = 0

	for _source in pairs(self.sources) do
		local source = _source.audio
		local pos = source:getPosition()
		if source:isPlaying() then
			local _length = source:getLength()
			position = position + (source.offset + pos) * _length
			length = length + _length
		end
	end

	if length == 0 then
		return nil
	end

	return position / length
end

AudioManager.play = function(self)
	for source in pairs(self.sources) do
		source.audio:setPosition(self.time - source.offset)
	end
end

AudioManager.setPosition = function(self)
	for source in pairs(self.sources) do
		source.audio:setPosition(self.time - source.offset)
	end
end

AudioManager.pause = function(self)
	for source in pairs(self.sources) do
		source.audio:pause()
	end
end

AudioManager.setTime = function(self, time)
	if time == self.time then
		return
	end

	local forcePosition = time < self.time
	self.time = time

	local sources = self:getCurrentSources()

	for source in pairs(sources) do
		if not self.sources[source] then
			self.sources[source] = source
			source.audio:play()
			if forcePosition then
				source:setPosition(time - source.offset)
			end
		end
	end
	for source in pairs(self.sources) do
		if not sources[source] then
			sources[source] = nil
			source.audio:stop()
		end
	end
	for source in pairs(self.sources) do
		if time < source.offset or time >= source.offset + source.duration then
			self.sources[source] = nil
		end
	end
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
			sources[source] = true
			-- table.insert(sources, source)
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
