AudioManager = createClass(soul.SoulObject)

AudioManager.load = function(self)
	self.loadingChunkData = {}
	self.loadingGroup = {}
	self.observers = {}
	self.chunkData = {}
	self.sounds = {}
	
	self.thread = soul.Thread:new({
		threadName = "AudioManager",
		messageReceived = function(thread, chunkData)
			self:setChunkData(chunkData)
		end,
		threadFunction = [[
			ffi = require("ffi")
			require("love.filesystem")
			require("libraries.packagePath")
			require("bass_ffi")
			receiveMessageCallback = function(chunkData)
				local file = love.filesystem.newFile(chunkData.filePath)
				file:open("r")
				chunkData.chunk = bass.BASS_SampleLoad(true, file:read(), 0, file:getSize(), 65535, 0)
				file:close()
				sendMessage(chunkData)
			end
		]]
	})
	self.thread:activate()
	
	self.loaded = true
end

AudioManager.unload = function(self)
	self.loaded = false
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

AudioManager.setChunkData = function(self, chunkData)
	self.chunkData[chunkData.filePath] = chunkData
	self.loadingGroup[chunkData.group] = self.loadingGroup[chunkData.group] - 1
	self.loadingChunkData[chunkData.filePath] = nil
	
	self:sendEvent({
		type = "Group",
		name = chunkData.group,
		value = self.loadingGroup[chunkData.group]
	})
	self:sendEvent({
		type = "ChunkData",
		name = chunkData.filePath,
		value = false
	})
end

AudioManager.addObserver = function(self, observer)
	self.observers[observer] = true
end

AudioManager.removeObserver = function(self, observer)
	self.observers[observer] = nil
end

AudioManager.sendEvent = function(self, event)
	for observer in pairs(self.observers) do
		observer:receiveEvent(event)
	end
end

AudioManager.loadChunk = function(self, filePath, group)
	if not self.chunkData[filePath] and not self.loadingChunkData[filePath] then
		self.thread:send({
			filePath = filePath,
			group = group
		})
		self.loadingGroup[group] = (self.loadingGroup[group] or 0) + 1
		self.loadingChunkData[filePath] = true
	end
end

AudioManager.unloadChunk = function(self, filePath)
	bass.BASS_SampleFree(self.chunkData[filePath].chunk)
	self.chunkData[filePath] = nil
end

AudioManager.unloadChunkGroup = function(self, group)
	for filePath, chunkData in pairs(self.chunkData) do
		if chunkData.group == group or group == "*" then
			self:unloadChunk(filePath)
		end
	end
end



AudioManager.getSound = function(self, filePath)
	local sound = AudioManager.Sound:new()
	sound.chunk = self.chunkData[filePath].chunk
	
	return sound
end

AudioManager.addSound = function(self, filePath, group)
	local sound = self:getSound(filePath)
	sound.group = group
	self.sounds[sound] = sound
	
	return sound
end

AudioManager.playSound = function(self, filePath, group)
	if self.chunkData[filePath] then
		self:addSound(filePath, group):play()
	end
end

AudioManager.playSoundGroup = function(self, group)
	for sound in pairs(self.sounds) do
		if sound.group == group then
			sound:play()
		end
	end
end

AudioManager.stopSoundGroup = function(self, group)
	for sound in pairs(self.sounds) do
		if sound.group == group then
			sound:stop()
			self.sounds[sound] = nil
		end
	end
end

AudioManager.pauseSoundGroup = function(self, group)
	for sound in pairs(self.sounds) do
		if sound.group == group then
			sound:pause()
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
	self.channel = bass.BASS_SampleGetChannel(self.chunk, false)
	bass.BASS_ChannelPlay(self.channel, false)
end

Sound.pause = function(self)
	bass.BASS_ChannelPause(self.channel)
end

Sound.stop = function(self)
	bass.BASS_ChannelStop(self.channel)
end