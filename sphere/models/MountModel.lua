local aquafs	= require("aqua.filesystem")
local Class		= require("aqua.util.Class")
local json		= require("json")

local MountModel = Class:new()

MountModel.configPath = "userdata/mount.json"
MountModel.chartsPath = "userdata/charts"

MountModel.load = function(self)
	self.mountInfo = self.configModel:getConfig("mount")

	for _, entry in ipairs(self.mountInfo) do
		aquafs.mount(entry[1], entry[2], 1)
	end
end

MountModel.unload = function(self)
	for _, entry in ipairs(self.mountInfo) do
		aquafs.unmount(entry[1])
	end
end

MountModel.getMountPoint = function(self, path)
	return self.chartsPath .. "/" .. path:gsub("\\", "/"):match("^.+/(.-)$")
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
	aquafs.mount(path, self:getMountPoint(path), 1)
end

MountModel.unmount = function(self, path)
	aquafs.unmount(path)
end

return MountModel
