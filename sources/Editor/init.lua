Editor = createClass(soul.SoulObject)

Editor.load = function(self)
	local file = love.filesystem.newFile("userdata/audio.mp3")
	file:open("r")
	self.sample = bass.BASS_SampleLoad(true, file:read(), 0, file:getSize(), 65535, 256)
	file:close()
	
	self.sampleInfo = ffi.new("BASS_SAMPLE")
	bass.BASS_SampleGetInfo(self.sample, self.sampleInfo)
	
	print(self.sampleInfo.length)
	self.sampleData = ffi.new("float[?]", self.sampleInfo.length)
	bass.BASS_SampleGetData(self.sample, self.sampleData)
	
	print(self.sampleData[1212323])
	
	self.wave = soul.graphics.Polygon:new({
		mode = "line",
		vertices = {},
		layer = 20
	})
	
	local x = 0
	for i = 44000, 55000 do
		table.insert(self.wave.vertices, x/2)
		x = x + 1
		table.insert(self.wave.vertices, 300 + self.sampleData[i*2+1]*1000)
	end
	self.wave:activate()
end