-- local tween = require("tween")
local AudioFactory = require("aqua.audio.AudioFactory")

local PreviewManager = {}

PreviewManager.init = function(self)
	self.state = 0
end

PreviewManager.playAudio = function(self, path, position)
	if not love.filesystem.exists(path) then return end
	if self.audio then self.audio:stop() end
	
	self.audio = AudioFactory:getStream(path)
	self.audio:setPosition(position)
	self.audio:play()
end

PreviewManager.update = function(self, dt)
end

PreviewManager.receive = function(self, event)
end

PreviewManager.reload = function(self, event)
end

return PreviewManager
