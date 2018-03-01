FileManager = createClass()

FileManager.AudioFormats = {
	"wav", "ogg", "mp3"
}

FileManager.Formats = {
	audio = FileManager.AudioFormats
}

FileManager.addPath = function(self, path)
	if not self.paths then
		self.paths = {}
	end
	
	table.insert(self.paths, path)
end

FileManager.removePath = function(self, path)
	for pathIndex, currentPath in pairs(self.paths) do
		if path == currentPath then
			table.remove(self.paths, pathIndex)
		end
	end
end

FileManager.findFile = function(self, fileName, fileType)
	local fileName = self:removeExtension(fileName, fileType)
	
	for _, path in ipairs(self.paths) do
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