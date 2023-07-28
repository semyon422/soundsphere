local audio = require("audio")
local Class = require("Class")

local MainAudio = Class:new()

MainAudio.load = function(self)
	self.soundData = nil
	self.offset = 0
	self.audioOffset = 0
	self.duration = 0
end

MainAudio.getAudioOffset = function(self)
	local editor = self.editorModel:getSettings()
	return self.offset + editor.audioOffset
end

MainAudio.unload = function(self)
	local source = self.source
	if not source then
		return
	end
	source:release()
	source = nil
end

MainAudio.getPosition = function(self)
	local source = self.source
	if not source then
		return
	end
	local pos = source:getPosition()
	if source:isPlaying() then
		return pos + self:getAudioOffset()
	end
end

MainAudio.loadResources = function(self, noteChart)
	local audioSettings = self.editorModel:getAudioSettings()
	for noteDatas in noteChart:getInputIterator() do
		for _, noteData in ipairs(noteDatas) do
			if noteData.stream then
				self.offset = noteData.streamOffset or 0
				local path = noteData.sounds[1][1]
				local soundData = self.editorModel.resourceModel:getResource(path)
				self.bassSoundData = soundData
				if soundData then
					self.duration = soundData:getDuration()
					self.soundData = love.sound.newSoundData(self.editorModel.audioPath)
					local mode = audioSettings.mode.primary
					self.source = audio.newSource(soundData, mode)
				end
			end
		end
	end
end

MainAudio.isPlayable = function(self)
	local time = self.time
	local offset = self:getAudioOffset()
	return time >= offset and time < offset + self.duration
end

MainAudio.update = function(self, force)
	local source = self.source
	if not source then
		return
	end

	local time = self.editorModel.timer:getTime()
	if time == self.time and not force then
		return
	end
	self.time = time

	local isPlaying = self.editorModel.timer.isPlaying
	local forcePosition = not isPlaying or force

	if not self:isPlayable() then
		source:stop()
		return
	end

	source:setRate(self.editorModel.timer.rate)
	source:setVolume(self.volume.master * self.volume.music)

	if forcePosition then
		source:setPosition(time - self:getAudioOffset())
	end

	if isPlaying then
		source:play()
	end
end

MainAudio.play = function(self)
	if self.source and self:isPlayable() then
		self.source:play()
	end
end

MainAudio.pause = function(self)
	if self.source and self:isPlayable() then
		self.source:pause()
	end
end

return MainAudio
