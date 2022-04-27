local FileManager = {}

local FileTypes = {
	audio = {"wav", "ogg", "mp3"},
	image = {"png", "bmp", "jpg"},
	video = {"mpg", "avi", "mp4", "mpeg", "wmv"},
}

local FileTypeMap = {}
for format, list in pairs(FileTypes) do
	for i = 1, #list do
		FileTypeMap[list[i]] = format
	end
end

local removeExtension = function(fileName)
	local ext = fileName:match("%.([^%.]+)$")
	local format = FileTypeMap[ext]
	return format and fileName:sub(1, -#ext - 2) or fileName, format
end

FileManager.priority = {}
FileManager.paths = {}

local sortPaths = function(a, b)
	return FileManager.priority[a] > FileManager.priority[b]
end

FileManager.getType = function(self, fileName)
	local ext = fileName:match("%.([^%.]+)$")
	return FileTypeMap[ext]
end

FileManager.addPath = function(self, path, priority)
	local paths = self.paths
	local _priority = self.priority
	if not _priority[path] then
		paths[#paths + 1] = path
	end
	_priority[path] = priority or 0
	table.sort(paths, sortPaths)
end

FileManager.removePath = function(self, path)
	local paths = self.paths
	self.priority[path] = nil
	for i = 1, #paths do
		if paths[i] == path then
			return table.remove(paths, i)
		end
	end
end

FileManager.findFile = function(self, fullFileName)
	fullFileName = fullFileName:gsub("\\", "/")
	local fileName, fileType = removeExtension(fullFileName)

	if not fileType then
		return
	end

	for _, path in ipairs(self.paths) do
		local filePath = path .. "/" .. fullFileName
		if love.filesystem.getInfo(filePath) then
			return filePath, fileType
		end
		for _, ext in ipairs(FileTypes[fileType]) do
			local filePath = path .. "/" .. fileName .. "." .. ext
			if love.filesystem.getInfo(filePath) then
				return filePath, fileType
			end
		end
	end
end

return FileManager
