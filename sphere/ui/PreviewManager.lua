-- local tween = require("tween")
local AudioFactory = require("aqua.audio.AudioFactory")

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
			self.audio:stop()
		else
			return
		end
	end
	
	self.path = path
	self.position = position
	self.audio = AudioFactory:getStream(path)
	self.audio:setPosition(position)
	self.audio:play()
end

PreviewManager.stop = function(self)
	if self.audio then self.audio:stop() end
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
