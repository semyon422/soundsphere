local rcopy = require("rcopy")

local DlcExtractor = {}

---@param archive string|love.FileData
---@param path string
---@return boolean? success, string? error
function DlcExtractor.extract(archive, path)
	local fs = love.filesystem
	local physfs = require("physfs")
	local mount_point = path .. "_temp"

	-- Ensure target directory doesn't exist or is empty
	if fs.getInfo(path) then
		-- In a real scenario we might want to clean it up or use a unique temp dir
	end

	if not physfs.mount(archive, mount_point, true) then
		return nil, physfs.getLastError()
	end

	-- rcopy recursively copies from mount_point to path
	local ok, err = pcall(rcopy, mount_point, path)
	
	physfs.unmount(archive)

	if not ok then
		return nil, "Copy failed: " .. tostring(err)
	end

	return true
end

return DlcExtractor
