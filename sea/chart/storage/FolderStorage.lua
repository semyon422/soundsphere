local IKeyValueStorage = require("sea.chart.storage.IKeyValueStorage")
local io_util = require("io_util")
local path_util = require("path_util")

---@class sea.FolderStorage: sea.IKeyValueStorage
---@operator call: sea.FolderStorage
local FolderStorage = IKeyValueStorage + {}

---@param prefix string
function FolderStorage:new(prefix)
	self.prefix = prefix
end

---@param key string
---@return string?
---@return string?
function FolderStorage:get(key)
	local path = path_util.join(self.prefix, key)
	return io_util.read_file_safe(path)
end

---@param key string
---@param value string
---@return true?
---@return string?
function FolderStorage:set(key, value)
	local path = path_util.join(self.prefix, key)
	return io_util.write_file_safe(path, value)
end

return FolderStorage
