local thread = require("thread")

return thread.async(function(archive, path)
	require("love.filesystem")
	local physfs = require("physfs")
	local rcopy = require("rcopy")
	local mount = path .. "_temp"

	local fs = love.filesystem
	if type(archive) == "string" then
		fs = physfs
	end

	if not fs.mount(archive, mount, true) then
		return nil, physfs.getLastError()
	end

	rcopy(mount, path)

	assert(fs.unmount(archive))

	return true
end)
