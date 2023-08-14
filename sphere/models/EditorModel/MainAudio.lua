local audio = require("audio")
local class = require("class")

local MainAudio = class()

function MainAudio:load()
	self.soundData = nil
	self.offset = 0
	self.duration = 0
end

function MainAudio:getAudioOffset()
	local editor = self.editorModel:getSettings()
	return self.offset + editor.audioOffset
end

function MainAudio:getWaveformOffset()
	local editor = self.editorModel:getSettings()
	return self.offset + editor.waveformOffset
end

function MainAudio:unload()
	local source = self.source
	if not source then
		return
	end
	source:release()
	self.source = nil
end

function MainAudio:getPosition()
	local source = self.source
	if not source then
		return
	end
	local pos = source:getPosition()
	if source:isPlaying() then
		return pos + self:getAudioOffset()
	end
end

function MainAudio:loadResources(noteChart)
	local audioSettings = self.editorModel:getAudioSettings()
	for noteDatas in noteChart:getInputIterator() do
		for _, noteData in ipairs(noteDatas) do
			if noteData.stream then
				self.offset = noteData.streamOffset or 0
				local path = noteData.sounds[1][1]
				local soundData = self.editorModel.resourceModel:getResource(path)
				if soundData then
					self.soundData = soundData
					self.duration = soundData:getDuration()
					local mode = audioSettings.mode.primary
					self.source = audio.newSource(soundData, mode)
				end
			end
		end
	end
end

function MainAudio:isPlayable()
	local time = self.time
	local offset = self:getAudioOffset()
	return time >= offset and time < offset + self.duration
end

function MainAudio:update(force)
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

	local offset = self:getAudioOffset()

	if time < offset then
		source:stop()
		return
	end

	-- substract 1 second because source can stop before (offset + duration)
	if time >= offset + self.duration - 1 then
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

function MainAudio:play()
	if self.source and self:isPlayable() then
		self.source:play()
	end
end

function MainAudio:pause()
	if self.source then
		self.source:pause()
	end
end

return MainAudio
