local aquathread = require("aqua.thread")

return aquathread.async(function(archive, path, remove)
	require("love.filesystem")
	local aquafs = require("aqua.filesystem")
	local rcopy = require("aqua.util.rcopy")
	local mount = path .. "_temp"
	local status, err = pcall(aquafs.mount, archive, mount, true)
	if not status then
		print(err)
		love.filesystem.remove(archive)
		return
	end
	rcopy(mount, path)
	assert(aquafs.unmount(archive))
	if remove then
		love.filesystem.remove(archive)
	end
	return true
end)
