local AudioFactory = require("aqua.audio.AudioFactory")
local Config = require("sphere.game.Config")

local PreviewManager = {}

PreviewManager.init = function(self)
	self.state = 0
end

PreviewManager.playAudio = function(self, path, position)
	if not love.filesystem.exists(path) then
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
	
	local volume = Config.data.volume
	
	self.path = path
	self.position = position
	self.audio = AudioFactory:getStream(path)
	self.audio:setPosition(position)
	self.audio:setVolume(volume.main * volume.music)
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
end

PreviewManager.reload = function(self, event)
end

return PreviewManager
