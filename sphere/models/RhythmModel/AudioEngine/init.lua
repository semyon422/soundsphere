local AudioFactory		= require("aqua.audio.AudioFactory")
local AudioContainer	= require("aqua.audio.Container")
local Class				= require("aqua.util.Class")
local Observable		= require("aqua.util.Observable")

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

AudioEngine.load = function(self)
	self.loaded = true
end

AudioEngine.update = function(self)
	self:updateTimeRate()
	self.backgroundContainer:update()
	self.foregroundContainer:update()
end

AudioEngine.unload = function(self)
	self.backgroundContainer:stop()
	self.foregroundContainer:stop()
	self.loaded = false
end

AudioEngine.receive = function(self, event)
	if not self.loaded or event.name ~= "LogicalNoteState" or event.key ~= "keyState" then
		return
	end

	local noteData
	local note = event.note
	if note.noteClass == "ShortLogicalNote" and event.value then
		noteData = note.startNoteData
	elseif note.noteClass == "LongLogicalNote" then
		if event.value then
			noteData = note.startNoteData
		else
			noteData = note.endNoteData
		end
	end

	if not noteData then
		return
	end
	local layer = note.autoplay and "background" or "foreground"

	self:playAudio(noteData.sounds, layer, noteData.keysound, noteData.stream, noteData.timePoint.absoluteTime)
end

AudioEngine.playAudio = function(self, paths, layer, keysound, stream, offset)
	local currentTime = self.rhythmModel.timeEngine.currentTime
	local aliases = self.localAliases
	if not paths then return end
	for i = 1, #paths do
		local path = paths[i][1]
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
			audio.offset = offset or currentTime
			audio:setRate(self.timeRate)
			audio:setBaseVolume(paths[i][2])
			local shouldPlay = true
			if self.forcePosition then
				local p = currentTime - audio.offset
				if p > audio:getLength() then
					shouldPlay = false
				else
					audio:setPosition(p)
				end
			end
			if shouldPlay then
				if layer == "background" then
					self.backgroundContainer:add(audio)
				elseif layer == "foreground" then
					self.foregroundContainer:add(audio)
				end
				audio:play()
			end
		end
	end
end

AudioEngine.play = function(self)
	self.backgroundContainer:play()
	self.foregroundContainer:play()
end

AudioEngine.pause = function(self)
	self.backgroundContainer:pause()
	self.foregroundContainer:pause()
end

AudioEngine.updateTimeRate = function(self)
	local timeRate = self.rhythmModel.timeEngine.timeRate
	if self.timeRate == timeRate then
		return
	end
	self.backgroundContainer:setRate(timeRate)
	self.foregroundContainer:setRate(timeRate)
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
