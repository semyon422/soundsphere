local AudioFactory		= require("aqua.audio.AudioFactory")
local AudioContainer	= require("aqua.audio.Container")
local Class				= require("aqua.util.Class")
local Observable		= require("aqua.util.Observable")
local SoundNoteFactory	= require("sphere.models.RhythmModel.AudioEngine.SoundNoteFactory")

local AudioEngine = Class:new()

AudioEngine.timeRate = 1
AudioEngine.globalVolume = 1
AudioEngine.musicVolume = 1
AudioEngine.effectsVolume = 1
AudioEngine.primaryAudioMode = "sample"
AudioEngine.secondaryAudioMode = "sample"

AudioEngine.construct = function(self)
	self.observable = Observable:new()

	self.localAliases = {}
	self.globalAliases = {}

	self.backgroundContainer = AudioContainer:new()
	self.foregroundContainer = AudioContainer:new()
end

AudioEngine.updateVolume = function(self)
	self.backgroundContainer:setVolume(self.globalVolume * self.musicVolume)
	self.foregroundContainer:setVolume(self.globalVolume * self.effectsVolume)
end

AudioEngine.load = function(self) end

AudioEngine.update = function(self)
	self.backgroundContainer:update()
	self.foregroundContainer:update()
end

AudioEngine.unload = function(self)
	self.backgroundContainer:stop()
	self.foregroundContainer:stop()
end

AudioEngine.receive = function(self, event)
	if event.name == "LogicalNoteState" then
		local soundNote = SoundNoteFactory:getNote(event.note)
		soundNote.audioEngine = self
		return soundNote:receive(event)
	elseif event.name == "TimeState" then
		self.currentTime = event.exactCurrentTimeNoOffset
		self:setTimeRate(event.timeRate)
	end
end

AudioEngine.playAudio = function(self, paths, layer, keysound, stream, offset)
	if not paths then return end
	for i = 1, #paths do
		local path = paths[i][1]
		local aliases = self.localAliases
		if not keysound and not aliases[path] then
			aliases = self.globalAliases
		end

		local mode
		if stream then
			mode = self.primaryAudioMode
		else
			mode = self.secondaryAudioMode
		end

		local apath = aliases[paths[i][1]]
		local audio = AudioFactory:getAudio(apath, mode)

		if audio then
			audio.offset = offset or self.currentTime
			audio:setRate(self.timeRate)
			audio:setBaseVolume(paths[i][2])
			if self.forcePosition then
				audio:setPosition(self.currentTime - audio.offset)
			end
			if layer == "background" then
				self.backgroundContainer:add(audio)
			elseif layer == "foreground" then
				self.foregroundContainer:add(audio)
			end
			audio:play()
		end
	end
end

AudioEngine.setTimeRate = function(self, timeRate)
	if timeRate == 0 and self.timeRate ~= 0 then
		self.backgroundContainer:pause()
		self.foregroundContainer:pause()
	elseif timeRate ~= 0 and self.timeRate == 0 then
		self.backgroundContainer:setRate(timeRate)
		self.foregroundContainer:setRate(timeRate)
		self.backgroundContainer:play()
		self.foregroundContainer:play()
	elseif timeRate ~= 0 and self.timeRate ~= 0 then
		self.backgroundContainer:setRate(timeRate)
		self.foregroundContainer:setRate(timeRate)
	end
	self.timeRate = timeRate
end

AudioEngine.getPosition = function(self)
	return self.backgroundContainer:getPosition()
end

AudioEngine.setPosition = function(self, position)
	self.backgroundContainer:setPosition(position)
	self.foregroundContainer:setPosition(position)
end

return AudioEngine
