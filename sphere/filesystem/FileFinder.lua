local FileFinder = {}

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
	ext = ext and ext:lower()
	local format = FileTypeMap[ext]
	return format and fileName:sub(1, -#ext - 2) or fileName, format
end

FileFinder.priority = {}
FileFinder.paths = {}
FileFinder.fileLists = {}

local sortPaths = function(a, b)
	return FileFinder.priority[a] > FileFinder.priority[b]
end

FileFinder.reset = function(self)
	self.priority = {}
	self.paths = {}
	self.fileLists = {}
end

FileFinder.getType = function(self, fileName)
	local ext = fileName:match("%.([^%.]+)$")
	ext = ext and ext:lower()
	return FileTypeMap[ext]
end

FileFinder.addPath = function(self, path, priority)
	local paths = self.paths
	local _priority = self.priority
	if not _priority[path] then
		paths[#paths + 1] = path
	end
	_priority[path] = priority or 0
	table.sort(paths, sortPaths)
end

FileFinder.removePath = function(self, path)
	local paths = self.paths
	self.priority[path] = nil
	for i = 1, #paths do
		if paths[i] == path then
			return table.remove(paths, i)
		end
	end
end

FileFinder.getFileListRecursive = function(self, path, list, prefix)
	list = list or {}
	prefix = prefix or ""
	local files = love.filesystem.getDirectoryItems(path)
	for i = 1, #files do
		local info = love.filesystem.getInfo(path .. "/" .. files[i])
		if info.type == "directory" then
			self:getFileListRecursive(path .. "/" .. files[i], list, prefix .. files[i] .. "/")
		else
			table.insert(list, prefix .. files[i])
		end
	end
	return list
end

FileFinder.getFileList = function(self, path)
	local fileLists = self.fileLists
	if fileLists[path] then
		return fileLists[path]
	end
	fileLists[path] = self:getFileListRecursive(path)
	return fileLists[path]
end

FileFinder.findFile = function(self, fullFileName)
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
		local files = self:getFileList(path)
		for _, file in ipairs(files) do
			if file:lower() == fullFileName:lower() then
				return path .. "/" .. file, fileType
			end
		end
		for _, file in ipairs(files) do
			local trueFileName, trueFileType = removeExtension(file)
			if fileName:lower() == trueFileName:lower() and fileType == trueFileType then
				return path .. "/" .. file, fileType
			end
		end
	end
end

return FileFinder
