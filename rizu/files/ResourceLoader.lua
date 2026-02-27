local class = require("class")
local table_util = require("table_util")
local OJM = require("o2jam.OJM")
local path_util = require("path_util")
local Video = require("Video")

---@class rizu.ResourceLoader
---@operator call: rizu.ResourceLoader
local ResourceLoader = class()

---@param fs fs.IFilesystem
---@param resource_finder rizu.ResourceFinder
function ResourceLoader:new(fs, resource_finder)
	self.fs = fs
	self.resource_finder = resource_finder

	---@type {[string|integer]: string}
	self.file_paths = {}
	---@type {[string]: string}
	self.file_contents = {}
	---@type {[string]: string}
	self.file_formats = {}

	---@type {[string]: true}
	self.file_pendings = {}

	---@type {[string]: string}
	self.resources = setmetatable({}, {__index = function(t, k)
		return self:getResource(k)
	end})
end

---@param resources ncdk.Resources
function ResourceLoader:load(resources)
	local fs = self.fs
	local resource_finder = self.resource_finder

	self.file_paths = {}
	local file_paths = self.file_paths
	self.file_formats = {}

	---@type string[]
	local new_paths = {}

	for _type, paths in resources:iter() do
		local name = paths[1]
		for _, path in ipairs(paths) do
			local found_path = resource_finder:findFile(path, _type)
			if found_path then
				file_paths[name] = found_path
				table.insert(new_paths, found_path)

				local _, ext = path_util.name_ext(found_path)
				self.file_formats[found_path] = resource_finder:getFormat(ext)

				if _type == "ojm" then
					local data = fs:read(found_path)
					if data then
						local ojm = OJM(data)
						for id, sample_data in pairs(ojm.samples) do
							local virtual_path = found_path .. ":" .. id
							file_paths[id] = virtual_path
							self.file_contents[virtual_path] = sample_data
							table.insert(new_paths, virtual_path)
						end
					end
				end
				break
			end
		end
	end

	---@type string[]
	local old_paths = {}
	for path in pairs(self.file_contents) do
		table.insert(old_paths, path)
	end

	local new, old = table_util.array_update2(new_paths, old_paths)

	for _, path in ipairs(old) do
		local resource = self.file_contents[path]
		if type(resource) == "table" and resource.release then
			resource:release()
		end
		self.file_contents[path] = nil
		self.file_formats[path] = nil
	end

	self.file_pendings = {}
	local file_pendings = self.file_pendings
	for _, path in ipairs(new) do
		file_pendings[path] = true
	end

	local path = next(file_pendings)
	while path do
		file_pendings[path] = nil
		if not self.file_contents[path] then
			local content = fs:read(path)
			if content then
				local format = self.file_formats[path]
				if format == "image" and love and love.image and love.graphics then
					local fileData = love.filesystem.newFileData(content, path)
					local imageData = love.image.newImageData(fileData)
					self.file_contents[path] = love.graphics.newImage(imageData)
				elseif format == "video" and Video then
					local fileData = love.filesystem.newFileData(content, path)
					self.file_contents[path] = assert(Video(fileData))
				else
					self.file_contents[path] = content
				end
			end
		end
		path = next(file_pendings)
	end
end

function ResourceLoader:rewind()
	for _, resource in pairs(self.file_contents) do
		if type(resource) == "table" and resource.rewind then
			resource:rewind()
		end
	end
end

---@param name string
---@return string?
function ResourceLoader:getResource(name)
	return self.file_contents[self.file_paths[name]]
end

return ResourceLoader
