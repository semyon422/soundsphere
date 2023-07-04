local Video = {}

Video.release = function(self)
	self.video:close()
	self.imageData:release()
	self.image:release()
end

Video.rewind = function(self)
	local v = self.video
	v:seek(0)
	v:read(self.imageData:getPointer())
end

Video.play = function(self, time)
	local v = self.video
	while time >= v:tell() do
		v:read(self.imageData:getPointer())
	end
	self.image:replacePixels(self.imageData)
end

return Video
