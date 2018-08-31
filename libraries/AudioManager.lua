AudioManager = createClass(soul.SoulObject)

AudioManager.load = function(self)
	self.loadingChunkData = {}
	self.chunkData = {}
	self.sounds = {}
	
	self.resourceLoader = ResourceLoader:getGlobal()
	self.resourceLoader:addObserver(self.observer)
	
	self.observable = Observable:new()
end

AudioManager.getGlobal = function(self)
	if not AudioManager.global then
		AudioManager.global = AudioManager:new()
	end
	return AudioManager.global
end

AudioManager.unload = function(self)
end

AudioManager.receiveEvent = function(self, event)
	if event.name == "love.update" then
		self:update()
	elseif event.resource and event.action == "load" then
		self:setChunkData(event)
	end
end

AudioManager.setChunkData = function(self, event)
	local chunkData = {
		chunk = event.resource
	}
	event.name = "ChunkDataLoaded"
	event.chunkData = chunkData
	self.chunkData[event.filePath] = chunkData
	self.loadingChunkData[event.filePath] = nil
	
	self.observable:sendEvent(event)
end

AudioManager.update = function(self)
	local stoppedSounds = {}
	for sound in pairs(self.sounds) do
		if bass.BASS_ChannelIsActive(sound.channel) == 0 then
			sound:stop()
			table.insert(stoppedSounds, sound)
		end
	end
	for _, sound in ipairs(stoppedSounds) do
		self.sounds[sound] = nil
	end
end

AudioManager.addObserver = function(self, observer)
	self.observable:addObserver(observer)
end

AudioManager.removeObserver = function(self, observer)
	self.observable:removeObserver(observer)
end

AudioManager.loadChunk = function(self, filePath)
	if not self.chunkData[filePath] and not self.loadingChunkData[filePath] then
		self.resourceLoader:loadData({
			dataType = "audio",
			action = "load",
			filePath = filePath,
			index = filePath
		})
		self.loadingChunkData[filePath] = true
	end
end

AudioManager.unloadChunk = function(self, filePath)
	self.resourceLoader:unloadData({
		dataType = "audio",
		action = "unload",
		resource = self.chunkData[filePath].chunk,
		index = filePath
	})
	self.chunkData[filePath] = nil
end



AudioManager.getSound = function(self, filePath)
	local sound = AudioManager.Sound:new()
	sound.chunk = self.chunkData[filePath].chunk
	sound.filePath = filePath
	
	return sound
end

AudioManager.addSound = function(self, filePath)
	local sound = self:getSound(filePath)
	self.sounds[sound] = sound
	
	return sound
end

AudioManager.playSound = function(self, filePath)
	if self.chunkData[filePath] then
		self:addSound(filePath):play()
	end
end

AudioManager.stopSound = function(self, filePath)
	for sound in pairs(self.sounds) do
		if sound.filePath == filePath then
			sound:stop()
		end
	end
end



AudioManager.Sound = {}

AudioManager.Sound_metatable = {}
AudioManager.Sound_metatable.__index = AudioManager.Sound

local Sound = AudioManager.Sound

Sound.new = function(self)
	local sound = {}
	
	setmetatable(sound, AudioManager.Sound_metatable)
	
	return sound
end

Sound.play = function(self)
	if not self.channel then
		self.channel = bass.BASS_SampleGetChannel(self.chunk, false)
	end
	bass.BASS_ChannelPlay(self.channel, false)
end

Sound.pause = function(self)
	bass.BASS_ChannelPause(self.channel)
end

Sound.stop = function(self)
	bass.BASS_ChannelStop(self.channel)
end

Sound.getPosition = function(self)
	return tonumber(bass.BASS_ChannelGetPosition(self.channel, 0)) / 1e5
end