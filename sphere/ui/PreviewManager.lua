local AudioFactory	= require("aqua.audio.AudioFactory")

local PreviewManager = {}

PreviewManager.playAudio = function(self, path, position)
	local info = love.filesystem.getInfo(path)
	if not info then
		self:stop()
		return
	end
	if self.audio then
		if self.path ~= path then
			self:stop()
		else
			return
		end
	end

	local audio
	local mode = self.configModel:get("audio.previewAudioMode")
	if mode == "sample" then
		audio = AudioFactory:getSample(path)
	elseif mode == "stream" then
		audio = AudioFactory:getStream(path)
	elseif mode == "streamTempo" then
		audio = AudioFactory:getStreamTempo(path)
	elseif mode == "streamUser" then
		audio = AudioFactory:getStreamUser(path)
	elseif mode == "streamUserTempo" then
		audio = AudioFactory:getStreamUserTempo(path)
	elseif mode == "streamMemoryTempo" then
		audio = AudioFactory:getStreamMemoryTempo(path)
	elseif mode == "streamMemoryReversable" then
		audio = AudioFactory:getStreamMemoryReversable(path)
	end

	if not audio then
		return
	end

	self.path = path
	self.position = position
	self.audio = audio
	self.audio:setPosition(position)
	self.audio:setVolume(self.configModel:get("volume.global") * self.configModel:get("volume.music"))
	self.audio:play()
end

PreviewManager.stop = function(self)
	if self.audio then
		self.audio:stop()
		self.audio:free()
	end
	self.audio = nil
end

PreviewManager.update = function(self, dt)
	if not self.audio then return end

	if not self.audio:isPlaying() then
		self.audio:setPosition(self.position)
		self.audio:play()
	end
end

PreviewManager.receive = function(self, event)
	if self.audio and event.name == "Config.set" and (event.key == "volume.global" or event.key == "volume.music") then
		self.audio:setVolume(self.configModel:get("volume.global") * self.configModel:get("volume.music"))
	end
end

PreviewManager.reload = function(self, event)
end

return PreviewManager
