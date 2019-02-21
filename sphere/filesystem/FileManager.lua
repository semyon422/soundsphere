local FileManager = {}

FileManager.AudioFormats = {
	"wav", "ogg", "mp3"
}

FileManager.Formats = {
	audio = FileManager.AudioFormats
}

FileManager.paths = {}

FileManager.addPath = function(self, path)
	self.paths[path] = true
end

FileManager.removePath = function(self, path)
	self.paths[path] = nil
end

FileManager.findFile = function(self, fileName, fileType)
	local fileName = self:removeExtension(fileName, fileType)
	
	for path in pairs(self.paths) do
		for _, format in ipairs(self.Formats[fileType]) do
			local filePath = path .. "/" .. fileName .. "." .. format
			if love.filesystem.exists(filePath) then
				return filePath
			end
		end
	end
end

FileManager.removeExtension = function(self, fileName, fileType)
	for _, format in ipairs(self.Formats[fileType]) do
		if fileName:find("%." .. format .. "$") then
			return fileName:match("^(.+)%." .. format .. "$")
		end
	end
	
	return fileName
end

return FileManager
