require("libraries.packagePath")

ffi = require("ffi")
require("bass_ffi")
require("love.filesystem")

loadAudio = function(event)
	local file = love.filesystem.newFile(event.filePath)
	file:open("r")
	event.resource = bass.BASS_SampleLoad(true, file:read(), 0, file:getSize(), 65535, 0)
	file:close()
end

receiveMessageCallback = function(event)
	if event.dataType == "audio" then
		loadAudio(event)
		sendMessage(event)
	end
end