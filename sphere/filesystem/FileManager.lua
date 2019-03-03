local FileManager = {}

FileManager.AudioFormats = {
	"wav", "ogg", "mp3"
}

FileManager.Formats = {
	audio = FileManager.AudioFormats
}

FileManager.priority = {}
FileManager.paths = {}

local sortPaths = function(a, b)
	return FileManager.priority[a] > FileManager.priority[b]
end

FileManager.addPath = function(self, path, priority)
	if not self.priority[path] then
		self.paths[#self.paths + 1] = path
	end
	self.priority[path] = priority or 0
	table.sort(self.paths, sortPaths)
end

FileManager.removePath = function(self, path)
	self.priority[path] = nil
	for i = 1, #self.paths do
		if self.paths[i] == path then
			self.paths[i] = nil
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

return FileManager
