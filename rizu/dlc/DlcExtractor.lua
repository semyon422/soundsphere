local LoveFilesystem = require("fs.LoveFilesystem")
local ZipFilesystem = require("fs.ZipFilesystem")
local fs_util = require("fs.util")

local DlcExtractor = {}

---@param archive string
---@param path string
---@return boolean? success, string? error
function DlcExtractor.extract(archive, path)
	local lfs = LoveFilesystem()
	local data, err = lfs:read(archive)

	if not data then
		return nil, "Failed to read archive: " .. tostring(err)
	end

	local ok, zfs_or_err = pcall(ZipFilesystem --[[@as fun(): fs.ZipFilesystem]], data)
	if not ok then
		return nil, "Failed to load zip: " .. tostring(zfs_or_err)
	end

	local ok, err = pcall(fs_util.copy, "", path, zfs_or_err, lfs)
	if not ok then
		return nil, "Extraction failed: " .. tostring(err)
	end

	return true
end

return DlcExtractor
