local physfs	= require("aqua.physfs")
local Class		= require("aqua.util.Class")

local MountModel = Class:new()

MountModel.construct = function(self)
	self.mountStatuses = {}
end

MountModel.chartsPath = "userdata/charts"

MountModel.load = function(self)
	self.mountInfo = self.game.configModel.configs.mount
	local mountStatuses = self.mountStatuses

	for _, entry in ipairs(self.mountInfo) do
		entry[1] = entry[1]:match("^(.-)[/]*$")
		entry[2] = entry[2]:match("^(.-)[/]*$")
		local path, mountpoint = entry[1], entry[2]
		local mountStatus = "mounted"
		if not physfs.mount(path, mountpoint, 1) then
			mountStatus = physfs.getLastError()
		end
		mountStatuses[path] = mountStatus
	end
end

MountModel.unload = function(self)
	for _, entry in ipairs(self.mountInfo) do
		local path = entry[1]
		if self.mountStatuses[path] == "mounted" then
			physfs.unmount(path)
		end
	end
end

MountModel.getMountPoint = function(self, path)
	return self.chartsPath .. "/" .. path:gsub("\\", "/"):match("^.+/(.-)$")
end

MountModel.isMountPath = function(self, path)
	for _, entry in ipairs(self.mountInfo) do
		if entry[1]:gsub("\\", "/") == path:gsub("\\", "/") then
			return true
		end
	end
end

MountModel.getRealPath = function(self, path)
	for _, entry in ipairs(self.mountInfo) do
		if path:find(entry[2]) == 1 then
			return path:gsub(entry[2], entry[1])
		end
	end
end

MountModel.isAdded = function(self, path)
	for _, entry in ipairs(self.mountInfo) do
		if entry[1] == path then
			return true
		end
	end
end

MountModel.addPath = function(self, path)
	local mountInfo = self.mountInfo
	mountInfo[#mountInfo + 1] = {path, self:getMountPoint(path)}
end

MountModel.mount = function(self, path)
	assert(physfs.mount(path, self:getMountPoint(path), true))
end

MountModel.unmount = function(self, path)
	assert(physfs.unmount(path))
end

return MountModel
