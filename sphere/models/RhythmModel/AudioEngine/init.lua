local _audio		= require("aqua.audio")
local AudioContainer	= require("aqua.audio.Container")
local Class				= require("aqua.util.Class")
local Observable		= require("aqua.util.Observable")
local NoteChartResourceLoader	= require("sphere.database.NoteChartResourceLoader")

local AudioEngine = Class:new()

AudioEngine.timeRate = 1

AudioEngine.construct = function(self)
	self.observable = Observable:new()

	self.volume = {
		master = 1,
		music = 1,
		effects = 1,
	}
	self.mode = {
		primary = "bass_sample",
		secondary = "bass_sample",
	}

	self.backgroundContainer = AudioContainer:new()
	self.foregroundContainer = AudioContainer:new()
end

AudioEngine.updateVolume = function(self)
	self.backgroundContainer:setVolume(self.volume.master * self.volume.music)
	self.foregroundContainer:setVolume(self.volume.master * self.volume.effects)
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
	self.backgroundContainer:release()
	self.foregroundContainer:release()
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

	if not noteData or not noteData.sounds then
		return
	end
	local layer = note.autoplay and "background" or "foreground"

	self:playAudio(noteData.sounds, note.autoplay, noteData.stream, noteData.timePoint.absoluteTime)
end

AudioEngine.playAudio = function(self, sounds, isBackground, stream, offset)
	local currentTime = self.rhythmModel.timeEngine.currentTime
	local aliases = NoteChartResourceLoader.aliases
	local resources = NoteChartResourceLoader.resources
	for i = 1, #sounds do
		local mode = stream and self.mode.primary or self.mode.secondary

		local soundData = resources[aliases[sounds[i][1]]]
		local audio = _audio:newAudio(soundData, mode)

		if audio then
			audio.offset = offset or currentTime
			audio:setBaseVolume(sounds[i][2])
			local shouldPlay = true
			if self.forcePosition then
				local p = currentTime - audio.offset
				if p >= audio:getLength() then
					shouldPlay = false
				else
					audio:setPosition(p)
				end
			end
			if shouldPlay then
				if isBackground then
					self.backgroundContainer:add(audio)
				else
					self.foregroundContainer:add(audio)
				end
			else
				audio:release()
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
