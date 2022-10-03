local aquathread = require("aqua.thread")

return aquathread.async(function(archive, path, remove)
	require("love.filesystem")
	local physfs = require("aqua.physfs")
	local rcopy = require("aqua.util.rcopy")
	local mount = path .. "_temp"
	if not physfs.mount(archive, mount, true) then
		if remove then
			love.filesystem.remove(archive)
		end
		return nil, physfs.getLastError()
	end
	rcopy(mount, path)
	assert(physfs.unmount(archive))
	if remove then
		love.filesystem.remove(archive)
	end
	return true
end)
