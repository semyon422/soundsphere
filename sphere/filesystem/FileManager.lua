local FileManager = {}

FileManager.AudioFormats = {
	"wav", "ogg", "mp3"
}

FileManager.ImageFormats = {
	"png", "bmp", "jpg"
}

FileManager.VideoFormats = {
	"mpg", "avi", "mp4", "mpeg", "wmv"
}

FileManager.Formats = {
	audio = FileManager.AudioFormats,
	image = FileManager.ImageFormats,
	video = FileManager.VideoFormats
}

FileManager.priority = {}
FileManager.paths = {}

FileManager.getType = function(self, path)
	for type, formats in pairs(self.Formats) do
		for _, ext in ipairs(formats) do
			if path:lower():find("%." .. ext .. "$") then
				return type
			end
		end
	end
end

local sortPaths = function(a, b)
	return FileManager.priority[a] > FileManager.priority[b]
end

FileManager.addPath = function(self, path, priority)
	local paths = self.paths
	local spriority = self.priority
	if not spriority[path] then
		paths[#paths + 1] = path
	end
	spriority[path] = priority or 0
	table.sort(paths, sortPaths)
end

FileManager.removePath = function(self, path)
	local paths = self.paths
	self.priority[path] = nil
	for i = 1, #paths do
		if paths[i] == path then
			table.remove(paths, i)
		end
	end
end

FileManager.findFile = function(self, fileName, fileType)
	local originalFileName = fileName:gsub("\\", "/")
	local fileName = self:removeExtension(originalFileName, fileType)

	for _, path in ipairs(self.paths) do
		local originalFilePath = path .. "/" .. originalFileName
		local info = love.filesystem.getInfo(originalFilePath)
		if info and self:getType(originalFileName) == fileType then
			return originalFilePath
		end
		for _, format in ipairs(self.Formats[fileType]) do
			local filePath = path .. "/" .. fileName .. "." .. format
			local info = love.filesystem.getInfo(filePath)
			if info then
				return filePath
			end
		end
	end
end

FileManager.removeExtension = function(self, fileName, fileType)
	for _, format in ipairs(self.Formats[fileType]) do
		local position = fileName:lower():find("%." .. format .. "$")
		if position then
			return fileName:sub(1, position - 1)
		end
	end

	return fileName
end

return FileManager
