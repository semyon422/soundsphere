local Class = require("Class")
local audio = require("audio")

local AudioManager = Class:new()

AudioManager.time = 0

AudioManager.load = function(self)
	self.sources = {}
	self.intervals = {}
	self.allSources = {}

	self.firstTime = 0
	self.lastTime = 0
end

AudioManager.unload = function(self)
	for source in pairs(self.allSources) do
		source.audio:stop()
		source.audio:release()
	end
end

AudioManager.update = function(self, force)
	local time = self.editorModel.timer:getTime()
	if time == self.time and not force then
		return
	end
	self.time = time

	local isPlaying = self.editorModel.timer.isPlaying
	local forcePosition = not isPlaying or force

	local sources = self:getCurrentSources()
	for source in pairs(sources) do
		if not self.sources[source] then
			self.sources[source] = source
		end
		if isPlaying then
			source.audio:setRate(self.editorModel.timer.rate)
			if source.isStream then
				source.audio:setVolume(self.volume.master * self.volume.music * source.volume)
			else
				source.audio:setVolume(self.volume.master * self.volume.effects * source.volume)
			end
			source.audio:play()
		end
	end
	for source in pairs(self.sources) do
		if not sources[source] then
			sources[source] = nil
			source.audio:stop()
			self.sources[source] = nil
		end
	end
	if forcePosition then
		for source in pairs(self.sources) do
			source.audio:setPosition(time - source.offset)
		end
	end
end

AudioManager.setVolume = function(self)
	for _source in pairs(self.sources) do
		local source = _source.audio
		if source.isStream then
			source.audio:setVolume(self.volume.master * self.volume.music * source.volume)
		else
			source.audio:setVolume(self.volume.master * self.volume.effects * source.volume)
		end
	end
end

AudioManager.setRate = function(self, rate)
	for _source in pairs(self.sources) do
		_source.audio:setRate(rate)
	end
end

AudioManager.getPosition = function(self)
	local position = 0
	local length = 0

	for _source in pairs(self.sources) do
		local source = _source.audio
		local pos = source:getPosition()
		if _source.isStream and source:isPlaying() then
			local _length = source:getLength()
			position = position + (_source.offset + pos) * _length
			length = length + _length
		end
	end

	if length == 0 then
		return nil
	end

	return position / length
end

AudioManager.play = function(self)
	local time = self.editorModel.timer:getTime()
	for source in pairs(self.sources) do
		source.audio:setPosition(time - source.offset)
	end
end

AudioManager.pause = function(self)
	for source in pairs(self.sources) do
		source.audio:pause()
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
	self.allSources[source] = true
end

AudioManager.remove = function(self, source)
	local intervals = self.intervals
	for i = math.floor(source.offset), math.ceil(source.offset + source.duration) - 1 do
		intervals[i] = intervals[i] or {}
		intervals[i][source] = nil
	end
	self.allSources[source] = nil
end

AudioManager.loadResources = function(self, noteChart)
	local audioSettings = self.editorModel:getAudioSettings()
	for noteDatas in noteChart:getInputIterator() do
		for _, noteData in ipairs(noteDatas) do
			local offset = noteData.timePoint.absoluteTime
			if noteData.sounds then
				for _, s in ipairs(noteData.sounds) do
					local path = self.editorModel.resourceModel.aliases[s[1]]
					local soundData = self.editorModel.resourceModel.resources[path]
					if soundData then
						local mode = noteData.stream and audioSettings.mode.primary or audioSettings.mode.secondary
						local _audio = audio:newAudio(soundData, mode)
						local duration = _audio:getLength()
						self:insert({
							offset = offset,
							duration = duration,
							soundData = soundData,
							audio = _audio,
							name = s[1],
							volume = s[2],
							isStream = noteData.stream,
						})
						self.firstTime = math.min(self.firstTime, offset)
						self.lastTime = math.max(self.lastTime, offset + duration)
					end
				end
			end
		end
	end
end

return AudioManager
