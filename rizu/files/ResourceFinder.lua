local class = require("class")
local path_util = require("path_util")

---@alias rizu.ResourceFormat "audio"|"image"|"video"

---@type {[rizu.ResourceFormat]: string[]}
local format_extensions = {
	audio = {"wav", "ogg", "mp3"},
	image = {"png", "bmp", "jpg"},
	video = {"mpg", "avi", "mp4", "mpeg", "wmv"},
}

---@type {[string]: rizu.ResourceFormat}
local extension_format = {}
for format, list in pairs(format_extensions) do
	for i = 1, #list do
		extension_format[list[i]] = format
	end
end

---@class rizu.ResourceFinder
---@operator call: rizu.ResourceFinder
local ResourceFinder = class()

---@param fs fs.IFilesystem
function ResourceFinder:new(fs)
	self.fs = fs
	self:reset()
end

function ResourceFinder:reset()
	---@type string[]
	self.paths = {}
	---@type {[string]: string[]}
	self.path_files = {}
end

---@param path string
function ResourceFinder:addPath(path)
	path = assert(path, "missing path")
	table.insert(self.paths, path)
	self.path_files[path] = self:getFilesRecursive(path)
end

---@param path string
---@param list table?
---@param prefix string?
---@return table
function ResourceFinder:getFilesRecursive(path, list, prefix)
	list = list or {}
	prefix = prefix or ""
	for _, file in ipairs(self.fs:getDirectoryItems(path)) do
		local info = assert(self.fs:getInfo(path .. "/" .. file))
		if info.type == "directory" then
			self:getFilesRecursive(path .. "/" .. file, list, prefix .. file .. "/")
		else
			table.insert(list, prefix .. file)
		end
	end
	return list
end

---@param ext string?
---@return rizu.ResourceFormat?
function ResourceFinder:getFormat(ext)
	return ext and extension_format[ext:lower()]
end

---@param req_name_ext string
---@return string?
function ResourceFinder:findFile(req_name_ext)
	req_name_ext = path_util.fix_separators(req_name_ext)
	req_name_ext = req_name_ext:gsub("^/", "")

	local req_name, req_ext = path_util.name_ext(req_name_ext)
	local format = self:getFormat(req_ext)
	if not format then
		return
	end

	local extensions = format_extensions[format]

	for _, path in ipairs(self.paths) do
		local req_path = path .. "/" .. req_name_ext
		if self.fs:getInfo(req_path) then
			return req_path
		end

		local files = self.path_files[path]

		for _, name_ext in ipairs(files) do
			if name_ext:lower() == req_name_ext:lower() then
				return path .. "/" .. name_ext
			end
		end

		for _, check_ext in ipairs(extensions) do
			for _, name_ext in ipairs(files) do
				local _name, _ext = path_util.name_ext(name_ext)
				if _ext and _name:lower() == req_name:lower() and _ext:lower() == check_ext then
					return path .. "/" .. name_ext
				end
			end
		end
	end
end

return ResourceFinder
