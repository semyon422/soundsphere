local physfs = require("physfs")
local class = require("class")

---@class sphere.MountModel
---@operator call: sphere.MountModel
local MountModel = class()

function MountModel:new()
	self.mountStatuses = {}
end

MountModel.chartsPath = "userdata/charts"

---@param mountInfo table
function MountModel:load(mountInfo)
	self.mountInfo = mountInfo
	local mountStatuses = self.mountStatuses

	for _, entry in ipairs(self.mountInfo) do
		entry[1] = entry[1]:match("^(.-)[/]*$")
		entry[2] = entry[2]:match("^(.-)[/]*$")
		local path, mountpoint = entry[1], entry[2]
		local mountStatus = "mounted"
		if not physfs.mount(path, mountpoint, true) then
			mountStatus = physfs.getLastError()
		end
		mountStatuses[path] = mountStatus
	end
end

function MountModel:unload()
	for _, entry in ipairs(self.mountInfo) do
		local path = entry[1]
		if self.mountStatuses[path] == "mounted" then
			physfs.unmount(path)
		end
	end
end

---@param path string
---@return string
function MountModel:getMountPoint(path)
	return self.chartsPath .. "/" .. path:gsub("\\", "/"):match("^.+/(.-)$")
end

---@param path string
---@return boolean
function MountModel:isMountPath(path)
	for _, entry in ipairs(self.mountInfo) do
		if entry[1]:gsub("\\", "/") == path:gsub("\\", "/") then
			return true
		end
	end
	return false
end

---@param path string
---@return string?
function MountModel:getRealPath(path)
	for _, entry in ipairs(self.mountInfo) do
		if path:find(entry[2]) == 1 then
			return (path:gsub(entry[2], entry[1]))
		end
	end
end

---@param path string
---@return boolean
function MountModel:isAdded(path)
	for _, entry in ipairs(self.mountInfo) do
		if entry[1] == path then
			return true
		end
	end
	return false
end

---@param path string
function MountModel:addPath(path)
	local mountInfo = self.mountInfo
	mountInfo[#mountInfo + 1] = {path, self:getMountPoint(path)}
end

---@param path string
function MountModel:mount(path)
	assert(physfs.mount(path, self:getMountPoint(path), true))
end

---@param path string
function MountModel:unmount(path)
	assert(physfs.unmount(path))
end

return MountModel
