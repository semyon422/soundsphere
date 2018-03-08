AudioManager = createClass(soul.SoulObject)

AudioManager.load = function(self)
	self.chunkData = {}
	self.sounds = {}
	
	self.loaded = true
end

AudioManager.unload = function(self)
	self.loaded = false
end

AudioManager.update = function(self)
	
end

AudioManager.loadChunk = function(self, filePath, group)
	if not self.chunkData[filePath] then
		local file = love.filesystem.newFile(filePath)
		file:open("r")
		self.chunkData[filePath] = {
			chunk = bass.BASS_SampleLoad(true, file:read(), 0, file:getSize(), 65535, 0),
			group = group
		}
		file:close()
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
	self:addSound(filePath, group):play()
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